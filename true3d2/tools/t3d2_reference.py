"""Deterministic host reference for True3D2 raster, portals and fixed physics."""

from __future__ import annotations

import argparse
import binascii
import json
from dataclasses import dataclass, field
from typing import Sequence


@dataclass(frozen=True)
class Vec3:
    x: float
    y: float
    z: float

    def __add__(self, other: "Vec3") -> "Vec3":
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other: "Vec3") -> "Vec3":
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)

    def scaled(self, amount: float) -> "Vec3":
        return Vec3(self.x * amount, self.y * amount, self.z * amount)

    def dot(self, other: "Vec3") -> float:
        return self.x * other.x + self.y * other.y + self.z * other.z


@dataclass(frozen=True)
class Portal:
    center: Vec3
    right: Vec3
    up: Vec3
    normal: Vec3


@dataclass(frozen=True)
class RasterVertex:
    x: int
    y: int
    inverse_depth: int
    u: int
    v: int


@dataclass
class Frame:
    width: int
    height: int
    color: bytearray = field(init=False)
    depth: list[int] = field(init=False)

    def __post_init__(self) -> None:
        self.color = bytearray(self.width * self.height)
        self.depth = [0] * (self.width * self.height)

    def clear(self, color: int = 0) -> None:
        self.color[:] = bytes((color,)) * len(self.color)
        self.depth[:] = [0] * len(self.depth)


def _edge(a: RasterVertex, b: RasterVertex, x2: int, y2: int) -> int:
    return (b.x - a.x) * (y2 - 2 * a.y) - (b.y - a.y) * (x2 - 2 * a.x)


def _is_top_left(a: RasterVertex, b: RasterVertex) -> bool:
    delta_x = b.x - a.x
    delta_y = b.y - a.y
    return delta_y < 0 or (delta_y == 0 and delta_x > 0)


def raster_triangle(frame: Frame, vertices: Sequence[RasterVertex], texture: bytes,
                    shade_bank: int = 0) -> int:
    if len(vertices) != 3 or len(texture) != 65536:
        raise ValueError("a triangle needs three vertices and a 256x256 texture")
    a, b, c = vertices
    area = _edge(a, b, 2 * c.x, 2 * c.y)
    if area == 0:
        return 0
    if area < 0:
        b, c = c, b
        area = -area
    minimum_x = max(0, min(a.x, b.x, c.x))
    maximum_x = min(frame.width - 1, max(a.x, b.x, c.x))
    minimum_y = max(0, min(a.y, b.y, c.y))
    maximum_y = min(frame.height - 1, max(a.y, b.y, c.y))
    edges = ((b, c), (c, a), (a, b))
    biases = tuple(0 if _is_top_left(first, second) else -1 for first, second in edges)
    samples = 0
    for y in range(minimum_y, maximum_y + 1):
        for x in range(minimum_x, maximum_x + 1):
            x2 = x * 2 + 1
            y2 = y * 2 + 1
            raw_weights = tuple(_edge(first, second, x2, y2) for first, second in edges)
            if any(weight + bias < 0 for weight, bias in zip(raw_weights, biases)):
                continue
            # ``area`` was evaluated in the same doubled coordinate space.
            denominator = area
            inverse_depth = sum(vertex.inverse_depth * weight
                                for vertex, weight in zip((a, b, c), raw_weights)) // denominator
            offset = y * frame.width + x
            if inverse_depth <= frame.depth[offset]:
                continue
            u = sum(vertex.u * weight for vertex, weight in zip((a, b, c), raw_weights)) // denominator
            v = sum(vertex.v * weight for vertex, weight in zip((a, b, c), raw_weights)) // denominator
            frame.depth[offset] = max(0, min(65535, inverse_depth))
            frame.color[offset] = texture[(v & 255) * 256 + (u & 255)] + shade_bank * 60
            samples += 1
    return samples


def composite_aperture(destination: Frame, source: Frame, left: int, top: int,
                       width: int, height: int, outline: int) -> int:
    written = 0
    limit = width * width * height * height
    for y in range(height):
        destination_y = top + y
        if not 0 <= destination_y < destination.height:
            continue
        normalized_y = 2 * y + 1 - height
        for x in range(width):
            destination_x = left + x
            if not 0 <= destination_x < destination.width:
                continue
            normalized_x = 2 * x + 1 - width
            ellipse = (normalized_x * normalized_x * height * height +
                       normalized_y * normalized_y * width * width)
            if ellipse > limit:
                continue
            offset = destination_y * destination.width + destination_x
            if ellipse > limit - limit // 5:
                destination.color[offset] = outline
            else:
                source_x = x * source.width // width
                source_y = y * source.height // height
                destination.color[offset] = source.color[source_y * source.width + source_x]
            written += 1
    return written


def transform_point_through_portal(point: Vec3, source: Portal, destination: Portal) -> Vec3:
    relative = point - source.center
    local_right = relative.dot(source.right)
    local_up = relative.dot(source.up)
    local_forward = relative.dot(source.normal)
    return (destination.center + destination.right.scaled(-local_right) +
            destination.up.scaled(local_up) + destination.normal.scaled(-local_forward))


def transform_vector_through_portal(vector: Vec3, source: Portal, destination: Portal) -> Vec3:
    local_right = vector.dot(source.right)
    local_up = vector.dot(source.up)
    local_forward = vector.dot(source.normal)
    return (destination.right.scaled(-local_right) + destination.up.scaled(local_up) +
            destination.normal.scaled(-local_forward))


@dataclass
class FixedBody:
    position: list[int]
    velocity: list[int]
    half_height: int
    sleep_ticks: int = 0

    def tick(self) -> None:
        if self.sleep_ticks >= 30:
            return
        self.velocity[2] -= 2560 // 60
        for axis in range(3):
            self.position[axis] += self.velocity[axis] // 60
        if self.position[2] <= self.half_height:
            self.position[2] = self.half_height
            self.velocity[2] = max(0, self.velocity[2])
            if self.velocity[0] == self.velocity[1] == 0:
                self.sleep_ticks += 1
        else:
            self.sleep_ticks = 0


def checker_texture() -> bytes:
    return bytes(34 if ((x >> 4) ^ (y >> 4)) & 1 else 18
                 for y in range(256) for x in range(256))


def render_reference_frame(frame_number: int) -> tuple[Frame, dict[str, object]]:
    texture = checker_texture()
    frames = (Frame(80, 60), Frame(40, 30), Frame(20, 15))
    triangle_counts = []
    sample_counts = []
    for layer, frame in reversed(tuple(enumerate(frames))):
        frame.clear(2 + layer)
        shift = (frame_number // 8) % 3
        vertices = (
            RasterVertex(2 + shift, frame.height - 3, 50000 - layer * 7000, 0, 255),
            RasterVertex(frame.width - 3, frame.height - 3, 38000 - layer * 5000, 255, 255),
            RasterVertex(frame.width // 2, 2, 45000 - layer * 6000, 128, 0),
        )
        sample_counts.insert(0, raster_triangle(frame, vertices, texture, layer))
        triangle_counts.insert(0, 1)
    composite_aperture(frames[1], frames[2], 14, 7, 12, 16, 242)
    composite_aperture(frames[0], frames[1], 26, 11, 28, 40, 241)
    report = {
        "frame": frame_number,
        "logical_crc32": binascii.crc32(frames[0].color) & 0xFFFFFFFF,
        "triangles": triangle_counts,
        "samples": sample_counts,
    }
    return frames[0], report


def benchmark(frame_count: int = 854) -> dict[str, object]:
    route_hash = 0
    sample_totals = [0, 0, 0]
    final_frame_hash = 0
    body = FixedBody([0, 0, 4 * 256], [0, 0, 0], 64)
    for frame_number in range(frame_count):
        frame, report = render_reference_frame(frame_number)
        body.tick()
        final_frame_hash = int(report["logical_crc32"])
        route_hash = binascii.crc32(frame.color, route_hash) & 0xFFFFFFFF
        for layer, value in enumerate(report["samples"]):
            sample_totals[layer] += int(value)
    return {
        "format": "T3D2 host reference benchmark v1",
        "frames": frame_count,
        "route_crc32": route_hash,
        "final_frame_crc32": final_frame_hash,
        "sample_totals": sample_totals,
        "body_state": {"position": body.position, "velocity": body.velocity,
                       "sleep_ticks": body.sleep_ticks},
    }


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frames", type=int, default=854)
    arguments = parser.parse_args(argv)
    if arguments.frames <= 0:
        parser.error("--frames must be positive")
    print(json.dumps(benchmark(arguments.frames), indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
