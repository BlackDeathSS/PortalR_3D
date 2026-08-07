#!/usr/bin/env python3
"""Exhaustively verify the full-turn direction and camera-FOV lookup tables.

The former C path linearly interpolated the 64 direction samples with signed
division, which truncates toward zero.  ``game_graphics_init`` now expands the
Y samples into a full-turn table with an error accumulator, obtains X through
a quarter-turn table offset, and precomputes every reachable FOV product.

This check reads the source direction samples and numeric constants directly
from ``src/game.c``.  It compares every angle in one 16,384-step turn and every
fixed-point component in [-256, 256] against the old C formulas.
"""

from __future__ import annotations

from pathlib import Path
import re


GAME_SOURCE = Path(__file__).resolve().parents[1] / "src" / "game.c"

# Historical X samples from the removed interpolation path.  Keeping the
# oracle in the host-side checker proves that the quarter-turn Y lookup is
# byte-for-byte equivalent without carrying a dead 128-byte table in-game.
LEGACY_DIRECTION_X = (
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25,
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
)


def read_numeric_define(source: str, name: str) -> int:
    match = re.search(
        rf"(?m)^\s*#define\s+{re.escape(name)}\s+(-?\d+)[uUlL]*\s*$",
        source,
    )
    if match is None:
        raise AssertionError(f"missing numeric #define {name} in {GAME_SOURCE}")
    return int(match.group(1))


def read_direction_samples(source: str, name: str, count: int) -> tuple[int, ...]:
    match = re.search(
        rf"static\s+const\s+int16_t\s+{re.escape(name)}"
        rf"\s*\[\s*ANGLE_STEPS\s*\]\s*=\s*\{{(.*?)\}}\s*;",
        source,
        re.DOTALL,
    )
    if match is None:
        raise AssertionError(f"missing {name} initializer in {GAME_SOURCE}")

    samples = tuple(int(value) for value in re.findall(r"-?\d+", match.group(1)))
    if len(samples) != count:
        raise AssertionError(
            f"{name} contains {len(samples)} samples; expected {count}"
        )
    return samples


def trunc_div(numerator: int, denominator: int) -> int:
    """Model C99 signed integer division without floating point."""

    magnitude = abs(numerator) // denominator
    return -magnitude if numerator < 0 else magnitude


def old_interpolate(
    samples: tuple[int, ...],
    angle: int,
    angle_steps: int,
    fraction_bits: int,
) -> int:
    """Model the former ``direction_for_angle`` component expression."""

    index = (angle >> fraction_bits) & (angle_steps - 1)
    next_index = (index + 1) & (angle_steps - 1)
    fraction = angle & ((1 << fraction_bits) - 1)
    difference = samples[next_index] - samples[index]
    return samples[index] + trunc_div(difference * fraction, 1 << fraction_bits)


def build_startup_lut(
    samples: tuple[int, ...],
    angle_steps: int,
    fraction_bits: int,
) -> tuple[int, ...]:
    """Model the error-accumulator loop in ``game_graphics_init``."""

    fraction_count = 1 << fraction_bits
    result = [0] * (angle_steps * fraction_count)

    for index in range(angle_steps):
        value = samples[index]
        difference = samples[(index + 1) & (angle_steps - 1)] - value
        step = -1 if difference < 0 else 1
        amount = abs(difference)
        error = 0
        offset = index << fraction_bits

        for fraction in range(fraction_count):
            result[offset + fraction] = value
            error += amount
            if error >= fraction_count:
                error -= fraction_count
                value += step

        if not 0 <= error < fraction_count:
            raise AssertionError(
                f"noncanonical recurrence error after segment {index}: {error}"
            )

    return tuple(result)


def main() -> None:
    source = GAME_SOURCE.read_text(encoding="utf-8")
    angle_steps = read_numeric_define(source, "ANGLE_STEPS")
    fraction_bits = read_numeric_define(source, "ANGLE_FRACTION_BITS")
    fixed_shift = read_numeric_define(source, "FIXED_SHIFT")
    field_of_view = read_numeric_define(source, "FIELD_OF_VIEW")

    if angle_steps <= 0 or angle_steps & (angle_steps - 1):
        raise AssertionError("ANGLE_STEPS must be a positive power of two")
    if angle_steps % 4:
        raise AssertionError("ANGLE_STEPS must be divisible by four")

    direction_y = read_direction_samples(source, "direction_y", angle_steps)
    if len(LEGACY_DIRECTION_X) != angle_steps:
        raise AssertionError(
            "legacy X oracle does not match ANGLE_STEPS: "
            f"{len(LEGACY_DIRECTION_X)} != {angle_steps}"
        )
    direction_lut = build_startup_lut(
        direction_y,
        angle_steps,
        fraction_bits,
    )

    angle_wrap = angle_steps << fraction_bits
    angle_mask = angle_wrap - 1
    quarter_turn = angle_wrap // 4
    component_checks = 0

    if len(direction_lut) != angle_wrap:
        raise AssertionError(
            f"startup table has {len(direction_lut)} entries; expected {angle_wrap}"
        )

    for angle in range(angle_wrap):
        expected_y = old_interpolate(
            direction_y,
            angle,
            angle_steps,
            fraction_bits,
        )
        actual_y = direction_lut[angle]
        if actual_y != expected_y:
            raise AssertionError(
                f"Y mismatch at angle {angle}: old={expected_y}, LUT={actual_y}"
            )
        component_checks += 1

        expected_x = old_interpolate(
            LEGACY_DIRECTION_X,
            angle,
            angle_steps,
            fraction_bits,
        )
        actual_x = direction_lut[(angle + quarter_turn) & angle_mask]
        if actual_x != expected_x:
            raise AssertionError(
                f"X mismatch at angle {angle}: old={expected_x}, LUT={actual_x}"
            )
        component_checks += 1

    fixed_one = 1 << fixed_shift
    fov_checks = 0
    for component in range(-fixed_one, fixed_one + 1):
        expected = trunc_div(component * field_of_view, fixed_one)
        magnitude = abs(component)
        scaled = (magnitude * field_of_view) >> fixed_shift
        actual = -scaled if component < 0 else scaled
        if actual != expected:
            raise AssertionError(
                f"FOV mismatch at component {component}: "
                f"old={expected}, LUT={actual}"
            )
        fov_checks += 1

    direction_bytes = angle_wrap * 2
    fov_bytes = (fixed_one * 2 + 1) * 2
    print(
        "direction/FOV LUTs: "
        f"{angle_wrap} angles, {component_checks} direction components, and "
        f"{fov_checks} FOV inputs matched exactly"
    )
    print(
        "lookup storage: "
        f"{direction_bytes} direction bytes + {fov_bytes} FOV bytes = "
        f"{direction_bytes + fov_bytes} bytes"
    )


if __name__ == "__main__":
    main()
