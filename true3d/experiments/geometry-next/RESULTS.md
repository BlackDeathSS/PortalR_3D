# Geometry-next isolated results

Frozen baseline: post-pass15 build `0x26080601`, 854-frame deterministic
live route, 844 clean frames.

| Candidate | Mean frame | Change | Mean FPS | 1% low | Exact | Size effect |
|---|---:|---:|---:|---:|---|---:|
| Baseline | 42.150 ms | - | 23.72 | 14.94 | yes | 43,698 B |
| Remove near-clip source copy | 42.118 ms | -0.08% | 23.74 | 14.95 | yes | -22 B code, -72 B BSS |
| Depth-1 immediate fill | 41.788 ms | -0.86% | 23.93 | 15.00 | yes | -120 B code |
| Depth-1 fused scan/fill | 41.539 ms | -1.45% | 24.07 | 15.24 | yes | +2,272 B code |
| Reuse cached face projections | 41.488 ms | -1.57% | 24.10 | 15.21 | yes | +558 B code, -72 B BSS |
| Projection reuse + fused depth-1 | 40.835 ms | -3.12% | 24.49 | 15.54 | yes | +2,962 B code |

The face-projection candidate changes partial room-face clipping so only the
two near-plane intersections are projected. Vertices already in front of the
near plane reuse `screen_vertices[face->vertex[index]]`, which is identical to
projecting the same transformed vertex again. Its detailed root-geometry mean
fell from 16.647 ms to 16.049 ms; portal geometry fell from 9.723 ms to
9.641 ms.

The depth-1 specialization is valid because `PORTAL_RECURSION_LIMIT == 1`:
those cameras never collect apertures. It prepares one polygon at a time and
consumes each two-chain span immediately into the full-resolution target or
the portal LOD buffer, preserving face order, horizon shading, clip rows, and
all pixels.

Rejected exact candidates:

- direct-mapped edge-step cache: 42.477 ms (slower);
- fused clipping/projection bounds: 42.190 ms (slower);
- pre-rasterized root apertures plus direct root scan/fill: 42.674 ms (slower).

Every retained and rejected timing above completed the same route, final
state, portal crossings, and per-frame logical output hashes. Frozen source,
RAM dumps, decoded JSON, CSV, and comparison reports live in the named
subdirectories beside this file.
