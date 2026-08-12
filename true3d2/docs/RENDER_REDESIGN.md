# Renderer redesign boundary

Build `0x26081005` establishes the current correctness baseline: fixed
perspective, shaded non-checker laboratory textures, planar wall-mounted
portals, a transformed 40x30 destination camera, and a 20x15 nested layer.
Those features are implemented, but the supplied-ROM measurements prove that
the current renderer is still an architectural prototype rather than the
production kernel.

- 4,800 texture/depth samples: 40.100 ms, including 25.055 ms in spans;
- 96 synthetic transform/cull/clip/project cases: 117.401 ms;
- 80x60-to-320x240 presentation: 13.767 ms;
- unlinked textured route: 107.487 ms mean, or 9.303 FPS capacity;
- continuously visible recursive portal: 805.725 ms median, or 1.241 FPS.

The next renderer must preserve the frozen 80x60, 40x30, and 20x15 layers,
16-bit inverse depth, exact visual hashes, and recursion depth. It must replace
the remaining runtime structure rather than reduce those requirements.

## 1. Meshlet-batched assembly front end

The generic normalizer and six gradient products now run in assembly and match
the C reference exactly. The remaining work is larger:

- consume compiler-packed vertices and indices directly from one meshlet;
- transform referenced vertices once into a fixed hot cache;
- reject by normal cone, sphere/outcodes, propagated aperture, and near plane;
- project with reciprocal tables and clip only triangles carrying an outcode;
- replace the C scan-edge walk and global scratch ABI with register-resident
  triangle packets and material batches.

The frozen 96-case gate remains 4 ms. The current 117.401 ms result is a hard
failure, not a near miss.

## 2. Fixed material span programs

- Replace the general span state block with copied writable eZ80 kernels for
  opaque resident mip, cutout resident mip, solid portal, and depth-only work.
- Patch texture base, shade bank, depth/UV increments, and row endpoints once
  per span or material batch, following Virtual3D's register-resident and
  self-modified kernel technique.
- Preserve top-left ownership and deterministic inverse-depth ties.

The 4,800-sample gate remains 8 ms. Code adapted from Virtual3D/MinecraftTI
must retain its license notice and attribution.

## 3. Visibility and portal layers

The functional recursion path is now present. It transforms the camera through
the linked pair, renders 40x30, renders a visible nested portal at 20x15, and
composites both through projected convex aperture masks. Optional meshlets are
rejected before transform after the per-layer budget is exhausted; the demo
now records `[11, 44, 32]` submitted triangles and `[4800, 1129, 112]` samples.

Production work remains:

- propagate the root portal aperture through gateway traversal instead of
  rendering a full child frustum;
- clip exact holes from host polygons rather than omitting all destination-host
  coplanar triangles;
- avoid rendering portal layers that cannot contribute covered root pixels;
- add meshlet projected-contribution and normal-cone rejection;
- implement destination working-set residency, charging, and the full-screen
  source-view skip.

## 4. Presenter and release gates

- Replace the current row-copy presenter with a measured copied/unrolled path
  that reaches 12.5 ms or less without changing logical resolution.
- Re-run the supplied-ROM visual, recursion, input, cancellation, Clear-exit,
  kernel, and runtime suites after every kernel replacement.
- Stop after the plan's measured optimization limit if fixed gates still fail;
  do not hide failure by reducing resolution, recursion, or sample contracts.

Recursive rendering is no longer blocked on correctness implementation. It is
blocked on the same assembly front end, aperture propagation, and span rewrite
required by the non-portal view.
