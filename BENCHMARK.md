# PortalR 3D benchmarks

The benchmark programs are separate calculator builds. They do not replace or
alter the playable `PORTAL3D` build.

## Static scene benchmark

`P3DBNCH` retains the targeted six-view regression suite.

### Run it on the calculator

1. Transfer `bin/P3DBNCH.8xp` to the calculator. Install `clibs.8xg` first if
   the CE C libraries are not already installed.
2. Run `P3DBNCH` and do not press keys while it works.
3. Wait for `Benchmark complete`. The program creates and archives the AppVar
   `P3DRES`. Its completion screen shows the report format and eight-digit
   build ID; that ID must match the decoder output.
4. Transfer `P3DRES.8xv` back to the computer and attach it to the Codex task.

The suite renders six fixed scenes at the production settings: 80 independent
rays, four-pixel display columns, 16-horizontal-by-8-vertical texture samples,
and portal depth six. Each scene has two warmups, eight clean timing samples, four
detailed samples, and a final frame hash. The hash makes visual-detail
regressions visible even when a change is faster.

Current expected hashes:

| Scene | FNV-1a frame hash |
| --- | --- |
| `NEAR_WALL` | `AA5E6985` |
| `MID_DIRECT` | `1538F381` |
| `LONG_DDA` | `125784EE` |
| `PORTAL_CHAIN` | `AD3E19C6` |
| `PORTAL_WIDE` | `D1FDE517` |
| `CUSTOM_PAIR` | `7CD87316` |

### Decode or compare static results

The decoder uses only the Python standard library:

```powershell
python tools/decode-benchmark.py P3DRES.8xv --output-dir benchmark-results
```

It writes:

- `P3DRES-samples.csv`: every sample and counter.
- `P3DRES-summary.csv`: per-scene means, medians, ranges, and deviations.
- `P3DRES.json`: validated source metadata plus all samples and summaries.

Compare a new result with a saved baseline:

```powershell
python tools/decode-benchmark.py P3DRES-new.8xv `
  --compare P3DRES-baseline.8xv `
  --output-dir benchmark-results
```

The additional compare CSV reports timing deltas and verifies that scene
configuration and frame hashes still match.

Clean samples are the decision metric for speed. Detailed category timings
are switch-cost corrected and useful for locating hot areas, but their
instrumented frames are intentionally reported with an intrusion percentage.

## Live gameplay benchmark

`P3DLIVE` replays a deterministic 971-frame gameplay session through the real
`game_update` -> `game_render` -> `gfx_SwapDraw` path. It renders every frame,
including stationary frames during pulsed slow turns. Camera positions are
never installed between sections.

The continuous route:

- starts at the normal player spawn;
- approaches and crosses the start portal in both directions;
- traverses and sweeps the upper large room;
- approaches the west portal, enters the lower small room, turns there, and
  crosses back;
- walks across the open room;
- approaches the adjacent east-wall portal pair from a distance;
- crosses that pair in both directions; and
- performs a slow near-boundary sweep before leaving.

The input replay uses a fixed 1/30-second simulation step. This makes movement,
turning, collision, and portal traversal identical between builds while the
renderer runs as fast as the calculator can complete each frame. Six exact
portal crossings and 18 section endpoints are validated before the report is
accepted.

### Run it on the calculator

1. Transfer `bin/P3DLIVE.8xp` and ensure `clibs.8xg` is installed.
2. Run `P3DLIVE` and let the rendered route and post-route validation finish.
   It takes roughly one to two minutes at the current engine speed.
3. Wait for `Live benchmark done`. The program creates and archives the AppVar
   `P3DLIVE`. The completion screen also shows the report format and the
   eight-digit build ID. Record that ID with the uploaded
   file; it must match the decoder's `Build 0x........` value.
4. Transfer `P3DLIVE.8xv` back to the computer.

The report contains every frame's update, render, swap, and combined time;
camera position and angle; scripted input; semantic section; movement and
portal-crossing flags; ray-cast count; and maximum ray-layer depth. Each section
also stores an endpoint framebuffer hash, an endpoint gameplay-state hash, and
one fine-grained render trace. The decoder derives portal recursion depth as
`max_depth - 1` and portal-layer casts as total casts minus the 80 base rays.

All 971 recorded timings come from one uninterrupted clean route, including
all six portal crossings. Afterward, a deterministic diagnostic pass replays
the slowest clean render from each section for fine tracing and re-renders the
18 section endpoints for framebuffer validation. Trace switches and full
screen hashes therefore do not stall or contaminate the live timing samples.
The `DETAILED` marker identifies the clean frame whose camera state was replayed
for that section; it is not excluded from FPS statistics in this report mode.

The live binary includes lightweight profiling counters and inactive
fine-trace branches so same-route comparisons are consistent and useful for
optimization work. Its absolute FPS can be slightly lower than the normal
release binary. Graphics initialization and the first render-only frame are
reported separately from the warmed route. The fixed gameplay simulation step
is 1/30 second; measured timestamps are accumulated from actual update, render,
and swap work.

### Decode or compare live results

```powershell
python tools/decode-live-benchmark.py P3DLIVE.8xv `
  --output-dir benchmark-results/live
```

The decoder writes:

- `P3DLIVE-frames.csv`: all 971 frames with derived timestamp and FPS.
- `P3DLIVE-sections.csv`: clean FPS, lows, spikes, crossings, hashes, and the
  representative fine trace for every section.
- `P3DLIVE-portal-crossings.csv`: three frames before through three frames after
  each actual portal crossing.
- `P3DLIVE-summary.csv`: whole-route clean and observed distributions.
- `P3DLIVE.json`: the validated full report.

Compare a new live route with a matching saved route:

```powershell
python tools/decode-live-benchmark.py P3DLIVE-new.8xv `
  --compare P3DLIVE-baseline.8xv `
  --output-dir benchmark-results/live
```

Only reports with the same route fingerprint, frame count, camera/input path,
section layout, and endpoint hashes are directly comparable. Because each
section traces its measured slowest clean render, fine-category deltas are
reported only when both files selected the same frame and camera state.
`portal_candidates` and `linked_exits` in the fine traces are ray/layer events,
not counts of unique portals. Floor and ceiling work is currently combined in
the `background` category; texture sampling, shading, and writes are fused into
the wall and portal draw categories. Separate stress-only and user-recorded
route modes are future extensions; demanding stress sections are already
labeled inside this route.

## Matched calculator and CEmu baseline

The 2026-07-29 matched captures use calculator OS 5.3.0 and CEmu OS 5.4.0.
Every static scene hash and every live section framebuffer/state hash matches.
The OS/emulator timing difference is below one percent:

| Benchmark | Real calculator | CEmu | CEmu delta |
| --- | ---: | ---: | ---: |
| Static six-scene mean | 65.972 ms | 65.930 ms | -0.064% |
| Live 971-frame mean | 68.348 ms | 68.107 ms | -0.35% |

The original static report recorded `58D9E0DC`; the original live report
recorded `13F48319`. Those historical values hashed loader-patched import
stubs, so they identify the loaded program image but cannot be reproduced
reliably from the ELF on the computer. Both reports use 80 rays, four-pixel
columns, 16-by-8 textures, and portal depth six.

The route-weighted real-calculator live hotspots are 25.547 ms background,
12.323 ms wall drawing, 11.414 ms DDA, 7.813 ms portal tracing, 7.176 ms
administration, and 5.201 ms portal drawing. The exact three-band stack-PUSH
clear reduces background writes from 117,760 to 77,760 per frame. A matching
CEmu rerun measured:

| Metric | Baseline | Stack-PUSH clear | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 68.107 ms | 63.653 ms | -6.54% |
| Live average FPS | 14.683 | 15.710 | +7.00% |
| Static six-scene mean | 65.930 ms | 57.272 ms | -13.13% |
| Static background mean | 20.581 ms | 15.199 ms | -26.15% |

Every framebuffer, route, camera/input state, and portal-crossing check still
matches. The captured reports recorded the old loader-dependent IDs
`4153B687` (static) and `16F15C64` (live).

The portal-transform pass (`26072902`) then measured:

| Metric | Stack-PUSH clear | Portal transform | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 63.653 ms | 63.239 ms | -0.65% |
| Live average FPS | 15.710 | 15.813 | +0.65% |
| Static portal-scene columns | 46.303 ms | 45.263 ms | -2.25% |
| Matched live portal trace | 7.708 ms | 7.118 ms | -7.65% |

All static hashes, all 971 live route states, all 18 live endpoint hashes, and
all six portal crossings still match.

### Previous exact optimization pass

Build `26072904` keeps the production 80 rays, four-pixel columns, 16-by-8
texture sampling, and portal depth six. The retained renderer changes are:

- persistent assembly DDA state, including exact continuation after a portal;
- portal-exit resolution fused into the DDA hit and transform path;
- paired floor/ceiling projection and exact specialized clipped-grid paths;
- full-turn direction and camera-FOV lookup tables; and
- a hybrid wall writer that uses an eight-row unrolled loop for long textured
  spans and the smaller paired loop for short spans.

The same 971-frame headless CEmu autotest was used throughout development.
The final build-04 comparison is:

| Metric | Build-03 autotest baseline | Build 26072904 | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 56.982 ms | 52.357 ms | -8.12% |
| Live average FPS | 17.549 | 19.100 | +8.83% |
| Live 1% low | 12.760 FPS | 14.179 FPS | +11.12% |
| Static six-scene mean | 53.327 ms | 49.081 ms | -7.96% |
| Static columns mean | 38.386 ms | 35.827 ms | -6.67% |
| Static background mean | 14.697 ms | 13.126 ms | -10.69% |

All six static frame hashes, all 971 live route states, all 18 endpoint
framebuffer/state hashes, and all six portal crossings remained exact, with
zero route timing spikes. The host-side oracles additionally check exact
equivalence for the DDA, portal transform, clipped-grid, direction/FOV lookup,
and wall-descriptor math.

These headless autotester figures are repeatable development comparisons; they
are not interchangeable with the matched GUI CEmu or real-calculator captures
above. At 52.357 ms, this instrumented route is about 19.1 FPS and still needs
roughly another 36% frame-time reduction to reach 30 FPS.

Adjacent-wall grouping was reverted after it slowed the same live route by
0.99%, despite helping isolated near-wall scenes. Whole-file `-O2` and `-O3`
were also rejected because they produced invalid calculator execution. The
default optimized build therefore remains `-Oz`.

### Current full-resolution optimization pass

Build `26081403` restores and retains the production 80 rays, four-pixel
columns, full one-cell floor/ceiling grid, 16-by-8 wall textures, and portal
depth six. A 6.8 KiB signed-component table replaces the repeated root-ray
sign, magnitude, clamp, and reciprocal setup. Hot assembly writers now compute
screen-row offsets with native `MLT` instead of indexing the padded row table.
Neither change removes a ray, texture sample, grid line, or portal layer.

Against the exact restored build `26081402` on the same White-ROM headless
CEmu route:

| Metric | Restored 26081402 | Build 26081403 | Change |
| --- | ---: | ---: | ---: |
| Live 971-frame mean | 43.896 ms | 43.452 ms | -1.01% |
| Live average FPS | 22.781 | 23.014 | +1.02% |
| Live 1% low | 16.972 FPS | 17.095 FPS | +0.73% |
| Worst frame | 61.462 ms | 60.974 ms | -0.79% |

All 971 frame timings are clean, the three expected portal crossings occur,
and there are no timing spikes. All 18 endpoint framebuffer hashes, state
hashes, and route state hashes match the restored full-resolution reference.
The release memory audit reports 93,181 of 153,600 bytes used, including the
guarded 8 KiB stack.

The rejected build `26081401` rendered only 40 independent rays, used a
two-cell grid LOD, and reduced portal depth. It remains available solely as a
performance reference in `benchmark-results/paired-reference-26081401`; its
35.165/26.708 FPS result is not a production-resolution comparison.

Both benchmark programs use the stable source-controlled build ID
`26081403`; confirm `Build: 0x26081403` on the completion screen and in the
next decoded report. Increment `GAME_BUILD_VERSION` whenever a
benchmark-comparable engine build changes.

Decoded source reports and comparisons are retained in
`benchmark-results/matched-cemu-calc-2026-07-29-16x8` and
`benchmark-results/optimized-background-push-2026-07-29`, and
`benchmark-results/optimized-portal-transform-2026-07-29`. The repeatable
headless development baseline and final build-04 captures are in
`benchmark-results/autotest-build03-{static,live}` and
`benchmark-results/autotest-build04-final-{static,live}`. The rejected paired
build is archived in `benchmark-results/paired-reference-26081401`, while the
restored and optimized full-resolution captures are in
`benchmark-results/full80-restored-26081402-white` and
`benchmark-results/full80-final-26081403-white`.

## Release FPS overlay

In the playable `PORTAL3D` release, press the calculator's `GRAPH` key (`F5`)
to toggle the FPS overlay. The value is a lightly smoothed measurement of the
render, overlay, and buffer-swap path. When disabled, the renderer follows its
original direct render-and-swap path. Benchmark, autotest, ray-diagnostic, and
profile builds do not include the overlay.

## Build and validate

```powershell
make BENCHMARK=1
make BENCHMARK=1 budget
make LIVE_BENCHMARK=1
make LIVE_BENCHMARK=1 budget
python tools/decode-benchmark.py --self-test
python tools/decode-live-benchmark.py --self-test
python tools/check-dda-exact.py
python tools/check-background-clear.py
python tools/check-direction-lut.py
python tools/check-grid-clipped.py
python tools/check-grid-pair.py
python tools/check-grid-projection.py
python tools/check-grid-step-masks.py
python tools/check-live-route.py
python tools/check-portal-transform.py
python tools/check-ray-stepper.py
python tools/check-wall-descriptors.py
```

Release, profile, ray-diagnostic, static benchmark, live benchmark, and
autotest variants use separate object directories and program names so
changing build flags cannot reuse incompatible objects.

The project RAM guard permits at most 96 KiB (`98304` bytes) for resident
program sections, mutable `.bss`, and the explicit 4 KiB stack reserve. The
budget report still prints each component separately so added lookup tables or
caches cannot silently consume the remaining headroom.
