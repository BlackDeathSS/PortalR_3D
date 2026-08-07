# Exact camera-transform specialization

## Decision: accept the point and room-edge kernels

This experiment replaces only the generic fixed-point multiplies used by
`transform_point` and the three room-box edge vectors.  It keeps the same
camera coordinates, projected points, polygons, pixels, portal crossings,
and game state.

On the deterministic 854-frame CEmu live route, against the current
row-band-fill baseline:

| Metric | Baseline | Candidate | Change |
| --- | ---: | ---: | ---: |
| Clean mean frame time | 42.691 ms | 42.279 ms | -0.413 ms (-0.967%) |
| Clean average FPS | 23.42 | 23.65 | +0.23 FPS (+0.976%) |
| 1% low | 14.91 FPS | 15.03 FPS | +0.12 FPS |
| Maximum clean frame | 80.505 ms | 79.865 ms | -0.641 ms |
| Release `.8xp` | 29,835 B | 28,955 B | -880 B |
| Live-autotest `.8xp` | 41,851 B | 40,971 B | -880 B |

The decoder reports `exact_route_and_endpoint_hashes=true`.  Every section's
logical-frame, presented-frame, engine-state, room, portal-LOD, route, and
portal-crossing hashes match.  Root-geometry detail samples improve by about
1.5-2.5%; portal-geometry samples improve by about 1.7-6.0%, depending on how
many transformed portal views are present.

The accepted calculator build uses 28,878 bytes resident, 33,274 bytes of
BSS, and a 4,096-byte reserved stack: 66,248 bytes total.  Its largest static
stack frame is 233 bytes.

## Why it is exact

The old point transform performs nine generic signed 32-bit products and
then shifts each three-product dot sum by eight.  Camera basis components are
engine-generated Q8 values in `[-256, 256]`.  For a component `c`, the new
assembly uses the identity

```text
c = c0 + 256*c1,  c0 in [0,255], c1 in {-1,0,1}
```

Three native `MLT` instructions form each signed 24-by-8 product.  The
`a*c1<<8` term is added, all three 32-bit products are accumulated, and only
then is the sum shifted.  Keeping the shared fractional carry is important:
shifting each product independently would not be equivalent.

Room bounds are signed 16-bit Q8 values, so a nonnegative room extent is at
most 65,535.  Each room edge product therefore needs only two byte multiplies
plus the same `c0/c1` correction.  This path is valid for every level accepted
by the existing room format; it is not limited to integer-sized built-in
rooms.

`test_transform_math.c` passed **38,619,968** independent equality checks:

- five million random three-component dot products over the proven
  one-recursion relative-coordinate interval and every allowed coefficient;
- every extent from 0 through 65,535 crossed with every coefficient from
  -256 through 256.

The target benchmark then validates the actual assembly and ABI on CEmu.

## Additional signed-axis portal experiment: held back

A third prototype also routed portal half-width/half-height vector scaling
through the two-`MLT` kernel.  It reduced the same snapshot from 42.279 ms to
42.073 ms and removed another 256 bytes.  All ten logical-frame, presented-
frame, and engine-state endpoint hashes still matched.  However, the
benchmark's final diagnostic replay selected frame 610 instead of frame 612,
leaving one otherwise-unused portal LOD bookkeeping byte different.  The
strict decoder therefore declined the comparison.

The algebra passed the host oracle, but this extra step is intentionally not
part of the accepted source.  Re-test it only after making diagnostic-frame
selection fixed rather than timing-selected.

## Artifacts

- `results/asm-transform-pass1`: point-transform-only result.
- `results/asm-transform-pass2`: accepted point plus room-edge result.
- `results/asm-transform-pass3`: held-back signed-axis portal scaler result.
- `transform2-vs-baseline.json`: direct strict comparison with the row-band
  baseline.
