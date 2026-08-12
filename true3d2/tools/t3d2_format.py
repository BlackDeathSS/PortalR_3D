"""Packed True3D2 formats shared by the compiler and host tests."""

from __future__ import annotations

import binascii
import struct
from pathlib import Path

MAP_HEADER = struct.Struct("<4sBBHIIHHHHBBHiiiIIIIIIIIII")
CELL = struct.Struct("<iiiiiiHHHHIHH")
GATEWAY = struct.Struct("<HHBBIhhhi")
MESHLET = struct.Struct("<HBBBBBBHiiihhhHbbbb")
PORTAL_SURFACE = struct.Struct("<HBBIiiihhhhhhhhhHH")
BODY = struct.Struct("<BBHiiiiiiHHHH")
MATERIAL = struct.Struct("<BbBB")
GEOMETRY_HEADER = struct.Struct("<4sBBHIIHH")
VERTEX = struct.Struct("<hhhBBbbbB")
TRIANGLE = struct.Struct("<BBB")
COLLISION_HEADER = struct.Struct("<4sBBHHHII")
COLLISION_NODE = struct.Struct("<hhhhhhHHHBB")
COLLISION_REFERENCE = struct.Struct("<HBB")

MAP_VERSION = 1
GEOMETRY_VERSION = 1
MAX_APPVAR_PAYLOAD = 65_512
MAX_GEOMETRY_PAYLOAD = 55_000
MAX_CELLS = 64
MAX_GATEWAYS = 128
MAX_MESHLETS = 1024
MAX_PORTAL_SURFACES = 64
MAX_MATERIALS = 32
MAX_BODIES = 8
MESHLET_MAX_VERTICES = 32
MESHLET_MAX_TRIANGLES = 48
TI_SIGNATURE = b"**TI83F*\x1a\x0a\x00"
APPVAR_TYPE = 0x15

EXPECTED_SIZES = {
    "map_header": 80,
    "cell": 40,
    "gateway": 20,
    "meshlet": 34,
    "portal_surface": 42,
    "body": 36,
    "material": 4,
    "geometry_header": 20,
    "vertex": 12,
    "triangle": 3,
    "collision_header": 20,
    "collision_node": 20,
    "collision_reference": 4,
}


def _assert_layouts() -> None:
    actual = {
        "map_header": MAP_HEADER.size,
        "cell": CELL.size,
        "gateway": GATEWAY.size,
        "meshlet": MESHLET.size,
        "portal_surface": PORTAL_SURFACE.size,
        "body": BODY.size,
        "material": MATERIAL.size,
        "geometry_header": GEOMETRY_HEADER.size,
        "vertex": VERTEX.size,
        "triangle": TRIANGLE.size,
        "collision_header": COLLISION_HEADER.size,
        "collision_node": COLLISION_NODE.size,
        "collision_reference": COLLISION_REFERENCE.size,
    }
    if actual != EXPECTED_SIZES:
        raise RuntimeError(f"True3D2 ABI layout mismatch: {actual!r}")


_assert_layouts()


def crc32(payload: bytes) -> int:
    return binascii.crc32(payload) & 0xFFFFFFFF


def fixed(value: float) -> int:
    result = round(float(value) * 256.0)
    if not -(1 << 23) <= result < (1 << 23):
        raise ValueError(f"Q16.8 value {value} does not fit the eZ80 runtime")
    return result


def q14(value: float) -> int:
    result = round(float(value) * 16384.0)
    if not -32768 <= result <= 32767:
        raise ValueError(f"Q1.14 value {value} does not fit int16")
    return result


def q4(value: float) -> int:
    result = round(float(value) * 16.0)
    if not -32768 <= result <= 32767:
        raise ValueError(f"Q12.4 collision bound {value} does not fit int16")
    return result


def appvar_name(name: str) -> str:
    normalized = name.upper()
    if not normalized or len(normalized) > 8 or not normalized[0].isalpha():
        raise ValueError(f"invalid TI AppVar name {name!r}")
    if any(not (character.isalnum() or character == "_") for character in normalized):
        raise ValueError(f"invalid TI AppVar name {name!r}")
    return normalized


def wrap_appvar(name: str, payload: bytes, comment: str = "True3D2 asset compiler") -> bytes:
    name = appvar_name(name)
    if len(payload) > MAX_APPVAR_PAYLOAD:
        raise ValueError(f"{name} payload is {len(payload)} bytes; AppVar limit is {MAX_APPVAR_PAYLOAD}")
    stored_length = len(payload) + 2
    entry = bytearray()
    entry.extend(struct.pack("<H", 13))
    entry.extend(struct.pack("<H", stored_length))
    entry.append(APPVAR_TYPE)
    entry.extend(name.encode("ascii").ljust(8, b"\0"))
    entry.extend((0, 0x80))
    entry.extend(struct.pack("<H", stored_length))
    entry.extend(struct.pack("<H", len(payload)))
    entry.extend(payload)
    result = bytearray(TI_SIGNATURE)
    result.extend(comment.encode("ascii", "replace")[:42].ljust(42, b"\0"))
    result.extend(struct.pack("<H", len(entry)))
    result.extend(entry)
    result.extend(struct.pack("<H", sum(entry) & 0xFFFF))
    return bytes(result)


def unwrap_appvar(blob: bytes, expected_name: str | None = None) -> tuple[str, bytes]:
    if len(blob) < 76 or not blob.startswith(TI_SIGNATURE):
        raise ValueError("not a TI variable file")
    section_size = struct.unpack_from("<H", blob, 53)[0]
    if 55 + section_size + 2 != len(blob):
        raise ValueError("invalid TI section length")
    section = blob[55 : 55 + section_size]
    if struct.unpack_from("<H", section, 0)[0] != 13 or section[4] != APPVAR_TYPE:
        raise ValueError("not an AppVar entry")
    if (sum(section) & 0xFFFF) != struct.unpack_from("<H", blob, 55 + section_size)[0]:
        raise ValueError("TI checksum mismatch")
    name = section[5:13].split(b"\0", 1)[0].decode("ascii")
    raw_size = struct.unpack_from("<H", section, 17)[0]
    if raw_size + 19 != section_size:
        raise ValueError("AppVar payload length mismatch")
    if expected_name is not None and name != appvar_name(expected_name):
        raise ValueError(f"expected {expected_name}, got {name}")
    return name, bytes(section[19:])


def write_appvar(directory: Path, name: str, payload: bytes) -> Path:
    path = directory / f"{appvar_name(name)}.8xv"
    path.write_bytes(wrap_appvar(name, payload))
    return path


def validate_map(payload: bytes) -> dict[str, int]:
    if len(payload) < MAP_HEADER.size:
        raise ValueError("map is smaller than its header")
    values = MAP_HEADER.unpack_from(payload)
    if values[0] != b"T3D2" or values[1] != MAP_VERSION or values[3] != MAP_HEADER.size:
        raise ValueError("invalid T3D2 map signature/version/header")
    if values[4] != len(payload):
        raise ValueError("T3D2 map total_size mismatch")
    if values[5] != crc32(payload[MAP_HEADER.size:]):
        raise ValueError("T3D2 map CRC mismatch")
    counts = {
        "cells": values[6], "gateways": values[7], "meshlets": values[8],
        "portals": values[9], "materials": values[10], "bodies": values[11],
    }
    limits = {
        "cells": MAX_CELLS, "gateways": MAX_GATEWAYS, "meshlets": MAX_MESHLETS,
        "portals": MAX_PORTAL_SURFACES, "materials": MAX_MATERIALS, "bodies": MAX_BODIES,
    }
    if counts["cells"] < 1 or counts["materials"] < 1 or any(
        counts[name] > limits[name] for name in counts
    ):
        raise ValueError("T3D2 count is out of range")
    sections = (
        (values[16], counts["cells"], CELL.size, "cells"),
        (values[17], counts["gateways"], GATEWAY.size, "gateways"),
        (values[18], counts["meshlets"], MESHLET.size, "meshlets"),
        (values[19], counts["portals"], PORTAL_SURFACE.size, "portals"),
        (values[20], counts["bodies"], BODY.size, "bodies"),
        (values[24], 256, 2, "palette"),
        (values[25], counts["materials"], MATERIAL.size, "materials"),
    )
    for offset, count, size, name in sections:
        if offset > len(payload) or count > (len(payload) - offset) // size:
            raise ValueError(f"T3D2 {name} section is out of bounds")
    for offset in values[21:24]:
        if offset > len(payload):
            raise ValueError("T3D2 variable section is out of bounds")
    return counts


def validate_geometry(payload: bytes, expected_page: int | None = None) -> dict[str, int]:
    if len(payload) < GEOMETRY_HEADER.size:
        raise ValueError("geometry page is smaller than its header")
    magic, version, page, header_size, payload_size, checksum, meshlets, _ = \
        GEOMETRY_HEADER.unpack_from(payload)
    if magic != b"T3DG" or version != GEOMETRY_VERSION or header_size != GEOMETRY_HEADER.size:
        raise ValueError("invalid T3D2 geometry signature/version/header")
    if expected_page is not None and page != expected_page:
        raise ValueError("geometry page index mismatch")
    if payload_size != len(payload) - GEOMETRY_HEADER.size:
        raise ValueError("geometry payload size mismatch")
    if checksum != crc32(payload[GEOMETRY_HEADER.size:]):
        raise ValueError("geometry CRC mismatch")
    return {"page": page, "meshlets": meshlets, "payload_size": payload_size}
