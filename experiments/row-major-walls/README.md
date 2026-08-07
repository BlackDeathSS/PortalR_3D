# Deferred terminal-wall experiment

This is an isolated snapshot of build `0x26072904` with the front-to-back
portal compositor and fixed-nine-step clipped-grid path.  It does not modify
the release sources.

`RENDER_ROW_MAJOR_WALLS=0` is the gate-off baseline.  Setting it to `1`
defers only terminal `PORTAL_NONE` wall columns.  Each terminal hit is decoded
into a 15-byte job containing its framebuffer destination, texture-run table,
scale boundaries, shaded color bank, clip, and strict-boundary flag.  One
assembly batch consumes all jobs after the 80 ray columns.  Portal masks and
unlinked portal walls remain on the established immediate path, so deferred
writes occupy disjoint four-pixel columns.

## Result: reject for integration

All six static framebuffer hashes match exactly, but the batch is slower in
every scene:

| Scene | Gate off | Deferred batch | Change |
|---|---:|---:|---:|
| NEAR_WALL | 44.659 ms | 48.019 ms | +7.53% |
| MID_DIRECT | 43.465 ms | 46.368 ms | +6.68% |
| LONG_DDA | 45.521 ms | 48.344 ms | +6.20% |
| PORTAL_CHAIN | 54.749 ms | 57.621 ms | +5.25% |
| PORTAL_WIDE | 41.595 ms | 44.399 ms | +6.74% |
| CUSTOM_PAIR | 54.325 ms | 57.133 ms | +5.17% |

The saved assembly entry/setup is smaller than the new predecode, 15-byte job
write, and later job read.  It also leaves the dominant strided framebuffer
writes unchanged.  A first C row-run prototype was framebuffer-exact but was
decisively worse (630.165 ms near and 467.724 ms mid), because transposing
individual wall pixels costs much more than it saves.

The host model explains why a general grouping pass is weak on gameplay:

- complete first-hit wall signatures reuse only `1.12x` on the 971-frame
  route;
- horizontal same-color runs average `2.98` logical columns;
- close-wall test scenes are coherent (16.67 columns/run near and 7.62 mid),
  but long/portal-heavy views average roughly 2--2.3.

The evidence points back to optimizing the existing direct vertical kernel in
place.  Deferral is only promising if the DDA emits prepared draw state at no
extra pass, or if a future renderer naturally produces layer-major jobs.

## RAM and code

Release-mode memory reports:

| Build | Resident program | `.bss` | Reserved stack | Largest frame | 96 KiB headroom |
|---|---:|---:|---:|---:|---:|
| Gate off | 18,089 B | 45,316 B | 4,096 B | 80 B | 30,803 B |
| Deferred batch | 18,557 B | 46,516 B | 4,096 B | 80 B | 29,135 B |

The experiment costs 468 bytes of resident program and 1,200 bytes of BSS.

## Reproduce

```powershell
make -C experiments/row-major-walls -B BENCHMARK=1 BENCHMARK_AUTOTEST=1 NAME=P3DRMB OBJDIR=obj/base ROW_MAJOR_WALLS=0
make -C experiments/row-major-walls -B BENCHMARK=1 BENCHMARK_AUTOTEST=1 NAME=P3DRMR OBJDIR=obj/row ROW_MAJOR_WALLS=1
```

Decoded A/B evidence is in `results/batch-vs-baseline2-compare.csv`.  The
`analyze_row_runs.py` model can optionally consume a decoded live
`*-frames.csv` route.
