#!/usr/bin/env python3
"""Verify the interleaved wall texel/run descriptor layout."""

from __future__ import annotations


MATERIALS = 4
WIDTH = 16
HEIGHT = 8
DESCRIPTOR_SIZE = 2
FIXED_ONE = 256
MAX_POSITIVE_DISTANCE = 0x7FFFFF


def texel(material: int, x: int, y: int) -> int:
    y *= 2
    if material == 0:
        mortar = x == 0 or y == 0 or y == 8 or (y >= 8 and x == 8)
        noise = (x * 5 + y * 3 + ((x ^ y) * 7)) & 3
        return 0 if mortar else 2 + noise
    if material == 1:
        seam = x in (0, 8) or y in (0, 8)
        rivet = (x & 7) in (2, 6) and (y & 7) in (2, 6)
        brushed = 2 + ((x * 3 + y * 5 + (x ^ y)) & 3)
        return 0 if seam else (7 if rivet else brushed)
    if material == 2:
        joint = y in (0, 8) or (x == 0 if y < 8 else x == 8)
        aggregate = 2 + ((x * 7 + y * 11 + (x ^ (y * 3))) & 3)
        pock = ((x * 13 + y * 5) & 31) == 0
        return 0 if joint else (1 if pock else aggregate)

    seam = x in (0, 8) or y in (0, 8)
    hazard = (x + y) & 7
    plate = 2 + ((x * 5 + y * 3 + (x ^ y)) & 3)
    return 0 if seam else (6 + (hazard & 1) if hazard < 2 else plate)


def legacy_distance_shade_tier(distance: int) -> int:
    """Model wall_shade_level()'s distance-only contribution."""
    if distance > FIXED_ONE * 8:
        return 2
    if distance > FIXED_ONE * 4:
        return 1
    return 0


def optimized_distance_shade_tier(distance: int) -> int:
    """Model the upper-byte test and DEC-HL comparisons in render_asm.s."""
    if (distance >> 16) != 0:
        return 2

    middle_byte_after_decrement = ((distance - 1) >> 8) & 0xFF
    if middle_byte_after_decrement >= 8:
        return 2
    if middle_byte_after_decrement >= 4:
        return 1
    return 0


def check_distance_shade_tiers() -> None:
    for distance in range(1, MAX_POSITIVE_DISTANCE + 1):
        legacy = legacy_distance_shade_tier(distance)
        optimized = optimized_distance_shade_tier(distance)
        if legacy != optimized:
            raise AssertionError(
                f"shade tier mismatch at distance {distance}: "
                f"legacy={legacy}, optimized={optimized}"
            )

    # The side contribution is either zero or one, so these distance tiers
    # also preserve the final four-level wall/portal shade without saturation.
    for side in (0, 1):
        for tier in (0, 1, 2):
            assert min(side + tier, 3) == side + tier


def main() -> None:
    descriptor_count = MATERIALS * WIDTH * HEIGHT
    descriptors = bytearray(descriptor_count * DESCRIPTOR_SIZE + 1)
    checked = 0

    for material in range(MATERIALS):
        for x in range(WIDTH):
            column = [texel(material, x, y) for y in range(HEIGHT)]
            assembly_base = (
                (material * WIDTH * HEIGHT) + x * HEIGHT
            ) * DESCRIPTOR_SIZE
            assert assembly_base == (material << 8) | (x << 4)

            for y, value in enumerate(column):
                next_y = y + 1
                while next_y < HEIGHT and column[next_y] == value:
                    next_y += 1

                descriptor = (
                    (material * WIDTH * HEIGHT + x * HEIGHT + y) *
                    DESCRIPTOR_SIZE
                )
                assert descriptor == assembly_base + y * DESCRIPTOR_SIZE
                descriptors[descriptor] = value * 4
                descriptors[descriptor + 1] = next_y
                assert 0 <= value <= 7
                assert y < next_y <= HEIGHT
                checked += 1

    for material in range(MATERIALS):
        for x in range(WIDTH):
            for y in range(HEIGHT):
                descriptor = (
                    (material * WIDTH * HEIGHT + x * HEIGHT + y) *
                    DESCRIPTOR_SIZE
                )
                value = descriptors[descriptor]
                next_y = descriptors[descriptor + 1]
                assert value == texel(material, x, y) * 4
                assert all(
                    texel(material, x, row) * 4 == value
                    for row in range(y, next_y)
                )
                assert (
                    next_y == HEIGHT or
                    texel(material, x, next_y) * 4 != value
                )

    # Assembly uses a three-byte load to fetch each two-byte descriptor.
    assert len(descriptors) == descriptor_count * DESCRIPTOR_SIZE + 1
    assert descriptors[-1] == 0
    print(f"wall descriptors exact: {checked} texel/run entries plus safe tail padding")
    check_distance_shade_tiers()
    print(
        "wall/portal shade tiers exact: "
        f"{MAX_POSITIVE_DISTANCE:,} positive 24-bit distances"
    )
if __name__ == "__main__":
    main()
