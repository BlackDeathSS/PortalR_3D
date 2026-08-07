# Feasibility and integration notes

## Feature boundary

`RENDER_LAYER_MAJOR_PORTALS=1` selects the prototype. With `0`, the copied
source builds the unchanged front-to-back column renderer. The root project is
not referenced by the experiment build.

The enabled path has two phases:

1. Trace all 80 layer-zero rays with `render_asm_cast_wall_begin`. Draw a
   terminal wall immediately, or draw the opaque part of a linked portal mask
   and retain the open center. Copy every exact 55-byte `RayDDAState` plus its
   14-byte hit into a fixed per-column checkpoint.
2. Coalesce adjacent continuing columns by `portal_id`. Decode the first hit's
   entry/exit direction pair and exit-axis constants once per run. Restore each
   ray in the run, use `render_asm_transform_ray_predecoded_state`, and resume
   `render_asm_cast_wall_continue`. Deeper portals use the proven existing
   transform path.

Columns have disjoint four-pixel destinations, so scheduling deeper layers
after every layer-zero column does not change cross-column compositing order.
Within one column, the existing front-to-back aperture rules are unchanged.

## ABI and storage

- `PortalTransformPlan` (8 bytes): `tangent_base[3]`, `normal[3]`, packed
  rotation/mirror flags, and the tangent-axis selector.
- `LayerRay` (80 bytes): exact DDA state (55), hit (14), distance bias (3),
  visibility/draw clips, visited masks, layer count, and continuation flag.
- `FirstPortalRun` (11 bytes): first column, one-past-last column, portal ID,
  and the shared plan.

Maximum dedicated storage is 7,288 bytes. LTO removes 16 bytes of obsolete
single-column scratch, so measured net BSS growth is 7,272 bytes.

## Measured build cost

Isolated `-Oz` release builds from the same copied sources:

| Variant | 8xp bytes | BSS bytes | Linker heap remaining |
| --- | ---: | ---: | ---: |
| Front-to-back gate off | 17,691 | 45,308 | 15,382 |
| Layer-major gate on | 18,809 | 52,580 | 8,110 |

The feature therefore adds 1,118 program bytes and 7,272 net BSS bytes. The
compiler reports the same 80-byte `game_render` stack frame for both builds.
The predecoded assembly kernel itself is 274 bytes.

## Exactness status

All C/assembly layout assertions pass. `verify_plan.py` independently checks
the plan against the original geometric transform for all 16 entry/exit
direction pairs, 256 tangents, representative edge/interior exit cells, and
representative signed ray components: 65,536 origins and 784 rotations pass.

A framebuffer-hash comparison is still required before integration. That is
the only material exactness blocker: the experiment intentionally does not run
CEmu, and compile/arithmetic checks cannot prove the complete compositor.

## Expected performance

This prototype is a scheduling/ABI proof, not a credible 30 FPS solution by
itself. On a 17-column first-portal run it replaces 17 direction-pair lookups
and exit-direction switches with one decode. It does **not** reduce the 80
independent layer-zero DDAs, wall rasterization, or background cost. It also
adds 4,400 bytes of mandatory state writes per frame and restores 55 bytes per
continuing portal column. Those RAM operations may outweigh the small transform
win on CE memory.

The useful next step, if hash-equivalent timing does not regress, is to move
the run descriptor ahead of continuation tracing: predecode all 12 portal IDs
once per frame and let the DDA resolver return a descriptor pointer. A real
multi-millisecond gain then requires packet/beam traversal for coherent ray
runs or a projected wall-face/span renderer; merely changing traversal order
cannot close the current roughly 24 ms gap to 30 FPS.
