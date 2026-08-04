# Renderer-specialized DDA ABI experiment

This directory is an isolated snapshot. It was not run in CEmu because the
shared dump path was reserved by the parent task.

## Candidate

The generic five-argument `render_asm_cast_wall_begin` and one-argument
`render_asm_cast_wall_continue` remain available for placement traces.
`render_column` instead calls two frame-free, no-argument entries:

- `render_asm_cast_wall_render_begin`
- `render_asm_cast_wall_render_continue`

`game_render` publishes the immutable camera origin and hit pointer once per
frame. `render_column` publishes only `ray_x` and `ray_y` once per logical
column. Portal transforms continue to mutate the normal persistent origin and
ray fields, so continuation semantics are unchanged.

The common cast body now returns directly. Generic framed wrappers call that
body and restore IX; specialized entries jump into it and return without ever
creating an IX frame.

## Validation

- `check-dda-exact.py --samples 250000`: PASS
  - 52,800 boundary seeds
  - 17,303 edge products
  - 10,000 axis-boundary casts / 65,400 steps
  - 250,000 bordered-map casts / 2,177,219 steps
- `check-portal-transform.py`: PASS
  - 1,192,464 exhaustive normal/tangent cases
  - 1,000,000 randomized signed-24-bit cases
  - 5,000 randomized depth-1..6 chains / 17,668 exact casts
- `make LIVE_BENCHMARK=1 budget`: PASS

No calculator/emulator framebuffer run was performed.

## Static cost and expected gain

| Item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| Resident program | 31,266 B | 31,432 B | +166 B |
| BSS | 49,488 B | 49,494 B | +6 B |
| Budgeted RAM | 84,850 B | 85,022 B | +172 B |
| Remaining 96 KiB budget | 13,454 B | 13,282 B | -172 B |
| `render_column` stack | 58 B | 58 B | 0 B |

The generated primary-call path loses five argument pushes, five cleanup pops,
camera/hit argument preparation, and the assembly frameset. The continuation
path loses its argument push/cleanup, frameset, and repeated hit-pointer store.
Against the submitted 971-frame route (80 primary casts plus 24.15 portal
continuations per frame on average), this is approximately 1,664 fewer emitted
instructions per frame. A reasonable static forecast is about 0.2-0.5 ms per
frame, not enough by itself to move a 47-57 ms frame through 33.3 ms.

The root source gained a three-byte `portal_plan` state field after this
snapshot. When applying the candidate there, append `render_origin_x` and
`render_origin_y` at offsets 58 and 61 and set `STATE_SIZE`/`sizeof` to 64.

## Next DDA extension: base-origin seed cache

Every primary ray shares a map start and origin fraction. Cache once per frame:

- padded map start pointer: 3 B
- qx for negative/positive X: 6 B
- qy for negative/positive Y: 6 B

The primary entry selects qx/qy by the ray sign and loads the cached map
pointer. Portal continuations continue through the existing transformed-origin
seed path. This removes roughly 16-22 more setup instructions per primary ray,
or about 1,280-1,760 instructions per frame, at +15 B state. Forecast:
approximately another 0.15-0.4 ms per frame.

## Background-generator audit

The current release compiler emits about 679 static instructions from grid
setup through ceiling replay, including roughly 202 IX-relative memory
operations, 150 push/pop/PEA operations, and 56 static call sites. The game
render frame is 82 B. An exact assembly generator should:

1. Keep the reciprocal scales, line endpoints/steps/inputs, and segment end in
   a fixed 60-70 B scratch block.
2. Specialize multiplication by 260 and 4096; keep reciprocal-table semantics.
3. Run the two fixed 16-line loops with register/no-argument projection entry
   points, preserving the one signed-zero-crossing recomputation.
4. Replay stored ceiling segments in assembly and retain the current clipping
   and raster kernels unchanged initially.
5. Validate all intermediate projected endpoints against the Python model,
   then gate integration on framebuffer hashes and background-phase timing.

This attacks compiler orchestration, not the necessary VRAM work. Expected
gain is likely around 0.5-1.5 ms normally and perhaps 2-3 ms in the LONG scene;
it is a better exact target than another C micro-tune but still not a complete
30 FPS solution.

The suggested unclipped q=2 paired-row specialization is not route-relevant:
only 11 eligible lines appear in 971 submitted frames (0.0113 line/frame,
0.89% of unclipped lines), and none occur in the six static scenes. A separate
clipped q=2 kernel covers 1,520 of 37,426 clipped rasters (4.06%, 1.57/frame)
and would reduce 209,254 pixel iterations to 77,317 row runs across the route,
about 136 loop iterations saved per frame before setup overhead.
