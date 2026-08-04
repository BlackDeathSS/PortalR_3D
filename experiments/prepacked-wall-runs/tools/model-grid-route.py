#!/usr/bin/env python3
"""Count background-grid line shapes for benchmark camera states.

This is a host-side model of ``draw_background_grid`` and the assembly
projection/culling boundary.  It is intentionally diagnostic-only: it helps
weight candidate raster-loop optimizations by the shapes the fixed benchmark
route actually emits.
"""

from __future__ import annotations

import argparse
import csv
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator


FIXED_ONE = 256
ANGLE_MASK = 16383
SCREEN_WIDTH = 320
NEAR_DISTANCE = 260
FAR_DISTANCE = 4096
NEAR_HEIGHT = 236
FAR_HEIGHT = 15
PROJECT_LIMIT = 4096
GRID_LINES = 16

DIRECTION_X = (
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25,
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
)
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


def trunc_div(numerator: int, denominator: int) -> int:
    quotient = abs(numerator) // denominator
    return -quotient if numerator < 0 else quotient


def fixed_mul(left: int, right: int) -> int:
    return trunc_div(left * right, FIXED_ONE)


def reciprocal(component: int) -> int:
    magnitude = abs(component)
    if magnitude == 0:
        return 0x3FFFFF
    if magnitude == 1:
        return 65536
    return 65536 // min(magnitude, 425)


def fixed_scale_mul(value: int, factor: int) -> int:
    whole = factor // FIXED_ONE
    fraction = factor - whole * FIXED_ONE
    return value * whole + fixed_mul(value, fraction)


def direction_for_angle(angle: int) -> tuple[int, int]:
    normalized = angle & ANGLE_MASK
    index = normalized >> 8
    fraction = normalized & 255

    def interpolate(table: tuple[int, ...]) -> int:
        value = table[index]
        difference = table[(index + 1) & 63] - value
        return value + trunc_div(difference * fraction, FIXED_ONE)

    return interpolate(DIRECTION_X), interpolate(DIRECTION_Y)


def project_x(lateral: int, height: int) -> int:
    positive_limit = (
        (PROJECT_LIMIT - SCREEN_WIDTH // 2) * FIXED_ONE // height
    )
    negative_limit = (
        (PROJECT_LIMIT + SCREEN_WIDTH // 2) * FIXED_ONE // height
    )
    if lateral >= positive_limit:
        return PROJECT_LIMIT
    if lateral <= -negative_limit:
        return -PROJECT_LIMIT
    return SCREEN_WIDTH // 2 + fixed_mul(lateral, height)


def x_outcode(x: int) -> int:
    if x < 0:
        return 1
    if x >= SCREEN_WIDTH:
        return 2
    return 0


def clip_line_x(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
) -> tuple[int, int, int, int] | None:
    out0 = x_outcode(x0)
    out1 = x_outcode(x1)
    if out0 & out1:
        return None
    if out1:
        bound = SCREEN_WIDTH - 1 if out1 == 2 else 0
        y1 = y0 + ((y1 - y0) * (bound - x0)) // (x1 - x0)
        x1 = bound
    if out0:
        bound = SCREEN_WIDTH - 1 if out0 == 2 else 0
        y0 = y0 + ((y1 - y0) * (bound - x0)) // (x1 - x0)
        x0 = bound
    return x0, y0, x1, y1


@dataclass(frozen=True)
class Camera:
    player_x: int
    player_y: int
    angle: int


def projected_pairs(camera: Camera) -> Iterator[tuple[int, int]]:
    direction_x, direction_y = direction_for_angle(camera.angle)
    inverse_x = 0 if direction_x == 0 else reciprocal(direction_x)
    inverse_y = 0 if direction_y == 0 else reciprocal(direction_y)
    x_near = fixed_mul(direction_x, NEAR_DISTANCE)
    x_far = fixed_mul(direction_x, FAR_DISTANCE)
    y_near = fixed_mul(direction_y, NEAR_DISTANCE)
    y_far = fixed_mul(direction_y, FAR_DISTANCE)

    if direction_y == 0:
        x_input_near = -camera.player_x
        x_input_far = x_input_near
        x_line_near = fixed_scale_mul(x_input_near, inverse_x)
        x_line_far = x_line_near
        x_line_step = inverse_x
        if direction_x < 0:
            x_line_near = -x_line_near
            x_line_far = -x_line_far
            x_line_step = -x_line_step
    else:
        x_input_near = camera.player_x + x_near
        x_input_far = camera.player_x + x_far
        x_line_near = fixed_scale_mul(x_input_near, inverse_y)
        x_line_far = fixed_scale_mul(x_input_far, inverse_y)
        x_line_step = -inverse_y
        if direction_y < 0:
            x_line_near = -x_line_near
            x_line_far = -x_line_far
            x_line_step = -x_line_step

    if direction_x == 0:
        y_input_near = -camera.player_y
        y_input_far = y_input_near
        y_line_near = fixed_scale_mul(y_input_near, inverse_y)
        y_line_far = y_line_near
        y_line_step = inverse_y
        if direction_y < 0:
            y_line_near = -y_line_near
            y_line_far = -y_line_far
            y_line_step = -y_line_step
    else:
        y_input_near = -camera.player_y - y_near
        y_input_far = -camera.player_y - y_far
        y_line_near = fixed_scale_mul(y_input_near, inverse_x)
        y_line_far = fixed_scale_mul(y_input_far, inverse_x)
        y_line_step = inverse_x
        if direction_x < 0:
            y_line_near = -y_line_near
            y_line_far = -y_line_far
            y_line_step = -y_line_step

    for family in ("x", "y"):
        if family == "x":
            line_near = x_line_near
            line_far = x_line_far
            line_step = x_line_step
            input_near = x_input_near
            input_far = x_input_far
            axis = direction_y
        else:
            line_near = y_line_near
            line_far = y_line_far
            line_step = y_line_step
            input_near = y_input_near
            input_far = y_input_far
            axis = direction_x

        for _ in range(GRID_LINES):
            if axis != 0:
                yield project_x(line_far, FAR_HEIGHT), project_x(
                    line_near, NEAR_HEIGHT
                )

            line_near += line_step
            line_far += line_step
            if family == "x":
                if direction_y == 0:
                    input_near += FIXED_ONE
                    if 0 <= input_near < FIXED_ONE:
                        line_near = fixed_scale_mul(input_near, inverse_x)
                        if direction_x < 0:
                            line_near = -line_near
                        line_far = line_near
                else:
                    input_near -= FIXED_ONE
                    input_far -= FIXED_ONE
                    if -FIXED_ONE < input_near <= 0:
                        line_near = fixed_scale_mul(input_near, inverse_y)
                        if direction_y < 0:
                            line_near = -line_near
                    if -FIXED_ONE < input_far <= 0:
                        line_far = fixed_scale_mul(input_far, inverse_y)
                        if direction_y < 0:
                            line_far = -line_far
            else:
                if direction_x == 0:
                    input_near += FIXED_ONE
                    if 0 <= input_near < FIXED_ONE:
                        line_near = fixed_scale_mul(input_near, inverse_y)
                        if direction_y < 0:
                            line_near = -line_near
                        line_far = line_near
                else:
                    input_near += FIXED_ONE
                    input_far += FIXED_ONE
                    if 0 <= input_near < FIXED_ONE:
                        line_near = fixed_scale_mul(input_near, inverse_x)
                        if direction_x < 0:
                            line_near = -line_near
                    if 0 <= input_far < FIXED_ONE:
                        line_far = fixed_scale_mul(input_far, inverse_x)
                        if direction_x < 0:
                            line_far = -line_far


def classify(camera: Camera) -> tuple[Counter[str], Counter[int], Counter[str]]:
    classes: Counter[str] = Counter()
    noclip_dx: Counter[int] = Counter()
    clipped_shapes: Counter[str] = Counter()
    for far_x, near_x in projected_pairs(camera):
        out0 = x_outcode(far_x)
        out1 = x_outcode(near_x)
        if out0 & out1:
            classes["culled"] += 1
            continue
        if out0 == 0 and out1 == 0:
            classes["noclip"] += 1
            noclip_dx[abs(near_x - far_x)] += 1
            continue

        classes["clipped"] += 1
        floor = clip_line_x(far_x, 127, near_x, 238)
        ceiling = clip_line_x(far_x, 113, near_x, 2)
        if floor is None or ceiling is None:
            raise AssertionError("retained line clipped away")
        fx0, fy0, fx1, fy1 = floor
        cx0, cy0, cx1, cy1 = ceiling
        if (fx0, fx1) != (cx0, cx1):
            raise AssertionError("paired clip produced different X endpoints")
        dx = abs(fx1 - fx0)
        floor_dy = abs(fy1 - fy0)
        ceiling_dy = abs(cy1 - cy0)
        floor_major = "H" if dx > floor_dy else "V"
        ceiling_major = "H" if dx > ceiling_dy else "V"
        clipped_shapes[
            f"{floor_major}{ceiling_major}:dy_delta="
            f"{ceiling_dy - floor_dy:+d}"
        ] += 1
    return classes, noclip_dx, clipped_shapes


def load_live_frames(path: Path) -> list[Camera]:
    with path.open(newline="", encoding="utf-8") as source:
        return [
            Camera(
                int(row["player_x_raw"]),
                int(row["player_y_raw"]),
                int(row["angle_raw"]),
            )
            for row in csv.DictReader(source)
        ]


STATIC_CAMERAS = (
    Camera(384, 384, 32 << 8),
    Camera(2432, 640, 48 << 8),
    Camera(896, 384, 6 << 8),
    Camera(384, 640, 32 << 8),
    Camera(1920, 1920, 0),
    Camera(384, 384, 32 << 8),
)


def summarize(name: str, cameras: Iterable[Camera]) -> None:
    cameras = list(cameras)
    totals: Counter[str] = Counter()
    dx_values: Counter[int] = Counter()
    clipped_shapes: Counter[str] = Counter()
    cache: dict[
        Camera, tuple[Counter[str], Counter[int], Counter[str]]
    ] = {}
    for camera in cameras:
        result = cache.setdefault(camera, classify(camera))
        totals.update(result[0])
        dx_values.update(result[1])
        clipped_shapes.update(result[2])

    count = len(cameras)
    print(f"{name}: {count} frames, {len(cache)} unique camera states")
    print(
        "  projected lines/frame: "
        f"noclip={totals['noclip'] / count:.3f}, "
        f"clipped={totals['clipped'] / count:.3f}, "
        f"culled={totals['culled'] / count:.3f}"
    )
    print(f"  no-clip dx: {dx_values.most_common(20)}")
    print(f"  clipped raster classes: {clipped_shapes}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--live-frames",
        type=Path,
        help="decoded P3DLIVE frames CSV to weight actual route states",
    )
    args = parser.parse_args()
    summarize("static suite", STATIC_CAMERAS)
    for index, camera in enumerate(STATIC_CAMERAS):
        summarize(f"static scene {index}", (camera,))
    if args.live_frames is not None:
        summarize("live route", load_live_frames(args.live_frames))


if __name__ == "__main__":
    main()
