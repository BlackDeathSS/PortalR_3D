#!/usr/bin/env python3
"""Estimate exact adjacent simple-wall coalescing opportunities.

This is a host-side model of the first DDA hit for the renderer's 80 rays.
It deliberately excludes every ray whose first wall is a portal: those rays
must keep the existing layered compositor.  Remaining adjacent rays are only
coalesced when every input that determines the final textured wall pixels is
identical:

  scale profile, visible bounds, mirrored texture column, material, and shade.

The model is useful for deciding whether a grouped assembly writer is worth
implementing; it does not modify or instrument the calculator renderer.
"""

from __future__ import annotations

import argparse
import csv
import dataclasses
import json
from collections import Counter
from pathlib import Path
from typing import Iterable, Iterator, Sequence


FIXED_ONE = 256
FIXED_INF = 0x3FFFFF
LCD_HEIGHT = 240
LOGICAL_COLUMNS = 80
ANGLE_STEPS = 64
ANGLE_FRACTION_BITS = 8
ANGLE_WRAP = ANGLE_STEPS << ANGLE_FRACTION_BITS
ANGLE_MASK = ANGLE_WRAP - 1
FIELD_OF_VIEW = 169
WALL_HEIGHT_TABLE_SHIFT = 2
WALL_HEIGHT_TABLE_SIZE = 2048
WALL_HEIGHT_MAX = LCD_HEIGHT * 4

DIR_NORTH = 0
DIR_SOUTH = 1
DIR_WEST = 2
DIR_EAST = 3

DIRECTION_Y = (
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25,
)

WALL_MAP = (
    (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
    (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
    (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
)

# source x/y/direction, target x/y/direction
BUILTIN_PORTALS = (
    (0, 13, DIR_SOUTH, 5, 13, DIR_NORTH),
    (5, 13, DIR_NORTH, 0, 13, DIR_SOUTH),
    (0, 4, DIR_SOUTH, 5, 9, DIR_NORTH),
    (5, 9, DIR_NORTH, 0, 4, DIR_SOUTH),
    (5, 0, DIR_EAST, 7, 0, DIR_EAST),
    (7, 0, DIR_EAST, 5, 0, DIR_EAST),
    (14, 5, DIR_NORTH, 14, 6, DIR_NORTH),
    (14, 6, DIR_NORTH, 14, 5, DIR_NORTH),
    (0, 2, DIR_SOUTH, 3, 0, DIR_EAST),
    (3, 0, DIR_EAST, 0, 2, DIR_SOUTH),
)
BUILTIN_PORTAL_KEYS = frozenset(
    (portal[0], portal[1], portal[2]) for portal in BUILTIN_PORTALS
)


@dataclasses.dataclass(frozen=True)
class Portal:
    x: int = 0
    y: int = 0
    direction: int = 0
    valid: bool = False


@dataclasses.dataclass(frozen=True)
class Scene:
    name: str
    player_x: int
    player_y: int
    angle: int
    primary: Portal = Portal()
    secondary: Portal = Portal()


@dataclasses.dataclass(frozen=True)
class Hit:
    distance: int
    map_x: int
    map_y: int
    side: int
    step_x: int
    step_y: int
    wall_direction: int
    wall_u: int


@dataclasses.dataclass(frozen=True)
class WallSignature:
    profile: int
    start: int
    end: int
    texture_column_offset: int
    material: int
    shade: int


@dataclasses.dataclass
class FrameGroups:
    label: str
    simple_columns: int
    portal_columns: int
    runs: list[int]
    run_heights: list[int]

    @property
    def grouped_columns(self) -> int:
        return sum(length - 1 for length in self.runs)

    @property
    def simple_calls_after(self) -> int:
        return len(self.runs)


STATIC_SCENES = (
    Scene("NEAR_WALL", 384, 384, 32 << 8),
    Scene("MID_DIRECT", 2432, 640, 48 << 8),
    Scene("LONG_DDA", 896, 384, 6 << 8),
    Scene("PORTAL_CHAIN", 384, 640, 32 << 8),
    Scene("PORTAL_WIDE", 1920, 1920, 0),
    Scene(
        "CUSTOM_PAIR",
        384,
        384,
        32 << 8,
        Portal(0, 1, DIR_SOUTH, True),
        Portal(14, 10, DIR_NORTH, True),
    ),
)


def trunc_div(numerator: int, denominator: int) -> int:
    """C99 signed integer division (truncate toward zero)."""
    if numerator < 0:
        return -((-numerator) // denominator)
    return numerator // denominator


def build_direction_y() -> tuple[int, ...]:
    result: list[int] = []
    for index, initial in enumerate(DIRECTION_Y):
        value = initial
        difference = DIRECTION_Y[(index + 1) & 63] - value
        step = -1 if difference < 0 else 1
        amount = abs(difference)
        error = 0
        for _ in range(256):
            result.append(value)
            error += amount
            if error >= 256:
                error -= 256
                value += step
    assert len(result) == ANGLE_WRAP
    return tuple(result)


DIRECTION_Y_LUT = build_direction_y()


def direction_for_angle(angle: int) -> tuple[int, int]:
    normalized = angle & ANGLE_MASK
    return (
        DIRECTION_Y_LUT[(normalized + ANGLE_WRAP // 4) & ANGLE_MASK],
        DIRECTION_Y_LUT[normalized],
    )


def fov_component(component: int) -> int:
    return trunc_div(component * FIELD_OF_VIEW, FIXED_ONE)


def ray_values(direction: int, plane: int) -> Iterator[int]:
    """Mirror ray_stepper_init()/advance(), including signed floor ranges."""
    if plane >= 0:
        if plane >= 160:
            quotient, remainder = 2, plane - 160
        elif plane >= 80:
            quotient, remainder = 1, plane - 80
        else:
            quotient, remainder = 0, plane
    elif plane < -160:
        quotient, remainder = -3, plane + 240
    elif plane < -80:
        quotient, remainder = -2, plane + 160
    else:
        quotient, remainder = -1, plane + 80

    value = direction - plane + quotient
    step = quotient + quotient
    if remainder >= 40:
        step += 1
        remainder -= 40
    error = remainder
    error_step = remainder + remainder

    for _ in range(LOGICAL_COLUMNS):
        yield value
        value += step
        error += error_step
        if error >= LOGICAL_COLUMNS:
            value += 1
            error -= LOGICAL_COLUMNS


def delta_for_component(component: int) -> int:
    magnitude = abs(component)
    if magnitude == 0:
        return FIXED_INF
    if magnitude == 1:
        return 65536
    return 65536 // min(magnitude, 425)


def scale_delta(fraction: int, delta: int) -> int:
    if delta == 65536:
        return fraction << 8
    return (fraction * delta) >> 8


def cast_first_wall(origin_x: int, origin_y: int, ray_x: int, ray_y: int) -> Hit:
    map_x = (origin_x >> 8) & 0xFF
    map_y = (origin_y >> 8) & 0xFF
    step_x = -1 if ray_x < 0 else 1
    step_y = -1 if ray_y < 0 else 1

    if ray_x == 0:
        delta_x = side_x = FIXED_INF
    else:
        delta_x = delta_for_component(ray_x)
        fraction_x = origin_x & 0xFF
        side_x = scale_delta(
            fraction_x if ray_x < 0 else FIXED_ONE - fraction_x,
            delta_x,
        )

    if ray_y == 0:
        delta_y = side_y = FIXED_INF
    else:
        delta_y = delta_for_component(ray_y)
        fraction_y = origin_y & 0xFF
        side_y = scale_delta(
            fraction_y if ray_y < 0 else FIXED_ONE - fraction_y,
            delta_y,
        )

    while True:
        step_x_first = side_x < side_y
        if side_x == side_y:
            x_wall = WALL_MAP[map_y][map_x + step_x]
            y_wall = WALL_MAP[map_y + step_y][map_x]
            step_x_first = bool(y_wall and not x_wall)

        if step_x_first:
            side_x += delta_x
            map_x += step_x
            side = 0
        else:
            side_y += delta_y
            map_y += step_y
            side = 1
        if WALL_MAP[map_y][map_x]:
            break

    if side == 0:
        distance = side_x - delta_x
        wall_direction = DIR_NORTH if ray_x >= 0 else DIR_SOUTH
        wall_position = origin_y + trunc_div(distance * ray_y, FIXED_ONE)
    else:
        distance = side_y - delta_y
        wall_direction = DIR_WEST if ray_y >= 0 else DIR_EAST
        wall_position = origin_x + trunc_div(distance * ray_x, FIXED_ONE)

    return Hit(
        max(distance, 1),
        map_x,
        map_y,
        side,
        step_x,
        step_y,
        wall_direction,
        wall_position & 0xFF,
    )


def build_profiles() -> tuple[tuple[int, int, int], ...]:
    """Return table-index -> (profile id, start, end)."""
    height = WALL_HEIGHT_MAX
    previous_height = 0
    profile = -1
    result: list[tuple[int, int, int]] = []
    limit = LCD_HEIGHT * FIXED_ONE >> WALL_HEIGHT_TABLE_SHIFT
    for index in range(WALL_HEIGHT_TABLE_SIZE):
        if index:
            while height > 1 and height * index > limit:
                height -= 1
        if height != previous_height:
            profile += 1
            if height >= LCD_HEIGHT:
                start, end = 0, LCD_HEIGHT
            else:
                start = (LCD_HEIGHT - height) >> 1
                end = start + height
            previous_height = height
        result.append((profile, start, end))
    return tuple(result)


PROFILES = build_profiles()


def is_portal_hit(scene: Scene, hit: Hit) -> bool:
    key = (hit.map_x, hit.map_y, hit.wall_direction)
    for portal in (scene.primary, scene.secondary):
        if portal.valid and key == (portal.x, portal.y, portal.direction):
            return True
    return key in BUILTIN_PORTAL_KEYS


def wall_signature(hit: Hit) -> WallSignature:
    table_index = min(hit.distance >> WALL_HEIGHT_TABLE_SHIFT, WALL_HEIGHT_TABLE_SIZE - 1)
    profile, start, end = PROFILES[table_index]
    texture = hit.wall_u & 0xF0
    if (hit.side == 0 and hit.step_x > 0) or (hit.side != 0 and hit.step_y < 0):
        texture = 0xF0 - texture
    texture >>= 1
    material = (hit.map_x ^ hit.map_y) & 3
    shade = hit.side
    if hit.distance > FIXED_ONE * 8:
        shade += 2
    elif hit.distance > FIXED_ONE * 4:
        shade += 1
    shade = min(shade, 3)
    return WallSignature(profile, start, end, texture, material, shade)


def analyze_scene(scene: Scene, label: str | None = None) -> FrameGroups:
    dir_x, dir_y = direction_for_angle(scene.angle)
    plane_x = -fov_component(dir_y)
    plane_y = fov_component(dir_x)
    x_rays = ray_values(dir_x, plane_x)
    y_rays = ray_values(dir_y, plane_y)
    signatures: list[WallSignature | None] = []
    for ray_x, ray_y in zip(x_rays, y_rays):
        hit = cast_first_wall(scene.player_x, scene.player_y, ray_x, ray_y)
        signatures.append(None if is_portal_hit(scene, hit) else wall_signature(hit))

    runs: list[int] = []
    run_heights: list[int] = []
    active: WallSignature | None = None
    length = 0
    for signature in signatures:
        if signature is not None and signature == active:
            length += 1
        else:
            if length:
                runs.append(length)
                assert active is not None
                run_heights.append(active.end - active.start)
            active = signature
            length = 1 if signature is not None else 0
    if length:
        runs.append(length)
        assert active is not None
        run_heights.append(active.end - active.start)

    simple = sum(signature is not None for signature in signatures)
    return FrameGroups(
        label or scene.name,
        simple,
        LOGICAL_COLUMNS - simple,
        runs,
        run_heights,
    )


def live_scenes(path: Path) -> Iterator[Scene]:
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        required = {"frame_index", "player_x_raw", "player_y_raw", "angle_raw"}
        if not reader.fieldnames or not required.issubset(reader.fieldnames):
            missing = required.difference(reader.fieldnames or ())
            raise ValueError(f"{path}: missing live-frame columns: {sorted(missing)}")
        for row in reader:
            yield Scene(
                f"live:{row['frame_index']}",
                int(row["player_x_raw"]),
                int(row["player_y_raw"]),
                int(row["angle_raw"]),
            )


def summarize(frames: Sequence[FrameGroups]) -> dict[str, object]:
    distribution: Counter[int] = Counter()
    simple = portal = before = after = grouped = 0
    frames_with_group = 0
    max_group = 0
    for frame in frames:
        simple += frame.simple_columns
        portal += frame.portal_columns
        before += frame.simple_columns
        after += frame.simple_calls_after
        grouped += frame.grouped_columns
        distribution.update(frame.runs)
        if frame.grouped_columns:
            frames_with_group += 1
        if frame.runs:
            max_group = max(max_group, max(frame.runs))
    simple_scanline_pointer_adds = sum(
        length * height
        for frame in frames
        for length, height in zip(frame.runs, frame.run_heights)
    )
    capped: dict[str, dict[str, float | int]] = {}
    for cap in (2, 4, 8):
        calls = sum(
            (length + cap - 1) // cap
            for frame in frames
            for length in frame.runs
        )
        saved = before - calls
        grouped_pointer_adds = sum(
            ((length + cap - 1) // cap) * height
            for frame in frames
            for length, height in zip(frame.runs, frame.run_heights)
        )
        capped[str(cap)] = {
            "simple_wall_calls_after": calls,
            "simple_wall_calls_saved": saved,
            "simple_wall_call_reduction_percent": (
                100.0 * saved / before if before else 0.0
            ),
            "simple_scanline_pointer_adds_after": grouped_pointer_adds,
            "simple_scanline_pointer_adds_saved": (
                simple_scanline_pointer_adds - grouped_pointer_adds
            ),
            "simple_scanline_pointer_add_reduction_percent": (
                100.0 * (simple_scanline_pointer_adds - grouped_pointer_adds)
                / simple_scanline_pointer_adds
                if simple_scanline_pointer_adds else 0.0
            ),
        }

    return {
        "frames": len(frames),
        "simple_columns": simple,
        "portal_first_hit_columns": portal,
        "simple_wall_calls_before": before,
        "simple_wall_calls_after_unbounded": after,
        "simple_wall_calls_saved": grouped,
        "simple_wall_call_reduction_percent": (100.0 * grouped / before) if before else 0.0,
        "all_ray_call_reduction_percent": (
            100.0 * grouped / (LOGICAL_COLUMNS * len(frames))
        ) if frames else 0.0,
        "frames_with_at_least_one_group": frames_with_group,
        "maximum_group_length": max_group,
        "group_length_distribution": dict(sorted(distribution.items())),
        "simple_scanline_pointer_adds_before": simple_scanline_pointer_adds,
        "bounded_group_results": capped,
    }


def print_rows(title: str, frames: Sequence[FrameGroups]) -> None:
    print(title)
    print("name             simple portal  runs saved  reduction  max  distribution")
    for frame in frames:
        distribution = Counter(frame.runs)
        encoded = ",".join(f"{length}x{count}" for length, count in sorted(distribution.items()))
        reduction = (
            100.0 * frame.grouped_columns / frame.simple_columns
            if frame.simple_columns else 0.0
        )
        print(
            f"{frame.label:16} {frame.simple_columns:6} {frame.portal_columns:6} "
            f"{len(frame.runs):5} {frame.grouped_columns:5} "
            f"{reduction:8.2f}% {max(frame.runs, default=0):4}  {encoded}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--live-csv",
        type=Path,
        help="decoded P3DLIVE *-frames.csv to analyze in addition to six static scenes",
    )
    parser.add_argument("--json", type=Path, help="optional path for machine-readable results")
    args = parser.parse_args()

    static_frames = [analyze_scene(scene) for scene in STATIC_SCENES]
    print_rows("Six static benchmark scenes", static_frames)
    result: dict[str, object] = {
        "static_frames": [dataclasses.asdict(frame) for frame in static_frames],
        "static_summary": summarize(static_frames),
    }

    if args.live_csv:
        live_frames = [
            analyze_scene(scene, scene.name)
            for scene in live_scenes(args.live_csv)
        ]
        live_summary = summarize(live_frames)
        print()
        print(f"P3DLIVE ({args.live_csv}, {len(live_frames)} frames)")
        print(json.dumps(live_summary, indent=2, sort_keys=True))
        result["live_source"] = str(args.live_csv)
        result["live_summary"] = live_summary

    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
