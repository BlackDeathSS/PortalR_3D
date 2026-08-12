# T3D3 status - build 0x26081128

## Completed foundation

- Forked the complete True3D06 source into an independent `t3d3` tree.
- Independent `T3D3DEV`, `T3D3LIVE`, and `T3D3LVAT` program identities.
- Prefer `T3D3LVL`, then accept legacy `T3DLVL1`, then use the built-in level.
- Preserved True3D projection, controls, room collision, portal placement,
  aperture holes, camera/basis transforms, traversal, and normal exit path.
- Added eight translation-only boxes with gravity, room collision, sleeping,
  pair separation/impulse, pickup/drop/throw, projected rendering, and portal
  transfer of position, velocity, and orientation basis.
- Added player/body contact: top support and grounded state, underside head
  blocking, horizontal pushing, wall-pinned blocking, velocity transfer, wake
  behavior, and portal-aware body movement during a push.
- Added a zero-body fast path so unused object support does not scan the pool
  during every physics tick and portal view.
- Added an eight-body render benchmark with deterministic root-room and
  portal-destination layouts.
- Batched cube-axis transforms, cached transformed centers and projected
  corners, added whole-cube screen rejection, and replaced repeated signed-axis
  fixed multiplies with signed component selection.
- Added density-adaptive cube LOD. Sparse views with up to four render candidates retain
  full projected faces through four room units; crowded views use the measured
  three-unit threshold. Reduced portal layers retain the aperture-safe shaded
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

## Validation

The final 80x60 854-frame route retains the build `0x26081117` section hashes:

- Route fingerprint: `0x90ABD6C8`
- Exact logical-frame, presented-frame, and simulation-state hashes by section
- Portal crossings: 4 at the same frames

Supplied-ROM CEmu 80x60 no-body result:

- Average: 34.249 FPS
- Median: 36.288 FPS
- 1% low: 17.709 FPS
- Mean frame: 29.198 ms
- Improvement over build `0x26081117`: 7.04% average FPS

Seventeen focused body checks pass on the supplied ROM: five held/thrown/portal
render-and-state checks, six push-and-wall-block checks, and three standing
support checks, plus three floor-aligned portal-push checks. The wall trace ends
with the cube exactly at the room boundary,
the player exactly one combined radius away, and both horizontal velocities
zero. Thrown and continuously pushed cubes finish in room 1 with the expected
portal-derived signed-axis basis.

Four additional noclip checks confirm that the camera can move beyond the room
boundary with room 0 retained and `noclip=1`, then clamps back to the exact
9.75-unit player boundary after noclip is disabled.

Normal-build memory budget:

- Resident program: 54,514 bytes
- BSS: 45,019 bytes
- Reserved stack: 4,096 bytes
- Total: 103,629 / 153,600 bytes
- Remaining: 49,971 bytes

These are emulator measurements, not real-calculator certification.

The deterministic eight-cube benchmarks improved as follows:

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

Against the original `0x26081102` eight-body baselines, the historical 64x48
reference gained 81.1% in the root layout and 145.5% in the portal-destination
layout. The current 80x60 development mode now clears 25 FPS on average in
both layouts, but its 13.16-15.17 FPS 1% lows remain below the tail target.
Detailed artifacts and methodology are in
[BODY_PERFORMANCE.md](BODY_PERFORMANCE.md).

Resolution scaling results are documented in
[RESOLUTION_PERFORMANCE.md](RESOLUTION_PERFORMANCE.md). With the accepted
assembly scan/composite pass and sleeping-pair skip, eight-cube averages are
now 25.32-25.86 FPS at 80x60. Every retained 80x60 capture has the same route
fingerprint, crossings, and per-frame logical, presented, and simulation
hashes.

## Next stage

1. Split the unchanged solid-span path behind a material-fill interface.
2. Benchmark an affine assembly texture span without changing projection or
   polygon coverage.
3. Add offline texture subdivision and mip/material records to `T3D3LVL` v2.
4. Target the remaining portal-geometry spikes and update/render interaction
   cost so the eight-body 1% low approaches the 25 FPS contract.
5. Add authored body spawns and repeat the full eight-body test on hardware.

Textures, arbitrary detail meshlets, and a new assembly texture rasterizer are
not implemented in this checkpoint.
