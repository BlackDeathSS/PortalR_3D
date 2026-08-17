#!/usr/bin/env python3
"""Compare depth-cue benchmark RAM dumps without requiring visual hashes."""

from __future__ import annotations

import argparse
import struct
import zlib
from pathlib import Path


MAGIC = b"T3DLIV1\0"
HEADER_SIZE = 112
PROFILES = (
    (0, "no-body", "no-body"),
    (1, "root-four", "root-four"),
    (3, "dual-portal-four", "dual-portal-four"),
)


def u16(data: bytes, offset: int) -> int:
    return struct.unpack_from("<H", data, offset)[0]


def u32(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def report_from_dump(path: Path) -> bytes:
    dump = path.read_bytes()
    matches: list[bytes] = []
    start = 0
    while True:
        offset = dump.find(MAGIC, start)
        if offset < 0:
            break
        if offset + HEADER_SIZE <= len(dump):
            size = u16(dump, offset + 32)
            end = offset + size
            if size >= HEADER_SIZE and end <= len(dump):
                report = dump[offset:end]
                if zlib.crc32(report[HEADER_SIZE:]) & 0xFFFFFFFF == u32(report, 60):
                    matches.append(report)
        start = offset + 1
    unique = list(dict.fromkeys(matches))
    if len(unique) != 1:
        raise ValueError(f"{path}: expected one CRC-valid report, found {len(unique)}")
    return unique[0]


def metrics(path: Path) -> dict[str, int]:
    report = report_from_dump(path)
    return {
        "clock_hz": u32(report, 16),
        "frames": u16(report, 38),
        "ticks": u32(report, 72),
        "state_hash": u32(report, 76),
        "profile": report[102],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--maximum-regression", type=float, default=5.0)
    args = parser.parse_args()
    failed = False

    print("profile             baseline FPS  candidate FPS  regression")
    for profile_index, label, filename in PROFILES:
        baseline = metrics(args.baseline / f"baseline-{filename}-ram.bin")
        candidate = metrics(args.candidate / f"candidate-{filename}-ram.bin")
        if baseline["profile"] != profile_index or candidate["profile"] != profile_index:
            raise ValueError(f"{label}: benchmark profile does not match its filename")
        baseline_fps = baseline["clock_hz"] * baseline["frames"] / baseline["ticks"]
        candidate_fps = candidate["clock_hz"] * candidate["frames"] / candidate["ticks"]
        regression = (candidate["ticks"] / baseline["ticks"] - 1.0) * 100.0
        same_state = baseline["state_hash"] == candidate["state_hash"]
        print(
            f"{label:<19} {baseline_fps:>10.2f}  {candidate_fps:>13.2f}  "
            f"{regression:>+9.2f}%"
        )
        if regression > args.maximum_regression or not same_state:
            failed = True
            if not same_state:
                print(f"  FAIL: simulation state hash changed for {label}")

    if failed:
        print(f"depth-cue benchmark: FAIL (limit {args.maximum_regression:.2f}%)")
        return 1
    print(f"depth-cue benchmark: PASS (limit {args.maximum_regression:.2f}%)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
