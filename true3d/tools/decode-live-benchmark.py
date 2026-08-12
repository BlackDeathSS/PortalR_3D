#!/usr/bin/env python3
"""Validate and decode True3D's deterministic T3DLIV1 benchmark.

Accepted inputs are a raw report payload, raw AppVar data (the two-byte inner
length followed by the report), a transferred TI ``.8xv`` file, or a full CEmu
RAM dump containing one unique CRC-valid report.  Successful decodes emit a
machine-readable JSON document and flat CSV files suitable for A/B analysis.
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
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Iterable, Sequence


MAGIC = b"T3DLIV1\0"
FORMAT_VERSION = 1
HEADER_SIZE = 112
SECTION_RECORD_SIZE = 116
FRAME_RECORD_SIZE = 24
SECTION_COUNT = 10
FRAME_COUNT = 854
WARMUP_FRAMES = 16
CATEGORY_COUNT = 10
COUNTER_COUNT = 11
EXPECTED_CROSSINGS = 4
EXPECTED_CROSSING_FRAMES = (318, 324, 432, 764)
ROUTE_STEP_COUNT = 21
REPORT_SIZE = (
    HEADER_SIZE
    + SECTION_COUNT * SECTION_RECORD_SIZE
    + FRAME_COUNT * FRAME_RECORD_SIZE
)

APPVAR_NAME = "T3DLIVE"
APPVAR_TYPE = 0x15
TI_SIGNATURE_PREFIX = b"**TI83F*\x1a\x0a"
TI_SIGNATURE_REVISIONS = frozenset((0x00, 0x0A))

FLAG_FRAME_TIMINGS = 1 << 0
FLAG_FIXED_TIMESTEP = 1 << 1
FLAG_FULL_UPDATE = 1 << 2
FLAG_FULL_RENDER_PRESENT = 1 << 3
FLAG_SECTION_TRACE = 1 << 4
FLAG_SECTION_HASHES = 1 << 5
FLAG_BUILTIN_LEVEL = 1 << 6
FLAG_CONSTANT_HUD = 1 << 7
FLAG_FULL_DETAIL = 1 << 8
FLAG_DIAGNOSTIC_REPLAY = 1 << 9
FLAG_ARCHIVED = 1 << 10
FLAG_FIXED_TRACE_FRAMES = 1 << 11
REQUIRED_HEADER_FLAGS = (1 << 10) - 1
KNOWN_HEADER_FLAGS = (
    REQUIRED_HEADER_FLAGS | FLAG_ARCHIVED | FLAG_FIXED_TRACE_FRAMES
)

HEADER_FLAG_NAMES = (
    "frame_timings",
    "fixed_timestep",
    "full_update",
    "full_render_present",
    "section_trace",
    "section_hashes",
    "builtin_level",
    "constant_hud",
    "full_detail",
    "diagnostic_replay",
    "archived",
    "fixed_trace_frames",
)

SECTION_PORTAL_VIEW = 1 << 0
SECTION_PORTAL_CROSS = 1 << 1
SECTION_TURN = 1 << 2
SECTION_PITCH = 1 << 3
SECTION_FREECAM = 1 << 4
SECTION_LOD = 1 << 5
SECTION_VERTICAL = 1 << 6
SECTION_STRESS = 1 << 7
KNOWN_SECTION_FLAGS = 0xFF
SECTION_FLAG_NAMES = (
    "portal_view",
    "portal_cross",
    "turn",
    "pitch",
    "freecam",
    "lod",
    "vertical",
    "stress",
)

FRAME_CROSSED_PORTAL = 1 << 0
FRAME_DETAILED = 1 << 1
FRAME_CHANGED = 1 << 2
FRAME_SECTION_END = 1 << 3
FRAME_FREECAM = 1 << 4
KNOWN_FRAME_FLAGS = 0x1F

CATEGORY_NAMES = (
    "admin",
    "setup",
    "root_geometry",
    "root_fill",
    "portal_setup",
    "portal_geometry",
    "portal_fill",
    "wait",
    "present",
    "overlay",
)
COUNTER_NAMES = (
    "transformed_vertices",
    "projected_points",
    "rasterized_polygons",
    "raster_rows",
    "filled_spans",
    "filled_pixels",
    "portal_composite_pixels",
    "portal_clip_pixels",
    "full_portal_views",
    "lod_portal_views",
    "edge_division_fallbacks",
)

EXPECTED_SECTIONS = (
    ("OPEN_YAW", SECTION_TURN, 128),
    ("PITCH_SWEEP", SECTION_PITCH, 96),
    ("PORTAL_FAR", SECTION_PORTAL_VIEW | SECTION_LOD, 56),
    ("PORTAL_NEAR", SECTION_PORTAL_VIEW | SECTION_LOD, 36),
    (
        "CROSS_DOWN",
        SECTION_PORTAL_VIEW | SECTION_PORTAL_CROSS | SECTION_STRESS,
        4,
    ),
    (
        "RETURN_UP",
        SECTION_PORTAL_VIEW
        | SECTION_PORTAL_CROSS
        | SECTION_FREECAM
        | SECTION_STRESS,
        10,
    ),
    (
        "LOD_RETREAT",
        SECTION_PORTAL_VIEW | SECTION_LOD | SECTION_FREECAM,
        48,
    ),
    (
        "LOD_APPROACH",
        SECTION_PORTAL_VIEW
        | SECTION_PORTAL_CROSS
        | SECTION_LOD
        | SECTION_FREECAM
        | SECTION_STRESS,
        60,
    ),
    ("FREECAM_YAW", SECTION_TURN | SECTION_FREECAM, 128),
    (
        "FREECAM_3D",
        SECTION_PITCH | SECTION_FREECAM | SECTION_VERTICAL | SECTION_STRESS,
        288,
    ),
)


class DecodeError(ValueError):
    """Raised when a report fails integrity or schema validation."""


@dataclass(frozen=True)
class WrapperInfo:
    kind: str
    variable_name: str | None = None
    variable_type: int | None = None
    archived: bool | None = None
    comment: str | None = None
    wrapper_checksum: int | None = None
    dump_offsets: tuple[int, ...] = ()


@dataclass(frozen=True)
class Header:
    flags: int
    clock_hz: int
    trace_timer_hz: int
    build_version: int
    route_fingerprint: int
    report_size: int
    section_count: int
    warmup_frames: int
    frame_count: int
    section_record_size: int
    frame_record_size: int
    render_width: int
    render_height: int
    render_scale: int
    recursion_limit: int
    category_count: int
    counter_count: int
    simulation_ticks_per_second: int
    elapsed_ticks_per_frame: int
    expected_crossings: int
    switch_cost_q8: int
    body_crc32: int
    graphics_init_ticks: int
    first_frame_ticks: int
    recorded_total_ticks: int
    route_state_hash: int
    final_logical_hash: int
    final_presented_hash: int
    actual_crossings: int
    detailed_frames: int
    duplicate_report_size: int
    route_step_count: int
    wall_ticks: int
    hud_fps_tenths: int
    level_version: int

    @property
    def flag_names(self) -> tuple[str, ...]:
        return tuple(
            name
            for bit, name in enumerate(HEADER_FLAG_NAMES)
            if self.flags & (1 << bit)
        )


@dataclass(frozen=True)
class Detail:
    raw_ticks: tuple[int, ...]
    entries: tuple[int, ...]
    counters: tuple[int, ...]
    total_ticks: int


@dataclass(frozen=True)
class Section:
    index: int
    section_id: int
    flags: int
    first_frame: int
    frame_count: int
    detailed_frame: int
    name: str
    logical_hash: int
    presented_hash: int
    state_hash: int
    crossing_count: int
    lod_state: int
    room: int
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

    @property
    def portal_lods(self) -> tuple[int, int]:
        return self.lod_state & 3, (self.lod_state >> 2) & 3


@dataclass(frozen=True)
class Frame:
    index: int
    section_id: int
    total_ticks: int
    update_ticks: int
    render_ticks: int
    swap_ticks: int
    state_hash: int
    position_x_raw: int
    position_y_raw: int
    position_z_raw: int
    room: int
    flags: int
    move_axis: int
    turn_axis: int
    look_axis: int
    buttons_active: bool

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
    def freecam(self) -> bool:
        return bool(self.flags & FRAME_FREECAM)

    @property
    def position(self) -> tuple[float, float, float]:
        return (
            self.position_x_raw / 256.0,
            self.position_y_raw / 256.0,
            self.position_z_raw / 256.0,
        )


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

    def frames_for_section(self, section: Section) -> list[Frame]:
        return self.frames[section.first_frame : section.end_frame]

    def section_for_frame(self, frame: Frame) -> Section:
        return self.sections[frame.section_id - 1]


def _u16(data: bytes | bytearray | memoryview, offset: int) -> int:
    return struct.unpack_from("<H", data, offset)[0]


def _u24(data: bytes | bytearray | memoryview, offset: int) -> int:
    return int.from_bytes(data[offset : offset + 3], "little")


def _u32(data: bytes | bytearray | memoryview, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def _s24(data: bytes | bytearray | memoryview, offset: int) -> int:
    value = _u24(data, offset)
    return value - (1 << 24) if value & (1 << 23) else value


def _hex32(value: int) -> str:
    return f"0x{value:08X}"


def _fnv1a(parts: Iterable[bytes]) -> int:
    value = 2166136261
    for part in parts:
        for byte in part:
            value ^= byte
            value = (value * 16777619) & 0xFFFFFFFF
    return value


def _decode_fixed_string(raw: bytes, context: str) -> str:
    if b"\0" not in raw:
        raise DecodeError(f"{context} is not NUL-terminated")
    prefix, suffix = raw.split(b"\0", 1)
    if any(suffix):
        raise DecodeError(f"{context} has non-zero bytes after its terminator")
    try:
        result = prefix.decode("ascii")
    except UnicodeDecodeError as exc:
        raise DecodeError(f"{context} is not ASCII") from exc
    if not result:
        raise DecodeError(f"{context} is empty")
    return result


def _candidate_payload(blob: bytes, offset: int) -> bytes | None:
    """Return a structurally plausible CRC-valid report at *offset*."""

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
        or _u16(view, 92) != report_size
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
    if len(blob) < 76:
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
    raw_name = bytes(entry[5:13])
    if b"\0" not in raw_name:
        raise DecodeError("TI variable name is not NUL-terminated")
    encoded_name, name_padding = raw_name.split(b"\0", 1)
    if any(name_padding):
        raise DecodeError("TI variable name has non-zero padding")
    try:
        variable_name = encoded_name.decode("ascii")
    except UnicodeDecodeError as exc:
        raise DecodeError("TI variable name is not ASCII") from exc
    archived = bool(entry[14] & 0x80)
    if entry[13] != 0 or entry[14] & 0x7F:
        raise DecodeError("TI variable entry has non-zero reserved/version bits")
    if _u16(entry, 15) != variable_length:
        raise DecodeError("TI variable length fields disagree")
    if section_size != 17 + variable_length:
        raise DecodeError("TI data section is not exactly one variable")
    if variable_type != APPVAR_TYPE:
        raise DecodeError(
            f"TI variable type is 0x{variable_type:02X}, expected AppVar 0x{APPVAR_TYPE:02X}"
        )
    if variable_name != APPVAR_NAME:
        raise DecodeError(
            f"TI AppVar is named {variable_name!r}, expected {APPVAR_NAME!r}"
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
    """Extract one unambiguous report from every supported container."""

    if blob.startswith(MAGIC) and len(blob) >= HEADER_SIZE:
        declared_size = _u16(blob, 32)
        if declared_size == len(blob):
            return bytes(blob), WrapperInfo(kind="raw")
    if len(blob) >= 2 + HEADER_SIZE and blob[2 : 2 + len(MAGIC)] == MAGIC:
        if _u16(blob, 0) == len(blob) - 2:
            payload = bytes(blob[2:])
            if _candidate_payload(payload, 0) is None:
                raise DecodeError("raw AppVar data contains an invalid report")
            return payload, WrapperInfo(kind="raw-appvar-data")
    if blob.startswith(b"**TI83F*"):
        return _extract_ti_appvar(blob)

    candidates: list[tuple[int, bytes]] = []
    start = 0
    while True:
        offset = blob.find(MAGIC, start)
        if offset < 0:
            break
        candidate = _candidate_payload(blob, offset)
        if candidate is not None:
            candidates.append((offset, candidate))
        start = offset + 1
    if not candidates:
        raise DecodeError(
            "input is not a raw/TI AppVar and contains no CRC-valid T3DLIV1 report"
        )
    unique: dict[bytes, list[int]] = {}
    for offset, payload in candidates:
        unique.setdefault(payload, []).append(offset)
    if len(unique) != 1:
        offsets = ", ".join(f"0x{offset:X}" for offset, _ in candidates)
        raise DecodeError(
            f"RAM dump contains {len(unique)} distinct CRC-valid T3DLIV1 "
            f"reports at {offsets}; expected one unique result"
        )
    payload, offsets = next(iter(unique.items()))
    return payload, WrapperInfo(
        kind="cemu-ram-dump", dump_offsets=tuple(offsets)
    )


def _parse_header(payload: bytes) -> Header:
    if len(payload) < HEADER_SIZE:
        raise DecodeError(
            f"report is {len(payload)} bytes; at least {HEADER_SIZE} required"
        )
    if payload[:8] != MAGIC:
        raise DecodeError(f"unsupported magic {payload[:8]!r}; expected {MAGIC!r}")
    if _u16(payload, 8) != FORMAT_VERSION:
        raise DecodeError(
            f"unsupported T3DLIV version {_u16(payload, 8)}; expected {FORMAT_VERSION}"
        )
    if _u16(payload, 10) != HEADER_SIZE:
        raise DecodeError(
            f"header size is {_u16(payload, 10)}; expected {HEADER_SIZE}"
        )
    header = Header(
        flags=_u32(payload, 12),
        clock_hz=_u32(payload, 16),
        trace_timer_hz=_u32(payload, 20),
        build_version=_u32(payload, 24),
        route_fingerprint=_u32(payload, 28),
        report_size=_u16(payload, 32),
        section_count=_u16(payload, 34),
        warmup_frames=_u16(payload, 36),
        frame_count=_u16(payload, 38),
        section_record_size=_u16(payload, 40),
        frame_record_size=_u16(payload, 42),
        render_width=payload[44],
        render_height=payload[45],
        render_scale=payload[46],
        recursion_limit=payload[47],
        category_count=payload[48],
        counter_count=payload[49],
        simulation_ticks_per_second=_u16(payload, 50),
        elapsed_ticks_per_frame=_u16(payload, 52),
        expected_crossings=_u16(payload, 54),
        switch_cost_q8=_u32(payload, 56),
        body_crc32=_u32(payload, 60),
        graphics_init_ticks=_u32(payload, 64),
        first_frame_ticks=_u32(payload, 68),
        recorded_total_ticks=_u32(payload, 72),
        route_state_hash=_u32(payload, 76),
        final_logical_hash=_u32(payload, 80),
        final_presented_hash=_u32(payload, 84),
        actual_crossings=_u16(payload, 88),
        detailed_frames=_u16(payload, 90),
        duplicate_report_size=_u16(payload, 92),
        route_step_count=payload[94],
        wall_ticks=_u32(payload, 96),
        hud_fps_tenths=_u16(payload, 100),
        level_version=payload[103],
    )
    reserved_offsets = (7, 95, 102, *range(104, HEADER_SIZE))
    nonzero = [offset for offset in reserved_offsets if payload[offset] != 0]
    if nonzero:
        raise DecodeError(
            "non-zero reserved header byte(s): "
            + ", ".join(str(offset) for offset in nonzero)
        )
    if header.flags & ~KNOWN_HEADER_FLAGS:
        raise DecodeError(
            f"unknown header flags 0x{header.flags & ~KNOWN_HEADER_FLAGS:08X}"
        )
    missing = REQUIRED_HEADER_FLAGS & ~header.flags
    if missing:
        raise DecodeError(f"required header flags are absent: 0x{missing:08X}")
    expected_values = {
        "report_size": REPORT_SIZE,
        "section_count": SECTION_COUNT,
        "warmup_frames": WARMUP_FRAMES,
        "frame_count": FRAME_COUNT,
        "section_record_size": SECTION_RECORD_SIZE,
        "frame_record_size": FRAME_RECORD_SIZE,
        "recursion_limit": 1,
        "category_count": CATEGORY_COUNT,
        "counter_count": COUNTER_COUNT,
        "simulation_ticks_per_second": 30,
        "elapsed_ticks_per_frame": 1,
        "expected_crossings": EXPECTED_CROSSINGS,
        "duplicate_report_size": REPORT_SIZE,
        "route_step_count": ROUTE_STEP_COUNT,
        "hud_fps_tenths": 300,
        "level_version": 1,
    }
    for name, expected in expected_values.items():
        actual = getattr(header, name)
        if actual != expected:
            raise DecodeError(f"{name} is {actual}; expected {expected}")
    render_configuration = (
        header.render_width,
        header.render_height,
        header.render_scale,
    )
    if render_configuration not in ((64, 48, 5), (80, 60, 4), (160, 120, 2)):
        raise DecodeError(
            "unsupported render configuration "
            f"{header.render_width}x{header.render_height} at "
            f"{header.render_scale}x"
        )
    if header.report_size != len(payload):
        raise DecodeError(
            f"header declares {header.report_size} bytes, found {len(payload)}"
        )
    if header.clock_hz == 0 or header.trace_timer_hz == 0:
        raise DecodeError("clock frequencies must be non-zero")
    if header.clock_hz != header.trace_timer_hz:
        raise DecodeError("frame and trace timer frequencies disagree")
    if header.build_version == 0 or header.route_fingerprint == 0:
        raise DecodeError("build and route fingerprints must be non-zero")
    if header.graphics_init_ticks == 0 or header.first_frame_ticks == 0:
        raise DecodeError("startup timing fields must be non-zero")
    if header.actual_crossings != header.expected_crossings:
        raise DecodeError(
            f"route expected {header.expected_crossings} crossings but recorded "
            f"{header.actual_crossings}"
        )
    if header.detailed_frames != header.section_count:
        raise DecodeError(
            f"detailed frame count is {header.detailed_frames}; "
            f"expected {header.section_count}"
        )
    computed_crc = zlib.crc32(payload[HEADER_SIZE:]) & 0xFFFFFFFF
    if computed_crc != header.body_crc32:
        raise DecodeError(
            "body CRC32 mismatch: "
            f"stored {_hex32(header.body_crc32)}, computed {_hex32(computed_crc)}"
        )
    return header


def parse_payload(
    payload: bytes, source: Path, wrapper: WrapperInfo
) -> LiveReport:
    header = _parse_header(payload)
    sections: list[Section] = []
    expected_first = 0
    for index, expected_config in enumerate(EXPECTED_SECTIONS):
        offset = HEADER_SIZE + index * SECTION_RECORD_SIZE
        record = payload[offset : offset + SECTION_RECORD_SIZE]
        name = _decode_fixed_string(record[8:24], f"section {index + 1} name")
        detail = Detail(
            raw_ticks=tuple(
                _u24(record, 40 + category * 3)
                for category in range(CATEGORY_COUNT)
            ),
            entries=tuple(
                _u16(record, 70 + category * 2)
                for category in range(CATEGORY_COUNT)
            ),
            counters=tuple(
                _u16(record, 90 + counter * 2)
                for counter in range(COUNTER_COUNT)
            ),
            total_ticks=_u32(record, 112),
        )
        section = Section(
            index=index,
            section_id=record[0],
            flags=record[1],
            first_frame=_u16(record, 2),
            frame_count=_u16(record, 4),
            detailed_frame=_u16(record, 6),
            name=name,
            logical_hash=_u32(record, 24),
            presented_hash=_u32(record, 28),
            state_hash=_u32(record, 32),
            crossing_count=_u16(record, 36),
            lod_state=record[38],
            room=record[39],
            detail=detail,
        )
        expected_name, expected_flags, expected_frames = expected_config
        if section.section_id != index + 1:
            raise DecodeError(
                f"section {index + 1} has ID {section.section_id}"
            )
        if section.flags & ~KNOWN_SECTION_FLAGS:
            raise DecodeError(f"section {section.section_id} has unknown flags")
        if (
            section.name != expected_name
            or section.flags != expected_flags
            or section.first_frame != expected_first
            or section.frame_count != expected_frames
        ):
            raise DecodeError(
                f"section {section.section_id} layout is "
                f"({section.name!r}, flags=0x{section.flags:02X}, "
                f"first={section.first_frame}, frames={section.frame_count}); "
                f"expected ({expected_name!r}, flags=0x{expected_flags:02X}, "
                f"first={expected_first}, frames={expected_frames})"
            )
        if section.detailed_frame < section.first_frame or (
            section.detailed_frame >= section.end_frame
        ):
            raise DecodeError(
                f"section {section.section_id} detailed frame is outside its range"
            )
        portal_lods = section.portal_lods
        if section.lod_state & 0xF0 or any(value > 2 for value in portal_lods):
            raise DecodeError(
                f"section {section.section_id} has invalid packed portal LOD state "
                f"0x{section.lod_state:02X}"
            )
        if section.room >= 8:
            raise DecodeError(
                f"section {section.section_id} endpoint room {section.room} is invalid"
            )
        if sum(detail.raw_ticks) != detail.total_ticks:
            raise DecodeError(
                f"section {section.section_id} detail total {detail.total_ticks} "
                f"does not match phase sum {sum(detail.raw_ticks)}"
            )
        if detail.total_ticks == 0:
            raise DecodeError(f"section {section.section_id} has an empty detail trace")
        sections.append(section)
        expected_first = section.end_frame
    if expected_first != header.frame_count:
        raise DecodeError("section ranges do not cover every frame")

    section_by_frame: list[int] = [0] * header.frame_count
    for section in sections:
        for frame_index in range(section.first_frame, section.end_frame):
            section_by_frame[frame_index] = section.section_id

    frame_block = HEADER_SIZE + SECTION_COUNT * SECTION_RECORD_SIZE
    frames: list[Frame] = []
    route_hash_parts: list[bytes] = []
    for index in range(header.frame_count):
        offset = frame_block + index * FRAME_RECORD_SIZE
        record = payload[offset : offset + FRAME_RECORD_SIZE]
        flags = record[22]
        packed_input = record[23]
        if flags & ~KNOWN_FRAME_FLAGS:
            raise DecodeError(
                f"frame {index} has unknown flags 0x{flags & ~KNOWN_FRAME_FLAGS:02X}"
            )
        if packed_input & 0x80:
            raise DecodeError(f"frame {index} has a non-zero reserved input bit")
        move_code = packed_input & 3
        turn_code = (packed_input >> 2) & 3
        look_code = (packed_input >> 4) & 3
        if 3 in (move_code, turn_code, look_code):
            raise DecodeError(f"frame {index} has an invalid packed input axis")
        frame = Frame(
            index=index,
            section_id=section_by_frame[index],
            total_ticks=_u16(record, 0),
            update_ticks=_u16(record, 2),
            render_ticks=_u16(record, 4),
            swap_ticks=_u16(record, 6),
            state_hash=_u32(record, 8),
            position_x_raw=_s24(record, 12),
            position_y_raw=_s24(record, 15),
            position_z_raw=_s24(record, 18),
            room=record[21],
            flags=flags,
            move_axis=move_code - 1,
            turn_axis=turn_code - 1,
            look_axis=look_code - 1,
            buttons_active=bool(packed_input & 0x40),
        )
        component_sum = (
            frame.update_ticks + frame.render_ticks + frame.swap_ticks
        )
        if frame.total_ticks != min(component_sum, 65535):
            raise DecodeError(
                f"frame {index} total {frame.total_ticks} does not match "
                f"clamped component sum {min(component_sum, 65535)}"
            )
        if frame.room >= 8:
            raise DecodeError(f"frame {index} room {frame.room} is invalid")
        section = sections[frame.section_id - 1]
        if frame.freecam != bool(section.flags & SECTION_FREECAM):
            raise DecodeError(
                f"frame {index} freecam flag disagrees with section "
                f"{section.section_id}"
            )
        frames.append(frame)
        route_hash_parts.append(record[8:12])

    detailed_count = 0
    crossing_count = 0
    for section in sections:
        section_frames = frames[section.first_frame : section.end_frame]
        detailed = [frame for frame in section_frames if frame.detailed]
        if len(detailed) != 1:
            raise DecodeError(
                f"section {section.section_id} has {len(detailed)} detailed "
                "frames; expected one"
            )
        if detailed[0].index != section.detailed_frame:
            raise DecodeError(
                f"section {section.section_id} detail record names frame "
                f"{section.detailed_frame}, flag is on {detailed[0].index}"
            )
        if not (header.flags & FLAG_FIXED_TRACE_FRAMES):
            maximum_render = max(frame.render_ticks for frame in section_frames)
            first_maximum = next(
                frame.index
                for frame in section_frames
                if frame.render_ticks == maximum_render
            )
            if section.detailed_frame != first_maximum:
                raise DecodeError(
                    f"section {section.section_id} detailed frame "
                    f"{section.detailed_frame} is not its first slowest render "
                    f"frame {first_maximum}"
                )
        section_crossings = sum(frame.crossed_portal for frame in section_frames)
        if section_crossings != section.crossing_count:
            raise DecodeError(
                f"section {section.section_id} crossing count is "
                f"{section.crossing_count}, frame flags show {section_crossings}"
            )
        if any(frame.section_end for frame in section_frames[:-1]):
            raise DecodeError(
                f"section {section.section_id} has a premature section-end flag"
            )
        if not section_frames[-1].section_end:
            raise DecodeError(
                f"section {section.section_id} final frame lacks section-end flag"
            )
        if section_frames[-1].state_hash != section.state_hash:
            raise DecodeError(
                f"section {section.section_id} endpoint state hash disagrees "
                "with its final frame"
            )
        if section_frames[-1].room != section.room:
            raise DecodeError(
                f"section {section.section_id} endpoint room disagrees with its "
                "final frame"
            )
        detailed_count += 1
        crossing_count += section_crossings
    if detailed_count != header.detailed_frames:
        raise DecodeError("header detailed-frame count disagrees with sections")
    if crossing_count != header.actual_crossings:
        raise DecodeError(
            f"header says {header.actual_crossings} crossings, found {crossing_count}"
        )
    crossing_frames = tuple(
        frame.index for frame in frames if frame.crossed_portal
    )
    if crossing_frames != EXPECTED_CROSSING_FRAMES:
        raise DecodeError(
            f"portal crossings are at frames {crossing_frames}; expected "
            f"{EXPECTED_CROSSING_FRAMES}"
        )
    route_hash = _fnv1a(route_hash_parts)
    if route_hash != header.route_state_hash:
        raise DecodeError(
            "route-state hash mismatch: "
            f"stored {_hex32(header.route_state_hash)}, computed {_hex32(route_hash)}"
        )
    if sections[-1].logical_hash != header.final_logical_hash:
        raise DecodeError("final logical hash disagrees with final section")
    if sections[-1].presented_hash != header.final_presented_hash:
        raise DecodeError("final presented hash disagrees with final section")

    warnings: list[str] = []
    saturated = [frame.index for frame in frames if frame.total_ticks == 65535]
    if saturated:
        warnings.append(
            f"{len(saturated)} frame total(s) saturated at 65535 ticks; "
            "the exact recorded aggregate cannot be reconstructed"
        )
    elif sum(frame.total_ticks for frame in frames) != header.recorded_total_ticks:
        raise DecodeError(
            "header recorded-total ticks disagree with frame records"
        )
    if header.wall_ticks < header.recorded_total_ticks:
        warnings.append(
            "route wall ticks are below summed frame ticks; inspect timer wrap"
        )
    if wrapper.kind == "cemu-ram-dump" and len(wrapper.dump_offsets) > 1:
        warnings.append(
            f"RAM dump contains {len(wrapper.dump_offsets)} identical valid "
            "copies; the first was selected"
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


def clean_frames(frames: Sequence[Frame]) -> list[Frame]:
    """Return timings accepted for clean statistics.

    T3DLIV1 marks one diagnostic source frame per section.  The decoder always
    excludes those ten selected frames, as required by the benchmark contract.
    """

    return [frame for frame in frames if not frame.detailed]


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
            "total_ticks": 0,
            "duration_ms": 0.0,
            "average_fps": None,
            "median_fps": None,
            "one_percent_low_fps": None,
        }
    total_ticks = sum(ticks)
    frame_ms = [ticks_to_ms(value, hz) for value in ticks]
    median_ticks = statistics.median(ticks)
    low_fps, low_count = _low_fps(ticks, hz, 0.01)
    threshold = max(2.0 * median_ticks, hz / 30.0)
    return {
        "frame_count": len(frames),
        "total_ticks": total_ticks,
        "duration_ms": ticks_to_ms(total_ticks, hz),
        "frame_time_ms": _metric(frame_ms),
        "average_fps": len(frames) * hz / total_ticks
        if total_ticks
        else float("inf"),
        "median_fps": hz / median_ticks if median_ticks else float("inf"),
        "minimum_fps": hz / max(ticks) if max(ticks) else float("inf"),
        "maximum_fps": hz / min(ticks) if min(ticks) else float("inf"),
        "one_percent_low_fps": low_fps,
        "one_percent_low_frame_count": low_count,
        "spike_threshold_ms": ticks_to_ms(threshold, hz),
        "spike_count": sum(value > threshold for value in ticks),
        "over_33_333_ms": sum(value * 30 > hz for value in ticks),
        "over_50_ms": sum(value * 20 > hz for value in ticks),
        "over_100_ms": sum(value * 10 > hz for value in ticks),
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
    for index, name in enumerate(CATEGORY_NAMES):
        raw = detail.raw_ticks[index]
        entries = detail.entries[index]
        overhead = (entries * switch_cost_q8 + 128) >> 8
        corrected = max(0, raw - overhead)
        corrected_total += corrected
        categories[name] = {
            "raw_ticks": raw,
            "entries": entries,
            "switch_overhead_ticks": overhead,
            "corrected_ticks": corrected,
            "corrected_ms": ticks_to_ms(corrected, trace_hz),
            "overhead_clamped": overhead > raw,
        }
    for category in categories.values():
        category["corrected_share_percent"] = (
            category["corrected_ticks"] * 100.0 / corrected_total
            if corrected_total
            else 0.0
        )
    return {
        "raw_total_ticks": detail.total_ticks,
        "raw_total_ms": ticks_to_ms(detail.total_ticks, trace_hz),
        "corrected_total_ticks": corrected_total,
        "corrected_total_ms": ticks_to_ms(corrected_total, trace_hz),
        "categories": categories,
        "counters": dict(zip(COUNTER_NAMES, detail.counters)),
    }


def section_summary(report: LiveReport, section: Section) -> dict[str, Any]:
    observed = report.frames_for_section(section)
    clean = clean_frames(observed)
    detail = corrected_detail(
        section.detail,
        report.header.switch_cost_q8,
        report.header.trace_timer_hz,
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
        "crossing_count": section.crossing_count,
        "logical_hash": _hex32(section.logical_hash),
        "presented_hash": _hex32(section.presented_hash),
        "state_hash": _hex32(section.state_hash),
        "portal_0_lod": section.portal_lods[0],
        "portal_1_lod": section.portal_lods[1],
        "endpoint_room": section.room,
        "clean_timing": timing_summary(clean, report.header.clock_hz),
        "observed_timing": timing_summary(observed, report.header.clock_hz),
        "detail": detail,
    }


def build_section_summaries(report: LiveReport) -> list[dict[str, Any]]:
    return [section_summary(report, section) for section in report.sections]


def _flatten_timing(
    scope: str,
    timing: dict[str, Any],
    detailed_excluded: int,
) -> dict[str, Any]:
    frame_ms = timing.get("frame_time_ms", {})
    return {
        "scope": scope,
        "frame_count": timing.get("frame_count"),
        "detailed_frames_excluded": detailed_excluded,
        "total_ticks": timing.get("total_ticks"),
        "duration_ms": timing.get("duration_ms"),
        "frame_ms_min": frame_ms.get("min"),
        "frame_ms_max": frame_ms.get("max"),
        "frame_ms_mean": frame_ms.get("mean"),
        "frame_ms_median": frame_ms.get("median"),
        "frame_ms_pstdev": frame_ms.get("pstdev"),
        "average_fps": timing.get("average_fps"),
        "median_fps": timing.get("median_fps"),
        "minimum_fps": timing.get("minimum_fps"),
        "maximum_fps": timing.get("maximum_fps"),
        "one_percent_low_fps": timing.get("one_percent_low_fps"),
        "one_percent_low_frame_count": timing.get(
            "one_percent_low_frame_count"
        ),
        "spike_threshold_ms": timing.get("spike_threshold_ms"),
        "spike_count": timing.get("spike_count"),
        "over_33_333_ms": timing.get("over_33_333_ms"),
        "over_50_ms": timing.get("over_50_ms"),
        "over_100_ms": timing.get("over_100_ms"),
        "update_ms_mean": timing.get("update_ms", {}).get("mean"),
        "render_ms_mean": timing.get("render_ms", {}).get("mean"),
        "swap_ms_mean": timing.get("swap_ms", {}).get("mean"),
    }


def summary_rows(report: LiveReport) -> list[dict[str, Any]]:
    clean = clean_frames(report.frames)
    metadata = {
        "build_version": _hex32(report.header.build_version),
        "route_fingerprint": _hex32(report.header.route_fingerprint),
        "warmup_frames": report.header.warmup_frames,
        "portal_crossings": report.header.actual_crossings,
        "graphics_init_ms": ticks_to_ms(
            report.header.graphics_init_ticks, report.header.clock_hz
        ),
        "first_frame_ms": ticks_to_ms(
            report.header.first_frame_ticks, report.header.clock_hz
        ),
        "route_wall_ms": ticks_to_ms(
            report.header.wall_ticks, report.header.clock_hz
        ),
        "recorded_total_ms": ticks_to_ms(
            report.header.recorded_total_ticks, report.header.clock_hz
        ),
        "switch_cost_ticks": report.header.switch_cost_q8 / 256.0,
    }
    rows = [
        _flatten_timing(
            "overall_clean",
            timing_summary(clean, report.header.clock_hz),
            len(report.frames) - len(clean),
        ),
        _flatten_timing(
            "overall_observed",
            timing_summary(report.frames, report.header.clock_hz),
            0,
        ),
    ]
    for row in rows:
        row.update(metadata)
    return rows


def section_rows(report: LiveReport) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for summary in build_section_summaries(report):
        timing = summary["clean_timing"]
        row = {
            "section_index": summary["section_index"],
            "section_id": summary["section_id"],
            "section_name": summary["section_name"],
            "section_flags": f"0x{summary['section_flags']:02X}",
            "section_flag_names": "|".join(summary["section_flag_names"]),
            "first_frame": summary["first_frame"],
            "frame_count": summary["frame_count"],
            "clean_frame_count": summary["clean_frame_count"],
            "detailed_frame": summary["detailed_frame"],
            "crossing_count": summary["crossing_count"],
            "logical_hash": summary["logical_hash"],
            "presented_hash": summary["presented_hash"],
            "state_hash": summary["state_hash"],
            "portal_0_lod": summary["portal_0_lod"],
            "portal_1_lod": summary["portal_1_lod"],
            "endpoint_room": summary["endpoint_room"],
            "clean_frame_ms_mean": timing["frame_time_ms"]["mean"],
            "clean_frame_ms_median": timing["frame_time_ms"]["median"],
            "clean_average_fps": timing["average_fps"],
            "clean_median_fps": timing["median_fps"],
            "clean_1_percent_low_fps": timing["one_percent_low_fps"],
            "detail_raw_total_ticks": summary["detail"]["raw_total_ticks"],
            "detail_corrected_total_ticks": summary["detail"][
                "corrected_total_ticks"
            ],
            "detail_corrected_total_ms": summary["detail"][
                "corrected_total_ms"
            ],
        }
        for name in CATEGORY_NAMES:
            category = summary["detail"]["categories"][name]
            row[f"{name}_raw_ticks"] = category["raw_ticks"]
            row[f"{name}_entries"] = category["entries"]
            row[f"{name}_switch_overhead_ticks"] = category[
                "switch_overhead_ticks"
            ]
            row[f"{name}_corrected_ticks"] = category["corrected_ticks"]
            row[f"{name}_corrected_ms"] = category["corrected_ms"]
            row[f"{name}_corrected_share_percent"] = category[
                "corrected_share_percent"
            ]
        row.update(summary["detail"]["counters"])
        rows.append(row)
    return rows


def frame_rows(report: LiveReport) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    elapsed_ticks = 0
    hz = report.header.clock_hz
    section_details = {
        section.section_id: corrected_detail(
            section.detail,
            report.header.switch_cost_q8,
            report.header.trace_timer_hz,
        )
        for section in report.sections
    }
    for frame in report.frames:
        section = report.section_for_frame(frame)
        elapsed_ticks += (
            frame.update_ticks + frame.render_ticks + frame.swap_ticks
        )
        x, y, z = frame.position
        row: dict[str, Any] = {
            "frame_index": frame.index,
            "section_id": section.section_id,
            "section_name": section.name,
            "simulation_time_seconds": (
                (frame.index + 1) * report.header.elapsed_ticks_per_frame
                / report.header.simulation_ticks_per_second
            ),
            "measured_elapsed_ticks": elapsed_ticks,
            "measured_elapsed_ms": ticks_to_ms(elapsed_ticks, hz),
            "total_ticks": frame.total_ticks,
            "total_ms": ticks_to_ms(frame.total_ticks, hz),
            "instantaneous_fps": hz / frame.total_ticks
            if frame.total_ticks
            else float("inf"),
            "update_ticks": frame.update_ticks,
            "update_ms": ticks_to_ms(frame.update_ticks, hz),
            "render_ticks": frame.render_ticks,
            "render_ms": ticks_to_ms(frame.render_ticks, hz),
            "swap_ticks": frame.swap_ticks,
            "swap_ms": ticks_to_ms(frame.swap_ticks, hz),
            "state_hash": _hex32(frame.state_hash),
            "position_x_raw": frame.position_x_raw,
            "position_y_raw": frame.position_y_raw,
            "position_z_raw": frame.position_z_raw,
            "position_x": x,
            "position_y": y,
            "position_z": z,
            "room": frame.room,
            "flags": f"0x{frame.flags:02X}",
            "detailed": int(frame.detailed),
            "excluded_from_clean_stats": int(frame.detailed),
            "crossed_portal": int(frame.crossed_portal),
            "changed": int(frame.changed),
            "section_end": int(frame.section_end),
            "freecam": int(frame.freecam),
            "move_axis": frame.move_axis,
            "turn_axis": frame.turn_axis,
            "look_axis": frame.look_axis,
            "buttons_active": int(frame.buttons_active),
        }
        if frame.detailed:
            detail = section_details[section.section_id]
            row["detail_corrected_total_ms"] = detail["corrected_total_ms"]
            for name in CATEGORY_NAMES:
                row[f"{name}_corrected_ms"] = detail["categories"][name][
                    "corrected_ms"
                ]
            row.update(detail["counters"])
        else:
            row["detail_corrected_total_ms"] = None
            for name in CATEGORY_NAMES:
                row[f"{name}_corrected_ms"] = None
            for name in COUNTER_NAMES:
                row[name] = None
        rows.append(row)
    return rows


def portal_crossing_rows(
    report: LiveReport, radius: int = 3
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    hz = report.header.clock_hz
    crossings = [frame for frame in report.frames if frame.crossed_portal]
    for crossing_index, frame in enumerate(crossings, start=1):
        section = report.section_for_frame(frame)
        before = report.frames[max(0, frame.index - radius) : frame.index]
        after = report.frames[
            frame.index + 1 : min(len(report.frames), frame.index + radius + 1)
        ]
        window = before + [frame] + after
        before_clean = clean_frames(before)
        after_clean = clean_frames(after)
        window_clean = clean_frames(window)
        before_summary = timing_summary(before_clean, hz)
        after_summary = timing_summary(after_clean, hz)
        rows.append(
            {
                "crossing_index": crossing_index,
                "frame_index": frame.index,
                "section_id": section.section_id,
                "section_name": section.name,
                "crossing_excluded_from_clean_stats": int(frame.detailed),
                "crossing_total_ticks": frame.total_ticks,
                "crossing_total_ms": ticks_to_ms(frame.total_ticks, hz),
                "crossing_render_ms": ticks_to_ms(frame.render_ticks, hz),
                "room_after_crossing": frame.room,
                "position_x": frame.position[0],
                "position_y": frame.position[1],
                "position_z": frame.position[2],
                "window_start": window[0].index,
                "window_end": window[-1].index,
                "window_clean_frames": len(window_clean),
                "window_clean_mean_ms": (
                    timing_summary(window_clean, hz)
                    .get("frame_time_ms", {})
                    .get("mean")
                ),
                "window_clean_max_ms": max(
                    (ticks_to_ms(item.total_ticks, hz) for item in window_clean),
                    default=None,
                ),
                "pre_clean_mean_ms": before_summary.get(
                    "frame_time_ms", {}
                ).get("mean"),
                "pre_clean_average_fps": before_summary.get("average_fps"),
                "post_clean_mean_ms": after_summary.get(
                    "frame_time_ms", {}
                ).get("mean"),
                "post_clean_average_fps": after_summary.get("average_fps"),
            }
        )
    return rows


def _percent_change(current: float | None, baseline: float | None) -> float | None:
    if current is None or baseline in (None, 0):
        return None
    return (current / baseline - 1.0) * 100.0


def compare_reports(current: LiveReport, baseline: LiveReport) -> dict[str, Any]:
    route_fields = (
        "route_fingerprint",
        "frame_count",
        "section_count",
        "render_width",
        "render_height",
        "render_scale",
        "recursion_limit",
        "simulation_ticks_per_second",
        "elapsed_ticks_per_frame",
        "expected_crossings",
    )
    mismatches = [
        name
        for name in route_fields
        if getattr(current.header, name) != getattr(baseline.header, name)
    ]
    if mismatches:
        raise DecodeError(
            "baseline is not the same route/configuration; mismatched: "
            + ", ".join(mismatches)
        )
    for section, base_section in zip(current.sections, baseline.sections):
        layout = (
            section.section_id,
            section.flags,
            section.first_frame,
            section.frame_count,
            section.name,
        )
        base_layout = (
            base_section.section_id,
            base_section.flags,
            base_section.first_frame,
            base_section.frame_count,
            base_section.name,
        )
        if layout != base_layout:
            raise DecodeError(
                f"section {section.section_id} configuration differs"
            )
        endpoints = (
            section.logical_hash,
            section.presented_hash,
            section.state_hash,
            section.lod_state,
            section.room,
            section.crossing_count,
        )
        base_endpoints = (
            base_section.logical_hash,
            base_section.presented_hash,
            base_section.state_hash,
            base_section.lod_state,
            base_section.room,
            base_section.crossing_count,
        )
        if endpoints != base_endpoints:
            raise DecodeError(
                f"section {section.section_id} endpoint hashes/state differ; "
                "reports are not exact-output comparable"
            )
    for frame, base_frame in zip(current.frames, baseline.frames):
        route_state = (
            frame.state_hash,
            frame.position_x_raw,
            frame.position_y_raw,
            frame.position_z_raw,
            frame.room,
            frame.move_axis,
            frame.turn_axis,
            frame.look_axis,
            frame.buttons_active,
            frame.crossed_portal,
            frame.changed,
            frame.section_end,
            frame.freecam,
        )
        base_state = (
            base_frame.state_hash,
            base_frame.position_x_raw,
            base_frame.position_y_raw,
            base_frame.position_z_raw,
            base_frame.room,
            base_frame.move_axis,
            base_frame.turn_axis,
            base_frame.look_axis,
            base_frame.buttons_active,
            base_frame.crossed_portal,
            base_frame.changed,
            base_frame.section_end,
            base_frame.freecam,
        )
        if route_state != base_state:
            raise DecodeError(f"route diverges at frame {frame.index}")

    scopes: list[tuple[str, str, list[Frame], list[Frame], Section | None]] = [
        (
            "overall",
            "ALL_CLEAN",
            clean_frames(current.frames),
            clean_frames(baseline.frames),
            None,
        )
    ]
    for section, base_section in zip(current.sections, baseline.sections):
        scopes.append(
            (
                "section",
                section.name,
                clean_frames(current.frames_for_section(section)),
                clean_frames(baseline.frames_for_section(base_section)),
                section,
            )
        )
    rows: list[dict[str, Any]] = []
    for scope, name, frames, base_frames, section in scopes:
        timing = timing_summary(frames, current.header.clock_hz)
        base_timing = timing_summary(base_frames, baseline.header.clock_hz)
        mean = timing["frame_time_ms"]["mean"]
        base_mean = base_timing["frame_time_ms"]["mean"]
        row: dict[str, Any] = {
            "scope": scope,
            "name": name,
            "current_clean_frames": len(frames),
            "baseline_clean_frames": len(base_frames),
            "current_frame_ms_mean": mean,
            "baseline_frame_ms_mean": base_mean,
            "frame_ms_delta": mean - base_mean,
            "frame_time_percent_change": _percent_change(mean, base_mean),
            "current_frame_ms_median": timing["frame_time_ms"]["median"],
            "baseline_frame_ms_median": base_timing["frame_time_ms"]["median"],
            "current_average_fps": timing["average_fps"],
            "baseline_average_fps": base_timing["average_fps"],
            "average_fps_percent_change": _percent_change(
                timing["average_fps"], base_timing["average_fps"]
            ),
            "current_1_percent_low_fps": timing["one_percent_low_fps"],
            "baseline_1_percent_low_fps": base_timing[
                "one_percent_low_fps"
            ],
        }
        if section is not None:
            base_section = baseline.sections[section.index]
            detail_comparable = (
                section.detailed_frame == base_section.detailed_frame
                and current.frames[section.detailed_frame].state_hash
                == baseline.frames[base_section.detailed_frame].state_hash
            )
            row["current_detailed_frame"] = section.detailed_frame
            row["baseline_detailed_frame"] = base_section.detailed_frame
            row["detail_trace_comparable"] = int(detail_comparable)
            detail = corrected_detail(
                section.detail,
                current.header.switch_cost_q8,
                current.header.trace_timer_hz,
            )
            base_detail = corrected_detail(
                base_section.detail,
                baseline.header.switch_cost_q8,
                baseline.header.trace_timer_hz,
            )
            for category in CATEGORY_NAMES:
                current_ms = detail["categories"][category]["corrected_ms"]
                baseline_ms = base_detail["categories"][category][
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
    if current.header.build_version == baseline.header.build_version:
        warnings.append("build versions are identical")
    if current.header.clock_hz != baseline.header.clock_hz:
        warnings.append("clock frequencies differ; comparisons use milliseconds")
    return {
        "baseline_source": str(baseline.source),
        "baseline_build_version": _hex32(baseline.header.build_version),
        "exact_route_and_endpoint_hashes": True,
        "warnings": warnings,
        "rows": rows,
    }


def _wrapper_json(wrapper: WrapperInfo) -> dict[str, Any]:
    result = asdict(wrapper)
    result["dump_offsets"] = [f"0x{offset:X}" for offset in wrapper.dump_offsets]
    if wrapper.variable_type is not None:
        result["variable_type_hex"] = f"0x{wrapper.variable_type:02X}"
    if wrapper.wrapper_checksum is not None:
        result["wrapper_checksum_hex"] = (
            f"0x{wrapper.wrapper_checksum:04X}"
        )
    return result


def _header_json(header: Header) -> dict[str, Any]:
    result = asdict(header)
    result.update(
        {
            "flags_hex": f"0x{header.flags:08X}",
            "flag_names": list(header.flag_names),
            "build_version_hex": _hex32(header.build_version),
            "route_fingerprint_hex": _hex32(header.route_fingerprint),
            "body_crc32_hex": _hex32(header.body_crc32),
            "route_state_hash_hex": _hex32(header.route_state_hash),
            "final_logical_hash_hex": _hex32(header.final_logical_hash),
            "final_presented_hash_hex": _hex32(
                header.final_presented_hash
            ),
            "switch_cost_ticks": header.switch_cost_q8 / 256.0,
        }
    )
    return result


def report_json(
    report: LiveReport,
    comparison: dict[str, Any] | None = None,
) -> dict[str, Any]:
    clean = clean_frames(report.frames)
    result: dict[str, Any] = {
        "schema": "T3DLIV1",
        "source": str(report.source),
        "payload_size": len(report.payload),
        "payload_sha256": report.payload_sha256,
        "validation": {
            "schema": "valid",
            "wrapper_checksum": (
                "valid" if report.wrapper.kind == "ti-appvar" else "not-applicable"
            ),
            "body_crc32": "valid",
            "unique_report": "valid",
            "reserved_fields": "valid",
            "section_frame_layout": "valid",
            "route_hash_and_endpoints": "valid",
            "portal_crossing_frames": list(EXPECTED_CROSSING_FRAMES),
        },
        "wrapper": _wrapper_json(report.wrapper),
        "header": _header_json(report.header),
        "timing_methodology": {
            "clean_statistics_exclude_detailed_frames": True,
            "detailed_frames_excluded": len(report.frames) - len(clean),
            "one_percent_low": (
                "aggregate FPS of the slowest ceil(1% * clean frames)"
            ),
            "phase_switch_correction": (
                "round(entries * switch_cost_q8 / 256) subtracted per category"
            ),
            "observed_statistics_include_detailed_frames": True,
        },
        "overall_clean": timing_summary(clean, report.header.clock_hz),
        "overall_observed": timing_summary(
            report.frames, report.header.clock_hz
        ),
        "sections": build_section_summaries(report),
        "frames": frame_rows(report),
        "portal_crossings": portal_crossing_rows(report),
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
    result = "".join(
        character if character.isalnum() or character in "-_" else "_"
        for character in value
    ).strip("_")
    return result or APPVAR_NAME


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
        "summary": output_dir / f"{prefix}-summary.csv",
        "sections": output_dir / f"{prefix}-sections.csv",
        "frames": output_dir / f"{prefix}-frames.csv",
        "crossings": output_dir / f"{prefix}-portal-crossings.csv",
        "json": output_dir / f"{prefix}.json",
    }
    paths["raw"].write_bytes(report.payload)
    _write_csv(paths["summary"], summary_rows(report))
    _write_csv(paths["sections"], section_rows(report))
    _write_csv(paths["frames"], frame_rows(report))
    _write_csv(paths["crossings"], portal_crossing_rows(report))
    if comparison is not None:
        paths["compare"] = output_dir / f"{prefix}-compare.csv"
        _write_csv(paths["compare"], comparison["rows"])
    paths["json"].write_text(
        json.dumps(
            report_json(report, comparison),
            indent=2,
            sort_keys=True,
            allow_nan=False,
        )
        + "\n",
        encoding="utf-8",
    )
    return paths


def print_summary(report: LiveReport) -> None:
    clean = clean_frames(report.frames)
    timing = timing_summary(clean, report.header.clock_hz)
    sections = build_section_summaries(report)
    slowest = max(
        sections,
        key=lambda item: item["clean_timing"]["frame_time_ms"]["mean"],
    )
    phase_ticks = {
        name: sum(
            corrected_detail(
                section.detail,
                report.header.switch_cost_q8,
                report.header.trace_timer_hz,
            )["categories"][name]["corrected_ticks"]
            for section in report.sections
        )
        for name in CATEGORY_NAMES
    }
    top_phases = sorted(phase_ticks.items(), key=lambda item: item[1], reverse=True)[:3]
    print(
        f"T3DLIV1: {len(report.frames)} frames, {len(clean)} clean, "
        f"{len(report.sections)} sections"
    )
    print(
        f"Build {_hex32(report.header.build_version)}, route "
        f"{_hex32(report.header.route_fingerprint)}, "
        f"{report.header.actual_crossings} crossings"
    )
    print(
        f"Clean: {timing['frame_time_ms']['mean']:.3f} ms mean, "
        f"{timing['frame_time_ms']['median']:.3f} ms median, "
        f"{timing['average_fps']:.2f} FPS, "
        f"{timing['one_percent_low_fps']:.2f} FPS 1% low"
    )
    print(
        f"Slowest section: {slowest['section_name']} at "
        f"{slowest['clean_timing']['frame_time_ms']['mean']:.3f} ms mean"
    )
    print(
        "Largest corrected detail phases: "
        + ", ".join(
            f"{name}={ticks_to_ms(ticks, report.header.trace_timer_hz):.3f} ms"
            for name, ticks in top_phases
        )
    )
    for warning in report.warnings:
        print(f"Warning: {warning}", file=sys.stderr)


def _pack_u24(value: int) -> bytes:
    return int(value & 0xFFFFFF).to_bytes(3, "little")


def _make_test_payload(*, render_adjustment: int = 0) -> bytes:
    body = bytearray(REPORT_SIZE - HEADER_SIZE)
    frame_block = SECTION_COUNT * SECTION_RECORD_SIZE
    detail_frames = tuple(
        sum(config[2] for config in EXPECTED_SECTIONS[:index])
        + config[2] // 2
        for index, config in enumerate(EXPECTED_SECTIONS)
    )
    route_parts: list[bytes] = []
    state_hashes: list[int] = []
    recorded_total = 0
    room = 0
    section_rooms: list[int] = []

    section_index = 0
    next_section_end = EXPECTED_SECTIONS[0][2]
    for frame_index in range(FRAME_COUNT):
        while frame_index >= next_section_end:
            section_index += 1
            next_section_end += EXPECTED_SECTIONS[section_index][2]
        section_flags = EXPECTED_SECTIONS[section_index][1]
        if frame_index in EXPECTED_CROSSING_FRAMES:
            room ^= 1
        update_ticks = 9 + frame_index % 3
        render_ticks = 100 + frame_index % 17
        if frame_index == detail_frames[section_index]:
            render_ticks = 400 + section_index * 13
        if frame_index == 0:
            render_ticks += render_adjustment
        swap_ticks = 5 + frame_index % 2
        total_ticks = update_ticks + render_ticks + swap_ticks
        state_hash = (0x41000000 + frame_index * 0x1021) & 0xFFFFFFFF
        record_offset = frame_block + frame_index * FRAME_RECORD_SIZE
        record = memoryview(body)[
            record_offset : record_offset + FRAME_RECORD_SIZE
        ]
        struct.pack_into("<HHHHI", record, 0, total_ticks, update_ticks, render_ticks, swap_ticks, state_hash)
        record[12:15] = _pack_u24(0x1000 + frame_index * 3)
        record[15:18] = _pack_u24(0x2000 - frame_index)
        record[18:21] = _pack_u24(0x3000 + frame_index * 2)
        record[21] = room
        flags = FRAME_CHANGED
        if frame_index in EXPECTED_CROSSING_FRAMES:
            flags |= FRAME_CROSSED_PORTAL
        if frame_index == detail_frames[section_index]:
            flags |= FRAME_DETAILED
        if frame_index + 1 == next_section_end:
            flags |= FRAME_SECTION_END
        if section_flags & SECTION_FREECAM:
            flags |= FRAME_FREECAM
        record[22] = flags
        turn_code = 2 if section_flags & SECTION_TURN else 1
        look_code = 2 if section_flags & SECTION_PITCH else 1
        record[23] = 1 | (turn_code << 2) | (look_code << 4)
        route_parts.append(bytes(record[8:12]))
        state_hashes.append(state_hash)
        recorded_total += total_ticks
        if frame_index + 1 == next_section_end:
            section_rooms.append(room)

    first_frame = 0
    logical_hashes: list[int] = []
    presented_hashes: list[int] = []
    for index, (name, flags, frame_count) in enumerate(EXPECTED_SECTIONS):
        record_offset = index * SECTION_RECORD_SIZE
        record = memoryview(body)[
            record_offset : record_offset + SECTION_RECORD_SIZE
        ]
        record[0] = index + 1
        record[1] = flags
        struct.pack_into("<HHH", record, 2, first_frame, frame_count, detail_frames[index])
        encoded_name = name.encode("ascii")
        record[8 : 8 + len(encoded_name)] = encoded_name
        logical_hash = 0x51000000 + index * 0x101
        presented_hash = 0x61000000 + index * 0x103
        logical_hashes.append(logical_hash)
        presented_hashes.append(presented_hash)
        struct.pack_into("<III", record, 24, logical_hash, presented_hash, state_hashes[first_frame + frame_count - 1])
        section_crossings = sum(
            first_frame <= frame < first_frame + frame_count
            for frame in EXPECTED_CROSSING_FRAMES
        )
        struct.pack_into("<H", record, 36, section_crossings)
        record[38] = ((index + 1) % 3) | (((index + 2) % 3) << 2)
        record[39] = section_rooms[index]
        raw_ticks = [55 + index * 3 + category for category in range(CATEGORY_COUNT)]
        for category, value in enumerate(raw_ticks):
            record[40 + category * 3 : 43 + category * 3] = _pack_u24(value)
            struct.pack_into("<H", record, 70 + category * 2, 2 + category % 3)
        for counter in range(COUNTER_COUNT):
            struct.pack_into("<H", record, 90 + counter * 2, 10 + index + counter)
        struct.pack_into("<I", record, 112, sum(raw_ticks))
        first_frame += frame_count

    header = bytearray(HEADER_SIZE)
    header[:8] = MAGIC
    struct.pack_into("<HHI", header, 8, FORMAT_VERSION, HEADER_SIZE, KNOWN_HEADER_FLAGS)
    struct.pack_into("<II", header, 16, 32768, 32768)
    struct.pack_into("<II", header, 24, 0x26080601, 0x7A31BEEF)
    struct.pack_into("<HHHHHH", header, 32, REPORT_SIZE, SECTION_COUNT, WARMUP_FRAMES, FRAME_COUNT, SECTION_RECORD_SIZE, FRAME_RECORD_SIZE)
    header[44:50] = bytes((64, 48, 5, 1, CATEGORY_COUNT, COUNTER_COUNT))
    struct.pack_into("<HHH", header, 50, 30, 1, EXPECTED_CROSSINGS)
    struct.pack_into("<I", header, 56, 320)
    struct.pack_into("<III", header, 64, 900, 700, recorded_total)
    struct.pack_into("<III", header, 76, _fnv1a(route_parts), logical_hashes[-1], presented_hashes[-1])
    struct.pack_into("<HHH", header, 88, EXPECTED_CROSSINGS, SECTION_COUNT, REPORT_SIZE)
    header[94] = ROUTE_STEP_COUNT
    struct.pack_into("<I", header, 96, recorded_total + 500)
    struct.pack_into("<H", header, 100, 300)
    header[103] = 1
    struct.pack_into("<I", header, 60, zlib.crc32(body) & 0xFFFFFFFF)
    return bytes(header + body)


def _make_test_8xv(payload: bytes) -> bytes:
    comment = b"True3D decoder self-test".ljust(42, b"\0")
    variable_length = len(payload) + 2
    entry = bytearray()
    entry.extend(struct.pack("<H", 13))
    entry.extend(struct.pack("<H", variable_length))
    entry.append(APPVAR_TYPE)
    entry.extend(APPVAR_NAME.encode("ascii").ljust(8, b"\0"))
    entry.extend((0, 0x80))
    entry.extend(struct.pack("<H", variable_length))
    entry.extend(struct.pack("<H", len(payload)))
    entry.extend(payload)
    result = bytearray(TI_SIGNATURE_PREFIX)
    result.append(0)
    result.extend(comment)
    result.extend(struct.pack("<H", len(entry)))
    result.extend(entry)
    result.extend(struct.pack("<H", sum(entry) & 0xFFFF))
    return bytes(result)


def _expect_decode_error(action: Any, text_fragment: str) -> None:
    try:
        action()
    except DecodeError as exc:
        if text_fragment not in str(exc):
            raise AssertionError(
                f"expected {text_fragment!r} in decoder error {str(exc)!r}"
            ) from exc
    else:
        raise AssertionError(f"expected DecodeError containing {text_fragment!r}")


def run_self_test() -> None:
    payload = _make_test_payload()
    raw_report = parse_payload(payload, Path("selftest.raw"), WrapperInfo(kind="raw"))
    assert len(raw_report.frames) == FRAME_COUNT
    assert len(raw_report.sections) == SECTION_COUNT
    assert len(clean_frames(raw_report.frames)) == FRAME_COUNT - SECTION_COUNT
    assert tuple(frame.index for frame in raw_report.frames if frame.crossed_portal) == EXPECTED_CROSSING_FRAMES
    assert timing_summary(clean_frames(raw_report.frames), 32768)["one_percent_low_frame_count"] == 9
    assert len(portal_crossing_rows(raw_report)) == EXPECTED_CROSSINGS

    raw_appvar = struct.pack("<H", len(payload)) + payload
    extracted, wrapper = extract_payload(raw_appvar)
    assert extracted == payload and wrapper.kind == "raw-appvar-data"

    wrapped = _make_test_8xv(payload)
    extracted, wrapper = extract_payload(wrapped)
    assert extracted == payload
    assert wrapper.kind == "ti-appvar" and wrapper.archived is True
    wrapped_report = parse_payload(extracted, Path("selftest.8xv"), wrapper)

    dump = b"\xA5" * 137 + payload + b"\x5A" * 211
    extracted, wrapper = extract_payload(dump)
    assert extracted == payload
    assert wrapper.kind == "cemu-ram-dump" and wrapper.dump_offsets == (137,)

    duplicate_dump = payload + b"\0" * 16 + payload
    extracted, wrapper = extract_payload(duplicate_dump)
    assert extracted == payload and len(wrapper.dump_offsets) == 2

    distinct = _make_test_payload(render_adjustment=1)
    _expect_decode_error(
        lambda: extract_payload(payload + b"\0" * 16 + distinct),
        "2 distinct CRC-valid",
    )
    corrupt_wrapper = bytearray(wrapped)
    corrupt_wrapper[-1] ^= 1
    _expect_decode_error(
        lambda: extract_payload(bytes(corrupt_wrapper)),
        "wrapper checksum mismatch",
    )
    corrupt_body = bytearray(payload)
    corrupt_body[-1] ^= 1
    _expect_decode_error(
        lambda: parse_payload(bytes(corrupt_body), Path("bad.raw"), WrapperInfo(kind="raw")),
        "CRC32 mismatch",
    )
    corrupt_reserved = bytearray(payload)
    corrupt_reserved[104] = 1
    _expect_decode_error(
        lambda: parse_payload(bytes(corrupt_reserved), Path("bad.raw"), WrapperInfo(kind="raw")),
        "reserved header",
    )

    adjusted_report = parse_payload(
        distinct, Path("adjusted.raw"), WrapperInfo(kind="raw")
    )
    comparison = compare_reports(adjusted_report, wrapped_report)
    assert len(comparison["rows"]) == SECTION_COUNT + 1
    assert comparison["rows"][0]["frame_time_percent_change"] > 0

    with tempfile.TemporaryDirectory() as directory:
        paths = write_outputs(
            adjusted_report, Path(directory), "selftest", comparison
        )
        assert set(("json", "summary", "sections", "frames", "crossings", "compare")) <= set(paths)
        assert all(path.is_file() and path.stat().st_size for path in paths.values())
        decoded = json.loads(paths["json"].read_text(encoding="utf-8"))
        assert decoded["schema"] == "T3DLIV1"
        assert decoded["overall_clean"]["frame_count"] == FRAME_COUNT - SECTION_COUNT
        assert len(decoded["portal_crossings"]) == EXPECTED_CROSSINGS
        with paths["frames"].open(newline="", encoding="utf-8") as stream:
            assert len(list(csv.DictReader(stream))) == FRAME_COUNT

    print("decode-live-benchmark self-test: PASS")


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Validate and decode True3D T3DLIV1 live benchmark data"
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        help="T3DLIVE.8xv, raw AppVar/report payload, or full CEmu RAM dump",
    )
    parser.add_argument(
        "--compare",
        type=Path,
        help="same-route T3DLIV1 result to use as a performance baseline",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("true3d/benchmark-results"),
        help="directory for decoded JSON and CSV outputs",
    )
    parser.add_argument(
        "--prefix",
        help="output filename prefix (default: input stem)",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run synthetic raw/AppVar/RAM/integrity/output tests and exit",
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
        paths = write_outputs(
            report,
            args.output_dir,
            args.prefix or args.input.stem,
            comparison,
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
