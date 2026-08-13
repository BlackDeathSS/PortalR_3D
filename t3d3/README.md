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

Build `0x26081304` keeps 80x60 as the normal `T3D3DEV` configuration. Convex
room faces, full-resolution flat cubes, reduced portal faces, and reduced
portal composition now use segment-wide assembly loops instead of returning to
C for every row. Reduced destination spans are limited to the portal bounds,
and settled body pairs are skipped until an interaction wakes either body. An
exact bounded camera-angle recovery removes 21-22 ms from each portal-crossing
spike. Equal-size cube projected extents are cached once per camera and reused
for every body bound. A conservative camera-space body AABB test now removes
complete off-screen cubes before corner construction, projection, clipping,
and face rasterization. The repeatable CEmu route runs at 37.20 FPS with no
cubes, 32.35 FPS with four cubes in the root room, and 28.51 FPS with four
cubes in the portal destination. Their 1% lows are 19.75, 16.94, and 17.17 FPS
respectively; all 854 per-frame simulation hashes remain exact. The 80x60
presenter now compares each 16-pixel group as two independent
8-pixel halves, so a moving edge updates 32x4 physical pixels instead of 64x4.
Uniform half-runs use a direct overlapping-`LDIR` fill. Portal clip setup and
horizon shading touch only aperture rows, and outside noclip views render only
the convex room faces on the camera side.

Developer noclip now rejects the entire current-room AABB before projecting
corners or preparing horizon rows when the camera is outside and the room is
fully beyond a conservative frustum. Conservative edge bounds prevent
popping. In the supplied-ROM CEmu noclip route, looking away reaches 148.3 FPS
and turning with the room still completely off-screen reaches 148.0 FPS. A
partially visible exterior view improves from 78.2 to 89.1 FPS. Normal gameplay remains on the original hot
path and retains its exact state hashes while raising the no-body route to
37.20 FPS.

The native 80x60 root renderer now uses a dedicated assembly scan-conversion
kernel. It keeps a running logical-row address and omits portal aperture-array
lookups that are always redundant for the root layer. The clipped portal
kernel likewise caches its row-left, row-right, and destination cursors across
scanlines. Full-detail cube faces now use a fixed-quad bounds/setup path, while
the 20x15 portal state directly establishes its floor/ceiling bands and scans
only the dominant forward wall. Half/full portal views retain complete room
geometry. The eight-unit cube LOD range is unchanged. Relative to build
`0x26081303`, root-four rises from 30.53 to 32.35 FPS and its 1% low from 16.03
to 16.94; portal-four rises from 27.51 to 28.51 FPS and its 1% low from 16.92
to 17.17.

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
