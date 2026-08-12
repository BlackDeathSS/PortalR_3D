#!/usr/bin/env python3
"""Compile a T3D2 JSON scene plus OBJ/PNG assets into checked AppVars."""

from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, Sequence

from PIL import Image

import t3d2_format as fmt


class CompileError(ValueError):
    pass


Vec2 = tuple[float, float]
Vec3 = tuple[float, float, float]


def add(a: Vec3, b: Vec3) -> Vec3:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def sub(a: Vec3, b: Vec3) -> Vec3:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def scale(a: Vec3, amount: float) -> Vec3:
    return (a[0] * amount, a[1] * amount, a[2] * amount)


def dot(a: Vec3, b: Vec3) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def cross(a: Vec3, b: Vec3) -> Vec3:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def length(a: Vec3) -> float:
    return math.sqrt(dot(a, a))


def normalize(a: Vec3) -> Vec3:
    magnitude = length(a)
    if magnitude < 1e-10:
        raise CompileError("zero-length vector")
    return scale(a, 1.0 / magnitude)


def midpoint(a: Vec3, b: Vec3) -> Vec3:
    return scale(add(a, b), 0.5)


def vec3(value: Sequence[object], label: str) -> Vec3:
    if not isinstance(value, list) or len(value) != 3:
        raise CompileError(f"{label} must contain three numbers")
    return (float(value[0]), float(value[1]), float(value[2]))


@dataclass(frozen=True)
class Vertex:
    position: Vec3
    uv: Vec2
    normal: Vec3
    shade: int = 0

    def interpolated(self, other: "Vertex", amount: float) -> "Vertex":
        inverse = 1.0 - amount
        blended_normal = (
            self.normal[0] * inverse + other.normal[0] * amount,
            self.normal[1] * inverse + other.normal[1] * amount,
            self.normal[2] * inverse + other.normal[2] * amount,
        )
        return Vertex(
            (
                self.position[0] * inverse + other.position[0] * amount,
                self.position[1] * inverse + other.position[1] * amount,
                self.position[2] * inverse + other.position[2] * amount,
            ),
            (
                self.uv[0] * inverse + other.uv[0] * amount,
                self.uv[1] * inverse + other.uv[1] * amount,
            ),
            normalize(blended_normal),
            round(self.shade * inverse + other.shade * amount),
        )


@dataclass(frozen=True)
class SourceTriangle:
    vertices: tuple[Vertex, Vertex, Vertex]
    material: int
    priority: int
    flags: int


@dataclass
class Cell:
    name: str
    minimum: Vec3
    maximum: Vec3


@dataclass
class Meshlet:
    cell: int
    material: int
    priority: int
    flags: int
    vertices: list[Vertex] = field(default_factory=list)
    triangles: list[tuple[int, int, int]] = field(default_factory=list)
    page: int = 0
    payload_offset: int = 0


def load_mtl(path: Path) -> list[dict[str, object]]:
    materials: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as error:
        raise CompileError(f"cannot read MTL {path}: {error}") from error
    for line_number, raw_line in enumerate(lines, 1):
        words = raw_line.split("#", 1)[0].split()
        if not words:
            continue
        if words[0] == "newmtl" and len(words) >= 2:
            current = {"name": words[1], "shade": 3, "mip_bias": 0}
            materials.append(current)
        elif words[0] == "Kd" and len(words) >= 4 and current is not None:
            try:
                red, green, blue = (max(0.0, min(1.0, float(value))) for value in words[1:4])
            except ValueError as error:
                raise CompileError(f"{path}:{line_number}: invalid Kd") from error
            luminance = red * 0.2126 + green * 0.7152 + blue * 0.0722
            current["shade"] = max(0, min(3, round(luminance * 3.0)))
    if not materials:
        raise CompileError(f"MTL {path} declares no materials")
    return materials


def discover_mtl_paths(base: Path, manifest: dict[str, object]) -> list[Path]:
    paths: list[Path] = []
    declared = manifest.get("material_libraries", [])
    if not isinstance(declared, list):
        raise CompileError("material_libraries must be an array")
    paths.extend(base / str(value) for value in declared)
    meshes = manifest.get("meshes", [])
    if isinstance(meshes, list):
        for mesh in meshes:
            if not isinstance(mesh, dict) or "obj" not in mesh:
                continue
            obj_path = base / str(mesh["obj"])
            try:
                lines = obj_path.read_text(encoding="utf-8").splitlines()
            except OSError:
                continue
            for line in lines:
                words = line.split("#", 1)[0].split()
                if words and words[0] == "mtllib":
                    paths.extend(obj_path.parent / name for name in words[1:])
    unique: list[Path] = []
    for path in paths:
        resolved = path.resolve()
        if resolved not in unique:
            unique.append(resolved)
    return unique


def _obj_index(token: str, count: int, label: str) -> int:
    try:
        raw = int(token)
    except ValueError as error:
        raise CompileError(f"invalid OBJ {label} index {token!r}") from error
    index = raw - 1 if raw > 0 else count + raw
    if index < 0 or index >= count:
        raise CompileError(f"OBJ {label} index {raw} is out of range")
    return index


def load_obj(path: Path, material_indices: dict[str, int], default_material: int) -> list[SourceTriangle]:
    positions: list[Vec3] = []
    texture_coordinates: list[Vec2] = []
    normals: list[Vec3] = []
    faces: list[tuple[list[tuple[int, int | None, int | None]], int]] = []
    current_material = default_material

    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as error:
        raise CompileError(f"cannot read OBJ {path}: {error}") from error
    for line_number, raw_line in enumerate(lines, 1):
        words = raw_line.split("#", 1)[0].split()
        if not words:
            continue
        command = words[0]
        try:
            if command == "v" and len(words) >= 4:
                positions.append((float(words[1]), float(words[2]), float(words[3])))
            elif command == "vt" and len(words) >= 3:
                texture_coordinates.append((float(words[1]), 1.0 - float(words[2])))
            elif command == "vn" and len(words) >= 4:
                normals.append(normalize((float(words[1]), float(words[2]), float(words[3]))))
            elif command == "usemtl" and len(words) >= 2:
                if words[1] not in material_indices:
                    raise CompileError(f"OBJ uses undeclared material {words[1]!r}")
                current_material = material_indices[words[1]]
            elif command == "f" and len(words) >= 4:
                face: list[tuple[int, int | None, int | None]] = []
                for word in words[1:]:
                    parts = word.split("/")
                    vertex_index = _obj_index(parts[0], len(positions), "position")
                    uv_index = (
                        _obj_index(parts[1], len(texture_coordinates), "texture")
                        if len(parts) > 1 and parts[1]
                        else None
                    )
                    normal_index = (
                        _obj_index(parts[2], len(normals), "normal")
                        if len(parts) > 2 and parts[2]
                        else None
                    )
                    face.append((vertex_index, uv_index, normal_index))
                faces.append((face, current_material))
        except (ValueError, CompileError) as error:
            raise CompileError(f"{path}:{line_number}: {error}") from error

    output: list[SourceTriangle] = []
    for face, material in faces:
        for corner in range(1, len(face) - 1):
            indices = (face[0], face[corner], face[corner + 1])
            face_normal = normalize(cross(
                sub(positions[indices[1][0]], positions[indices[0][0]]),
                sub(positions[indices[2][0]], positions[indices[0][0]]),
            ))
            vertices = []
            for position_index, uv_index, normal_index in indices:
                vertices.append(Vertex(
                    positions[position_index],
                    texture_coordinates[uv_index] if uv_index is not None else (0.0, 0.0),
                    normals[normal_index] if normal_index is not None else face_normal,
                ))
            output.append(SourceTriangle(tuple(vertices), material, 128, 0))
    if not output:
        raise CompileError(f"OBJ {path} contains no triangles")
    return output


def transform_triangle(triangle: SourceTriangle, translation: Vec3, mesh_scale: Vec3,
                       priority: int, flags: int, material: int | None) -> SourceTriangle:
    transformed = []
    for vertex in triangle.vertices:
        position = add((
            vertex.position[0] * mesh_scale[0],
            vertex.position[1] * mesh_scale[1],
            vertex.position[2] * mesh_scale[2],
        ), translation)
        normal = normalize((
            vertex.normal[0] / mesh_scale[0],
            vertex.normal[1] / mesh_scale[1],
            vertex.normal[2] / mesh_scale[2],
        ))
        transformed.append(Vertex(position, vertex.uv, normal, vertex.shade))
    return SourceTriangle(tuple(transformed), material if material is not None else triangle.material,
                          priority, flags)


def subdivide(triangle: SourceTriangle, maximum_edge: float, depth: int = 0) -> list[SourceTriangle]:
    vertices = triangle.vertices
    lengths = [
        dot(sub(vertices[1].position, vertices[0].position), sub(vertices[1].position, vertices[0].position)),
        dot(sub(vertices[2].position, vertices[1].position), sub(vertices[2].position, vertices[1].position)),
        dot(sub(vertices[0].position, vertices[2].position), sub(vertices[0].position, vertices[2].position)),
    ]
    longest = max(range(3), key=lengths.__getitem__)
    if lengths[longest] <= maximum_edge * maximum_edge:
        return [triangle]
    if depth >= 8:
        raise CompileError("affine subdivision exceeded depth 8; raise affine_max_edge or rescale the mesh")
    edge_indices = ((0, 1, 2), (1, 2, 0), (2, 0, 1))[longest]
    first, second, opposite = edge_indices
    middle = vertices[first].interpolated(vertices[second], 0.5)
    one = SourceTriangle((vertices[first], middle, vertices[opposite]),
                         triangle.material, triangle.priority, triangle.flags)
    two = SourceTriangle((middle, vertices[second], vertices[opposite]),
                         triangle.material, triangle.priority, triangle.flags)
    return subdivide(one, maximum_edge, depth + 1) + subdivide(two, maximum_edge, depth + 1)


def clip_polygon_axis(vertices: list[Vertex], axis: int, boundary: float,
                      keep_greater: bool) -> list[Vertex]:
    if not vertices:
        return []
    output: list[Vertex] = []
    previous = vertices[-1]
    previous_distance = previous.position[axis] - boundary
    previous_inside = previous_distance >= -1e-7 if keep_greater else previous_distance <= 1e-7
    for current in vertices:
        current_distance = current.position[axis] - boundary
        current_inside = current_distance >= -1e-7 if keep_greater else current_distance <= 1e-7
        if current_inside != previous_inside:
            denominator = previous.position[axis] - current.position[axis]
            amount = 0.0 if abs(denominator) < 1e-12 else previous_distance / denominator
            output.append(previous.interpolated(current, amount))
        if current_inside:
            output.append(current)
        previous = current
        previous_distance = current_distance
        previous_inside = current_inside
    return output


def clip_triangle_to_cell(triangle: SourceTriangle, cell: Cell) -> list[SourceTriangle]:
    polygon = list(triangle.vertices)
    for axis in range(3):
        polygon = clip_polygon_axis(polygon, axis, cell.minimum[axis], True)
        polygon = clip_polygon_axis(polygon, axis, cell.maximum[axis], False)
    output = []
    for index in range(1, len(polygon) - 1):
        vertices = (polygon[0], polygon[index], polygon[index + 1])
        if length(cross(sub(vertices[1].position, vertices[0].position),
                        sub(vertices[2].position, vertices[0].position))) > 1e-7:
            output.append(SourceTriangle(vertices, triangle.material,
                                         triangle.priority, triangle.flags))
    return output


def point_in_cell(point: Vec3, cell: Cell, tolerance: float = 1e-6) -> bool:
    return all(cell.minimum[axis] - tolerance <= point[axis] <=
               cell.maximum[axis] + tolerance for axis in range(3))


def vertex_key(vertex: Vertex) -> tuple[int, ...]:
    return tuple(round(value * 65536.0) for value in
                 (*vertex.position, *vertex.uv, *vertex.normal, vertex.shade))


def build_meshlets(triangles_by_cell: list[list[SourceTriangle]]) -> list[Meshlet]:
    output: list[Meshlet] = []
    for cell_index, triangles in enumerate(triangles_by_cell):
        groups: dict[tuple[int, int, int], list[SourceTriangle]] = {}
        for triangle in triangles:
            groups.setdefault((triangle.material, triangle.priority, triangle.flags), []).append(triangle)
        for (material, priority, flags), group in sorted(groups.items()):
            current = Meshlet(cell_index, material, priority, flags)
            lookup: dict[tuple[int, ...], int] = {}
            for triangle in group:
                keys = [vertex_key(vertex) for vertex in triangle.vertices]
                new_vertices = sum(key not in lookup for key in keys)
                if current.triangles and (
                    len(current.triangles) >= fmt.MESHLET_MAX_TRIANGLES or
                    len(current.vertices) + new_vertices > fmt.MESHLET_MAX_VERTICES
                ):
                    output.append(current)
                    current = Meshlet(cell_index, material, priority, flags)
                    lookup = {}
                indices = []
                for key, vertex in zip(keys, triangle.vertices):
                    if key not in lookup:
                        lookup[key] = len(current.vertices)
                        current.vertices.append(vertex)
                    indices.append(lookup[key])
                current.triangles.append(tuple(indices))
            if current.triangles:
                output.append(current)
    if len(output) > fmt.MAX_MESHLETS:
        raise CompileError(f"scene needs {len(output)} meshlets; limit is {fmt.MAX_MESHLETS}")
    return output


def pack_vertex(vertex: Vertex, origin: Vec3) -> bytes:
    local = [round((vertex.position[axis] - origin[axis]) * 256.0) for axis in range(3)]
    if any(value < -32768 or value > 32767 for value in local):
        raise CompileError("meshlet spans more than the Q8 int16 local-vertex range")
    normal = [max(-127, min(127, round(component * 127.0))) for component in vertex.normal]
    u = max(0, min(255, round(vertex.uv[0] * 255.0)))
    v = max(0, min(255, round(vertex.uv[1] * 255.0)))
    return fmt.VERTEX.pack(*local, u, v, *normal, max(0, min(3, vertex.shade)))


def meshlet_origin(meshlet: Meshlet) -> Vec3:
    return tuple(sum(vertex.position[axis] for vertex in meshlet.vertices) /
                 len(meshlet.vertices) for axis in range(3))  # type: ignore[return-value]


def meshlet_record(meshlet: Meshlet, origin: Vec3) -> bytes:
    minimum = [min(vertex.position[axis] for vertex in meshlet.vertices) for axis in range(3)]
    maximum = [max(vertex.position[axis] for vertex in meshlet.vertices) for axis in range(3)]
    center = [(minimum[axis] + maximum[axis]) * 0.5 for axis in range(3)]
    relative_center = [round((center[axis] - origin[axis]) * 256.0) for axis in range(3)]
    radius = max(length(sub(vertex.position, tuple(center))) for vertex in meshlet.vertices)
    radius_fixed = round(radius * 256.0)
    if any(value < -32768 or value > 32767 for value in relative_center) or \
       not 0 <= radius_fixed <= 65535:
        raise CompileError("meshlet bounds do not fit the packed Q8 record")
    normals = [vertex.normal for vertex in meshlet.vertices]
    try:
        cone_axis = normalize(tuple(sum(normal[axis] for normal in normals) for axis in range(3)))
        cutoff = min(dot(cone_axis, normal) for normal in normals)
        packed_axis = [max(-127, min(127, round(value * 127.0))) for value in cone_axis]
        packed_cutoff = max(-127, min(127, round(cutoff * 127.0)))
    except CompileError:
        packed_axis = [0, 0, 0]
        packed_cutoff = -127
    return fmt.MESHLET.pack(
        meshlet.cell, meshlet.page, meshlet.priority, meshlet.material, meshlet.flags,
        len(meshlet.vertices), len(meshlet.triangles), meshlet.payload_offset,
        fmt.fixed(origin[0]), fmt.fixed(origin[1]), fmt.fixed(origin[2]),
        *relative_center, radius_fixed,
        *packed_axis, packed_cutoff,
    )


def pack_geometry_pages(meshlets: list[Meshlet]) -> list[bytes]:
    page_payloads: list[bytearray] = [bytearray()]
    page_counts = [0]
    for meshlet in meshlets:
        origin = meshlet_origin(meshlet)
        payload = bytearray()
        for vertex in meshlet.vertices:
            payload.extend(pack_vertex(vertex, origin))
        for triangle in meshlet.triangles:
            payload.extend(fmt.TRIANGLE.pack(*triangle))
        if len(payload) > fmt.MAX_GEOMETRY_PAYLOAD:
            raise CompileError("one meshlet exceeds a geometry page")
        if page_payloads[-1] and len(page_payloads[-1]) + len(payload) > fmt.MAX_GEOMETRY_PAYLOAD:
            page_payloads.append(bytearray())
            page_counts.append(0)
        meshlet.page = len(page_payloads) - 1
        meshlet.payload_offset = len(page_payloads[-1])
        page_payloads[-1].extend(payload)
        page_counts[-1] += 1
    pages = []
    for page_index, payload in enumerate(page_payloads):
        header = fmt.GEOMETRY_HEADER.pack(
            b"T3DG", fmt.GEOMETRY_VERSION, page_index, fmt.GEOMETRY_HEADER.size,
            len(payload), fmt.crc32(payload), page_counts[page_index], 0,
        )
        pages.append(header + payload)
    if len(pages) > 100:
        raise CompileError("geometry requires more than T3D2G00...T3D2G99")
    return pages


def polygon_basis(vertices: list[Vec3], label: str) -> tuple[Vec3, Vec3, Vec3, Vec3, float, float]:
    if not 3 <= len(vertices) <= 8:
        raise CompileError(f"{label} must have 3..8 vertices")
    normal = normalize(cross(sub(vertices[1], vertices[0]), sub(vertices[2], vertices[0])))
    right = normalize(sub(vertices[1], vertices[0]))
    up = normalize(cross(normal, right))
    center = tuple(sum(vertex[axis] for vertex in vertices) / len(vertices) for axis in range(3))
    if any(abs(dot(normal, sub(vertex, vertices[0]))) > 1e-4 for vertex in vertices):
        raise CompileError(f"{label} is not planar")
    signs = []
    for index, vertex in enumerate(vertices):
        following = vertices[(index + 1) % len(vertices)]
        after = vertices[(index + 2) % len(vertices)]
        signs.append(dot(cross(sub(following, vertex), sub(after, following)), normal))
    if any(value < -1e-6 for value in signs):
        raise CompileError(f"{label} winding is concave or inconsistent")
    half_width = max(abs(dot(sub(vertex, center), right)) for vertex in vertices)
    half_height = max(abs(dot(sub(vertex, center), up)) for vertex in vertices)
    return center, right, up, normal, half_width, half_height


def pvs_rows(cell_count: int, gateway_pairs: list[tuple[int, int]]) -> list[bytes]:
    graph = [set() for _ in range(cell_count)]
    for source, destination in gateway_pairs:
        graph[source].add(destination)
    row_size = (cell_count + 7) // 8
    rows = []
    for start in range(cell_count):
        visible = {start}
        pending = [start]
        while pending:
            current = pending.pop()
            for destination in graph[current]:
                if destination not in visible:
                    visible.add(destination)
                    pending.append(destination)
        row = bytearray(row_size)
        for index in visible:
            row[index // 8] |= 1 << (index & 7)
        rows.append(bytes(row))
    return rows


def build_collision(meshlets: list[Meshlet], cell_count: int) -> tuple[bytes, list[int]]:
    items_by_cell: list[list[tuple[int, int, tuple[float, ...], Vec3]]] = [
        [] for _ in range(cell_count)
    ]
    for meshlet_index, meshlet in enumerate(meshlets):
        for triangle_index, triangle in enumerate(meshlet.triangles):
            points = [meshlet.vertices[index].position for index in triangle]
            bounds = tuple(
                value
                for axis in range(3)
                for value in (min(point[axis] for point in points),
                              max(point[axis] for point in points))
            )
            centroid = tuple(sum(point[axis] for point in points) / 3.0 for axis in range(3))
            items_by_cell[meshlet.cell].append((meshlet_index, triangle_index, bounds, centroid))

    nodes: list[dict[str, object]] = []
    references: list[tuple[int, int]] = []
    roots: list[int] = []

    def create_node(items: list[tuple[int, int, tuple[float, ...], Vec3]]) -> int:
        node_index = len(nodes)
        all_bounds = tuple(
            value
            for axis in range(3)
            for value in (min(item[2][axis * 2] for item in items),
                          max(item[2][axis * 2 + 1] for item in items))
        )
        nodes.append({"bounds": all_bounds})
        if len(items) <= 8:
            first = len(references)
            references.extend((item[0], item[1]) for item in items)
            nodes[node_index].update(left=0xFFFF, right=0xFFFF, first=first,
                                     count=len(items), axis=0xFF)
            return node_index
        extents = [all_bounds[axis * 2 + 1] - all_bounds[axis * 2] for axis in range(3)]
        axis = max(range(3), key=extents.__getitem__)
        items.sort(key=lambda item: item[3][axis])
        middle = len(items) // 2
        left = create_node(items[:middle])
        right = create_node(items[middle:])
        nodes[node_index].update(left=left, right=right, first=0, count=0, axis=axis)
        return node_index

    for items in items_by_cell:
        roots.append(create_node(items) if items else 0xFFFF)
    if len(nodes) > 65535 or len(references) > 65535:
        raise CompileError("collision BVH exceeds its 16-bit index space")
    node_bytes = bytearray()
    for node in nodes:
        bounds = node["bounds"]
        quantized = [fmt.q4(float(value)) for value in bounds]  # type: ignore[arg-type]
        node_bytes.extend(fmt.COLLISION_NODE.pack(
            *quantized, int(node["left"]), int(node["right"]), int(node["first"]),
            int(node["count"]), int(node["axis"]),
        ))
    reference_bytes = b"".join(fmt.COLLISION_REFERENCE.pack(meshlet, triangle, 0)
                               for meshlet, triangle in references)
    header = fmt.COLLISION_HEADER.pack(
        b"C2BV", 1, 4, fmt.COLLISION_HEADER.size, len(nodes), len(references),
        fmt.COLLISION_HEADER.size, fmt.COLLISION_HEADER.size + len(node_bytes),
    )
    return header + node_bytes + reference_bytes, roots


def compile_texture(path: Path | None, procedural_style: str | None = None) -> tuple[bytes, bytes, bytes, list[int]]:
    if path is not None and procedural_style is not None:
        raise CompileError("texture_atlas and procedural_texture are mutually exclusive")
    if path is None:
        image = Image.new("RGB", (256, 256))
        pixels = image.load()
        if procedural_style in (None, "checker"):
            for y in range(256):
                for x in range(256):
                    value = 210 if ((x >> 4) ^ (y >> 4)) & 1 else 70
                    pixels[x, y] = (value, value, value)
        elif procedural_style == "portal_lab":
            for y in range(256):
                for x in range(256):
                    local_x = x & 127
                    local_y = y & 127
                    seam = local_x % 32 < 2 or local_y % 32 < 2
                    inset = local_x % 32 in (4, 5, 26, 27) or \
                        local_y % 32 in (4, 5, 26, 27)
                    if x < 128 and y < 128:
                        # Warm wall panels with broad seams and a restrained
                        # vertical luminance change; no high-frequency checker.
                        value = 204 - local_y // 10 + ((local_x // 32) & 1) * 5
                        pixels[x, y] = (76, 82, 88) if seam else \
                            ((154, 163, 169) if inset else (value, value + 4, value + 7))
                    elif x >= 128 and y < 128:
                        # Directional floor slabs: frequent depth bands and a
                        # sparse longitudinal seam, never a checker pattern.
                        floor_seam = local_y % 16 < 2 or local_x % 64 < 2
                        floor_inset = local_y % 16 in (4, 5)
                        value = 92 + ((local_y // 16) & 1) * 10
                        pixels[x, y] = (30, 38, 44) if floor_seam else \
                            ((62, 72, 79) if floor_inset else (value - 8, value, value + 6))
                    elif x < 128:
                        value = 218 - ((local_x // 32) & 1) * 5
                        pixels[x, y] = (112, 120, 126) if seam else \
                            ((180, 188, 193) if inset else (value, value + 3, value + 5))
                    else:
                        value = 166 + ((local_y // 32) & 1) * 7
                        pixels[x, y] = (64, 74, 82) if seam else \
                            ((119, 132, 140) if inset else (value - 12, value, value + 8))
        else:
            raise CompileError(f"unknown procedural_texture {procedural_style!r}")
    else:
        image = Image.open(path).convert("RGB")
        if image.size != (256, 256):
            raise CompileError(f"texture atlas {path} is {image.size}, expected 256x256")
    quantized = image.quantize(colors=60, method=Image.Quantize.MEDIANCUT,
                               dither=Image.Dither.NONE)
    palette_data = quantized.getpalette()[:180]
    palette_data.extend([0] * (180 - len(palette_data)))
    texture = quantized.tobytes()
    mip = bytearray()
    for size in (128, 64, 32, 16, 8, 4, 2, 1):
        resized = image.resize((size, size), Image.Resampling.BOX)
        indexed = resized.quantize(palette=quantized, dither=Image.Dither.NONE)
        mip.extend(indexed.tobytes())
    palette: list[int] = []
    for factor in (0.52, 0.68, 0.84, 1.0):
        for index in range(60):
            red, green, blue = palette_data[index * 3:index * 3 + 3]
            r5 = min(31, round(red * factor * 31 / 255))
            g5 = min(31, round(green * factor * 31 / 255))
            b5 = min(31, round(blue * factor * 31 / 255))
            palette.append((r5 << 10) | (g5 << 5) | b5)
    reserved = [
        0x0000, 0x7C00, 0x021F, 0x7FFF, 0x4210, 0x6318, 0x001F, 0x03E0,
        0x7C00, 0x7FE0, 0x03FF, 0x7C1F, 0x2108, 0x318C, 0x5294, 0x0000,
    ]
    palette.extend(reserved)
    return texture[:32768], texture[32768:], bytes(mip), palette


def validate_certification(manifest: dict[str, object]) -> None:
    certification = manifest.get("certification")
    if certification is None:
        return
    if not isinstance(certification, dict):
        raise CompileError("certification must be an object")
    views = certification.get("views", [])
    if not isinstance(views, list) or not views:
        raise CompileError("a certified scene must declare certification.views")
    triangle_limits = (96, 64, 32)
    sample_limits = (4800, 1200, 300)
    for index, view in enumerate(views):
        if not isinstance(view, dict):
            raise CompileError(f"certification view {index} must be an object")
        triangles = view.get("triangles")
        samples = view.get("samples")
        if not isinstance(triangles, list) or not isinstance(samples, list) or \
           len(triangles) != 3 or len(samples) != 3:
            raise CompileError(f"certification view {index} needs three triangle and sample counts")
        for layer in range(3):
            if int(triangles[layer]) < 0 or int(samples[layer]) < 0 or \
               int(triangles[layer]) > triangle_limits[layer] or \
               int(samples[layer]) > sample_limits[layer]:
                raise CompileError(f"certification view {index} exceeds layer {layer} budget")


def compile_scene(manifest_path: Path, output_directory: Path) -> dict[str, object]:
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise CompileError(f"cannot read manifest {manifest_path}: {error}") from error
    if not isinstance(manifest, dict):
        raise CompileError("manifest root must be an object")
    validate_certification(manifest)
    base = manifest_path.parent

    raw_cells = manifest.get("cells")
    if not isinstance(raw_cells, list) or not 1 <= len(raw_cells) <= fmt.MAX_CELLS:
        raise CompileError(f"cells must contain 1..{fmt.MAX_CELLS} entries")
    cells: list[Cell] = []
    cell_names: dict[str, int] = {}
    for index, raw in enumerate(raw_cells):
        if not isinstance(raw, dict):
            raise CompileError(f"cell {index} must be an object")
        name = str(raw.get("name", index))
        minimum = vec3(raw.get("min"), f"cell {name} min")
        maximum = vec3(raw.get("max"), f"cell {name} max")
        if any(minimum[axis] >= maximum[axis] for axis in range(3)):
            raise CompileError(f"cell {name} has invalid bounds")
        if name in cell_names:
            raise CompileError(f"duplicate cell name {name!r}")
        cell_names[name] = index
        cells.append(Cell(name, minimum, maximum))

    raw_materials = manifest.get("materials")
    if raw_materials is None:
        mtl_paths = discover_mtl_paths(base, manifest)
        raw_materials = []
        for mtl_path in mtl_paths:
            raw_materials.extend(load_mtl(mtl_path))
        if not raw_materials:
            raw_materials = [{"name": "default", "shade": 3}]
    if not isinstance(raw_materials, list) or not 1 <= len(raw_materials) <= fmt.MAX_MATERIALS:
        raise CompileError(f"materials must contain 1..{fmt.MAX_MATERIALS} entries")
    materials: list[tuple[int, int]] = []
    material_names: dict[str, int] = {}
    for index, raw in enumerate(raw_materials):
        if not isinstance(raw, dict):
            raise CompileError(f"material {index} must be an object")
        name = str(raw.get("name", index))
        if name in material_names:
            raise CompileError(f"duplicate material name {name!r}")
        shade = int(raw.get("shade", 3))
        mip_bias = int(raw.get("mip_bias", 0))
        if not 0 <= shade <= 3 or not -8 <= mip_bias <= 7:
            raise CompileError(f"material {name} shade/mip_bias is out of range")
        flags = 1 if bool(raw.get("cutout", False)) else 0
        materials.append((flags, mip_bias, shade, 0))
        material_names[name] = index

    raw_meshes = manifest.get("meshes", [])
    if not isinstance(raw_meshes, list):
        raise CompileError("meshes must be an array")
    triangles_by_cell: list[list[SourceTriangle]] = [[] for _ in cells]
    source_triangle_count = 0
    subdivided_triangle_count = 0
    for mesh_number, raw in enumerate(raw_meshes):
        if not isinstance(raw, dict) or "obj" not in raw:
            raise CompileError(f"mesh {mesh_number} must specify obj")
        default_material_name = str(raw.get("material", next(iter(material_names))))
        if default_material_name not in material_names:
            raise CompileError(f"mesh {mesh_number} names unknown material {default_material_name!r}")
        override_material = material_names[default_material_name] if "material" in raw else None
        triangles = load_obj(base / str(raw["obj"]), material_names,
                             material_names[default_material_name])
        source_triangle_count += len(triangles)
        translation = vec3(raw.get("translation", [0, 0, 0]), f"mesh {mesh_number} translation")
        scale_value = raw.get("scale", [1, 1, 1])
        mesh_scale = ((float(scale_value),) * 3 if isinstance(scale_value, (int, float))
                      else vec3(scale_value, f"mesh {mesh_number} scale"))
        if any(abs(value) < 1e-8 for value in mesh_scale):
            raise CompileError(f"mesh {mesh_number} scale cannot contain zero")
        priority = int(raw.get("priority", 128))
        if not 0 <= priority <= 255:
            raise CompileError(f"mesh {mesh_number} priority must fit uint8")
        flags = 1 if bool(raw.get("essential", False)) else 0
        maximum_edge = float(raw.get("affine_max_edge", manifest.get("affine_max_edge", 2.0)))
        if maximum_edge <= 0:
            raise CompileError("affine_max_edge must be positive")
        explicit_cell = raw.get("cell", "auto")
        explicit_cell_index = None
        if explicit_cell != "auto":
            cell_key = str(explicit_cell)
            if cell_key not in cell_names:
                raise CompileError(f"mesh {mesh_number} names unknown cell {explicit_cell!r}")
            explicit_cell_index = cell_names[cell_key]
        for triangle in triangles:
            transformed = transform_triangle(triangle, translation, mesh_scale,
                                               priority, flags, override_material)
            for divided in subdivide(transformed, maximum_edge):
                subdivided_triangle_count += 1
                if explicit_cell_index is not None:
                    if not all(point_in_cell(vertex.position, cells[explicit_cell_index])
                               for vertex in divided.vertices):
                        raise CompileError(f"mesh {mesh_number} leaves explicit cell {explicit_cell!r}")
                    triangles_by_cell[explicit_cell_index].append(divided)
                else:
                    clipped = 0
                    for cell_index, cell in enumerate(cells):
                        pieces = clip_triangle_to_cell(divided, cell)
                        triangles_by_cell[cell_index].extend(pieces)
                        clipped += len(pieces)
                    if clipped == 0:
                        raise CompileError(f"mesh {mesh_number} has geometry outside all cells")

    meshlets = build_meshlets(triangles_by_cell)
    geometry_pages = pack_geometry_pages(meshlets)
    collision, collision_roots = build_collision(meshlets, len(cells))

    vertex_pool: list[int] = []
    gateway_build: list[dict[str, object]] = []
    gateway_pairs: list[tuple[int, int]] = []
    raw_gateways = manifest.get("gateways", [])
    if not isinstance(raw_gateways, list):
        raise CompileError("gateways must be an array")
    for gateway_index, raw in enumerate(raw_gateways):
        if not isinstance(raw, dict):
            raise CompileError(f"gateway {gateway_index} must be an object")
        try:
            source = cell_names[str(raw["source"])]
            destination = cell_names[str(raw["destination"])]
        except KeyError as error:
            raise CompileError(f"gateway {gateway_index} references an unknown cell") from error
        vertices = [vec3(vertex, f"gateway {gateway_index} vertex")
                    for vertex in raw.get("vertices", [])]
        center, right, up, normal, half_width, half_height = polygon_basis(
            vertices, f"gateway {gateway_index}")
        del center, right, up, half_width, half_height
        if not all(point_in_cell(vertex, cells[source]) and point_in_cell(vertex, cells[destination])
                   for vertex in vertices):
            raise CompileError(f"gateway {gateway_index} must lie in both adjacent cell bounds")
        vertex_index = len(vertex_pool)
        vertex_pool.extend(fmt.fixed(component) for vertex in vertices for component in vertex)
        gateway_build.append(dict(source=source, destination=destination, vertices=vertices,
                                  vertex_index=vertex_index, normal=normal))
        gateway_pairs.append((source, destination))
        if bool(raw.get("two_way", True)):
            gateway_build.append(dict(source=destination, destination=source,
                                      vertices=list(reversed(vertices)), vertex_index=vertex_index,
                                      normal=scale(normal, -1.0)))
            gateway_pairs.append((destination, source))
    gateway_build.sort(key=lambda gateway: (int(gateway["source"]), int(gateway["destination"])))
    if len(gateway_build) > fmt.MAX_GATEWAYS:
        raise CompileError(f"expanded gateway count exceeds {fmt.MAX_GATEWAYS}")

    portal_build: list[dict[str, object]] = []
    raw_surfaces = manifest.get("portal_surfaces", [])
    if not isinstance(raw_surfaces, list):
        raise CompileError("portal_surfaces must be an array")
    for surface_index, raw in enumerate(raw_surfaces):
        if not isinstance(raw, dict):
            raise CompileError(f"portal surface {surface_index} must be an object")
        try:
            cell_index = cell_names[str(raw["cell"])]
        except KeyError as error:
            raise CompileError(f"portal surface {surface_index} references an unknown cell") from error
        vertices = [vec3(vertex, f"portal surface {surface_index} vertex")
                    for vertex in raw.get("vertices", [])]
        center, right, up, normal, half_width, half_height = polygon_basis(
            vertices, f"portal surface {surface_index}")
        if not all(point_in_cell(vertex, cells[cell_index]) for vertex in vertices):
            raise CompileError(f"portal surface {surface_index} leaves cell bounds")
        placeable = bool(raw.get("placeable", True))
        if placeable and (half_width < 1.5 or half_height < 1.75):
            raise CompileError(
                f"portal surface {surface_index} cannot fit the 3.0x3.5 portal aperture")
        if fmt.fixed(half_width) > 65535 or fmt.fixed(half_height) > 65535:
            raise CompileError(f"portal surface {surface_index} extents exceed uint16 Q8")
        vertex_index = len(vertex_pool)
        vertex_pool.extend(fmt.fixed(component) for vertex in vertices for component in vertex)
        portal_build.append(dict(cell=cell_index, vertices=vertices, vertex_index=vertex_index,
                                 center=center, right=right, up=up, normal=normal,
                                 half_width=half_width, half_height=half_height,
                                 flags=1 if placeable else 0))
    if len(portal_build) > fmt.MAX_PORTAL_SURFACES:
        raise CompileError(f"portal surface count exceeds {fmt.MAX_PORTAL_SURFACES}")

    raw_bodies = manifest.get("bodies", [])
    if not isinstance(raw_bodies, list) or len(raw_bodies) > fmt.MAX_BODIES:
        raise CompileError(f"bodies must contain at most {fmt.MAX_BODIES} entries")
    body_values = []
    for body_index, raw in enumerate(raw_bodies):
        if not isinstance(raw, dict):
            raise CompileError(f"body {body_index} must be an object")
        shape_name = str(raw.get("shape", "box"))
        if shape_name not in ("box", "sphere"):
            raise CompileError(f"body {body_index} shape must be box or sphere")
        cell_index = cell_names.get(str(raw.get("cell")))
        if cell_index is None:
            raise CompileError(f"body {body_index} references an unknown cell")
        position = vec3(raw.get("position"), f"body {body_index} position")
        velocity = vec3(raw.get("velocity", [0, 0, 0]), f"body {body_index} velocity")
        half = vec3(raw.get("half_extent", [0.25, 0.25, 0.25]),
                    f"body {body_index} half_extent")
        if not point_in_cell(position, cells[cell_index]) or any(value <= 0 for value in half):
            raise CompileError(f"body {body_index} position/extent is invalid")
        half_fixed = [fmt.fixed(value) for value in half]
        if any(value > 65535 for value in half_fixed):
            raise CompileError(f"body {body_index} extent exceeds uint16")
        inverse_mass = int(raw.get("inverse_mass", 256))
        if not 0 <= inverse_mass <= 65535:
            raise CompileError(f"body {body_index} inverse_mass is out of range")
        body_values.append((1 if shape_name == "sphere" else 0, 0, cell_index,
                            *(fmt.fixed(value) for value in position),
                            *(fmt.fixed(value) for value in velocity),
                            *half_fixed, inverse_mass))

    spawn = manifest.get("spawn", {"cell": cells[0].name, "position": [0, 0, 0]})
    if not isinstance(spawn, dict):
        raise CompileError("spawn must be an object")
    spawn_cell = cell_names.get(str(spawn.get("cell")))
    spawn_position = vec3(spawn.get("position"), "spawn position")
    if spawn_cell is None or not point_in_cell(spawn_position, cells[spawn_cell]):
        raise CompileError("spawn references an unknown cell or lies outside it")

    rows = pvs_rows(len(cells), gateway_pairs)
    meshlet_ranges = []
    gateway_ranges = []
    for cell_index in range(len(cells)):
        meshlet_indices = [index for index, meshlet in enumerate(meshlets) if meshlet.cell == cell_index]
        gateway_indices = [index for index, gateway in enumerate(gateway_build)
                           if int(gateway["source"]) == cell_index]
        meshlet_ranges.append((meshlet_indices[0] if meshlet_indices else 0,
                               len(meshlet_indices)))
        gateway_ranges.append((gateway_indices[0] if gateway_indices else 0,
                               len(gateway_indices)))

    sizes = {
        "header": fmt.MAP_HEADER.size,
        "cells": len(cells) * fmt.CELL.size,
        "gateways": len(gateway_build) * fmt.GATEWAY.size,
        "meshlets": len(meshlets) * fmt.MESHLET.size,
        "portals": len(portal_build) * fmt.PORTAL_SURFACE.size,
        "bodies": len(body_values) * fmt.BODY.size,
        "pvs": sum(map(len, rows)),
        "vertices": len(vertex_pool) * 4,
        "collision": len(collision),
        "palette": 512,
        "materials": len(materials) * fmt.MATERIAL.size,
    }
    offsets: dict[str, int] = {}
    cursor = 0
    for name in sizes:
        offsets[name] = cursor
        cursor += sizes[name]
    if cursor > fmt.MAX_APPVAR_PAYLOAD:
        raise CompileError(f"T3D2MAP is {cursor} bytes; AppVar limit is {fmt.MAX_APPVAR_PAYLOAD}")

    cell_bytes = bytearray()
    pvs_cursor = offsets["pvs"]
    for index, cell in enumerate(cells):
        first_meshlet, meshlet_count = meshlet_ranges[index]
        first_gateway, gateway_count = gateway_ranges[index]
        cell_bytes.extend(fmt.CELL.pack(
            fmt.fixed(cell.minimum[0]), fmt.fixed(cell.maximum[0]),
            fmt.fixed(cell.minimum[1]), fmt.fixed(cell.maximum[1]),
            fmt.fixed(cell.minimum[2]), fmt.fixed(cell.maximum[2]),
            first_meshlet, meshlet_count, first_gateway, gateway_count,
            pvs_cursor, len(rows[index]), collision_roots[index],
        ))
        pvs_cursor += len(rows[index])

    gateway_bytes = bytearray()
    for gateway in gateway_build:
        vertices = gateway["vertices"]
        normal = gateway["normal"]
        plane_distance = dot(normal, vertices[0])  # type: ignore[index]
        gateway_bytes.extend(fmt.GATEWAY.pack(
            int(gateway["source"]), int(gateway["destination"]), len(vertices), 0,
            offsets["vertices"] + int(gateway["vertex_index"]) * 4,
            *(fmt.q14(value) for value in normal), fmt.fixed(plane_distance),
        ))

    meshlet_bytes = b"".join(meshlet_record(meshlet, meshlet_origin(meshlet))
                              for meshlet in meshlets)
    portal_bytes = bytearray()
    for surface in portal_build:
        portal_bytes.extend(fmt.PORTAL_SURFACE.pack(
            int(surface["cell"]), len(surface["vertices"]), int(surface["flags"]),
            offsets["vertices"] + int(surface["vertex_index"]) * 4,
            *(fmt.fixed(value) for value in surface["center"]),
            *(fmt.q14(value) for value in surface["right"]),
            *(fmt.q14(value) for value in surface["up"]),
            *(fmt.q14(value) for value in surface["normal"]),
            fmt.fixed(float(surface["half_width"])), fmt.fixed(float(surface["half_height"])),
        ))
    body_bytes = b"".join(fmt.BODY.pack(*values) for values in body_values)
    vertex_bytes = b"".join(int(value).to_bytes(4, "little", signed=True) for value in vertex_pool)

    texture_path = manifest.get("texture_atlas")
    procedural_texture = manifest.get("procedural_texture")
    texture0, texture1, mip, palette = compile_texture(
        base / str(texture_path) if texture_path is not None else None,
        str(procedural_texture) if procedural_texture is not None else None,
    )
    palette_bytes = b"".join(value.to_bytes(2, "little") for value in palette)
    material_bytes = b"".join(fmt.MATERIAL.pack(*values) for values in materials)
    payload_without_header = b"".join((
        bytes(cell_bytes), bytes(gateway_bytes), meshlet_bytes, bytes(portal_bytes),
        body_bytes, b"".join(rows), vertex_bytes, collision, palette_bytes, material_bytes,
    ))
    total_size = fmt.MAP_HEADER.size + len(payload_without_header)
    header = fmt.MAP_HEADER.pack(
        b"T3D2", fmt.MAP_VERSION, 0, fmt.MAP_HEADER.size, total_size,
        fmt.crc32(payload_without_header), len(cells), len(gateway_build), len(meshlets),
        len(portal_build), len(materials), len(body_values), spawn_cell,
        *(fmt.fixed(value) for value in spawn_position),
        offsets["cells"], offsets["gateways"], offsets["meshlets"], offsets["portals"],
        offsets["bodies"], offsets["pvs"], offsets["vertices"], offsets["collision"],
        offsets["palette"], offsets["materials"],
    )
    map_payload = header + payload_without_header
    output_directory.mkdir(parents=True, exist_ok=True)
    written = [fmt.write_appvar(output_directory, "T3D2MAP", map_payload)]
    for page_index, page in enumerate(geometry_pages):
        written.append(fmt.write_appvar(output_directory, f"T3D2G{page_index:02d}", page))
    written.extend((
        fmt.write_appvar(output_directory, "T3D2TX0", texture0),
        fmt.write_appvar(output_directory, "T3D2TX1", texture1),
        fmt.write_appvar(output_directory, "T3D2MIP", mip),
    ))
    collision_fields = fmt.COLLISION_HEADER.unpack_from(collision)
    report: dict[str, object] = {
        "format": "T3D2 build report v1",
        "manifest": str(manifest_path),
        "map_bytes": len(map_payload),
        "geometry_page_bytes": [len(page) for page in geometry_pages],
        "texture_bytes": len(texture0) + len(texture1),
        "mip_bytes": len(mip),
        "cells": len(cells),
        "gateways": len(gateway_build),
        "source_triangles": source_triangle_count,
        "subdivided_triangles": subdivided_triangle_count,
        "stored_triangles": sum(len(meshlet.triangles) for meshlet in meshlets),
        "meshlets": len(meshlets),
        "collision_nodes": collision_fields[4],
        "collision_references": collision_fields[5],
        "appvars": [path.name for path in written],
        "certified": "certification" in manifest,
    }
    report_path = output_directory / "t3d2-build-report.json"
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return report


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--output", "-o", type=Path, required=True)
    arguments = parser.parse_args(argv)
    try:
        report = compile_scene(arguments.manifest.resolve(), arguments.output.resolve())
    except CompileError as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
