# Fused exact transform and room-edge batch

## Decision: accept; supersedes `transform-math-current`

This version keeps the exact fused point transform, then batches all three
room-axis edge vectors under one assembly frame rather than making three C
ABI calls.

Strict comparison against the current row-band-fill baseline passes every
route, endpoint, logical-frame, presented-frame, engine-state, portal-LOD,
and portal-crossing hash.

| Metric | Baseline | Fused candidate | Change |
| --- | ---: | ---: | ---: |
| Clean mean frame time | 42.691 ms | 42.192 ms | -0.499 ms (-1.169%) |
| Clean average FPS | 23.42 | 23.70 | +0.28 FPS |
| 1% low | 14.91 FPS | 15.05 FPS | +0.14 FPS |
| Release `.8xp` | 29,835 B | 28,683 B | -1,152 B |
| Live-autotest `.8xp` | 41,851 B | 40,699 B | -1,152 B |

The host oracle in `test_transform_math.c` passes 38,619,968 exact cases.
The identities, supported-domain proof, and held-back portal signed-axis
experiment are documented in `../transform-math-current/RESULTS.md`.

The direct strict comparison is `results/fused-vs-baseline.json`.
