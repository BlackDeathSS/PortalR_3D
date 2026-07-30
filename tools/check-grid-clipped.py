#!/usr/bin/env python3
"""Exhaustively verify the specialized clipped floor/ceiling grid path.

GraphX clips endpoint 1 before endpoint 0 and rounds signed division toward
negative infinity.  The assembly path derives both Y coordinates from one
positive quotient/remainder per clipped endpoint, then feeds each clipped line
to a local translation of ``gfx_Line_NoClip``.

The full check covers every projected X endpoint pair in [-4096, 4096].
NumPy is used only to enumerate and compare the 35,979,904 retained clipped
pairs efficiently.  Pixel-level comparison is then performed for every unique
post-clip floor/ceiling state reached by that exhaustive enumeration.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import re
from typing import Iterator

import numpy as np


SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240
ENDPOINT_MIN = -4096
ENDPOINT_MAX = 4096
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


def x_outcode(x: int) -> int:
    if x < 0:
        return 1
    if x >= SCREEN_WIDTH:
        return 2
    return 0


def graphx_clip_line(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
) -> tuple[int, int, int, int] | None:
    """Model the X-only portion of GraphX ``gfx_Line`` exactly."""
    out0 = x_outcode(x0)
    out1 = x_outcode(x1)
    if out0 & out1:
        return None

    # Cohen-Sutherland in GraphX selects endpoint 1 whenever it is outside.
    if out1:
        bound = SCREEN_WIDTH - 1 if out1 == 2 else 0
        y1 = y0 + ((y1 - y0) * (bound - x0)) // (x1 - x0)
        x1 = bound

    if out0:
        bound = SCREEN_WIDTH - 1 if out0 == 2 else 0
        # This intentionally uses the already-clipped and rounded endpoint 1.
        y0 = y0 + ((y1 - y0) * (bound - x0)) // (x1 - x0)
        x0 = bound

    return x0, y0, x1, y1


def pair_clip_endpoint(
    x0: int,
    floor_y0: int,
    ceiling_y0: int,
    x1: int,
    floor_y1: int,
    ceiling_y1: int,
    bound: int,
) -> tuple[int, int]:
    """Translate ``.Lgrid_clip_pair_endpoint`` independently."""
    numerator_x = abs(bound - x0)
    denominator_x = abs(x1 - x0)
    floor_delta = floor_y1 - floor_y0
    ceiling_delta = ceiling_y0 - ceiling_y1

    if not 0 <= numerator_x <= denominator_x:
        raise AssertionError("clip parameter escaped [0, 1]")
    if ceiling_delta - floor_delta not in (0, 1):
        raise AssertionError(
            "paired delta invariant failed: "
            f"floor={floor_delta}, ceiling={ceiling_delta}"
        )

    # Independently translate the assembly's two-MLT product construction.
    product = (
        floor_delta * (numerator_x & 0xFF)
        + (floor_delta * ((numerator_x >> 8) & 0xFF) << 8)
    )
    expected_product = floor_delta * numerator_x
    if product != expected_product:
        raise AssertionError(
            f"two-MLT product mismatch: {product} != {expected_product}"
        )

    # Translate the seven descending trial subtractions in .Lgrid_div_u7.
    quotient = 0
    remainder = product
    for bit in range(6, -1, -1):
        trial = denominator_x << bit
        if remainder >= trial:
            remainder -= trial
            quotient |= 1 << bit
    expected_quotient, expected_remainder = divmod(product, denominator_x)
    if (quotient, remainder) != (expected_quotient, expected_remainder):
        raise AssertionError(
            "seven-bit divider mismatch: "
            f"assembly={(quotient, remainder)}, "
            f"expected={(expected_quotient, expected_remainder)}"
        )
    if quotient >= 128:
        raise AssertionError("seven-bit divider quotient overflow")

    floor_result = floor_y0 + quotient

    ceiling_magnitude = quotient
    if ceiling_delta != floor_delta:
        remainder += numerator_x
        if remainder >= denominator_x:
            remainder -= denominator_x
            ceiling_magnitude += 1
    if remainder:
        ceiling_magnitude += 1

    ceiling_result = ceiling_y0 - ceiling_magnitude
    return floor_result, ceiling_result


def paired_clip_lines(
    far_x: int,
    near_x: int,
) -> tuple[
    tuple[int, int, int, int],
    tuple[int, int, int, int],
] | None:
    """Model the assembly's endpoint-1-first paired clipper."""
    out0 = x_outcode(far_x)
    out1 = x_outcode(near_x)
    if out0 & out1:
        return None

    floor_y0 = FLOOR_FAR_Y
    floor_y1 = FLOOR_NEAR_Y
    ceiling_y0 = CEILING_FAR_Y
    ceiling_y1 = CEILING_NEAR_Y

    if out1:
        bound = SCREEN_WIDTH - 1 if out1 == 2 else 0
        floor_y1, ceiling_y1 = pair_clip_endpoint(
            far_x,
            floor_y0,
            ceiling_y0,
            near_x,
            floor_y1,
            ceiling_y1,
            bound,
        )
        near_x = bound

    if out0:
        bound = SCREEN_WIDTH - 1 if out0 == 2 else 0
        floor_y0, ceiling_y0 = pair_clip_endpoint(
            far_x,
            floor_y0,
            ceiling_y0,
            near_x,
            floor_y1,
            ceiling_y1,
            bound,
        )
        far_x = bound

    return (
        (far_x, floor_y0, near_x, floor_y1),
        (far_x, ceiling_y0, near_x, ceiling_y1),
    )


def graphx_line_noclip(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
) -> list[tuple[int, int]]:
    """Reference GraphX ``gfx_Line_NoClip`` at the pixel level."""
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


def dynamic_raster_model(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
) -> list[tuple[int, int]]:
    """Translate ``.Lgrid_draw_dynamic_noclip`` and its 24-bit errors."""
    if x0 < x1:
        x = x0
        y = y0
        x_end = x1
        y_end = y1
    else:
        x = x1
        y = y1
        x_end = x0
        y_end = y0

    dx = x_end - x
    signed_dy = y_end - y
    y_step = 1 if signed_dy >= 0 else -1
    dy = abs(signed_dy)
    pixels: list[tuple[int, int]] = []

    if dy >= dx:
        error = dy // 2
        remaining = dy + 1
        while remaining:
            pixels.append((x, y))
            remaining -= 1
            if not remaining:
                break
            y += y_step
            error -= dx
            if error < 0:
                x += 1
                error += dy
    else:
        error = dx // 2
        remaining = dx + 1
        negative_dy = (-dy) & INT24_MASK
        while remaining:
            pixels.append((x, y))
            x += 1
            remaining -= 1
            if not remaining:
                break
            if dy == 0:
                continue

            total = error + negative_dy
            carry = total > INT24_MASK
            error = total & INT24_MASK
            if carry:
                continue

            y += y_step
            error = (error + dx) & INT24_MASK

    return pixels


def run_raster_model(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
) -> list[tuple[int, int]]:
    """Translate the shallow horizontal-run raster path."""
    if x0 < x1:
        x = x0
        y = y0
        x_end = x1
        y_end = y1
    else:
        x = x1
        y = y1
        x_end = x0
        y_end = y0

    dx = x_end - x
    signed_dy = y_end - y
    y_step = 1 if signed_dy >= 0 else -1
    dy = abs(signed_dy)
    if dy == 0 or dx < 3 * dy:
        return dynamic_raster_model(x0, y0, x1, y1)

    quotient, remainder = divmod(dx, dy)
    run = quotient // 2 + 1
    phase = run * dy - dx // 2
    remaining = dx + 1
    pixels: list[tuple[int, int]] = []

    def emit(length: int) -> None:
        nonlocal x, remaining
        for _ in range(length):
            pixels.append((x, y))
            x += 1
        remaining -= length

    emit(run)
    y += y_step
    for _ in range(dy - 1):
        if phase <= remainder:
            run = quotient + 1
            phase += dy - remainder
        else:
            run = quotient
            phase -= remainder
        emit(run)
        y += y_step
    emit(remaining)
    return pixels


def _reference_clip_arrays(
    x0: np.ndarray,
    x1: np.ndarray,
    y0_value: int,
    y1_value: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Independent vector translation of GraphX's sequential clipping."""
    y0 = np.full(np.broadcast_shapes(x0.shape, x1.shape), y0_value, np.int64)
    y1 = np.full_like(y0, y1_value)
    x0 = np.broadcast_to(x0, y0.shape).copy()
    x1 = np.broadcast_to(x1, y0.shape).copy()

    outside1 = (x1 < 0) | (x1 >= SCREEN_WIDTH)
    bound1 = np.where(x1 < 0, 0, SCREEN_WIDTH - 1)
    denominator = x1 - x0
    safe_denominator = np.where(outside1 & (denominator != 0), denominator, 1)
    quotient = np.floor_divide(
        (y1 - y0) * (bound1 - x0),
        safe_denominator,
    )
    y1 = np.where(outside1, y0 + quotient, y1)
    x1 = np.where(outside1, bound1, x1)

    outside0 = (x0 < 0) | (x0 >= SCREEN_WIDTH)
    bound0 = np.where(x0 < 0, 0, SCREEN_WIDTH - 1)
    denominator = x1 - x0
    safe_denominator = np.where(outside0 & (denominator != 0), denominator, 1)
    quotient = np.floor_divide(
        (y1 - y0) * (bound0 - x0),
        safe_denominator,
    )
    y0 = np.where(outside0, y0 + quotient, y0)
    x0 = np.where(outside0, bound0, x0)
    return x0, y0, x1, y1


def _paired_clip_arrays(
    x0_input: np.ndarray,
    x1_input: np.ndarray,
) -> tuple[np.ndarray, ...]:
    """Vector translation of the one-quotient paired endpoint clipper."""
    shape = np.broadcast_shapes(x0_input.shape, x1_input.shape)
    x0 = np.broadcast_to(x0_input, shape).copy()
    x1 = np.broadcast_to(x1_input, shape).copy()
    floor0 = np.full(shape, FLOOR_FAR_Y, np.int64)
    floor1 = np.full(shape, FLOOR_NEAR_Y, np.int64)
    ceiling0 = np.full(shape, CEILING_FAR_Y, np.int64)
    ceiling1 = np.full(shape, CEILING_NEAR_Y, np.int64)

    def update(
        mask: np.ndarray,
        bound: np.ndarray,
        target_is_one: bool,
    ) -> None:
        nonlocal x0, x1, floor0, floor1, ceiling0, ceiling1
        n = np.abs(bound - x0)
        d = np.abs(x1 - x0)
        safe_d = np.where(mask & (d != 0), d, 1)
        floor_delta = floor1 - floor0
        ceiling_delta = ceiling0 - ceiling1
        product = floor_delta * n
        quotient = np.floor_divide(product, safe_d)
        remainder = product - quotient * safe_d
        floor_result = floor0 + quotient

        extra_delta = ceiling_delta - floor_delta
        adjusted = remainder + np.where(extra_delta != 0, n, 0)
        wrapped = adjusted >= safe_d
        ceiling_magnitude = (
            quotient
            + np.where((extra_delta != 0) & wrapped, 1, 0)
            + np.where(np.mod(adjusted, safe_d) != 0, 1, 0)
        )
        ceiling_result = ceiling0 - ceiling_magnitude

        if target_is_one:
            floor1 = np.where(mask, floor_result, floor1)
            ceiling1 = np.where(mask, ceiling_result, ceiling1)
            x1 = np.where(mask, bound, x1)
        else:
            floor0 = np.where(mask, floor_result, floor0)
            ceiling0 = np.where(mask, ceiling_result, ceiling0)
            x0 = np.where(mask, bound, x0)

    outside1 = (x1 < 0) | (x1 >= SCREEN_WIDTH)
    update(
        outside1,
        np.where(x1 < 0, 0, SCREEN_WIDTH - 1),
        target_is_one=True,
    )
    outside0 = (x0 < 0) | (x0 >= SCREEN_WIDTH)
    update(
        outside0,
        np.where(x0 < 0, 0, SCREEN_WIDTH - 1),
        target_is_one=False,
    )
    return x0, floor0, ceiling0, x1, floor1, ceiling1


def _pack_states(
    x0: np.ndarray,
    floor0: np.ndarray,
    ceiling0: np.ndarray,
    x1: np.ndarray,
    floor1: np.ndarray,
    ceiling1: np.ndarray,
) -> np.ndarray:
    values = [x0, x1, floor0, floor1, ceiling0, ceiling1]
    shifts = [0, 9, 18, 26, 34, 42]
    packed = np.zeros(x0.shape, dtype=np.uint64)
    for value, shift in zip(values, shifts):
        packed |= value.astype(np.uint64) << np.uint64(shift)
    return packed


def _unpack_state(
    packed: int,
) -> tuple[int, int, int, int, int, int]:
    x0 = packed & 0x1FF
    x1 = (packed >> 9) & 0x1FF
    floor0 = (packed >> 18) & 0xFF
    floor1 = (packed >> 26) & 0xFF
    ceiling0 = (packed >> 34) & 0xFF
    ceiling1 = (packed >> 42) & 0xFF
    return x0, floor0, ceiling0, x1, floor1, ceiling1


def enumerate_and_check_endpoints(
    endpoint_min: int,
    endpoint_max: int,
    chunk_rows: int = 32,
) -> tuple[int, int, int, set[int]]:
    x1_values = np.arange(endpoint_min, endpoint_max + 1, dtype=np.int64)
    retained = 0
    one_clip = 0
    two_clip = 0
    unique_states: set[int] = set()

    for chunk_start in range(endpoint_min, endpoint_max + 1, chunk_rows):
        chunk_end = min(chunk_start + chunk_rows - 1, endpoint_max)
        x0_values = np.arange(chunk_start, chunk_end + 1, dtype=np.int64)
        x0 = x0_values[:, None]
        x1 = x1_values[None, :]

        same_left = (x0 < 0) & (x1 < 0)
        same_right = (x0 >= SCREEN_WIDTH) & (x1 >= SCREEN_WIDTH)
        visible = ~(same_left | same_right)
        fully_inside = (
            (x0 >= 0)
            & (x0 < SCREEN_WIDTH)
            & (x1 >= 0)
            & (x1 < SCREEN_WIDTH)
        )
        clipped = visible & ~fully_inside

        floor_reference = _reference_clip_arrays(
            x0, x1, FLOOR_FAR_Y, FLOOR_NEAR_Y
        )
        ceiling_reference = _reference_clip_arrays(
            x0, x1, CEILING_FAR_Y, CEILING_NEAR_Y
        )
        paired = _paired_clip_arrays(x0, x1)
        reference = (
            floor_reference[0],
            floor_reference[1],
            ceiling_reference[1],
            floor_reference[2],
            floor_reference[3],
            ceiling_reference[3],
        )

        for name, expected, actual in zip(
            ("x0", "floor0", "ceiling0", "x1", "floor1", "ceiling1"),
            reference,
            paired,
        ):
            mismatch = clipped & (expected != actual)
            if np.any(mismatch):
                row, column = np.argwhere(mismatch)[0]
                far_x = int(x0_values[row])
                near_x = int(x1_values[column])
                raise AssertionError(
                    f"paired clip {name} mismatch: far_x={far_x}, "
                    f"near_x={near_x}, GraphX={int(expected[row, column])}, "
                    f"paired={int(actual[row, column])}"
                )

        clip_count = (
            ((x1 < 0) | (x1 >= SCREEN_WIDTH)).astype(np.uint8)
            + ((x0 < 0) | (x0 >= SCREEN_WIDTH)).astype(np.uint8)
        )
        retained += int(np.count_nonzero(clipped))
        one_clip += int(np.count_nonzero(clipped & (clip_count == 1)))
        two_clip += int(np.count_nonzero(clipped & (clip_count == 2)))

        packed = _pack_states(*paired)
        unique_states.update(np.unique(packed[clipped]).tolist())

    return retained, one_clip, two_clip, unique_states


def check_unique_rasters(unique_states: set[int]) -> int:
    pixel_checks = 0
    for packed in unique_states:
        x0, floor0, ceiling0, x1, floor1, ceiling1 = _unpack_state(packed)
        for y0, y1, label in (
            (floor0, floor1, "floor"),
            (ceiling0, ceiling1, "ceiling"),
        ):
            expected = graphx_line_noclip(x0, y0, x1, y1)
            actual = run_raster_model(x0, y0, x1, y1)
            if expected != actual:
                difference = next(
                    (
                        index,
                        expected_pixel,
                        actual_pixel,
                    )
                    for index, (expected_pixel, actual_pixel) in enumerate(
                        zip(expected, actual)
                    )
                    if expected_pixel != actual_pixel
                )
                raise AssertionError(
                    f"dynamic clipped {label} raster mismatch: "
                    f"state={_unpack_state(packed)}, difference={difference}"
                )
            pixel_checks += len(expected)
    return pixel_checks


def check_assembly_contract() -> None:
    source = ASM_PATH.read_text(encoding="utf-8")
    required = (
        ".Lgrid_clip_pair_endpoint:",
        ".Lgrid_div_u7:",
        ".Lgrid_draw_dynamic_noclip:",
        ".Lgrid_dynamic_run_setup:",
        ".Lgrid_dynamic_run_middle:",
        ".Lgrid_dynamic_run_fill:",
        "ld (.Lgrid_dynamic_horizontal_color + 1), a",
        "ld (.Lgrid_dynamic_vertical_color + 1), a",
    )
    for fragment in required:
        if fragment not in source:
            raise AssertionError(f"missing clipped-grid assembly fragment: {fragment}")

    block = source.split(".Lfused_grid_draw_clipped:", 1)[1].split(
        ".Lfused_grid_return:", 1
    )[0]
    if "call _gfx_Line" in block:
        raise AssertionError("clipped path still calls GraphX gfx_Line")


def check_run_recurrence() -> int:
    """Exhaust every reachable horizontal-major dx/dy pair."""
    cases = 0
    for dx in range(1, SCREEN_WIDTH):
        for dy in range(min(dx, FLOOR_NEAR_Y - FLOOR_FAR_Y + 1)):
            expected = graphx_line_noclip(0, 0, dx, dy)
            actual = run_raster_model(0, 0, dx, dy)
            if actual != expected:
                raise AssertionError(
                    f"run recurrence mismatch: dx={dx}, dy={dy}"
                )
            cases += 1
    return cases


def check_arithmetic_kernels() -> tuple[int, int]:
    """Exhaust the standalone multiply and bounded-divider operand domains."""
    multiplicands = np.arange(0, 8193, dtype=np.int64)[None, :]
    deltas = np.arange(0, 112, dtype=np.int64)[:, None]
    assembled_product = (
        deltas * (multiplicands & 0xFF)
        + (deltas * ((multiplicands >> 8) & 0xFF) << 8)
    )
    expected_product = deltas * multiplicands
    if not np.array_equal(assembled_product, expected_product):
        row, column = np.argwhere(assembled_product != expected_product)[0]
        raise AssertionError(
            "two-MLT kernel mismatch: "
            f"delta={row}, multiplicand={column}"
        )
    multiply_cases = int(assembled_product.size)

    divider_cases = 0
    quotient_values = np.arange(0, 128, dtype=np.int64)[None, :, None]
    for d_start in range(1, 8193, 256):
        d_stop = min(d_start + 256, 8193)
        denominators = np.arange(d_start, d_stop, dtype=np.int64)[:, None, None]
        remainders = np.stack(
            (
                np.zeros(d_stop - d_start, dtype=np.int64),
                np.minimum(
                    np.ones(d_stop - d_start, dtype=np.int64),
                    np.arange(d_start, d_stop, dtype=np.int64) - 1,
                ),
                np.arange(d_start, d_stop, dtype=np.int64) - 1,
            ),
            axis=1,
        )[:, None, :]
        numerator = quotient_values * denominators + remainders
        actual_remainder = numerator.copy()
        actual_quotient = np.zeros_like(numerator)
        for bit in range(6, -1, -1):
            trial = denominators << bit
            accepted = actual_remainder >= trial
            actual_remainder = np.where(
                accepted,
                actual_remainder - trial,
                actual_remainder,
            )
            actual_quotient |= accepted.astype(np.int64) << bit

        if not np.array_equal(actual_quotient, quotient_values + np.zeros_like(numerator)):
            raise AssertionError(
                f"seven-bit quotient kernel mismatch in d={d_start}..{d_stop - 1}"
            )
        if not np.array_equal(actual_remainder, remainders + np.zeros_like(numerator)):
            raise AssertionError(
                f"seven-bit remainder kernel mismatch in d={d_start}..{d_stop - 1}"
            )
        divider_cases += int(numerator.size)

    return multiply_cases, divider_cases


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--quick",
        action="store_true",
        help="check a smaller endpoint interval for fast local iteration",
    )
    arguments = parser.parse_args()

    check_assembly_contract()
    run_cases = check_run_recurrence()
    multiply_cases, divider_cases = check_arithmetic_kernels()
    if arguments.quick:
        endpoint_min = -512
        endpoint_max = 831
    else:
        endpoint_min = ENDPOINT_MIN
        endpoint_max = ENDPOINT_MAX

    retained, one_clip, two_clip, unique_states = enumerate_and_check_endpoints(
        endpoint_min,
        endpoint_max,
    )
    pixel_checks = check_unique_rasters(unique_states)
    qualifier = "quick" if arguments.quick else "exhaustive"
    print(
        f"clipped grid exact ({qualifier}): {retained} retained endpoint pairs "
        f"({one_clip} one-edge, {two_clip} two-edge), "
        f"{len(unique_states)} unique post-clip states, "
        f"{pixel_checks} GraphX-equivalent pixel visits; "
        f"{run_cases} run-recurrence, {multiply_cases} multiply and "
        f"{divider_cases} divider kernel cases"
    )


if __name__ == "__main__":
    main()
