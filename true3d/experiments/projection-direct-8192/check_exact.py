#!/usr/bin/env python3
"""Exactness checks for the direct near-depth projection table."""

from __future__ import annotations

import hashlib
import random
import struct

PROJECTION_TABLE_SHIFT = 2
PROJECTION_TABLE_SIZE = 2048
NEAR_DEPTH_COUNT = PROJECTION_TABLE_SIZE << PROJECTION_TABLE_SHIFT
FAR_SHIFT = 5
NEAR_PLANE = 32
FOCAL = 42
FIXED_ONE = 256
SCALE_SHIFT = 6
PROJECTED_LIMIT = 1_048_576
NUMERATOR = FOCAL * FIXED_ONE * (1 << SCALE_SHIFT)


def build_baseline_tables() -> tuple[list[int], list[int]]:
    near = [0] * PROJECTION_TABLE_SIZE
    far = [0] * PROJECTION_TABLE_SIZE
    first = NEAR_PLANE >> PROJECTION_TABLE_SHIFT
    for index in range(first):
        near[index] = 65535
    for index in range(first, PROJECTION_TABLE_SIZE):
        near[index] = NUMERATOR // (index << PROJECTION_TABLE_SHIFT)
    for index in range(NEAR_DEPTH_COUNT >> FAR_SHIFT, PROJECTION_TABLE_SIZE):
        far[index] = NUMERATOR // (index << FAR_SHIFT)
    return near, far


def build_direct_table(baseline: list[int]) -> list[int]:
    direct: list[int] = []
    for scale in baseline:
        direct.extend((scale, scale, scale, scale))
    return direct


BASELINE_NEAR, FAR = build_baseline_tables()
DIRECT_NEAR = build_direct_table(BASELINE_NEAR)


def baseline_scale(depth: int) -> int:
    if depth >= NEAR_DEPTH_COUNT:
        index = depth >> FAR_SHIFT
        if index >= PROJECTION_TABLE_SIZE:
            index = PROJECTION_TABLE_SIZE - 1
        return FAR[index]
    index = depth >> PROJECTION_TABLE_SHIFT
    if index == 0:
        index = 1
    if index >= PROJECTION_TABLE_SIZE:
        index = PROJECTION_TABLE_SIZE - 1
    return BASELINE_NEAR[index]


def candidate_scale(depth: int) -> int:
    if depth >= NEAR_DEPTH_COUNT:
        index = depth >> FAR_SHIFT
        if index >= PROJECTION_TABLE_SIZE:
            index = PROJECTION_TABLE_SIZE - 1
        return FAR[index]
    return DIRECT_NEAR[depth]


def clamp_projected(value: int) -> int:
    return max(-PROJECTED_LIMIT, min(PROJECTED_LIMIT, value))


def project(x: int, y: int, depth: int, low_resolution: bool, candidate: bool):
    scale = candidate_scale(depth) if candidate else baseline_scale(depth)
    projected_x = clamp_projected(32 * FIXED_ONE + ((x * scale) >> SCALE_SHIFT))
    projected_y = clamp_projected(24 * FIXED_ONE - ((y * scale) >> SCALE_SHIFT))
    if low_resolution:
        projected_x >>= 1
        projected_y >>= 1
    return projected_x, projected_y


def main() -> None:
    # Every direct-table entry, including the legacy index-zero-to-one case.
    for depth in range(NEAR_DEPTH_COUNT):
        expected = baseline_scale(depth)
        actual = candidate_scale(depth)
        if actual != expected:
            raise AssertionError((depth, expected, actual))

    # Every unsaturated far depth plus all bucket/saturation boundaries.
    far_depths = set(range(NEAR_DEPTH_COUNT, PROJECTION_TABLE_SIZE << FAR_SHIFT))
    boundaries = (
        0, 1, 2, 3, 4, 7, 8, 15, 28, 29, 30, 31, 32, 33,
        NEAR_DEPTH_COUNT - 2, NEAR_DEPTH_COUNT - 1,
        NEAR_DEPTH_COUNT, NEAR_DEPTH_COUNT + 1,
        (PROJECTION_TABLE_SIZE << FAR_SHIFT) - 2,
        (PROJECTION_TABLE_SIZE << FAR_SHIFT) - 1,
        PROJECTION_TABLE_SIZE << FAR_SHIFT,
        (PROJECTION_TABLE_SIZE << FAR_SHIFT) + 1,
        1_048_576, 8_388_606, 8_388_607,
    )
    far_depths.update(boundaries)
    for depth in sorted(far_depths):
        expected = baseline_scale(depth)
        actual = candidate_scale(depth)
        if actual != expected:
            raise AssertionError((depth, expected, actual))

    rng = random.Random(0x3D819)
    baseline_hash = hashlib.sha256()
    candidate_hash = hashlib.sha256()
    projected_cases = 200_000
    depth_boundaries = tuple(sorted(far_depths))
    for case in range(projected_cases):
        if case & 1:
            depth = rng.randrange(NEAR_DEPTH_COUNT)
        elif case & 2:
            depth = rng.choice(depth_boundaries)
        else:
            depth = rng.randrange(NEAR_PLANE, 8_388_608)
        x = rng.randint(-2_097_152, 2_097_152)
        y = rng.randint(-2_097_152, 2_097_152)
        low_resolution = bool(rng.getrandbits(1))
        expected = project(x, y, depth, low_resolution, False)
        actual = project(x, y, depth, low_resolution, True)
        if actual != expected:
            raise AssertionError((x, y, depth, low_resolution, expected, actual))
        record = struct.pack("<iii?", expected[0], expected[1], depth, low_resolution)
        baseline_hash.update(record)
        candidate_hash.update(struct.pack("<iii?", actual[0], actual[1], depth, low_resolution))

    if baseline_hash.digest() != candidate_hash.digest():
        raise AssertionError("projected output hashes differ")

    print(f"near depths checked: {NEAR_DEPTH_COUNT:,}")
    print(f"far/boundary depths checked: {len(far_depths):,}")
    print(f"projected point cases checked: {projected_cases:,}")
    print(f"projection SHA-256: {baseline_hash.hexdigest()}")


if __name__ == "__main__":
    main()
