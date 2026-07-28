#!/usr/bin/env python3
"""Validate the assembly exact-DDA accumulator and legacy projection rebuild."""

from __future__ import annotations

import argparse
import random


BIAS = 0x800000
MASK24 = 0xFFFFFF
FIXED_INF = 0x3FFFFF
EDGE_Q = (0, 1, 2, 3, 127, 128, 129, 253, 254, 255, 256)
EDGE_COMPONENT = (0, 1, 2, 3, 4, 25, 154, 255, 256, 257, 424, 425)


def reciprocal_delta(component: int) -> int:
    if component == 0:
        return FIXED_INF
    if component == 1:
        return 65536
    return 65536 // min(component, 425)


def assembly_q_product(q: int, component: int) -> int:
    """Model .Lmul_q_component's one-MLT plus high-bit correction."""
    if q == 256:
        return component << 8
    low_product = q * (component & 0xFF)
    high_correction = (q << 8) if component & 0x100 else 0
    return low_product + high_correction


def initial_side(q: int, component: int) -> int:
    if component == 0:
        return FIXED_INF
    delta = reciprocal_delta(component)
    return delta if q == 256 else (q * delta) >> 8


def trunc_div_256(value: int) -> int:
    return value // 256 if value >= 0 else -((-value) // 256)


def choose_side(error: int, wall_map: list[int], index: int, sx: int, sy: int) -> int:
    if error < 0:
        return 0
    if error > 0:
        return 1

    # Match the renderer's point-only corner rule: enter X only when the
    # default Y neighbor is solid and the X neighbor is empty.
    y_wall = wall_map[index + sy * 16]
    x_wall = wall_map[index + sx]
    return 0 if y_wall and not x_wall else 1


def make_map(rng: random.Random) -> list[int]:
    wall_map = [0] * 256
    for y in range(16):
        for x in range(16):
            if x == 0 or x == 15 or y == 0 or y == 15:
                wall_map[y * 16 + x] = 1
            elif rng.random() < 0.18:
                wall_map[y * 16 + x] = 1
    return wall_map


def check_cast(
    wall_map: list[int],
    start_x: int,
    start_y: int,
    fraction_x: int,
    fraction_y: int,
    ray_x: int,
    ray_y: int,
) -> int:
    sx = -1 if ray_x < 0 else 1
    sy = -1 if ray_y < 0 else 1
    ax = abs(ray_x)
    ay = abs(ray_y)
    qx = fraction_x if ray_x < 0 else 256 - fraction_x
    qy = fraction_y if ray_y < 0 else 256 - fraction_y
    side_x = initial_side(qx, ax)
    side_y = initial_side(qy, ay)
    delta_x = reciprocal_delta(ax)
    delta_y = reciprocal_delta(ay)
    initial_x = side_x
    initial_y = side_y
    error_biased = BIAS + assembly_q_product(qx, ay) - assembly_q_product(qy, ax)
    ax_step = ax << 8
    ay_step = ay << 8
    threshold = ax_step + ay_step
    recurrence = qx * ay - qy * ax + ax_step
    map_x = start_x
    map_y = start_y
    index = map_y * 16 + map_x
    steps = 0

    while True:
        exact_error = qx * ay - qy * ax
        if not 0 <= error_biased <= 0xFFFFFF:
            raise AssertionError(("biased overflow", error_biased, exact_error))
        if error_biased - BIAS != exact_error:
            raise AssertionError(("error drift", error_biased - BIAS, exact_error))
        if recurrence != exact_error + ax_step or not 0 <= recurrence <= MASK24:
            raise AssertionError(("recurrence drift", recurrence, exact_error, ax_step))

        result = (recurrence + ay_step - threshold) & MASK24
        carry = recurrence + ay_step < threshold
        if result == 0:
            recurrence_side = choose_side(0, wall_map, index, sx, sy)
        else:
            recurrence_side = 0 if carry else 1

        reference_side = choose_side(exact_error, wall_map, index, sx, sy)
        accumulator_side = choose_side(error_biased - BIAS, wall_map, index, sx, sy)
        if accumulator_side != reference_side:
            raise AssertionError(("ownership", accumulator_side, reference_side))
        if recurrence_side != reference_side:
            raise AssertionError(("recurrence ownership", recurrence_side, reference_side))

        side = accumulator_side
        if side == 0:
            qx += 256
            error_biased += ay << 8
            recurrence = (result + threshold) & MASK24
            side_x += delta_x
            map_x += sx
            index += sx
        else:
            qy += 256
            error_biased -= ax << 8
            recurrence = result
            side_y += delta_y
            map_y += sy
            index += sy * 16
        steps += 1

        if wall_map[index]:
            break
        if steps > 30:
            raise AssertionError("bordered map did not terminate")

    if side == 0:
        legacy_distance = side_x - delta_x
        displacement = abs(map_x - start_x)
        rebuilt_distance = initial_x + (displacement - 1) * delta_x
        origin_minor = start_y * 256 + fraction_y
        wall_u_legacy = (origin_minor + trunc_div_256(legacy_distance * ray_y)) & 0xFF
        wall_u_rebuilt = (origin_minor + trunc_div_256(rebuilt_distance * ray_y)) & 0xFF
    else:
        legacy_distance = side_y - delta_y
        displacement = abs(map_y - start_y)
        rebuilt_distance = initial_y + (displacement - 1) * delta_y
        origin_minor = start_x * 256 + fraction_x
        wall_u_legacy = (origin_minor + trunc_div_256(legacy_distance * ray_x)) & 0xFF
        wall_u_rebuilt = (origin_minor + trunc_div_256(rebuilt_distance * ray_x)) & 0xFF

    legacy_distance = max(legacy_distance, 1)
    rebuilt_distance = max(rebuilt_distance, 1)
    if rebuilt_distance != legacy_distance:
        raise AssertionError(("distance", rebuilt_distance, legacy_distance))
    if wall_u_rebuilt != wall_u_legacy:
        raise AssertionError(("wall_u", wall_u_rebuilt, wall_u_legacy))
    return steps


def check_axis_boundary_cast(
    wall_map: list[int],
    start_x: int,
    start_y: int,
    fraction: int,
    component: int,
    horizontal: bool,
) -> int:
    """Model the preserved two-cell path for a ray on an exact boundary."""
    step = -1 if component < 0 else 1
    magnitude = abs(component)
    q = fraction if component < 0 else 256 - fraction
    delta = reciprocal_delta(magnitude)
    initial = initial_side(q, magnitude)
    side_distance = initial
    map_x = start_x
    map_y = start_y
    steps = 0

    while True:
        side_distance += delta
        if horizontal:
            map_x += step
            here = wall_map[map_y * 16 + map_x]
            adjacent = wall_map[(map_y - 1) * 16 + map_x]
        else:
            map_y += step
            here = wall_map[map_y * 16 + map_x]
            adjacent = wall_map[map_y * 16 + map_x - 1]
        steps += 1
        if here and adjacent:
            break
        if steps > 15:
            raise AssertionError("axis boundary path did not reach the solid border")

    displacement = abs((map_x - start_x) if horizontal else (map_y - start_y))
    rebuilt = initial + (displacement - 1) * delta
    accumulated = side_distance - delta
    if rebuilt != accumulated:
        raise AssertionError(("axis distance", rebuilt, accumulated))
    return steps


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--samples", type=int, default=150_000)
    parser.add_argument("--seed", type=int, default=0xDDA84CE)
    args = parser.parse_args()
    rng = random.Random(args.seed)

    algebra_cases = 0
    for qx in EDGE_Q:
        for qy in EDGE_Q:
            for ax in EDGE_COMPONENT:
                for ay in EDGE_COMPONENT:
                    if ax == ay == 0:
                        continue
                    if assembly_q_product(qx, ay) != qx * ay:
                        raise AssertionError(("qx product", qx, ay))
                    if assembly_q_product(qy, ax) != qy * ax:
                        raise AssertionError(("qy product", qy, ax))
                    exact = qx * ay - qy * ax
                    biased = BIAS + exact
                    if not 0 <= biased <= 0xFFFFFF:
                        raise AssertionError(("edge overflow", qx, qy, ax, ay, exact))
                    exact_side = -1 if exact < 0 else 1 if exact > 0 else 0
                    biased_side = -1 if biased < BIAS else 1 if biased > BIAS else 0
                    if biased_side != exact_side:
                        raise AssertionError(("edge sign", qx, qy, ax, ay))
                    ax_step = ax << 8
                    ay_step = ay << 8
                    recurrence = exact + ax_step
                    threshold = ax_step + ay_step
                    result = (recurrence + ay_step - threshold) & MASK24
                    carry = recurrence + ay_step < threshold
                    recurrence_side = -1 if carry else 0 if result == 0 else 1
                    if recurrence_side != exact_side:
                        raise AssertionError(
                            ("edge recurrence sign", qx, qy, ax, ay)
                        )
                    algebra_cases += 1

    maps = [make_map(rng) for _ in range(64)]
    axis_cases = 0
    axis_steps = 0
    while axis_cases < 10_000:
        wall_map = maps[rng.randrange(len(maps))]
        start_x = rng.randrange(1, 15)
        start_y = rng.randrange(1, 15)
        horizontal = bool(rng.getrandbits(1))
        # The two cells sharing the starting boundary must both be open.
        other_index = (
            (start_y - 1) * 16 + start_x
            if horizontal
            else start_y * 16 + start_x - 1
        )
        if wall_map[start_y * 16 + start_x] or wall_map[other_index]:
            continue
        component = rng.choice((-1, 1)) * rng.randrange(1, 426)
        axis_steps += check_axis_boundary_cast(
            wall_map,
            start_x,
            start_y,
            rng.randrange(256),
            component,
            horizontal,
        )
        axis_cases += 1

    total_steps = 0
    cast_cases = 0
    while cast_cases < args.samples:
        wall_map = maps[rng.randrange(len(maps))]
        start_x = rng.randrange(1, 15)
        start_y = rng.randrange(1, 15)
        wall_map[start_y * 16 + start_x] = 0
        fraction_x = rng.randrange(256)
        fraction_y = rng.randrange(256)
        ray_x = rng.randrange(-425, 426)
        ray_y = rng.randrange(-425, 426)
        if ray_x == ray_y == 0:
            continue
        # Exact zero-component boundary rays use the preserved specialized
        # two-cell ownership path, not the generic accumulator under test.
        if (ray_x == 0 and fraction_x == 0) or (ray_y == 0 and fraction_y == 0):
            continue
        total_steps += check_cast(
            wall_map,
            start_x,
            start_y,
            fraction_x,
            fraction_y,
            ray_x,
            ray_y,
        )
        cast_cases += 1

    print(
        f"exact DDA OK: {algebra_cases} edge products, "
        f"{axis_cases} axis-boundary casts/{axis_steps} steps, "
        f"{cast_cases} bordered-map casts/{total_steps} steps"
    )


if __name__ == "__main__":
    main()
