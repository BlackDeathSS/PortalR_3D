#!/usr/bin/env python3
"""Host exactness and raster-hash checks for edge_divide_q8_exact."""

from __future__ import annotations

import hashlib
import math
import random
import struct

FIXED_ONE = 256
EDGE_RECIPROCAL_SHIFT = 4
EDGE_RECIPROCAL_SIZE = 2048
EDGE_STEP_PRECISION_SHIFT = 12
PROJECTED_LIMIT = 1_048_576
RENDER_HEIGHT = 48


def reference_divide(delta_x: int, delta_y: int) -> int:
    magnitude = (abs(delta_x) << 8) // delta_y
    return -magnitude if delta_x < 0 else magnitude


def specialized_divide_model(delta_x: int, delta_y: int) -> int:
    """Bit-accurate model of the 30-iteration assembly routine."""
    quotient = (abs(delta_x) << 10) & 0xFFFFFFFF
    remainder = 0
    for _ in range(30):
        carry = quotient >> 31
        quotient = (quotient << 1) & 0xFFFFFFFF
        remainder = (remainder << 1) | carry
        if remainder >= delta_y:
            remainder -= delta_y
            quotient |= 1
    assert remainder < delta_y
    assert quotient < (1 << 30)
    return -quotient if delta_x < 0 else quotient


def is_fallback(delta_x: int, delta_y: int) -> bool:
    index = (delta_y + 8) >> EDGE_RECIPROCAL_SHIFT
    return (
        delta_y < FIXED_ONE
        or index >= EDGE_RECIPROCAL_SIZE
        or delta_x > 32767
        or delta_x < -32767
    )


def reciprocal_table() -> list[int]:
    table = [0] * EDGE_RECIPROCAL_SIZE
    numerator = 1 << (EDGE_STEP_PRECISION_SHIFT + 8)
    for index in range(1, EDGE_RECIPROCAL_SIZE):
        denominator = index << EDGE_RECIPROCAL_SHIFT
        table[index] = min(65535, (numerator + denominator // 2) // denominator)
    return table


RECIPROCAL = reciprocal_table()


def edge_step(delta_x: int, delta_y: int, specialized: bool) -> int:
    index = (delta_y + 8) >> EDGE_RECIPROCAL_SHIFT
    if is_fallback(delta_x, delta_y):
        if specialized:
            return specialized_divide_model(delta_x, delta_y)
        return reference_divide(delta_x, delta_y)
    return (delta_x * RECIPROCAL[index]) >> EDGE_STEP_PRECISION_SHIFT


def floor_q8(value: int) -> int:
    if value >= 0:
        return value // FIXED_ONE
    return -((-value + FIXED_ONE - 1) // FIXED_ONE)


def ceil_q8(value: int) -> int:
    if value >= 0:
        return (value + FIXED_ONE - 1) // FIXED_ONE
    return -((-value) // FIXED_ONE)


def raster_spans(points: list[tuple[int, int]], lod_shift: int, specialized: bool):
    step = 1 << lod_shift
    sample_origin = step >> 1
    minimum_y = min(y for _, y in points)
    maximum_y = max(y for _, y in points)
    first_row = max(0, ceil_q8(minimum_y - FIXED_ONE // 2))
    last_row = min(RENDER_HEIGHT - 1, floor_q8(maximum_y - 1 - FIXED_ONE // 2))
    if first_row <= sample_origin:
        first_row = sample_origin
    else:
        first_row = sample_origin + (
            ((first_row - sample_origin + step - 1) >> lod_shift) << lod_shift
        )
    if first_row > last_row:
        return ()

    left = {row: PROJECTED_LIMIT + 1 for row in range(first_row, last_row + 1, step)}
    right = {row: -PROJECTED_LIMIT - 1 for row in range(first_row, last_row + 1, step)}
    for index, point_a in enumerate(points):
        ax, ay = point_a
        bx, by = points[(index + 1) % len(points)]
        if ay == by:
            continue
        if ay > by:
            ax, bx = bx, ax
            ay, by = by, ay
        delta_x = bx - ax
        delta_y = by - ay
        edge_first = max(first_row, ceil_q8(ay - FIXED_ONE // 2))
        edge_last = min(last_row, floor_q8(by - 1 - FIXED_ONE // 2))
        if edge_first <= sample_origin:
            edge_first = sample_origin
        else:
            edge_first = sample_origin + (
                ((edge_first - sample_origin + step - 1) >> lod_shift) << lod_shift
            )
        if edge_first > edge_last:
            continue
        x_step = edge_step(delta_x, delta_y, specialized)
        x_value = ax + (
            x_step * (edge_first * FIXED_ONE + FIXED_ONE // 2 - ay) >> 8
        )
        for row in range(edge_first, edge_last + 1, step):
            left[row] = min(left[row], max(-PROJECTED_LIMIT, min(PROJECTED_LIMIT, x_value)))
            right[row] = max(right[row], max(-PROJECTED_LIMIT, min(PROJECTED_LIMIT, x_value)))
            if row + step <= edge_last:
                x_value += x_step * step
    return tuple((row, left[row], right[row]) for row in left)


def boundary_values(limit: int) -> list[int]:
    values = {0, 1, limit}
    for power in range(0, limit.bit_length()):
        center = 1 << power
        for offset in (-2, -1, 0, 1, 2):
            value = center + offset
            if 0 <= value <= limit:
                values.add(value)
    return sorted(values)


def main() -> None:
    dx_magnitudes = set(boundary_values(2_097_152))
    dx_magnitudes.update((255, 256, 257, 32766, 32767, 32768, 32769, 1_048_575, 1_048_576))
    delta_x_values = sorted(dx_magnitudes | {-value for value in dx_magnitudes})
    delta_y_values = set(boundary_values(2_097_152)) - {0}
    delta_y_values.update((254, 255, 256, 257, 32758, 32759, 32760, 32767, 32768, 32776, 32777))

    checked = 0
    for delta_x in delta_x_values:
        for delta_y in sorted(delta_y_values):
            expected = reference_divide(delta_x, delta_y)
            actual = specialized_divide_model(delta_x, delta_y)
            if actual != expected:
                raise AssertionError((delta_x, delta_y, expected, actual))
            checked += 1

    rng = random.Random(0xE3D06)
    cause_counts = {"short": 0, "tall": 0, "wide": 0, "table": 0}
    for _ in range(250_000):
        delta_x = rng.randint(-2_097_152, 2_097_152)
        delta_y = rng.randint(1, 2_097_152)
        expected = reference_divide(delta_x, delta_y)
        actual = specialized_divide_model(delta_x, delta_y)
        if actual != expected:
            raise AssertionError((delta_x, delta_y, expected, actual))
        checked += 1
        if delta_y < 256:
            cause_counts["short"] += 1
        elif ((delta_y + 8) >> 4) >= 2048:
            cause_counts["tall"] += 1
        elif abs(delta_x) > 32767:
            cause_counts["wide"] += 1
        else:
            cause_counts["table"] += 1

    # Bias a second random corpus toward every fallback boundary; uniform
    # sampling overwhelmingly selects the tall category.
    fallback_dy = [1, 2, 3, 7, 15, 31, 63, 127, 254, 255,
                   32759, 32760, 32767, 32768, 32776, 32777,
                   65535, 65536, 1_048_576, 2_097_152]
    fallback_dx = [-2_097_152, -1_048_576, -32769, -32768, -32767,
                   -1, 0, 1, 32767, 32768, 32769, 1_048_576, 2_097_152]
    for _ in range(100_000):
        delta_x = rng.choice(fallback_dx) if rng.randrange(2) else rng.randint(-2_097_152, 2_097_152)
        delta_y = rng.choice(fallback_dy)
        expected = reference_divide(delta_x, delta_y)
        actual = specialized_divide_model(delta_x, delta_y)
        if actual != expected:
            raise AssertionError((delta_x, delta_y, expected, actual))
        checked += 1

    base_hash = hashlib.sha256()
    specialized_hash = hashlib.sha256()
    raster_cases = 20_000
    raster_fallback_edges = 0
    for _ in range(raster_cases):
        count = rng.randint(3, 8)
        center_x = rng.randint(-64 * FIXED_ONE, 128 * FIXED_ONE)
        center_y = rng.randint(-32 * FIXED_ONE, 80 * FIXED_ONE)
        angles = sorted(rng.random() * math.tau for _ in range(count))
        points = []
        for angle in angles:
            # Include ordinary projected polygons plus deliberately clipped
            # extremes that exercise short, tall, and wide fallback edges.
            radius_x = rng.choice((rng.randint(1, 512) * FIXED_ONE,
                                  rng.randint(32768, PROJECTED_LIMIT)))
            radius_y = rng.choice((rng.randint(1, 128) * FIXED_ONE,
                                  rng.randint(32760, PROJECTED_LIMIT)))
            x = max(-PROJECTED_LIMIT, min(PROJECTED_LIMIT,
                    center_x + int(math.cos(angle) * radius_x)))
            y = max(-PROJECTED_LIMIT, min(PROJECTED_LIMIT,
                    center_y + int(math.sin(angle) * radius_y)))
            points.append((x, y))
        raster_fallback_edges += sum(
            1 for i, (ax, ay) in enumerate(points)
            if points[(i + 1) % count][1] != ay
            for bx, by in [points[(i + 1) % count]]
            if is_fallback(bx - ax, abs(by - ay))
        )
        lod_shift = rng.randrange(3)
        baseline = raster_spans(points, lod_shift, False)
        candidate = raster_spans(points, lod_shift, True)
        if baseline != candidate:
            raise AssertionError((points, lod_shift, baseline, candidate))
        for digest, spans in ((base_hash, baseline), (specialized_hash, candidate)):
            digest.update(struct.pack("<B", lod_shift))
            digest.update(struct.pack("<B", len(spans)))
            for row, left, right in spans:
                digest.update(struct.pack("<Bii", row, left, right))

    if base_hash.digest() != specialized_hash.digest():
        raise AssertionError("raster hashes differ")

    print(f"exact quotient cases: {checked:,} passed")
    print(f"random category sample: {cause_counts}")
    print(f"raster cases: {raster_cases:,} passed")
    print(f"raster fallback edges exercised: {raster_fallback_edges:,}")
    print(f"raster SHA-256: {base_hash.hexdigest()}")


if __name__ == "__main__":
    main()
