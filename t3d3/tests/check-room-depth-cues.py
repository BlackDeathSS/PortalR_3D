#!/usr/bin/env python3
"""Demonstrate why flat T3D3 rooms have weak absolute-scale cues."""

from __future__ import annotations


FOCAL_LENGTH = 42.0
VIEW_CENTER_Y = 30.0
PANEL_INTERVAL = 4.0
FACE_LIGHT_LEVEL = (3, 2, 3, 2, 2, 1)


def project(x: float, y: float, depth: float) -> tuple[float, float]:
    return (
        FOCAL_LENGTH * x / depth,
        VIEW_CENTER_Y - FOCAL_LENGTH * y / depth,
    )


def panel_rows(maximum_depth: float, camera_height: float) -> list[float]:
    rows = []
    depth = PANEL_INTERVAL
    while depth < maximum_depth:
        rows.append(VIEW_CENTER_Y + FOCAL_LENGTH * camera_height / depth)
        depth += PANEL_INTERVAL
    return rows


def distance_light(depth: float) -> int:
    if depth <= 8.0:
        return 3
    if depth <= 16.0:
        return 2
    if depth <= 24.0:
        return 1
    return 0


def current_room_light(face_offset: int) -> int:
    """Mirror the renderer's orientation-only room-face light lookup."""
    return FACE_LIGHT_LEVEL[face_offset]


def depth_cued_room_light(face_offset: int, depth: float) -> int:
    """Mirror the implemented distance cap on a room wall's authored light."""
    return min(current_room_light(face_offset), distance_light(depth))


def main() -> None:
    small_points = [
        (-4.0, -1.5, 8.0),
        (4.0, -1.5, 8.0),
        (4.0, 3.5, 8.0),
        (-4.0, 3.5, 8.0),
    ]
    scale = 3.0
    large_points = [
        (x * scale, y * scale, depth * scale)
        for x, y, depth in small_points
    ]
    small_projection = [project(*point) for point in small_points]
    large_projection = [project(*point) for point in large_points]

    assert small_projection == large_projection

    # T3D3's room-face light is selected from face orientation. It therefore
    # stays unchanged when only the room's absolute scale changes. Its current
    # floor/ceiling horizon bands are also screen-row based, and proportional
    # rooms produce the same projected rows as shown above.
    small_wall_light = current_room_light(2)
    large_wall_light = current_room_light(2)
    assert small_wall_light == large_wall_light

    small_panels = panel_rows(8.0, 1.5)
    large_panels = panel_rows(24.0, 1.5)
    assert len(large_panels) > len(small_panels)
    near_wall_light = depth_cued_room_light(2, 8.0)
    far_wall_light = depth_cued_room_light(2, 24.0)
    assert near_wall_light != far_wall_light

    print("scaled solid-room projection: identical")
    print(f"current wall light: {small_wall_light} at both depths")
    print(
        "4-unit floor panel seams: "
        f"{len(small_panels)} in an 8-unit view, "
        f"{len(large_panels)} in a 24-unit view"
    )
    print(
        "depth-cued far-wall light: "
        f"{near_wall_light} at 8 units, "
        f"{far_wall_light} at 24 units"
    )
    print("room depth-cue diagnostic: PASS")


if __name__ == "__main__":
    main()
