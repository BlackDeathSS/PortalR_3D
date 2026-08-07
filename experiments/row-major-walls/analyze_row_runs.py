#!/usr/bin/env python3
"""Model exact horizontal color runs for terminal first-hit walls.

This deliberately starts with the conservative subset used by the prior wall
group model: columns whose first hit is not a portal.  It answers whether a
row-major writer can amortize stores without changing any texture samples.
"""

from __future__ import annotations

import argparse
import collections
import csv
import importlib.util
import sys
from pathlib import Path


HERE = Path(__file__).resolve().parent
TEXTURE_HEIGHT = 8
MODEL_PATH = HERE / "tools" / "analyze-wall-groups.py"
SPEC = importlib.util.spec_from_file_location("wall_groups", MODEL_PATH)
assert SPEC and SPEC.loader
M = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = M
SPEC.loader.exec_module(M)


def profile_boundaries(height: int, start: int, end: int) -> tuple[int, ...]:
    step = (TEXTURE_HEIGHT << 8) // height
    visible = min(height, M.LCD_HEIGHT)
    result = []
    for boundary in range(TEXTURE_HEIGHT + 1):
        screen_offset = ((boundary << 8) + step - 1) // step
        result.append(start + min(screen_offset, visible))
    assert result[0] == start and result[-1] == end
    return tuple(result)


def texel(material: int, x: int, source_y: int) -> int:
    if material == 0:
        mortar = x == 0 or source_y == 0 or source_y == 8 or (
            source_y >= 8 and x == 8
        )
        noise = (x * 5 + source_y * 3 + ((x ^ source_y) * 7)) & 3
        return 0 if mortar else 2 + noise
    if material == 1:
        seam = x == 0 or x == 8 or source_y == 0 or source_y == 8
        rivet = (x & 7) in (2, 6) and (source_y & 7) in (2, 6)
        brushed = 2 + ((x * 3 + source_y * 5 + (x ^ source_y)) & 3)
        return 0 if seam else (7 if rivet else brushed)
    if material == 2:
        joint = source_y == 0 or source_y == 8 or (
            x == (0 if source_y < 8 else 8)
        )
        aggregate = 2 + ((x * 7 + source_y * 11 + (x ^ (source_y * 3))) & 3)
        pock = ((x * 13 + source_y * 5) & 31) == 0
        return 0 if joint else (1 if pock else aggregate)
    seam = x == 0 or x == 8 or source_y == 0 or source_y == 8
    hazard = (x + source_y) & 7
    plate = 2 + ((x * 5 + source_y * 3 + (x ^ source_y)) & 3)
    return 0 if seam else (6 + (hazard & 1) if hazard < 2 else plate)


def scene_columns(scene):
    dir_x, dir_y = M.direction_for_angle(scene.angle)
    plane_x = -M.fov_component(dir_y)
    plane_y = M.fov_component(dir_x)
    result = []
    for ray_x, ray_y in zip(
        M.ray_values(dir_x, plane_x), M.ray_values(dir_y, plane_y)
    ):
        hit = M.cast_first_wall(scene.player_x, scene.player_y, ray_x, ray_y)
        if M.is_portal_hit(scene, hit):
            result.append(None)
            continue
        signature = M.wall_signature(hit)
        height = signature.end - signature.start
        # Recover the full projection height from the profile table.  The
        # visible height is sufficient except for a screen-filling wall.
        full_height = M.LCD_HEIGHT * 4 if signature.start == 0 and signature.end == 240 else height
        if signature.start == 0 and signature.end == 240:
            # Find the profile's first table entry and reproduce its height.
            full_height = next(
                h for p, h in enumerate_profile_heights() if p == signature.profile
            )
        boundaries = profile_boundaries(
            full_height, signature.start, signature.end
        )
        # The signature stores the eight-descriptor byte-index operand
        # (0, 8, ..., 120), not the 0..15 texture x coordinate itself.
        texture_x = signature.texture_column_offset >> 3
        colors = tuple(
            (signature.material, signature.shade, texel(signature.material, texture_x, y << 1))
            for y in range(TEXTURE_HEIGHT)
        )
        result.append((signature.start, signature.end, boundaries, colors))
    return result


def enumerate_profile_heights():
    seen = set()
    height = M.WALL_HEIGHT_MAX
    previous = 0
    profile = -1
    limit = M.LCD_HEIGHT * M.FIXED_ONE >> M.WALL_HEIGHT_TABLE_SHIFT
    for index in range(M.WALL_HEIGHT_TABLE_SIZE):
        if index:
            while height > 1 and height * index > limit:
                height -= 1
        if height != previous:
            profile += 1
            seen.add(profile)
            yield profile, height
            previous = height


def summarize(scene):
    columns = scene_columns(scene)
    active = 0
    runs = 0
    lengths = collections.Counter()
    for y in range(M.LCD_HEIGHT):
        current = None
        length = 0
        for column in columns + [None]:
            color = None
            if column is not None:
                start, end, boundaries, colors = column
                if start <= y < end:
                    source = 0
                    while source < 7 and boundaries[source + 1] <= y:
                        source += 1
                    color = colors[source]
            if color is not None and color == current:
                length += 1
            else:
                if length:
                    runs += 1
                    active += length
                    lengths[length] += 1
                current = color
                length = 1 if color is not None else 0
    return active, runs, lengths


def signature_stats(scene):
    dir_x, dir_y = M.direction_for_angle(scene.angle)
    plane_x = -M.fov_component(dir_y)
    plane_y = M.fov_component(dir_x)
    signatures = []
    for ray_x, ray_y in zip(
        M.ray_values(dir_x, plane_x), M.ray_values(dir_y, plane_y)
    ):
        hit = M.cast_first_wall(scene.player_x, scene.player_y, ray_x, ray_y)
        if not M.is_portal_hit(scene, hit):
            signatures.append(M.wall_signature(hit))
    return (
        len(signatures),
        len(set(signatures)),
        len({s.profile for s in signatures}),
        len({(s.material, s.texture_column_offset) for s in signatures}),
        len({(s.material, s.shade) for s in signatures}),
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--live-csv", type=Path)
    args = parser.parse_args()
    scenes = list(M.STATIC_SCENES)
    if args.live_csv:
        scenes.extend(M.live_scenes(args.live_csv))
    total_active = total_runs = 0
    total_jobs = total_signatures = 0
    distribution = collections.Counter()
    for index, scene in enumerate(scenes):
        active, runs, lengths = summarize(scene)
        jobs, signatures, profiles, textures, colors = signature_stats(scene)
        total_active += active
        total_runs += runs
        total_jobs += jobs
        total_signatures += signatures
        distribution.update(lengths)
        if index < len(M.STATIC_SCENES):
            print(f"{scene.name:16} pixels={active:5} runs={runs:5} mean={active/runs if runs else 0:.2f} jobs={jobs:2} signatures={signatures:2} profile/texture/color={profiles}/{textures}/{colors}")
    print(f"TOTAL frames={len(scenes)} pixels={total_active} runs={total_runs} mean={total_active/total_runs if total_runs else 0:.3f}")
    print(f"jobs={total_jobs} signatures={total_signatures} reuse={total_jobs/total_signatures if total_signatures else 0:.3f}")
    print("run lengths", dict(sorted(distribution.items())))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
