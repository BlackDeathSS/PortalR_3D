# Prepacked shaded wall-run experiment

This isolated experiment starts from the register-resident full-wall renderer.
`PREPACKED_WALL_RUNS=0` is the baseline; `=1` selects an 8 KiB lookup indexed
by material (4), shade (4), texture column (16), and source row (8).

Each four-byte record is `{next source row, palette, palette, palette}`.  The
three palette bytes are loaded directly as the packed four-pixel wall color.
Clipped portal-aperture spans continue to use the established generic kernel.

## Result

Two serialized 971-frame live A/B passes produced identical results:

| Build | Mean frame | Average FPS | 1% low |
|---|---:|---:|---:|
| Register baseline | 44.483786 ms | 22.4801 | 16.7115 |
| Prepacked table | 44.020491 ms | 22.7167 | 16.8136 |
| Change | -0.463295 ms (-1.0415%) | +1.0525% | +0.6106% |

All 18 sections improved by 0.2945--0.5157 ms.  All 18 framebuffer hashes,
all 18 state hashes, all 971 route-state rows, and all three portal crossings
match.  The repeated reverse-order run was deterministic.

The full-wall hot lookup falls from 15 to 10 instructions per texture run.
Setup also replaces separate texture/color base calculations with one table
base.  With 4.52 texture runs per complete texture column, this saves about 30
setup/hot instructions per ordinary full wall.

## RAM and code

| Build | Resident | `.bss` | 96 KiB headroom |
|---|---:|---:|---:|
| Baseline release | 18,318 B | 49,404 B | 26,486 B |
| Prepacked release | 18,525 B | 57,596 B | 18,087 B |

The candidate costs 207 resident bytes and exactly 8,192 B of BSS.

The static benchmark currently cannot link: its candidate BSS is 63,740 B,
while CEdev's BSS region is 60,690 B, an overflow of 3,050 B.  At least 3,051
benchmark-only bytes must move or be eliminated.  A compact same-format report
can save 3,160 B by retaining only the meaningful 20 bytes of each clean
sample, generating the 64-byte header while saving, and retaining six frame
hashes instead of six complete scene records.  Streaming the full 6,064-byte
report directly into `P3DTMP` is the safer design and avoids its final duplicate
in RAM.

## Host checks

`tools/check-prepacked-wall-runs.py` exhaustively verifies all 2,048 records,
the assembly address formula, packed palette values, and 512 complete run
chains.  The existing wall descriptor/shade and DDA exhaustive checks also
pass.

## Scanline-compositor estimate

A general assembly scanline compositor is unlikely to save 3 ms on the live
route.  It would execute 19,200 column-state checks per frame, while the route
model has only about 5,265 active ordinary-wall row/column cells.  At 2.98
logical columns per same-color run, there are roughly 1,767 horizontal runs.
Packed contiguous stores save only several store/pointer instructions per run,
which is unlikely to repay the state checks, much less net the roughly 144,000
48-MHz clocks represented by 3 ms.  A high-coverage close-wall-only hybrid may
still be viable; a general replacement is not.

## Reproduce

```powershell
make -C experiments/prepacked-wall-runs -B NAME=PWRBASE OBJDIR=obj/base BUDGET_MAP=bin/PWRBASE.map PREPACKED_WALL_RUNS=0 budget
make -C experiments/prepacked-wall-runs -B NAME=PWRFAST OBJDIR=obj/fast BUDGET_MAP=bin/PWRFAST.map PREPACKED_WALL_RUNS=1 budget
python experiments/prepacked-wall-runs/tools/check-prepacked-wall-runs.py
```

Decoded live evidence is under `results/`.  The two intentionally failing
autotester CRC checks produced the RAM dumps used by the decoder.
