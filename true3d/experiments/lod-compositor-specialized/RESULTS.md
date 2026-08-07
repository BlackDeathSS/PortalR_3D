# Specialized portal LOD compositor

This is an isolated exact prototype based on the integrated overlapping-LDIR and
aperture-pointer baseline.  It does not modify `true3d/src`, and no CEmu run was
started.

Baseline `engine.c` SHA-256:
`3E6FA02D72AE0A69A6BADB8E7D005E3ACFAA8A432244282D46FC2C32188F82DD`.

Candidate `engine.c` SHA-256:
`C31F08936FC8A94797ECBF0DC7D506ED2B573D64CF4EB2BEE8420F63DD9288C9`.

## Change

The baseline compositor evaluates `column >> layer->lod_shift` for every
destination pixel.  The eZ80 compiler emits a call to `__ishru` inside that
pixel loop and reconstructs source and destination addresses on every
iteration.

The prototype dispatches once on the only two reachable reduced-detail states:

- `lod_shift == 1`: align the clipped left edge, then copy one source byte to
  two consecutive destination bytes.
- `lod_shift == 2`: align the clipped left edge, then copy one source byte to
  four consecutive destination bytes.

Only the at-most-one-pixel or at-most-three-pixel clipped prefixes and suffixes
use scalar handling.  Source and destination pointers otherwise advance
linearly.

## Generated hot-loop delta

The dominant baseline pixel loop contains 39 visible eZ80 instructions per
destination pixel plus one `__ishru` helper call.

| Main loop | Visible instructions | Pixels produced | Instructions/pixel | Shift helper |
|---|---:|---:|---:|---:|
| Baseline variable shift | 39 | 1 | 39.0 | 1 per pixel |
| Specialized half LOD | 17 | 2 | 8.5 | none |
| Specialized quarter LOD | 34 | 4 | 8.5 | none |

This is a 78% reduction in visible main-loop instructions per destination pixel,
before counting the removed helper body.  Fixed shifts remain only in row setup.
For narrow clipped spans, prefix/suffix and per-row setup reduce the percentage
gain, so the live benchmark must still decide whether the larger code is worth
retaining.

## Build and memory delta

Both release and live benchmark builds pass.

| Release item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| `render_camera` text | 0x123D | 0x138D | +336 B |
| total text | 0x6D9F | 0x6EEF | +336 B |
| resident program | 29,031 B | 29,367 B | +336 B |
| release AppVar | 29,107 B | 29,443 B | +336 B |
| BSS | 21,162 B | 21,162 B | unchanged |
| `render_camera` stack | 162 B | 162 B | unchanged |
| budget headroom | 99,311 B | 98,975 B | -336 B |

| Instrumented item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| `render_camera` text | 0x1A69 | 0x1CB1 | +584 B |
| total text | 0x9B13 | 0x9D5B | +584 B |
| resident program | 41,245 B | 41,829 B | +584 B |
| live benchmark AppVar | 41,322 B | 41,906 B | +584 B |
| BSS | 21,256 B | 21,256 B | unchanged |
| `render_camera` stack | 172 B | 172 B | unchanged |
| budget headroom | 87,003 B | 86,419 B | -584 B |

The instrumented build grows more because its portal-composite counter logic is
present in each specialized branch.  Runtime counter values are unchanged.

## Exactness validation

`check_exact.py` compares the baseline mapping with the two specialized paths.
It passed:

- 225,024 exhaustive combinations of render width, render row, LOD shift, and
  every valid clipped `[left, right]` span.
- 20,000 randomized full clipped layers, including invalid/empty rows, random
  source pixels, and random pre-existing destination pixels to confirm that
  bytes outside each aperture remain untouched.

The test covers 32x24 and 64x48 render modes and both reachable LOD shifts.
The benchmark pixel counter is charged by the same clipped width in every path.

## Recommendation

The static inner-loop result is strong enough for a serialized CEmu A/B after
the root baseline work is complete.  Judge it on `portal_fill` time and scenes
that actually enter LOD 1 or LOD 2; ordinary rooms and full-resolution portals
cannot benefit.  Retain only if the timed reduction justifies 336 bytes of
release code.
