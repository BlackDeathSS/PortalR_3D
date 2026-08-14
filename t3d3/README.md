# T3D3

T3D3 is the compatibility-first successor to True3D. It starts from the proven
True3D06 engine rather than the abandoned T3D2 renderer, preserving its correct
perspective, six-plane room collision, wall-aligned portals, player traversal,
controls, adaptive portal views, and deterministic benchmark.

The compatibility route deliberately renders exactly like True3D. It exists so
the texture rasterizer, improved portal kernels, higher-detail geometry, and
movable-body system can be introduced independently and rejected if they break
perspective, collision, portal placement, or performance.

The first T3D3 extension is active: a four-slot translation-only box pool
supports gravity, room collision, sleeping, simple body/body response,
pickup/drop/throw, projected box rendering in root and portal views, and portal
traversal with position, velocity, and all three box basis axes transformed.
The player can stand on cubes, hit them from below, push them across the floor,
and is stopped when a pushed cube is pinned against a room boundary. Player
pushes wake sleeping cubes and can carry a cube through a correctly aligned
portal crossing.

Build `0x26081309` retains the restored `0x26081303` geometry path after the
04-06 cube experiments caused close-face loss, distorted projections, and
hardware lows near 11 FPS. The restored path uses the shared C cube transform,
the proven eight-vertex projector, near clipping, generic convex face setup,
and the established root/portal scan converters. It deliberately removes the
later cube AABB shortcut, fixed-quad setup, 20x15 principal-plane reduction,
assembly corner transform, and direct cube scan-conversion/batching paths.

Build 09 fixes the remaining direction-dependent missing-face regression in
that generic path. Reused polygon scratch could inherit the previous face's
`top_vertex`, causing the two-chain rasterizer to start from the wrong edge.
The common bounds routine now initializes it for every face. A conservative
oblique near-plane bound also prevents rejecting a whole cube while visible
corners remain. Five held-cube angles and seven close near-clipped angles pass
with complete convex silhouettes.

Additional isolated fixes are applied on top of 03. Developer noclip treats the
exterior room shell as opaque, suppressing portal recursion, fullscreen portal
replacement, and interior cubes while the camera is outside. Cube lighting now
uses the transformed outward surface normal rather than the room wall's inward
normal and assigns distinct levels to the three cube axes: bright top, medium
front/back, and dark sides. Lighting remains correct after portal traversal.

The `dual-portal-four` stress profile keeps both wall portals and all four
root-room cubes visible. It confirms the reported 12-13 FPS tail: the first
honest run measured 14.58 FPS average / 12.02 FPS 1% low. A specialized
half-resolution compositor plus exact duplicate-destination sharing improve
that to 16.09 / 12.98 without changing any simulation, logical-frame, or
presented-frame endpoint hash. Non-equivalent portal views retain the original
two-pass renderer.

Developer noclip retains the conservative whole-room AABB rejection from the
03 base, before corner projection and horizon setup. Conservative edge bounds
prevent popping. The historical supplied-ROM route reached about 148 FPS while
the room was fully outside the frustum and 89 FPS with an exterior face
visible. Normal gameplay stays on the original hot path; the current no-body
certification route measures 36.98 FPS.

The native 80x60 root renderer retains build 03's dedicated assembly
scan-conversion kernel and running logical-row address. The clipped portal
kernel retains cached row-left, row-right, and destination cursors. Cube faces
use the generic clipped convex-polygon setup, and every 20x15/40x30/80x60
portal state renders complete room geometry. The eight-unit cube LOD range is
unchanged.

Floor-resting cubes can now be pushed directly through a wall portal. The body
aperture test preserves an exact floor-aligned fit instead of rejecting it with
the old negative clearance margin. A deterministic push-through fixture keeps
the player in the source room while confirming that the cube, velocity, and
basis transfer to the destination room.

Cube LOD uses one rule for the complete four-box pool: projected faces remain
fully detailed through eight world units, with the shaded silhouette path used
beyond that distance. Portal rendering retains
full, half, and quarter resolution states selected from projected aperture
size; thresholds are normalized for 80x60 and reduced buffers clear only their
visible aperture.

The former 64x48 dev binary is preserved as `bin/T3D3R60.8xp`, and 160x120
remains an experimental full-presenter build. A 160x120 dirty presenter was
measured and rejected because its comparison overhead made every scene slower.
See
[docs/RESOLUTION_PERFORMANCE.md](docs/RESOLUTION_PERFORMANCE.md) for results,
memory limits, calculator binaries, and hardware-test instructions.

Pressing `Math` with no selectable object creates a development cube, making the
feature testable before body records are added to the level format.

Build with:

```text
make
make budget
make reference64
```

The calculator program is `T3D3DEV`. T3D3 first looks for `T3D3LVL`; if it is
not present or is invalid, it accepts the legacy `T3DLVL1` AppVar and finally
falls back to the built-in two-room chamber.

T3D3 also supports multiple editor-built levels embedded directly in the
program. Its startup selector lists a valid external AppVar first when one is
present, followed by every embedded level. Use Up/Down and `2nd` to choose, or
`Clear` to exit. The shared [`PortalR 3D Studio`](../editor/README.md) edits the
levels and can build/package T3D3 and Portal3D together.

Controls are initially identical to True3D:

- arrows: walk and turn
- `Y=` / `Window`: look up/down
- `2nd`: jump
- `Alpha` / `Mode`: place orange/blue portal
- `Graph`: toggle developer fly mode
- `Trace` (`F4`): toggle noclip while developer fly mode is active
- `Del`: descend in developer mode
- `Zoom`: toggle 80x60 / 40x30
- `Math`: pick up/drop a cube; creates a development cube if none is targeted
- `Vars`: throw the held cube
- `Clear`: exit

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the staged renderer,
texture, body-physics, and higher-detail design.

Noclip bypasses room, portal-crossing, and player/body collision for the camera
and is automatically disabled when developer fly mode is turned off. This lets
the camera cross the room shell and inspect it from outside without changing
body physics.

Current checkpoint limitations: surfaces still use True3D's shaded solid spans;
the textured assembly span kernel and detail mesh format are the next stage.
Body collision and player contact use translation-only axis-aligned extents;
angular dynamics and stable multi-body stacking remain out of scope. The
80x60 mode is now the development default; its real-hardware tail performance
still needs further work before it can satisfy the 25 FPS 1% low target.
