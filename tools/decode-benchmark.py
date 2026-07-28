#!/usr/bin/env python3
"""Decode PortalR 3D benchmark AppVars.

The calculator benchmark writes a compact, checksummed P3DBEN2 payload to the
P3DRES AppVar.  This tool accepts either the transferred .8xv file or the raw
payload and emits machine-readable samples, per-scene summaries, and JSON.

Only the Python standard library is used so the decoder can travel with the
project without adding a host-side dependency.
"""

from __future__ import annotations

import argparse
import csv
import json
import statistics
import struct
import sys
import tempfile
import zlib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Sequence


MAGIC = b"P3DBEN2\0"
FORMAT_VERSION = 2
HEADER_SIZE = 64
SCENE_RECORD_SIZE = 40
SAMPLE_RECORD_SIZE = 80
APPVAR_TYPE = 0x15
TI_SIGNATURE_PREFIX = b"**TI83F*\x1a\x0a"
TI_SIGNATURE_REVISIONS = frozenset((0x00, 0x0A))
FLAG_SWITCH_COST_Q8 = 1 << 6

CATEGORY_NAMES = (
    "admin",
    "wait",
    "background",
    "dda",
    "portal_trace",
    "wall_draw",
    "portal_draw",
)

COUNT_NAMES = (
    "portal_transforms",
    "wall_calls",
    "mask_calls",
    "portal_candidates",
    "linked_exits",
    "textured_rows",
    "dda_steps",
)


class DecodeError(ValueError):
    """Raised when an input fails structural or integrity validation."""


@dataclass(frozen=True)
class WrapperInfo:
    kind: str
    variable_name: str | None = None
    variable_type: int | None = None
    archived: bool | None = None
    comment: str | None = None
    wrapper_checksum: int | None = None


@dataclass(frozen=True)
class Header:
    flags: int
    clock_hz: int
    trace_timer_hz: int
    build_fingerprint: int
    suite_fingerprint: int
    payload_size: int
    scene_count: int
    warmups: int
    samples_per_scene: int
    scene_record_size: int
    sample_record_size: int
    logical_columns: int
    column_width: int
    texture_size: int
    depth_limit: int
    clock_id: int
    category_count: int
    switch_cost_q8: int
    payload_crc32: int


@dataclass(frozen=True)
class Scene:
    index: int
    scene_id: int
    flags: int
    sample_count: int
    first_sample: int
    frame_hash: int
    player_x_raw: int
    player_y_raw: int
    angle_raw: int
    primary: bytes
    secondary: bytes
    name: str

    @property
    def player_x(self) -> float:
        return self.player_x_raw / 256.0

    @property
    def player_y(self) -> float:
        return self.player_y_raw / 256.0

    @property
    def angle_degrees(self) -> float:
        return self.angle_raw * 360.0 / (64.0 * 256.0)


@dataclass(frozen=True)
class Sample:
    index: int
    total_ticks: int
    wait_ticks: int
    background_ticks: int
    columns_ticks: int
    casts: int
    max_depth: int
    status: int
    trace_total_ticks: int
    category_raw_ticks: tuple[int, ...]
    category_entries: tuple[int, ...]
    portal_transforms: int
    wall_calls: int
    mask_calls: int
    portal_candidates: int
    linked_exits: int
    textured_rows: int
    dda_steps: int

    @property
    def detailed(self) -> bool:
        return bool(self.status & 0x01)


@dataclass
class BenchmarkReport:
    source: Path
    wrapper: WrapperInfo
    header: Header
    scenes: list[Scene]
    samples: list[Sample]
    warnings: list[str] = field(default_factory=list)

    def samples_for_scene(self, scene: Scene) -> list[Sample]:
        start = scene.first_sample
        return self.samples[start : start + scene.sample_count]


def _u16(data: bytes, offset: int) -> int:
    return struct.unpack_from("<H", data, offset)[0]


def _u32(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def _s24(data: bytes, offset: int) -> int:
    value = int.from_bytes(data[offset : offset + 3], "little", signed=False)
    return value - (1 << 24) if value & (1 << 23) else value


def _display_ascii(raw: bytes) -> str:
    return raw.split(b"\0", 1)[0].decode("ascii", errors="replace")


def _hex32(value: int) -> str:
    return f"0x{value:08X}"


def extract_payload(blob: bytes) -> tuple[bytes, WrapperInfo]:
    """Extract and validate a P3DBEN payload from raw bytes or a TI AppVar."""

    if blob.startswith(MAGIC):
        return blob, WrapperInfo(kind="raw")

    # Some dumping tools return the AppVar's data field, including its inner
    # two-byte length, instead of either a .8xv wrapper or the pure payload.
    if len(blob) >= 2 + len(MAGIC) and blob[2 : 2 + len(MAGIC)] == MAGIC:
        inner_size = _u16(blob, 0)
        if inner_size != len(blob) - 2:
            raise DecodeError(
                f"raw AppVar data length says {inner_size} bytes, "
                f"but {len(blob) - 2} bytes follow"
            )
        return blob[2:], WrapperInfo(kind="raw-appvar-data")

    if not blob.startswith(b"**TI83F*"):
        raise DecodeError(
            "input is neither a raw P3DBEN2 payload nor a TI-83F variable file"
        )
    if len(blob) < 55 + 19 + 2:
        raise DecodeError("TI variable file is truncated")
    if (
        blob[:10] != TI_SIGNATURE_PREFIX
        or blob[10] not in TI_SIGNATURE_REVISIONS
    ):
        raise DecodeError("unsupported or corrupt TI variable signature")

    section_size = _u16(blob, 53)
    expected_file_size = 55 + section_size + 2
    if len(blob) != expected_file_size:
        raise DecodeError(
            f"TI data-section length requires {expected_file_size} file bytes, "
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
    header_length = _u16(entry, 0)
    if header_length != 13:
        raise DecodeError(
            f"unsupported TI variable entry header length {header_length}; expected 13"
        )
    variable_length = _u16(entry, 2)
    variable_type = entry[4]
    variable_name = _display_ascii(entry[5:13])
    archived = bool(entry[14] & 0x80)
    repeated_length = _u16(entry, 15)
    if repeated_length != variable_length:
        raise DecodeError(
            "TI variable length fields disagree: "
            f"{variable_length} versus {repeated_length}"
        )
    if section_size != 17 + variable_length:
        raise DecodeError(
            "TI data section contains an invalid entry length or multiple entries"
        )
    if variable_type != APPVAR_TYPE:
        raise DecodeError(
            f"TI variable {variable_name!r} has type 0x{variable_type:02X}; "
            f"expected AppVar type 0x{APPVAR_TYPE:02X}"
        )
    if variable_length < 2:
        raise DecodeError("AppVar data is missing its inner payload length")

    inner_size = _u16(entry, 17)
    if variable_length != inner_size + 2:
        raise DecodeError(
            f"AppVar entry length is {variable_length}, but inner payload length "
            f"requires {inner_size + 2}"
        )
    payload = entry[19 : 19 + inner_size]
    if len(payload) != inner_size:
        raise DecodeError("AppVar payload is truncated")

    comment = blob[11:53].split(b"\0", 1)[0].decode("ascii", errors="replace")
    return payload, WrapperInfo(
        kind="ti-appvar",
        variable_name=variable_name,
        variable_type=variable_type,
        archived=archived,
        comment=comment,
        wrapper_checksum=stored_checksum,
    )


def parse_payload(payload: bytes, source: Path, wrapper: WrapperInfo) -> BenchmarkReport:
    if len(payload) < HEADER_SIZE:
        raise DecodeError(
            f"benchmark payload is {len(payload)} bytes; at least {HEADER_SIZE} required"
        )
    if payload[:8] != MAGIC:
        raise DecodeError(
            f"unsupported benchmark magic {payload[:8]!r}; expected {MAGIC!r}"
        )

    version = _u16(payload, 8)
    header_size = _u16(payload, 10)
    if version != FORMAT_VERSION:
        raise DecodeError(
            f"unsupported P3DBEN version {version}; this decoder supports {FORMAT_VERSION}"
        )
    if header_size != HEADER_SIZE:
        raise DecodeError(
            f"unsupported P3DBEN2 header size {header_size}; expected {HEADER_SIZE}"
        )

    header = Header(
        flags=_u32(payload, 12),
        clock_hz=_u32(payload, 16),
        trace_timer_hz=_u32(payload, 20),
        build_fingerprint=_u32(payload, 24),
        suite_fingerprint=_u32(payload, 28),
        payload_size=_u16(payload, 32),
        scene_count=_u16(payload, 34),
        warmups=_u16(payload, 36),
        samples_per_scene=_u16(payload, 38),
        scene_record_size=_u16(payload, 40),
        sample_record_size=_u16(payload, 42),
        logical_columns=_u16(payload, 44),
        column_width=payload[46],
        texture_size=payload[47],
        depth_limit=payload[48],
        clock_id=payload[49],
        category_count=payload[50],
        switch_cost_q8=_u32(payload, 52),
        payload_crc32=_u32(payload, 56),
    )

    if payload[51] != 0 or _u32(payload, 60) != 0:
        raise DecodeError("non-zero reserved header field in P3DBEN2 payload")
    if header.payload_size != len(payload):
        raise DecodeError(
            f"payload header declares {header.payload_size} bytes, found {len(payload)}"
        )
    if header.scene_record_size != SCENE_RECORD_SIZE:
        raise DecodeError(
            f"scene record size is {header.scene_record_size}; expected {SCENE_RECORD_SIZE}"
        )
    if header.sample_record_size != SAMPLE_RECORD_SIZE:
        raise DecodeError(
            f"sample record size is {header.sample_record_size}; expected {SAMPLE_RECORD_SIZE}"
        )
    if header.category_count != len(CATEGORY_NAMES):
        raise DecodeError(
            f"category count is {header.category_count}; expected {len(CATEGORY_NAMES)}"
        )
    if header.clock_hz == 0 or header.trace_timer_hz == 0:
        raise DecodeError("benchmark clock frequencies must be non-zero")

    computed_crc = zlib.crc32(payload[header_size:]) & 0xFFFFFFFF
    if computed_crc != header.payload_crc32:
        raise DecodeError(
            "benchmark payload CRC32 mismatch: "
            f"stored {_hex32(header.payload_crc32)}, computed {_hex32(computed_crc)}"
        )

    scene_block_end = header_size + header.scene_count * header.scene_record_size
    if scene_block_end > len(payload):
        raise DecodeError("scene records extend beyond the benchmark payload")
    sample_bytes = len(payload) - scene_block_end
    if sample_bytes % header.sample_record_size:
        raise DecodeError(
            f"sample block has {sample_bytes} bytes, which is not divisible by "
            f"record size {header.sample_record_size}"
        )
    sample_count = sample_bytes // header.sample_record_size

    scenes: list[Scene] = []
    for index in range(header.scene_count):
        offset = header_size + index * header.scene_record_size
        record = payload[offset : offset + header.scene_record_size]
        if _u16(record, 6) != 0:
            raise DecodeError(f"scene {index} has a non-zero reserved field")
        scene = Scene(
            index=index,
            scene_id=record[0],
            flags=record[1],
            sample_count=_u16(record, 2),
            first_sample=_u16(record, 4),
            frame_hash=_u32(record, 8),
            player_x_raw=_s24(record, 12),
            player_y_raw=_s24(record, 15),
            angle_raw=_u16(record, 18),
            primary=record[20:24],
            secondary=record[24:28],
            name=_display_ascii(record[28:40]),
        )
        if scene.first_sample + scene.sample_count > sample_count:
            raise DecodeError(
                f"scene {index} sample range [{scene.first_sample}, "
                f"{scene.first_sample + scene.sample_count}) exceeds {sample_count} records"
            )
        scenes.append(scene)

    samples: list[Sample] = []
    for index in range(sample_count):
        offset = scene_block_end + index * header.sample_record_size
        record = payload[offset : offset + header.sample_record_size]
        samples.append(
            Sample(
                index=index,
                total_ticks=_u32(record, 0),
                wait_ticks=_u32(record, 4),
                background_ticks=_u32(record, 8),
                columns_ticks=_u32(record, 12),
                casts=_u16(record, 16),
                max_depth=record[18],
                status=record[19],
                trace_total_ticks=_u32(record, 20),
                category_raw_ticks=tuple(
                    _u32(record, 24 + category * 4)
                    for category in range(len(CATEGORY_NAMES))
                ),
                category_entries=tuple(
                    _u16(record, 52 + category * 2)
                    for category in range(len(CATEGORY_NAMES))
                ),
                portal_transforms=_u16(record, 66),
                wall_calls=_u16(record, 68),
                mask_calls=_u16(record, 70),
                portal_candidates=_u16(record, 72),
                linked_exits=_u16(record, 74),
                textured_rows=_u16(record, 76),
                dda_steps=_u16(record, 78),
            )
        )

    warnings: list[str] = []
    expected_first = 0
    for scene in sorted(scenes, key=lambda item: item.first_sample):
        if scene.first_sample != expected_first:
            raise DecodeError(
                "scene sample ranges overlap or leave a gap at sample "
                f"{expected_first}"
            )
        expected_first += scene.sample_count
        if scene.sample_count != header.samples_per_scene:
            warnings.append(
                f"scene {scene.scene_id} ({scene.name}) has {scene.sample_count} samples; "
                f"header says {header.samples_per_scene} per scene"
            )
    if expected_first != sample_count:
        raise DecodeError(
            f"scene sample ranges cover {expected_first} of {sample_count} records"
        )

    ids = [scene.scene_id for scene in scenes]
    if len(set(ids)) != len(ids):
        warnings.append("scene IDs are not unique")
    names = [scene.name for scene in scenes]
    if len(set(names)) != len(names):
        warnings.append("scene names are not unique")

    report = BenchmarkReport(
        source=source,
        wrapper=wrapper,
        header=header,
        scenes=scenes,
        samples=samples,
        warnings=warnings,
    )
    _add_trace_validation_warnings(report)
    return report


def decode_file(path: Path) -> BenchmarkReport:
    try:
        blob = path.read_bytes()
    except OSError as exc:
        raise DecodeError(f"cannot read {path}: {exc}") from exc
    payload, wrapper = extract_payload(blob)
    return parse_payload(payload, path.resolve(), wrapper)


def corrected_ticks(sample: Sample, category: int, switch_cost_q8: int) -> int:
    raw = sample.category_raw_ticks[category]
    overhead = (
        sample.category_entries[category] * switch_cost_q8 + 128
    ) >> 8
    return max(0, raw - overhead)


def _add_trace_validation_warnings(report: BenchmarkReport) -> None:
    switch_cost_q8 = report.header.switch_cost_q8
    maximum_intrusion = 0.0
    maximum_residual = 0.0
    clamped_categories: dict[str, int] = {}
    if not report.header.flags & FLAG_SWITCH_COST_Q8:
        report.warnings.append(
            "trace switch-cost field is not marked as Q8; category correction "
            "may be incompatible"
        )
    for sample in report.samples:
        raw_sum = sum(sample.category_raw_ticks)
        if raw_sum != sample.trace_total_ticks:
            report.warnings.append(
                f"sample {sample.index}: category ticks sum to {raw_sum}, "
                f"trace_total_ticks is {sample.trace_total_ticks}"
            )
        for category, name in enumerate(CATEGORY_NAMES):
            overhead = (
                sample.category_entries[category] * switch_cost_q8 + 128
            ) >> 8
            if overhead > sample.category_raw_ticks[category]:
                clamped_categories[name] = clamped_categories.get(name, 0) + 1
        if sample.status & ~0x01:
            report.warnings.append(
                f"sample {sample.index}: unknown status bits 0x{sample.status & ~0x01:02X}"
            )
        if not sample.detailed and (
            sample.trace_total_ticks != 0
            or any(sample.category_raw_ticks)
            or any(sample.category_entries)
            or any(getattr(sample, name) for name in COUNT_NAMES)
        ):
            report.warnings.append(
                f"sample {sample.index}: clean record contains detailed-only data"
            )

    for scene in report.scenes:
        samples = report.samples_for_scene(scene)
        clean = [sample for sample in samples if not sample.detailed]
        detailed = [sample for sample in samples if sample.detailed]
        clean_count = len(clean)
        detailed_count = len(detailed)
        if clean_count == 0:
            report.warnings.append(
                f"scene {scene.scene_id} ({scene.name}) has no clean samples"
            )
        if detailed_count == 0:
            report.warnings.append(
                f"scene {scene.scene_id} ({scene.name}) has no detailed samples"
            )
        if clean and detailed:
            clean_ms = statistics.fmean(
                ticks_to_ms(sample.total_ticks, report.header.clock_hz)
                for sample in clean
            )
            detailed_ms = statistics.fmean(
                ticks_to_ms(sample.total_ticks, report.header.clock_hz)
                for sample in detailed
            )
            corrected_ms = statistics.fmean(
                ticks_to_ms(
                    sum(
                        corrected_ticks(sample, category, switch_cost_q8)
                        for category in range(len(CATEGORY_NAMES))
                    ),
                    report.header.trace_timer_hz,
                )
                for sample in detailed
            )
            if clean_ms > 0:
                maximum_intrusion = max(
                    maximum_intrusion,
                    abs((detailed_ms / clean_ms - 1.0) * 100.0),
                )
                maximum_residual = max(
                    maximum_residual,
                    abs((corrected_ms / clean_ms - 1.0) * 100.0),
                )

    if maximum_intrusion > 5.0:
        report.warnings.append(
            "fine trace instrumentation changes detailed-frame time by as much "
            f"as {maximum_intrusion:.1f}%; use clean samples for performance "
            "comparisons"
        )
    for name, count in sorted(clamped_categories.items()):
        report.warnings.append(
            f"{name} switch overhead exceeded raw time in {count} detailed "
            "samples; those corrected values were clamped to zero"
        )
    if maximum_residual > 5.0:
        report.warnings.append(
            "switch-corrected category totals differ from clean time by as much "
            f"as {maximum_residual:.1f}%; category times are approximate"
        )


def ticks_to_ms(ticks: float | int, clock_hz: int) -> float:
    return float(ticks) * 1000.0 / clock_hz


def _safe_mean(values: Sequence[float | int]) -> float | None:
    return statistics.fmean(values) if values else None


def _safe_median(values: Sequence[float | int]) -> float | None:
    return statistics.median(values) if values else None


def _safe_pstdev(values: Sequence[float | int]) -> float | None:
    return statistics.pstdev(values) if values else None


def _metric_stats(values: Sequence[int], scale: float = 1.0) -> dict[str, float | int | None]:
    if not values:
        return {
            "count": 0,
            "min": None,
            "max": None,
            "mean": None,
            "median": None,
            "pstdev": None,
        }
    scaled = [value * scale for value in values]
    return {
        "count": len(values),
        "min": min(scaled),
        "max": max(scaled),
        "mean": statistics.fmean(scaled),
        "median": statistics.median(scaled),
        "pstdev": statistics.pstdev(scaled),
    }


def summarize_scene(report: BenchmarkReport, scene: Scene) -> dict[str, Any]:
    samples = report.samples_for_scene(scene)
    clean = [sample for sample in samples if not sample.detailed]
    detailed = [sample for sample in samples if sample.detailed]
    clock_hz = report.header.clock_hz
    trace_hz = report.header.trace_timer_hz
    switch_cost_q8 = report.header.switch_cost_q8

    timing: dict[str, Any] = {}
    for name, getter in (
        ("total", lambda sample: sample.total_ticks),
        ("wait", lambda sample: sample.wait_ticks),
        ("background", lambda sample: sample.background_ticks),
        ("columns", lambda sample: sample.columns_ticks),
    ):
        values = [getter(sample) for sample in clean]
        timing[name] = {
            "ticks": _metric_stats(values),
            "ms": _metric_stats(values, 1000.0 / clock_hz),
        }

    categories: dict[str, Any] = {}
    for category, name in enumerate(CATEGORY_NAMES):
        raw_values = [sample.category_raw_ticks[category] for sample in detailed]
        corrected_values = [
            corrected_ticks(sample, category, switch_cost_q8)
            for sample in detailed
        ]
        entry_values = [sample.category_entries[category] for sample in detailed]
        categories[name] = {
            "raw_ticks": _metric_stats(raw_values),
            "entries": _metric_stats(entry_values),
            "corrected_ticks": _metric_stats(corrected_values),
            "corrected_ms": _metric_stats(corrected_values, 1000.0 / trace_hz),
        }

    counts: dict[str, Any] = {}
    for count_name in ("casts", "max_depth"):
        values = [getattr(sample, count_name) for sample in samples]
        counts[count_name] = _metric_stats(values)
    for count_name in COUNT_NAMES:
        values = [getattr(sample, count_name) for sample in detailed]
        counts[count_name] = _metric_stats(values)

    trace_values = [sample.trace_total_ticks for sample in detailed]
    detailed_total_values = [sample.total_ticks for sample in detailed]
    corrected_trace_values = [
        sum(
            corrected_ticks(sample, category, switch_cost_q8)
            for category in range(len(CATEGORY_NAMES))
        )
        for sample in detailed
    ]
    clean_total_ms = timing["total"]["ms"]["mean"]
    detailed_total_ms = _metric_stats(
        detailed_total_values, 1000.0 / clock_hz
    )
    corrected_trace_ms = _metric_stats(
        corrected_trace_values, 1000.0 / trace_hz
    )
    trace_intrusion_percent = (
        None
        if clean_total_ms in (None, 0) or detailed_total_ms["mean"] is None
        else (detailed_total_ms["mean"] / clean_total_ms - 1.0) * 100.0
    )
    corrected_trace_residual_percent = (
        None
        if clean_total_ms in (None, 0) or corrected_trace_ms["mean"] is None
        else (corrected_trace_ms["mean"] / clean_total_ms - 1.0) * 100.0
    )
    return {
        "scene_index": scene.index,
        "scene_id": scene.scene_id,
        "scene_name": scene.name,
        "scene_flags": scene.flags,
        "frame_hash": _hex32(scene.frame_hash),
        "clean_sample_count": len(clean),
        "detailed_sample_count": len(detailed),
        "timing": timing,
        "trace_total": {
            "ticks": _metric_stats(trace_values),
            "ms": _metric_stats(trace_values, 1000.0 / trace_hz),
            "intrusion_percent": trace_intrusion_percent,
        },
        "detailed_total": {
            "ticks": _metric_stats(detailed_total_values),
            "ms": detailed_total_ms,
        },
        "corrected_trace_total": {
            "ticks": _metric_stats(corrected_trace_values),
            "ms": corrected_trace_ms,
            "residual_percent": corrected_trace_residual_percent,
        },
        "categories": categories,
        "counts": counts,
    }


def build_summaries(report: BenchmarkReport) -> list[dict[str, Any]]:
    return [summarize_scene(report, scene) for scene in report.scenes]


def _sample_row(report: BenchmarkReport, scene: Scene, sample: Sample) -> dict[str, Any]:
    header = report.header
    row: dict[str, Any] = {
        "scene_index": scene.index,
        "scene_id": scene.scene_id,
        "scene_name": scene.name,
        "scene_flags": f"0x{scene.flags:02X}",
        "frame_hash": _hex32(scene.frame_hash),
        "player_x_raw": scene.player_x_raw,
        "player_y_raw": scene.player_y_raw,
        "player_x": scene.player_x,
        "player_y": scene.player_y,
        "angle_raw": scene.angle_raw,
        "angle_degrees": scene.angle_degrees,
        "primary_hex": scene.primary.hex().upper(),
        "secondary_hex": scene.secondary.hex().upper(),
        "sample_index": sample.index,
        "scene_sample_index": sample.index - scene.first_sample,
        "detailed": int(sample.detailed),
        "status": f"0x{sample.status:02X}",
        "total_ticks": sample.total_ticks,
        "total_ms": ticks_to_ms(sample.total_ticks, header.clock_hz),
        "wait_ticks": sample.wait_ticks,
        "wait_ms": ticks_to_ms(sample.wait_ticks, header.clock_hz),
        "background_ticks": sample.background_ticks,
        "background_ms": ticks_to_ms(sample.background_ticks, header.clock_hz),
        "columns_ticks": sample.columns_ticks,
        "columns_ms": ticks_to_ms(sample.columns_ticks, header.clock_hz),
        "casts": sample.casts,
        "max_depth": sample.max_depth,
        "trace_total_ticks": sample.trace_total_ticks,
        "trace_total_ms": ticks_to_ms(
            sample.trace_total_ticks, header.trace_timer_hz
        ),
        "trace_category_delta_ticks": (
            sum(sample.category_raw_ticks) - sample.trace_total_ticks
        ),
        "portal_transforms": sample.portal_transforms,
        "wall_calls": sample.wall_calls,
        "mask_calls": sample.mask_calls,
        "portal_candidates": sample.portal_candidates,
        "linked_exits": sample.linked_exits,
        "textured_rows": sample.textured_rows,
        "dda_steps": sample.dda_steps,
    }
    for category, name in enumerate(CATEGORY_NAMES):
        corrected = corrected_ticks(
            sample, category, report.header.switch_cost_q8
        )
        row[f"{name}_raw_ticks"] = sample.category_raw_ticks[category]
        row[f"{name}_entries"] = sample.category_entries[category]
        row[f"{name}_corrected_ticks"] = corrected
        row[f"{name}_corrected_ms"] = ticks_to_ms(
            corrected, report.header.trace_timer_hz
        )
    return row


def sample_rows(report: BenchmarkReport) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for scene in report.scenes:
        rows.extend(
            _sample_row(report, scene, sample)
            for sample in report.samples_for_scene(scene)
        )
    return rows


def _summary_row(summary: dict[str, Any]) -> dict[str, Any]:
    row: dict[str, Any] = {
        "scene_index": summary["scene_index"],
        "scene_id": summary["scene_id"],
        "scene_name": summary["scene_name"],
        "scene_flags": f"0x{summary['scene_flags']:02X}",
        "frame_hash": summary["frame_hash"],
        "clean_samples": summary["clean_sample_count"],
        "detailed_samples": summary["detailed_sample_count"],
    }
    for metric in ("total", "wait", "background", "columns"):
        stats = summary["timing"][metric]["ms"]
        for stat in ("min", "max", "mean", "median", "pstdev"):
            row[f"{metric}_ms_{stat}"] = stats[stat]
    trace = summary["trace_total"]["ms"]
    for stat in ("min", "max", "mean", "median", "pstdev"):
        row[f"trace_total_ms_{stat}"] = trace[stat]
    row["trace_intrusion_percent"] = summary["trace_total"][
        "intrusion_percent"
    ]
    corrected_trace = summary["corrected_trace_total"]["ms"]
    for stat in ("min", "max", "mean", "median", "pstdev"):
        row[f"corrected_trace_total_ms_{stat}"] = corrected_trace[stat]
    row["corrected_trace_residual_percent"] = summary[
        "corrected_trace_total"
    ]["residual_percent"]
    for category in CATEGORY_NAMES:
        category_summary = summary["categories"][category]
        row[f"{category}_corrected_ticks_mean"] = category_summary[
            "corrected_ticks"
        ]["mean"]
        row[f"{category}_corrected_ms_mean"] = category_summary["corrected_ms"][
            "mean"
        ]
        row[f"{category}_entries_mean"] = category_summary["entries"]["mean"]
    for count_name in ("casts", "max_depth") + COUNT_NAMES:
        row[f"{count_name}_mean"] = summary["counts"][count_name]["mean"]
    return row


def summary_rows(report: BenchmarkReport) -> list[dict[str, Any]]:
    return [_summary_row(summary) for summary in build_summaries(report)]


def _scene_config(scene: Scene) -> tuple[Any, ...]:
    return (
        scene.flags,
        scene.player_x_raw,
        scene.player_y_raw,
        scene.angle_raw,
        scene.primary,
        scene.secondary,
        scene.name,
    )


def _percent_change(current: float | None, baseline: float | None) -> float | None:
    if current is None or baseline is None or baseline == 0:
        return None
    return (current / baseline - 1.0) * 100.0


def _delta(current: float | None, baseline: float | None) -> float | None:
    if current is None or baseline is None:
        return None
    return current - baseline


def compare_reports(
    current: BenchmarkReport, baseline: BenchmarkReport
) -> dict[str, Any]:
    warnings: list[str] = []
    notes: list[str] = []
    current_header = current.header
    baseline_header = baseline.header

    config_fields = (
        "flags",
        "clock_hz",
        "trace_timer_hz",
        "suite_fingerprint",
        "warmups",
        "samples_per_scene",
        "logical_columns",
        "column_width",
        "texture_size",
        "depth_limit",
        "clock_id",
        "category_count",
    )
    for name in config_fields:
        current_value = getattr(current_header, name)
        baseline_value = getattr(baseline_header, name)
        if current_value != baseline_value:
            warnings.append(
                f"configuration mismatch for {name}: current={current_value}, "
                f"baseline={baseline_value}"
            )
    if current_header.build_fingerprint != baseline_header.build_fingerprint:
        notes.append(
            "build fingerprints differ (expected when comparing engine revisions): "
            f"current={_hex32(current_header.build_fingerprint)}, "
            f"baseline={_hex32(baseline_header.build_fingerprint)}"
        )
    if current_header.switch_cost_q8 != baseline_header.switch_cost_q8:
        notes.append(
            "timer switch calibration differs: "
            f"current={current_header.switch_cost_q8 / 256.0:.3f} ticks, "
            f"baseline={baseline_header.switch_cost_q8 / 256.0:.3f} ticks"
        )

    baseline_by_id = {scene.scene_id: scene for scene in baseline.scenes}
    current_by_id = {scene.scene_id: scene for scene in current.scenes}
    for scene_id in sorted(set(baseline_by_id) - set(current_by_id)):
        scene = baseline_by_id[scene_id]
        warnings.append(
            f"baseline scene {scene_id} ({scene.name}) is missing from current result"
        )
    for scene_id in sorted(set(current_by_id) - set(baseline_by_id)):
        scene = current_by_id[scene_id]
        warnings.append(
            f"current scene {scene_id} ({scene.name}) is missing from baseline result"
        )

    current_summaries = {
        row["scene_id"]: row for row in summary_rows(current)
    }
    baseline_summaries = {
        row["scene_id"]: row for row in summary_rows(baseline)
    }
    rows: list[dict[str, Any]] = []
    for scene_id in sorted(set(current_by_id) & set(baseline_by_id)):
        current_scene = current_by_id[scene_id]
        baseline_scene = baseline_by_id[scene_id]
        config_match = _scene_config(current_scene) == _scene_config(baseline_scene)
        frame_match = current_scene.frame_hash == baseline_scene.frame_hash
        if not config_match:
            warnings.append(
                f"scene configuration mismatch for ID {scene_id}: "
                f"current={current_scene.name!r}, baseline={baseline_scene.name!r}"
            )
        if not frame_match:
            warnings.append(
                f"frame hash mismatch for scene {scene_id} ({current_scene.name}): "
                f"current={_hex32(current_scene.frame_hash)}, "
                f"baseline={_hex32(baseline_scene.frame_hash)}"
            )

        current_summary = current_summaries[scene_id]
        baseline_summary = baseline_summaries[scene_id]
        row: dict[str, Any] = {
            "scene_id": scene_id,
            "scene_name": current_scene.name,
            "config_match": int(config_match),
            "frame_hash_match": int(frame_match),
            "current_frame_hash": _hex32(current_scene.frame_hash),
            "baseline_frame_hash": _hex32(baseline_scene.frame_hash),
            "current_clean_samples": current_summary["clean_samples"],
            "baseline_clean_samples": baseline_summary["clean_samples"],
            "current_detailed_samples": current_summary["detailed_samples"],
            "baseline_detailed_samples": baseline_summary["detailed_samples"],
        }
        for metric in ("total", "wait", "background", "columns"):
            current_mean = current_summary[f"{metric}_ms_mean"]
            baseline_mean = baseline_summary[f"{metric}_ms_mean"]
            row[f"current_{metric}_ms_mean"] = current_mean
            row[f"baseline_{metric}_ms_mean"] = baseline_mean
            row[f"{metric}_ms_delta"] = _delta(current_mean, baseline_mean)
            row[f"{metric}_percent_change"] = _percent_change(
                current_mean, baseline_mean
            )
        for category in CATEGORY_NAMES:
            key = f"{category}_corrected_ms_mean"
            current_mean = current_summary[key]
            baseline_mean = baseline_summary[key]
            row[f"current_{key}"] = current_mean
            row[f"baseline_{key}"] = baseline_mean
            row[f"{category}_corrected_ms_delta"] = _delta(
                current_mean, baseline_mean
            )
            row[f"{category}_corrected_percent_change"] = _percent_change(
                current_mean, baseline_mean
            )
        rows.append(row)

    return {
        "baseline_source": str(baseline.source),
        "warnings": warnings,
        "notes": notes,
        "rows": rows,
    }


def _header_json(header: Header) -> dict[str, Any]:
    return {
        "format": "P3DBEN2",
        "version": FORMAT_VERSION,
        "flags": f"0x{header.flags:08X}",
        "clock_hz": header.clock_hz,
        "trace_timer_hz": header.trace_timer_hz,
        "build_fingerprint": _hex32(header.build_fingerprint),
        "suite_fingerprint": _hex32(header.suite_fingerprint),
        "payload_size": header.payload_size,
        "scene_count": header.scene_count,
        "warmups": header.warmups,
        "samples_per_scene": header.samples_per_scene,
        "scene_record_size": header.scene_record_size,
        "sample_record_size": header.sample_record_size,
        "logical_columns": header.logical_columns,
        "column_width": header.column_width,
        "texture_size": header.texture_size,
        "depth_limit": header.depth_limit,
        "clock_id": header.clock_id,
        "category_count": header.category_count,
        "category_names": list(CATEGORY_NAMES),
        "switch_cost_q8": header.switch_cost_q8,
        "switch_cost_ticks": header.switch_cost_q8 / 256.0,
        "payload_crc32": _hex32(header.payload_crc32),
    }


def _scene_json(scene: Scene) -> dict[str, Any]:
    return {
        "index": scene.index,
        "id": scene.scene_id,
        "name": scene.name,
        "flags": f"0x{scene.flags:02X}",
        "sample_count": scene.sample_count,
        "first_sample": scene.first_sample,
        "frame_hash": _hex32(scene.frame_hash),
        "player_x_raw": scene.player_x_raw,
        "player_y_raw": scene.player_y_raw,
        "player_x": scene.player_x,
        "player_y": scene.player_y,
        "angle_raw": scene.angle_raw,
        "angle_degrees": scene.angle_degrees,
        "primary_hex": scene.primary.hex().upper(),
        "secondary_hex": scene.secondary.hex().upper(),
    }


def _wrapper_json(wrapper: WrapperInfo) -> dict[str, Any]:
    result: dict[str, Any] = {"kind": wrapper.kind}
    if wrapper.variable_name is not None:
        result.update(
            {
                "variable_name": wrapper.variable_name,
                "variable_type": f"0x{wrapper.variable_type:02X}",
                "archived": wrapper.archived,
                "comment": wrapper.comment,
                "checksum": f"0x{wrapper.wrapper_checksum:04X}",
            }
        )
    return result


def report_json(
    report: BenchmarkReport, comparison: dict[str, Any] | None = None
) -> dict[str, Any]:
    result: dict[str, Any] = {
        "source": str(report.source),
        "validation": {
            "ti_wrapper_checksum": "valid"
            if report.wrapper.kind == "ti-appvar"
            else "not-applicable",
            "payload_crc32": "valid",
            "lengths": "valid",
        },
        "wrapper": _wrapper_json(report.wrapper),
        "header": _header_json(report.header),
        "warnings": report.warnings,
        "scenes": [_scene_json(scene) for scene in report.scenes],
        "samples": sample_rows(report),
        "summaries": build_summaries(report),
    }
    if comparison is not None:
        result["comparison"] = comparison
    return result


def _write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        path.write_text("", encoding="utf-8")
        return
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def write_outputs(
    report: BenchmarkReport,
    output_dir: Path,
    prefix: str,
    comparison: dict[str, Any] | None = None,
) -> list[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    sample_path = output_dir / f"{prefix}-samples.csv"
    summary_path = output_dir / f"{prefix}-summary.csv"
    json_path = output_dir / f"{prefix}.json"
    _write_csv(sample_path, sample_rows(report))
    _write_csv(summary_path, summary_rows(report))
    with json_path.open("w", encoding="utf-8") as handle:
        json.dump(report_json(report, comparison), handle, indent=2)
        handle.write("\n")
    paths = [sample_path, summary_path, json_path]
    if comparison is not None:
        comparison_path = output_dir / f"{prefix}-compare.csv"
        _write_csv(comparison_path, comparison["rows"])
        paths.append(comparison_path)
    return paths


def _sanitize_prefix(value: str) -> str:
    cleaned = "".join(
        character if character.isalnum() or character in "-_." else "_"
        for character in value
    ).strip("._")
    return cleaned or "P3DRES"


def print_summary(report: BenchmarkReport) -> None:
    header = report.header
    print(
        f"P3DBEN2: {header.scene_count} scenes, {len(report.samples)} samples, "
        f"build {_hex32(header.build_fingerprint)}, "
        f"suite {_hex32(header.suite_fingerprint)}"
    )
    print(
        "scene         clean mean       min       max   columns"
        "   trace ovh   residual"
    )
    for row in summary_rows(report):
        mean = row["total_ms_mean"]
        minimum = row["total_ms_min"]
        maximum = row["total_ms_max"]
        columns = row["columns_ms_mean"]
        intrusion = row["trace_intrusion_percent"]
        residual = row["corrected_trace_residual_percent"]
        format_ms = lambda value: "   n/a " if value is None else f"{value:7.2f}"
        format_percent = (
            lambda value: "    n/a"
            if value is None
            else f"{value:+6.1f}%"
        )
        print(
            f"{row['scene_name'][:12]:12} {format_ms(mean)}ms "
            f"{format_ms(minimum)} {format_ms(maximum)} "
            f"{format_ms(columns)} {format_percent(intrusion)} "
            f"{format_percent(residual)}"
        )


def _pack_s24(value: int) -> bytes:
    if not -(1 << 23) <= value < (1 << 23):
        raise ValueError("s24 value out of range")
    return (value & 0xFFFFFF).to_bytes(3, "little")


def _make_test_payload(
    *, frame_hash_delta: int = 0, tick_delta: int = 0
) -> bytes:
    scene_count = 2
    samples_per_scene = 3
    scenes = bytearray()
    samples = bytearray()
    for scene_index in range(scene_count):
        scene = bytearray(SCENE_RECORD_SIZE)
        scene[0] = scene_index + 1
        scene[1] = scene_index
        struct.pack_into("<H", scene, 2, samples_per_scene)
        struct.pack_into("<H", scene, 4, scene_index * samples_per_scene)
        struct.pack_into(
            "<I", scene, 8, 0x11223300 + scene_index + frame_hash_delta
        )
        scene[12:15] = _pack_s24((8 + scene_index) * 256 + 128)
        scene[15:18] = _pack_s24((4 + scene_index) * 256 + 64)
        struct.pack_into("<H", scene, 18, scene_index * 16 * 256)
        scene[20:24] = bytes((1, 2, 3, 4))
        scene[24:28] = bytes((5, 6, 7, 8))
        name = f"scene{scene_index}".encode("ascii")
        scene[28 : 28 + len(name)] = name
        scenes.extend(scene)

        for sample_index in range(samples_per_scene):
            sample = bytearray(SAMPLE_RECORD_SIZE)
            total = 3000 + scene_index * 500 + sample_index * 10 + tick_delta
            struct.pack_into("<IIII", sample, 0, total, 2, 800, total - 802)
            struct.pack_into("<H", sample, 16, 80 + scene_index * 40)
            sample[18] = 1 + scene_index
            sample[19] = 1 if sample_index == samples_per_scene - 1 else 0
            raw_ticks = [100, 200, 300, 400, 500, 600, 700]
            if not sample[19]:
                raw_ticks = [0] * len(CATEGORY_NAMES)
            trace_total = sum(raw_ticks)
            struct.pack_into("<I", sample, 20, trace_total)
            for category, value in enumerate(raw_ticks):
                struct.pack_into("<I", sample, 24 + category * 4, value)
                struct.pack_into(
                    "<H", sample, 52 + category * 2, 1 if sample[19] else 0
                )
            if sample[19]:
                struct.pack_into(
                    "<HHHHHHH", sample, 66, 4, 80, 2, 10, 4, 120, 240
                )
            samples.extend(sample)

    payload_size = HEADER_SIZE + len(scenes) + len(samples)
    header = bytearray(HEADER_SIZE)
    header[:8] = MAGIC
    struct.pack_into("<HH", header, 8, FORMAT_VERSION, HEADER_SIZE)
    struct.pack_into("<I", header, 12, 0x00000003 | FLAG_SWITCH_COST_Q8)
    struct.pack_into("<I", header, 16, 32768)
    struct.pack_into("<I", header, 20, 32768)
    struct.pack_into("<I", header, 24, 0xAABBCCDD)
    struct.pack_into("<I", header, 28, 0x01020304)
    struct.pack_into("<HHHHHHH", header, 32, payload_size, scene_count, 2,
                     samples_per_scene, SCENE_RECORD_SIZE, SAMPLE_RECORD_SIZE, 80)
    header[46:52] = bytes((4, 16, 4, 1, len(CATEGORY_NAMES), 0))
    struct.pack_into("<I", header, 52, 10 << 8)
    body = bytes(scenes + samples)
    struct.pack_into("<I", header, 56, zlib.crc32(body) & 0xFFFFFFFF)
    return bytes(header) + body


def _make_test_8xv(payload: bytes, signature_revision: int = 0x00) -> bytes:
    if signature_revision not in TI_SIGNATURE_REVISIONS:
        raise ValueError("unsupported self-test TI signature revision")
    comment = b"P3DBEN decoder self-test".ljust(42, b"\0")
    variable_length = len(payload) + 2
    entry = bytearray()
    entry.extend(struct.pack("<H", 13))
    entry.extend(struct.pack("<H", variable_length))
    entry.append(APPVAR_TYPE)
    entry.extend(b"P3DRES\0\0")
    entry.append(0)
    entry.append(0x80)
    entry.extend(struct.pack("<H", variable_length))
    entry.extend(struct.pack("<H", len(payload)))
    entry.extend(payload)
    wrapper = bytearray(TI_SIGNATURE_PREFIX)
    wrapper.append(signature_revision)
    wrapper.extend(comment)
    wrapper.extend(struct.pack("<H", len(entry)))
    wrapper.extend(entry)
    wrapper.extend(struct.pack("<H", sum(entry) & 0xFFFF))
    return bytes(wrapper)


def run_self_test() -> None:
    payload = _make_test_payload()
    wrapper_blob = _make_test_8xv(payload)
    raw_report = parse_payload(payload, Path("selftest.raw"), WrapperInfo(kind="raw"))
    extracted, wrapper_info = extract_payload(wrapper_blob)
    assert extracted == payload
    cemu_extracted, _ = extract_payload(
        _make_test_8xv(payload, signature_revision=0x0A)
    )
    assert cemu_extracted == payload
    wrapped_report = parse_payload(
        extracted, Path("selftest.8xv"), wrapper_info
    )
    assert wrapped_report.wrapper.variable_name == "P3DRES"
    assert len(wrapped_report.scenes) == 2
    assert len(wrapped_report.samples) == 6
    assert wrapped_report.scenes[0].player_x == 8.5
    assert corrected_ticks(wrapped_report.samples[2], 0, 10 << 8) == 90
    first_summary = summarize_scene(wrapped_report, wrapped_report.scenes[0])
    assert first_summary["counts"]["portal_transforms"]["mean"] == 4
    assert first_summary["counts"]["dda_steps"]["mean"] == 240

    comparison_payload = _make_test_payload(frame_hash_delta=1, tick_delta=-100)
    comparison_report = parse_payload(
        comparison_payload, Path("comparison.raw"), WrapperInfo(kind="raw")
    )
    comparison = compare_reports(comparison_report, raw_report)
    assert any("frame hash mismatch" in warning for warning in comparison["warnings"])
    assert comparison["rows"][0]["total_percent_change"] < 0
    assert "wait_percent_change" in comparison["rows"][0]
    assert "wait_corrected_percent_change" in comparison["rows"][0]
    assert "background_percent_change" in comparison["rows"][0]
    assert "background_corrected_percent_change" in comparison["rows"][0]

    corrupt_wrapper = bytearray(wrapper_blob)
    corrupt_wrapper[-1] ^= 0x01
    try:
        extract_payload(bytes(corrupt_wrapper))
    except DecodeError as exc:
        assert "wrapper checksum mismatch" in str(exc)
    else:
        raise AssertionError("corrupt wrapper checksum was accepted")

    corrupt_payload = bytearray(payload)
    corrupt_payload[-1] ^= 0x01
    try:
        parse_payload(
            bytes(corrupt_payload), Path("corrupt.raw"), WrapperInfo(kind="raw")
        )
    except DecodeError as exc:
        assert "payload CRC32 mismatch" in str(exc)
    else:
        raise AssertionError("corrupt payload CRC32 was accepted")

    with tempfile.TemporaryDirectory(prefix="p3dben-selftest-") as temp_dir:
        paths = write_outputs(
            wrapped_report, Path(temp_dir), "selftest", comparison
        )
        assert len(paths) == 4
        assert all(path.is_file() and path.stat().st_size > 0 for path in paths)
        decoded_json = json.loads((Path(temp_dir) / "selftest.json").read_text())
        assert decoded_json["validation"]["payload_crc32"] == "valid"
        assert len(decoded_json["samples"]) == 6

    print("decode-benchmark.py self-test: PASS")


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Decode a PortalR 3D P3DRES.8xv benchmark into samples CSV, "
            "summary CSV, and JSON."
        )
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        help="P3DRES.8xv or raw P3DBEN2 payload",
    )
    parser.add_argument(
        "--compare",
        type=Path,
        metavar="BASELINE",
        help="compare clean timings and detailed categories against another result",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="destination directory (default: input file directory)",
    )
    parser.add_argument(
        "--prefix",
        help="output filename prefix (default: input filename stem)",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run synthetic raw/AppVar/CRC/output tests and exit",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="suppress the human-readable scene table",
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
        output_dir = (
            args.output_dir.resolve()
            if args.output_dir
            else args.input.resolve().parent
        )
        prefix = _sanitize_prefix(args.prefix or args.input.stem)
        paths = write_outputs(report, output_dir, prefix, comparison)
    except DecodeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    except OSError as exc:
        print(f"error writing output: {exc}", file=sys.stderr)
        return 2

    if not args.quiet:
        print_summary(report)
    all_warnings = list(report.warnings)
    if baseline:
        all_warnings.extend(f"baseline: {warning}" for warning in baseline.warnings)
    if comparison:
        all_warnings.extend(comparison["warnings"])
        for note in comparison["notes"]:
            print(f"note: {note}", file=sys.stderr)
    for warning in all_warnings:
        print(f"warning: {warning}", file=sys.stderr)
    for path in paths:
        print(f"wrote {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
