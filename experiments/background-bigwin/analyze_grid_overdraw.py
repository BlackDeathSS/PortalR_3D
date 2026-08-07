from __future__ import annotations

import csv
import importlib.util
import sys
from pathlib import Path


root = Path(__file__).resolve().parents[2]


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


model = load("grid_model", root / "tools" / "model-grid-route.py")
check = load("grid_check", root / "tools" / "check-grid-clipped.py")


def live_cameras(path: Path):
    with path.open(newline="", encoding="utf-8") as source:
        for row in csv.DictReader(source):
            yield model.Camera(
                int(row["player_x_raw"]),
                int(row["player_y_raw"]),
                int(row["angle_raw"]),
            )


def frame_counts(camera):
    visits = 0
    pixels = set()
    retained = 0
    for far_x, near_x in model.projected_pairs(camera):
        floor = model.clip_line_x(far_x, 127, near_x, 238)
        ceiling = model.clip_line_x(far_x, 113, near_x, 2)
        if floor is None or ceiling is None:
            continue
        retained += 1
        for line in (floor, ceiling):
            line_pixels = check.graphx_line_noclip(*line)
            visits += len(line_pixels)
            pixels.update(line_pixels)
    return retained, visits, len(pixels)


def summarize(label, camera_values):
    values = [frame_counts(camera) for camera in camera_values]
    retained = sum(value[0] for value in values)
    visits = sum(value[1] for value in values)
    unique = sum(value[2] for value in values)
    print(
        label,
        f"lines={retained / len(values):.2f}/frame",
        f"visits={visits / len(values):.1f}/frame",
        f"unique={unique / len(values):.1f}/frame",
        f"overdraw={(visits - unique) / visits:.2%}",
    )


summarize("static", model.STATIC_CAMERAS)
for index, camera in enumerate(model.STATIC_CAMERAS):
    summarize(f"static-{index}", [camera])

frames = list(live_cameras(
    root
    / "benchmark-results"
    / "grid-fixed9-ratio16-dx256-lazypatch-live"
    / "lazy-live-frames.csv"
))
summarize("live", frames)
