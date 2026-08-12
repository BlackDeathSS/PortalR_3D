# Supplied-ROM CEmu performance and behavior report

Recorded 2026-08-10 with `cemu-autotester.exe` and the user-supplied 4 MiB ROM.
The ROM is not included in the repository; its SHA-256 is
`808F588DB9CAE429B4D3C276490873B70774AFD57E16DD6CE2E6CE8A58A000D6`.
These are deterministic emulator measurements, not real-calculator
certification.

## Implemented behavior

- The example scene now uses a quantized `portal_lab` atlas: broad shaded wall
  panels, directional floor slabs, a light ceiling, and divider panels. It does
  not use the old checker fallback.
- Projection remains at focal length 53 for the 80x60 root, matching the
  intended True3D field of view after scaling.
- `Mode` and `Alpha` place independent portals on compiled wall surfaces;
  additional north/south/side hosts let the test use perpendicular walls.
- Portal corners come from stored world-space right/up/normal bases. Their
  apertures stay on the wall, foreshorten, and near-clip rather than behaving
  as camera-facing sprites.
- Linked portals transform camera position and basis, render the destination at
  40x30, render a visible nested portal at 20x15, and stop at depth two.
- Depth-two optional geometry is capped at 32 submitted triangles before later
  meshlets are transformed. The current child-host hole is conservative: all
  coplanar destination-host triangles are omitted rather than polygon-clipped.
- Input remains continuously latched across slow frames. `Del` cancels both
  portals and `Clear` returns normally through `gfx_End`.

Visual regressions for build `0x26081005` cover the root frame
(`0xE1ABFBEB`), palette (`0x6A4C0DE9`), angled unlinked portal
(`0xF50B1257`), and recursive linked frame (`0xB38C0C48`).

## Unlinked 120-frame route

The route holds Up for six seconds, collides at `y=3.75`, and remains inside
cell zero. The final frame submits 15 triangles and counts 4,800 logical
texture/depth samples.

| Metric | CEmu result | Contract | Pass |
| --- | ---: | ---: | :---: |
| Wall FPS | 8.989 | >=30 average | No |
| Render-capacity average | 9.303 FPS | >=30 FPS | No |
| Render-capacity median | 9.397 FPS | diagnostic | - |
| Render-capacity 1% low | 8.097 FPS | >=25 FPS | No |
| Mean frame | 107.487 ms | <=33.33 ms | No |
| 99th percentile | 123.474 ms | <=40 ms | No |
| Raster/portals per frame | 93.684 ms | diagnostic | - |
| Present per frame | 13.772 ms | diagnostic | - |
| Update per frame | 3.423 ms | <=2 ms | No |

Renderer sub-phases average 4.711 ms for visibility/clear, 9.191 ms for
transform, and 79.614 ms for triangle setup/spans. The decoded artifact is
`benchmark-results/cemu-2026-08-10/runtime-build-26081005.json`.

## Continuously visible recursive portal

This route places the pair on perpendicular entry-cell walls, turns back to
keep the linked aperture visible, and runs until the 15-second autotest limit.
It exercises all three layers and reports `[11, 44, 32]` submitted triangles,
`[4800, 1129, 112]` samples, and nine deterministic depth-two meshlet drops.

| Metric | CEmu result | Contract | Pass |
| --- | ---: | ---: | :---: |
| Wall FPS | 1.777 | >=30 average | No |
| Route capacity average | 1.824 FPS | >=30 FPS | No |
| Linked steady median | 1.241 FPS | diagnostic | - |
| 1% low | 1.231 FPS | >=25 FPS | No |
| Linked median frame | 805.725 ms | <=33.33 ms | No |
| 99th percentile | 812.225 ms | <=40 ms | No |

The route average includes initial unlinked placement frames, so the median is
the more representative continuously linked number. The decoded artifact is
`benchmark-results/cemu-2026-08-10/recursive-runtime-build-26081005.json`.

## Isolated kernel gates

The triangle normalizer and six signed gradient products now execute in eZ80
assembly while preserving the prior raster hash. Scan-edge orchestration and
reciprocal table selection remain C; the opaque texture/depth span is assembly.

| Kernel | Current | Gate | Pass |
| --- | ---: | ---: | :---: |
| Presenter | 13.767 ms | <=12.5 ms | No |
| 4,800-sample raster including setup | 40.100 ms | <=8 ms | No |
| Span-only diagnostic | 25.055 ms | - | - |
| 96-triangle geometry | 117.401 ms | <=4 ms | No |

The raster hash remains `0xBF3EE216`; the presenter/projection hash remains
`0xE6F3C4AA`. The exact report is
`benchmark-results/cemu-2026-08-10/kernel-build-26081005.json`.

## Conclusion

This build fixes the requested visual model: textured depth cues, planar
wall-mounted portals, transformed destination rendering, and depth-two visual
recursion are real rather than black/fake sprites. It is not close to the FPS
contract. The unlinked view is roughly 3.6 times too slow for 30 FPS, and a
large recursive portal is roughly 24 times too slow by steady median capacity.

The next optimization pass must replace the C scan-edge/clip/project path with
a meshlet-batched assembly front end, propagate portal apertures before child
submission, and replace the 25.055 ms global-state span loop with copied
material kernels. Resolution, recursion depth, and the performance contract
must not be silently reduced.
