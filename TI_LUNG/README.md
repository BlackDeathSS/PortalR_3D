# TI_LUNG

TI_LUNG is a standalone TI-84 Plus CE submarine-horror game built on an
extended version of the T3D3 fixed-point renderer. It is an original
calculator-scale interpretation of the navigation-and-photography structure
of *Iron Lung*; it uses newly written code and procedural visuals rather than
ripped game assets.

## Current game

- A full-screen 2D submarine helm with heading dial, precise coordinate
  displays, four proximity returns, O2 and depth meters.
- Q12 fixed-point navigation (1/4096 coordinate precision), avoiding the
  calculator's expensive software floating point while making movement finer.
- A 950 x 950 navigation chart with a movable coordinate cursor. It displays
  the closest survey object's X/Y and required heading, plus an angle marker.
- Solid cave collision: contacting a wall ends the run.
- New Game / Continue with an autosaved AppVar state.
- A white-flash-to-grain one-shot developed photo. The camera creates an
  untextured, low-poly T3D3 exterior image once at a 30-unit render distance,
  then leaves that framebuffer on screen until `2nd` returns to the helm.
- `Trace` opens a noclip T3D3 exterior inspection view for debugging. It
  streams a broad sixteen-cell radius of map-aligned cave chunks around freecam;
  the exterior container itself is invisible.
- Scripted proximity returns, impacts, navigation displacement, fire,
  pressure loss, a late camera encounter, and an ending sequence.

## Controls

On the title screen:

- `2nd`: begin a new run
- `Graph`: continue an autosave, when one exists
- `Clear`: abort

At the helm:

- Arrow up/down: move the submarine forward/backward
- Arrow left/right: rotate the submarine
- `2nd`: take an external photo
- `Graph`: open or close the map
- `Mode`: open or close the briefing
- `Trace`: toggle the 3D noclip debug view
- `Clear`: exit

On the map:

- Arrow keys: move the coordinate cursor in five-unit steps
- `2nd`: set the cursor as the helm waypoint
- `Graph` or `Mode`: return to the helm

In the debug view, arrow keys fly, `2nd` rises, `Mode` descends, `Prgm`
cycles to the next point of interest at its exact coordinates and required
heading, and `Trace` returns to the 2D helm.

## Renderer changes

TI_LUNG still uses T3D3's fixed-point camera transform, near clipping,
face-light palette, depth ordering, polygon rasterizer, dirty presenter, room
collision, and 4x low-resolution presentation. The reusable engine additions
are opt-in compile-time features:

- `T3D3_STATIC_BOX_LIMIT`: independent-extents static world boxes, exact
  camera-space bounds, conservative frustum rejection, visible-face
  submission, and far-to-near ordering.
- `T3D3_MATERIAL_TEXTURE`: a sparse palette-shade material pass designed for
  calculator cost rather than a full-screen texture scan.

The public static-scene API is `engine_static_scene_reset()` plus
`engine_spawn_static_box()`. Normal PortalR/T3D3 builds leave both features at
zero and retain their prior memory layout.

[Virtual3D](https://github.com/TheMachine02/Virtual3D) was evaluated as a
reference because it supports texture mapping, clipping, double buffering,
depth sorting, and mipmapping. Its 320 x 240 double-buffer architecture and
documented unfinished lighting/clipping work made a wholesale integration a
poor fit for this game's RAM and stability goals, so no Virtual3D code or
assets are copied here. Virtual3D is published under its repository's
[MIT/BSD-style license terms](https://github.com/TheMachine02/Virtual3D/blob/main/LICENSE).

## Build and tests

Build with CEdev 15 or newer:

```text
make -B
make budget
```

Transfer `bin/TILUNG.8xp` and the CE C libraries to the calculator. The current
T3D3 package is 39,748 bytes; its memory audit budgets code, data, BSS, and a
4 KiB stack at 103,640 / 153,600 bytes, leaving 49,960 bytes. The alternate
raycaster package is 17,886 bytes and budgets 37,358 bytes, leaving 116,242.

The deterministic tests in `tests/cemu` cover:

- `front_cabin_autotest.json`: presses `2nd` and verifies the helm state.
- `photo_still_autotest.json`: verifies the one-shot 3D photo buffers.
- `low_ram_launch_autotest.json`: keeps a 35 KiB RAM AppVar resident, then
  verifies that the game still launches.
- `ray_trace_autotest.json`: verifies the portal-free raycaster and exact POI
  teleport view using the same heading axes as navigation and proximity.
- `skeletal_creature_autotest.json`: activates a moving skeletal return in
  Trace and verifies that the camera develops its detailed bone silhouette.
- `scripted_skeleton_autotest.json`: records the first two exact POIs and
  verifies that the first story-driven skeletal encounter actually starts.

Scripted skeletal encounters begin after 2, 5, and 8 marked photographs. The
first is a close predatory fish, the second a long eel, and the third a large
jawed organism. They continue moving while the submarine is idle, can produce
real four-quadrant proximity returns, and only appear in a photograph while
inside the camera's forward field of view. In Trace debug, press `STAT` to
cycle fish, eel, giant maw, and off without changing the saved story flags.
