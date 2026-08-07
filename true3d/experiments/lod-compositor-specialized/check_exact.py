"""Bit-exact host oracle for the specialized portal LOD compositor."""

from __future__ import annotations

import random


STRIDE = 32


def reference_span(frame: bytes, row: int, left: int, right: int, shift: int) -> bytes:
    source_row = (row >> shift) * STRIDE
    return bytes(frame[source_row + (column >> shift)] for column in range(left, right + 1))


def half_span(frame: bytes, row: int, left: int, right: int) -> bytes:
    source = (row >> 1) * STRIDE + (left >> 1)
    column = left
    result = bytearray()

    if column & 1:
        result.append(frame[source])
        source += 1
        column += 1
    while column < right:
        color = frame[source]
        source += 1
        result.extend((color, color))
        column += 2
    if column <= right:
        result.append(frame[source])
    return bytes(result)


def quarter_span(frame: bytes, row: int, left: int, right: int) -> bytes:
    source = (row >> 2) * STRIDE + (left >> 2)
    column = left
    phase = column & 3
    result = bytearray()

    if phase:
        color = frame[source]
        source += 1
        while True:
            result.append(color)
            column += 1
            phase += 1
            if column > right or phase >= 4:
                break
    while column + 3 <= right:
        color = frame[source]
        source += 1
        result.extend((color, color, color, color))
        column += 4
    if column <= right:
        color = frame[source]
        while column <= right:
            result.append(color)
            column += 1
    return bytes(result)


def apply_reference(
    destination: bytearray,
    frame: bytes,
    width: int,
    first_row: int,
    last_row: int,
    row_left: list[int],
    row_right: list[int],
    shift: int,
) -> None:
    for row in range(first_row, last_row + 1):
        left = row_left[row]
        right = row_right[row]
        if left <= right:
            start = row * width + left
            destination[start : start + right - left + 1] = reference_span(
                frame, row, left, right, shift
            )


def apply_specialized(
    destination: bytearray,
    frame: bytes,
    width: int,
    first_row: int,
    last_row: int,
    row_left: list[int],
    row_right: list[int],
    shift: int,
) -> None:
    compositor = half_span if shift == 1 else quarter_span
    for row in range(first_row, last_row + 1):
        left = row_left[row]
        right = row_right[row]
        if left <= right:
            start = row * width + left
            destination[start : start + right - left + 1] = compositor(
                frame, row, left, right
            )


def main() -> None:
    frame = bytes((index * 73 + 19) & 0xFF for index in range(STRIDE * 24))
    checked_spans = 0

    for width, height in ((32, 24), (64, 48)):
        for shift, compositor in ((1, half_span), (2, quarter_span)):
            for row in range(height):
                for left in range(width):
                    for right in range(left, width):
                        expected = reference_span(frame, row, left, right, shift)
                        actual = compositor(frame, row, left, right)
                        if actual != expected:
                            raise AssertionError(
                                (width, height, shift, row, left, right, expected, actual)
                            )
                        checked_spans += 1

    rng = random.Random(0x3D10D)
    randomized_layers = 20_000
    for _ in range(randomized_layers):
        width, height = rng.choice(((32, 24), (64, 48)))
        shift = rng.choice((1, 2))
        first_row = rng.randrange(height)
        last_row = rng.randrange(first_row, height)
        row_left = [255] * height
        row_right = [0] * height
        for row in range(first_row, last_row + 1):
            if rng.randrange(5) != 0:
                row_left[row] = rng.randrange(width)
                row_right[row] = rng.randrange(row_left[row], width)
        random_frame = bytes(rng.randrange(256) for _ in range(STRIDE * 24))
        initial = bytearray(rng.randrange(256) for _ in range(width * height))
        expected = initial.copy()
        actual = initial.copy()
        apply_reference(
            expected,
            random_frame,
            width,
            first_row,
            last_row,
            row_left,
            row_right,
            shift,
        )
        apply_specialized(
            actual,
            random_frame,
            width,
            first_row,
            last_row,
            row_left,
            row_right,
            shift,
        )
        if actual != expected:
            raise AssertionError((width, height, shift, first_row, last_row))

    print(f"PASS: {checked_spans:,} exhaustive clipped spans")
    print(f"PASS: {randomized_layers:,} randomized clipped layers")


if __name__ == "__main__":
    main()
