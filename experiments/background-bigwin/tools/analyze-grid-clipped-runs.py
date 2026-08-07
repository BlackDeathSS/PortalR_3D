#!/usr/bin/env python3
"""Report exact clipped background-grid run shapes for decoded live frames."""

from __future__ import annotations

import argparse
import importlib.util
import sys
from collections import Counter
from pathlib import Path


def load_model():
    path = Path(__file__).with_name("model-grid-route.py")
    spec = importlib.util.spec_from_file_location("model_grid_route", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("frames", type=Path, help="decoded P3DLIVE frames CSV")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()
    model = load_model()
    counts: Counter[tuple[str, int]] = Counter()
    widths: Counter[tuple[str, int, int]] = Counter()

    for camera in model.load_live_frames(args.frames):
        for far_x, near_x in model.projected_pairs(camera):
            out0 = model.x_outcode(far_x)
            out1 = model.x_outcode(near_x)
            if out0 & out1 or (out0 == 0 and out1 == 0):
                continue
            lines = (
                ("floor", model.clip_line_x(far_x, 127, near_x, 238)),
                ("ceiling", model.clip_line_x(far_x, 113, near_x, 2)),
            )
            for kind, line in lines:
                if line is None:
                    raise AssertionError("retained line clipped away")
                x0, y0, x1, y1 = line
                dx = abs(x1 - x0)
                dy = abs(y1 - y0)
                counts[kind, dy] += 1
                widths[kind, dy, dx] += 1

    total = sum(widths.values())
    flat = sum(frequency for (_, dy, _), frequency in widths.items() if dy == 0)
    print(f"clipped rasters: {total}; flat: {flat}")
    for ratio in (3, 4, 6, 8, 10, 12, 16):
        selected = [
            (dx, dy, frequency)
            for (_, dy, dx), frequency in widths.items()
            if dy and dx >= ratio * dy
        ]
        lines = sum(frequency for _, _, frequency in selected)
        pixels = sum((dx + 1) * frequency for dx, _, frequency in selected)
        runs = sum((dy + 1) * frequency for _, dy, frequency in selected)
        repeated_divides = sum((dx // dy) * frequency for dx, dy, frequency in selected)
        print(
            f"ratio {ratio:2d}: {lines:6d} lines ({lines / total:6.2%}), "
            f"{pixels:8d} pixels, {runs:7d} runs, "
            f"mean run={pixels / runs if runs else 0:5.2f}, "
            f"old divide loops={repeated_divides:7d}, "
            f"fixed9={9 * lines:7d}"
        )

    if args.verbose:
        for kind in ("floor", "ceiling"):
            print(kind)
            for (entry_kind, dy), count in sorted(counts.items()):
                if entry_kind != kind:
                    continue
                common = sorted(
                    (
                        (width, frequency)
                        for (k, d, width), frequency in widths.items()
                        if k == kind and d == dy
                    ),
                    key=lambda item: (-item[1], item[0]),
                )[:12]
                print(f"  dy={dy:3d}: {count:6d}; widths {common}")


if __name__ == "__main__":
    main()
