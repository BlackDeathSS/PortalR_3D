# CEmu grid-stepper optimization pass

Inputs captured on CEmu OS 5.4.0:

- `static/P3DRES-cemu-os540.8xv`
- `live/P3DLIVE-cemu-os540.8xv`

The immediate comparison baseline is
`../optimized-portal-transform-2026-07-29`.

## Validation

- Both TI wrapper checksums and payload CRCs are valid.
- Both reports contain the expected stable build ID `26072903`.
- Static suite fingerprint is `B203060E`; all six scene configurations and
  framebuffer hashes match build `26072902`.
- Live route fingerprint is `D5EE967A`; all 971 camera/input states, all 18
  endpoint framebuffer/state hashes, final framebuffer hash `88062001`, and
  final route-state hash `73435A77` match.
- The live route records all six expected portal crossings.
- Both reports retain 80 logical columns, four-pixel columns, 8-row textures,
  and portal depth six.

## Clean timing

| Metric | Build 26072902 | Grid stepper 26072903 | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 63.239 ms | 62.966 ms | -0.273 ms (-0.43%) |
| Live render mean | 62.848 ms | 62.574 ms | -0.274 ms (-0.44%) |
| Live average FPS | 15.813 | 15.882 | +0.43% |
| Live 1% low FPS | 11.927 | 11.923 | -0.03% |
| Static six-scene mean | 57.207 ms | 56.849 ms | -0.358 ms (-0.63%) |
| Static wait mean | 2.126 ms | 2.025 ms | -0.101 ms |
| Static background mean | 15.196 ms | 15.103 ms | -0.093 ms (-0.62%) |
| Static column mean | 39.502 ms | 39.503 ms | +0.001 ms |

The live gain is entirely in the render phase; update and swap move by less
than 0.001 ms. The 1% low and worst-frame changes are effectively neutral.

## Cardinal versus non-cardinal static scenes

`NEAR_WALL`, `MID_DIRECT`, `PORTAL_CHAIN`, `PORTAL_WIDE`, and `CUSTOM_PAIR`
use cardinal camera headings. `LONG_DDA` uses a 33.75-degree heading.

| Group and phase | Build 26072902 | Grid stepper 26072903 | Change |
| --- | ---: | ---: | ---: |
| Cardinal background | 13.086 ms | 12.965 ms | -0.121 ms (-0.92%) |
| Cardinal columns | 42.059 ms | 42.064 ms | +0.005 ms |
| Cardinal total | 57.332 ms | 57.245 ms | -0.087 ms |
| Non-cardinal background | 25.749 ms | 25.791 ms | +0.042 ms |
| Non-cardinal columns | 26.718 ms | 26.699 ms | -0.019 ms |
| Non-cardinal total | 56.583 ms | 54.871 ms | -1.713 ms |

The apparent non-cardinal total gain is not renderer work: that scene's wait
time falls by 1.572 ms while background and columns remain neutral. The
repeatable phase evidence is the 0.121 ms cardinal-background reduction.

## Matched fine traces

Fourteen of 18 live diagnostic replays selected exactly the same camera state
in both captures:

| Category | Build 26072902 | Grid stepper 26072903 | Change |
| --- | ---: | ---: | ---: |
| Administration | 7.592 ms | 7.468 ms | -0.124 ms (-1.64%) |
| Background | 18.197 ms | 18.160 ms | -0.037 ms (-0.20%) |
| DDA | 11.819 ms | 11.749 ms | -0.070 ms (-0.59%) |
| Portal trace | 8.026 ms | 8.054 ms | +0.028 ms (+0.35%) |
| Wall draw | 12.748 ms | 12.680 ms | -0.068 ms (-0.53%) |
| Portal draw | 4.752 ms | 4.796 ms | +0.044 ms (+0.92%) |

Two matched traces are exactly cardinal. Their background mean falls from
13.611 ms to 13.245 ms (-0.366 ms, -2.69%); the 12 non-cardinal matched traces
move from 18.962 ms to 18.979 ms (+0.09%). This agrees with the static
cardinal-scene split.

Fine traces remain approximate: trace intrusion reaches 62.4% and
corrected-category residual reaches 8.9%. Clean live timing and the coarse
static background phase are the primary evidence.
