#!/usr/bin/env python3
"""Host exactness and eZ80 work models for the run-length presenter."""

from __future__ import annotations

import hashlib
import itertools
import random


def fixed_row(source: bytes, scale: int) -> bytes:
    return bytes(value for pixel in source for value in (pixel,) * scale)


def run_row(source: bytes, scale: int) -> bytes:
    """Model the seed plus forward-overlapping LDIR implementation."""
    destination = bytearray()
    start = 0
    while start < len(source):
        color = source[start]
        end = start + 1
        while end < len(source) and source[end] == color:
            end += 1
        count = (end - start) * scale
        destination.append(color)
        # LDIR starts one byte behind DE.  Every newly written byte therefore
        # becomes the source for the next iteration.
        source_index = len(destination) - 1
        for _ in range(count - 1):
            destination.append(destination[source_index])
            source_index += 1
        start = end
    return bytes(destination)


def fixed_frame(source: bytes, width: int, height: int, scale: int) -> bytes:
    destination = bytearray()
    for row in range(height):
        expanded = fixed_row(source[row * width:(row + 1) * width], scale)
        destination.extend(expanded * scale)
    return bytes(destination)


def run_frame(source: bytes, width: int, height: int, scale: int) -> bytes:
    destination = bytearray()
    for row in range(height):
        expanded = run_row(source[row * width:(row + 1) * width], scale)
        # This is the existing one-LDIR forward-overlapping vertical copy.
        row_start = len(destination)
        destination.extend(expanded)
        source_index = row_start
        for _ in range(len(expanded) * (scale - 1)):
            destination.append(destination[source_index])
            source_index += 1
    return bytes(destination)


def runs(source: bytes) -> list[int]:
    lengths: list[int] = []
    start = 0
    while start < len(source):
        end = start + 1
        while end < len(source) and source[end] == source[start]:
            end += 1
        lengths.append(end - start)
        start = end
    return lengths


def baseline_horizontal_cycles(width: int, scale: int) -> int:
    # Per logical pixel: LD A,(IY)=4, INC IY=2, S*(LD (DE),A=2 +
    # INC DE=1), DJNZ=4 taken/2 final.
    return width * (6 + 3 * scale + 4) - 2


def run_horizontal_cycles(source: bytes, scale: int) -> int:
    """Cycle model for the assembled candidate, excluding common row setup."""
    remaining = len(source)
    total = 0
    offset = 0
    for length in runs(source):
        # LD A,(IY), INC IY, LD C,1, DEC B.
        total += 4 + 2 + 2 + 1
        remaining -= 1
        # JR Z is taken only when the run starts on the final pixel.
        total += 3 if remaining == 0 else 2
        for _ in range(length - 1):
            # CP (IY), untaken JR NZ, INC IY, INC C, DJNZ.
            total += 4 + 2 + 2 + 1
            remaining -= 1
            total += 2 if remaining == 0 else 4
        offset += length
        if remaining:
            # One mismatching comparison terminates every non-final run.
            total += 4 + 3
        # PUSH BC, LD B,n, MLT, DEC BC, seed store/increment,
        # PUSH DE/POP HL, DEC HL, LDIR, POP BC, LD/OR/JR.
        count = length * scale - 1
        total += 4 + 2 + 6 + 1 + 2 + 1 + 4 + 4 + 1
        total += 2 + 3 * count
        total += 4 + 1 + 1 + (3 if remaining else 2)
    assert offset == len(source)
    return total


def patterned_row(width: int, run_count: int) -> bytes:
    values = bytearray()
    for index in range(width):
        values.append((index * run_count // width) & 1)
    # The formula above can collapse adjacent intended runs for odd divisions;
    # construct exact alternating balanced runs instead.
    values.clear()
    base, extra = divmod(width, run_count)
    for run in range(run_count):
        values.extend(bytes((run & 1,)) * (base + (run < extra)))
    return bytes(values)


def main() -> None:
    row_cases = 0
    # Exhaust every binary transition pattern through sixteen pixels.  This
    # covers all 2^15 possible run-boundary masks, both starting colors, and
    # every possible mixture of singleton and long runs in that width.
    for bits in range(1 << 16):
        row = bytes((bits >> index) & 1 for index in range(16))
        for scale in (5, 10):
            expected = fixed_row(row, scale)
            actual = run_row(row, scale)
            if actual != expected:
                raise AssertionError((row, scale))
            row_cases += 1

    # Exercise every possible eight-bit color as a maximal run at both real
    # logical widths.
    for width, scale in ((64, 5), (32, 10)):
        for color in range(256):
            row = bytes((color,)) * width
            if run_row(row, scale) != fixed_row(row, scale):
                raise AssertionError((width, scale, color))
            row_cases += 1

    rng = random.Random(0x5EED1E)
    digest_fixed = hashlib.sha256()
    digest_runs = hashlib.sha256()
    random_rows = 100_000
    for case in range(random_rows):
        width, scale = ((64, 5), (32, 10))[case & 1]
        if case % 4 == 0:
            # Long palette runs resembling flat background and wall spans.
            row = bytes(rng.randrange(16) for _ in range(rng.randrange(1, 9)))
            row = bytes(row[min(len(row) - 1, index * len(row) // width)]
                        for index in range(width))
        elif case % 4 == 1:
            row = bytes((index & 1) * 255 for index in range(width))
        else:
            row = rng.randbytes(width)
        expected = fixed_row(row, scale)
        actual = run_row(row, scale)
        if actual != expected:
            raise AssertionError((case, width, scale))
        digest_fixed.update(expected)
        digest_runs.update(actual)
        row_cases += 1

    frame_cases = 0
    for width, height, scale in ((64, 48, 5), (32, 24, 10)):
        adversarial = (
            bytes(width * height),
            bytes((index & 1) * 255 for index in range(width * height)),
            bytes(index & 255 for index in range(width * height)),
            rng.randbytes(width * height),
        )
        for source in adversarial:
            expected = fixed_frame(source, width, height, scale)
            actual = run_frame(source, width, height, scale)
            if actual != expected or len(actual) != 320 * 240:
                raise AssertionError((width, height, scale))
            digest_fixed.update(expected)
            digest_runs.update(actual)
            frame_cases += 1

    if digest_fixed.digest() != digest_runs.digest():
        raise AssertionError("framebuffer hashes differ")

    print(f"row cases passed: {row_cases:,}")
    print(f"full-frame adversarial cases passed: {frame_cases:,}")
    print(f"framebuffer SHA-256: {digest_fixed.hexdigest()}")
    print()
    print("horizontal eZ80 cycle model (baseline -> RLE):")
    for width, scale in ((64, 5), (32, 10)):
        baseline = baseline_horizontal_cycles(width, scale)
        counts = (1, 4, 8, 16, 32, width)
        shown = []
        for count in dict.fromkeys(counts):
            if count > width:
                continue
            row = patterned_row(width, count)
            actual_count = len(runs(row))
            candidate = run_horizontal_cycles(row, scale)
            shown.append(f"R={actual_count}: {baseline}->{candidate} ({(candidate / baseline - 1) * 100:+.1f}%)")
        print(f"  {width}x scale {scale}: " + "; ".join(shown))


if __name__ == "__main__":
    main()
