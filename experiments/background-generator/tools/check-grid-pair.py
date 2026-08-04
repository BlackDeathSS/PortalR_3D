#!/usr/bin/env python3
"""Exhaustively check the paired floor/ceiling grid rasterizers.

The reference below models GraphX ``gfx_Line_NoClip`` at the pixel level,
including its equal-X endpoint swap, ``abs(dy) >= dx`` vertical-major tie,
half-delta error initialization, and strict-underflow correction tests.  The
paired model separately translates ``.Lgrid_draw_pair_noclip`` from
``src/render_asm.s`` so an error in that routine is not hidden by sharing the
reference implementation.
"""

from __future__ import annotations

from pathlib import Path
import re


SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240
INT24_MASK = 0xFFFFFF

ASM_PATH = Path(__file__).resolve().parents[1] / "src" / "render_asm.s"


def read_equ(name: str) -> int:
    source = ASM_PATH.read_text(encoding="utf-8")
    match = re.search(
        rf"(?m)^\s*\.equ\s+{re.escape(name)}\s*,\s*(-?\d+)\s*$",
        source,
    )
    if match is None:
        raise AssertionError(f"missing numeric .equ {name} in {ASM_PATH}")
    return int(match.group(1))


FLOOR_NEAR_Y = read_equ("GRID_NEAR_SCREEN_Y")
FLOOR_FAR_Y = read_equ("GRID_FAR_SCREEN_Y")
CEILING_NEAR_Y = read_equ("GRID_CEILING_NEAR_SCREEN_Y")
CEILING_FAR_Y = read_equ("GRID_CEILING_FAR_SCREEN_Y")
HORIZONTAL_BYTES = read_equ("GRID_HORIZONTAL_BYTES")
HORIZONTAL_PUSHES = read_equ("GRID_HORIZONTAL_PUSHES")
HORIZONTAL_HEAD_BYTES = read_equ("GRID_HORIZONTAL_HEAD_BYTES")


def graphx_line_noclip(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
) -> list[tuple[int, int]]:
    """Model GraphX's assembly ``gfx_Line_NoClip`` exactly."""
    # GraphX retains the input order only for x0 < x1.  Equal-X lines take
    # the same swap path as right-to-left lines.
    if x0 < x1:
        x, y = x0, y0
        x_end, y_end = x1, y1
    else:
        x, y = x1, y1
        x_end, y_end = x0, y0

    dx = x_end - x
    signed_dy = y_end - y
    y_step = 1 if signed_dy >= 0 else -1
    dy = abs(signed_dy)
    pixels: list[tuple[int, int]] = []

    # GraphX selects vertical-major on the dx == dy tie.
    if dy >= dx:
        error = dy // 2
        for index in range(dy + 1):
            pixels.append((x, y))
            if index == dy:
                break
            y += y_step
            error -= dx
            if error < 0:
                x += 1
                error += dy
    else:
        error = dx // 2
        for index in range(dx + 1):
            pixels.append((x, y))
            if index == dx:
                break
            x += 1
            error -= dy
            if error < 0:
                y += y_step
                error += dx

    return pixels


def paired_grid_line_model(
    far_x: int,
    near_x: int,
) -> tuple[list[tuple[int, int]], list[tuple[int, int]]]:
    """Translate ``.Lgrid_draw_pair_noclip`` independently of GraphX."""
    # ``sbc far_x, near_x`` branches only when far_x < near_x.  The
    # fallthrough therefore also reproduces GraphX's equal-X swap.
    if far_x < near_x:
        x = far_x
        dx = near_x - far_x
        floor_y = FLOOR_FAR_Y
        ceiling_y = CEILING_FAR_Y
        floor_y_step = 1
        ceiling_y_step = -1
    else:
        x = near_x
        dx = far_x - near_x
        floor_y = FLOOR_NEAR_Y
        ceiling_y = CEILING_NEAR_Y
        floor_y_step = -1
        ceiling_y_step = 1

    floor_pixels: list[tuple[int, int]] = []
    ceiling_pixels: list[tuple[int, int]] = []

    # BC holds dx + 1 when the assembly performs ``cp a, 113``.  Thus
    # counts below 113 are exactly the GraphX vertical-major cases dx <= 111.
    if dx + 1 < 113:
        error = 55  # 111 // 2
        for index in range(112):
            floor_pixels.append((x, floor_y))
            ceiling_pixels.append((x, ceiling_y))
            if index == 111:
                break
            floor_y += floor_y_step
            ceiling_y += ceiling_y_step
            error -= dx
            if error < 0:
                x += 1
                error += 111
    else:
        # IY is a 24-bit register.  The carry from adding -111 decides
        # whether to advance Y.  The correction executes between EXX
        # instructions, so BC is the alternate-bank fixed dx rather than
        # the main-bank remaining-pixel count.
        error = dx // 2
        remaining = dx + 1
        while True:
            floor_pixels.append((x, floor_y))
            ceiling_pixels.append((x, ceiling_y))
            x += 1
            remaining -= 1
            if remaining == 0:
                break

            if error >= 111:
                error -= 111
                continue

            error = (error - 111) & INT24_MASK
            floor_y += floor_y_step
            ceiling_y += ceiling_y_step
            error = (error + dx) & INT24_MASK

    return floor_pixels, ceiling_pixels


def first_difference(
    expected: list[tuple[int, int]],
    actual: list[tuple[int, int]],
) -> tuple[int, tuple[int, int] | None, tuple[int, int] | None] | None:
    for index, (expected_pixel, actual_pixel) in enumerate(zip(expected, actual)):
        if expected_pixel != actual_pixel:
            return index, expected_pixel, actual_pixel
    if len(expected) != len(actual):
        index = min(len(expected), len(actual))
        expected_pixel = expected[index] if index < len(expected) else None
        actual_pixel = actual[index] if index < len(actual) else None
        return index, expected_pixel, actual_pixel
    return None


def check_slanted_pair(far_x: int, near_x: int) -> None:
    expected_floor = graphx_line_noclip(
        far_x, FLOOR_FAR_Y, near_x, FLOOR_NEAR_Y
    )
    # This is intentionally a second, independent GraphX invocation rather
    # than a mirror of the already-rasterized floor pixel list.
    expected_ceiling = graphx_line_noclip(
        far_x, CEILING_FAR_Y, near_x, CEILING_NEAR_Y
    )
    actual_floor, actual_ceiling = paired_grid_line_model(far_x, near_x)

    floor_difference = first_difference(expected_floor, actual_floor)
    if floor_difference is not None:
        index, expected, actual = floor_difference
        raise AssertionError(
            "paired floor mismatch: "
            f"far_x={far_x}, near_x={near_x}, pixel_index={index}, "
            f"GraphX={expected}, paired={actual}"
        )

    ceiling_difference = first_difference(expected_ceiling, actual_ceiling)
    if ceiling_difference is not None:
        index, expected, actual = ceiling_difference
        raise AssertionError(
            "paired ceiling mismatch: "
            f"far_x={far_x}, near_x={near_x}, pixel_index={index}, "
            f"GraphX={expected}, paired={actual}"
        )


def paired_horizontal_rows(
    floor_y: int,
) -> tuple[list[tuple[int, int]], list[tuple[int, int]]]:
    """Model the two interrupt-masked packed-PUSH row fills."""
    ceiling_y = SCREEN_HEIGHT - floor_y
    floor_offsets = set(range(HORIZONTAL_HEAD_BYTES))
    ceiling_offsets = set(range(HORIZONTAL_HEAD_BYTES))

    # Each ADL-mode PUSH writes three bytes below SP. The assembly starts SP
    # one byte beyond the row and walks backward through the packed region.
    floor_sp = HORIZONTAL_BYTES
    ceiling_sp = HORIZONTAL_BYTES
    for _ in range(HORIZONTAL_PUSHES):
        floor_sp -= 3
        ceiling_sp -= 3
        floor_offsets.update(range(floor_sp, floor_sp + 3))
        ceiling_offsets.update(range(ceiling_sp, ceiling_sp + 3))

    if floor_sp != HORIZONTAL_HEAD_BYTES:
        raise AssertionError(
            f"floor packed fill stopped at byte {floor_sp}, "
            f"expected {HORIZONTAL_HEAD_BYTES}"
        )
    if ceiling_sp != HORIZONTAL_HEAD_BYTES:
        raise AssertionError(
            f"ceiling packed fill stopped at byte {ceiling_sp}, "
            f"expected {HORIZONTAL_HEAD_BYTES}"
        )

    floor = [(x, floor_y) for x in sorted(floor_offsets)]
    ceiling = [(x, ceiling_y) for x in sorted(ceiling_offsets)]
    return floor, ceiling


def check_horizontal_pair(floor_y: int) -> None:
    expected_floor = [(x, floor_y) for x in range(SCREEN_WIDTH)]
    expected_ceiling_y = SCREEN_HEIGHT - floor_y
    expected_ceiling = [
        (x, expected_ceiling_y) for x in range(SCREEN_WIDTH)
    ]
    actual_floor, actual_ceiling = paired_horizontal_rows(floor_y)
    if actual_floor != expected_floor or actual_ceiling != expected_ceiling:
        raise AssertionError(
            "horizontal grid pair mismatch: "
            f"floor_y={floor_y}, ceiling_y={expected_ceiling_y}"
        )


def check_constants() -> None:
    expected = (127, 238, 113, 2)
    actual = (FLOOR_FAR_Y, FLOOR_NEAR_Y, CEILING_FAR_Y, CEILING_NEAR_Y)
    if actual != expected:
        raise AssertionError(
            f"paired grid endpoint constants changed: expected {expected}, got {actual}"
        )
    if FLOOR_FAR_Y + CEILING_FAR_Y != SCREEN_HEIGHT:
        raise AssertionError("far floor/ceiling endpoints are not Y mirrors")
    if FLOOR_NEAR_Y + CEILING_NEAR_Y != SCREEN_HEIGHT:
        raise AssertionError("near floor/ceiling endpoints are not Y mirrors")
    if HORIZONTAL_BYTES != SCREEN_WIDTH:
        raise AssertionError(
            f"horizontal byte count {HORIZONTAL_BYTES} != {SCREEN_WIDTH}"
        )
    if HORIZONTAL_PUSHES * 3 + HORIZONTAL_HEAD_BYTES != SCREEN_WIDTH:
        raise AssertionError(
            "packed horizontal fill does not cover exactly one screen row"
        )


def main() -> None:
    check_constants()

    slanted_cases = 0
    for far_x in range(SCREEN_WIDTH):
        for near_x in range(SCREEN_WIDTH):
            check_slanted_pair(far_x, near_x)
            slanted_cases += 1

    # Both screen-row lookups are valid precisely for y=1..239.
    horizontal_cases = 0
    for floor_y in range(1, SCREEN_HEIGHT):
        check_horizontal_pair(floor_y)
        horizontal_cases += 1

    print(
        "paired grid rasterizers exact: "
        f"{slanted_cases} exhaustive in-bounds endpoint pairs and "
        f"{horizontal_cases} valid horizontal row pairs"
    )


if __name__ == "__main__":
    main()
