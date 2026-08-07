# Exact run-length presenter experiment

## Verdict

Reject and keep the original fixed-factor unrolled presenter.  The run-length
candidate is framebuffer-exact for arbitrary eight-bit pixels, but exact CEmu
A/B made a complete frame 0.179% slower and the benchmark's corrected
presenter aggregate 2.27% slower.  It also adds 32 bytes of code.

This result is explained by the eZ80 timing rather than by an unlucky scene.
In ADL mode `LDIR` costs `2 + 3*BC` cycles.  Seeding a run with `LD (DE),A`,
incrementing `DE`, and copying the remaining bytes with an overlapping `LDIR`
therefore costs `3L + 2` cycles for an `L`-byte run.  The existing unrolled
`LD (DE),A` / `INC DE` pairs cost exactly `3L` cycles.  The proposed run copy
is already two cycles behind before paying for run detection, `MLT BC`, stack
traffic, and branches.  No distribution of same-color runs can make this
specific algorithm break even.

The candidate remains isolated here for auditability.  The parent task's
temporary integration was reverted, so root `src/present.s` remains on the
faster implementation.

## Exact CEmu A/B

The parent task integrated only this presenter change over the current direct
projection-table pass and ran the exact benchmark:

| metric | baseline | run-length candidate | change |
|---|---:|---:|---:|
| mean render | 68.772 ms | 68.895 ms | +0.123 ms (+0.179%) |
| mean FPS | 14.54 | 14.51 | -0.03 |
| corrected presenter aggregate | 146.484 ms | 149.811 ms | +3.327 ms (+2.27%) |

Render and state hashes matched exactly.

## Candidate method

For every 64-pixel or 32-pixel source row, the candidate scans adjacent pixels
into maximal same-color runs.  It multiplies each run length by the fixed
horizontal scale (five or ten), writes one seed byte, and expands that seed
with a forward-overlapping `LDIR`.  The existing vertical replication remains
unchanged: one overlapping `LDIR` copies the completed 320-byte row four or
nine more times.

The implementation handles all 256 palette values; it makes no assumptions
about texture palettes, transparency, or background colors.

## Static eZ80 work model

The host model uses the ADL timings from the Zilog eZ80 CPU User Manual,
including `LDIR = 2 + 3*BC` and `MLT BC = 6` cycles.  It models the horizontal
row expansion only; the identical vertical copy is excluded from both sides.
`R` is the number of maximal color runs in one logical row.

| mode | runs | baseline cycles | candidate cycles | change |
|---|---:|---:|---:|---:|
| 64 x scale 5 | 1 | 1,598 | 1,820 | +13.9% |
| 64 x scale 5 | 4 | 1,598 | 1,934 | +21.0% |
| 64 x scale 5 | 8 | 1,598 | 2,086 | +30.5% |
| 64 x scale 5 | 16 | 1,598 | 2,390 | +49.6% |
| 64 x scale 5 | 32 | 1,598 | 2,998 | +87.6% |
| 64 x scale 5 | 64 | 1,598 | 4,217 | +163.9% |
| 32 x scale 10 | 1 | 1,278 | 1,404 | +9.9% |
| 32 x scale 10 | 4 | 1,278 | 1,518 | +18.8% |
| 32 x scale 10 | 8 | 1,278 | 1,670 | +30.7% |
| 32 x scale 10 | 16 | 1,278 | 1,974 | +54.5% |
| 32 x scale 10 | 32 | 1,278 | 2,585 | +102.3% |

Even an entirely solid row is slower.  Textured rows, which naturally create
more runs, increase the loss.

## Exactness tests

`check_exact.py` compares the fixed-factor and run-length algorithms, including
their forward-overlapping horizontal and vertical copies.  Its recorded result
is:

```text
row cases passed: 231,584
full-frame adversarial cases passed: 8
framebuffer SHA-256: d73227b505a6945bf58e4c9c37c919cd87510a509d784dd58fbe983fb1292a41
```

Coverage includes all 65,536 binary 16-pixel rows at both scale factors, every
possible solid eight-bit color at both real widths, 100,000 deterministic
random/adversarial real-width rows, and complete solid, alternating, ramp, and
random framebuffers at 64x48 and 32x24.

## Code and RAM

| configuration | baseline | candidate | delta |
|---|---:|---:|---:|
| 64x48 presenter routine | 58 B | 79 B | +21 B |
| 32x24 presenter routine | 70 B | 81 B | +11 B |
| release resident program | 31,211 B | 31,243 B | +32 B |
| release `.text` | 30,243 B | 30,275 B | +32 B |
| release `.bss` | 33,450 B | 33,450 B | 0 B |
| release budgeted RAM total | 68,757 B | 68,789 B | +32 B |
| release headroom to 96 KiB | 29,547 B | 29,515 B | -32 B |
| release headroom to 150 KiB hard limit | 84,843 B | 84,811 B | -32 B |
| release artifact | 31,287 B | 31,319 B | +32 B |
| live resident program | 43,939 B | 43,971 B | +32 B |
| live `.text` | 42,393 B | 42,425 B | +32 B |
| live `.bss` | 33,544 B | 33,544 B | 0 B |
| live budgeted RAM total | 81,579 B | 81,611 B | +32 B |
| live headroom to 96 KiB | 16,725 B | 16,693 B | -32 B |
| live headroom to 150 KiB hard limit | 72,021 B | 71,989 B | -32 B |
| live artifact | 44,016 B | 44,048 B | +32 B |

The reserved stack remains 4,096 bytes and the largest attributed release
stack frame remains 237 bytes.

## ABI and interrupt safety

Both entry points preserve `IY`, balance every stack operation, and return with
the same ABI-visible state as the baseline.  The candidate uses only ordinary
caller-clobbered registers for working state.  It does not relocate `SP`, use
alternate registers, or add `DI`/`EI`; its interrupt assumptions are therefore
the same as the existing `LDIR` presenter.

## Validation performed

- Release build: passed.
- Live benchmark build: passed.
- Release/live 153,600-byte RAM checks with 4,096-byte reserved stack: passed.
- Host arbitrary-palette framebuffer exactness: passed.
- Exact CEmu A/B by the parent integration pass: hashes passed; mean render
  regressed by 0.179% and presenter work regressed by 2.27%.
