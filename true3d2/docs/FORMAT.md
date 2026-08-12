# T3D2 scene and binary format

The authoritative packed layouts and static size assertions are in
`src/t3d2_format.h`; `tools/t3d2_format.py` mirrors and tests them. Every offset
in `T3D2MAP` is absolute from the first byte of the map payload. Meshlet payload
offsets are relative to the geometry page payload after `T3D2GeometryHeader`.
World positions use signed Q16.8, bases use signed Q1.14, and collision bounds
use signed Q12.4.

## Authoring manifest

The minimal shape is:

```json
{
  "format": "T3D2 scene v1",
  "spawn": {"cell": "room", "position": [1, 2, 1.5]},
  "cells": [{"name": "room", "min": [0, 0, 0], "max": [8, 8, 4]}],
  "materials": [{"name": "wall", "shade": 3, "mip_bias": 0}],
  "meshes": [{"obj": "room.obj", "cell": "auto", "essential": true}],
  "gateways": [],
  "portal_surfaces": [],
  "bodies": []
}
```

`cell: "auto"` clips each triangle against the convex axis-aligned cell bounds.
An explicit cell requires every vertex to lie inside it. `affine_max_edge`
controls offline subdivision and defaults to 2 world units. OBJ polygons are
fan-triangulated. `usemtl` names must appear in `materials`; if that array is
omitted, `mtllib` files (or `material_libraries`) supply `newmtl` names and `Kd`
selects a static shade bank. A `texture_atlas` must be exactly 256x256.
Alternatively, `procedural_texture` may be `"checker"` or `"portal_lab"`;
the latter emits shaded wall panels, directional floor slabs, a light ceiling,
and divider panels. The two texture fields are mutually exclusive. Omitting
both produces the deterministic checker atlas used by legacy tests.

Gateways name `source`, `destination`, a convex planar `vertices` array of 3..8
points, and optional `two_way` (default true). Portal surfaces name `cell`, the
same kind of convex polygon, and optional `placeable`. Bodies accept `box` or
`sphere`, position/velocity, half extent, cell, and inverse mass.

Certified manifests include explicit measured/analysed view budgets:

```json
"certification": {
  "views": [{"triangles": [96, 64, 32], "samples": [4800, 1200, 300]}]
}
```

This declaration only enforces caps; it does not confer FPS certification.

## Emitted AppVars

- `T3D2MAP`: header, cells, gateways, meshlets, portal hosts, body spawns, PVS,
  shared polygon vertices, collision BVH, 256-entry palette, materials.
- `T3D2G00...`: CRC-checked geometry pages, each at most 55,000 payload bytes.
- `T3D2TX0/1`: two 32 KiB halves of the base-index texture atlas.
- `T3D2MIP`: 128 through 1 pixel levels, totaling 21,845 bytes.

The loader verifies signatures, versions, all counts/ranges, CRCs, cell and
gateway references, collision trees/references, page payload ranges, and every
resource size before setting `scene_loaded`.
