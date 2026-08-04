#!/usr/bin/env python3
"""Model exact lookup-driven rasterizers for the paired background grid.

The renderer's in-bounds slanted grid lines always span 111 rows.  This
script proves two useful table encodings against GraphX's Bresenham pixel
sequence:

* a generic one-bit minor-step mask for every ``dx`` in 0..319;
* a denser horizontal-major run mask.  For ``dx`` in 112..319, the 112
  Y-runs contain either ``q`` or ``q + 1`` pixels, where
  ``q = (dx + 1) // 112``.  One bit per run therefore reproduces the whole
  line in only 14 bytes per ``dx``.

The script does not alter or generate renderer source.  Its size and
instruction-count model are intended to evaluate a future assembly A/B.
"""

from __future__ import annotations

from dataclasses import dataclass


DY = 111
MAX_DX = 319
HORIZONTAL_FIRST_DX = DY + 1
HORIZONTAL_DX_COUNT = MAX_DX - HORIZONTAL_FIRST_DX + 1
RUNS_PER_LINE = DY + 1
RUN_MASK_BYTES = RUNS_PER_LINE // 8


def graphx_offsets(dx: int) -> list[tuple[int, int]]:
    """Return GraphX ``gfx_Line_NoClip`` offsets for ``(0, 0)..(dx, 111)``."""
    if not 0 <= dx <= MAX_DX:
        raise ValueError(dx)

    x = 0
    y = 0
    pixels: list[tuple[int, int]] = []
    if DY >= dx:
        error = DY // 2
        for index in range(DY + 1):
            pixels.append((x, y))
            if index == DY:
                break
            y += 1
            error -= dx
            if error < 0:
                x += 1
                error += DY
    else:
        error = dx // 2
        for index in range(dx + 1):
            pixels.append((x, y))
            if index == dx:
                break
            x += 1
            error -= DY
            if error < 0:
                y += 1
                error += dx
    return pixels


def generic_step_record(dx: int) -> bytes:
    """Pack one post-pixel minor-axis decision bit per major-axis pixel."""
    pixels = graphx_offsets(dx)
    record = bytearray((len(pixels) + 7) // 8)
    for index, (current, following) in enumerate(zip(pixels, pixels[1:])):
        if DY >= dx:
            stepped = following[0] != current[0]
        else:
            stepped = following[1] != current[1]
        if stepped:
            record[index >> 3] |= 1 << (index & 7)
    return bytes(record)


def generic_step_offsets(dx: int, record: bytes) -> list[tuple[int, int]]:
    """Reconstruct pixels using the generic packed step record."""
    vertical_major = DY >= dx
    pixel_count = max(DY, dx) + 1
    x = 0
    y = 0
    pixels: list[tuple[int, int]] = []
    for index in range(pixel_count):
        pixels.append((x, y))
        if index + 1 == pixel_count:
            break
        stepped = bool(record[index >> 3] & (1 << (index & 7)))
        if vertical_major:
            y += 1
            x += int(stepped)
        else:
            x += 1
            y += int(stepped)
    return pixels


def horizontal_runs(dx: int) -> list[int]:
    """Return the number of consecutive pixels in each of the 112 Y rows."""
    if dx < HORIZONTAL_FIRST_DX:
        raise ValueError(dx)
    runs = [0] * RUNS_PER_LINE
    for _, y in graphx_offsets(dx):
        runs[y] += 1
    return runs


def horizontal_run_record(dx: int) -> bytes:
    """Pack whether each Y run has one pixel beyond its common base."""
    runs = horizontal_runs(dx)
    base = (dx + 1) // RUNS_PER_LINE
    record = bytearray(RUN_MASK_BYTES)
    for row, length in enumerate(runs):
        if length not in (base, base + 1):
            raise AssertionError(
                f"dx={dx}, row={row}: run {length} is not {base} or {base + 1}"
            )
        if length == base + 1:
            record[row >> 3] |= 1 << (row & 7)
    expected_extra = (dx + 1) % RUNS_PER_LINE
    actual_extra = sum(byte.bit_count() for byte in record)
    if actual_extra != expected_extra:
        raise AssertionError(
            f"dx={dx}: {actual_extra} extra runs != {expected_extra}"
        )
    return bytes(record)


def horizontal_run_offsets(dx: int, record: bytes) -> list[tuple[int, int]]:
    """Reconstruct pixels by emitting a base run plus one optional pixel."""
    base = (dx + 1) // RUNS_PER_LINE
    x = 0
    pixels: list[tuple[int, int]] = []
    for y in range(RUNS_PER_LINE):
        length = base + int(bool(record[y >> 3] & (1 << (y & 7))))
        for _ in range(length):
            pixels.append((x, y))
            x += 1
    return pixels


@dataclass(frozen=True)
class InstructionEstimate:
    current: int
    generic_mask: int
    run_mask: int | None


def instruction_estimate(dx: int) -> InstructionEstimate:
    """Count hot-loop instructions from concrete candidate loop shapes.

    This is deliberately an instruction count, not a claimed eZ80 cycle
    count.  It excludes common setup and table lookup.  The current counts
    directly follow ``.Lgrid_pair_vertical`` and the two horizontal loops.
    Candidate counts assume eight decisions are unrolled per loaded mask byte.
    """
    if dx <= DY:
        # Current vertical loop: six instructions for every pixel, seven for
        # each ordinary transition, and five more for each X correction.
        current = 6 * RUNS_PER_LINE + 7 * DY + 5 * dx
        # Candidate: paired stores, two row-pointer adds, rotate/test, and
        # four extra instructions for each X correction.  Four instructions
        # per 8-pixel group cover mask load/advance and group control.
        generic = 10 * RUNS_PER_LINE + 4 * dx + 4 * RUN_MASK_BYTES
        return InstructionEstimate(current, generic, None)

    # Current horizontal loop: ten instructions for the final pixel, thirteen
    # for an ordinary transition, and seven additional instructions for each
    # of the exactly 111 row corrections.
    current = 10 + 13 * (dx - DY) + 20 * DY

    pixels = dx + 1
    generic_groups = (pixels + 7) // 8
    generic = 8 * pixels + 4 * DY + 4 * generic_groups

    # Run-mask candidate: six instructions per emitted floor/ceiling pixel,
    # six per row for bit test plus the two paired row-pointer updates, and
    # four per eight-row descriptor group.
    run_mask = (
        6 * pixels
        + 6 * RUNS_PER_LINE
        + 4 * RUN_MASK_BYTES
    )
    return InstructionEstimate(current, generic, run_mask)


def main() -> None:
    generic_table_bytes = 0
    run_table_bytes = 0
    for dx in range(MAX_DX + 1):
        expected = graphx_offsets(dx)
        generic_record = generic_step_record(dx)
        generic_table_bytes += len(generic_record)
        actual = generic_step_offsets(dx, generic_record)
        if actual != expected:
            raise AssertionError(f"generic step-mask mismatch at dx={dx}")

        if dx >= HORIZONTAL_FIRST_DX:
            run_record = horizontal_run_record(dx)
            run_table_bytes += len(run_record)
            run_actual = horizontal_run_offsets(dx, run_record)
            if run_actual != expected:
                raise AssertionError(f"horizontal run-mask mismatch at dx={dx}")

    if run_table_bytes != HORIZONTAL_DX_COUNT * RUN_MASK_BYTES:
        raise AssertionError("unexpected horizontal run-table size")

    current_total = 0
    generic_total = 0
    hybrid_total = 0
    for dx in range(MAX_DX + 1):
        estimate = instruction_estimate(dx)
        current_total += estimate.current
        generic_total += estimate.generic_mask
        hybrid_total += (
            estimate.run_mask
            if estimate.run_mask is not None
            else estimate.generic_mask
        )

    def reduction(before: int, after: int) -> float:
        return 100.0 * (before - after) / before

    print(
        "grid step-mask models exact: "
        f"{MAX_DX + 1} exhaustive dx values, dy={DY}"
    )
    print(
        "table sizes: "
        f"generic={generic_table_bytes} bytes, "
        f"horizontal run-mask={run_table_bytes} bytes, "
        f"hybrid with vertical generic="
        f"{run_table_bytes + RUN_MASK_BYTES * (DY + 1)} bytes"
    )
    print(
        "unweighted hot-loop instruction model over dx=0..319: "
        f"generic -{reduction(current_total, generic_total):.1f}%, "
        f"hybrid -{reduction(current_total, hybrid_total):.1f}%"
    )
    for dx in (0, 32, 64, 96, 111, 112, 160, 223, 256, 319):
        estimate = instruction_estimate(dx)
        candidate = (
            estimate.run_mask
            if estimate.run_mask is not None
            else estimate.generic_mask
        )
        print(
            f"dx={dx:3d}: current={estimate.current:4d}, "
            f"generic={estimate.generic_mask:4d}, "
            f"hybrid={candidate:4d}, "
            f"hybrid reduction={reduction(estimate.current, candidate):5.1f}%"
        )


if __name__ == "__main__":
    main()
