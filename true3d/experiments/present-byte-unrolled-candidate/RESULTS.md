# Unrolled byte-store presenter

## Verdict

Accept.  Exact CEmu A/B shows a 10.85% reduction in presenter time and a 3.82%
reduction in complete-frame time with exact logical, presented, and engine-state
hashes.  Mean throughput rises from 23.93 to 24.89 FPS without changing render
resolution, palette values, textures, or any generated pixel.

The parent task integrated this presenter into root after the exact benchmark.
This directory remains an isolated before/after artifact and host proof.

## Method

The old 64x48 path loaded source pixels through `IY`, emitted five ordinary
byte stores, and paid a `DJNZ` loop for every logical pixel.  The candidate:

1. uses `HL` as the sequential source pointer (`LD A,(HL)` / `INC HL`);
2. expands the five byte stores as a macro;
3. statically unrolls that macro 64 times per logical row;
4. retains the existing single forward-overlapping `LDIR` that replicates the
   completed 320-byte row four more times;
5. uses `IXH` only as the 48-row counter and preserves `IX` at the function
   boundary.

The 32x24 performance presenter is intentionally unchanged.  This isolates the
optimization to the normal-detail 64x48 mode used by the benchmark and avoids
changing an unmeasured path.

## Exact CEmu A/B

The parent task integrated only this presenter change over the current
two-chain pass and ran the exact ten-frame benchmark:

| metric | baseline | unrolled candidate | change |
|---|---:|---:|---:|
| corrected presenter aggregate | 14.648 ms | 13.0585 ms | -1.5895 ms (-10.85%) |
| mean complete frame | 41.780 ms | 40.183 ms | -1.597 ms (-3.82%) |
| mean throughput | 23.93 FPS | 24.89 FPS | +0.96 FPS (+4.0%) |

All logical framebuffer, presented-frame, and engine-state hashes matched
exactly.

The close agreement between the 1.5895 ms presenter reduction and 1.597 ms
complete-frame reduction confirms that the gain comes from the intended phase;
there is no hidden renderer-detail change.

## Static eZ80 work model

For one 64-pixel horizontal row, including row-loop control but excluding the
identical vertical `LDIR`:

| path | cycles per row | change |
|---|---:|---:|
| indexed source plus `DJNZ` | 1,598 | baseline |
| sequential source, fully unrolled | 1,152 | -446 (-27.91%) |

The candidate saves approximately 444 cycles on every non-final row, or about
21,312 cycles per complete presenter call.  The static saving is about 8.1% of
modeled full-presenter work once the unchanged vertical copies are included;
CEmu measures a larger 10.85% presenter improvement.

## Exactness tests

`check_exact.c` compares the baseline and candidate algorithms, including a
literal forward-overlapping model of the 1,280-byte vertical copy:

```text
complete frame cases passed: 85792
output bytes compared: 6588825600
framebuffer FNV-1a-64: 47e508f0993ec10e
horizontal model per row: 1598 -> 1152 cycles (-27.91%)
```

Coverage includes every one of the 65,536 possible 16-bit binary transition
patterns tiled across a complete 64x48 frame, every solid eight-bit palette
value, and 20,000 deterministic random frames.  All comparisons cover the
complete 320x240 presented framebuffer.

## Code and RAM

The speed tradeoff is 750 bytes of resident code and no additional BSS.

| configuration | baseline | candidate | delta |
|---|---:|---:|---:|
| release resident program | 30,217 B | 30,967 B | +750 B |
| release `.text` | 29,249 B | 29,999 B | +750 B |
| release `.bss` | 33,162 B | 33,162 B | 0 B |
| release budgeted RAM total | 67,475 B | 68,225 B | +750 B |
| release headroom to 96 KiB | 30,829 B | 30,079 B | -750 B |
| release headroom to 150 KiB hard limit | 86,125 B | 85,375 B | -750 B |
| release AppVar | 30,293 B | 31,043 B | +750 B |
| live resident program | 42,717 B | 43,467 B | +750 B |
| live `.bss` | 33,256 B | 33,256 B | 0 B |
| live budgeted RAM total | 80,069 B | 80,819 B | +750 B |
| live headroom to 96 KiB | 18,235 B | 17,485 B | -750 B |
| live headroom to 150 KiB hard limit | 73,531 B | 72,781 B | -750 B |
| live AppVar | 42,794 B | 43,544 B | +750 B |
| autotest AppVar | 42,233 B | 42,983 B | +750 B |

The reserved stack remains 4,096 bytes and the largest attributed stack frame
is unchanged.

## ABI and interrupt safety

The optimized entry point preserves `IX`, balances every push and pop, and
returns with the normal C ABI's callee-saved state intact.  `AF`, `BC`, `DE`,
and `HL` are used only as ordinary caller-clobbered working registers.  The
stack is never relocated.

The candidate adds no `DI` or `EI` and retains the existing vertical `LDIR`.
Its interrupt assumptions are therefore identical to the previously accepted
presenter.

## Validation performed

- Release build: passed.
- Live benchmark build: passed.
- Autotest build: passed.
- Release/live 153,600-byte RAM checks with a 4,096-byte reserved stack:
  passed.
- Host arbitrary-palette full-frame exactness: passed.
- Exact CEmu ten-frame A/B: every logical, presented, and state hash matched.
- Exact CEmu performance: presenter -10.85%, complete frame -3.82%; accepted
  and integrated by the parent task.
