#!/usr/bin/env python3
"""Property-check the direction-specialized portal affine transform."""

from __future__ import annotations

import argparse
from pathlib import Path
import random
import re


DIR_NORTH = 0
DIR_SOUTH = 1
DIR_WEST = 2
DIR_EAST = 3

FIXED_ONE = 256
INT24_BITS = 24
INT24_SIGN = 1 << (INT24_BITS - 1)
INT24_MODULUS = 1 << INT24_BITS
INT24_MASK = INT24_MODULUS - 1
INT24_MIN = -INT24_SIGN
INT24_MAX = INT24_SIGN - 1

ROTATION = (
    (2, 0, -1, 1),
    (0, 2, 1, -1),
    (1, -1, 2, 0),
    (-1, 1, 0, 2),
)

# Bits 0-1 encode 0, +1, 2, -1; bit 7 means tangent -> 256-tangent.
EXPECTED_FLAGS = (
    0x82, 0x00, 0x03, 0x81,
    0x00, 0x82, 0x81, 0x03,
    0x01, 0x83, 0x82, 0x00,
    0x83, 0x01, 0x00, 0x82,
)
CODE_ROTATION = (0, 1, 2, -1)
FIXED_INF = 0x3FFFFF

REPRESENTATIVE_COMPONENTS = (
    INT24_MIN,
    INT24_MIN + 1,
    -65536,
    -425,
    -256,
    -1,
    0,
    1,
    255,
    256,
    425,
    65535,
    INT24_MAX - 1,
    INT24_MAX,
)


def signed24(value: int) -> int:
    value &= INT24_MASK
    return value - INT24_MODULUS if value & INT24_SIGN else value


def reciprocal_delta(component: int) -> int:
    magnitude = abs(component)
    if magnitude == 0:
        return FIXED_INF
    if magnitude == 1:
        return 65536
    return 65536 // min(magnitude, 425)


def seed_values(
    origin_x: int,
    origin_y: int,
    ray_x: int,
    ray_y: int,
) -> tuple[int, int, int, int, int]:
    fraction_x = origin_x & 0xFF
    fraction_y = origin_y & 0xFF
    qx = fraction_x if ray_x < 0 else 256 - fraction_x
    qy = fraction_y if ray_y < 0 else 256 - fraction_y
    ax = abs(ray_x)
    ay = abs(ray_y)
    threshold = (ax + ay) << 8
    recurrence = qx * ay + (256 - qy) * ax
    axis_mode = (
        2 if ray_x == 0 and fraction_x == 0
        else 1 if ray_y == 0 and fraction_y == 0
        else 0
    )
    return qx, qy, threshold, recurrence, axis_mode


def empty_bordered_map() -> list[int]:
    return [
        int(x == 0 or x == 15 or y == 0 or y == 15)
        for y in range(16)
        for x in range(16)
    ]


def cast_signature(
    wall_map: list[int],
    origin_x: int,
    origin_y: int,
    ray_x: int,
    ray_y: int,
) -> tuple[int, int, int, int]:
    """Cast with the persistent exact recurrence; return hit and step count."""
    qx, qy, threshold, recurrence, axis_mode = seed_values(
        origin_x, origin_y, ray_x, ray_y
    )
    if axis_mode:
        raise AssertionError("chain generator unexpectedly selected axis mode")
    sx = -1 if ray_x < 0 else 1
    sy = -1 if ray_y < 0 else 1
    ax_step = abs(ray_x) << 8
    ay_step = abs(ray_y) << 8
    map_x = (origin_x >> 8) & 0xFF
    map_y = (origin_y >> 8) & 0xFF
    index = map_y * 16 + map_x
    steps = 0

    while True:
        raw = recurrence + ay_step - threshold
        carry = raw < 0
        result = raw & INT24_MASK
        if result == 0:
            y_wall = wall_map[index + sy * 16]
            x_wall = wall_map[index + sx]
            side = 0 if y_wall and not x_wall else 1
        else:
            side = 0 if carry else 1
        if side == 0:
            recurrence = (result + threshold) & INT24_MASK
            map_x += sx
            index += sx
        else:
            recurrence = result
            map_y += sy
            index += sy * 16
        steps += 1
        if wall_map[index]:
            return map_x, map_y, side, steps
        if steps > 30:
            raise AssertionError("persistent chain cast missed bordered map")


def rotate(x: int, y: int, rotation: int) -> tuple[int, int]:
    x = signed24(x)
    y = signed24(y)
    if rotation == 1:
        return signed24(-y), x
    if rotation == -1:
        return y, signed24(-x)
    if rotation == 2:
        return signed24(-x), signed24(-y)
    return x, y


def parse_transform_flags(assembly_path: Path) -> tuple[int, ...]:
    source = assembly_path.read_text(encoding="utf-8")
    match = re.search(
        r"^\.Lportal_transform_flags:\s*$"
        r"(?P<body>.*?)"
        r"(?=^\s*\.section|\Z)",
        source,
        flags=re.MULTILINE | re.DOTALL,
    )
    if match is None:
        raise AssertionError(
            f"{assembly_path}: .Lportal_transform_flags table not found"
        )

    values: list[int] = []
    for byte_line in re.findall(
        r"^\s*\.byte\s+([^;\r\n]+)",
        match.group("body"),
        flags=re.MULTILINE,
    ):
        for token in byte_line.split(","):
            values.append(int(token.strip(), 0) & 0xFF)
    flags = tuple(values)
    if flags != EXPECTED_FLAGS:
        raise AssertionError(
            "portal transform flag table mismatch:\n"
            f"  assembly={flags}\n"
            f"  expected={EXPECTED_FLAGS}"
        )
    return flags


def entry_local(
    tangent: int,
    pre_cross_normal: int,
    entry_direction: int,
) -> tuple[int, int]:
    """Recreate the legacy advance/subtract/cross local coordinate."""
    if entry_direction == DIR_NORTH:
        return signed24(pre_cross_normal + FIXED_ONE), signed24(tangent)
    if entry_direction == DIR_SOUTH:
        return signed24(pre_cross_normal - FIXED_ONE), signed24(tangent)
    if entry_direction == DIR_WEST:
        return signed24(tangent), signed24(pre_cross_normal + FIXED_ONE)
    return signed24(tangent), signed24(pre_cross_normal - FIXED_ONE)


def reference_transform(
    tangent: int,
    pre_cross_normal: int,
    ray_x: int,
    ray_y: int,
    delta_x: int,
    delta_y: int,
    entry_direction: int,
    exit_direction: int,
    exit_x: int,
    exit_y: int,
) -> tuple[int, int, int, int, int, int, int]:
    local_x, local_y = entry_local(
        tangent, pre_cross_normal, entry_direction
    )
    rotation = ROTATION[entry_direction][exit_direction]
    local_x, local_y = rotate(local_x, local_y, rotation)

    if rotation == 2:
        local_x = signed24(local_x + FIXED_ONE)
        local_y = signed24(local_y + FIXED_ONE)
    elif rotation == 1:
        local_x = signed24(local_x + FIXED_ONE)
    elif rotation == -1:
        local_y = signed24(local_y + FIXED_ONE)

    output_x = signed24(exit_x * FIXED_ONE + local_x)
    output_y = signed24(exit_y * FIXED_ONE + local_y)
    if exit_direction == DIR_NORTH:
        output_x = signed24(exit_x * FIXED_ONE - 1)
    elif exit_direction == DIR_SOUTH:
        output_x = signed24((exit_x + 1) * FIXED_ONE + 1)
    elif exit_direction == DIR_WEST:
        output_y = signed24(exit_y * FIXED_ONE - 1)
    else:
        output_y = signed24((exit_y + 1) * FIXED_ONE + 1)

    ray_x, ray_y = rotate(ray_x, ray_y, rotation)
    if rotation & 1:
        delta_x, delta_y = delta_y, delta_x
    return (
        output_x,
        output_y,
        ray_x,
        ray_y,
        rotation,
        signed24(delta_x),
        signed24(delta_y),
    )


def specialized_transform(
    flags: tuple[int, ...],
    tangent: int,
    ray_x: int,
    ray_y: int,
    delta_x: int,
    delta_y: int,
    entry_direction: int,
    exit_direction: int,
    exit_x: int,
    exit_y: int,
) -> tuple[int, int, int, int, int, int, int]:
    pair_flags = flags[entry_direction * 4 + exit_direction]
    rotation = CODE_ROTATION[pair_flags & 3]
    tangent = signed24(tangent)
    if pair_flags & 0x80:
        tangent = signed24(FIXED_ONE - tangent)

    if exit_direction == DIR_NORTH:
        output_x = signed24(exit_x * FIXED_ONE - 1)
        output_y = signed24(exit_y * FIXED_ONE + tangent)
    elif exit_direction == DIR_SOUTH:
        output_x = signed24((exit_x + 1) * FIXED_ONE + 1)
        output_y = signed24(exit_y * FIXED_ONE + tangent)
    elif exit_direction == DIR_WEST:
        output_x = signed24(exit_x * FIXED_ONE + tangent)
        output_y = signed24(exit_y * FIXED_ONE - 1)
    else:
        output_x = signed24(exit_x * FIXED_ONE + tangent)
        output_y = signed24((exit_y + 1) * FIXED_ONE + 1)

    ray_x, ray_y = rotate(ray_x, ray_y, rotation)
    if rotation & 1:
        delta_x, delta_y = delta_y, delta_x
    return (
        output_x,
        output_y,
        ray_x,
        ray_y,
        rotation,
        signed24(delta_x),
        signed24(delta_y),
    )


def assert_case(
    flags: tuple[int, ...],
    *,
    tangent: int,
    pre_cross_normal: int,
    ray_x: int,
    ray_y: int,
    delta_x: int,
    delta_y: int,
    entry_direction: int,
    exit_direction: int,
    exit_x: int,
    exit_y: int,
) -> None:
    reference = reference_transform(
        tangent,
        pre_cross_normal,
        ray_x,
        ray_y,
        delta_x,
        delta_y,
        entry_direction,
        exit_direction,
        exit_x,
        exit_y,
    )
    specialized = specialized_transform(
        flags,
        tangent,
        ray_x,
        ray_y,
        delta_x,
        delta_y,
        entry_direction,
        exit_direction,
        exit_x,
        exit_y,
    )
    if reference != specialized:
        raise AssertionError(
            "portal transform mismatch:\n"
            f"  reference={reference}\n"
            f"  specialized={specialized}\n"
            f"  entry={entry_direction}, exit={exit_direction}, "
            f"tile=({exit_x},{exit_y}), tangent={tangent}, "
            f"normal={pre_cross_normal}, ray=({ray_x},{ray_y}), "
            f"deltas=({delta_x},{delta_y})"
        )

    expected_rotation = ROTATION[entry_direction][exit_direction]
    if specialized[4] != expected_rotation:
        raise AssertionError(
            f"signed rotation mismatch: {specialized[4]} != "
            f"{expected_rotation}"
        )
    expected_deltas = (
        (signed24(delta_y), signed24(delta_x))
        if expected_rotation & 1
        else (signed24(delta_x), signed24(delta_y))
    )
    if specialized[5:] != expected_deltas:
        raise AssertionError(
            f"caller delta-swap mismatch: {specialized[5:]} != "
            f"{expected_deltas}"
        )
    old_magnitudes = (abs(signed24(ray_x)), abs(signed24(ray_y)))
    expected_magnitudes = (
        (old_magnitudes[1], old_magnitudes[0])
        if expected_rotation & 1
        else old_magnitudes
    )
    new_magnitudes = (abs(specialized[2]), abs(specialized[3]))
    if new_magnitudes != expected_magnitudes:
        raise AssertionError(
            f"persistent magnitude swap mismatch: {new_magnitudes} != "
            f"{expected_magnitudes}"
        )
    if sum(new_magnitudes) != sum(old_magnitudes):
        raise AssertionError(
            "persistent recurrence threshold changed across rotation"
        )


def check_exhaustive_boundaries(flags: tuple[int, ...]) -> int:
    count = 0
    for entry_direction in range(4):
        for exit_direction in range(4):
            exit_x = (entry_direction * 3 + exit_direction * 5) % 15
            exit_y = (entry_direction * 7 + exit_direction * 2) % 15
            ray_x = REPRESENTATIVE_COMPONENTS[
                entry_direction * 3 + exit_direction
            ]
            ray_y = REPRESENTATIVE_COMPONENTS[
                entry_direction + exit_direction * 3 + 1
            ]
            for tangent in range(-8, 265):
                for pre_cross_normal in range(-8, 265):
                    assert_case(
                        flags,
                        tangent=tangent,
                        pre_cross_normal=pre_cross_normal,
                        ray_x=ray_x,
                        ray_y=ray_y,
                        delta_x=0x012345,
                        delta_y=0x234567,
                        entry_direction=entry_direction,
                        exit_direction=exit_direction,
                        exit_x=exit_x,
                        exit_y=exit_y,
                    )
                    count += 1
    return count


def check_representative_components(flags: tuple[int, ...]) -> int:
    count = 0
    for entry_direction in range(4):
        for exit_direction in range(4):
            for ray_x in REPRESENTATIVE_COMPONENTS:
                for ray_y in REPRESENTATIVE_COMPONENTS:
                    for exit_x, exit_y in ((0, 0), (14, 14)):
                        assert_case(
                            flags,
                            tangent=(-8, 264)[(ray_x ^ ray_y) & 1],
                            pre_cross_normal=(264, -8)[
                                (ray_x ^ ray_y) & 1
                            ],
                            ray_x=ray_x,
                            ray_y=ray_y,
                            delta_x=0x000100,
                            delta_y=0x3FFFFF,
                            entry_direction=entry_direction,
                            exit_direction=exit_direction,
                            exit_x=exit_x,
                            exit_y=exit_y,
                        )
                        count += 1
    return count


def check_random_cases(
    flags: tuple[int, ...],
    case_count: int,
    seed: int,
) -> None:
    rng = random.Random(seed)
    for _ in range(case_count):
        assert_case(
            flags,
            tangent=rng.randrange(-8, 265),
            pre_cross_normal=rng.randrange(-8, 265),
            ray_x=rng.randrange(INT24_MIN, INT24_MAX + 1),
            ray_y=rng.randrange(INT24_MIN, INT24_MAX + 1),
            delta_x=rng.randrange(1, 0x400000),
            delta_y=rng.randrange(1, 0x400000),
            entry_direction=rng.randrange(4),
            exit_direction=rng.randrange(4),
            exit_x=rng.randrange(15),
            exit_y=rng.randrange(15),
        )


def check_random_chains(case_count: int, seed: int) -> int:
    rng = random.Random(seed ^ 0xDDA57A7E)
    wall_map = empty_bordered_map()
    casts = 0

    for _ in range(case_count):
        origin_x = rng.randrange(2, 14) * FIXED_ONE + rng.randrange(1, 256)
        origin_y = rng.randrange(2, 14) * FIXED_ONE + rng.randrange(1, 256)
        ray_x = rng.choice(tuple(range(-425, 0)) + tuple(range(1, 426)))
        ray_y = rng.choice(tuple(range(-425, 0)) + tuple(range(1, 426)))
        delta_x = reciprocal_delta(ray_x)
        delta_y = reciprocal_delta(ray_y)
        invariant_threshold = (abs(ray_x) + abs(ray_y)) << 8

        for _depth in range(rng.randrange(1, 7)):
            _map_x, _map_y, side, _steps = cast_signature(
                wall_map, origin_x, origin_y, ray_x, ray_y
            )
            casts += 1
            if side == 0:
                entry_direction = DIR_NORTH if ray_x >= 0 else DIR_SOUTH
            else:
                entry_direction = DIR_WEST if ray_y >= 0 else DIR_EAST
            exit_direction = rng.randrange(4)
            exit_x = rng.randrange(2, 13)
            exit_y = rng.randrange(2, 13)
            tangent = rng.randrange(256)
            pre_cross_normal = rng.randrange(-8, 265)

            transformed = specialized_transform(
                EXPECTED_FLAGS,
                tangent,
                ray_x,
                ray_y,
                delta_x,
                delta_y,
                entry_direction,
                exit_direction,
                exit_x,
                exit_y,
            )
            origin_x, origin_y, ray_x, ray_y, rotation, delta_x, delta_y = (
                transformed
            )
            expected_delta_x = reciprocal_delta(ray_x)
            expected_delta_y = reciprocal_delta(ray_y)
            if (delta_x, delta_y) != (expected_delta_x, expected_delta_y):
                raise AssertionError(
                    "persistent delta drift in portal chain: "
                    f"{(delta_x, delta_y)} != "
                    f"{(expected_delta_x, expected_delta_y)}"
                )
            qx, qy, threshold, recurrence, axis_mode = seed_values(
                origin_x, origin_y, ray_x, ray_y
            )
            normal_q = qx if exit_direction in (DIR_NORTH, DIR_SOUTH) else qy
            if normal_q != 255:
                raise AssertionError(
                    f"portal restart normal q drifted: {normal_q}, "
                    f"entry={entry_direction}, exit={exit_direction}, "
                    f"rotation={rotation}"
                )
            if threshold != invariant_threshold:
                raise AssertionError(
                    f"portal chain threshold drifted: "
                    f"{threshold} != {invariant_threshold}"
                )
            if not 0 <= recurrence <= INT24_MASK:
                raise AssertionError(
                    f"portal chain recurrence overflowed: {recurrence}"
                )
            if axis_mode != 0:
                raise AssertionError(
                    "nonzero chain ray unexpectedly selected axis path"
                )

    return casts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases", type=int, default=1_000_000)
    parser.add_argument("--chains", type=int, default=5_000)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument(
        "--assembly",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "src" / "render_asm.s",
    )
    args = parser.parse_args()
    if args.cases < 1:
        parser.error("--cases must be positive")
    if args.chains < 1:
        parser.error("--chains must be positive")

    flags = parse_transform_flags(args.assembly)
    boundary_count = check_exhaustive_boundaries(flags)
    component_count = check_representative_components(flags)
    check_random_cases(flags, args.cases, args.seed)
    chain_casts = check_random_chains(args.chains, args.seed)
    print(
        "portal transform exact: "
        f"16 direction pairs, {boundary_count} exhaustive "
        "normal/tangent boundary cases (-8..264), "
        f"{component_count} representative signed-24-bit ray cases, "
        f"{args.cases} randomized signed-24-bit cases (seed {args.seed}); "
        f"{args.chains} randomized depth-1..6 persistent portal chains/"
        f"{chain_casts} exact bordered-map casts; origins, signed rotations, "
        "magnitude/delta swap parity, thresholds, q seeds, and casts match"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
