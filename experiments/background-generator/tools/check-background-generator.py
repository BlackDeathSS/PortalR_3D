#!/usr/bin/env python3
"""Property-check the one-transition assembly background-grid generator.

The reference is a direct model of the former C implementation.  The
candidate model follows the assembly decomposition and affine repair rules,
then emits the exact arguments passed to the already-verified raster kernels.
"""

from __future__ import annotations

from pathlib import Path
import random
import re


FIXED_ONE = 256
NEAR_DISTANCE = 260
FAR_DISTANCE = 4096
GRID_LINES = 16
ANGLE_STEPS = 64
ANGLE_FRACTION_BITS = 8
ANGLE_WRAP = ANGLE_STEPS << ANGLE_FRACTION_BITS
WALL_HEIGHT_MAX = 960
WALL_HEIGHT_NUMERATOR = 15360
ASM_PATH = Path(__file__).resolve().parents[1] / "src" / "render_asm.s"

DIRECTION_Y = (
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25,
)


def trunc_div(value: int, divisor: int) -> int:
    return value // divisor if value >= 0 else -((-value) // divisor)


def reference_scale(value: int, factor: int) -> int:
    whole, fraction = divmod(factor, FIXED_ONE)
    return value * whole + trunc_div(value * fraction, FIXED_ONE)


def assembly_scale(value: int, factor: int) -> int:
    """Model the four-MLT split in .Lbackground_scale_mul."""
    magnitude = abs(value)
    assert magnitude < 65536
    if factor >> 16:
        result = magnitude << 8
    else:
        result = ((magnitude & 0xFF) * factor) // FIXED_ONE
        result += (magnitude >> 8) * factor
    return -result if value < 0 else result


def inverse(component: int) -> int:
    magnitude = abs(component)
    if magnitude == 0:
        return 0
    if magnitude == 1:
        return 65536
    return 65536 // magnitude


def wall_height_reference(distance: int) -> int:
    index = distance >> 2
    if index == 0:
        return WALL_HEIGHT_MAX
    return min(WALL_HEIGHT_MAX, WALL_HEIGHT_NUMERATOR // index)


def build_profile_tables() -> tuple[list[int], list[int]]:
    height = WALL_HEIGHT_MAX
    previous = 0
    profiles: list[int] = []
    indices = [0] * 8192
    for index in range(2048):
        if index:
            while height > 1 and height * index > WALL_HEIGHT_NUMERATOR:
                height -= 1
        if height != previous:
            profiles.append(height)
            previous = height
        base = index << 2
        indices[base : base + 4] = [len(profiles) - 1] * 4
    return indices, profiles


PROFILE_INDICES, PROFILES = build_profile_tables()


def wall_height_assembly(distance: int) -> int:
    return PROFILES[PROFILE_INDICES[distance]]


def direction_table() -> list[int]:
    table = [0] * ANGLE_WRAP
    for index, start in enumerate(DIRECTION_Y):
        value = start
        difference = DIRECTION_Y[(index + 1) & 63] - value
        step = -1 if difference < 0 else 1
        amount = abs(difference)
        error = 0
        offset = index << ANGLE_FRACTION_BITS
        for fraction in range(FIXED_ONE):
            table[offset + fraction] = value
            error += amount
            if error >= FIXED_ONE:
                error -= FIXED_ONE
                value += step
    return table


ANGLE_TABLE = direction_table()
DIRECTIONS = tuple(
    (ANGLE_TABLE[(angle + ANGLE_WRAP // 4) & (ANGLE_WRAP - 1)], ANGLE_TABLE[angle])
    for angle in range(ANGLE_WRAP)
)


def horizontal(distance: int, assembly: bool) -> tuple[str, int] | None:
    if distance < NEAR_DISTANCE or distance > FAR_DISTANCE:
        return None
    height = wall_height_assembly(distance) if assembly else wall_height_reference(distance)
    screen_y = 120 + height // 2
    return ("h", screen_y) if screen_y < 240 else None


def reference_lines(
    player_x: int,
    player_y: int,
    direction_x: int,
    direction_y: int,
) -> tuple[tuple[object, ...], ...]:
    inv_x = inverse(direction_x)
    inv_y = inverse(direction_y)
    x_near = trunc_div(direction_x * NEAR_DISTANCE, FIXED_ONE)
    x_far = direction_x * 16
    y_near = trunc_div(direction_y * NEAR_DISTANCE, FIXED_ONE)
    y_far = direction_y * 16

    if direction_y == 0:
        x_input_near = -player_x
        x_input_far = x_input_near
        x_line_near = reference_scale(x_input_near, inv_x)
        x_line_far = x_line_near
        x_step = inv_x
        if direction_x < 0:
            x_line_near = -x_line_near
            x_line_far = -x_line_far
            x_step = -x_step
    else:
        x_input_near = player_x + x_near
        x_input_far = player_x + x_far
        x_line_near = reference_scale(x_input_near, inv_y)
        x_line_far = reference_scale(x_input_far, inv_y)
        x_step = -inv_y
        if direction_y < 0:
            x_line_near = -x_line_near
            x_line_far = -x_line_far
            x_step = -x_step

    if direction_x == 0:
        y_input_near = -player_y
        y_input_far = y_input_near
        y_line_near = reference_scale(y_input_near, inv_y)
        y_line_far = y_line_near
        y_step = inv_y
        if direction_y < 0:
            y_line_near = -y_line_near
            y_line_far = -y_line_far
            y_step = -y_step
    else:
        y_input_near = -player_y - y_near
        y_input_far = -player_y - y_far
        y_line_near = reference_scale(y_input_near, inv_x)
        y_line_far = reference_scale(y_input_far, inv_x)
        y_step = inv_x
        if direction_x < 0:
            y_line_near = -y_line_near
            y_line_far = -y_line_far
            y_step = -y_step

    result: list[tuple[object, ...]] = []
    for _ in range(GRID_LINES):
        if direction_y == 0:
            line = horizontal(x_line_near, assembly=False)
            if line is not None:
                result.append(line)
        else:
            result.append(("p", x_line_near, x_line_far))
        x_line_near += x_step
        x_line_far += x_step
        if direction_y == 0:
            x_input_near += FIXED_ONE
            if 0 <= x_input_near < FIXED_ONE:
                x_line_near = reference_scale(x_input_near, inv_x)
                if direction_x < 0:
                    x_line_near = -x_line_near
                x_line_far = x_line_near
        else:
            x_input_near -= FIXED_ONE
            x_input_far -= FIXED_ONE
            if -FIXED_ONE < x_input_near <= 0:
                x_line_near = reference_scale(x_input_near, inv_y)
                if direction_y < 0:
                    x_line_near = -x_line_near
            if -FIXED_ONE < x_input_far <= 0:
                x_line_far = reference_scale(x_input_far, inv_y)
                if direction_y < 0:
                    x_line_far = -x_line_far

    for _ in range(GRID_LINES):
        if direction_x == 0:
            line = horizontal(y_line_near, assembly=False)
            if line is not None:
                result.append(line)
        else:
            result.append(("p", y_line_near, y_line_far))
        y_line_near += y_step
        y_line_far += y_step
        if direction_x == 0:
            y_input_near += FIXED_ONE
            if 0 <= y_input_near < FIXED_ONE:
                y_line_near = reference_scale(y_input_near, inv_y)
                if direction_y < 0:
                    y_line_near = -y_line_near
                y_line_far = y_line_near
        else:
            y_input_near += FIXED_ONE
            y_input_far += FIXED_ONE
            if 0 <= y_input_near < FIXED_ONE:
                y_line_near = reference_scale(y_input_near, inv_x)
                if direction_x < 0:
                    y_line_near = -y_line_near
            if 0 <= y_input_far < FIXED_ONE:
                y_line_far = reference_scale(y_input_far, inv_x)
                if direction_x < 0:
                    y_line_far = -y_line_far
    return tuple(result)


def assembly_lines(
    player_x: int,
    player_y: int,
    direction_x: int,
    direction_y: int,
) -> tuple[tuple[object, ...], ...]:
    inv_x = inverse(direction_x)
    inv_y = inverse(direction_y)
    x_near = assembly_scale(direction_x, NEAR_DISTANCE)
    x_far = direction_x << 4
    y_near = assembly_scale(direction_y, NEAR_DISTANCE)
    y_far = direction_y << 4

    if direction_y == 0:
        x_input_near = -player_x
        x_input_far = x_input_near
        x_line_near = assembly_scale(x_input_near, inv_x)
        x_line_far = x_line_near
        x_step = inv_x
        if direction_x < 0:
            x_line_near = -x_line_near
            x_line_far = -x_line_far
            x_step = -x_step
    else:
        x_input_near = player_x + x_near
        x_input_far = player_x + x_far
        x_line_near = assembly_scale(x_input_near, inv_y)
        x_line_far = assembly_scale(x_input_far, inv_y)
        x_step = -inv_y
        if direction_y < 0:
            x_line_near = -x_line_near
            x_line_far = -x_line_far
            x_step = -x_step

    if direction_x == 0:
        y_input_near = -player_y
        y_input_far = y_input_near
        y_line_near = assembly_scale(y_input_near, inv_y)
        y_line_far = y_line_near
        y_step = inv_y
        if direction_y < 0:
            y_line_near = -y_line_near
            y_line_far = -y_line_far
            y_step = -y_step
    else:
        y_input_near = -player_y - y_near
        y_input_far = -player_y - y_far
        y_line_near = assembly_scale(y_input_near, inv_x)
        y_line_far = assembly_scale(y_input_far, inv_x)
        y_step = inv_x
        if direction_x < 0:
            y_line_near = -y_line_near
            y_line_far = -y_line_far
            y_step = -y_step

    result: list[tuple[object, ...]] = []
    for index in range(GRID_LINES):
        if direction_y == 0:
            line = horizontal(x_line_near, assembly=True)
            if line is not None:
                result.append(line)
        else:
            result.append(("p", x_line_near, x_line_far))
        if index == GRID_LINES - 1:
            break
        x_line_near += x_step
        x_line_far += x_step
        if direction_y != 0:
            x_input_near -= FIXED_ONE
            x_input_far -= FIXED_ONE
            if -255 <= x_input_near <= 0:
                x_line_near = assembly_scale(x_input_near, inv_y)
                if direction_y < 0:
                    x_line_near = -x_line_near
            if -255 <= x_input_far <= 0:
                x_line_far = assembly_scale(x_input_far, inv_y)
                if direction_y < 0:
                    x_line_far = -x_line_far

    for index in range(GRID_LINES):
        if direction_x == 0:
            line = horizontal(y_line_near, assembly=True)
            if line is not None:
                result.append(line)
        else:
            result.append(("p", y_line_near, y_line_far))
        if index == GRID_LINES - 1:
            break
        y_line_near += y_step
        y_line_far += y_step
        if direction_x != 0:
            y_input_near += FIXED_ONE
            y_input_far += FIXED_ONE
            if 0 <= y_input_near <= 255:
                y_line_near = assembly_scale(y_input_near, inv_x)
                if direction_x < 0:
                    y_line_near = -y_line_near
            if 0 <= y_input_far <= 255:
                y_line_far = assembly_scale(y_input_far, inv_x)
                if direction_x < 0:
                    y_line_far = -y_line_far
    return tuple(result)


def check_frame(player_x: int, player_y: int, direction: tuple[int, int]) -> None:
    expected = reference_lines(player_x, player_y, *direction)
    actual = assembly_lines(player_x, player_y, *direction)
    if actual != expected:
        for index, (left, right) in enumerate(zip(expected, actual)):
            if left != right:
                detail = f"first line {index}: expected {left}, got {right}"
                break
        else:
            detail = f"line counts differ: expected {len(expected)}, got {len(actual)}"
        raise AssertionError(
            f"camera=({player_x},{player_y}) direction={direction}: {detail}"
        )


def check_source_contract() -> None:
    source = ASM_PATH.read_text(encoding="utf-8")
    required = (
        "_render_asm_draw_background_grid:",
        "_render_asm_add_projected_grid_segment_registers:",
        "_render_asm_draw_horizontal_grid_pair_register:",
        "call _render_asm_clear_background",
        "call .Lbackground_repair_down_crossing",
        "call .Lbackground_repair_up_crossing",
    )
    for marker in required:
        if marker not in source:
            raise AssertionError(f"missing assembly generator contract: {marker}")
    section = source.split("_render_asm_draw_background_grid:", 1)[1].split(
        ".size _render_asm_draw_background_grid", 1
    )[0]
    frame_reads = re.findall(r"\(ix \+ (?:6|9|12)\)", section)
    if frame_reads != ["(ix + 6)", "(ix + 9)", "(ix + 12)"]:
        raise AssertionError(f"unexpected per-line IX frame reads: {frame_reads}")
    forbidden = ("_fixed_scale_mul", "__idivs", "__imuls", "_gfx_Line")
    for marker in forbidden:
        if marker in section:
            raise AssertionError(f"generator reintroduced hot helper {marker}")


def main() -> None:
    check_source_contract()

    factors = {0, NEAR_DISTANCE, 65536}
    factors.update(inverse(component) for component in range(1, 257))
    scale_cases = 0
    for factor in sorted(factors):
        for value in range(-8192, 8193):
            expected = reference_scale(value, factor)
            actual = assembly_scale(value, factor)
            if actual != expected:
                raise AssertionError(
                    f"scale value={value} factor={factor}: expected {expected}, got {actual}"
                )
            scale_cases += 1

    for distance in range(NEAR_DISTANCE, FAR_DISTANCE + 1):
        expected = wall_height_reference(distance)
        actual = wall_height_assembly(distance)
        if actual != expected:
            raise AssertionError(
                f"height distance={distance}: expected {expected}, got {actual}"
            )

    representative = (
        (301, 301), (383, 640), (511, 1025), (1024, 2047),
        (1979, 2305), (3071, 3379), (3584, 3584), (3795, 3795),
    )
    angle_frames = 0
    for angle, direction in enumerate(DIRECTIONS):
        player = representative[angle & (len(representative) - 1)]
        check_frame(*player, direction)
        angle_frames += 1

    edge_angles = {
        0, 1, 2, 255, 256, 4095, 4096, 4097,
        8191, 8192, 8193, 12287, 12288, 12289, 16382, 16383,
    }
    fraction_frames = 0
    for angle in sorted(edge_angles):
        direction = DIRECTIONS[angle]
        for fraction in range(256):
            player_x = (1 + ((fraction * 5 + angle) % 13)) * 256 + fraction
            player_y = (1 + ((fraction * 7 + angle // 256) % 13)) * 256 + (255 - fraction)
            check_frame(player_x, player_y, direction)
            fraction_frames += 1

    rng = random.Random(0xBACC_603D)
    random_frames = 50_000
    for _ in range(random_frames):
        direction = DIRECTIONS[rng.randrange(ANGLE_WRAP)]
        player_x = rng.randint(301, 3795)
        player_y = rng.randint(301, 3795)
        check_frame(player_x, player_y, direction)

    print(
        "background generator exact: "
        f"{scale_cases:,} signed scale cases, "
        f"{FAR_DISTANCE - NEAR_DISTANCE + 1:,} height lookups, "
        f"{angle_frames:,} all-angle frames, "
        f"{fraction_frames:,} axis-edge fraction frames, and "
        f"{random_frames:,} deterministic random camera frames"
    )


if __name__ == "__main__":
    main()
