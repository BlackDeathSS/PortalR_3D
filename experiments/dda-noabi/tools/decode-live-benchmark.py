#!/usr/bin/env python3
"""Decode PortalR's deterministic live-gameplay benchmark result.

The calculator writes a compact P3DLIV1 payload to the P3DLIVE AppVar.  This
tool accepts the raw payload, a transferred TI .8xv file, raw AppVar data, or a
CEmu RAM dump containing one unique CRC-valid payload.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import statistics
import struct
import sys
import tempfile
import zlib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable, Sequence


MAGIC = b"P3DLIV1\0"
FORMAT_VERSION = 1
HEADER_SIZE = 96
SECTION_RECORD_SIZE = 84
FRAME_RECORD_SIZE = 24
CATEGORY_COUNT = 7
APPVAR_TYPE = 0x15
TI_SIGNATURE_PREFIX = b"**TI83F*\x1a\x0a"
TI_SIGNATURE_REVISIONS = frozenset((0x00, 0x0A))

FLAG_FRAME_TIMINGS = 1 << 0
FLAG_FIXED_TIMESTEP = 1 << 1
FLAG_FULL_GAME_UPDATE = 1 << 2
FLAG_FULL_RENDER_SWAP = 1 << 3
FLAG_SECTION_TRACE = 1 << 4
FLAG_FRAME_HASHES = 1 << 5
FLAG_STARTUP_TIMING = 1 << 6
FLAG_DIAGNOSTICS_EXCLUDED = 1 << 7
FLAG_ARCHIVE_RESULT = 1 << 8
FLAG_DIAGNOSTIC_REPLAY = 1 << 9
KNOWN_HEADER_FLAGS = (
    FLAG_FRAME_TIMINGS
    | FLAG_FIXED_TIMESTEP
    | FLAG_FULL_GAME_UPDATE
    | FLAG_FULL_RENDER_SWAP
    | FLAG_SECTION_TRACE
    | FLAG_FRAME_HASHES
    | FLAG_STARTUP_TIMING
    | FLAG_DIAGNOSTICS_EXCLUDED
    | FLAG_ARCHIVE_RESULT
    | FLAG_DIAGNOSTIC_REPLAY
)

SECTION_FLAG_NAMES = (
    "small_room",
    "large_room",
    "slow_turn",
    "fast_turn",
    "portal_view",
    "portal_approach",
    "portal_cross",
    "stress",
)
KNOWN_SECTION_FLAGS = 0xFF

FRAME_CROSSED_PORTAL = 1 << 0
FRAME_DETAILED = 1 << 1
FRAME_CHANGED = 1 << 2
FRAME_SECTION_END = 1 << 3
KNOWN_FRAME_FLAGS = 0x0F

CATEGORY_NAMES = (
    "admin",
    "wait",
    "background",
    "dda",
    "portal_trace",
    "wall_draw",
    "portal_draw",
)
COUNTER_NAMES = (
    "portal_transforms",
    "wall_calls",
    "mask_calls",
    "portal_candidates",
    "linked_exits",
    "textured_rows",
    "dda_steps",
)


class DecodeError(ValueError):
    """Raised when a result fails structural or integrity validation."""


@dataclass(frozen=True)
class WrapperInfo:
    kind: str
    variable_name: str | None = None
    variable_type: int | None = None
    archived: bool | None = None
    comment: str | None = None
    wrapper_checksum: int | None = None
    dump_offset: int | None = None


@dataclass(frozen=True)
class Header:
    flags: int
    clock_hz: int
    trace_timer_hz: int
    build_fingerprint: int
    route_fingerprint: int
    report_size: int
    section_count: int
    warmup_frames: int
    frame_count: int
    section_record_size: int
    frame_record_size: int
    logical_columns: int
    column_width: int
    texture_size: int
    depth_limit: int
    category_count: int
    simulation_ticks_per_second: int
    elapsed_ticks_per_frame: int
    expected_crossings: int
    switch_cost_q8: int
    body_crc32: int
    graphics_init_ticks: int
    first_frame_ticks: int
    recorded_total_ticks: int
    route_state_hash: int
    final_frame_hash: int
    actual_crossings: int
    detailed_frames: int
    duplicate_report_size: int
    wall_ticks: int


@dataclass(frozen=True)
class Detail:
    raw_ticks: tuple[int, ...]
    entries: tuple[int, ...]
    portal_transforms: int
    wall_calls: int
    mask_calls: int
    portal_candidates: int
    linked_exits: int
    textured_rows: int
    dda_steps: int


@dataclass(frozen=True)
class Section:
    index: int
    section_id: int
    flags: int
    first_frame: int
    frame_count: int
    detailed_frame: int
    name: str
    frame_hash: int
    state_hash: int
    crossing_count: int
    detail: Detail

    @property
    def end_frame(self) -> int:
        return self.first_frame + self.frame_count

    @property
    def flag_names(self) -> tuple[str, ...]:
        return tuple(
            name
            for bit, name in enumerate(SECTION_FLAG_NAMES)
            if self.flags & (1 << bit)
        )


@dataclass(frozen=True)
class Frame:
    index: int
    total_ticks: int
    update_ticks: int
    render_ticks: int
    swap_ticks: int
    player_x_raw: int
    player_y_raw: int
    angle_raw: int
    casts: int
    max_depth: int
    section_id: int
    flags: int
    move_axis: int
    turn_axis: int

    @property
    def detailed(self) -> bool:
        return bool(self.flags & FRAME_DETAILED)

    @property
    def crossed_portal(self) -> bool:
        return bool(self.flags & FRAME_CROSSED_PORTAL)

    @property
    def changed(self) -> bool:
        return bool(self.flags & FRAME_CHANGED)

    @property
    def section_end(self) -> bool:
        return bool(self.flags & FRAME_SECTION_END)

    @property
    def player_x(self) -> float:
        return self.player_x_raw / 256.0

    @property
    def player_y(self) -> float:
        return self.player_y_raw / 256.0

    @property
    def angle_degrees(self) -> float:
        return self.angle_raw * 360.0 / (64.0 * 256.0)


@dataclass
class LiveReport:
    source: Path
    wrapper: WrapperInfo
    payload: bytes = field(repr=False)
    payload_sha256: str
    header: Header
    sections: list[Section]
    frames: list[Frame]
    warnings: list[str] = field(default_factory=list)

    def section_for_id(self, section_id: int) -> Section:
        if section_id < 1 or section_id > len(self.sections):
            raise DecodeError(f"invalid section ID {section_id}")
        return self.sections[section_id - 1]

    def frames_for_section(self, section: Section) -> list[Frame]:
        return self.frames[section.first_frame : section.end_frame]


def _u16(data: bytes, offset: int) -> int:
    return struct.unpack_from("<H", data, offset)[0]


def _u24(data: bytes, offset: int) -> int:
    return int.from_bytes(data[offset : offset + 3], "little")


def _u32(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def _s24(data: bytes, offset: int) -> int:
    value = _u24(data, offset)
    return value - (1 << 24) if value & (1 << 23) else value


def _hex32(value: int) -> str:
    return f"0x{value:08X}"


def _display_ascii(raw: bytes) -> str:
    return raw.split(b"\0", 1)[0].decode("ascii", errors="replace")


def _fnv1a(data_parts: Iterable[bytes]) -> int:
    value = 2166136261
    for part in data_parts:
        for byte in part:
            value ^= byte
            value = (value * 16777619) & 0xFFFFFFFF
    return value


def _candidate_payload(blob: bytes, offset: int) -> bytes | None:
    """Return a structurally plausible, CRC-valid payload at *offset*."""

    if offset < 0 or offset + HEADER_SIZE > len(blob):
        return None
    if blob[offset : offset + len(MAGIC)] != MAGIC:
        return None
    view = blob[offset:]
    if _u16(view, 8) != FORMAT_VERSION or _u16(view, 10) != HEADER_SIZE:
        return None
    report_size = _u16(view, 32)
    if report_size < HEADER_SIZE or report_size > len(view):
        return None
    section_count = _u16(view, 34)
    frame_count = _u16(view, 38)
    if (
        _u16(view, 40) != SECTION_RECORD_SIZE
        or _u16(view, 42) != FRAME_RECORD_SIZE
        or _u16(view, 88) != report_size
        or HEADER_SIZE
        + section_count * SECTION_RECORD_SIZE
        + frame_count * FRAME_RECORD_SIZE
        != report_size
    ):
        return None
    payload = bytes(view[:report_size])
    if (zlib.crc32(payload[HEADER_SIZE:]) & 0xFFFFFFFF) != _u32(payload, 60):
        return None
    return payload


def _extract_ti_appvar(blob: bytes) -> tuple[bytes, WrapperInfo]:
    if len(blob) < 55 + 19 + 2:
        raise DecodeError("TI variable file is truncated")
    if blob[:10] != TI_SIGNATURE_PREFIX or blob[10] not in TI_SIGNATURE_REVISIONS:
        raise DecodeError("unsupported or corrupt TI variable signature")

    section_size = _u16(blob, 53)
    expected_size = 55 + section_size + 2
    if len(blob) != expected_size:
        raise DecodeError(
            f"TI data-section length requires {expected_size} bytes, "
            f"found {len(blob)}"
        )
    section_start = 55
    section_end = section_start + section_size
    stored_checksum = _u16(blob, section_end)
    computed_checksum = sum(blob[section_start:section_end]) & 0xFFFF
    if stored_checksum != computed_checksum:
        raise DecodeError(
            "TI wrapper checksum mismatch: "
            f"stored 0x{stored_checksum:04X}, computed 0x{computed_checksum:04X}"
        )

    entry = blob[section_start:section_end]
    if len(entry) < 19 or _u16(entry, 0) != 13:
        raise DecodeError("unsupported TI variable entry header")
    variable_length = _u16(entry, 2)
    variable_type = entry[4]
    variable_name = _display_ascii(entry[5:13])
    archived = bool(entry[14] & 0x80)
    repeated_length = _u16(entry, 15)
    if repeated_length != variable_length:
        raise DecodeError("TI variable length fields disagree")
    if section_size != 17 + variable_length:
        raise DecodeError("TI data section is not exactly one variable")
    if variable_type != APPVAR_TYPE:
        raise DecodeError(
            f"TI variable {variable_name!r} is type 0x{variable_type:02X}, "
            f"not AppVar type 0x{APPVAR_TYPE:02X}"
        )
    if variable_length < 2:
        raise DecodeError("AppVar data is missing its inner length")
    inner_size = _u16(entry, 17)
    if variable_length != inner_size + 2:
        raise DecodeError("AppVar inner and outer lengths disagree")
    payload = bytes(entry[19 : 19 + inner_size])
    if len(payload) != inner_size:
        raise DecodeError("AppVar payload is truncated")

    comment = blob[11:53].split(b"\0", 1)[0].decode(
        "ascii", errors="replace"
    )
    return payload, WrapperInfo(
        kind="ti-appvar",
        variable_name=variable_name,
        variable_type=variable_type,
        archived=archived,
        comment=comment,
        wrapper_checksum=stored_checksum,
    )


def extract_payload(blob: bytes) -> tuple[bytes, WrapperInfo]:
    """Extract a P3DLIV1 payload from every supported container."""

    if blob.startswith(MAGIC) and len(blob) >= HEADER_SIZE:
        declared_size = _u16(blob, 32)
        if declared_size == len(blob):
            # Preserve precise parser diagnostics for a corrupt raw payload
            # instead of degrading them to the RAM scanner's "not found".
            return bytes(blob), WrapperInfo(kind="raw")

    if len(blob) >= 2 + HEADER_SIZE and blob[2 : 2 + len(MAGIC)] == MAGIC:
        inner_size = _u16(blob, 0)
        if inner_size == len(blob) - 2:
            payload = bytes(blob[2:])
            if _candidate_payload(payload, 0) is None:
                raise DecodeError("raw AppVar data contains an invalid payload")
            return payload, WrapperInfo(kind="raw-appvar-data")

    if blob.startswith(b"**TI83F*"):
        return _extract_ti_appvar(blob)

    valid: list[tuple[int, bytes]] = []
    start = 0
    while True:
        offset = blob.find(MAGIC, start)
        if offset < 0:
            break
        candidate = _candidate_payload(blob, offset)
        if candidate is not None:
            valid.append((offset, candidate))
        start = offset + 1

    if not valid:
        raise DecodeError(
            "input is not a raw/TI AppVar and contains no CRC-valid P3DLIV1 payload"
        )
    unique: dict[bytes, list[int]] = {}
    for offset, payload in valid:
        unique.setdefault(payload, []).append(offset)
    if len(unique) != 1:
        offsets = ", ".join(f"0x{offset:X}" for offset, _ in valid)
        raise DecodeError(
            f"RAM dump contains {len(unique)} distinct CRC-valid P3DLIV1 "
            f"payloads at {offsets}; expected one unique result"
        )
    payload, offsets = next(iter(unique.items()))
    return payload, WrapperInfo(
        kind="cemu-ram-dump", dump_offset=offsets[0]
    )


def parse_payload(
    payload: bytes, source: Path, wrapper: WrapperInfo
) -> LiveReport:
    if len(payload) < HEADER_SIZE:
        raise DecodeError(
            f"live payload is {len(payload)} bytes; at least {HEADER_SIZE} required"
        )
    if payload[:8] != MAGIC:
        raise DecodeError(f"unsupported magic {payload[:8]!r}; expected {MAGIC!r}")
    if _u16(payload, 8) != FORMAT_VERSION:
        raise DecodeError(
            f"unsupported P3DLIV version {_u16(payload, 8)}; "
            f"expected {FORMAT_VERSION}"
        )
    if _u16(payload, 10) != HEADER_SIZE:
        raise DecodeError(
            f"header size is {_u16(payload, 10)}; expected {HEADER_SIZE}"
        )

    header = Header(
        flags=_u32(payload, 12),
        clock_hz=_u32(payload, 16),
        trace_timer_hz=_u32(payload, 20),
        build_fingerprint=_u32(payload, 24),
        route_fingerprint=_u32(payload, 28),
        report_size=_u16(payload, 32),
        section_count=_u16(payload, 34),
        warmup_frames=_u16(payload, 36),
        frame_count=_u16(payload, 38),
        section_record_size=_u16(payload, 40),
        frame_record_size=_u16(payload, 42),
        logical_columns=_u16(payload, 44),
        column_width=payload[46],
        texture_size=payload[47],
        depth_limit=payload[48],
        category_count=payload[49],
        simulation_ticks_per_second=_u16(payload, 50),
        elapsed_ticks_per_frame=_u16(payload, 52),
        expected_crossings=_u16(payload, 54),
        switch_cost_q8=_u32(payload, 56),
        body_crc32=_u32(payload, 60),
        graphics_init_ticks=_u32(payload, 64),
        first_frame_ticks=_u32(payload, 68),
        recorded_total_ticks=_u32(payload, 72),
        route_state_hash=_u32(payload, 76),
        final_frame_hash=_u32(payload, 80),
        actual_crossings=_u16(payload, 84),
        detailed_frames=_u16(payload, 86),
        duplicate_report_size=_u16(payload, 88),
        wall_ticks=_u32(payload, 92),
    )

    if payload[7] != 0 or payload[90:92] != b"\0\0":
        raise DecodeError("non-zero reserved header bytes")
    if header.flags & ~KNOWN_HEADER_FLAGS:
        raise DecodeError(
            f"unknown header flags 0x{header.flags & ~KNOWN_HEADER_FLAGS:08X}"
        )
    if header.report_size != len(payload):
        raise DecodeError(
            f"header declares {header.report_size} bytes, found {len(payload)}"
        )
    if header.duplicate_report_size != header.report_size:
        raise DecodeError("duplicate report-size field disagrees")
    if header.section_record_size != SECTION_RECORD_SIZE:
        raise DecodeError(
            f"section record size is {header.section_record_size}; "
            f"expected {SECTION_RECORD_SIZE}"
        )
    if header.frame_record_size != FRAME_RECORD_SIZE:
        raise DecodeError(
            f"frame record size is {header.frame_record_size}; "
            f"expected {FRAME_RECORD_SIZE}"
        )
    if header.category_count != CATEGORY_COUNT:
        raise DecodeError(
            f"category count is {header.category_count}; expected {CATEGORY_COUNT}"
        )
    if (
        header.clock_hz == 0
        or header.trace_timer_hz == 0
        or header.simulation_ticks_per_second == 0
        or header.elapsed_ticks_per_frame == 0
        or header.section_count == 0
        or header.frame_count == 0
    ):
        raise DecodeError("zero count/frequency in required header field")
    expected_size = (
        HEADER_SIZE
        + header.section_count * SECTION_RECORD_SIZE
        + header.frame_count * FRAME_RECORD_SIZE
    )
    if expected_size != len(payload):
        raise DecodeError(
            f"record counts require {expected_size} bytes, found {len(payload)}"
        )
    computed_crc = zlib.crc32(payload[HEADER_SIZE:]) & 0xFFFFFFFF
    if computed_crc != header.body_crc32:
        raise DecodeError(
            "body CRC32 mismatch: "
            f"stored {_hex32(header.body_crc32)}, computed {_hex32(computed_crc)}"
        )

    sections: list[Section] = []
    for index in range(header.section_count):
        offset = HEADER_SIZE + index * SECTION_RECORD_SIZE
        record = payload[offset : offset + SECTION_RECORD_SIZE]
        if record[23] != 0 or record[45] != 0:
            raise DecodeError(f"section {index} has non-zero reserved bytes")
        detail = Detail(
            raw_ticks=tuple(_u24(record, 24 + category * 3)
                            for category in range(CATEGORY_COUNT)),
            entries=tuple(_u16(record, 46 + category * 2)
                          for category in range(CATEGORY_COUNT)),
            portal_transforms=_u16(record, 64),
            wall_calls=_u16(record, 66),
            mask_calls=_u16(record, 68),
            portal_candidates=_u16(record, 70),
            linked_exits=_u16(record, 72),
            textured_rows=_u16(record, 74),
            dda_steps=_u16(record, 76),
        )
        section = Section(
            index=index,
            section_id=record[0],
            flags=record[1],
            first_frame=_u16(record, 2),
            frame_count=_u16(record, 4),
            detailed_frame=_u16(record, 6),
            name=_display_ascii(record[8:24]),
            frame_hash=_u32(record, 60),
            state_hash=_u32(record, 78),
            crossing_count=_u16(record, 82),
            detail=detail,
        )
        if section.section_id != index + 1:
            raise DecodeError(
                f"section {index} has ID {section.section_id}; expected {index + 1}"
            )
        if section.flags & ~KNOWN_SECTION_FLAGS:
            raise DecodeError(f"section {index} has unknown flags")
        if not section.name:
            raise DecodeError(f"section {index} has an empty name")
        sections.append(section)

    frame_block = HEADER_SIZE + header.section_count * SECTION_RECORD_SIZE
    frames: list[Frame] = []
    route_parts: list[bytes] = []
    for index in range(header.frame_count):
        offset = frame_block + index * FRAME_RECORD_SIZE
        record = payload[offset : offset + FRAME_RECORD_SIZE]
        if record[22:24] != b"\0\0":
            raise DecodeError(f"frame {index} has non-zero reserved bytes")
        flags = record[20]
        if flags & ~KNOWN_FRAME_FLAGS:
            raise DecodeError(
                f"frame {index} has unknown flags 0x{flags & ~KNOWN_FRAME_FLAGS:02X}"
            )
        move_code = record[21] & 3
        turn_code = (record[21] >> 2) & 3
        if record[21] & 0xF0 or move_code == 3 or turn_code == 3:
            raise DecodeError(f"frame {index} has invalid packed input")
        frame = Frame(
            index=index,
            total_ticks=_u16(record, 0),
            update_ticks=_u16(record, 2),
            render_ticks=_u16(record, 4),
            swap_ticks=_u16(record, 6),
            player_x_raw=_s24(record, 8),
            player_y_raw=_s24(record, 11),
            angle_raw=_u16(record, 14),
            casts=_u16(record, 16),
            max_depth=record[18],
            section_id=record[19],
            flags=flags,
            move_axis=move_code - 1,
            turn_axis=turn_code - 1,
        )
        component_sum = (
            frame.update_ticks + frame.render_ticks + frame.swap_ticks
        )
        if frame.total_ticks != min(component_sum, 65535):
            raise DecodeError(
                f"frame {index} total {frame.total_ticks} does not match "
                f"clamped component sum {min(component_sum, 65535)}"
            )
        if frame.section_id < 1 or frame.section_id > header.section_count:
            raise DecodeError(f"frame {index} has invalid section ID")
        if frame.max_depth > header.depth_limit:
            raise DecodeError(
                f"frame {index} depth {frame.max_depth} exceeds limit "
                f"{header.depth_limit}"
            )
        frames.append(frame)
        route_parts.append(record[8:18])

    expected_first = 0
    detailed_count = 0
    crossing_count = 0
    for section in sections:
        if section.first_frame != expected_first:
            raise DecodeError(
                f"section {section.section_id} starts at {section.first_frame}; "
                f"expected contiguous frame {expected_first}"
            )
        if section.frame_count == 0 or section.end_frame > header.frame_count:
            raise DecodeError(f"section {section.section_id} has invalid frame range")
        section_frames = frames[section.first_frame : section.end_frame]
        if any(frame.section_id != section.section_id for frame in section_frames):
            raise DecodeError(
                f"frame section IDs disagree with section {section.section_id}"
            )
        section_detailed = [frame for frame in section_frames if frame.detailed]
        if len(section_detailed) != 1:
            raise DecodeError(
                f"section {section.section_id} has {len(section_detailed)} "
                "detailed frames; expected one"
            )
        if section.detailed_frame != section_detailed[0].index:
            raise DecodeError(
                f"section {section.section_id} detail record names frame "
                f"{section.detailed_frame}, but flag is on "
                f"{section_detailed[0].index}"
            )
        section_crossings = sum(frame.crossed_portal for frame in section_frames)
        if section_crossings != section.crossing_count:
            raise DecodeError(
                f"section {section.section_id} crossing count is "
                f"{section.crossing_count}, flags show {section_crossings}"
            )
        for frame in section_frames[:-1]:
            if frame.section_end:
                raise DecodeError(
                    f"frame {frame.index} prematurely marks section end"
                )
        if not section_frames[-1].section_end:
            raise DecodeError(
                f"section {section.section_id} final frame lacks section-end flag"
            )
        detailed_count += len(section_detailed)
        crossing_count += section_crossings
        expected_first = section.end_frame

    if expected_first != header.frame_count:
        raise DecodeError("section ranges do not cover every frame")
    if detailed_count != header.detailed_frames:
        raise DecodeError(
            f"header says {header.detailed_frames} detailed frames, found "
            f"{detailed_count}"
        )
    if crossing_count != header.actual_crossings:
        raise DecodeError(
            f"header says {header.actual_crossings} crossings, found "
            f"{crossing_count}"
        )
    if header.actual_crossings != header.expected_crossings:
        raise DecodeError(
            f"route expected {header.expected_crossings} crossings but recorded "
            f"{header.actual_crossings}"
        )
    computed_route_hash = _fnv1a(route_parts)
    if computed_route_hash != header.route_state_hash:
        raise DecodeError(
            "route-state hash mismatch: "
            f"stored {_hex32(header.route_state_hash)}, "
            f"computed {_hex32(computed_route_hash)}"
        )
    if sections[-1].frame_hash != header.final_frame_hash:
        raise DecodeError("final frame hash disagrees with final section hash")

    warnings: list[str] = []
    saturated = [frame.index for frame in frames if frame.total_ticks == 65535]
    if saturated:
        warnings.append(
            f"{len(saturated)} frame totals saturated at 65535 ticks; exact "
            "aggregate timing cannot be reconstructed"
        )
    elif sum(frame.total_ticks for frame in frames) != header.recorded_total_ticks:
        raise DecodeError(
            "header recorded-total ticks disagree with frame records"
        )
    if header.wall_ticks < header.recorded_total_ticks:
        warnings.append(
            "wall-clock route ticks are below summed phase ticks; inspect timer "
            "wrap or measurement overhead"
        )
    if header.detailed_frames != header.section_count:
        warnings.append(
            "detailed-frame count differs from section count"
        )
    if wrapper.kind == "ti-appvar" and wrapper.variable_name != "P3DLIVE":
        warnings.append(
            f"payload came from AppVar {wrapper.variable_name!r}, not 'P3DLIVE'"
        )

    return LiveReport(
        source=source,
        wrapper=wrapper,
        payload=payload,
        payload_sha256=hashlib.sha256(payload).hexdigest().upper(),
        header=header,
        sections=sections,
        frames=frames,
        warnings=warnings,
    )


def decode_file(path: Path) -> LiveReport:
    try:
        blob = path.read_bytes()
    except OSError as exc:
        raise DecodeError(f"cannot read {path}: {exc}") from exc
    payload, wrapper = extract_payload(blob)
    return parse_payload(payload, path.resolve(), wrapper)


def ticks_to_ms(ticks: float | int, hz: int) -> float:
    return float(ticks) * 1000.0 / hz


def timing_excluded_from_clean_stats(
    report: LiveReport, frame: Frame
) -> bool:
    """Whether this recorded frame timing contains inline fine tracing.

    P3DLIV1 originally captured the fine trace inside the timed route, so its
    DETAILED frame was instrumented and must be excluded. New producers replay
    the selected deterministic state after the clean timed pass; their DETAILED
    bit identifies the replay source frame but its stored frame timing is clean.
    """

    return frame.detailed and not (
        report.header.flags & FLAG_DIAGNOSTIC_REPLAY
    )


def clean_timing_frames(
    report: LiveReport, frames: Sequence[Frame] | None = None
) -> list[Frame]:
    source = report.frames if frames is None else frames
    return [
        frame
        for frame in source
        if not timing_excluded_from_clean_stats(report, frame)
    ]


def _metric(values: Sequence[float | int]) -> dict[str, float | int | None]:
    if not values:
        return {
            "count": 0,
            "min": None,
            "max": None,
            "mean": None,
            "median": None,
            "pstdev": None,
        }
    return {
        "count": len(values),
        "min": min(values),
        "max": max(values),
        "mean": statistics.fmean(values),
        "median": statistics.median(values),
        "pstdev": statistics.pstdev(values),
    }


def _low_fps(ticks: Sequence[int], hz: int, fraction: float) -> tuple[float, int]:
    count = max(1, math.ceil(len(ticks) * fraction))
    slowest = sorted(ticks, reverse=True)[:count]
    total = sum(slowest)
    return (count * hz / total if total else float("inf"), count)


def timing_summary(frames: Sequence[Frame], hz: int) -> dict[str, Any]:
    ticks = [frame.total_ticks for frame in frames]
    if not ticks:
        return {
            "frame_count": 0,
            "duration_ms": 0.0,
            "average_fps": None,
        }
    frame_ms = [ticks_to_ms(value, hz) for value in ticks]
    total_ticks = sum(ticks)
    low_1, low_1_count = _low_fps(ticks, hz, 0.01)
    low_01, low_01_count = _low_fps(ticks, hz, 0.001)
    median_ticks = statistics.median(ticks)
    spike_threshold_ticks = max(2.0 * median_ticks, hz / 30.0)
    return {
        "frame_count": len(frames),
        "total_ticks": total_ticks,
        "duration_ms": ticks_to_ms(total_ticks, hz),
        "frame_time_ms": _metric(frame_ms),
        "average_fps": len(frames) * hz / total_ticks
        if total_ticks else float("inf"),
        "minimum_fps": hz / max(ticks) if max(ticks) else float("inf"),
        "maximum_fps": hz / min(ticks) if min(ticks) else float("inf"),
        "one_percent_low_fps": low_1,
        "one_percent_low_frame_count": low_1_count,
        "point_one_percent_low_fps": low_01,
        "point_one_percent_low_frame_count": low_01_count,
        "spike_threshold_ms": ticks_to_ms(spike_threshold_ticks, hz),
        "spike_count": sum(value > spike_threshold_ticks for value in ticks),
        "over_33_333_ms": sum(value * 30 > hz for value in ticks),
        "over_50_ms": sum(value * 20 > hz for value in ticks),
        "over_100_ms": sum(value * 10 > hz for value in ticks),
        "over_twice_median": sum(value > 2.0 * median_ticks for value in ticks),
        "update_ms": _metric(
            [ticks_to_ms(frame.update_ticks, hz) for frame in frames]
        ),
        "render_ms": _metric(
            [ticks_to_ms(frame.render_ticks, hz) for frame in frames]
        ),
        "swap_ms": _metric(
            [ticks_to_ms(frame.swap_ticks, hz) for frame in frames]
        ),
    }


def corrected_detail(
    detail: Detail, switch_cost_q8: int, trace_hz: int
) -> dict[str, Any]:
    categories: dict[str, Any] = {}
    corrected_total = 0
    raw_total = 0
    for index, name in enumerate(CATEGORY_NAMES):
        raw = detail.raw_ticks[index]
        entries = detail.entries[index]
        overhead = (entries * switch_cost_q8 + 128) >> 8
        corrected = max(0, raw - overhead)
        raw_total += raw
        corrected_total += corrected
        categories[name] = {
            "raw_ticks": raw,
            "entries": entries,
            "overhead_ticks": overhead,
            "corrected_ticks": corrected,
            "corrected_ms": ticks_to_ms(corrected, trace_hz),
            "overhead_clamped": overhead > raw,
        }
    counters = {name: getattr(detail, name) for name in COUNTER_NAMES}
    return {
        "raw_total_ticks": raw_total,
        "raw_total_ms": ticks_to_ms(raw_total, trace_hz),
        "corrected_total_ticks": corrected_total,
        "corrected_total_ms": ticks_to_ms(corrected_total, trace_hz),
        "categories": categories,
        "counters": counters,
    }


def section_summary(report: LiveReport, section: Section) -> dict[str, Any]:
    frames = report.frames_for_section(section)
    clean = clean_timing_frames(report, frames)
    detailed_frame = report.frames[section.detailed_frame]
    clean_timing = timing_summary(clean, report.header.clock_hz)
    detail = corrected_detail(
        section.detail,
        report.header.switch_cost_q8,
        report.header.trace_timer_hz,
    )
    clean_mean = clean_timing.get("frame_time_ms", {}).get("mean")
    detailed_ms = ticks_to_ms(
        detailed_frame.total_ticks, report.header.clock_hz
    )
    diagnostic_replay = bool(
        report.header.flags & FLAG_DIAGNOSTIC_REPLAY
    )
    intrusion = (
        None
        if diagnostic_replay or clean_mean in (None, 0)
        else (detailed_ms / clean_mean - 1.0) * 100.0
    )
    return {
        "section_index": section.index,
        "section_id": section.section_id,
        "section_name": section.name,
        "section_flags": section.flags,
        "section_flag_names": list(section.flag_names),
        "first_frame": section.first_frame,
        "frame_count": section.frame_count,
        "clean_frame_count": len(clean),
        "detailed_frame": section.detailed_frame,
        "diagnostic_replay": diagnostic_replay,
        "detailed_frame_timing_excluded": (
            timing_excluded_from_clean_stats(report, detailed_frame)
        ),
        "crossing_count": section.crossing_count,
        "frame_hash": _hex32(section.frame_hash),
        "state_hash": _hex32(section.state_hash),
        "clean_timing": clean_timing,
        "detailed_frame_time_ms": detailed_ms,
        "selected_clean_frame_time_ms": (
            detailed_ms if diagnostic_replay else None
        ),
        "detailed_intrusion_percent": intrusion,
        "detail": detail,
    }


def build_section_summaries(report: LiveReport) -> list[dict[str, Any]]:
    return [section_summary(report, section) for section in report.sections]


def portal_crossing_windows(
    report: LiveReport, radius: int = 3
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    hz = report.header.clock_hz
    for crossing_index, frame in enumerate(
        (item for item in report.frames if item.crossed_portal), start=1
    ):
        section = report.section_for_id(frame.section_id)
        before = report.frames[max(0, frame.index - radius) : frame.index]
        after = report.frames[
            frame.index + 1 : min(len(report.frames), frame.index + radius + 1)
        ]
        before_clean = clean_timing_frames(report, before)
        after_clean = clean_timing_frames(report, after)
        before_stats = timing_summary(before_clean, hz)
        after_stats = timing_summary(after_clean, hz)
        window = before + [frame] + after
        window_clean = clean_timing_frames(report, window)
        observed_max_ms = max(
            ticks_to_ms(item.total_ticks, hz) for item in window
        )
        rows.append(
            {
                "crossing_index": crossing_index,
                "frame_index": frame.index,
                "section_id": section.section_id,
                "section_name": section.name,
                "crossing_detailed": int(frame.detailed),
                "crossing_included_in_clean_stats": int(
                    not timing_excluded_from_clean_stats(report, frame)
                ),
                "crossing_total_ticks": frame.total_ticks,
                "crossing_total_ms": ticks_to_ms(frame.total_ticks, hz),
                "crossing_render_ms": ticks_to_ms(frame.render_ticks, hz),
                "player_x": frame.player_x,
                "player_y": frame.player_y,
                "angle_degrees": frame.angle_degrees,
                "pre_clean_frames": len(before_clean),
                "pre_clean_mean_ms": before_stats.get(
                    "frame_time_ms", {}
                ).get("mean"),
                "pre_clean_average_fps": before_stats.get("average_fps"),
                "post_clean_frames": len(after_clean),
                "post_clean_mean_ms": after_stats.get(
                    "frame_time_ms", {}
                ).get("mean"),
                "post_clean_average_fps": after_stats.get("average_fps"),
                "window_start": window[0].index,
                "window_end": window[-1].index,
                # Keep the original column as an observed/instrumented alias.
                "window_max_ms": observed_max_ms,
                "window_observed_max_ms": observed_max_ms,
                "window_clean_frames": len(window_clean),
                "window_clean_max_ms": (
                    max(
                        ticks_to_ms(item.total_ticks, hz)
                        for item in window_clean
                    )
                    if window_clean
                    else None
                ),
            }
        )
    return rows


def _frame_row(
    report: LiveReport, frame: Frame, measured_elapsed_ticks: int
) -> dict[str, Any]:
    section = report.section_for_id(frame.section_id)
    hz = report.header.clock_hz
    section_flag_values = {
        f"section_{name}": int(bool(section.flags & (1 << bit)))
        for bit, name in enumerate(SECTION_FLAG_NAMES)
    }
    component_total_ticks = (
        frame.update_ticks + frame.render_ticks + frame.swap_ticks
    )
    row: dict[str, Any] = {
        "frame_index": frame.index,
        # State and timing are sampled after this frame's update/render/swap.
        "simulation_time_seconds": (
            (frame.index + 1) * report.header.elapsed_ticks_per_frame
            / report.header.simulation_ticks_per_second
        ),
        "measured_elapsed_ticks": measured_elapsed_ticks,
        "measured_elapsed_ms": ticks_to_ms(measured_elapsed_ticks, hz),
        "measured_elapsed_seconds": measured_elapsed_ticks / hz,
        "section_id": section.section_id,
        "section_name": section.name,
        "section_flags": f"0x{section.flags:02X}",
        "section_flag_names": "|".join(section.flag_names),
        "total_ticks": frame.total_ticks,
        "component_total_ticks": component_total_ticks,
        "total_ms": ticks_to_ms(frame.total_ticks, hz),
        "instantaneous_fps": (
            hz / frame.total_ticks if frame.total_ticks else float("inf")
        ),
        "update_ticks": frame.update_ticks,
        "update_ms": ticks_to_ms(frame.update_ticks, hz),
        "render_ticks": frame.render_ticks,
        "render_ms": ticks_to_ms(frame.render_ticks, hz),
        "swap_ticks": frame.swap_ticks,
        "swap_ms": ticks_to_ms(frame.swap_ticks, hz),
        "player_x_raw": frame.player_x_raw,
        "player_y_raw": frame.player_y_raw,
        "player_x": frame.player_x,
        "player_y": frame.player_y,
        "map_x": frame.player_x_raw // 256,
        "map_y": frame.player_y_raw // 256,
        "angle_raw": frame.angle_raw,
        "angle_degrees": frame.angle_degrees,
        "move_axis": frame.move_axis,
        "turn_axis": frame.turn_axis,
        "casts": frame.casts,
        "logical_columns": report.header.logical_columns,
        "portal_layer_casts": max(
            frame.casts - report.header.logical_columns, 0
        ),
        # max_depth is retained as the legacy name for ray_layer_depth.
        "max_depth": frame.max_depth,
        "ray_layer_depth": frame.max_depth,
        "portal_recursion_depth": max(frame.max_depth - 1, 0),
        "flags": f"0x{frame.flags:02X}",
        "detailed": int(frame.detailed),
        "timing_excluded_from_clean_stats": int(
            timing_excluded_from_clean_stats(report, frame)
        ),
        "crossed_portal": int(frame.crossed_portal),
        "changed": int(frame.changed),
        "section_end": int(frame.section_end),
    }
    row.update(section_flag_values)
    detail = (
        corrected_detail(
            section.detail,
            report.header.switch_cost_q8,
            report.header.trace_timer_hz,
        )
        if frame.index == section.detailed_frame
        else None
    )
    row["detail_corrected_total_ms"] = (
        detail["corrected_total_ms"] if detail else None
    )
    for name in CATEGORY_NAMES:
        row[f"{name}_corrected_ms"] = (
            detail["categories"][name]["corrected_ms"] if detail else None
        )
    for name in COUNTER_NAMES:
        row[name] = detail["counters"][name] if detail else None
    return row


def frame_rows(report: LiveReport) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    measured_elapsed_ticks = 0
    for frame in report.frames:
        measured_elapsed_ticks += (
            frame.update_ticks + frame.render_ticks + frame.swap_ticks
        )
        rows.append(_frame_row(report, frame, measured_elapsed_ticks))
    return rows


def _flatten_route_timing(
    scope: str,
    timing: dict[str, Any],
    *,
    detailed_frames_excluded: int,
) -> dict[str, Any]:
    frame_ms = timing.get("frame_time_ms", {})
    return {
        "scope": scope,
        "includes_detailed_frames": int(detailed_frames_excluded == 0),
        "detailed_frames_excluded": detailed_frames_excluded,
        "frame_count": timing.get("frame_count"),
        "total_ticks": timing.get("total_ticks"),
        "duration_ms": timing.get("duration_ms"),
        "average_fps": timing.get("average_fps"),
        "minimum_fps": timing.get("minimum_fps"),
        "maximum_fps": timing.get("maximum_fps"),
        "one_percent_low_fps": timing.get("one_percent_low_fps"),
        "one_percent_low_frame_count": timing.get(
            "one_percent_low_frame_count"
        ),
        "point_one_percent_low_fps": timing.get(
            "point_one_percent_low_fps"
        ),
        "point_one_percent_low_frame_count": timing.get(
            "point_one_percent_low_frame_count"
        ),
        "frame_ms_min": frame_ms.get("min"),
        "frame_ms_max": frame_ms.get("max"),
        "frame_ms_mean": frame_ms.get("mean"),
        "frame_ms_median": frame_ms.get("median"),
        "frame_ms_pstdev": frame_ms.get("pstdev"),
        "spike_threshold_ms": timing.get("spike_threshold_ms"),
        "spike_count": timing.get("spike_count"),
        "over_33_333_ms": timing.get("over_33_333_ms"),
        "over_50_ms": timing.get("over_50_ms"),
        "over_100_ms": timing.get("over_100_ms"),
        "over_twice_median": timing.get("over_twice_median"),
        "update_ms_mean": timing.get("update_ms", {}).get("mean"),
        "render_ms_mean": timing.get("render_ms", {}).get("mean"),
        "swap_ms_mean": timing.get("swap_ms", {}).get("mean"),
    }


def summary_rows(report: LiveReport) -> list[dict[str, Any]]:
    """Return whole-route clean and fully observed timing distributions."""

    clean = clean_timing_frames(report)
    detailed_count = len(report.frames) - len(clean)
    rows = [
        _flatten_route_timing(
            "overall_clean",
            timing_summary(clean, report.header.clock_hz),
            detailed_frames_excluded=detailed_count,
        ),
        _flatten_route_timing(
            "overall_observed",
            timing_summary(report.frames, report.header.clock_hz),
            detailed_frames_excluded=0,
        ),
    ]
    route_wall_ms = ticks_to_ms(
        report.header.wall_ticks, report.header.clock_hz
    )
    recorded_phase_total_ms = ticks_to_ms(
        report.header.recorded_total_ticks, report.header.clock_hz
    )
    metadata = {
        "diagnostic_replay": int(
            bool(report.header.flags & FLAG_DIAGNOSTIC_REPLAY)
        ),
        "warmup_frames_before_measurement": report.header.warmup_frames,
        "graphics_init_ms": ticks_to_ms(
            report.header.graphics_init_ticks, report.header.clock_hz
        ),
        "first_frame_render_only_ms": ticks_to_ms(
            report.header.first_frame_ticks, report.header.clock_hz
        ),
        "route_wall_ms": route_wall_ms,
        "recorded_phase_total_ms": recorded_phase_total_ms,
        "wall_minus_recorded_phase_ms": (
            route_wall_ms - recorded_phase_total_ms
        ),
    }
    for row in rows:
        row.update(metadata)
    return rows


def _flatten_section_summary(summary: dict[str, Any]) -> dict[str, Any]:
    timing = summary["clean_timing"]
    frame_ms = timing.get("frame_time_ms", {})
    row: dict[str, Any] = {
        "section_index": summary["section_index"],
        "section_id": summary["section_id"],
        "section_name": summary["section_name"],
        "section_flags": f"0x{summary['section_flags']:02X}",
        "section_flag_names": "|".join(summary["section_flag_names"]),
        "first_frame": summary["first_frame"],
        "frame_count": summary["frame_count"],
        "clean_frame_count": summary["clean_frame_count"],
        "detailed_frame": summary["detailed_frame"],
        "diagnostic_replay": int(summary["diagnostic_replay"]),
        "detailed_frame_timing_excluded": int(
            summary["detailed_frame_timing_excluded"]
        ),
        "crossing_count": summary["crossing_count"],
        "frame_hash": summary["frame_hash"],
        "state_hash": summary["state_hash"],
        "clean_duration_ms": timing.get("duration_ms"),
        "clean_average_fps": timing.get("average_fps"),
        "clean_minimum_fps": timing.get("minimum_fps"),
        "clean_maximum_fps": timing.get("maximum_fps"),
        "clean_1_percent_low_fps": timing.get("one_percent_low_fps"),
        "clean_1_percent_low_frames": timing.get(
            "one_percent_low_frame_count"
        ),
        "clean_0_1_percent_low_fps": timing.get(
            "point_one_percent_low_fps"
        ),
        "clean_0_1_percent_low_frames": timing.get(
            "point_one_percent_low_frame_count"
        ),
        "frame_ms_min": frame_ms.get("min"),
        "frame_ms_max": frame_ms.get("max"),
        "frame_ms_mean": frame_ms.get("mean"),
        "frame_ms_median": frame_ms.get("median"),
        "frame_ms_pstdev": frame_ms.get("pstdev"),
        "spike_threshold_ms": timing.get("spike_threshold_ms"),
        "spike_count": timing.get("spike_count"),
        "over_33_333_ms": timing.get("over_33_333_ms"),
        "over_50_ms": timing.get("over_50_ms"),
        "over_100_ms": timing.get("over_100_ms"),
        "over_twice_median": timing.get("over_twice_median"),
        "update_ms_mean": timing.get("update_ms", {}).get("mean"),
        "render_ms_mean": timing.get("render_ms", {}).get("mean"),
        "swap_ms_mean": timing.get("swap_ms", {}).get("mean"),
        "detailed_frame_time_ms": summary["detailed_frame_time_ms"],
        "selected_clean_frame_time_ms": summary[
            "selected_clean_frame_time_ms"
        ],
        "detailed_intrusion_percent": summary[
            "detailed_intrusion_percent"
        ],
        "detail_corrected_total_ms": summary["detail"][
            "corrected_total_ms"
        ],
    }
    for name in CATEGORY_NAMES:
        category = summary["detail"]["categories"][name]
        row[f"{name}_raw_ticks"] = category["raw_ticks"]
        row[f"{name}_entries"] = category["entries"]
        row[f"{name}_corrected_ticks"] = category["corrected_ticks"]
        row[f"{name}_corrected_ms"] = category["corrected_ms"]
    for name in COUNTER_NAMES:
        row[name] = summary["detail"]["counters"][name]
    return row


def section_rows(report: LiveReport) -> list[dict[str, Any]]:
    return [
        _flatten_section_summary(summary)
        for summary in build_section_summaries(report)
    ]


def _percent_change(current: float | None, baseline: float | None) -> float | None:
    if current is None or baseline in (None, 0):
        return None
    return (current / baseline - 1.0) * 100.0


def compare_reports(
    current: LiveReport, baseline: LiveReport
) -> dict[str, Any]:
    current_header = current.header
    baseline_header = baseline.header
    route_fields = (
        "route_fingerprint",
        "frame_count",
        "section_count",
        "simulation_ticks_per_second",
        "elapsed_ticks_per_frame",
        "logical_columns",
        "column_width",
        "texture_size",
        "depth_limit",
    )
    mismatches = [
        name
        for name in route_fields
        if getattr(current_header, name) != getattr(baseline_header, name)
    ]
    if mismatches:
        raise DecodeError(
            "baseline is not the same route/configuration; mismatched: "
            + ", ".join(mismatches)
        )
    for current_section, baseline_section in zip(
        current.sections, baseline.sections
    ):
        current_config = (
            current_section.section_id,
            current_section.flags,
            current_section.first_frame,
            current_section.frame_count,
            current_section.name,
        )
        baseline_config = (
            baseline_section.section_id,
            baseline_section.flags,
            baseline_section.first_frame,
            baseline_section.frame_count,
            baseline_section.name,
        )
        if current_config != baseline_config:
            raise DecodeError(
                f"section {current_section.section_id} configuration differs"
            )
        if (
            current_section.frame_hash != baseline_section.frame_hash
            or current_section.state_hash != baseline_section.state_hash
        ):
            raise DecodeError(
                f"section {current_section.section_id} endpoint hashes differ; "
                "reports are not directly comparable"
            )
    for current_frame, baseline_frame in zip(current.frames, baseline.frames):
        route_state = (
            current_frame.player_x_raw,
            current_frame.player_y_raw,
            current_frame.angle_raw,
            current_frame.section_id,
            current_frame.move_axis,
            current_frame.turn_axis,
            current_frame.crossed_portal,
        )
        baseline_state = (
            baseline_frame.player_x_raw,
            baseline_frame.player_y_raw,
            baseline_frame.angle_raw,
            baseline_frame.section_id,
            baseline_frame.move_axis,
            baseline_frame.turn_axis,
            baseline_frame.crossed_portal,
        )
        if route_state != baseline_state:
            raise DecodeError(
                f"camera/input route diverges at frame {current_frame.index}"
            )

    current_summaries = build_section_summaries(current)
    baseline_summaries = build_section_summaries(baseline)
    scopes: list[tuple[str, str, dict[str, Any], dict[str, Any],
                       Section | None, Section | None]] = []
    current_clean = clean_timing_frames(current)
    baseline_clean = clean_timing_frames(baseline)
    scopes.append(
        (
            "overall",
            "ALL_CLEAN",
            timing_summary(current_clean, current_header.clock_hz),
            timing_summary(baseline_clean, baseline_header.clock_hz),
            None,
            None,
        )
    )
    for current_summary, baseline_summary, current_section, baseline_section in zip(
        current_summaries,
        baseline_summaries,
        current.sections,
        baseline.sections,
    ):
        scopes.append(
            (
                "section",
                current_section.name,
                current_summary["clean_timing"],
                baseline_summary["clean_timing"],
                current_section,
                baseline_section,
            )
        )

    rows: list[dict[str, Any]] = []
    for (
        scope,
        name,
        current_timing,
        baseline_timing,
        current_section,
        baseline_section,
    ) in scopes:
        current_mean = current_timing.get("frame_time_ms", {}).get("mean")
        baseline_mean = baseline_timing.get("frame_time_ms", {}).get("mean")
        row: dict[str, Any] = {
            "scope": scope,
            "name": name,
            "current_clean_frames": current_timing.get("frame_count"),
            "baseline_clean_frames": baseline_timing.get("frame_count"),
            "current_frame_ms_mean": current_mean,
            "baseline_frame_ms_mean": baseline_mean,
            "frame_ms_delta": (
                None
                if current_mean is None or baseline_mean is None
                else current_mean - baseline_mean
            ),
            "frame_time_percent_change": _percent_change(
                current_mean, baseline_mean
            ),
            "current_average_fps": current_timing.get("average_fps"),
            "baseline_average_fps": baseline_timing.get("average_fps"),
            "average_fps_percent_change": _percent_change(
                current_timing.get("average_fps"),
                baseline_timing.get("average_fps"),
            ),
            "current_1_percent_low_fps": current_timing.get(
                "one_percent_low_fps"
            ),
            "baseline_1_percent_low_fps": baseline_timing.get(
                "one_percent_low_fps"
            ),
            "current_spikes": current_timing.get("spike_count"),
            "baseline_spikes": baseline_timing.get("spike_count"),
        }
        if current_section is not None and baseline_section is not None:
            row["frame_hash_match"] = int(
                current_section.frame_hash == baseline_section.frame_hash
            )
            row["state_hash_match"] = int(
                current_section.state_hash == baseline_section.state_hash
            )
            current_detail = corrected_detail(
                current_section.detail,
                current_header.switch_cost_q8,
                current_header.trace_timer_hz,
            )
            baseline_detail = corrected_detail(
                baseline_section.detail,
                baseline_header.switch_cost_q8,
                baseline_header.trace_timer_hz,
            )
            current_detail_frame = current.frames[
                current_section.detailed_frame
            ]
            baseline_detail_frame = baseline.frames[
                baseline_section.detailed_frame
            ]
            current_detail_state = (
                current_detail_frame.index,
                current_detail_frame.player_x_raw,
                current_detail_frame.player_y_raw,
                current_detail_frame.angle_raw,
                current_detail_frame.section_id,
            )
            baseline_detail_state = (
                baseline_detail_frame.index,
                baseline_detail_frame.player_x_raw,
                baseline_detail_frame.player_y_raw,
                baseline_detail_frame.angle_raw,
                baseline_detail_frame.section_id,
            )
            detail_comparable = (
                current_detail_state == baseline_detail_state
            )
            row["current_detailed_frame"] = current_section.detailed_frame
            row["baseline_detailed_frame"] = baseline_section.detailed_frame
            row["detail_trace_comparable"] = int(detail_comparable)
            row["detail_trace_noncomparable_reason"] = (
                None
                if detail_comparable
                else "selected frame index/state differs"
            )
            for category in CATEGORY_NAMES:
                current_ms = current_detail["categories"][category][
                    "corrected_ms"
                ]
                baseline_ms = baseline_detail["categories"][category][
                    "corrected_ms"
                ]
                row[f"current_{category}_corrected_ms"] = current_ms
                row[f"baseline_{category}_corrected_ms"] = baseline_ms
                row[f"{category}_percent_change"] = (
                    _percent_change(current_ms, baseline_ms)
                    if detail_comparable
                    else None
                )
        rows.append(row)

    warnings: list[str] = []
    if current_header.build_fingerprint == baseline_header.build_fingerprint:
        warnings.append("build fingerprints are identical")
    if current_header.clock_hz != baseline_header.clock_hz:
        warnings.append("clock frequencies differ; comparisons use milliseconds")
    if bool(current_header.flags & FLAG_DIAGNOSTIC_REPLAY) != bool(
        baseline_header.flags & FLAG_DIAGNOSTIC_REPLAY
    ):
        warnings.append(
            "clean-timing semantics differ: one report uses a separate "
            "diagnostic replay and the other uses inline fine tracing"
        )
    return {
        "baseline_source": str(baseline.source),
        "warnings": warnings,
        "rows": rows,
    }


def _header_json(header: Header) -> dict[str, Any]:
    result = dict(header.__dict__)
    for name in (
        "flags",
        "build_fingerprint",
        "route_fingerprint",
        "body_crc32",
        "route_state_hash",
        "final_frame_hash",
    ):
        result[name] = _hex32(getattr(header, name))
    result["switch_cost_ticks"] = header.switch_cost_q8 / 256.0
    result["graphics_init_ms"] = ticks_to_ms(
        header.graphics_init_ticks, header.clock_hz
    )
    result["first_frame_ms"] = ticks_to_ms(
        header.first_frame_ticks, header.clock_hz
    )
    result["first_frame_render_only_ms"] = result["first_frame_ms"]
    result["recorded_total_ms"] = ticks_to_ms(
        header.recorded_total_ticks, header.clock_hz
    )
    result["wall_ms"] = ticks_to_ms(header.wall_ticks, header.clock_hz)
    return result


def _wrapper_json(wrapper: WrapperInfo) -> dict[str, Any]:
    result: dict[str, Any] = {"kind": wrapper.kind}
    for name in (
        "variable_name",
        "archived",
        "comment",
        "dump_offset",
    ):
        value = getattr(wrapper, name)
        if value is not None:
            result[name] = value
    if wrapper.variable_type is not None:
        result["variable_type"] = f"0x{wrapper.variable_type:02X}"
    if wrapper.wrapper_checksum is not None:
        result["wrapper_checksum"] = f"0x{wrapper.wrapper_checksum:04X}"
    return result


def report_json(
    report: LiveReport, comparison: dict[str, Any] | None = None
) -> dict[str, Any]:
    clean = clean_timing_frames(report)
    observed = timing_summary(report.frames, report.header.clock_hz)
    diagnostic_replay = bool(
        report.header.flags & FLAG_DIAGNOSTIC_REPLAY
    )
    result: dict[str, Any] = {
        "format": "P3DLIV1",
        "source": str(report.source),
        "payload_sha256": report.payload_sha256,
        "validation": {
            "body_crc32": "valid",
            "record_structure": "valid",
            "route_state_hash": "valid",
            "ti_wrapper_checksum": (
                "valid" if report.wrapper.kind == "ti-appvar" else "not-applicable"
            ),
        },
        "wrapper": _wrapper_json(report.wrapper),
        "header": _header_json(report.header),
        "overall_clean": timing_summary(clean, report.header.clock_hz),
        "overall_observed": observed,
        "timing_methodology": {
            "diagnostic_replay": diagnostic_replay,
            "detailed_bits_identify_replayed_states": diagnostic_replay,
            "clean_excludes_detailed_frames": not diagnostic_replay,
            "detailed_frames_excluded": len(report.frames) - len(clean),
            "observed_includes_detailed_frames": True,
            "simulation_timestamp_is_post_update": True,
            "measured_elapsed_is_cumulative_update_render_swap": True,
        },
        "sections": build_section_summaries(report),
        "frames": frame_rows(report),
        "portal_crossings": portal_crossing_windows(report),
        "warnings": report.warnings,
    }
    if comparison is not None:
        result["comparison"] = comparison
    return result


def _write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        path.write_text("", encoding="utf-8")
        return
    fieldnames: list[str] = []
    seen: set[str] = set()
    for row in rows:
        for name in row:
            if name not in seen:
                seen.add(name)
                fieldnames.append(name)
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def _sanitize_prefix(value: str) -> str:
    clean = "".join(
        character if character.isalnum() or character in "-_" else "_"
        for character in value
    ).strip("_")
    return clean or "P3DLIVE"


def write_outputs(
    report: LiveReport,
    output_dir: Path,
    prefix: str,
    comparison: dict[str, Any] | None = None,
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    prefix = _sanitize_prefix(prefix)
    paths = {
        "raw": output_dir / f"{prefix}.raw",
        "frames": output_dir / f"{prefix}-frames.csv",
        "sections": output_dir / f"{prefix}-sections.csv",
        "portal_crossings": output_dir / f"{prefix}-portal-crossings.csv",
        "summary": output_dir / f"{prefix}-summary.csv",
        "json": output_dir / f"{prefix}.json",
    }
    paths["raw"].write_bytes(report.payload)
    _write_csv(paths["frames"], frame_rows(report))
    _write_csv(paths["sections"], section_rows(report))
    _write_csv(
        paths["portal_crossings"], portal_crossing_windows(report)
    )
    _write_csv(paths["summary"], summary_rows(report))
    if comparison is not None:
        paths["compare"] = output_dir / f"{prefix}-compare.csv"
        _write_csv(paths["compare"], comparison["rows"])
    paths["json"].write_text(
        json.dumps(report_json(report, comparison), indent=2, sort_keys=True)
        + "\n",
        encoding="utf-8",
    )
    return paths


def print_summary(report: LiveReport) -> None:
    clean = clean_timing_frames(report)
    summary = timing_summary(clean, report.header.clock_hz)
    print(
        f"P3DLIV1: {len(report.frames)} frames, "
        f"{len(clean)} clean, {len(report.sections)} sections"
    )
    print(
        f"Build {_hex32(report.header.build_fingerprint)}, route "
        f"{_hex32(report.header.route_fingerprint)}, "
        f"{report.header.actual_crossings} portal crossings"
    )
    print(
        f"Clean: {summary['frame_time_ms']['mean']:.3f} ms mean, "
        f"{summary['average_fps']:.2f} FPS, "
        f"{summary['one_percent_low_fps']:.2f} FPS 1% low"
    )
    print(
        f"Range: {summary['frame_time_ms']['min']:.3f}-"
        f"{summary['frame_time_ms']['max']:.3f} ms; "
        f"{summary['spike_count']} spikes"
    )
    if (
        summary["point_one_percent_low_frame_count"] < 10
    ):
        print(
            "Note: 0.1% low uses only "
            f"{summary['point_one_percent_low_frame_count']} frame(s)."
        )
    for warning in report.warnings:
        print(f"Warning: {warning}", file=sys.stderr)


def _pack_u24(value: int) -> bytes:
    return int(value & 0xFFFFFF).to_bytes(3, "little")


def _pack_s24(value: int) -> bytes:
    return _pack_u24(value)


def _make_test_payload(*, diagnostic_replay: bool = False) -> bytes:
    section_count = 2
    frame_count = 8
    report_size = (
        HEADER_SIZE
        + section_count * SECTION_RECORD_SIZE
        + frame_count * FRAME_RECORD_SIZE
    )
    body = bytearray(report_size - HEADER_SIZE)
    sections_offset = 0
    frames_offset = section_count * SECTION_RECORD_SIZE
    detail_frames = (2, 5)
    frame_hashes = (0x11223344, 0x55667788)

    for section_index in range(section_count):
        record_offset = sections_offset + section_index * SECTION_RECORD_SIZE
        record = memoryview(body)[
            record_offset : record_offset + SECTION_RECORD_SIZE
        ]
        record[0] = section_index + 1
        record[1] = (
            (1 << 1) | (1 << 6)
            if section_index == 0
            else (1 << 0) | (1 << 4) | (1 << 6)
        )
        struct.pack_into("<H", record, 2, section_index * 4)
        struct.pack_into("<H", record, 4, 4)
        struct.pack_into("<H", record, 6, detail_frames[section_index])
        name = f"TEST_{section_index + 1}".encode("ascii")
        record[8 : 8 + len(name)] = name
        for category in range(CATEGORY_COUNT):
            record[24 + category * 3 : 27 + category * 3] = _pack_u24(
                20 + section_index * 4 + category
            )
            struct.pack_into("<H", record, 46 + category * 2, category + 1)
        struct.pack_into("<I", record, 60, frame_hashes[section_index])
        for counter, value in enumerate(range(1, 8)):
            struct.pack_into("<H", record, 64 + counter * 2, value)
        struct.pack_into("<I", record, 78, 0xABC00000 + section_index)
        struct.pack_into("<H", record, 82, 1)

    route_parts: list[bytes] = []
    total_ticks = 0
    for frame_index in range(frame_count):
        record_offset = frames_offset + frame_index * FRAME_RECORD_SIZE
        record = memoryview(body)[
            record_offset : record_offset + FRAME_RECORD_SIZE
        ]
        total = 100 + frame_index
        struct.pack_into("<H", record, 0, total)
        struct.pack_into("<H", record, 2, 2)
        struct.pack_into("<H", record, 4, total - 3)
        struct.pack_into("<H", record, 6, 1)
        record[8:11] = _pack_s24(384 + frame_index * 8)
        record[11:14] = _pack_s24(640 + frame_index * 4)
        struct.pack_into("<H", record, 14, frame_index * 64)
        struct.pack_into("<H", record, 16, 80 + frame_index)
        record[18] = 1 + (frame_index & 1)
        record[19] = 1 if frame_index < 4 else 2
        flags = FRAME_CHANGED
        if frame_index in detail_frames:
            flags |= FRAME_DETAILED | FRAME_CROSSED_PORTAL
        if frame_index in (3, 7):
            flags |= FRAME_SECTION_END
        record[20] = flags
        record[21] = 2 | (1 << 2)  # move +1, turn 0
        route_parts.append(bytes(record[8:18]))
        total_ticks += total

    header = bytearray(HEADER_SIZE)
    header[:8] = MAGIC
    struct.pack_into("<H", header, 8, FORMAT_VERSION)
    struct.pack_into("<H", header, 10, HEADER_SIZE)
    flags = KNOWN_HEADER_FLAGS & ~FLAG_DIAGNOSTIC_REPLAY
    if diagnostic_replay:
        flags |= FLAG_DIAGNOSTIC_REPLAY
    struct.pack_into("<I", header, 12, flags)
    struct.pack_into("<I", header, 16, 32768)
    struct.pack_into("<I", header, 20, 32768)
    struct.pack_into("<I", header, 24, 0x12345678)
    struct.pack_into("<I", header, 28, 0x87654321)
    struct.pack_into("<H", header, 32, report_size)
    struct.pack_into("<H", header, 34, section_count)
    struct.pack_into("<H", header, 36, 2)
    struct.pack_into("<H", header, 38, frame_count)
    struct.pack_into("<H", header, 40, SECTION_RECORD_SIZE)
    struct.pack_into("<H", header, 42, FRAME_RECORD_SIZE)
    struct.pack_into("<H", header, 44, 80)
    header[46] = 4
    header[47] = 16
    header[48] = 6
    header[49] = CATEGORY_COUNT
    struct.pack_into("<H", header, 50, 30)
    struct.pack_into("<H", header, 52, 1)
    struct.pack_into("<H", header, 54, 2)
    struct.pack_into("<I", header, 56, 256)
    struct.pack_into("<I", header, 64, 500)
    struct.pack_into("<I", header, 68, 100)
    struct.pack_into("<I", header, 72, total_ticks)
    struct.pack_into("<I", header, 76, _fnv1a(route_parts))
    struct.pack_into("<I", header, 80, frame_hashes[-1])
    struct.pack_into("<H", header, 84, 2)
    struct.pack_into("<H", header, 86, 2)
    struct.pack_into("<H", header, 88, report_size)
    struct.pack_into("<I", header, 92, total_ticks + 50)
    struct.pack_into("<I", header, 60, zlib.crc32(body) & 0xFFFFFFFF)
    return bytes(header + body)


def _make_test_8xv(payload: bytes) -> bytes:
    comment = b"P3DLIV decoder self-test".ljust(42, b"\0")
    variable_length = len(payload) + 2
    entry = bytearray()
    entry.extend(struct.pack("<H", 13))
    entry.extend(struct.pack("<H", variable_length))
    entry.append(APPVAR_TYPE)
    entry.extend(b"P3DLIVE\0")
    entry.append(0)
    entry.append(0x80)
    entry.extend(struct.pack("<H", variable_length))
    entry.extend(struct.pack("<H", len(payload)))
    entry.extend(payload)
    wrapper = bytearray(TI_SIGNATURE_PREFIX)
    wrapper.append(0)
    wrapper.extend(comment)
    wrapper.extend(struct.pack("<H", len(entry)))
    wrapper.extend(entry)
    wrapper.extend(struct.pack("<H", sum(entry) & 0xFFFF))
    return bytes(wrapper)


def run_self_test() -> None:
    payload = _make_test_payload()
    raw_report = parse_payload(
        payload, Path("selftest.raw"), WrapperInfo(kind="raw")
    )
    assert len(raw_report.frames) == 8
    assert len(raw_report.sections) == 2
    legacy_windows = portal_crossing_windows(raw_report)
    assert len(legacy_windows) == 2
    assert legacy_windows[0]["crossing_included_in_clean_stats"] == 0
    assert len(clean_timing_frames(raw_report)) == 6
    rows = frame_rows(raw_report)
    assert math.isclose(rows[0]["simulation_time_seconds"], 1.0 / 30.0)
    assert rows[0]["measured_elapsed_ticks"] == 100
    assert rows[-1]["measured_elapsed_ticks"] == sum(
        frame.update_ticks + frame.render_ticks + frame.swap_ticks
        for frame in raw_report.frames
    )
    assert rows[0]["section_large_room"] == 1
    assert rows[0]["section_portal_cross"] == 1
    assert rows[0]["section_small_room"] == 0
    assert rows[0]["ray_layer_depth"] == rows[0]["max_depth"] == 1
    assert rows[0]["portal_recursion_depth"] == 0
    assert rows[-1]["portal_recursion_depth"] == 1
    assert rows[0]["portal_layer_casts"] == 0
    assert rows[-1]["portal_layer_casts"] == 7
    assert rows[2]["timing_excluded_from_clean_stats"] == 1
    route_summaries = summary_rows(raw_report)
    assert [row["scope"] for row in route_summaries] == [
        "overall_clean",
        "overall_observed",
    ]
    assert route_summaries[0]["frame_count"] == 6
    assert route_summaries[0]["detailed_frames_excluded"] == 2
    assert route_summaries[0]["warmup_frames_before_measurement"] == 2
    assert route_summaries[0]["first_frame_render_only_ms"] > 0
    assert route_summaries[0]["route_wall_ms"] > 0
    assert (
        route_summaries[0]["recorded_phase_total_ms"]
        == route_summaries[1]["recorded_phase_total_ms"]
    )
    assert route_summaries[1]["frame_count"] == 8
    assert route_summaries[1]["includes_detailed_frames"] == 1

    replay_payload = _make_test_payload(diagnostic_replay=True)
    replay_report = parse_payload(
        replay_payload,
        Path("selftest-replay.raw"),
        WrapperInfo(kind="raw"),
    )
    assert replay_report.header.flags & FLAG_DIAGNOSTIC_REPLAY
    assert len(clean_timing_frames(replay_report)) == 8
    replay_rows = frame_rows(replay_report)
    assert replay_rows[2]["detailed"] == 1
    assert replay_rows[2]["timing_excluded_from_clean_stats"] == 0
    replay_summary = summary_rows(replay_report)
    assert replay_summary[0]["frame_count"] == 8
    assert replay_summary[0]["detailed_frames_excluded"] == 0
    assert replay_summary[0]["diagnostic_replay"] == 1
    replay_sections = build_section_summaries(replay_report)
    assert replay_sections[0]["detailed_intrusion_percent"] is None
    assert replay_sections[0]["selected_clean_frame_time_ms"] is not None
    replay_windows = portal_crossing_windows(replay_report)
    assert replay_windows[0]["crossing_included_in_clean_stats"] == 1
    replay_json = report_json(replay_report)
    assert replay_json["timing_methodology"]["diagnostic_replay"] is True
    assert (
        replay_json["timing_methodology"]["detailed_frames_excluded"] == 0
    )

    appvar_blob = _make_test_8xv(payload)
    extracted, wrapper = extract_payload(appvar_blob)
    assert extracted == payload
    assert wrapper.kind == "ti-appvar"
    assert wrapper.variable_name == "P3DLIVE"
    wrapped_report = parse_payload(
        extracted, Path("selftest.8xv"), wrapper
    )
    assert wrapped_report.wrapper.archived is True

    raw_appvar = struct.pack("<H", len(payload)) + payload
    extracted, wrapper = extract_payload(raw_appvar)
    assert extracted == payload and wrapper.kind == "raw-appvar-data"

    dump = b"\xA5" * 137 + payload + b"\x5A" * 211
    extracted, wrapper = extract_payload(dump)
    assert extracted == payload
    assert wrapper.kind == "cemu-ram-dump" and wrapper.dump_offset == 137

    duplicate_dump = payload + b"\0" * 16 + payload
    extracted, wrapper = extract_payload(duplicate_dump)
    assert extracted == payload
    assert wrapper.kind == "cemu-ram-dump"

    distinct_payload = _make_test_payload(diagnostic_replay=True)
    try:
        extract_payload(payload + b"\0" * 16 + distinct_payload)
    except DecodeError as exc:
        assert "2 distinct CRC-valid" in str(exc)
    else:
        raise AssertionError("ambiguous RAM dump was accepted")

    corrupt = bytearray(payload)
    corrupt[-1] ^= 1
    try:
        parse_payload(
            bytes(corrupt), Path("corrupt.raw"), WrapperInfo(kind="raw")
        )
    except DecodeError as exc:
        assert "CRC32 mismatch" in str(exc)
    else:
        raise AssertionError("corrupt body CRC was accepted")

    comparison = compare_reports(raw_report, wrapped_report)
    assert len(comparison["rows"]) == 3
    cross_mode_comparison = compare_reports(replay_report, raw_report)
    assert any(
        "clean-timing semantics differ" in warning
        for warning in cross_mode_comparison["warnings"]
    )

    moved_payload = bytearray(replay_payload)
    first_section_detail_offset = HEADER_SIZE + 6
    struct.pack_into("<H", moved_payload, first_section_detail_offset, 1)
    frame_block = HEADER_SIZE + 2 * SECTION_RECORD_SIZE
    moved_payload[frame_block + 2 * FRAME_RECORD_SIZE + 20] &= (
        ~FRAME_DETAILED & 0xFF
    )
    moved_payload[frame_block + FRAME_RECORD_SIZE + 20] |= FRAME_DETAILED
    struct.pack_into(
        "<I",
        moved_payload,
        60,
        zlib.crc32(moved_payload[HEADER_SIZE:]) & 0xFFFFFFFF,
    )
    moved_report = parse_payload(
        bytes(moved_payload),
        Path("selftest-replay-moved.raw"),
        WrapperInfo(kind="raw"),
    )
    moved_comparison = compare_reports(moved_report, replay_report)
    assert moved_comparison["rows"][1]["detail_trace_comparable"] == 0
    assert (
        moved_comparison["rows"][1]["admin_percent_change"] is None
    )
    with tempfile.TemporaryDirectory() as directory:
        paths = write_outputs(
            raw_report,
            Path(directory),
            "selftest",
            comparison,
        )
        for path in paths.values():
            assert path.is_file() and path.stat().st_size > 0
        assert paths["summary"].name == "selftest-summary.csv"
        with paths["summary"].open(
            newline="", encoding="utf-8"
        ) as stream:
            summary_csv = list(csv.DictReader(stream))
        assert [row["scope"] for row in summary_csv] == [
            "overall_clean",
            "overall_observed",
        ]
        decoded_json = json.loads(paths["json"].read_text(encoding="utf-8"))
        assert decoded_json["validation"]["body_crc32"] == "valid"
        assert len(decoded_json["frames"]) == 8
        assert decoded_json["overall_clean"]["frame_count"] == 6
        assert decoded_json["overall_observed"]["frame_count"] == 8
        assert decoded_json["frames"][0]["simulation_time_seconds"] > 0
        assert (
            decoded_json["frames"][-1]["measured_elapsed_ticks"]
            == rows[-1]["measured_elapsed_ticks"]
        )

    print("decode-live-benchmark self-test: PASS")


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Validate and decode PortalR P3DLIVE gameplay benchmark data"
        )
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        help="P3DLIVE.8xv, raw P3DLIV1 payload, or CEmu RAM dump",
    )
    parser.add_argument(
        "--compare",
        type=Path,
        help="same-route live result to use as a baseline",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("benchmark-results"),
        help="directory for CSV and JSON outputs",
    )
    parser.add_argument(
        "--prefix",
        help="output filename prefix (default: input stem)",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run synthetic raw/AppVar/RAM/CRC/output tests and exit",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_argument_parser()
    args = parser.parse_args(argv)
    if args.self_test:
        run_self_test()
        return 0
    if args.input is None:
        parser.error("input is required unless --self-test is used")

    try:
        report = decode_file(args.input)
        baseline = decode_file(args.compare) if args.compare else None
        comparison = compare_reports(report, baseline) if baseline else None
        prefix = args.prefix or args.input.stem
        paths = write_outputs(
            report, args.output_dir, prefix, comparison
        )
        print_summary(report)
        for label, path in paths.items():
            print(f"{label}: {path.resolve()}")
        if comparison:
            for warning in comparison["warnings"]:
                print(f"Comparison note: {warning}", file=sys.stderr)
        return 0
    except (DecodeError, OSError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
