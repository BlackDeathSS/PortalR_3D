# T3D3 architecture

T3D3 is a compatibility-first fork of True3D06. The existing engine is the
behavioral specification for camera projection, player collision, controls,
portal placement, portal traversal, wall apertures, and deterministic output.
Those systems are not replaced together. Each new subsystem must pass the
unchanged True3D route before it can become the default.

## Runtime layers

1. `level` validates a T3D3 level and can fall back to a legacy `T3DLVL1` map.
2. `engine` owns the fixed-step player, rooms, portal transforms, visibility,
   raster orchestration, presentation, and benchmark counters.
3. `render kernel` remains the existing constant-color convex span path during
   the compatibility phase. The textured kernel will be selected per material,
   so untextured portal hosts retain the established fast path.
4. `bodies` owns a fixed pool of translation-only movable objects and uses the
   same room planes and portal transform functions as the player.
5. Offline tools will add texture/material records without making runtime OBJ
   parsing or unrestricted triangle submission part of the engine.

## Non-negotiable compatibility tests

- Root projection and perspective match True3D framebuffer hashes.
- Collision produces the same position, velocity, grounded state, and room.
- Both portal cameras transform position and the complete orthogonal basis.
- Portal placement remains ray/plane based and clamps to the physical host.
- A portal aperture is a hole in its host polygon, never a camera-facing sprite.
- `Clear` exits through the normal CEdev graphics/keypad shutdown path.

## Staged redesign

### Stage 0: frozen True3D baseline

T3D3 has an independent program name, level AppVar, build ID, memory map, and
benchmark result. Legacy T3D1 levels remain usable.

### Stage 1: renderer interface and measurements

Split projection, span generation, material fill, portal composition, and
presentation into explicit internal interfaces without changing output. Add
separate counters for edge setup, visible rows, pixels, portal transforms, and
dynamic objects.

### Stage 2: hybrid texture spans

Add an assembly affine texture-span kernel at 64x48 first. Keep solid spans for
flat or distant surfaces. Use offline-subdivided wall/floor quads, an 8-bit
atlas, static shade banks, and per-surface mip choice. Do not add a depth buffer
to the convex-room fast path; use cell order and exact portal clips.

### Stage 3: movable bodies

Add four sphere/box bodies with fixed 60 Hz integration, gravity, sleeping,
room-plane collision, pickup/hold/throw, and portal crossing. Position, linear
velocity, and box basis use the same rigid portal transform as the player.
Angular velocity, torque, and general stable stacking remain out of scope.

Checkpoint `0x26081111` implemented the initial eight-body runtime; the current
engine caps the gameplay pool at four. The interaction,
rendering, room collision, sleep, pair response, portal transfer, and
player/body contact. The contact layer supports standing, underside blocking,
horizontal pushes, pinned-body blocking, wake-up, and portal-aware pushed-body
movement. Body portal fit uses the physical aperture minus the body extent plus
a 1/32-unit fixed-point tolerance, allowing a floor-resting cube to traverse a
portal whose lower edge is exactly flush with the floor.

Dynamic bodies are collected and center-transformed once per camera, sorted
far-to-near, and culled against the near plane. A full-detail cube is assembled
from one center and three batched camera-space axes; only vertices referenced
by camera-facing faces are projected, and those projections are reused across
the faces. Equal-depth pairs share a projection scale and assembly call. A
whole-cube screen-bounds test avoids face setup when possible, and sequential
faces reuse layer scratch rather than allocating a span record on the stack.
Every supported cube retains the exact face path through eight room units.
More distant cubes and all reduced portal-layer cubes use
a two-projection shaded silhouette LOD clipped against the layer's exact row
aperture. This avoids paying six polygon setups per small cube while preventing
portal leakage. Equal-size cubes share camera axes, flat LOD bounds are derived
from center and absolute axis extents, same-depth bounds share one assembly
projection setup, and full cubes submit only the three potentially visible
faces.

The 64x48 presentation path keeps a logical-frame cache for each physical
GraphX draw buffer. It compares eight-pixel groups and expands only changed
groups into 40x5 physical blocks. Root room faces are rasterized and filled
immediately; the portal pass then overwrites the exact host aperture. Raster
rows use byte bounds, precomputed horizon shade subtraction, and range-checked
byte column extraction to avoid signed 24-bit shift helpers in the scanline
loop. The 32x24 mode retains the full presenter.

Compile-time 80x60 and 160x120 modes scale the established 64x48 projection
output while retaining the same field of view and coverage rules. The 80x60
mode is the development default. It keeps a logical-frame cache for each
physical draw buffer and uses an exact sixteen-pixel-group dirty 4x presenter.
Its overlay rectangles are
invalidated in logical coordinates before GraphX draws the FPS display,
developer HUD, and crosshair. The 160x120 mode keeps the full unrolled 2x
presenter: scanning the physical buffer for changes was measurably slower, and
two logical caches do not fit cleanly in the standard runtime. Presenter
sections are independently collectable, so neither high-resolution path adds
code or cache cost to the 64x48 reference binary. A 320x240 logical mode is
excluded by the standard-runtime memory budget; it requires full-RAM takeover
or a tiled, in-place portal design.

Portal child layers choose full, half, or quarter resolution from their exact
projected aperture area with hysteresis. Width and height gates scale with the
active logical resolution. Reduced layers clear only the scratch rectangle
that the aperture can sample before rendering and compositing it. Build
`0x26081128` moves full and reduced two-chain scan intervals and reduced portal
composition to assembly. Reduced spans are clamped to the portal bounds before
downsampling, so scratch pixels outside the compositable destination are not
written.

Developer freecam normally retains room and player/body collision. Pressing
`Trace` (F4) toggles a separate noclip flag while freecam is active. Noclip
skips player portal crossing, room clamping, and player/body resolution while
leaving world-body simulation unchanged. Disabling freecam clears noclip and
clamps the camera into its current room on the same update.

Level-file body records and real-calculator four-body certification remain to
be completed. The emulator route and before/after results are documented in
[BODY_PERFORMANCE.md](BODY_PERFORMANCE.md).

### Stage 4: higher-detail cells

Extend rooms with offline-compiled detail meshlets and gateways. The six room
planes remain authoritative for player/portal behavior. Detail geometry is
culled by current cell and projected size and rendered after the room shell.

### Stage 5: assembly hot paths

Replace only measured bottlenecks: textured span stepping, portal compositing,
edge setup, and transformed-vertex batches. Every replacement is A/B checked
against a host reference and the deterministic calculator route.

## Performance contract

T3D3 retains 64x48 as the performance reference, while 80x60 is now the
development default chosen for visual detail. Quality changes remain explicit
modes, not silent fallbacks. Build `0x26081128` reaches 25.32-25.86 FPS average
in the historical deterministic 80x60 eight-body CEmu layouts. The current
four-body layouts reach 29.14 FPS root / 26.41 FPS through-portal averages,
with 15.81 / 16.21 FPS 1% lows. They clear the average gate but
does not yet meet the 25 FPS tail contract and is not real-hardware certified.
Further work must target portal spikes and presentation before texture cost is
added.
