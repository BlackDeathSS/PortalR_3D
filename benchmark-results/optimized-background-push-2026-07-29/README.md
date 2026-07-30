# CEmu background stack-PUSH pass

Inputs captured on CEmu OS 5.4.0:

- `live/P3DLIVE-cemu-os540.8xv`
- `static/P3DRES-cemu-os540.8xv`

Both TI wrappers, payload CRCs, record layouts, and the live route-state hash
validate. The comparison baseline is
`../matched-cemu-calc-2026-07-29-16x8`.

## Results

| Metric | Prior CEmu | Current CEmu | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 68.107 ms | 63.653 ms | -4.454 ms (-6.54%) |
| Live average FPS | 14.683 | 15.710 | +7.00% |
| Live 1% low FPS | 10.852 | 11.893 | +9.59% |
| Live worst frame | 94.879 ms | 84.808 ms | -10.071 ms |
| Static six-scene mean | 65.930 ms | 57.272 ms | -8.658 ms (-13.13%) |
| Static mean-derived FPS | 15.168 | 17.461 | +15.12% |
| Static background mean | 20.581 ms | 15.199 ms | -5.382 ms (-26.15%) |
| Static column mean | 39.974 ms | 40.020 ms | +0.046 ms (+0.115%) |

The static background saving is stable across all six scenes: 5.314–5.432 ms.
On the six live sections whose detailed replay selected exactly the same route
state in both builds, corrected background time falls from 25.976 ms to
20.625 ms, a 5.351 ms (20.6%) reduction. Corrected DDA, portal trace, wall
draw, and portal draw changes are all below 2.6%; those small changes should
not be interpreted as engine speedups because timer-switch calibration changed
from 0.984 to 1.000 tick.

Every static framebuffer hash matches. Every live section framebuffer and
state hash matches, the route fingerprint is still `D5EE967A`, all 971
camera/input states compare exactly, and the route still has six portal
crossings. The suite/configuration also remains at 80 logical columns,
four-pixel columns, 8-row textures, and portal depth six.

## Historical fingerprint note

The uploaded reports identify as `4153B687` (static) and `16F15C64` (live).
The old fingerprint implementation hashed import stubs after the calculator
loader patched them, while the documented values were calculated from the
unpatched ELF. That explains the mismatch. The deterministic output, route,
configuration, and measured background improvement all match the intended
optimization. New reports use the stable source-controlled build ID instead.

The static fine-trace categories remain approximate: instrumentation intrusion
reaches 62.4%, corrected-category residual reaches 7.9%, and some portal-draw
samples clamp after switch correction. Clean frame and coarse background/column
measurements are the primary comparison.
