# True3D2

True3D2 is a new, versioned TI-84 Plus CE mesh/portal engine beside the existing
`true3d` and PortalR renderers. It is an experimental implementation of the
hybrid architecture, not yet a performance-certified replacement.

The checked-in vertical slice includes:

- fixed 80x60, 40x30, and 20x15 color/depth layers and a dedicated unrolled
  4x eZ80 presenter;
- checked `T3D2MAP`, paged meshlet, 256x256 atlas, and mip AppVar formats;
- an OBJ/JSON/PNG compiler with triangulation, cell clipping, affine
  subdivision, 32-vertex/48-triangle meshlets, PVS, gateway and portal checks,
  compact collision BVHs, palette shade banks, mips, CRCs, and `.8xv` output;
- a device-side general-mesh path with PVS selection, vertex reuse,
  backface/near clipping, affine texture mapping, 16-bit inverse depth, and an
  assembly triangle normalizer/gradient path and opaque span loop behind a
  checked C edge walker;
- projected wall-mounted portal apertures with transformed 40x30 destination
  cameras and a fixed 20x15 nested recursion layer;
- deterministic 60 Hz player/body state plus linked-portal position, basis,
  velocity, and translation-only body-orientation transforms;
- host raster/portal/physics references, a T3D1 box-level converter, and
  malformed-data/determinism tests;
- isolated kernel/runtime reports plus reproducible ROM-driven CEmu tests;
- a journal/chunk recovery format, PC verifier/extractor, and fail-closed
  `T3DRECOV` calculator inspector.

See [Implementation status](docs/STATUS.md) for the exact remaining production
work. In particular, the current mixed C/assembly rasterizer failed the frozen
kernel gates after three measured passes; it is not performance-certified. See
[the 2026-08-10 CEmu report](docs/CEMU_PERFORMANCE_2026-08-10.md) and the
[renderer replacement boundary](docs/RENDER_REDESIGN.md).

## Build and test

```sh
cd true3d2
make
make budget
python -m unittest discover -s tests -v
```

Build the mandatory kernel-gate program:

```sh
make clean
make KERNEL_BENCHMARK=1
python tools/decode_kernel.py T3DKERN.8xv
```

Compile the example scene:

```sh
python tools/t3d2_compile.py examples/two_cell/scene.t3d2.json \
  --output examples/two_cell/build
```

Convert and then compile a legacy level:

```sh
python tools/t3d1_to_t3d2.py T3DLVL1.8xv --output converted
python tools/t3d2_compile.py converted/scene.t3d2.json --output converted/build
```

Build the recovery inspector separately:

```sh
cd recovery
make
```

## Controls

- Arrow keys: move and turn
- `2nd`: jump
- `Alpha` / `Mode`: place the two portals
- `Del`: cancel both portals
- `Clear`: exit

Portal placement is aim-based: `Mode` places/replaces blue and `Alpha`
places/replaces orange on a compiled portal host in the current cell. The
current renderer constructs each aperture from its stored center/right/up
basis, near-clips its four world-space corners, and projects the resulting
planar polygon. It therefore remains on the host wall and foreshortens with the
camera instead of behaving as a camera-facing sprite. The linked aperture is
filled from a transformed destination camera rendered at 40x30. A portal seen
through that view is rendered once more at 20x15; visual recursion then stops.
The destination host's coplanar meshlets are omitted as a temporary host-hole
implementation, so exact polygon-level host clipping remains unfinished.

## Safety and performance contract

`FULL_TAKEOVER=1` still returns `T3D2_ERROR_MEMORY_UNPROVEN`. The normal build
never erases raw flash sectors and never overwrites the full RAM map. The
recovery formats and inspectors exist so the dangerous handoff can be tested
before it is enabled—not as evidence that it is already safe.

The selected production contract remains 30 FPS average and 25 FPS 1% low on
real hardware, with the fixed resolution and recursion tiers. No host timing is
reported as calculator evidence. The hardware kernel gates and certified route
must pass before this engine is called performance-certified.

The normal build does not take over RAM and therefore creates no `T3DBKM`
journal for `T3DRECOV` after a reset. Recovery remains deliberately fail-closed.
