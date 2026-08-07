# True3D exact low-risk prototypes

These experiments were snapshotted from the in-progress True3D benchmark tree on
2026-08-06.  They do not modify `true3d/src`, and no CEmu run was started before
the shared baseline was captured.

Baseline source hashes:

- `engine.c`: `450DAA20F8EB8524024321AAD8A8F6AB2E1553B21F9780423F8FE59CF7E49613`
- `present.s`: `60099156D0FD773D61CD5837C767D7C3FE8400FE070A9AF324CB22742E36ED4A`

## A: one overlapping LDIR per expanded row

Directory: `overlap-ldir`

The original presenter expands one 320-byte physical row, then issues four
separate 320-byte `LDIR`s in 64-by-48 mode or nine in 32-by-24 mode.  The
prototype points `HL` at the completed row, leaves `DE` at the next row, and
uses one forward-overlapping transfer:

- 64-by-48: `BC = 1280`, producing the four remaining rows.
- 32-by-24: `BC = 2880`, producing the nine remaining rows.

`LDIR` advances source and destination together.  Once the first 320 bytes have
been copied, its source is the row it just completed, so the same pixels repeat
until the full block is filled.

Static release deltas:

| Item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| `present_low_frame_fast` | 103 B | 58 B | -45 B |
| `present_low_frame_32_fast` | 190 B | 70 B | -120 B |
| total `.text` | 0x6E31 | 0x6D8C | -165 B |
| release AppVar | 29,253 B | 29,089 B | -164 B |
| live benchmark AppVar | 41,526 B | 41,362 B | -164 B |
| BSS | 0x52AA | 0x52AA | unchanged |

Dynamic setup reduction, excluding the unchanged byte-transfer work:

- 64-by-48: three removed seven-instruction copy setups per logical row, or
  1,008 fewer executed setup instructions per frame.
- 32-by-24: eight removed seven-instruction copy setups per logical row, or
  1,344 fewer executed setup instructions per frame.

The number of direct expansion stores and the number of bytes transferred by
`LDIR` are unchanged.  A host model compared the old repeated-copy algorithm
with the overlapping algorithm for 1,000 random rows at both 5x and 10x vertical
expansion; every byte matched.

Expected exactness: bit-identical.  Remaining validation is a CEmu and hardware
frame-hash run after the shared baseline, principally to confirm LCD VRAM
read-after-write behavior during an overlapping `LDIR`.

## B: cache portal-aperture pointers

Directory: `aperture-pointer-cache`

The original `fill_polygon` caches two one-byte polygon indices.  On every host
wall row it reconstructs `&layer->polygon[index]`; `DrawPolygon` is 151 bytes,
so the compiler emits `__imulu(index, 151)` inside the row-by-aperture loop.

The prototype caches the two `DrawPolygon *` values during aperture discovery.
The hot loop then loads and increments those pointers directly.  It pays at
most two `__imulu(index, 3)` calls while initially storing matching pointers,
instead of as many as 96 `__imulu(index, 151)` calls for two portals across 48
rows.

Static release deltas:

| Item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| `render_camera` | 0x122A | 0x123D | +19 B |
| release AppVar | 29,253 B | 29,273 B | +20 B |
| render assembly lines | 2,379 | 2,381 | +2 |
| static stride-151 sites in `render_camera` | 6 | 4 | -2 |
| static push/pop/PEA sites | 331 | 323 | -8 |
| `render_camera` stack | 162 B | 162 B | unchanged |
| BSS | 0x52AA | 0x52AA | unchanged |

With benchmark instrumentation enabled, compiler allocation improves further:

| Item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| instrumented `render_camera` | 0x1A91 | 0x1A69 | -40 B |
| live benchmark AppVar | 41,526 B | 41,486 B | -40 B |
| instrumented stack | 172 B | 172 B | unchanged |
| instrumented BSS | 0x5308 | 0x5308 | unchanged |

Expected exactness: bit-identical.  The cached pointers refer to the same static
render-layer polygons, preserve their index order, and remain valid because
`fill_polygon` only writes framebuffer pixels.  CEmu hashes and timing remain to
be run after the root baseline is available.

## Suggested integration order

1. Integrate overlapping `LDIR`; it is smaller in every build and removes work
   from every frame.
2. Integrate aperture pointer caching; judge it mainly on portal-fill time and
   portal-heavy live frames, not on normal rooms without a visible aperture.
3. Require identical logical-frame hashes, physical-frame hashes, portal state,
   and benchmark route completion before retaining either change.
