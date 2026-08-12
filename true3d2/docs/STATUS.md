# Implementation status

This file separates working foundations from production claims. A checked box
means code and host verification exist; it does not substitute for calculator
timing or recovery testing.

## Milestone 1: baselines

- [x] True3D and MinecraftTI source hashes/licenses/binary sizes frozen in
  `BASELINES.md`; retained True3D route captures are identified there.
- [x] True3D2 build/map artifacts and deterministic host route hashes.
- [x] Isolated presenter, 4,800-sample raster, and 96-triangle setup report.
- [x] Run the report and input/exit regressions with the supplied ROM in CEmu;
  results and ROM hash are in `CEMU_PERFORMANCE_2026-08-10.md`.
- [ ] Repeat the gates on real CE hardware; CEmu is A/B evidence only.
- [ ] Add instrumentation to an unchanged MinecraftTI demo and save its phase
  baseline. True3D2 does not depend on this to build.

## Milestone 2: recovery

- [x] Versioned journal with per-chunk and complete-snapshot CRCs.
- [x] Five-chunk host verifier/extractor and corruption/state tests.
- [x] Standalone calculator inspector which never restores invalid data.
- [x] Engine takeover entry point fails closed, including `FULL_TAKEOVER=1`.
- [ ] OS/hardware allowlist, battery/free-archive checks, protected restore
  stub, interrupted-state injection, reset recovery, and 100-launch soak.
- [ ] Only after those tests: enable backup allocation and RAM overwrite.

## Milestone 3: render kernels

- [x] Unrolled assembly 80x60-to-320x240 presenter.
- [x] Correctness-reference affine texture/inverse-depth rasterizer.
- [x] Near clip, per-meshlet transform cache, backface test, counters, hashes.
- [x] Assembly signed triangle normalization, six-gradient setup, and opaque
  affine texture/depth span; the audited scan-edge walker remains C.
- [ ] Hardware gates: presenter <=12.5 ms, raster <=8 ms, setup <=4 ms.
- [x] The measured C-to-assembly redesign improved the isolated raster from
  1,028.168 ms to 40.100 ms, but all three gates still fail. The feasibility
  report records the remaining full-kernel redesign.
- [x] Freeze the corrected projection/portal visual baseline and document the
  meshlet-batched, material-specialized assembly replacement boundary in
  `RENDER_REDESIGN.md`.

## Milestone 4: static renderer

- [x] OBJ/JSON authoring, cell clipping, subdivision, meshlets, geometry pages.
- [x] Atlas quantization, four shade banks, full mip chain, checked AppVars.
- [x] Runtime resource CRCs, PVS plus frustum-tested gateway cell traversal,
  vertex caching, root general-mesh rendering, and resident 128x128 mip cache.
- [x] Compact offline collision BVH and T3D1 conversion.
- [ ] Exact propagated gateway aperture clips and projected-contribution/
  normal-cone meshlet culling.
- [ ] Runtime mip selection and geometry-cache residency policy.
- [ ] Stable assembly ABI using IX/IY and documented clobber/stack contracts.

## Milestone 5: portals

- [x] Compiled convex portal hosts and gameplay rigid transforms.
- [x] Player/body traversal, velocity/basis/orientation transfer, recross guard.
- [x] Fixed 80/40/20 buffers and a True3D-style planar root aperture built
  from four world-space portal corners, with near clipping and scan conversion.
- [x] Aimed blue/orange placement, same-slot replacement, linking, and Del
  cancellation verified in supplied-ROM CEmu tests.
- [x] Render transformed destination cameras into the fixed 40x30 child layer
  and a portal visible through it into the fixed 20x15 layer; stop at depth two.
- [ ] Leave host pixels unwritten, propagate aperture/gateway clips, add the
  full-screen fast path, and implement the residency-backed charging state.
  The current child view conservatively omits destination-host coplanar
  triangles instead of clipping the exact hole.

## Milestone 6: physics

- [x] Fixed-rate gravity/jump, eight-body pool, sleep, portal transfer.
- [x] Player cell-AABB wall collision and gateway cell handoff; the benchmark
  can no longer leave the authored scene through a solid wall.
- [ ] Swept capsule, BVH triangle queries, slopes, steps, triggers.
- [ ] Cell-bucket broadphase, body/body impulses, static box/sphere contacts.
- [ ] Prove the certified scene stays within the 2 ms average physics budget.

## Milestone 7: certification

- [x] Compiler rejects declared certified views over the 96/64/32 triangle and
  4800/1200/300 sample budgets.
- [x] Current linked/BSS/stack budget: 83,679 bytes including a reserved
  6,144-byte stack; 69,921 bytes remain under the 150 KiB development limit.
  The loader additionally uses a 32 KiB mip cache plus scene/geometry heap.
- [ ] 24-cell/6,000-source-triangle certification scene and exact route.
- [ ] >=30 FPS average, >=25 FPS 1% low, <=40 ms 99th percentile on hardware.
- [ ] CEmu/hardware timing calibration, hash parity, cache/queue/canary soak.
