#!/usr/bin/env python3
"""Verify the deterministic P3DLIVE input route against gameplay math."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src" / "live_benchmark.c"

FIXED_ONE = 256
PLAYER_RADIUS = 44
ANGLE_MASK = (64 << 8) - 1
MOVE_AMOUNT = (448 * 1) // 30
TURN_AMOUNT = (12 * 256 * 1) // 30

DIRECTION_X = (
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25,
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
)
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
MAP_ROWS = (
    "###############",
    "#.............#",
    "#............##",
    "#......#......#",
    "#..........#..#",
    "#.............#",
    "#.............#",
    "######........#",
    "#....#........#",
    "#....#........#",
    "#....#........#",
    "#.............#",
    "#....#........#",
    "#....#........#",
    "###############",
)

DIR_NORTH = 0
DIR_SOUTH = 1
DIR_WEST = 2
DIR_EAST = 3

PORTAL_LINKS = {
    (0, 13, DIR_SOUTH): (5, 13, DIR_NORTH),
    (5, 13, DIR_NORTH): (0, 13, DIR_SOUTH),
    (0, 4, DIR_SOUTH): (5, 9, DIR_NORTH),
    (5, 9, DIR_NORTH): (0, 4, DIR_SOUTH),
    (5, 0, DIR_EAST): (7, 0, DIR_EAST),
    (7, 0, DIR_EAST): (5, 0, DIR_EAST),
    (14, 5, DIR_NORTH): (14, 6, DIR_NORTH),
    (14, 6, DIR_NORTH): (14, 5, DIR_NORTH),
    (0, 2, DIR_SOUTH): (3, 0, DIR_EAST),
    (3, 0, DIR_EAST): (0, 2, DIR_SOUTH),
}

EXPECTED_CROSSINGS = (
    (6, 0, 896, 315, 4096),
    (171, 4, 314, 640, 16352),
    (297, 7, 1222, 2388, 8128),
    (407, 9, 314, 1108, 16288),
    (760, 13, 3526, 1652, 8096),
    (842, 15, 3526, 1420, 8064),
)
EXPECTED_FINAL_STATE = (3422, 900, 12144)
EXPECTED_FRAME_COUNT = 971


@dataclass(frozen=True)
class RouteStep:
    frames: int
    move_axis: int
    turn_axis: int
    section: int
    pulse_turn: bool


@dataclass
class Game:
    x: int = 384
    y: int = 640
    angle: int = 32 << 8


def trunc_div(numerator: int, denominator: int) -> int:
    magnitude = abs(numerator) // abs(denominator)
    return magnitude if numerator * denominator >= 0 else -magnitude


def fixed_mul(left: int, right: int) -> int:
    return trunc_div(left * right, FIXED_ONE)


def direction_for_angle(angle: int) -> tuple[int, int]:
    index = (angle >> 8) & 63
    next_index = (index + 1) & 63
    fraction = angle & 255
    x = DIRECTION_X[index] + trunc_div(
        (DIRECTION_X[next_index] - DIRECTION_X[index]) * fraction,
        256,
    )
    y = DIRECTION_Y[index] + trunc_div(
        (DIRECTION_Y[next_index] - DIRECTION_Y[index]) * fraction,
        256,
    )
    return x, y


def map_is_wall(x: int, y: int) -> bool:
    return (
        x < 0
        or y < 0
        or x >= len(MAP_ROWS[0])
        or y >= len(MAP_ROWS)
        or MAP_ROWS[y][x] == "#"
    )


def portal_rotation(entry: int, exit_direction: int) -> int:
    if entry == exit_direction:
        return 2
    rotations = {
        DIR_NORTH: {DIR_SOUTH: 0, DIR_EAST: 1, DIR_WEST: -1},
        DIR_EAST: {DIR_WEST: 0, DIR_SOUTH: 1, DIR_NORTH: -1},
        DIR_SOUTH: {DIR_NORTH: 0, DIR_WEST: 1, DIR_EAST: -1},
        DIR_WEST: {DIR_EAST: 0, DIR_NORTH: 1, DIR_SOUTH: -1},
    }
    return rotations[entry][exit_direction]


def rotate_quarter(x: int, y: int, quarters: int) -> tuple[int, int]:
    if quarters == 1:
        return -y, x
    if quarters == -1:
        return y, -x
    if abs(quarters) == 2:
        return -x, -y
    return x, y


def transform_player(
    game: Game,
    exit_portal: tuple[int, int, int],
    entry_direction: int,
) -> None:
    exit_x, exit_y, exit_direction = exit_portal
    local_x = game.x - trunc_div(game.x, FIXED_ONE) * FIXED_ONE
    local_y = game.y - trunc_div(game.y, FIXED_ONE) * FIXED_ONE
    rotation = portal_rotation(entry_direction, exit_direction)
    local_x, local_y = rotate_quarter(local_x, local_y, rotation)

    if abs(rotation) == 2:
        local_x += FIXED_ONE
        local_y += FIXED_ONE
    elif rotation == 1:
        local_x += FIXED_ONE
    elif rotation == -1:
        local_y += FIXED_ONE

    game.x = exit_x * FIXED_ONE + local_x
    game.y = exit_y * FIXED_ONE + local_y
    if exit_direction == DIR_NORTH:
        game.x = exit_x * FIXED_ONE - PLAYER_RADIUS - 1
    elif exit_direction == DIR_SOUTH:
        game.x = (exit_x + 1) * FIXED_ONE + PLAYER_RADIUS + 1
    elif exit_direction == DIR_WEST:
        game.y = exit_y * FIXED_ONE - PLAYER_RADIUS - 1
    else:
        game.y = (exit_y + 1) * FIXED_ONE + PLAYER_RADIUS + 1

    if exit_direction in (DIR_NORTH, DIR_SOUTH):
        minimum = exit_y * FIXED_ONE + PLAYER_RADIUS + 1
        maximum = (exit_y + 1) * FIXED_ONE - PLAYER_RADIUS - 1
        game.y = max(minimum, min(maximum, game.y))
    else:
        minimum = exit_x * FIXED_ONE + PLAYER_RADIUS + 1
        maximum = (exit_x + 1) * FIXED_ONE - PLAYER_RADIUS - 1
        game.x = max(minimum, min(maximum, game.x))
    game.angle = (game.angle + rotation * 16 * 256) & ANGLE_MASK


def move_without_portal(game: Game, amount: int) -> None:
    direction_x, direction_y = direction_for_angle(game.angle)
    delta_x = fixed_mul(direction_x, amount)
    delta_y = fixed_mul(direction_y, amount)
    if delta_x:
        candidate = game.x + delta_x
        probe = candidate + (PLAYER_RADIUS if delta_x > 0 else -PLAYER_RADIUS)
        if not map_is_wall(
            trunc_div(probe, FIXED_ONE),
            trunc_div(game.y, FIXED_ONE),
        ):
            game.x = candidate
    if delta_y:
        candidate = game.y + delta_y
        probe = candidate + (PLAYER_RADIUS if delta_y > 0 else -PLAYER_RADIUS)
        if not map_is_wall(
            trunc_div(game.x, FIXED_ONE),
            trunc_div(probe, FIXED_ONE),
        ):
            game.y = candidate


def try_player_portal(
    game: Game,
    probe_x: int,
    probe_y: int,
    amount: int,
) -> bool:
    current_x = trunc_div(game.x, FIXED_ONE)
    current_y = trunc_div(game.y, FIXED_ONE)
    target_x = trunc_div(probe_x, FIXED_ONE)
    target_y = trunc_div(probe_y, FIXED_ONE)
    if target_x != current_x:
        entry_direction = DIR_SOUTH if target_x < current_x else DIR_NORTH
        target_y = current_y
    elif target_y != current_y:
        entry_direction = DIR_EAST if target_y < current_y else DIR_WEST
        target_x = current_x
    else:
        return False
    exit_portal = PORTAL_LINKS.get((target_x, target_y, entry_direction))
    if exit_portal is None:
        return False
    transform_player(game, exit_portal, entry_direction)
    move_without_portal(game, amount)
    return True


def move_player(game: Game, amount: int) -> bool:
    if amount == 0:
        return False
    direction_x, direction_y = direction_for_angle(game.angle)
    delta_x = fixed_mul(direction_x, amount)
    delta_y = fixed_mul(direction_y, amount)
    probe_x = (
        game.x
        + delta_x
        + (PLAYER_RADIUS if delta_x > 0 else -PLAYER_RADIUS)
    )
    probe_y = (
        game.y
        + delta_y
        + (PLAYER_RADIUS if delta_y > 0 else -PLAYER_RADIUS)
    )
    if delta_x and try_player_portal(game, probe_x, game.y, amount):
        return True
    if delta_y and try_player_portal(game, game.x, probe_y, amount):
        return True
    move_without_portal(game, amount)
    return False


def parse_route() -> list[RouteStep]:
    source = SOURCE.read_text(encoding="utf-8")
    match = re.search(
        r"static const LiveRouteStep live_route\[\] = \{(?P<body>.*?)\n\};",
        source,
        re.DOTALL,
    )
    if not match:
        raise AssertionError("could not find live_route[] in source")
    entries = re.findall(
        r"\{\s*(\d+),\s*(-?\d+),\s*(-?\d+),\s*(\d+),\s*"
        r"(0|LIVE_STEP_PULSE_TURN)\s*\}",
        match.group("body"),
    )
    if not entries:
        raise AssertionError("live_route[] contains no recognized entries")
    return [
        RouteStep(
            frames=int(frames),
            move_axis=int(move_axis),
            turn_axis=int(turn_axis),
            section=int(section),
            pulse_turn=flags == "LIVE_STEP_PULSE_TURN",
        )
        for frames, move_axis, turn_axis, section, flags in entries
    ]


def main() -> int:
    route = parse_route()
    game = Game()
    crossings: list[tuple[int, int, int, int, int]] = []
    frame = 0

    for step in route:
        for step_frame in range(step.frames):
            turn_axis = step.turn_axis
            if step.pulse_turn and step_frame & 1:
                turn_axis = 0
            game.angle = (game.angle + turn_axis * TURN_AMOUNT) & ANGLE_MASK
            crossed = move_player(game, step.move_axis * MOVE_AMOUNT)
            if crossed:
                crossings.append(
                    (frame, step.section, game.x, game.y, game.angle)
                )
            frame += 1

    if frame != EXPECTED_FRAME_COUNT:
        raise AssertionError(
            f"route has {frame} frames; expected {EXPECTED_FRAME_COUNT}"
        )
    if tuple(crossings) != EXPECTED_CROSSINGS:
        raise AssertionError(
            f"portal crossings changed:\nactual={crossings}\n"
            f"expected={list(EXPECTED_CROSSINGS)}"
        )
    final_state = (game.x, game.y, game.angle)
    if final_state != EXPECTED_FINAL_STATE:
        raise AssertionError(
            f"final state changed: {final_state}; expected {EXPECTED_FINAL_STATE}"
        )

    print(
        "live route exact: "
        f"{frame} frames, {len(crossings)} portal crossings, "
        f"final state {final_state}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
