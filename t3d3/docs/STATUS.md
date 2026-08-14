# T3D3 status - build 0x26081309

## Completed foundation

- Forked the complete True3D06 source into an independent `t3d3` tree.
- Independent `T3D3DEV`, `T3D3LIVE`, and `T3D3LVAT` program identities.
- Prefer `T3D3LVL`, then accept legacy `T3DLVL1`, then use the built-in level.
- Preserved True3D projection, controls, room collision, portal placement,
  aperture holes, camera/basis transforms, traversal, and normal exit path.
- Added four translation-only boxes with gravity, room collision, sleeping,
  pair separation/impulse, pickup/drop/throw, projected rendering, and portal
  transfer of position, velocity, and orientation basis.
- Added player/body contact: top support and grounded state, underside head
  blocking, horizontal pushing, wall-pinned blocking, velocity transfer, wake
  behavior, and portal-aware body movement during a push.
- Added a zero-body fast path so unused object support does not scan the pool
  during every physics tick and portal view.
- Added a four-body render benchmark with deterministic root-room and
  portal-destination layouts.
- Batched cube-axis transforms, cached transformed centers and projected
  corners, added whole-cube screen rejection, and replaced repeated signed-axis
  fixed multiplies with signed component selection.
- Cube LOD keeps every supported box on the full projected-face path through
  eight room units. Reduced portal layers retain the aperture-safe shaded
  silhouette path.
- Added a two-buffer dirty presenter for the native 64x48 mode. It compares
  eight-pixel logical groups against the cache for the active GraphX draw
  buffer and performs 5x expansion only for changed groups.
- Changed the root room shell to rasterize and fill each face immediately,
  avoiding the second full span-buffer walk before portal apertures are
  composed.
- Reduced raster setup cost with byte row ranges, precomputed horizon shading,
  and range-checked byte extraction instead of signed 24-bit shifts on every
  scanline.
- Shared equal-size cube camera axes, added analytic flat-LOD bounds and paired
  same-depth projection, and limited full cubes to their three potentially
  visible faces.
- Paired equal-depth room/cube vertices in one assembly projection frame,
  projected only vertices referenced by camera-facing cube faces, reused the
  render-layer polygon scratch instead of allocating a full span buffer for
  every cube face, and clipped flat-cube rectangles to portal bounds before
  entering their row loops.
- Added full 80x60 and half/quarter portal assembly scan loops. Each call walks
  an active two-edge segment, clips it, shades it, and fills it without a
  per-row C/assembly transition.
- Added an exact assembly half/quarter portal compositor and clamped reduced
  destination spans to the only scratch columns the aperture can consume.
- Skip pair solvers when both bodies are sleeping; pushes, pickup, throws,
  gravity, portal transfer, and player contact still wake bodies normally.
- Fixed floor-aligned body traversal so a cube that exactly fits a portal can
  be pushed through from rest instead of requiring a throw to lift it clear of
  an artificial negative aperture margin.
- Added compile-time 80x60 and 160x120 render modes with dedicated 4x and 2x
  assembly presenters, interactive calculator builds, hardware-safe benchmark
  builds, and an automated nine-configuration test matrix.
- Promoted 80x60 to the default `T3D3DEV` mode. Its exact two-buffer dirty 4x
  presenter compares sixteen-pixel logical groups and invalidates HUD/crosshair
  cache regions before overlay drawing. A measured 160x120 physical-buffer comparison was rejected
  because it reduced average FPS by 4.8-6.2%; 160x120 retains its full unrolled
  presenter.
- Normalized portal LOD width/height thresholds for the active logical
  resolution and limited half/quarter scratch clearing to the visible aperture.
  Counter captures cover full, half, and quarter portal states.
- Added developer-only noclip. `Trace`/F4 toggles it while freecam is active;
  it bypasses player room, portal, and object collision and automatically turns
  off when freecam is disabled.
- Replaced the 256-angle/65-pitch exhaustive post-crossing camera recovery with
  an exact quadrant/lower-bound lookup. The cardinal plateau tie rule remains
  identical, while each measured crossing saves 21.3-22.5 ms.
- Consolidated reduced-portal scratch clearing, removed redundant dirty-
  presenter pointer shuffles, and unrolled cache-cold 80x60 presentation.
- Cache the equal-size cube's camera-space projected extent once per camera
  for every root and portal body-bound test.
- Reject a complete off-screen room before corner projection and horizon setup
  while developer noclip is outside the room. An enlarged frustum prevents
  popping, and normal gameplay bypasses the added bounds work.
- Split each 80x60 dirty-presenter group into independently compared 8-pixel
  halves. Changed halves copy 32x4 physical blocks; uniform wall halves seed
  one pixel and expand it with an overlapping `LDIR` constant-color run.
- Cull hidden/opposite convex room faces when developer noclip is outside the
  current room, and limit portal clip/shading setup to aperture rows.
- Added a native 80x60 root scan-conversion kernel that retains a running row
  pointer and removes per-row aperture lookups. The portal-clipped kernel now
  advances cached aperture and destination cursors rather than reconstructing
  all three addresses on every row.
- Restored build 03's shared C cube transform, eight-vertex projector, near
  clipper, and generic convex face setup after the 04-06 shortcuts regressed
  close and oblique cubes.
- Treat the developer-noclip exterior room shell as opaque. Portals, the
  fullscreen portal shortcut, and bodies no longer draw over exterior walls.
- Shade cube faces from their transformed outward world normal. Room faces
  continue using inward normals; portal-transformed cube bases remain lit in
  world orientation.
- Give the top, world-Y walls, and world-X walls distinct bright, medium, and
  dark cube shades. Adjacent projected faces no longer visually merge at close
  or oblique angles.
- Fix the actual direction-dependent cube face loss by initializing every
  reused polygon's `top_vertex` before generic two-chain scan conversion.
- Use a conservative oblique-cube near-plane bound so a whole body cannot be
  rejected while one or more corners still cross the visible near plane.
- Add an honest `dual-portal-four` benchmark with both wall portals and all
  four root-room cubes visible during the complete route.
- Specialize 40x30-to-80x60 portal composition in assembly. When both reduced
  portals map to the exact same destination camera, render the destination
  once and composite it through both exact aperture masks.

## Validation

The new supplied-ROM dual-portal/four-cube stress route measures 16.09 FPS
average, 12.98 FPS 1% low, and 62.15 ms mean frame time. The first honest
baseline measured 14.58 / 12.02 FPS and 68.60 ms. The retained optimizations
therefore improve average FPS by 10.38%, the low by 8.03%, and mean frame time
by 9.40%. All ten simulation, logical-frame, and presented-frame endpoint
hashes match the unshared renderer. Final hashes are logical `0xD5BBF829`,
presented `0xEDE265BA`, and route state `0xA11D4677`.

Five held-cube direction checks and seven near-clipped floor-cube direction
checks pass on the supplied ROM. Their decoded captures show complete convex
faces at every sampled angle. These are the focused regression tests for the
build 09 rendering bug.

The established compatibility route retains deterministic state:

- Route fingerprint: `0x90ABD6C8`
- Exact simulation-state hashes by section
- Portal crossings: 4 at the same frames
- Final logical frame: `0xE0C1779F`
- Final presented frame: `0x82D46383`
- Final route state: `0x2567643B`

Historical supplied-ROM CEmu 80x60 body results for build `0x26081308`:

| Layout | Average | 1% low | Mean frame |
|---|---:|---:|---:|
| No bodies | 36.98 FPS | 19.74 FPS | 27.04 ms |
| Four root cubes | 30.99 FPS | 16.47 FPS | 32.27 ms |
| Four portal cubes | 28.30 FPS | 17.18 FPS | 35.34 ms |

Build 09 keeps build 07's rollback of the 04-06 speculative paths to
restore the last fully correct cube renderer. Relative to archived build 03,
the standard routes remain within normal measurement variance. Resolution, the
eight-unit LOD, portal recursion, clipping, and physics are unchanged.

All 33 focused checks pass on the supplied ROM: twelve cube direction/near-
clip checks, five held/thrown checks, six player-push checks, three standing
support checks, three floor-aligned portal-push checks, and four noclip checks.
New wall-clock variants were accepted only after decoding their images and
player/body records: thrown and pushed bodies reach the intended rooms,
standing leaves the player grounded at the cube-top height, and the exterior
noclip frame contains no portal or body leakage.

Four additional noclip checks confirm that the camera can move beyond the room
boundary with room 0 retained and `noclip=1`, then clamps back to the exact
9.75-unit player boundary after noclip is disabled.

The latest exterior capture shows no portal or body pixels over the room shell.
Its sampled HUD rates are 117.4 FPS looking away, 145.6 FPS at the frustum
edge, and 103.7 FPS with a partial exterior face visible. The values are live
HUD samples rather than the 854-frame certification statistic.

Normal-build memory budget:

- Resident program: 60,866 bytes
- BSS: 45,275 bytes
- Reserved stack: 4,096 bytes
- Total: 110,237 / 153,600 bytes
- Remaining: 43,363 bytes

These are emulator measurements, not real-calculator certification.

The earlier deterministic eight-cube benchmarks improved as follows:

| Layout | Build | Average | 1% low | Mean frame |
|---|---:|---:|---:|---:|
| Root room | `0x26081102` | 13.818 FPS | 7.263 FPS | 72.367 ms |
| Root room | `0x26081103` | 18.989 FPS | 11.625 FPS | 52.663 ms |
| Root room | `0x26081105` | 25.023 FPS | 13.091 FPS | 39.964 ms |
| Portal destination | `0x26081102` | 10.325 FPS | 6.983 FPS | 96.853 ms |
| Portal destination | `0x26081103` | 18.650 FPS | 13.032 FPS | 53.619 ms |
| Portal destination | `0x26081105` | 25.352 FPS | 14.979 FPS | 39.444 ms |
| Root room (80x60) | `0x26081128` | 25.320 FPS | 13.157 FPS | 39.495 ms |
| Portal destination (80x60) | `0x26081128` | 25.860 FPS | 15.167 FPS | 38.670 ms |
| Root room (80x60) | `0x26081144` | 25.602 FPS | 13.617 FPS | 39.060 ms |
| Portal destination (80x60) | `0x26081144` | 26.143 FPS | 16.665 FPS | 38.252 ms |

Build `0x26081202` replaces that experimental eight-body load with the final
four-box cap and removes the density-based 3-unit LOD cutoff:

| Layout | Average | 1% low | Mean frame |
|---|---:|---:|---:|
| Four cubes in root room (80x60) | 29.14 FPS | 15.81 FPS | 34.31 ms |
| Four cubes in portal destination (80x60) | 26.41 FPS | 16.21 FPS | 37.86 ms |

Against the original `0x26081102` eight-body baselines, the historical 64x48
reference gained 81.1% in the root layout and 145.5% in the portal-destination
layout. The current 80x60 development mode clears 25 FPS on average in the
older single-aperture four-box layouts. Build 08 measured 30.99 FPS average /
16.47 FPS 1% low for root-four and 28.30 / 17.18 for portal-four. Those
profiles do not represent two apertures plus four cubes. Build 09's honest
combined stress profile measures 16.09 / 12.98. Resolution and the eight-unit
cube LOD remain unchanged; every portal LOD state uses complete room geometry.
Detailed artifacts and methodology are in
[BODY_PERFORMANCE.md](BODY_PERFORMANCE.md).

Resolution scaling results are documented in
[RESOLUTION_PERFORMANCE.md](RESOLUTION_PERFORMANCE.md). With the accepted
assembly scan/composite and frame-consistency passes, four-cube averages are
now 28.30-30.99 FPS at 80x60. Every retained 80x60 capture has the same route
fingerprint, crossings, and per-frame simulation hashes.

## Next stage

1. Split the unchanged solid-span path behind a material-fill interface.
2. Benchmark an affine assembly texture span without changing projection or
   polygon coverage.
3. Add offline texture subdivision and mip/material records to `T3D3LVL` v2.
4. Add a pixel-exact assembly scan-conversion path for fully projectable root
   cube quads, then target the remaining 4x presentation cost. These are the
   two largest measured parts of the dual-portal tail.
5. Add authored body spawns and repeat the full four-body test on hardware.

Textures, arbitrary detail meshlets, and a new assembly texture rasterizer are
not implemented in this checkpoint.
