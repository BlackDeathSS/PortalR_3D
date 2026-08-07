#!/usr/bin/env python3
"""Property test the two-chain scan converter against True3D's reference path."""

from __future__ import annotations

import argparse
import math
import random

FIXED_SHIFT = 8
FIXED_ONE = 1 << FIXED_SHIFT
PROJECTED_LIMIT = 1 << 20
EDGE_RECIPROCAL_SHIFT = 4
EDGE_RECIPROCAL_SIZE = 2048
EDGE_STEP_PRECISION_SHIFT = 12
RENDER_WIDTH = 64
RENDER_HEIGHT = 48
NEAR_PLANE = 32
PROJECTION_TABLE_SHIFT = 2
PROJECTION_TABLE_SIZE = 2048
FAR_PROJECTION_TABLE_SHIFT = 5
PROJECTION_SCALE_SHIFT = 6
PROJECTION_FOCAL = 42


def trunc_div(numerator: int, denominator: int) -> int:
    assert denominator > 0
    return numerator // denominator if numerator >= 0 else -((-numerator) // denominator)


def floor_q8(value: int) -> int:
    return value // FIXED_ONE


def ceil_q8(value: int) -> int:
    return -((-value) // FIXED_ONE)


def clamp_projected(value: int) -> int:
    return max(-PROJECTED_LIMIT, min(PROJECTED_LIMIT, value))


def edge_x_step(delta_x: int, delta_y: int) -> int:
    index = (delta_y + (1 << (EDGE_RECIPROCAL_SHIFT - 1))) >> EDGE_RECIPROCAL_SHIFT
    if (
        delta_y < FIXED_ONE
        or index >= EDGE_RECIPROCAL_SIZE
        or delta_x > 32767
        or delta_x < -32767
    ):
        return trunc_div(delta_x * FIXED_ONE, delta_y)
    denominator = index << EDGE_RECIPROCAL_SHIFT
    reciprocal = ((1 << (EDGE_STEP_PRECISION_SHIFT + FIXED_SHIFT)) + denominator // 2) // denominator
    reciprocal = min(reciprocal, 65535)
    return (delta_x * reciprocal) >> EDGE_STEP_PRECISION_SHIFT


def row_bounds(points, shift, layer_first, layer_last, active_height):
    step = 1 << shift
    origin = step >> 1
    minimum_y = min(y for _, y in points)
    maximum_y = max(y for _, y in points)
    first = ceil_q8(minimum_y - FIXED_ONE // 2)
    last = floor_q8(maximum_y - 1 - FIXED_ONE // 2)
    if shift == 0:
        first = max(first, layer_first)
        last = min(last, layer_last)
    else:
        clip_first = (layer_first >> shift) * step + origin
        clip_last = (layer_last >> shift) * step + origin
        first = max(first, clip_first)
        last = min(last, clip_last)
    first = max(first, 0)
    last = min(last, active_height - 1)
    if first <= origin:
        first = origin
    else:
        first = origin + (((first - origin + step - 1) >> shift) << shift)
    if last < origin:
        return None
    last = origin + (((last - origin) >> shift) << shift)
    if first > last:
        return None
    return step, origin, first, last


def finish_span(left, right, active_width):
    first_column = ceil_q8(clamp_projected(left) - FIXED_ONE // 2)
    last_column = floor_q8(clamp_projected(right) - FIXED_ONE // 2)
    first_column = max(first_column, 0)
    last_column = min(last_column, active_width - 1)
    return (first_column, last_column) if first_column <= last_column else (255, 0)


def reference(points, shift, layer_first, layer_last, row_left, row_right, active_width, active_height):
    bounds = row_bounds(points, shift, layer_first, layer_last, active_height)
    if bounds is None:
        return False, None, None, {}
    step, origin, first, last = bounds
    left = {row: PROJECTED_LIMIT + 1 for row in range(first, last + 1, step)}
    right = {row: -PROJECTED_LIMIT - 1 for row in range(first, last + 1, step)}
    for index, original_a in enumerate(points):
        a = original_a
        b = points[(index + 1) % len(points)]
        if a[1] == b[1]:
            continue
        if a[1] > b[1]:
            a, b = b, a
        delta_x = b[0] - a[0]
        delta_y = b[1] - a[1]
        edge_first = max(ceil_q8(a[1] - FIXED_ONE // 2), first)
        edge_last = min(floor_q8(b[1] - 1 - FIXED_ONE // 2), last)
        if edge_first <= origin:
            edge_first = origin
        else:
            edge_first = origin + (((edge_first - origin + step - 1) >> shift) << shift)
        if edge_first > edge_last:
            continue
        x_step = edge_x_step(delta_x, delta_y)
        x_value = a[0] + ((x_step * (edge_first * FIXED_ONE + FIXED_ONE // 2 - a[1])) >> FIXED_SHIFT)
        for row in range(edge_first, edge_last + 1, step):
            if x_value < left[row]:
                left[row] = clamp_projected(x_value)
            if x_value > right[row]:
                right[row] = clamp_projected(x_value)
            if row + step <= edge_last:
                x_value += x_step * step
    spans = {}
    any_pixel = False
    for row in range(first, last + 1, step):
        if left[row] == PROJECTED_LIMIT + 1:
            spans[row] = (255, 0)
            continue
        spans[row] = finish_span(left[row], right[row], active_width)
        lo, hi = spans[row]
        if lo <= hi and (
            shift != 0
            or (layer_first <= row <= layer_last and hi >= row_left[row] and lo <= row_right[row])
        ):
            any_pixel = True
    return any_pixel, first, last, spans


def chain_begin(points, state, row, step):
    while state["edges_left"]:
        vertex = state["vertex"]
        a = points[vertex]
        if state["direction"] > 0:
            next_vertex = vertex + 1
            if next_vertex == len(points):
                next_vertex = 0
        else:
            next_vertex = len(points) - 1 if vertex == 0 else vertex - 1
        state["vertex"] = next_vertex
        state["edges_left"] -= 1
        b = points[next_vertex]
        if a[1] == b[1]:
            continue
        if a[1] > b[1]:
            return False
        first = ceil_q8(a[1] - FIXED_ONE // 2)
        last = floor_q8(b[1] - 1 - FIXED_ONE // 2)
        if last < row:
            continue
        if first > row:
            return False
        x_step = edge_x_step(b[0] - a[0], b[1] - a[1])
        state["last"] = last
        state["x"] = a[0] + ((x_step * (row * FIXED_ONE + FIXED_ONE // 2 - a[1])) >> FIXED_SHIFT)
        state["advance"] = x_step * step
        return True
    return False


def candidate(points, shift, layer_first, layer_last, row_left, row_right, active_width, active_height):
    bounds = row_bounds(points, shift, layer_first, layer_last, active_height)
    if bounds is None:
        return False, None, None, {}
    step, _, first, last = bounds
    top = min(range(len(points)), key=lambda index: points[index][1])
    chains = [
        {"vertex": top, "direction": 1, "edges_left": len(points)},
        {"vertex": top, "direction": -1, "edges_left": len(points)},
    ]
    if not chain_begin(points, chains[0], first, step) or not chain_begin(points, chains[1], first, step):
        return False, first, last, {"failure": (255, 0)}
    spans = {}
    any_pixel = False
    for row in range(first, last + 1, step):
        for chain in chains:
            if row > chain["last"] and not chain_begin(points, chain, row, step):
                return False, first, last, {"failure": (255, 0)}
        left, right = chains[0]["x"], chains[1]["x"]
        if left > right:
            left, right = right, left
        spans[row] = finish_span(left, right, active_width)
        lo, hi = spans[row]
        if lo <= hi and (
            shift != 0
            or (layer_first <= row <= layer_last and hi >= row_left[row] and lo <= row_right[row])
        ):
            any_pixel = True
        for chain in chains:
            if row + step <= chain["last"]:
                chain["x"] += chain["advance"]
    return any_pixel, first, last, spans


def convex_hull(points):
    points = sorted(set(points))
    if len(points) < 3:
        return []
    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    lower = []
    for point in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], point) <= 0:
            lower.pop()
        lower.append(point)
    upper = []
    for point in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], point) <= 0:
            upper.pop()
        upper.append(point)
    return lower[:-1] + upper[:-1]


def project(point, shift):
    x, y, depth = point
    if depth >= PROJECTION_TABLE_SIZE << PROJECTION_TABLE_SHIFT:
        index = min(depth >> FAR_PROJECTION_TABLE_SHIFT, PROJECTION_TABLE_SIZE - 1)
        scale = (PROJECTION_FOCAL * FIXED_ONE * (1 << PROJECTION_SCALE_SHIFT)) // (index << FAR_PROJECTION_TABLE_SHIFT)
    else:
        index = max(1, min(depth >> PROJECTION_TABLE_SHIFT, PROJECTION_TABLE_SIZE - 1))
        scale = 65535 if index < (NEAR_PLANE >> PROJECTION_TABLE_SHIFT) else (
            PROJECTION_FOCAL * FIXED_ONE * (1 << PROJECTION_SCALE_SHIFT)
        ) // (index << PROJECTION_TABLE_SHIFT)
    px = clamp_projected(32 * FIXED_ONE + ((x * scale) >> PROJECTION_SCALE_SHIFT))
    py = clamp_projected(24 * FIXED_ONE - ((y * scale) >> PROJECTION_SCALE_SHIFT))
    return (px >> shift, py >> shift)


def intersect_near(first, second):
    lower, upper = (first, second) if first[2] <= second[2] else (second, first)
    depth_delta = upper[2] - lower[2]
    fraction = (((NEAR_PLANE - lower[2]) << 14) + depth_delta // 2) // depth_delta
    return (
        lower[0] + (((upper[0] - lower[0]) * fraction) >> 14),
        lower[1] + (((upper[1] - lower[1]) * fraction) >> 14),
        NEAR_PLANE,
    )


def clip_and_project(source, shift):
    output = []
    for index, current in enumerate(source):
        previous = source[index - 1]
        current_inside = current[2] >= NEAR_PLANE
        previous_inside = previous[2] >= NEAR_PLANE
        if current_inside != previous_inside:
            output.append(intersect_near(previous, current))
        if current_inside:
            output.append(current)
    return [project(point, shift) for point in output] if len(output) >= 3 else []


def check(points, rng, ordinal, label):
    if len(points) < 3 or len(points) > 8:
        return False
    if rng.randrange(2):
        points = list(reversed(points))
    rotate = rng.randrange(len(points))
    points = points[rotate:] + points[:rotate]
    shift = rng.randrange(3)
    active_width = RENDER_WIDTH >> (1 if label == "near" and shift else 0)
    active_height = RENDER_HEIGHT >> (1 if label == "near" and shift else 0)
    # LOD samples the active target using shift; random clipping exercises both paths.
    layer_first = rng.randrange(active_height)
    layer_last = rng.randrange(layer_first, active_height)
    row_left = [rng.randrange(active_width) for _ in range(active_height)]
    row_right = [rng.randrange(row_left[row], active_width) for row in range(active_height)]
    args = (shift, layer_first, layer_last, row_left, row_right, active_width, active_height)
    expected = reference(points, *args)
    actual = candidate(points, *args)
    if expected != actual:
        raise AssertionError(
            f"{label} case {ordinal} differs\npoints={points}\nargs={args[:3] + args[-2:]}\n"
            f"reference={expected}\ncandidate={actual}"
        )
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=0x3D202608)
    parser.add_argument("--screen-cases", type=int, default=200_000)
    parser.add_argument("--near-cases", type=int, default=100_000)
    args = parser.parse_args()
    rng = random.Random(args.seed)
    checked_screen = 0
    checked_near = 0

    for ordinal in range(args.screen_cases):
        count = rng.randrange(3, 13)
        raw = [
            (rng.randrange(-96 * FIXED_ONE, 160 * FIXED_ONE),
             rng.randrange(-96 * FIXED_ONE, 144 * FIXED_ONE))
            for _ in range(count)
        ]
        points = convex_hull(raw)
        if 3 <= len(points) <= 8:
            checked_screen += check(points, rng, ordinal, "screen")

    for ordinal in range(args.near_cases):
        center = (
            rng.randrange(-4 * FIXED_ONE, 4 * FIXED_ONE),
            rng.randrange(-3 * FIXED_ONE, 3 * FIXED_ONE),
            rng.randrange(-2 * FIXED_ONE, 8 * FIXED_ONE),
        )
        u = (
            rng.randrange(FIXED_ONE // 4, 4 * FIXED_ONE),
            rng.randrange(-FIXED_ONE, FIXED_ONE),
            rng.randrange(-4 * FIXED_ONE, 4 * FIXED_ONE),
        )
        v = (
            rng.randrange(-FIXED_ONE, FIXED_ONE),
            rng.randrange(FIXED_ONE // 4, 4 * FIXED_ONE),
            rng.randrange(-4 * FIXED_ONE, 4 * FIXED_ONE),
        )
        source = []
        for su, sv in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
            source.append(tuple(center[i] + su * u[i] + sv * v[i] for i in range(3)))
        projection_shift = rng.randrange(2)
        points = clip_and_project(source, projection_shift)
        if 3 <= len(points) <= 8:
            # Projection can collapse tiny polygons; a hull equality check restricts
            # this property to the convex, non-degenerate renderer contract.
            hull = convex_hull(points)
            if len(hull) == len(set(points)) and len(hull) == len(points):
                checked_near += check(points, rng, ordinal, "near")

    print(
        f"PASS seed=0x{args.seed:X} screen={checked_screen} "
        f"near_clipped_or_projected={checked_near} total={checked_screen + checked_near}"
    )


if __name__ == "__main__":
    main()
