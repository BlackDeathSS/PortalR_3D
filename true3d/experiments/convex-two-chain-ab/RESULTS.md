# True3D convex two-chain raster experiment

This directory is a current-root A/B candidate captured on 2026-08-06.  It
preserves the production projection lookup, presenter, aperture-pointer cache,
specialized portal LOD compositor, benchmark route, and every non-raster source
byte.  Compared with `true3d/src`, only `engine.c` and the new
`raster_two_chain_split.inc` differ.

Current-root `engine.c` SHA-256 at the final comparison:

`BD708C3C8100CB9092AAC0F06A56426B85AFE60DD4CDF7A2348F347C19BCD235`

## Design

Near-plane clipping retains the cyclic order of a convex face.  From the first
minimum-y vertex, the clockwise and counter-clockwise sides are therefore two
y-monotone chains.  The candidate keeps one active edge on each chain and
directly produces the row's minimum and maximum x intersection.

This removes the old per-polygon work that:

- cleared two 48-entry `int24_t` min/max arrays;
- visited every edge and compared every intersection against both arrays;
- multiplied each row index by three to address the arrays;
- reloaded both arrays in a second scanline pass.

The full-resolution and LOD scan loops remain separate.  Full resolution has a
compile-time step of one; LOD retains the exact sample origin and step of the
reference path.  Both retain the existing top-inclusive/bottom-exclusive edge
rule, Q8 sample centers, reciprocal/fallback edge slope, clipping, and final
ceil/floor rules.

The active x and x-advance values are native signed 24-bit values.  The host
model performs the same 24-bit wrapping.  For any edge spanning another sample,
the advance is bounded by the projected endpoint delta; a steep sub-sample edge
may truncate an unused advance, but it is replaced before the next sample.

## Exactness

Run:

```powershell
dotnet run --configuration Release --project host-check/HostCheck.csproj
```

Result:

```text
PASS seed=0x3D202608 screen=199022 near_clipped_or_projected=98941 total=297963
```

The randomized corpus covers both windings, rotated starting vertices, full,
half, and quarter sample steps, random layer clips, off-screen coordinates,
horizontal edges, Q8 sample-boundary cases, and planar quads passed through the
engine's near-plane clipping and projection math.  It compares return value,
first/last row, and every sampled left/right span.

Calculator/CEmu frame hashes are still required before production integration.
This experiment deliberately did not start CEmu.

## Current-root build comparison

The baseline was rebuilt from the byte-identical source snapshot in
`../convex-two-chain-ab-baseline-current`.

| Metric | Current root | Split two-chain | Delta |
|---|---:|---:|---:|
| release AppVar | 31,287 B | 30,293 B | -994 B |
| live AppVar | 44,016 B | 42,794 B | -1,222 B |
| release BSS | `0x82AA` | `0x818A` | -288 B |
| live BSS | `0x8308` | `0x81E8` | -288 B |
| release raster text | `0x10D3` | `0xB0A + 0x288` | -833 B |
| live raster text | `0x1262` | `0xBB0 + 0x2A0` | -1,042 B |

The generated live raster region also changed as follows:

| Static assembly measure | Current root | Split two-chain | Delta |
|---|---:|---:|---:|
| instruction lines | 1,958 | 1,508 | -450 (-23.0%) |
| call sites | 173 | 130 | -43 (-24.9%) |
| push/pop/PEA sites | 225 | 200 | -25 |
| `__imulu` sites | 16 | 7 | -9 |

These are static sites, not cycle counts.  The hot scanline path additionally
removes two six-byte scratch clears and three of the four 24-bit min/max
comparisons expected per convex row.

Stack-usage files report:

- release reference raster: 88 B;
- release candidate raster: 73 B, with a nested 34 B walker frame;
- live reference raster: 96 B;
- live candidate raster: 69 B, with a nested 34 B walker frame;
- `render_camera`: unchanged at 162 B release / 172 B live.

Treating the `.su` frames additively, the deepest raster call grows by 19 B in
release and 7 B in the live build.  BSS falls by 288 B, so total RAM remains
lower.

## Binaries

- `bin/TRUE3D06.8xp`: release candidate
- `bin/T3DLIVE.8xp`: live-benchmark candidate for CEmu/hash A/B

The most useful next decision is a timed, hash-checked live run against the
fresh baseline.  If the split version wins, delete the `#if 0` reference block
when moving the include implementation into production.  A unified two-chain
loop is roughly another kilobyte smaller but gives up the measured constant-step
full-resolution specialization, so it is not the first performance candidate.
