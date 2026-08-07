# TRUE3D06 adaptive portal renderer

This CEdev project replaces the earlier 2.5D sector assumptions with real XYZ
geometry. Rooms are axis-aligned convex boxes with six independently colored
faces. Portals can be placed on any wall, floor, or ceiling that is large enough.

The portal camera, player position, complete view basis, and velocity all use the
same general 3D rigid transform. Yaw and pitch are stored explicitly, and the
camera basis is reconstructed from lookup tables instead of accumulating
rotation error. Portal crossings transform the view and then rebuild a level,
orthogonal player camera. Missing or invalid external levels fall back to the
built-in two-room test chamber.

Controls:

- Arrow up/down: move forward/backward
- Arrow left/right: turn
- `F1` (`Y=`): look up
- `F2` (`Window`): look down
- `F3` (`Zoom`): toggle 64 by 48 / 32 by 24 rendering
- `2nd`: jump; rise in developer mode
- `Alpha`: place the orange portal
- `Mode`: place the blue portal
- `Graph`: toggle developer fly mode and gravity
- `Del`: descend in developer mode
- `Clear`: exit

Vertical look has hard stops at straight up and straight down, so the camera
cannot wrap or roll over. The always-on HUD shows a lightly smoothed FPS value
with one decimal place and displays `FREECAM` while developer fly mode is
active. Developer mode keeps room collision but disables gravity and allows
free vertical movement.

## Map editor

Open `editor/index.html` on the PC. The dependency-free editor can add up to
eight rooms, edit their XYZ bounds and face colors, set the spawn, and configure
the two initial portals. Its isometric preview and face selectors cover all six
orientations.

Export `T3DLVL1.8xv`, then transfer that AppVar alongside `TRUE3D06.8xp`. The
game loads the archived AppVar directly without copying it into working RAM.
JSON and raw `.t3d` import/export are also available.

## Performance and memory

The main renderer toggles between a 64 by 48 framebuffer with a fixed 5x
assembly presenter and a true 32 by 24 performance mode with a fixed 10x
presenter. Portal recursion is capped at one child view. Symmetric high-precision
near-plane intersections and accurate tall-edge slopes prevent adjacent walls
from separating while turning or standing near a face.

Projected convex polygons use a two-chain scan converter and cache their
bounded scanline spans once. The visibility pass forwards each polygon's top
vertex and vertical bounds, avoiding a second vertex scan. Portal
apertures use exact per-row intervals, reducing clip construction from as many
as 3,072 pixel tests to at most 48 row intersections. Host walls leave portal
coverage unfilled instead of drawing pixels that the child view immediately
overwrites, while faces outside a portal's bounding region are rejected before
rasterization.

In 64 by 48 mode, portal views adapt through 64 by 48, 32 by 24, and 16 by 12.
In 32 by 24 mode they adapt through 32 by 24, 16 by 12, and 8 by 6. Every child
view is composited through its original aperture, and hysteresis prevents detail
from flickering near a size threshold. Four derived palette shades provide
stable wall-direction lighting plus inexpensive floor and ceiling depth bands.
Those bands are emitted as constant-color row ranges instead of recomputing
distance and shade for every span. Span filling remains a fast single-color
`memset`, and the 64 by 48 presenter is fully unrolled while preserving the
same exact 5 by 5 pixel expansion.

Build from this directory with `make` and run `make budget` for the conservative
150 KiB working-RAM check.

For repeatable performance work, `make LIVE_BENCHMARK=1` builds an 854-frame
rendered gameplay route that exports `T3DLIVE.8xv` with its build ID, frame
timings, render phases, portal crossings, and exact output hashes. Optional
deep raster/fill counters are enabled with `LIVE_BENCHMARK_COUNTERS=1`.
See [BENCHMARK.md](BENCHMARK.md) for calculator/CEmu capture, decoding, CSV
export, and exact A/B comparison commands.

The default build uses the calculator-safe speed-oriented `-Os` setting. The
more aggressive `-O1` through `-O3` settings are intentionally not used because
this CE toolchain miscompiles the current renderer at those levels. Run
`make budget` after changes for the exact resident image, BSS, stack reserve,
and remaining-RAM report.
