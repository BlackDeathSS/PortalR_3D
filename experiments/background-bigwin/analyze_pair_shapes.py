from __future__ import annotations

import csv
import importlib.util
import sys
from collections import Counter
from pathlib import Path


model_path = Path(__file__).resolve().parents[2] / "tools" / "model-grid-route.py"
spec = importlib.util.spec_from_file_location("grid_model", model_path)
assert spec is not None and spec.loader is not None
model = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = model
spec.loader.exec_module(model)


def cameras(path: Path):
    with path.open(newline="", encoding="utf-8") as source:
        for row in csv.DictReader(source):
            yield model.Camera(
                int(row["player_x_raw"]),
                int(row["player_y_raw"]),
                int(row["angle_raw"]),
            )


def qualifies(dx: int, dy: int) -> bool:
    return dy > 0 and dx >= 256 and dx >= 16 * dy


def summarize(label, camera_values):
    counts = Counter()
    pixels = Counter()
    for camera in camera_values:
        add_camera(camera, counts, pixels)
    print(label)
    for kind, count in counts.most_common():
        print(kind, count, f"{count / len(camera_values):.3f}/frame", pixels[kind], "pixels")


def add_camera(camera, counts, pixels):
    for far_x, near_x in model.projected_pairs(camera):
        out0 = model.x_outcode(far_x)
        out1 = model.x_outcode(near_x)
        if out0 & out1 or (out0 == 0 and out1 == 0):
            continue
        floor = model.clip_line_x(far_x, 127, near_x, 238)
        ceiling = model.clip_line_x(far_x, 113, near_x, 2)
        assert floor is not None and ceiling is not None
        dx = abs(floor[2] - floor[0])
        fdy = abs(floor[3] - floor[1])
        cdy = abs(ceiling[3] - ceiling[1])
        ffast = qualifies(dx, fdy)
        cfast = qualifies(dx, cdy)
        major = ("H" if dx > fdy else "V") + ("H" if dx > cdy else "V")
        kind = f"{major}:{int(ffast)}{int(cfast)}"
        counts[kind] += 1
        pixels[kind] += 2 * (dx + 1)


live_cameras = list(cameras(
    Path(__file__).resolve().parents[2]
    / "benchmark-results"
    / "grid-fixed9-ratio16-dx256-lazypatch-live"
    / "lazy-live-frames.csv"
))
summarize("live", live_cameras)
for index, camera in enumerate(model.STATIC_CAMERAS):
    summarize(f"static {index}", [camera])
