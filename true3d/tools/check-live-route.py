#!/usr/bin/env python3
"""Verify True3D's deterministic live-benchmark route against engine math.

The route itself, benchmark constants, built-in level, trigonometry table, and
axis bases are read from the C sources.  This is deliberately independent of
the calculator binary: it mirrors ``engine_init()`` and ``engine_update()`` so
route edits cannot silently change crossings or the state hashes written to
T3DLIVE.
"""

from __future__ import annotations

import ast
import re
import struct
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Iterable, Sequence


ROOT = Path(__file__).resolve().parents[1]
LIVE_PATH = ROOT / "src" / "live_benchmark.c"
ENGINE_PATH = ROOT / "src" / "engine.c"
ENGINE_HEADER_PATH = ROOT / "src" / "engine.h"
LEVEL_PATH = ROOT / "src" / "level.c"
LEVEL_HEADER_PATH = ROOT / "src" / "level.h"

FNV_OFFSET = 2166136261
FNV_PRIME = 16777619


class CheckError(ValueError):
    """Raised when source parsing or route verification fails."""


def strip_comments(source: str) -> str:
    source = re.sub(r"/\*.*?\*/", "", source, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", "", source)


def logical_lines(source: str) -> list[str]:
    return re.sub(r"\\\r?\n", " ", source).splitlines()


class MacroResolver:
    """Resolve the small integer-expression subset used by these sources."""

    def __init__(self, sources: Iterable[str]) -> None:
        self.raw: dict[str, str] = {}
        self.cache: dict[str, int] = {}
        for source in sources:
            for line in logical_lines(strip_comments(source)):
                match = re.match(r"\s*#define\s+([A-Za-z_]\w*)\s+(.+?)\s*$", line)
                if match and not match.group(2).startswith("("):
                    self.raw[match.group(1)] = match.group(2).strip()
                elif match:
                    # Object-like expressions often begin with a parenthesis.
                    self.raw[match.group(1)] = match.group(2).strip()

    def value(self, name: str) -> int:
        if name in self.cache:
            return self.cache[name]
        if name not in self.raw:
            raise CheckError(f"unknown source constant {name}")
        # A temporary sentinel makes recursive aliases fail clearly.
        self.cache[name] = 0
        try:
            value = evaluate_expression(self.raw[name], self.value)
        except Exception:
            self.cache.pop(name, None)
            raise
        self.cache[name] = value
        return value


def evaluate_expression(expression: str, resolve: Callable[[str], int]) -> int:
    expression = re.sub(r"\s+", " ", expression.strip())
    expression = re.sub(
        r"\((?:u?int(?:8|16|24|32)_t|fixed_t|size_t)\)", "", expression
    )
    expression = re.sub(r"(?<=\d)[uUlL]+\b", "", expression)
    tree = ast.parse(expression, mode="eval")

    def visit(node: ast.AST) -> int:
        if isinstance(node, ast.Expression):
            return visit(node.body)
        if isinstance(node, ast.Constant):
            if isinstance(node.value, int):
                return node.value
            if isinstance(node.value, str) and len(node.value) == 1:
                return ord(node.value)
            raise CheckError(f"unsupported constant in {expression!r}")
        if isinstance(node, ast.Name):
            return resolve(node.id)
        if isinstance(node, ast.UnaryOp):
            value = visit(node.operand)
            if isinstance(node.op, ast.USub):
                return -value
            if isinstance(node.op, ast.UAdd):
                return value
            if isinstance(node.op, ast.Invert):
                return ~value
        if isinstance(node, ast.BinOp):
            left = visit(node.left)
            right = visit(node.right)
            if isinstance(node.op, ast.Add):
                return left + right
            if isinstance(node.op, ast.Sub):
                return left - right
            if isinstance(node.op, ast.Mult):
                return left * right
            if isinstance(node.op, ast.LShift):
                return left << right
            if isinstance(node.op, ast.RShift):
                return left >> right
            if isinstance(node.op, ast.BitOr):
                return left | right
            if isinstance(node.op, ast.BitAnd):
                return left & right
            if isinstance(node.op, ast.BitXor):
                return left ^ right
            if isinstance(node.op, (ast.Div, ast.FloorDiv)):
                return trunc_div(left, right)
        raise CheckError(f"unsupported C expression {expression!r}")

    return visit(tree)


def extract_initializer(source: str, declaration: str) -> str:
    clean = strip_comments(source)
    match = re.search(declaration + r"\s*=\s*", clean, flags=re.DOTALL)
    if not match:
        raise CheckError(f"initializer not found: {declaration}")
    start = clean.find("{", match.end())
    if start < 0:
        raise CheckError(f"opening brace not found: {declaration}")
    depth = 0
    quote: str | None = None
    escaped = False
    for index in range(start, len(clean)):
        char = clean[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in "\"'":
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return clean[start : index + 1]
    raise CheckError(f"unterminated initializer: {declaration}")


def parse_numeric_initializer(text: str, resolver: MacroResolver) -> list[object]:
    index = 0

    def skip_space() -> None:
        nonlocal index
        while index < len(text) and text[index].isspace():
            index += 1

    def value() -> object:
        nonlocal index
        skip_space()
        if index >= len(text):
            raise CheckError("unexpected end of initializer")
        if text[index] == "{":
            index += 1
            result: list[object] = []
            skip_space()
            while index < len(text) and text[index] != "}":
                result.append(value())
                skip_space()
                if index < len(text) and text[index] == ",":
                    index += 1
                    skip_space()
                elif index >= len(text) or text[index] != "}":
                    raise CheckError("expected comma or closing brace")
            if index >= len(text):
                raise CheckError("unterminated nested initializer")
            index += 1
            return result

        start = index
        parentheses = 0
        quote: str | None = None
        escaped = False
        while index < len(text):
            char = text[index]
            if quote is not None:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = None
                index += 1
                continue
            if char in "\"'":
                quote = char
            elif char == "(":
                parentheses += 1
            elif char == ")":
                parentheses -= 1
            elif parentheses == 0 and char in ",}":
                break
            index += 1
        expression = text[start:index].strip()
        if not expression:
            raise CheckError("empty initializer expression")
        return evaluate_expression(expression, resolver.value)

    parsed = value()
    skip_space()
    if index != len(text):
        raise CheckError("trailing data after initializer")
    if not isinstance(parsed, list):
        raise CheckError("top-level initializer is not a list")
    return parsed


@dataclass(frozen=True)
class RouteStep:
    frames: int
    move_axis: int
    turn_axis: int
    look_axis: int
    buttons: int
    section: int


@dataclass(frozen=True)
class Section:
    name: str
    flags: int


def parse_route(source: str, resolver: MacroResolver) -> list[RouteStep]:
    block = extract_initializer(
        source, r"static\s+const\s+LiveRouteStep\s+live_route\s*\[\s*\]"
    )
    rows = re.findall(r"\{([^{}]+)\}", block[1:-1])
    route: list[RouteStep] = []
    for row in rows:
        fields = [part.strip() for part in row.split(",") if part.strip()]
        if len(fields) != 6:
            raise CheckError(f"route row has {len(fields)} fields: {row!r}")
        values = [evaluate_expression(field, resolver.value) for field in fields]
        route.append(RouteStep(*values))
    if not route:
        raise CheckError("live_route contains no rows")
    return route


def parse_sections(source: str, resolver: MacroResolver) -> list[Section]:
    block = extract_initializer(
        source, r"static\s+const\s+LiveSection\s+live_sections\s*\[[^\]]+\]"
    )
    sections: list[Section] = []
    for match in re.finditer(r'\{\s*"([^"]+)"\s*,(.*?)\}', block, re.DOTALL):
        sections.append(
            Section(match.group(1), evaluate_expression(match.group(2), resolver.value))
        )
    if not sections:
        raise CheckError("live_sections contains no rows")
    return sections


@dataclass
class Vec3:
    x: int = 0
    y: int = 0
    z: int = 0

    def copy(self) -> "Vec3":
        return Vec3(self.x, self.y, self.z)


@dataclass(frozen=True)
class Room:
    minimum_x: int
    maximum_x: int
    minimum_y: int
    maximum_y: int
    minimum_z: int
    maximum_z: int


@dataclass
class Portal:
    center: Vec3
    right: Vec3
    up: Vec3
    normal: Vec3
    half_width: int
    half_height: int
    room: int
    host_face: int
    linked: int
    active: bool


@dataclass
class State:
    position: Vec3 = field(default_factory=Vec3)
    velocity: Vec3 = field(default_factory=Vec3)
    right: Vec3 = field(default_factory=Vec3)
    up: Vec3 = field(default_factory=Vec3)
    forward: Vec3 = field(default_factory=Vec3)
    yaw: int = 64
    pitch: int = 0
    room: int = 0
    previous_buttons: int = 0
    grounded: int = 1
    dev_mode: int = 0
    render_shift: int = 0


@dataclass(frozen=True)
class Crossing:
    frame: int
    portal: int
    source_room: int
    destination_room: int
    section: int
    state_hash: int
    position: tuple[int, int, int]
    yaw: int
    pitch: int


@dataclass(frozen=True)
class SectionEnd:
    frame: int
    section: int
    state_hash: int
    position: tuple[int, int, int]
    velocity: tuple[int, int, int]
    yaw: int
    pitch: int
    room: int
    grounded: int
    dev_mode: int
    render_shift: int


@dataclass(frozen=True)
class SimulationResult:
    state: State
    crossings: tuple[Crossing, ...]
    section_ends: tuple[SectionEnd, ...]
    route_state_hash: int
    frame_state_hashes: tuple[int, ...]


class EngineModel:
    def __init__(
        self,
        resolver: MacroResolver,
        quarter_sine: Sequence[int],
        rooms: Sequence[Room],
        portals: Sequence[Portal],
        spawn: tuple[int, int, int, int],
    ) -> None:
        self.fixed_shift = resolver.value("FIXED_SHIFT")
        self.fixed_one = 1 << self.fixed_shift
        self.move_speed = resolver.value("MOVE_SPEED")
        self.turn_speed = resolver.value("TURN_UNITS_PER_SECOND")
        self.pitch_speed = resolver.value("PITCH_UNITS_PER_SECOND")
        self.pitch_limit = resolver.value("PITCH_LIMIT")
        self.gravity = resolver.value("GRAVITY")
        self.jump_speed = resolver.value("JUMP_SPEED")
        self.player_radius = resolver.value("PLAYER_RADIUS")
        self.player_eye_height = resolver.value("PLAYER_EYE_HEIGHT")
        self.ceiling_margin = resolver.value("CEILING_MARGIN")
        self.portal_margin = resolver.value("PORTAL_APERTURE_MARGIN")
        self.quarter_sine = tuple(quarter_sine)
        self.rooms = tuple(rooms)
        self.portals = tuple(portals)
        self.spawn_room, self.spawn_x, self.spawn_y, self.spawn_z = spawn
        self.button_jump = resolver.value("ENGINE_BUTTON_JUMP")
        self.button_orange = resolver.value("ENGINE_BUTTON_ORANGE_PORTAL")
        self.button_blue = resolver.value("ENGINE_BUTTON_BLUE_PORTAL")
        self.button_dev = resolver.value("ENGINE_BUTTON_DEV_MODE")
        self.button_down = resolver.value("ENGINE_BUTTON_FLY_DOWN")
        self.button_resolution = resolver.value("ENGINE_BUTTON_RESOLUTION")

    @staticmethod
    def signed24(value: int) -> int:
        value &= 0xFFFFFF
        return value - 0x1000000 if value & 0x800000 else value

    def fixed_mul(self, left: int, right: int) -> int:
        # Signed right shift on the eZ80 toolchain is arithmetic, matching Python.
        return self.signed24((left * right) >> self.fixed_shift)

    def angle_sine(self, angle: int) -> int:
        angle &= 0xFF
        quadrant = angle >> 6
        offset = angle & 63
        if quadrant == 0:
            return self.quarter_sine[offset]
        if quadrant == 1:
            return self.quarter_sine[64 - offset]
        if quadrant == 2:
            return -self.quarter_sine[offset]
        return -self.quarter_sine[64 - offset]

    def rebuild_basis(self, state: State) -> None:
        magnitude = abs(state.pitch)
        sine_yaw = self.angle_sine(state.yaw)
        cosine_yaw = self.angle_sine(state.yaw + 64)
        sine_pitch = self.quarter_sine[magnitude]
        cosine_pitch = self.quarter_sine[64 - magnitude]
        if state.pitch < 0:
            sine_pitch = -sine_pitch
        state.right = Vec3(-sine_yaw, cosine_yaw, 0)
        state.forward = Vec3(
            self.fixed_mul(cosine_pitch, cosine_yaw),
            self.fixed_mul(cosine_pitch, sine_yaw),
            sine_pitch,
        )
        state.up = Vec3(
            -self.fixed_mul(sine_pitch, cosine_yaw),
            -self.fixed_mul(sine_pitch, sine_yaw),
            cosine_pitch,
        )

    @staticmethod
    def subtract(left: Vec3, right: Vec3) -> Vec3:
        return Vec3(left.x - right.x, left.y - right.y, left.z - right.z)

    @staticmethod
    def add(left: Vec3, right: Vec3) -> Vec3:
        return Vec3(left.x + right.x, left.y + right.y, left.z + right.z)

    def scale(self, vector: Vec3, amount: int) -> Vec3:
        return Vec3(
            self.fixed_mul(vector.x, amount),
            self.fixed_mul(vector.y, amount),
            self.fixed_mul(vector.z, amount),
        )

    @staticmethod
    def axis_component(vector: Vec3, axis: Vec3) -> int:
        if axis.x:
            return vector.x if axis.x > 0 else -vector.x
        if axis.y:
            return vector.y if axis.y > 0 else -vector.y
        return vector.z if axis.z > 0 else -vector.z

    @staticmethod
    def add_axis(vector: Vec3, axis: Vec3, amount: int) -> None:
        if axis.x:
            vector.x += amount if axis.x > 0 else -amount
        elif axis.y:
            vector.y += amount if axis.y > 0 else -amount
        else:
            vector.z += amount if axis.z > 0 else -amount

    def transform_vector(self, portal_index: int, vector: Vec3) -> Vec3:
        source = self.portals[portal_index]
        destination = self.portals[source.linked]
        result = Vec3()
        self.add_axis(result, destination.right, -self.axis_component(vector, source.right))
        self.add_axis(result, destination.up, self.axis_component(vector, source.up))
        self.add_axis(
            result, destination.normal, -self.axis_component(vector, source.normal)
        )
        result.x = self.signed24(result.x)
        result.y = self.signed24(result.y)
        result.z = self.signed24(result.z)
        return result

    def transform_point(self, portal_index: int, point: Vec3) -> Vec3:
        source = self.portals[portal_index]
        destination = self.portals[source.linked]
        result = self.add(
            destination.center,
            self.transform_vector(portal_index, self.subtract(point, source.center)),
        )
        return Vec3(*(self.signed24(value) for value in (result.x, result.y, result.z)))

    def recover_angles(self, state: State) -> None:
        vertical = abs(state.forward.z)
        best_pitch = 0
        best_error = 0x7FFFFF
        for pitch in range(self.pitch_limit + 1):
            error = abs(vertical - self.quarter_sine[pitch])
            if error < best_error:
                best_error = error
                best_pitch = pitch
        state.pitch = -best_pitch if state.forward.z < 0 else best_pitch

        if abs(state.forward.x) + abs(state.forward.y) > 8:
            heading_source = 0
        elif abs(state.right.x) + abs(state.right.y) > 8:
            heading_source = 1
        else:
            heading_source = 2
        best_yaw = state.yaw
        best_score = -(1 << 31)
        for angle in range(256):
            sine = self.angle_sine(angle)
            cosine = self.angle_sine(angle + 64)
            if heading_source == 0:
                score = state.forward.x * cosine + state.forward.y * sine
            elif heading_source == 1:
                score = -state.right.x * sine + state.right.y * cosine
            else:
                score = state.up.x * cosine + state.up.y * sine
                if state.pitch > 0:
                    score = -score
            if score > best_score:
                best_score = score
                best_yaw = angle
        state.yaw = best_yaw
        self.rebuild_basis(state)

    def crossing_extent(self, state: State, portal: Portal) -> int:
        if not state.dev_mode and portal.normal.z > self.fixed_one // 2:
            return self.player_eye_height
        return self.player_radius

    def try_crossing(self, state: State, start: Vec3, candidate: Vec3) -> int | None:
        for portal_index, portal in enumerate(self.portals):
            if (
                not portal.active
                or not self.portals[portal.linked].active
                or portal.room != state.room
            ):
                continue
            start_distance = self.axis_component(
                self.subtract(start, portal.center), portal.normal
            )
            end_distance = self.axis_component(
                self.subtract(candidate, portal.center), portal.normal
            )
            source_extent = self.crossing_extent(state, portal)
            destination_extent = self.crossing_extent(
                state, self.portals[portal.linked]
            )
            start_distance -= source_extent
            end_distance -= source_extent
            if (
                start_distance < 0
                or end_distance > 0
                or (start_distance == 0 and end_distance == 0)
            ):
                continue
            fraction = trunc_div(
                start_distance * self.fixed_one, start_distance - end_distance
            )
            hit = self.subtract(
                self.add(
                    start,
                    self.scale(self.subtract(candidate, start), fraction),
                ),
                portal.center,
            )
            if (
                abs(self.axis_component(hit, portal.right))
                > portal.half_width - self.portal_margin
                or abs(self.axis_component(hit, portal.up))
                > portal.half_height - self.portal_margin
            ):
                continue

            transformed = self.transform_point(portal_index, candidate)
            candidate.x, candidate.y, candidate.z = (
                transformed.x,
                transformed.y,
                transformed.z,
            )
            state.velocity = self.transform_vector(portal_index, state.velocity)
            state.right = self.transform_vector(portal_index, state.right)
            state.up = self.transform_vector(portal_index, state.up)
            state.forward = self.transform_vector(portal_index, state.forward)
            self.recover_angles(state)
            state.room = self.portals[portal.linked].room
            self.add_axis(
                candidate,
                self.portals[portal.linked].normal,
                source_extent + destination_extent + 16,
            )
            candidate.x = self.signed24(candidate.x)
            candidate.y = self.signed24(candidate.y)
            candidate.z = self.signed24(candidate.z)
            state.grounded = 0
            return portal_index
        return None

    def collide(self, state: State, position: Vec3) -> None:
        room = self.rooms[state.room]
        minimum_x = room.minimum_x + self.player_radius
        maximum_x = room.maximum_x - self.player_radius
        minimum_y = room.minimum_y + self.player_radius
        maximum_y = room.maximum_y - self.player_radius
        minimum_z = room.minimum_z + (
            self.player_radius if state.dev_mode else self.player_eye_height
        )
        maximum_z = room.maximum_z - (
            self.player_radius if state.dev_mode else self.ceiling_margin
        )
        if position.x < minimum_x:
            position.x = minimum_x
            state.velocity.x = 0
        elif position.x > maximum_x:
            position.x = maximum_x
            state.velocity.x = 0
        if position.y < minimum_y:
            position.y = minimum_y
            state.velocity.y = 0
        elif position.y > maximum_y:
            position.y = maximum_y
            state.velocity.y = 0
        if position.z <= minimum_z:
            position.z = minimum_z
            if state.velocity.z < 0:
                state.velocity.z = 0
            state.grounded = int(not state.dev_mode)
        else:
            state.grounded = 0
        if position.z > maximum_z:
            position.z = maximum_z
            if state.velocity.z > 0:
                state.velocity.z = 0

    def initial_state(self) -> State:
        state = State(
            position=Vec3(self.spawn_x, self.spawn_y, self.spawn_z),
            room=self.spawn_room,
        )
        self.rebuild_basis(state)
        self.collide(state, state.position)
        return state

    def update(
        self,
        state: State,
        step: RouteStep,
        elapsed_ticks: int,
        ticks_per_second: int,
    ) -> int | None:
        pressed = step.buttons & (~state.previous_buttons & 0xFF)
        state.previous_buttons = step.buttons & 0xFF
        if ticks_per_second == 0:
            return None
        elapsed_ticks = min(elapsed_ticks, ticks_per_second // 8)

        camera_changed = False
        if step.turn_axis:
            turn_step = (
                self.turn_speed * elapsed_ticks + ticks_per_second // 2
            ) // ticks_per_second
            state.yaw = (
                state.yaw + step.turn_axis * (turn_step if turn_step else 1)
            ) & 0xFF
            camera_changed = True
        if step.look_axis:
            pitch_step = (
                self.pitch_speed * elapsed_ticks + ticks_per_second // 2
            ) // ticks_per_second
            pitch = state.pitch + step.look_axis * (pitch_step if pitch_step else 1)
            pitch = max(-self.pitch_limit, min(self.pitch_limit, pitch))
            if pitch != state.pitch:
                state.pitch = pitch
                camera_changed = True
        if camera_changed:
            self.rebuild_basis(state)

        if pressed & self.button_dev:
            state.dev_mode ^= 1
            state.velocity = Vec3()
            state.grounded = 0
        if pressed & self.button_resolution:
            state.render_shift ^= 1
        if pressed & (self.button_orange | self.button_blue):
            raise CheckError("route checker does not permit runtime portal placement")
        if (
            not state.dev_mode
            and pressed & self.button_jump
            and state.grounded
        ):
            state.velocity.z = self.jump_speed
            state.grounded = 0

        if state.dev_mode:
            state.velocity = self.scale(
                state.forward, step.move_axis * self.move_speed
            )
            if step.buttons & self.button_jump:
                state.velocity.z = self.signed24(
                    state.velocity.z + self.move_speed
                )
            if step.buttons & self.button_down:
                state.velocity.z = self.signed24(
                    state.velocity.z - self.move_speed
                )
        else:
            horizontal = Vec3(state.right.y, -state.right.x, 0)
            state.velocity.x = self.fixed_mul(
                horizontal.x, step.move_axis * self.move_speed
            )
            state.velocity.y = self.fixed_mul(
                horizontal.y, step.move_axis * self.move_speed
            )
            state.velocity.z = self.signed24(
                state.velocity.z
                - trunc_div(self.gravity * elapsed_ticks, ticks_per_second)
            )

        start = state.position.copy()
        candidate = Vec3(
            self.signed24(
                state.position.x
                + trunc_div(state.velocity.x * elapsed_ticks, ticks_per_second)
            ),
            self.signed24(
                state.position.y
                + trunc_div(state.velocity.y * elapsed_ticks, ticks_per_second)
            ),
            self.signed24(
                state.position.z
                + trunc_div(state.velocity.z * elapsed_ticks, ticks_per_second)
            ),
        )
        crossed = self.try_crossing(state, start, candidate)
        self.collide(state, candidate)
        state.position = candidate
        return crossed


def trunc_div(numerator: int, denominator: int) -> int:
    if denominator == 0:
        raise ZeroDivisionError("C-style division by zero")
    magnitude = abs(numerator) // abs(denominator)
    return magnitude if (numerator < 0) == (denominator < 0) else -magnitude


def fnv1a(data: bytes, seed: int = FNV_OFFSET) -> int:
    value = seed
    for byte in data:
        value ^= byte
        value = (value * FNV_PRIME) & 0xFFFFFFFF
    return value


def signed24_bytes(value: int) -> bytes:
    return (value & 0xFFFFFF).to_bytes(3, "little")


def state_bytes(state: State) -> bytes:
    data = bytearray()
    for vector in (
        state.position,
        state.velocity,
        state.right,
        state.up,
        state.forward,
    ):
        data += signed24_bytes(vector.x)
        data += signed24_bytes(vector.y)
        data += signed24_bytes(vector.z)
    data += bytes(
        (
            state.yaw & 0xFF,
            state.pitch & 0xFF,
            state.room & 0xFF,
            state.previous_buttons & 0xFF,
            state.grounded & 0xFF,
            state.dev_mode & 0xFF,
            state.render_shift & 0xFF,
        )
    )
    if len(data) != 52:
        raise AssertionError(f"serialized EngineState is {len(data)} bytes")
    return bytes(data)


def state_hash(state: State) -> int:
    return fnv1a(state_bytes(state))


def route_fingerprint(route: Sequence[RouteStep], sections: Sequence[Section]) -> int:
    packed = bytearray()
    for step in route:
        packed += struct.pack(
            "<HbbbBB",
            step.frames,
            step.move_axis,
            step.turn_axis,
            step.look_axis,
            step.buttons,
            step.section,
        )
    value = fnv1a(bytes(packed))
    for section in sections:
        value = fnv1a(section.name.encode("ascii"), value)
        value ^= section.flags
        value = (value * FNV_PRIME) & 0xFFFFFFFF
    return value


def build_model(
    resolver: MacroResolver, engine_source: str, level_source: str
) -> EngineModel:
    quarter = parse_numeric_initializer(
        extract_initializer(
            engine_source,
            r"static\s+const\s+int16_t\s+quarter_sine\s*\[[^\]]+\]",
        ),
        resolver,
    )
    if len(quarter) != 65 or not all(isinstance(value, int) for value in quarter):
        raise CheckError("quarter_sine must contain exactly 65 integers")

    def vectors(name: str) -> list[Vec3]:
        parsed = parse_numeric_initializer(
            extract_initializer(
                engine_source,
                rf"static\s+const\s+Vec3\s+{name}\s*\[[^\]]+\]",
            ),
            resolver,
        )
        if len(parsed) != 6:
            raise CheckError(f"{name} must contain six axes")
        result: list[Vec3] = []
        for row in parsed:
            if not isinstance(row, list) or len(row) != 3:
                raise CheckError(f"malformed row in {name}")
            result.append(Vec3(*(int(value) for value in row)))
        return result

    normals = vectors("face_normals")
    rights = vectors("face_right_vectors")
    ups = vectors("face_up_vectors")
    level = parse_numeric_initializer(
        extract_initializer(
            level_source,
            r"static\s+const\s+BuiltinTrue3DLevel\s+builtin_level",
        ),
        resolver,
    )
    if len(level) != 2 or not isinstance(level[0], list) or not isinstance(level[1], list):
        raise CheckError("malformed builtin_level")
    header = level[0]
    room_rows = level[1]
    if len(header) != 9:
        raise CheckError(f"built-in header has {len(header)} fields, expected 9")
    magic = header[0]
    if magic != [ord("T"), ord("3"), ord("D"), ord("1")]:
        raise CheckError("built-in level magic changed")
    room_count = int(header[2])
    if room_count != len(room_rows):
        raise CheckError("built-in room count disagrees with room records")
    rooms: list[Room] = []
    for row in room_rows:
        if not isinstance(row, list) or len(row) != 7:
            raise CheckError("malformed built-in room record")
        rooms.append(Room(*(int(value) for value in row[:6])))

    portal_rows = header[8]
    if not isinstance(portal_rows, list) or len(portal_rows) != 2:
        raise CheckError("built-in level must define two portal spawns")
    half_width = resolver.value("PORTAL_HALF_WIDTH")
    half_height = resolver.value("PORTAL_HALF_HEIGHT")
    active_mask = int(header[4])
    portals: list[Portal] = []
    for portal_index, row in enumerate(portal_rows):
        if not isinstance(row, list) or len(row) != 5:
            raise CheckError("malformed built-in portal spawn")
        room_index, face, x, y, z = (int(value) for value in row)
        if room_index >= len(rooms) or face >= 6:
            raise CheckError("built-in portal spawn is out of range")
        room = rooms[room_index]
        center = Vec3(x, y, z)
        if face <= 1:
            center.x = max(
                room.minimum_x + half_width,
                min(room.maximum_x - half_width, center.x),
            )
            center.y = max(
                room.minimum_y + half_height,
                min(room.maximum_y - half_height, center.y),
            )
            center.z = room.minimum_z if face == 0 else room.maximum_z
        elif face <= 3:
            center.x = max(
                room.minimum_x + half_width,
                min(room.maximum_x - half_width, center.x),
            )
            center.z = max(
                room.minimum_z + half_height,
                min(room.maximum_z - half_height, center.z),
            )
            center.y = room.minimum_y if face == 2 else room.maximum_y
        else:
            center.y = max(
                room.minimum_y + half_width,
                min(room.maximum_y - half_width, center.y),
            )
            center.z = max(
                room.minimum_z + half_height,
                min(room.maximum_z - half_height, center.z),
            )
            center.x = room.minimum_x if face == 4 else room.maximum_x
        if face <= 1:
            face_width = room.maximum_x - room.minimum_x
            face_height = room.maximum_y - room.minimum_y
        elif face <= 3:
            face_width = room.maximum_x - room.minimum_x
            face_height = room.maximum_z - room.minimum_z
        else:
            face_width = room.maximum_y - room.minimum_y
            face_height = room.maximum_z - room.minimum_z
        portals.append(
            Portal(
                center=center,
                right=rights[face],
                up=ups[face],
                normal=normals[face],
                half_width=half_width,
                half_height=half_height,
                room=room_index,
                host_face=room_index * 6 + face,
                linked=1 - portal_index,
                active=bool(
                    active_mask & (1 << portal_index)
                    and face_width >= 2 * half_width
                    and face_height >= 2 * half_height
                ),
            )
        )
    spawn = (int(header[3]), int(header[5]), int(header[6]), int(header[7]))
    return EngineModel(
        resolver,
        [int(value) for value in quarter],
        rooms,
        portals,
        spawn,
    )


def validate_route(
    route: Sequence[RouteStep],
    sections: Sequence[Section],
    resolver: MacroResolver,
    model: EngineModel,
) -> None:
    expected_frames = resolver.value("LIVE_FRAME_COUNT")
    expected_sections = resolver.value("LIVE_SECTION_COUNT")
    if len(sections) != expected_sections:
        raise CheckError(
            f"parsed {len(sections)} sections, source declares {expected_sections}"
        )
    if sum(step.frames for step in route) != expected_frames:
        raise CheckError(
            f"route totals {sum(step.frames for step in route)} frames, "
            f"source declares {expected_frames}"
        )
    if expected_frames != 854:
        raise CheckError(f"expected the versioned 854-frame route, found {expected_frames}")
    previous_section = 0
    seen: list[int] = []
    for index, step in enumerate(route):
        if step.frames <= 0:
            raise CheckError(f"route step {index} has no frames")
        if step.section < 0 or step.section >= len(sections):
            raise CheckError(f"route step {index} has invalid section {step.section}")
        if index and step.section < previous_section:
            raise CheckError(f"route section order goes backwards at step {index}")
        if step.section != previous_section and step.section != previous_section + 1:
            raise CheckError(f"route skips a section at step {index}")
        previous_section = step.section
        if not seen or seen[-1] != step.section:
            seen.append(step.section)
        if step.move_axis not in (-1, 0, 1):
            raise CheckError(f"route step {index} has invalid move axis")
        if step.turn_axis not in (-1, 0, 1):
            raise CheckError(f"route step {index} has invalid turn axis")
        if step.look_axis not in (-1, 0, 1):
            raise CheckError(f"route step {index} has invalid look axis")
        if step.buttons & model.button_resolution:
            raise CheckError(f"route step {index} toggles reduced-detail rendering")
    if seen != list(range(len(sections))):
        raise CheckError(f"route section order is {seen}, expected every section in order")


def simulate(
    model: EngineModel,
    route: Sequence[RouteStep],
    sections: Sequence[Section],
    elapsed_ticks: int,
    ticks_per_second: int,
) -> SimulationResult:
    state = model.initial_state()
    crossings: list[Crossing] = []
    ends: list[SectionEnd] = []
    hashes: list[int] = []
    route_hash = FNV_OFFSET
    frame = 0
    for step in route:
        for _ in range(step.frames):
            source_room = state.room
            portal_index = model.update(state, step, elapsed_ticks, ticks_per_second)
            current_hash = state_hash(state)
            hashes.append(current_hash)
            route_hash = fnv1a(current_hash.to_bytes(4, "little"), route_hash)
            if state.render_shift != 0:
                raise CheckError(f"frame {frame} left full-detail render mode")
            if state.room != source_room:
                if portal_index is None:
                    raise CheckError(f"frame {frame} changed rooms without a portal")
                crossings.append(
                    Crossing(
                        frame=frame,
                        portal=portal_index,
                        source_room=source_room,
                        destination_room=state.room,
                        section=step.section,
                        state_hash=current_hash,
                        position=(state.position.x, state.position.y, state.position.z),
                        yaw=state.yaw,
                        pitch=state.pitch,
                    )
                )
            if frame + 1 == sum(
                route_step.frames
                for route_step in route
                if route_step.section <= step.section
            ):
                ends.append(
                    SectionEnd(
                        frame=frame,
                        section=step.section,
                        state_hash=current_hash,
                        position=(state.position.x, state.position.y, state.position.z),
                        velocity=(state.velocity.x, state.velocity.y, state.velocity.z),
                        yaw=state.yaw,
                        pitch=state.pitch,
                        room=state.room,
                        grounded=state.grounded,
                        dev_mode=state.dev_mode,
                        render_shift=state.render_shift,
                    )
                )
            frame += 1
    if len(ends) != len(sections):
        raise CheckError(f"recorded {len(ends)} section endpoints, expected {len(sections)}")
    return SimulationResult(
        state=state,
        crossings=tuple(crossings),
        section_ends=tuple(ends),
        route_state_hash=route_hash,
        frame_state_hashes=tuple(hashes),
    )


def format_vec(vector: tuple[int, int, int]) -> str:
    return f"({vector[0]},{vector[1]},{vector[2]})"


def main() -> int:
    try:
        live_source = LIVE_PATH.read_text(encoding="utf-8")
        engine_source = ENGINE_PATH.read_text(encoding="utf-8")
        engine_header = ENGINE_HEADER_PATH.read_text(encoding="utf-8")
        level_source = LEVEL_PATH.read_text(encoding="utf-8")
        level_header = LEVEL_HEADER_PATH.read_text(encoding="utf-8")
        resolver = MacroResolver(
            (live_source, engine_source, engine_header, level_source, level_header)
        )
        route = parse_route(live_source, resolver)
        sections = parse_sections(live_source, resolver)
        model = build_model(resolver, engine_source, level_source)
        validate_route(route, sections, resolver, model)
        elapsed = resolver.value("LIVE_ELAPSED_TICKS")
        ticks_per_second = resolver.value("LIVE_TICKS_PER_SECOND")
        result = simulate(model, route, sections, elapsed, ticks_per_second)
        repeated = simulate(model, route, sections, elapsed, ticks_per_second)
        if result != repeated:
            raise CheckError("independent repeated simulation was not deterministic")

        expected_crossings = resolver.value("LIVE_EXPECTED_CROSSINGS")
        if expected_crossings != 4:
            raise CheckError(
                f"expected the versioned four-crossing route, source declares "
                f"{expected_crossings}"
            )
        if len(result.crossings) != expected_crossings:
            raise CheckError(
                f"modeled {len(result.crossings)} crossings, expected "
                f"{expected_crossings}"
            )
        crossing_sections = [crossing.section for crossing in result.crossings]
        expected_crossing_sections = [4, 5, 7, 9]
        if crossing_sections != expected_crossing_sections:
            raise CheckError(
                f"crossings occurred in sections {crossing_sections}, expected "
                f"{expected_crossing_sections}"
            )

        fingerprint = route_fingerprint(route, sections)
        print(
            f"True3D live route OK: {len(result.frame_state_hashes)} frames, "
            f"{len(route)} steps, {len(sections)} sections, "
            f"{len(result.crossings)} crossings"
        )
        print(
            f"timestep={elapsed}/{ticks_per_second}s full_detail=1 "
            f"frame_indices=zero_based route_fingerprint=0x{fingerprint:08X}"
        )
        print("crossings:")
        for crossing in result.crossings:
            print(
                f"  frame={crossing.frame:03d} section={crossing.section}:"
                f"{sections[crossing.section].name} portal={crossing.portal} "
                f"rooms={crossing.source_room}->{crossing.destination_room} "
                f"pos={format_vec(crossing.position)} yaw={crossing.yaw} "
                f"pitch={crossing.pitch} state_hash=0x{crossing.state_hash:08X}"
            )
        print("section_end_trace:")
        for endpoint in result.section_ends:
            print(
                f"  frame={endpoint.frame:03d} section={endpoint.section}:"
                f"{sections[endpoint.section].name} room={endpoint.room} "
                f"pos={format_vec(endpoint.position)} "
                f"vel={format_vec(endpoint.velocity)} yaw={endpoint.yaw} "
                f"pitch={endpoint.pitch} freecam={endpoint.dev_mode} "
                f"grounded={endpoint.grounded} detail={1 - endpoint.render_shift} "
                f"state_hash=0x{endpoint.state_hash:08X}"
            )
        state = result.state
        print(
            "final_state: "
            f"room={state.room} pos=({state.position.x},{state.position.y},"
            f"{state.position.z}) vel=({state.velocity.x},{state.velocity.y},"
            f"{state.velocity.z}) yaw={state.yaw} pitch={state.pitch} "
            f"freecam={state.dev_mode} grounded={state.grounded} "
            f"render_shift={state.render_shift} buttons=0x{state.previous_buttons:02X}"
        )
        print(
            f"basis: right=({state.right.x},{state.right.y},{state.right.z}) "
            f"up=({state.up.x},{state.up.y},{state.up.z}) "
            f"forward=({state.forward.x},{state.forward.y},{state.forward.z})"
        )
        print(
            f"final_state_hash=0x{state_hash(state):08X} "
            f"route_state_hash=0x{result.route_state_hash:08X}"
        )
        return 0
    except (CheckError, OSError, SyntaxError, ValueError) as error:
        print(f"True3D live route FAILED: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
