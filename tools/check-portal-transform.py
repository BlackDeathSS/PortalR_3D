#!/usr/bin/env python3
"""Property-check the exact portal-transform normal-coordinate shortcut."""

from __future__ import annotations

import argparse
import random


DIR_NORTH = 0
DIR_SOUTH = 1
DIR_WEST = 2
DIR_EAST = 3

ROTATION = (
    (2, 0, -1, 1),
    (0, 2, 1, -1),
    (1, -1, 2, 0),
    (-1, 1, 0, 2),
)


def rotate(x: int, y: int, rotation: int) -> tuple[int, int]:
    if rotation == 1:
        return -y, x
    if rotation == -1:
        return y, -x
    if rotation == 2:
        return -x, -y
    return x, y


def finish_transform(
    local_x: int,
    local_y: int,
    entry_direction: int,
    exit_direction: int,
    exit_x: int,
    exit_y: int,
) -> tuple[int, int, int]:
    rotation = ROTATION[entry_direction][exit_direction]
    local_x, local_y = rotate(local_x, local_y, rotation)

    if rotation == 2:
        local_x += 256
        local_y += 256
    elif rotation == 1:
        local_x += 256
    elif rotation == -1:
        local_y += 256

    output_x = exit_x * 256 + local_x
    output_y = exit_y * 256 + local_y
    if exit_direction == DIR_NORTH:
        output_x = exit_x * 256 - 1
    elif exit_direction == DIR_SOUTH:
        output_x = (exit_x + 1) * 256 + 1
    elif exit_direction == DIR_WEST:
        output_y = exit_y * 256 - 1
    else:
        output_y = (exit_y + 1) * 256 + 1
    return output_x, output_y, rotation


def check_cases(case_count: int, seed: int) -> None:
    rng = random.Random(seed)

    for _ in range(case_count):
        side = rng.randrange(2)
        step_x = rng.choice((-1, 1))
        step_y = rng.choice((-1, 1))

        # Reciprocal rounding can put the pre-cross normal and tangent just
        # outside one cell. The exit-normal overwrite must discard only the
        # former; this is why RayHit retains the full wall position.
        pre_cross_normal = rng.randrange(-8, 265)
        tangent = rng.randrange(-8, 265)

        if side == 0:
            old_local_x = pre_cross_normal + step_x * 256
            old_local_y = tangent
            fast_local_x = 256 if step_x > 0 else 0
            fast_local_y = tangent
            entry_direction = DIR_NORTH if step_x > 0 else DIR_SOUTH
        else:
            old_local_x = tangent
            old_local_y = pre_cross_normal + step_y * 256
            fast_local_x = tangent
            fast_local_y = 256 if step_y > 0 else 0
            entry_direction = DIR_WEST if step_y > 0 else DIR_EAST

        exit_direction = rng.randrange(4)
        exit_x = rng.randrange(15)
        exit_y = rng.randrange(15)
        old_result = finish_transform(
            old_local_x,
            old_local_y,
            entry_direction,
            exit_direction,
            exit_x,
            exit_y,
        )
        fast_result = finish_transform(
            fast_local_x,
            fast_local_y,
            entry_direction,
            exit_direction,
            exit_x,
            exit_y,
        )
        if old_result != fast_result:
            raise AssertionError(
                "portal transform mismatch: "
                f"old={old_result}, fast={fast_result}, side={side}, "
                f"steps=({step_x},{step_y}), tangent={tangent}, "
                f"normal={pre_cross_normal}, exit_direction={exit_direction}"
            )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases", type=int, default=1_000_000)
    parser.add_argument("--seed", type=int, default=1)
    args = parser.parse_args()
    if args.cases < 1:
        parser.error("--cases must be positive")
    check_cases(args.cases, args.seed)
    print(
        f"portal transform exact: {args.cases} randomized cases "
        f"(seed {args.seed})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
