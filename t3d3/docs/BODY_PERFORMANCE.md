# Eight-body performance report

## Current 80x60 assembly scan pass

Build `0x26081128` follows the exact `0x26081117` geometry baseline. It moves
the complete full- and reduced-resolution scan/fill intervals and reduced
portal compositor into assembly, then removes redundant sleeping-body pair
solves without changing coverage, LOD thresholds, portal math, or simulation.

| Layout | `0x26081117` | `0x26081128` | Gain | Current 1% low |
|---|---:|---:|---:|---:|
| No bodies | 31.997 FPS | 34.249 FPS | 7.04% | 17.709 FPS |
| Eight cubes in root room | 22.534 FPS | 25.320 FPS | 12.36% | 13.157 FPS |
| Eight cubes in portal destination | 22.630 FPS | 25.860 FPS | 14.27% | 15.167 FPS |

The portal-eight mean falls from 44.188 to 38.670 ms. Its average render phase
falls from 39.103 to 36.001 ms and update falls from 5.072 to 2.656 ms. Across
the ten detailed frames, portal-geometry sum falls from 165.222 to 138.367 ms,
root fill from 66.010 to 55.725 ms, and portal fill from 18.372 to 16.144 ms.
All 854 per-frame state hashes and all logical, presented, and state section
hashes match `0x26081117` in all three layouts. The 21 standing, pushing,
throwing, portal-transfer, and noclip checks also pass; their fixed wall-clock
fixtures include semantically checked faster-cadence CRC variants.

The full kernel walks both active convex edges and fills an entire edge segment
per call. A companion kernel handles half/quarter portal destinations, clamps
unreachable destination spans before downsampling, and the assembly compositor
expands only the exact aperture rows. A separate flat-cube kernel handles the
dense eight-body silhouette path. Hardware benchmark packages and decoded
captures are retained under `benchmark-results/resolution-26081128/80x60`.

The heavy layouts now exceed 25 FPS on average in CEmu, satisfying the requested
greater-than-10% improvement gate. Their 1% lows remain 13.157 and 15.167 FPS,
so this is not yet a 25 FPS tail guarantee or real-calculator certification.

Build `0x26081104` targets the room, portal-composition, presentation, and
movable-cube costs reported when all eight cubes are visible directly or
through a portal. The measurements use the supplied
TI-84 Plus CE ROM in CEmu and the inherited deterministic 854-frame route.
Sixteen frames are warm-up; ten detailed phase frames are excluded from the
clean aggregate because counter switching deliberately perturbs them.

## Results

| Layout | Build | Average | Median | 1% low | Mean frame |
|---|---:|---:|---:|---:|---:|
| Eight cubes in root room | `0x26081102` | 13.818 FPS | 15.608 FPS | 7.263 FPS | 72.367 ms |
| Eight cubes in root room | `0x26081103` | 18.989 FPS | 19.236 FPS | 11.625 FPS | 52.663 ms |
| Eight cubes in root room | `0x26081104` | 25.023 FPS | 24.555 FPS | 13.091 FPS | 39.964 ms |
| Eight cubes in portal destination | `0x26081102` | 10.325 FPS | 8.505 FPS | 6.983 FPS | 96.853 ms |
| Eight cubes in portal destination | `0x26081103` | 18.650 FPS | 17.896 FPS | 13.032 FPS | 53.619 ms |
| Eight cubes in portal destination | `0x26081104` | 25.352 FPS | 24.909 FPS | 14.979 FPS | 39.444 ms |

Relative to build `0x26081103`, average FPS increased another 31.8% in the root
layout and 35.9% in the portal-destination layout. Relative to the original
`0x26081102` measurements, the total gains are 81.1% and 145.5%. Mean frame
time is now 39.964 ms and 39.444 ms. The ordinary no-body route improved from
25.860 FPS / 38.670 ms to 36.926 FPS / 27.081 ms. Its 1% low improved from
15.399 to 18.818 FPS.

Every one of the ten route sections retains the `0x26081103` logical-frame,
presented-frame, and simulation-state hashes in both eight-body layouts. The
no-body route also retains the established final route state `0x2567643B`,
logical framebuffer `0x13BBC90D`, presented framebuffer `0x708E17EF`, route
fingerprint `0x90ABD6C8`, and four portal crossings.

The raw and decoded artifacts are retained under
`benchmark-results/body-performance` and
`benchmark-results/geometry-present-26081104`. The former contains the
`0x26081102` and `0x26081103` baselines; the latter contains the final no-body,
root-eight-body, and portal-eight-body CSV, JSON, and raw captures.

## Changes responsible

- Transform a body center once per camera and reuse it for sorting and drawing.
- Batch the three world camera axes, then apply the body's portal-derived
  signed-axis orientation without general fixed-point vector multiplies.
- Construct all eight camera-space corners by additions from the center and
  axes.
- Project each corner once and share it between all visible faces.
- Reject a fully off-screen cube before per-face clipping and raster setup.
- Use a two-projection shaded silhouette for cubes at least three room units
  away and for all reduced portal layers. Every row is still intersected with
  the exact portal aperture.
- Retain full projected faces for nearby root-view cubes and preserve the
  zero-body early-out.
- Reuse camera-space axes for equal-sized cubes in the same camera instead of
  transforming the room axes once per body.
- Derive flat-LOD screen bounds directly from the camera-space center and
  absolute axis extents, then project the same-depth bounds with one assembly
  setup.
- Set up only the three cube faces that can face a camera, rather than testing
  all six faces.
- Rasterize and fill root room faces immediately, removing a second full span
  buffer traversal before portal composition.
- Use byte scanline bounds, precomputed row-light subtraction, and direct byte
  extraction after range checks in the raster hot path.
- Cache the logical frame separately for both physical draw buffers and expand
  only dirty eight-pixel groups to the 320x240 display. At 64x48 the physical
  scale is 5x, not 4x; the development HUD invalidates only the blocks it
  touches.

## Remaining limit

Both deterministic eight-body layouts now exceed 25 FPS on average in CEmu,
but neither is a reliable 25 FPS result yet. Their 1% lows are 13.091 and
14.979 FPS, and 495/616 of 844 clean frames exceed 33.333 ms. The slow tail is
now concentrated in view-dependent portal geometry plus the roughly 5 ms
update cost of eight active bodies. The next pass should target those spikes
and avoid adding texture cost until frame-time consistency improves.

The emulator figures should not be presented as hardware certification. For a
view similar to the reported screenshots, CEmu now demonstrates about 25 FPS
average in the certified layouts, but the exact result depends on camera
coverage, portal LOD, and calculator timing and must be measured on the physical
device.
