#!/usr/bin/env python3
"""Property-check the exact assembly floor-grid X projection."""

from __future__ import annotations

import random


SCREEN_WIDTH = 320
SCREEN_CENTER_X = 160
PROJECT_LIMIT = 4096
FIXED_ONE = 256
INT24_MIN = -0x800000
INT24_MAX = 0x7FFFFF

# FLOOR_NEAR_HEIGHT/FLOOR_FAR_HEIGHT are compile-time checked in game.c.
# These are the corresponding viewport-edge thresholds used by the early
# rejection in render_asm.s.
NEAR_HEIGHT = 236
FAR_HEIGHT = 15
NEAR_LEFT_EDGE = -175
NEAR_RIGHT_EDGE = 174
FAR_LEFT_EDGE = -2748
FAR_RIGHT_EDGE = 2731
RANDOM_CULL_CASES = 100_000
RANDOM_SEED = 0x3D_C011


def trunc_div(value: int, divisor: int) -> int:
    """C99 signed division: truncate toward zero."""
    if value < 0:
        return -((-value) // divisor)
    return value // divisor


def reference(lateral: int, positive_limit: int, negative_limit: int, height: int) -> int:
    if lateral >= positive_limit:
        return PROJECT_LIMIT
    if lateral <= -negative_limit:
        return -PROJECT_LIMIT
    return SCREEN_CENTER_X + trunc_div(lateral * height, FIXED_ONE)


def assembly_model(
    lateral: int,
    positive_limit: int,
    negative_limit: int,
    height: int,
) -> int:
    negative = lateral < 0
    magnitude = -lateral if negative else lateral
    if (not negative and magnitude >= positive_limit) or (
        negative and magnitude >= negative_limit
    ):
        return -PROJECT_LIMIT if negative else PROJECT_LIMIT

    x0 = magnitude & 0xFF
    x1 = (magnitude >> 8) & 0xFF
    x2 = (magnitude >> 16) & 0xFF
    # Derived clamp limits keep this partial product within one byte for
    # every supported 8-bit projection height.
    assert x2 * height <= 0xFF
    projected = ((x0 * height) >> 8) + x1 * height + (x2 * height << 8)
    return SCREEN_CENTER_X - projected if negative else SCREEN_CENTER_X + projected


def projection_limits(height: int) -> tuple[int, int]:
    return (
        ((PROJECT_LIMIT - SCREEN_CENTER_X) * FIXED_ONE) // height,
        ((PROJECT_LIMIT + SCREEN_CENTER_X) * FIXED_ONE) // height,
    )


def project_endpoint(lateral: int, height: int) -> int:
    positive_limit, negative_limit = projection_limits(height)
    return reference(lateral, positive_limit, negative_limit, height)


def projected_cull_side(lateral_near: int, lateral_far: int) -> int:
    """Return -1/1 when both projected endpoints are wholly off one X edge."""
    near_x = project_endpoint(lateral_near, NEAR_HEIGHT)
    far_x = project_endpoint(lateral_far, FAR_HEIGHT)
    if near_x < 0 and far_x < 0:
        return -1
    if near_x >= SCREEN_WIDTH and far_x >= SCREEN_WIDTH:
        return 1
    return 0


def assembly_precheck_side(lateral_near: int, lateral_far: int) -> int:
    """Model the sign-directed threshold branches in render_asm.s."""
    if lateral_near < 0:
        if lateral_near <= NEAR_LEFT_EDGE and lateral_far <= FAR_LEFT_EDGE:
            return -1
    elif lateral_near >= NEAR_RIGHT_EDGE and lateral_far >= FAR_RIGHT_EDGE:
        return 1
    return 0


def check_cull_pair(lateral_near: int, lateral_far: int) -> None:
    expected = projected_cull_side(lateral_near, lateral_far)
    actual = assembly_precheck_side(lateral_near, lateral_far)
    if actual != expected:
        raise AssertionError(
            "grid pre-cull mismatch: "
            f"near={lateral_near} far={lateral_far}: "
            f"projected side {expected}, precheck side {actual}"
        )


def check_early_cull() -> tuple[int, int]:
    # Independently derive the first lateral values whose truncating
    # projections fall left of x=0 or reach x=SCREEN_WIDTH.
    derived_near_left = -(
        ((SCREEN_CENTER_X + 1) * FIXED_ONE + NEAR_HEIGHT - 1) // NEAR_HEIGHT
    )
    derived_near_right = (
        SCREEN_CENTER_X * FIXED_ONE + NEAR_HEIGHT - 1
    ) // NEAR_HEIGHT
    derived_far_left = -(
        ((SCREEN_CENTER_X + 1) * FIXED_ONE + FAR_HEIGHT - 1) // FAR_HEIGHT
    )
    derived_far_right = (
        SCREEN_CENTER_X * FIXED_ONE + FAR_HEIGHT - 1
    ) // FAR_HEIGHT
    derived = (
        derived_near_left,
        derived_near_right,
        derived_far_left,
        derived_far_right,
    )
    encoded = (
        NEAR_LEFT_EDGE,
        NEAR_RIGHT_EDGE,
        FAR_LEFT_EDGE,
        FAR_RIGHT_EDGE,
    )
    if encoded != derived:
        raise AssertionError(
            f"encoded grid pre-cull thresholds {encoded} != derived {derived}"
        )

    # Cross the two endpoint thresholds in every combination, including both
    # exact boundary values and several values on either side.
    near_cases = {
        value
        for edge in (NEAR_LEFT_EDGE, NEAR_RIGHT_EDGE)
        for value in range(edge - 8, edge + 9)
    }
    near_cases.update((INT24_MIN, -1, 0, INT24_MAX))
    far_cases = {
        value
        for edge in (FAR_LEFT_EDGE, FAR_RIGHT_EDGE)
        for value in range(edge - 8, edge + 9)
    }
    far_cases.update((INT24_MIN, -1, 0, INT24_MAX))

    threshold_cases = 0
    for lateral_near in sorted(near_cases):
        for lateral_far in sorted(far_cases):
            check_cull_pair(lateral_near, lateral_far)
            threshold_cases += 1

    # A fixed seed makes failures reproducible. Half the pairs span the full
    # signed-24-bit domain; half concentrate on the useful projection range.
    rng = random.Random(RANDOM_SEED)
    for index in range(RANDOM_CULL_CASES):
        if index & 1:
            lateral_near = rng.randint(-8192, 8192)
            lateral_far = rng.randint(-8192, 8192)
        else:
            lateral_near = rng.randint(INT24_MIN, INT24_MAX)
            lateral_far = rng.randint(INT24_MIN, INT24_MAX)
        check_cull_pair(lateral_near, lateral_far)

    return threshold_cases, RANDOM_CULL_CASES


def check_projection(height: int) -> int:
    positive_limit, negative_limit = projection_limits(height)
    cases = 0

    first = -negative_limit - 2
    last = positive_limit + 2
    for lateral in range(first, last + 1):
        expected = reference(lateral, positive_limit, negative_limit, height)
        actual = assembly_model(lateral, positive_limit, negative_limit, height)
        if actual != expected:
            raise AssertionError(
                f"height={height} lateral={lateral}: expected {expected}, got {actual}"
            )
        cases += 1

    for lateral in (-0x800000, -0x7FFFFF, 0x7FFFFE, 0x7FFFFF):
        if first <= lateral <= last:
            continue
        expected = reference(lateral, positive_limit, negative_limit, height)
        actual = assembly_model(lateral, positive_limit, negative_limit, height)
        if actual != expected:
            raise AssertionError(
                f"height={height} lateral={lateral}: expected {expected}, got {actual}"
            )
        cases += 1

    return cases


def main() -> None:
    cases = sum(check_projection(height) for height in range(1, 256))
    threshold_cases, random_cases = check_early_cull()
    print(
        "grid projection exact: "
        f"{cases} exhaustive cases across every supported height 1..255; "
        f"early cull exact for {threshold_cases} threshold-neighborhood and "
        f"{random_cases} deterministic random endpoint pairs"
    )


if __name__ == "__main__":
    main()
