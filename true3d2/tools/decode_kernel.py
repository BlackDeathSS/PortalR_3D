#!/usr/bin/env python3
"""Decode and verify a T3DKERN AppVar produced by the hardware kernel gate."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path
from typing import Sequence

import t3d2_format as fmt


REPORT = struct.Struct("<8sBBHIIHHHHIIIIII")
MAGIC = b"T3DKRN1\0"


def _validated_candidate(blob: bytes) -> tuple[object, ...]:
    if len(blob) != REPORT.size:
        raise ValueError(f"kernel report is {len(blob)} bytes, expected {REPORT.size}")
    values = REPORT.unpack(blob)
    if values[0] != MAGIC or values[1] != 1 or values[3] != REPORT.size:
        raise ValueError("unsupported kernel report signature/version")
    if values[-1] != fmt.crc32(blob[:-4]):
        raise ValueError("kernel report CRC mismatch")
    return values


def extract_report(blob: bytes) -> tuple[object, ...]:
    if blob.startswith(fmt.TI_SIGNATURE):
        _, blob = fmt.unwrap_appvar(blob, "T3DKERN")
        return _validated_candidate(blob)
    try:
        return _validated_candidate(blob)
    except ValueError:
        pass
    offset = 0
    while True:
        offset = blob.find(MAGIC, offset)
        if offset < 0:
            raise ValueError("no CRC-valid T3DKERN report found")
        if offset + REPORT.size <= len(blob):
            try:
                return _validated_candidate(blob[offset:offset + REPORT.size])
            except ValueError:
                pass
        offset += 1


def decode(path: Path) -> dict[str, object]:
    values = extract_report(path.read_bytes())
    clock_rate = values[5]
    if clock_rate == 0:
        raise ValueError("kernel report clock rate is zero")
    flags = values[2]
    presenter_iterations = values[6]
    presenter_ms = values[10] * 1000.0 / clock_rate / presenter_iterations
    raster_ms = values[11] * 1000.0 / clock_rate
    geometry_ms = values[12] * 1000.0 / clock_rate
    return {
        "format": "T3D2 kernel gate report v1",
        "build_version": f"0x{values[4]:08X}",
        "clock_rate": clock_rate,
        "presenter": {"milliseconds": presenter_ms, "limit": 12.5,
                      "pass": bool(flags & 1)},
        "raster": {"milliseconds": raster_ms, "limit": 8.0,
                   "samples": values[7], "pass": bool(flags & 2)},
        "span_only": {"milliseconds": values[9] * 1000.0 / clock_rate,
                      "samples": 4800},
        "geometry": {"milliseconds": geometry_ms, "limit": 4.0,
                     "triangles": values[8], "pass": bool(flags & 4)},
        "all_gates_pass": flags == 7,
        "presenter_hash": f"0x{values[13]:08X}",
        "raster_hash": f"0x{values[14]:08X}",
    }


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    arguments = parser.parse_args(argv)
    try:
        report = decode(arguments.report)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))
    return 0 if report["all_gates_pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
