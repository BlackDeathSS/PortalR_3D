#!/usr/bin/env python3
"""Decode a T3DFPS runtime report from an AppVar, payload, or CEmu RAM dump."""

from __future__ import annotations

import argparse
import json
import math
import struct
from pathlib import Path
from typing import Sequence

import t3d2_format as fmt


HEADER = struct.Struct("<8sBBHIIIIIIIIIiiiHBBHHI")
HEADER_V2 = struct.Struct("<8sBBHIIIIIIIIIiiiHBBHHHHHHHHBBBBIIII")
MAGIC = b"T3DFPS1\0"
CRC_OFFSET = HEADER.size - 4


def _validated_candidate(candidate: bytes) -> tuple[tuple[object, ...], list[int]]:
    if len(candidate) < HEADER.size:
        raise ValueError("runtime report is truncated")
    version = candidate[8]
    layout = HEADER if version == 1 else HEADER_V2 if version == 2 else None
    if layout is None or len(candidate) < layout.size:
        raise ValueError("unsupported runtime report signature/version")
    values = layout.unpack_from(candidate)
    if values[0] != MAGIC or values[3] != layout.size:
        raise ValueError("unsupported runtime report signature/version")
    sample_count = int(values[19])
    expected_size = layout.size + sample_count * 3
    if len(candidate) != expected_size or sample_count > int(values[20]):
        raise ValueError("runtime report sample length is invalid")
    zeroed = bytearray(candidate)
    crc_offset = layout.size - 4
    stored_crc = struct.unpack_from("<I", zeroed, crc_offset)[0]
    struct.pack_into("<I", zeroed, crc_offset, 0)
    if stored_crc != fmt.crc32(zeroed):
        raise ValueError("runtime report CRC mismatch")
    samples = [int.from_bytes(candidate[layout.size + index * 3:
                                       layout.size + index * 3 + 3], "little")
               for index in range(sample_count)]
    return values, samples


def extract_report(blob: bytes) -> tuple[tuple[object, ...], list[int]]:
    if blob.startswith(fmt.TI_SIGNATURE):
        _, blob = fmt.unwrap_appvar(blob, "T3DFPS")
        return _validated_candidate(blob)
    try:
        return _validated_candidate(blob)
    except ValueError:
        pass
    offset = 0
    while True:
        offset = blob.find(MAGIC, offset)
        if offset < 0:
            raise ValueError("no CRC-valid T3DFPS report found")
        if offset + HEADER.size <= len(blob):
            header_size = struct.unpack_from("<H", blob, offset + 10)[0]
            sample_count = struct.unpack_from("<H", blob, offset + 64)[0]
            size = header_size + sample_count * 3
            if offset + size <= len(blob):
                try:
                    return _validated_candidate(blob[offset:offset + size])
                except ValueError:
                    pass
        offset += 1


def decode(path: Path) -> dict[str, object]:
    values, samples = extract_report(path.read_bytes())
    clock_rate = int(values[5])
    frame_count = int(values[6])
    wall_ticks = int(values[7])
    if clock_rate <= 0 or frame_count <= 0 or wall_ticks <= 0 or not samples:
        raise ValueError("runtime report contains no measurable frames")
    ordered = sorted(samples)
    mean_ticks = sum(samples) / len(samples)
    median_ticks = (ordered[(len(ordered) - 1) // 2] + ordered[len(ordered) // 2]) / 2
    slow_count = max(1, math.ceil(len(samples) * 0.01))
    slow_mean = sum(ordered[-slow_count:]) / slow_count
    p99_ticks = ordered[min(len(ordered) - 1, math.ceil(len(ordered) * 0.99) - 1)]
    capacity_average = clock_rate / mean_ticks
    one_percent_low = clock_rate / slow_mean
    flags = int(values[2])
    result: dict[str, object] = {
        "format": f"T3D2 runtime performance report v{int(values[1])}",
        "build_version": f"0x{int(values[4]):08X}",
        "scene_loaded": bool(flags & 1),
        "autotest": bool(flags & 2),
        "frames": frame_count,
        "sampled_frames": len(samples),
        "wall_seconds": wall_ticks / clock_rate,
        "wall_fps": frame_count * clock_rate / wall_ticks,
        "render_capacity_fps": {
            "average": capacity_average,
            "median": clock_rate / median_ticks,
            "one_percent_low": one_percent_low,
        },
        "frame_ms": {
            "mean": mean_ticks * 1000 / clock_rate,
            "median": median_ticks * 1000 / clock_rate,
            "p99": p99_ticks * 1000 / clock_rate,
            "maximum": ordered[-1] * 1000 / clock_rate,
        },
        "phase_ms_per_frame": {
            "update": int(values[9]) * 1000 / clock_rate / frame_count,
            "raster_and_portals": int(values[10]) * 1000 / clock_rate / frame_count,
            "present": int(values[11]) * 1000 / clock_rate / frame_count,
        },
        "logical_hash": f"0x{int(values[12]):08X}",
        "player": {
            "position": [int(values[13]) / 256.0, int(values[14]) / 256.0,
                         int(values[15]) / 256.0],
            "cell": int(values[16]),
            "yaw": int(values[17]),
        },
        "portals": {
            "orange_active": bool(int(values[18]) & 1),
            "blue_active": bool(int(values[18]) & 2),
            "linked": bool(int(values[18]) & 4),
        },
        "contract": {
            "average_at_least_30": capacity_average >= 30.0,
            "one_percent_low_at_least_25": one_percent_low >= 25.0,
            "p99_at_most_40_ms": p99_ticks * 1000 / clock_rate <= 40.0,
        },
    }
    if int(values[1]) >= 2:
        result["renderer_work"] = {
            "submitted_triangles": [int(values[index]) for index in range(21, 24)],
            "shaded_samples": [int(values[index]) for index in range(24, 27)],
            "dropped_meshlets": [int(values[index]) for index in range(27, 30)],
            "phase_ms_per_frame": {
                "visibility_and_clear": int(values[31]) * 1000 / clock_rate / frame_count,
                "transform": int(values[32]) * 1000 / clock_rate / frame_count,
                "triangles": int(values[33]) * 1000 / clock_rate / frame_count,
            },
        }
    return result


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    arguments = parser.parse_args(argv)
    try:
        report = decode(arguments.report)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
