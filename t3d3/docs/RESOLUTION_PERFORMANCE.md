# Resolution performance report

Build `0x26081128` keeps 80x60 as the development default and adds exact
assembly scan/fill and reduced portal composition on top of `0x26081117`. The
64x48 reference and experimental 160x120 modes remain available. All modes keep
the same 4:3 field of view.

The measurements use the supplied TI-84 Plus CE ROM in CEmu, the deterministic
854-frame route, 16 warm-up frames, and ten excluded instrumented detail
frames. Each configuration records its logical dimensions and presenter scale
in the benchmark header.

## Results

| Build | Layout | Average | Median | 1% low | Mean frame |
|---|---|---:|---:|---:|---:|
| `0x26081107` | No bodies | 31.313 FPS | 32.817 FPS | 16.930 FPS | 31.935 ms |
| `0x26081111` | No bodies | 31.771 FPS | 34.187 FPS | 16.576 FPS | 31.475 ms |
| `0x26081117` | No bodies | 31.997 FPS | 34.420 FPS | 16.634 FPS | 31.253 ms |
| `0x26081128` | No bodies | 34.249 FPS | 36.288 FPS | 17.709 FPS | 29.198 ms |
| `0x26081107` | Eight cubes direct | 21.964 FPS | 21.501 FPS | 11.903 FPS | 45.530 ms |
| `0x26081111` | Eight cubes direct | 22.121 FPS | 21.860 FPS | 11.927 FPS | 45.205 ms |
| `0x26081117` | Eight cubes direct | 22.534 FPS | 22.306 FPS | 12.258 FPS | 44.377 ms |
| `0x26081128` | Eight cubes direct | 25.320 FPS | 24.472 FPS | 13.157 FPS | 39.495 ms |
| `0x26081107` | Eight cubes through portal | 22.107 FPS | 21.658 FPS | 13.545 FPS | 45.235 ms |
| `0x26081111` | Eight cubes through portal | 22.171 FPS | 21.515 FPS | 13.550 FPS | 45.103 ms |
| `0x26081117` | Eight cubes through portal | 22.630 FPS | 22.193 FPS | 13.725 FPS | 44.188 ms |
| `0x26081128` | Eight cubes through portal | 25.860 FPS | 25.822 FPS | 15.167 FPS | 38.670 ms |

All three final captures retain route fingerprint `0x90ABD6C8`, four portal
crossings, all 854 per-frame simulation hashes, and every logical/presented
section hash against build `0x26081117`. Average FPS improves by 7.04%, 12.36%,
and 14.27%. In portal-eight, mean render time falls from 39.103 to 36.001 ms
and mean update time from 5.072 to 2.656 ms.

The accepted assembly path walks a complete active two-edge interval per call,
including clipping, shade selection, and span fill. Separate kernels cover
full flat-cube silhouettes and half/quarter destination faces; reduced spans
are clamped before downsampling, and an assembly compositor expands the packed
scratch plane only through the exact aperture. A shared-edge cache and an
earlier per-row assembly helper were measured and rejected because they
regressed the portal-eight route.

The current presenter paths are:

- 64x48 uses the two-buffer dirty 5x presenter.
- 80x60 uses the default two-buffer dirty 4x presenter.
- 160x120 uses a full 2x presenter.

The 80x60 presenter keeps an exact logical-frame cache for each GraphX draw
buffer. It now compares sixteen logical pixels at a time and expands changed
groups into 64x4 physical blocks. This halves group-loop overhead. It can copy
more pixels for a small isolated change, which is why the no-body 1% low is
slightly lower even though average and median performance improve.

Cube LOD now uses the camera's body-render candidate count. Four or fewer cubes keep exact
projected faces until four world units; five or more use the proven three-unit
cutoff. A global four-unit cutoff was measured and rejected: it reduced the
eight-cube-through-portal route to 18.961 FPS. The adaptive version restores
22.171 FPS while giving normal sparse scenes the requested longer detail range.

Portal LOD already uses exact aperture area with hysteresis. Counter captures
confirm distant apertures render at half resolution, very small or oblique
apertures reach quarter resolution, and near/full-screen portals remain full
resolution. Width and height thresholds are now resolution-normalized, and the
half/quarter scratch buffer clears only the aperture rectangle rather than its
entire allocation.

A matching 160x120 shortcut was also implemented and measured. Two 19,200-byte
logical caches do not fit cleanly in the standard CEdev runtime layout. A
cache-free variant instead compared the logical frame against the already
expanded LCD buffer, but scanning all 19,200 samples every frame cost more than
the full unrolled 2x presenter: averages fell to 15.155, 12.248, and 12.185 FPS.
That experiment was rejected and removed. At 160x120 the full presenter remains
faster; a useful dirty design will need producer-side dirty tiles or explicit
damage tracking so unchanged pixels are never scanned.

## Memory boundary

| Mode | Resident program | BSS | Stack reserve | Total | Remaining |
|---|---:|---:|---:|---:|---:|
| 64x48 reference | approximately 55 KiB | 38,935 B | 4,096 B | approximately 98 KiB | approximately 55 KiB |
| 80x60 default | 54,514 B | 45,019 B | 4,096 B | 103,629 B | 49,971 B |
| 160x120 | 55,409 B | 55,756 B | 4,096 B | 115,261 B | 38,339 B |

A true 320x240 logical mode is not included. Its root color frame alone is
76,800 bytes, the half-resolution portal scratch is 38,400 bytes, and the
current projection/edge tables are about 24 KiB. With roughly 56 KiB of
resident program code and a 4 KiB stack, those items already exceed the
153,600-byte safe runtime budget before render layers, physics, level data, or
other state are counted. Native logical rendering therefore requires the
planned full-RAM takeover or a different in-place/tiled portal architecture.

## Calculator builds

Interactive builds are emitted as:

- `bin/T3D3DEV.8xp`: default 80x60.
- `bin/T3D3R60.8xp`: preserved 64x48 reference; `make reference64` rebuilds it.
- `bin/T3D3R80.8xp`: superseded pre-default 80x60 reference.
- `bin/T3D3R160.8xp`: experimental 160x120.

Each layout under `benchmark-results/resolution-26081128/80x60` also
contains a hardware-safe `T3D3LIVE` benchmark and its split AppVars. Transfer
all `T3D3LIVE.8xp*` files from one selected directory, run `T3D3LIVE`, then
transfer the resulting `T3D3LIV` AppVar back to the PC for decoding. Test one
configuration at a time because the split variable names are shared.

The current supplied-ROM matrix can be repeated with:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run-resolution-benchmarks.ps1 -Resolutions 80
```
