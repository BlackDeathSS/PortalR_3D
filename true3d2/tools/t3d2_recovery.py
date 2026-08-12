#!/usr/bin/env python3
"""Create, inspect, and extract True3D2 journaled RAM backup chunks."""

from __future__ import annotations

import argparse
import json
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

import t3d2_format as fmt


JOURNAL = struct.Struct("<8sBBBBIII5I5II")
MAGIC = b"T3DBK1\0\0"
VERSION = 1
CHUNK_COUNT = 5
STATE_WRITING = 1
STATE_VERIFIED = 2
STATE_TAKEOVER = 3
STATE_RESTORING = 4
STATE_RESTORED = 5
STATE_NAMES = {
    STATE_WRITING: "writing",
    STATE_VERIFIED: "verified",
    STATE_TAKEOVER: "takeover",
    STATE_RESTORING: "restoring",
    STATE_RESTORED: "restored",
}


@dataclass(frozen=True)
class BackupJournal:
    state: int
    flags: int
    generation: int
    ram_size: int
    ram_crc32: int
    chunk_sizes: tuple[int, int, int, int, int]
    chunk_crc32: tuple[int, int, int, int, int]

    def packed(self) -> bytes:
        if self.state not in STATE_NAMES:
            raise ValueError("invalid journal state")
        raw = bytearray(JOURNAL.pack(
            MAGIC, VERSION, self.state, CHUNK_COUNT, self.flags,
            self.generation, self.ram_size, self.ram_crc32,
            *self.chunk_sizes, *self.chunk_crc32, 0,
        ))
        struct.pack_into("<I", raw, len(raw) - 4, fmt.crc32(raw[:-4]))
        return bytes(raw)

    @classmethod
    def unpacked(cls, raw: bytes) -> "BackupJournal":
        if len(raw) != JOURNAL.size:
            raise ValueError(f"journal is {len(raw)} bytes, expected {JOURNAL.size}")
        values = JOURNAL.unpack(raw)
        if values[0] != MAGIC or values[1] != VERSION or values[3] != CHUNK_COUNT:
            raise ValueError("unsupported backup journal signature/version")
        if values[-1] != fmt.crc32(raw[:-4]):
            raise ValueError("backup journal CRC mismatch")
        journal = cls(values[2], values[4], values[5], values[6], values[7],
                      tuple(values[8:13]), tuple(values[13:18]))
        if sum(journal.chunk_sizes) != journal.ram_size:
            raise ValueError("backup chunk sizes do not equal RAM size")
        if journal.state not in STATE_NAMES:
            raise ValueError("unknown backup journal state")
        return journal

    @property
    def recovery_action(self) -> str:
        if self.state == STATE_WRITING:
            return "discard-incomplete"
        if self.state in (STATE_VERIFIED, STATE_TAKEOVER, STATE_RESTORING):
            return "extract-or-restore"
        return "cleanup-completed"


def split_snapshot(snapshot: bytes) -> list[bytes]:
    chunk_size = (len(snapshot) + CHUNK_COUNT - 1) // CHUNK_COUNT
    return [snapshot[index * chunk_size:(index + 1) * chunk_size]
            for index in range(CHUNK_COUNT)]


def make_backup(snapshot: bytes, generation: int,
                state: int = STATE_VERIFIED) -> tuple[BackupJournal, list[bytes]]:
    if not snapshot:
        raise ValueError("RAM snapshot cannot be empty")
    chunks = split_snapshot(snapshot)
    journal = BackupJournal(
        state=state,
        flags=0,
        generation=generation & 0xFFFFFFFF,
        ram_size=len(snapshot),
        ram_crc32=fmt.crc32(snapshot),
        chunk_sizes=tuple(map(len, chunks)),
        chunk_crc32=tuple(fmt.crc32(chunk) for chunk in chunks),
    )
    return journal, chunks


def verify_chunks(journal: BackupJournal, chunks: Sequence[bytes]) -> bytes:
    if len(chunks) != CHUNK_COUNT:
        raise ValueError(f"backup needs exactly {CHUNK_COUNT} chunks")
    for index, chunk in enumerate(chunks):
        if len(chunk) != journal.chunk_sizes[index]:
            raise ValueError(f"backup chunk {index} size mismatch")
        if fmt.crc32(chunk) != journal.chunk_crc32[index]:
            raise ValueError(f"backup chunk {index} CRC mismatch")
    snapshot = b"".join(chunks)
    if len(snapshot) != journal.ram_size or fmt.crc32(snapshot) != journal.ram_crc32:
        raise ValueError("reassembled RAM snapshot CRC mismatch")
    return snapshot


def load_backup(directory: Path) -> tuple[BackupJournal, bytes]:
    _, journal_raw = fmt.unwrap_appvar((directory / "T3DBKM.8xv").read_bytes(), "T3DBKM")
    journal = BackupJournal.unpacked(journal_raw)
    chunks = []
    for index in range(CHUNK_COUNT):
        _, chunk = fmt.unwrap_appvar((directory / f"T3DBK{index}.8xv").read_bytes(),
                                     f"T3DBK{index}")
        chunks.append(chunk)
    return journal, verify_chunks(journal, chunks)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path, help="directory containing T3DBKM/T3DBK0..4 .8xv files")
    parser.add_argument("--extract", type=Path, help="write the verified raw snapshot")
    arguments = parser.parse_args(argv)
    try:
        journal, snapshot = load_backup(arguments.directory)
        if arguments.extract is not None:
            arguments.extract.write_bytes(snapshot)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(json.dumps({
        "format": "T3D2 backup journal v1",
        "state": STATE_NAMES[journal.state],
        "recovery_action": journal.recovery_action,
        "generation": journal.generation,
        "ram_size": journal.ram_size,
        "ram_crc32": f"0x{journal.ram_crc32:08X}",
        "chunks_verified": CHUNK_COUNT,
        "extracted": str(arguments.extract) if arguments.extract else None,
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
