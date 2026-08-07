# Exact edge-divider experiment

## Verdict

Reject and keep the root renderer on the original CRT division fallback.
The specialized divider is exact, but the measured render time is neutral to
very slightly worse.  This area accounts for too little of a frame (only
3--11 calls in the traced frames) to justify more code or a large reciprocal
table.

The candidate remains isolated in this directory for auditability.  The root
source was not changed by this experiment.

## Measured result

The candidate was integrated temporarily on top of pass 3 and exact-tested in
CEmu by the parent task, then reverted:

| build | mean render time | change |
|---|---:|---:|
| pass-3 baseline | 69.136 ms | -- |
| exact assembly divider | 69.144 ms | +0.008 ms (+0.012%) |

Rendered output matched exactly.  The individual profiler phases were also
effectively neutral/slightly worse (about +0.09 ms when their changes were
aggregated).  This confirms that the C-call boundary and setup cost erase the
small saving inside a fallback that runs only a few times per frame.

## Candidate method

`src/edge_divide.s` implements the fallback quotient

```text
truncate_toward_zero(delta_x * 256 / delta_y)
```

with a specialized restoring divider:

- `delta_y` is positive and at most 2,097,152.
- `abs(delta_x) << 8` is at most `2^29`.
- Two known-zero leading iterations are removed, leaving 30 iterations.
- The remainder is always below `delta_y`; after its next shift it is below
  `2^22`, so it fits exactly in one 24-bit ADL register.
- Magnitude division followed by signed negation reproduces C truncation
  toward zero.

The OS CRT unsigned core always performs 32 iterations and carries a 32-bit
remainder.  Its loop executes 12--13 instructions per bit (384--416 loop
instructions).  The specialized loop executes 7--8 instructions per bit
(210--240 loop instructions), a static loop reduction of roughly 37--45%.
The generated call-site/prologue cost and very low call count prevent that
local reduction from improving a complete frame.

## Exactness checks

Run with the bundled workspace Python:

```powershell
python check_exact.py
```

Recorded result:

```text
exact quotient cases: 370,291 passed
random category sample: {'short': 28, 'tall': 246137, 'wide': 3785, 'table': 50}
raster cases: 20,000 passed
raster fallback edges exercised: 104,828
raster SHA-256: 1896d1409083f66a8b76f69b71bc3cfb630a0eff899a70d8b23e47f27b1c88c0
```

The quotient corpus covers signed extrema, powers of two and adjacent values,
all fallback thresholds, 250,000 uniform random pairs, and 100,000
fallback-biased pairs.  The raster corpus compares complete sampled span
hashes at every LOD shift.

## Generated code and RAM

| configuration | baseline | candidate | delta |
|---|---:|---:|---:|
| release resident program | 29,367 B | 29,504 B | +137 B |
| release `.text` | 28,399 B | 28,536 B | +137 B |
| release `.bss` | 21,162 B | 21,162 B | 0 B |
| release budget headroom | 98,975 B | 98,838 B | -137 B |
| release AppVar | 29,443 B | 29,581 B | +138 B |
| live resident program | 41,829 B | 41,944 B | +115 B |
| live `.text` | 40,283 B | 40,398 B | +115 B |
| live `.bss` | 21,256 B | 21,256 B | 0 B |
| live budget headroom | 86,419 B | 86,304 B | -115 B |
| live AppVar | 41,906 B | 42,020 B | +114 B |

The assembly routine is 99 bytes.  The release `rasterize_polygon` body grows
from `0xA49` to `0xA6F` (+38 bytes); the live body grows by 16 bytes.  Release
raster stack attribution changes 83 to 82 bytes and live changes 97 to 82
bytes, while the largest program stack frame is unchanged.

The original fallback generates calls to `__lshl` and signed `__ldivs` (whose
unsigned core runs 32 restoring iterations).  The candidate replaces those
with one C-ABI call to the custom routine; that routine itself calls
`__frameset0` and runs 30 specialized iterations.

## Other exact approaches considered

- Converting the C expression to explicit unsigned magnitude division still
  uses the same 32-iteration CRT core, adds sign helpers, and grows release by
  71 resident bytes and live by 91 bytes.  It was rejected without runtime
  testing.
- An exact-denominator reciprocal table for `dy=256..32759` alone needs
  32,504 three-byte entries (97,512 bytes).  A 24-bit reciprocal is only an
  estimate: exactness still needs a 46-bit multiply and a quotient-times-
  denominator correction.  It would nearly exhaust release headroom and does
  not fit the live benchmark's 86,419-byte headroom.
- A normalized smaller reciprocal table discards denominator bits.  Restoring
  exact semantics then needs potentially multiple corrections or a wider
  multiply, removing its advantage at only 3--11 calls per frame.
- A quotient lookup cannot cover both the 4,194,305 possible signed deltas and
  2,097,152 positive denominators within the RAM budget.

## Optional cause diagnostic

`../edge-divider-cause-instrumented` is an isolated, render-identical live
build that packs the short/tall/wide cause counts into the existing fallback
field.  Its README explains the bit packing.  It is useful only if future
geometry changes make fallback division materially hotter; it is not needed
for the current optimization pass.
