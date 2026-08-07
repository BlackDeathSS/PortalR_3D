# True3D background/fill experiment

Baseline: the current two-chain scan converter (`build 0x26080601`), measured
with the 854-frame CEmu live route.

## Retained candidate

`unclipped-artifacts/engine.c` is the recommended integration reference. It:

- converts the floor/ceiling distance lighting into five constant-color row
  ranges, eliminating the per-scanline signed absolute value and threshold
  work;
- computes the flat wall color once per polygon;
- removes row-bound checks already guaranteed by rasterization; and
- skips the redundant per-row layer-left/right clamps only for non-apertured
  root polygons, whose clip is always the full logical viewport.

| Metric | Baseline | Candidate | Change |
| --- | ---: | ---: | ---: |
| Clean mean | 49.283 ms | 47.637 ms | -1.646 ms (-3.34%) |
| Average FPS | 20.29 | 20.99 | +3.46% |
| 1% low FPS | 12.51 | 13.05 | +4.32% |
| Autotest size | 42,233 B | 41,673 B | -560 B |

On comparable detailed frames, root fill fell 13.4-32.1% and portal fill fell
6.5-18.9%. The route fingerprint, every recorded state hash, all ten section
logical/presented hashes, final logical hash `0x13BBC90D`, final presented hash
`0x232B60B4`, endpoints, LOD states, and four portal crossings match exactly.
Decoded evidence is in `unclipped-artifacts/recommended.json` and
`unclipped-artifacts/recommended-compare.csv`.

An exhaustive host check also compared the old and banded lighting equations
for both horizontal face light levels, both 64x48 and 32x24 horizon limits,
every row, and horizon positions -256 through +256: all 73,872 combinations
matched.

## Rejected candidates

- Always-inline `write_frame_span`: 49.283 -> 50.043 ms (+1.54% slower) and
  +1,134 bytes. Rejected.
- Specialized eZ80 span fill replacing libc `memset`: only 47.181 -> 47.118
  ms (-0.13%), below a convincing margin and confounded by the unsafe no-clear
  variant. Rejected.
- Eliding the depth-zero framebuffer clear looked exact on the scripted route
  and saved 0.457 ms, but failed a broader temporal-staleness test. The
  experiment rendered 1,024 deterministic cameras (all 256 yaw values four
  times, all 129 legal pitch values repeatedly, both rooms, randomized interior
  positions, active portals, and all portal LOD starting states) first with a
  clear, then from a buffer poisoned with `reference ^ 0x5A`. It found 118,207
  mismatched/stale pixels; first failure was sample 4, logical pixel 2496.
  **Keep the root clear.** The RAM evidence is
  `validation-artifacts/validation-ram.bin`; the result words are
  `DONE, 1024, 118207, 4, 2496` at map symbol
  `_true3d_clear_validation_result`.

The experiment-only validation harness remains behind
`TRUE3D_CLEAR_VALIDATION`; it is compiled out in normal builds.
