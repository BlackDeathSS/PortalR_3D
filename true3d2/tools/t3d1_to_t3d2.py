#!/usr/bin/env python3
"""Convert a packed T3D1 box-room level into T3D2 JSON plus OBJ assets."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path
from typing import Sequence

import t3d2_format as fmt


HEADER = struct.Struct("<4sBBBBhhhBBhhhBBhhh")
ROOM = struct.Struct("<hhhhhh6B")
FACE_VERTICES = (
    (0, 1, 2, 3),
    (4, 7, 6, 5),
    (0, 4, 5, 1),
    (3, 2, 6, 7),
    (0, 3, 7, 4),
    (1, 5, 6, 2),
)


def q8(value: int) -> float:
    return value / 256.0


def raw_payload(path: Path) -> bytes:
    blob = path.read_bytes()
    if blob.startswith(fmt.TI_SIGNATURE):
        name, blob = fmt.unwrap_appvar(blob)
        if name != "T3DLVL1":
            raise ValueError(f"expected T3DLVL1 AppVar, got {name}")
    return blob


def face_polygon(room: dict[str, object], face: int) -> list[list[float]]:
    minimum = room["min"]
    maximum = room["max"]
    vertices = (
        (minimum[0], minimum[1], minimum[2]),
        (maximum[0], minimum[1], minimum[2]),
        (maximum[0], maximum[1], minimum[2]),
        (minimum[0], maximum[1], minimum[2]),
        (minimum[0], minimum[1], maximum[2]),
        (maximum[0], minimum[1], maximum[2]),
        (maximum[0], maximum[1], maximum[2]),
        (minimum[0], maximum[1], maximum[2]),
    )
    return [list(vertices[index]) for index in FACE_VERTICES[face]]


def shared_gateway(first: dict[str, object], second: dict[str, object]) -> list[list[float]] | None:
    first_min, first_max = first["min"], first["max"]
    second_min, second_max = second["min"], second["max"]
    for axis in range(3):
        if abs(first_max[axis] - second_min[axis]) < 1e-7:
            plane = first_max[axis]
        elif abs(second_max[axis] - first_min[axis]) < 1e-7:
            plane = first_min[axis]
        else:
            continue
        other = [candidate for candidate in range(3) if candidate != axis]
        lower = [max(first_min[candidate], second_min[candidate]) for candidate in other]
        upper = [min(first_max[candidate], second_max[candidate]) for candidate in other]
        if lower[0] >= upper[0] or lower[1] >= upper[1]:
            continue
        points = []
        for one, two in ((lower[0], lower[1]), (upper[0], lower[1]),
                         (upper[0], upper[1]), (lower[0], upper[1])):
            point = [0.0, 0.0, 0.0]
            point[axis] = plane
            point[other[0]] = one
            point[other[1]] = two
            points.append(point)
        return points
    return None


def room_obj(room: dict[str, object], room_index: int) -> str:
    minimum, maximum = room["min"], room["max"]
    vertices = (
        (minimum[0], minimum[1], minimum[2]),
        (maximum[0], minimum[1], minimum[2]),
        (maximum[0], maximum[1], minimum[2]),
        (minimum[0], maximum[1], minimum[2]),
        (minimum[0], minimum[1], maximum[2]),
        (maximum[0], minimum[1], maximum[2]),
        (maximum[0], maximum[1], maximum[2]),
        (minimum[0], maximum[1], maximum[2]),
    )
    lines = [f"o legacy_room_{room_index}"]
    lines.extend(f"v {x:g} {y:g} {z:g}" for x, y, z in vertices)
    lines.extend(("vt 0 0", "vt 1 0", "vt 1 1", "vt 0 1"))
    for face, indices in enumerate(FACE_VERTICES):
        lines.append(f"usemtl legacy_{room['colors'][face]}")
        lines.append("f " + " ".join(
            f"{vertex + 1}/{corner + 1}" for corner, vertex in enumerate(indices)
        ))
    return "\n".join(lines) + "\n"


def convert(source: Path, output: Path) -> Path:
    payload = raw_payload(source)
    if len(payload) < HEADER.size:
        raise ValueError("T3D1 payload is truncated")
    fields = HEADER.unpack_from(payload)
    if fields[0] != b"T3D1" or fields[1] != 1:
        raise ValueError("not a supported T3D1 level")
    room_count = fields[2]
    spawn_room = fields[3]
    portal_mask = fields[4]
    if not 1 <= room_count <= 8 or spawn_room >= room_count or \
       len(payload) != HEADER.size + room_count * ROOM.size:
        raise ValueError("invalid T3D1 room count or payload size")
    portal_values = (
        {"room": fields[8], "face": fields[9],
         "center": [q8(fields[10]), q8(fields[11]), q8(fields[12])]},
        {"room": fields[13], "face": fields[14],
         "center": [q8(fields[15]), q8(fields[16]), q8(fields[17])]},
    )
    rooms = []
    for index in range(room_count):
        values = ROOM.unpack_from(payload, HEADER.size + index * ROOM.size)
        minimum = [q8(values[0]), q8(values[2]), q8(values[4])]
        maximum = [q8(values[1]), q8(values[3]), q8(values[5])]
        if any(minimum[axis] >= maximum[axis] for axis in range(3)):
            raise ValueError(f"T3D1 room {index} has invalid bounds")
        rooms.append({"name": f"room_{index}", "min": minimum, "max": maximum,
                      "colors": list(values[6:12])})

    output.mkdir(parents=True, exist_ok=True)
    meshes = []
    used_colors = sorted({color for room in rooms for color in room["colors"]})
    for index, room in enumerate(rooms):
        obj_name = f"room_{index:02d}.obj"
        (output / obj_name).write_text(room_obj(room, index), encoding="utf-8")
        meshes.append({"obj": obj_name, "cell": room["name"], "priority": 255,
                       "essential": True, "affine_max_edge": 2.0})
    gateways = []
    for first in range(room_count):
        for second in range(first + 1, room_count):
            vertices = shared_gateway(rooms[first], rooms[second])
            if vertices is not None:
                gateways.append({"source": rooms[first]["name"],
                                 "destination": rooms[second]["name"],
                                 "two_way": True, "vertices": vertices})
    portal_surfaces = [
        {"cell": room["name"], "placeable": True,
         "vertices": face_polygon(room, face)}
        for room in rooms for face in range(6)
    ]
    manifest = {
        "format": "T3D2 scene v1",
        "source": {"format": "T3D1", "path": str(source)},
        "spawn": {"cell": rooms[spawn_room]["name"],
                  "position": [q8(fields[5]), q8(fields[6]), q8(fields[7])]},
        "cells": [{key: room[key] for key in ("name", "min", "max")} for room in rooms],
        "gateways": gateways,
        "portal_surfaces": portal_surfaces,
        "materials": [{"name": f"legacy_{color}", "shade": 3} for color in used_colors],
        "meshes": meshes,
        "legacy_initial_portals": [
            {**portal, "active": bool(portal_mask & (1 << index))}
            for index, portal in enumerate(portal_values)
        ],
    }
    manifest_path = output / "scene.t3d2.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return manifest_path


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", "-o", type=Path, required=True)
    arguments = parser.parse_args(argv)
    try:
        manifest = convert(arguments.source.resolve(), arguments.output.resolve())
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
