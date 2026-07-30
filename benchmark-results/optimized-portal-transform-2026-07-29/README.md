# CEmu portal-transform optimization pass

Inputs captured on CEmu OS 5.4.0:

- `static/P3DRES-cemu-os540.8xv`
- `live/P3DLIVE-cemu-os540.8xv`

The immediate comparison baseline is
`../optimized-background-push-2026-07-29`.

## Validation

- Both TI wrapper checksums and payload CRCs are valid.
- Both reports contain the expected stable build ID `26072902`.
- Static suite fingerprint is `B203060E`; all six scene configurations and
  framebuffer hashes match the previous pass.
- Live route fingerprint is `D5EE967A`; all 971 camera/input states, all 18
  endpoint framebuffer/state hashes, the final framebuffer hash `88062001`,
  and the final route-state hash `73435A77` match.
- The live route records exactly six expected portal crossings.
- Both reports retain 80 logical columns, four-pixel columns, 8-row textures,
  and portal depth six.

## Headline timings

| Metric | Background-PUSH pass | Portal-transform pass | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 63.653 ms | 63.239 ms | -0.414 ms (-0.65%) |
| Live average FPS | 15.710 | 15.813 | +0.65% |
| Live 1% low FPS | 11.893 | 11.927 | +0.28% |
| Live worst frame | 84.808 ms | 84.320 ms | -0.488 ms |
| Static six-scene mean | 57.272 ms | 57.207 ms | -0.065 ms (-0.11%) |
| Static six-scene column mean | 40.020 ms | 39.502 ms | -0.518 ms (-1.29%) |
| Static portal-scene column mean | 46.303 ms | 45.263 ms | -1.040 ms (-2.25%) |

The clean static total is partly hidden by run-to-run display-wait movement:
mean wait rises by 0.451 ms while column work falls by 0.518 ms. The three
non-portal scene column measurements are unchanged within 0.008 ms; the full
column gain occurs in the three portal scenes.

Twelve live diagnostic replays selected exactly the same state in both
captures. Across those matched states, corrected portal-trace time falls from
7.708 ms to 7.118 ms, saving 0.590 ms (7.65%). The five matched states with
75-99 portal transforms fall from 13.318 ms to 12.079 ms, saving 1.239 ms
(9.30%). The three static portal scenes similarly show corrected portal-trace
time falling from 10.501 ms to 9.616 ms (8.43%).

Fine-trace categories remain approximate: trace intrusion reaches 62.4%,
corrected-category residual reaches 8.5%, and switch calibration changed from
1.000 to 0.984 tick. Clean live timing and the coarse static column phase
confirm the optimization independently of those corrected categories.
