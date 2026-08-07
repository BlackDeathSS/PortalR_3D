#!/usr/bin/env python3
"""Exhaustively prove the division-free 80-ray stepper initialization."""

from __future__ import annotations

from dataclasses import dataclass


LOGICAL_COLUMNS = 80
DIRECTION_MIN = -256
DIRECTION_MAX = 256
PLANE_MIN = -169
PLANE_MAX = 169


@dataclass
class Stepper:
    value: int
    step: int
    error: int
    error_step: int


def trunc_div(numerator: int, denominator: int) -> int:
    """Model C signed integer division without using floating point."""

    magnitude = abs(numerator) // denominator
    return -magnitude if numerator < 0 else magnitude


def old_init(direction: int, plane: int) -> Stepper:
    numerator = (direction - plane) * LOGICAL_COLUMNS + plane
    delta = plane * 2
    value = trunc_div(numerator, LOGICAL_COLUMNS)
    error = numerator - value * LOGICAL_COLUMNS
    step = trunc_div(delta, LOGICAL_COLUMNS)
    error_step = delta - step * LOGICAL_COLUMNS

    if error < 0:
        value -= 1
        error += LOGICAL_COLUMNS
    if error_step < 0:
        step -= 1
        error_step += LOGICAL_COLUMNS
    return Stepper(value, step, error, error_step)


def new_init(direction: int, plane: int) -> Stepper:
    if plane >= 0:
        if plane >= 160:
            quotient = 2
            remainder = plane - 160
        elif plane >= 80:
            quotient = 1
            remainder = plane - 80
        else:
            quotient = 0
            remainder = plane
    elif plane < -160:
        quotient = -3
        remainder = plane + 240
    elif plane < -80:
        quotient = -2
        remainder = plane + 160
    else:
        quotient = -1
        remainder = plane + 80

    value = direction - plane + quotient
    error = remainder
    step = quotient + quotient
    if remainder >= 40:
        step += 1
        remainder -= 40
    error_step = remainder + remainder
    return Stepper(value, step, error, error_step)


def generated_rays(initial: Stepper) -> tuple[int, ...]:
    stepper = Stepper(
        initial.value,
        initial.step,
        initial.error,
        initial.error_step,
    )
    rays: list[int] = []

    for _ in range(LOGICAL_COLUMNS):
        rays.append(stepper.value)
        stepper.value += stepper.step
        stepper.error += stepper.error_step
        if stepper.error >= LOGICAL_COLUMNS:
            stepper.value += 1
            stepper.error -= LOGICAL_COLUMNS
    return tuple(rays)


def main() -> None:
    cases = 0
    rays = 0

    for direction in range(DIRECTION_MIN, DIRECTION_MAX + 1):
        for plane in range(PLANE_MIN, PLANE_MAX + 1):
            expected = old_init(direction, plane)
            actual = new_init(direction, plane)

            if actual != expected:
                raise AssertionError(
                    f"init mismatch direction={direction}, plane={plane}: "
                    f"old={expected}, new={actual}"
                )
            if not 0 <= actual.error < LOGICAL_COLUMNS:
                raise AssertionError(f"noncanonical error: {actual}")
            if not 0 <= actual.error_step < LOGICAL_COLUMNS:
                raise AssertionError(f"noncanonical error step: {actual}")

            expected_rays = generated_rays(expected)
            actual_rays = generated_rays(actual)
            if actual_rays != expected_rays:
                mismatch = next(
                    index
                    for index, (old, new) in enumerate(
                        zip(expected_rays, actual_rays)
                    )
                    if old != new
                )
                raise AssertionError(
                    f"ray mismatch direction={direction}, plane={plane}, "
                    f"column={mismatch}: old={expected_rays[mismatch]}, "
                    f"new={actual_rays[mismatch]}"
                )

            cases += 1
            rays += LOGICAL_COLUMNS

    print(
        "ray stepper: "
        f"{cases} direction/plane pairs and {rays} generated rays matched"
    )


if __name__ == "__main__":
    main()
