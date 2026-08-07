# Full-resolution raster specialization

## Result

This is an exact optimization and is worth integrating.  A root layer with
`lod_shift == 0` now uses a scan converter with compile-time `step = 1` and
`sample_origin = 0`; portal LOD layers continue to use the original generic
path unchanged.

After integration with the LOD compositor pass, the deterministic CEmu live
route improved from **76.490 ms to 69.136 ms per frame** (**-9.61%**), or
**13.07 to 14.46 FPS**.  Root geometry improved by roughly **14-16%** and
full-resolution portal geometry improved by roughly **17%**.  Logical-frame,
presented-frame, engine-state, and per-section hashes remained exact.

## Exactness checks

`test_equivalence.c` independently models the previous shift-zero path and
the specialized path.  It compares the return value, first/last row, and all
48 left/right span bytes.  Its deterministic cases include both 64x48 and
32x24 render modes, clipped layer rows, arbitrary aperture row bounds,
subpixel boundary values, off-screen vertices, horizontal edges, reversed
edges, and three through eight polygon points.

Build and run it on the host with:

```powershell
C:\msys64\ucrt64\bin\gcc.exe -std=c11 -O2 -Wall -Wextra -Werror test_equivalence.c -o bin\test_equivalence.exe
.\bin\test_equivalence.exe
```

Observed result:

```text
PASS: 100000 randomized full-resolution raster cases are exact
```

The calculator live benchmark then confirmed exact results along the full
scripted gameplay route, including portal traversal and LOD state changes.

## Generated-code evidence

For diagnosis, both branches were temporarily marked `noinline` so the CEdev
linker map and relocations exposed each path independently.  Those attributes
are deliberately absent from the integration version because allowing LTO to
merge the dispatcher saves about 200 resident bytes and avoids another call
on every polygon.

| Release routine | Bytes |
| --- | ---: |
| Previous generic `rasterize_polygon` | 2,633 |
| Specialized full-resolution branch (isolated) | 1,989 |
| Preserved LOD branch (isolated) | 2,478 |
| Isolated dispatcher | 43 |
| Shared `edge_x_step` after extraction | 161 |

The isolated full-resolution branch is 644 bytes (24.5%) smaller than the
old generic routine by itself.  More importantly for runtime, its internal
math-helper relocation sites fell from 66 to 36.  Including the five helper
sites in the extracted shared edge-step routine gives 41 sites, still 25
fewer than before.  In particular, the full branch changed:

- `__iand`: 4 to 0 sites
- `__ishl`: 10 to 1 site
- `__ishrs`: 6 to 0 sites
- `__ishru_1`: 1 to 0 sites

The remaining right shifts are fixed-point rounding and long-arithmetic
operations, not the removed per-row `lod_shift` alignment work.

With normal LTO, the two C branches are folded into one 4,307-byte emitted
dispatcher plus the 161-byte shared edge-step routine.  The zero-shift branch
still bypasses the generic setup at entry; it does not execute the LOD helper
sequence.

## Size and stack deltas

These A/B numbers use the same pre-LOD-compositor source snapshot so only the
raster specialization changes.

| Build | Baseline | Specialized | Delta |
| --- | ---: | ---: | ---: |
| Release `.8xp` | 29,107 B | 30,943 B | +1,836 B |
| Release resident program | 29,367 B | 30,866 B | +1,499 B |
| Release `.bss` | 21,162 B | 21,162 B | 0 B |
| Release budgeted RAM | 54,625 B | 56,124 B | +1,499 B |
| Live-autotest `.8xp` | 40,761 B | 42,863 B | +2,102 B |
| Live-autotest resident program | 41,269 B | 42,786 B | +1,517 B |
| Live-autotest `.bss` | 21,256 B | 21,256 B | 0 B |
| Live-autotest budgeted RAM | 66,621 B | 68,138 B | +1,517 B |

The largest reported stack frame remains 237 bytes in both builds.  Under
normal LTO, the release raster routine's reported static frame changes from
83 to 88 bytes; the instrumented build changes from 97 to 96 bytes.  The
4,096-byte reserved stack and the project RAM limit both remain comfortably
within budget.

## Minimal integration diff

Relative to `experiments/lod-compositor-baseline/src/engine.c`, the only
engine change is:

1. rename the existing implementation to `rasterize_polygon_lod` without
   changing its body;
2. add `rasterize_polygon_full`, replacing variable alignment and increments
   with the exact shift-zero forms;
3. dispatch on `layer->lod_shift` in a small `rasterize_polygon` wrapper.

No structures, buffers, draw order, clipping rules, top-left/sample-center
rules, portal state, colors, resolution, or detail are changed.

To inspect the minimal patch:

```powershell
git diff --no-index ..\lod-compositor-baseline\src\engine.c src\engine.c
```

## Risks and follow-up

- The two scan converters intentionally duplicate rounding-sensitive code.
  Any later clipping or fill-rule correction must be applied to both paths
  and rechecked with the host oracle and live-route hashes.
- The optimization spends about 1.5 KiB of resident program space.  The
  measured geometry reduction justifies that cost, but it should be retained
  in future memory-budget reports.
- Do not add `noinline` to the production branches.  It was useful only for
  codegen inspection and increases code size while adding polygon-call
  overhead.
- LTO decisions can change after unrelated large renderer edits.  Recheck the
  map/helper relocations if the scan converter changes materially.
