# Projection-math specialization

## Decision: reject

The six-`MLT` signed projection primitive is exact, but the real renderer is
slower with it.  On the deterministic CEmu live route, layered on top of the
direct-depth projection table, the scalar candidate changed:

| Metric | CRT baseline | Six-`MLT` candidate | Change |
| --- | ---: | ---: | ---: |
| Mean frame time | 68.772 ms | 69.126 ms | +0.354 ms (+0.515%) |
| Mean FPS | 14.54 | 14.47 | -0.07 FPS |

Logical-frame, presented-frame, engine-state, section, portal-crossing, and
LOD hashes remained exact.  This is therefore a clean performance rejection,
not a rendering-correctness failure.  The production root was reverted and
must retain the compiler CRT multiply/shift path.

The likely cause is straightforward: CEdev's long multiply helper is already
well optimized.  Replacing each helper pair with six native byte multiplies
also introduces byte-column assembly, four local product bytes, fixed shift
work, and C ABI setup.  Removing helper names from the relocation table did
not remove enough actual work to pay for those costs.

## Variants investigated

### Scalar primitive (calculator-tested, rejected)

The first candidate replaced each expression

```c
((int32_t)value * scale) >> 6
```

with one exact assembly call.  `project_camera_point` stopped referencing its
two `__lmulu` and two `__lshrs` helpers, but invoked the 229-byte primitive
twice per projected point.

Release code changed as follows:

| Routine set | Bytes |
| --- | ---: |
| Original `project_camera_point` | 325 |
| Scalar-candidate `project_camera_point` | 284 |
| Scalar assembly primitive | 229 |
| Net resident code | +188 |

This is the exact variant measured above.  It must not be integrated.

### Fused pair (compile/host-tested only)

The source retained in this experiment is a more aggressive diagnostic
variant.  It computes X and Y in one ABI call and also fuses the projection
centers, signed clamp, and optional half-resolution shift.  It removes from
the C wrapper:

- two `__lmulu` calls;
- two `__lshrs` calls;
- four `__lcmps` calls;
- four `__setflag` calls;
- one `__lsub` call;
- two `half_projected` calls.

The release C wrapper falls from 325 to 53 bytes and calls one 396-byte
assembly routine, for a net 124-byte increase.  This fused variant was not
run in CEmu because the underlying six-`MLT` kernel had already lost the exact
calculator A/B and the parent optimization pass was closed.  It is retained
only as an isolated experiment; it is not an integration recommendation.

## Exactness and bounds

`test_projection_mul.c` independently models:

- sign extension from signed 24-bit camera coordinates to signed 32-bit;
- the low 32 bits of the signed-by-unsigned product;
- arithmetic right shift by six;
- X-center addition and Y-center subtraction;
- signed clamp to `[-1048576, 1048576]`;
- arithmetic signed-24 shift for half-resolution rendering.

The oracle passed **8,195,096 checks**:

- the Cartesian product of important signed-24 and unsigned-16 boundaries;
- every value from -262144 through 262143 at eight representative scales;
- two million random full-domain signed-24/unsigned-16 multiplies;
- two million random fused X/Y projections across both render shifts.

Build and run it with:

```powershell
C:\msys64\ucrt64\bin\gcc.exe -std=c11 -O2 -Wall -Wextra -Werror test_projection_mul.c -o bin\test_projection_mul.exe
.\bin\test_projection_mul.exe
```

Observed output:

```text
PASS: 8195096 exact projection multiply/pair checks
```

The exhaustive interval is wider than the proven one-recursion renderer
bound.  A room coordinate and root camera coordinate are signed 16-bit; one
portal transform can enlarge a destination vertex-to-camera coordinate to at
most 131070.  Enumerating every allowed yaw and pitch gives a maximum camera
basis L1 norm of 445, so a transformed component is bounded below 227838
(plus only a few fixed-rounding units), safely inside +/-262144.  The assembly
model also passes random values across the complete signed-24 domain.

Projected vertices always have depth at least the 32-unit near plane.  The
largest scale actually used by projection is therefore 21504, although the
primitive and oracle preserve the existing result for every unsigned-16
scale through 65535.

## Build and memory deltas for the retained fused diagnostic

These compile-only A/B numbers use the same isolated pre-direct-table source
snapshot; only projection math differs.

| Build | Baseline | Fused diagnostic | Delta |
| --- | ---: | ---: | ---: |
| Release `.8xp` | 31,279 B | 31,403 B | +124 B |
| Release resident program | 31,202 B | 31,326 B | +124 B |
| Release `.bss` | 21,162 B | 21,162 B | 0 B |
| Release budgeted RAM | 56,460 B | 56,584 B | +124 B |
| Live-autotest `.8xp` | 43,447 B | 43,575 B | +128 B |
| Live-autotest resident program | 43,370 B | 43,499 B | +129 B |
| Live-autotest `.bss` | 21,256 B | 21,256 B | 0 B |
| Live-autotest budgeted RAM | 68,722 B | 68,851 B | +129 B |

The largest reported stack frame remains 237 bytes.  The C wrapper's static
frame falls from 14 bytes to zero; the assembly routine reserves four local
product bytes.

## Follow-up guidance

- Do not optimize this path by counting CRT helper symbols alone; only a full
  rendered-route A/B is decisive.
- Do not integrate either six-`MLT` variant without a new exact benchmark.
- A future projection attempt should eliminate more surrounding work than the
  multiply alone—for example, a renderer-specific register pipeline that
  avoids the C ABI entirely—or target the transform/dot-product batch as one
  fused operation.
- Any future candidate must retain low-32 overflow behavior, negative
  arithmetic rounding, clamp order, and half-resolution rounding.  Replacing
  the expression with a mathematically wider product is not bit-equivalent.
