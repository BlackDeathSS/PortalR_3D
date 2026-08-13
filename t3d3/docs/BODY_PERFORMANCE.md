# Movable-body performance report

Build `0x26081304` targets geometry before rasterization. Complete cube AABBs
are rejected against a conservative camera-space frustum before any corners,
projected vertices, clipped faces, or scanlines are produced. Unclipped
full-detail cube faces use a fixed four-point setup, and the 20x15 far-portal
state uses direct floor/ceiling depth bands plus its dominant forward wall.
The half- and full-resolution portal states retain all room faces, and the
eight-unit full-detail cube LOD distance is unchanged.

| Layout | `0x26081303` average | `0x26081304` average | Old 1% low | New 1% low |
|---|---:|---:|---:|---:|
| No bodies | 36.60 FPS | 37.20 FPS | 19.52 FPS | 19.75 FPS |
| Four root cubes | 30.53 FPS | 32.35 FPS | 16.03 FPS | 16.94 FPS |
| Four portal cubes | 27.51 FPS | 28.51 FPS | 16.92 FPS | 17.17 FPS |

Root-four improves 5.98% in average FPS and 5.66% at the 1% low. All 854
per-frame simulation hashes, the route fingerprint, and four crossing frames
remain exact. One far-quarter-portal section intentionally has a new logical
and presented hash because of the 20x15 principal-plane budget; every other
section remains pixel-exact. Final captures are in
`benchmark-results/resolution-26081304/80x60`.

Build `0x26081303` specializes full-resolution root scan conversion and caches
portal aperture/destination row cursors. Root-four improves from 29.67 to 30.53
FPS average and from 15.57 to 16.03 FPS at the 1% low. Portal-four improves
from 26.81 to 27.51 FPS average and from 16.72 to 16.92 FPS at the 1% low.
All route state, logical-frame, and presented-frame hashes remain exact; the
eight-unit full-detail cube range is unchanged. The no-body route improves
from 35.51 to 36.60 FPS average and from 19.28 to 19.52 FPS at the 1% low.
Final captures are in `benchmark-results/resolution-26081303/80x60`.

## Noclip whole-room rejection

Build `0x26081302` adds a hierarchical 16-to-8-pixel dirty presenter, direct
solid half-run fills, exterior noclip face selection, and aperture-row-limited
portal setup/shading. The supplied-ROM 80x60 route measures 35.51 FPS average /
19.28 FPS 1% low with no cubes, 29.67 / 15.57 with root-four, and 26.81 / 16.72
with portal-four. Portal-four improves from 26.41 / 16.21; root-four improves
slightly in average while its tail remains effectively unchanged.
The outside-room fixture measures 148.3 FPS looking away, 148.0 FPS with the
room fully beyond the frustum, and 89.1 FPS with an exterior face visible.
Final decoded captures are stored under
`benchmark-results/resolution-26081302/80x60`.

Build `0x26081301` adds a noclip-only whole-room camera-space AABB rejection
before corner projection, horizon-row setup, face scanning, portal setup, and
body rendering. The test frustum is enlarged by eight base-resolution pixels
on every side; borderline rooms use the unchanged exact renderer. The
repeatable supplied-ROM CEmu route measures 128.0 FPS looking away versus
88.3 FPS without the guard, and 140.0 versus 99.6 FPS while turning with the
room still outside the framebuffer. A partially visible distant room is
effectively unchanged at 78.2 versus 79.1 FPS.

The normal deterministic route bypasses the noclip guard and remains exact:
34.75 FPS average, 19.33 FPS 1% low, route fingerprint `0x90ABD6C8`, four
crossings, and matching state/logical/presented hashes. The permanent sentinel
capture is `tests/cemu/noclip_performance_autotest.json`.

## Four-body / eight-unit LOD checkpoint

Build `0x26081202` caps the gameplay pool at four boxes and removes the former
five-or-more density branch. Every supported box keeps full projected faces
through eight world units. The deterministic 80x60 supplied-ROM CEmu results
are 29.14 FPS average / 15.81 FPS 1% low for four root-room boxes and 26.41 FPS
average / 16.21 FPS 1% low for four portal-destination boxes. Both routes keep
the `0x90ABD6C8` fingerprint and four portal crossings. Artifacts are under
`benchmark-results/resolution-26081202/80x60`.

## Historical eight-body frame-consistency pass

Build `0x26081201` includes the sparse-view eight-unit cube LOD range. The
underlying performance pass remains pixel- and simulation-exact to the accepted
`0x26081128` 80x60 renderer. It replaces the exhaustive camera-angle recovery
performed after a player portal crossing with a bounded lookup. Pitch uses a
monotonic lower-bound search; yaw examines only the applicable sine-table
quadrant plus the two cardinal plateau samples needed to preserve the original
earliest-angle tie rule. The optimized result was exhaustively compared for
all 256 yaw values, all 129 pitch values, and both portal directions.

The pass also clears reduced portal scratch rows with one contiguous operation,
removes redundant pointer-copy stack traffic from unchanged dirty-presenter
groups, and unrolls the full 80x60 presenter used on cache cold starts. It does
not change portal LOD thresholds, cube LOD, aperture coverage, resolution, or
simulation cadence.

The current micro-pass also caches the shared equal-size cube's camera-space
projected extent once per camera, removing repeated absolute-value sums from
every body bound test. The final root-eight capture is 39.012 ms / 25.63 FPS
average with a 13.63 FPS 1% low; state, logical-frame, and presented-frame
hashes remain exact. This is a small geometry saving, not a solution to the
remaining raster/composite tail.

| Layout | `0x26081128` average | `0x26081144` average | Old 1% low | New 1% low |
|---|---:|---:|---:|---:|
| No bodies | 34.249 FPS | 34.752 FPS | 17.709 FPS | 19.331 FPS |
| Eight cubes in root room | 25.320 FPS | 25.602 FPS | 13.157 FPS | 13.617 FPS |
| Eight cubes in portal destination | 25.860 FPS | 26.143 FPS | 15.167 FPS | 16.665 FPS |

Mean frame time is 28.775 ms with no bodies, 39.060 ms with eight cubes in the
root room, and 38.252 ms with eight cubes in the portal destination. The four
portal-heavy crossing frames changed as follows:

| Route frame | Old | New | Saved |
|---:|---:|---:|---:|
| 318 | 64.789 ms | 42.328 ms | 22.461 ms |
| 324 | 73.181 ms | 50.751 ms | 22.430 ms |
| 432 | 72.845 ms | 51.514 ms | 21.332 ms |
| 764 | 77.972 ms | 55.908 ms | 22.064 ms |

All 854 per-frame state hashes and every logical, presented, and state section
hash match `0x26081128` in all three layouts. All 21 interaction fixtures pass.
New wall-clock CRC variants were admitted only after checking the captured
views and decoded player/body state; they reflect the faster render cadence,
not changed physics rules.

Two alternatives were measured and rejected. Always using the full unrolled
presenter fell to 22.86 FPS average and 15.35 FPS 1% low in the portal-eight
route because unconditional physical writes dominate. A reduced-portal body
assembly prototype improved average time slightly but changed 19 logical
frames by narrowing adjacent silhouettes one reduced sample; it was removed.

The remaining tail is sustained view-dependent cube/portal raster work, not
the former crossing search. Root-eight remains the worst 1% case at 13.62 FPS;
portal-eight is now 16.66 FPS. These are supplied-ROM CEmu measurements, not
physical-calculator certification. Decoded captures and hardware packages are
under `benchmark-results/resolution-26081144/80x60`.

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
