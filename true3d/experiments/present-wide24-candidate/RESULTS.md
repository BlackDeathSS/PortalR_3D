# Packed 24-bit presenter experiment

## Verdict

Reject.  The candidate is slower and its displayed output is not exact.  Exact
CEmu A/B measured a 5.23% presenter regression and a 1.81% complete-frame
regression.  Logical framebuffer and engine-state hashes matched, but all ten
presented-frame hashes differed.

The immediate correctness failure is now understood: in eZ80 ADL mode `MLT HL`
writes the 16-bit product back to the complete 24-bit register pair and clears
the upper byte.  It does not preserve `UHL`.  The candidate consequently
indexed address `0x000000` instead of its intended fixed table at `0xD10000`.
The host proof modeled the intended table lookup and therefore did not model
this processor side effect.

Even after correcting the address construction, the measured lookup, compare,
and branch overhead leaves no reason to retain this approach.  The parent
integration was reverted; root sources do not contain this candidate.

## Candidate method

Initialization builds a fixed 768-byte table at `0xD10000`.  Each of its 256
entries contains three copies of one palette byte.  The 64x48 presenter then
looks up one packed triplet per logical pixel, caches the previous triplet, and
emits five physical pixels with two 24-bit indexed stores.  The existing
forward-overlapping vertical `LDIR` remains unchanged.

This was meant to replace five one-byte stores and five destination increments
with two wider stores while retaining arbitrary eight-bit palette values and
the exact 5x5 expansion.

## Exact CEmu A/B

The parent task integrated only this presenter candidate over the current
two-chain pass and ran the exact ten-frame benchmark:

| metric | baseline | packed-24 candidate | change |
|---|---:|---:|---:|
| corrected presenter aggregate | 14.648 ms | 15.414 ms | +0.766 ms (+5.23%) |
| mean complete frame | 41.780 ms | 42.537 ms | +0.757 ms (+1.81%) |

- Logical framebuffer hashes: all matched.
- Engine-state hashes: all matched.
- Presented-frame hashes: 0 of 10 matched.

The displayed mismatch is deterministic and is explained by the `MLT HL`
semantics above rather than by renderer state.

## Processor-semantics finding

CEmu implements `MLT rp` by reading the selected 24-bit pair, multiplying its
low and middle bytes, and writing the resulting 16-bit value through the normal
register-pair write path.  That write zero-extends the result, so `UHL` becomes
zero.  This agrees with the observed presented hashes and table-address trace.

The relevant assumption in this experiment was therefore invalid:

```text
assumed: HL = D1:color:03 after MLT HL
actual:  HL = 00:product_hi:product_lo after MLT HL
```

Future fixed-page lookup experiments must explicitly reconstruct the upper
address byte after `MLT`, or use indexed arithmetic that never relies on the
upper byte surviving the multiply.

## Host exactness test and limitation

`check_exact.c` proves that the *intended* lookup-and-store algorithm produces
the same 320x240 framebuffer as the ordinary byte presenter:

```text
complete frame cases passed: 85792
output bytes compared: 6588825600
```

Coverage includes all 65,536 binary transition patterns tiled across a full
64x48 framebuffer, every solid eight-bit palette value, and 20,000 random
frames.  It also models the forward-overlapping 1,280-byte vertical copy.

This result is useful only as an algorithm-level proof.  It does not validate
assembly register semantics and specifically failed to model `MLT` clearing
the upper register byte.  The exact CEmu presented-frame hashes are the
authoritative result.

## Code and RAM

The 768-byte lookup table is at a fixed address and therefore is not counted in
the linker's `.bss`; the effective RAM totals below include it explicitly.

| configuration | baseline | candidate | delta |
|---|---:|---:|---:|
| release resident program | 30,217 B | 31,390 B | +1,173 B |
| release `.bss` | 33,162 B | 33,162 B | 0 B |
| release fixed table | 0 B | 768 B | +768 B |
| release effective RAM total | 67,475 B | 69,416 B | +1,941 B |
| release headroom to 96 KiB | 30,829 B | 28,888 B | -1,941 B |
| release headroom to 150 KiB hard limit | 86,125 B | 84,184 B | -1,941 B |
| release AppVar | 30,293 B | 31,467 B | +1,174 B |
| live resident program | 42,717 B | 43,890 B | +1,173 B |
| live `.bss` | 33,256 B | 33,256 B | 0 B |
| live fixed table | 0 B | 768 B | +768 B |
| live effective RAM total | 80,069 B | 82,010 B | +1,941 B |
| live headroom to 96 KiB | 18,235 B | 16,294 B | -1,941 B |
| live headroom to 150 KiB hard limit | 73,531 B | 71,590 B | -1,941 B |
| live AppVar | 42,794 B | 43,966 B | +1,172 B |

The reserved stack remains 4,096 bytes.  The candidate's fixed table begins at
`0xD10000`; the linked baseline BSS ends at `0xD0D450`, so the regions do not
overlap.

## ABI and interrupt safety

The candidate preserves the same callee-saved registers as the baseline,
balances its stack, and uses ordinary caller-clobbered registers for temporary
state.  It does not relocate `SP` or change interrupt enable state.  Its
vertical-copy interrupt assumptions are identical to the existing `LDIR`
presenter.  These properties do not rescue the correctness or speed result.

## Validation performed

- Release build: passed.
- Live benchmark build: passed.
- Host intended-algorithm framebuffer exactness: passed.
- Exact CEmu logical and state hashes: passed.
- Exact CEmu presented hashes: failed all ten frames.
- Exact CEmu performance: regressed; candidate rejected and reverted.
