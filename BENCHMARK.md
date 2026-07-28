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
   `P3DRES`.
4. Transfer `P3DRES.8xv` back to the computer and attach it to the Codex task.

The suite renders six fixed scenes at the production settings: 80 rays,
four-pixel columns, 16-pixel textures, and portal depth six. Each scene has
two warmups, eight clean timing samples, four detailed samples, and a final
frame hash. The hash makes visual-detail regressions visible even when a
change is faster.

Current expected hashes:

| Scene | FNV-1a frame hash |
| --- | --- |
| `NEAR_WALL` | `809E63C5` |
| `MID_DIRECT` | `17094EF1` |
| `LONG_DDA` | `0F8C057E` |
| `PORTAL_CHAIN` | `DFEB88EA` |
| `PORTAL_WIDE` | `15477647` |
| `CUSTOM_PAIR` | `09E6070E` |

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
   `P3DLIVE`.
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

## Build and validate

```powershell
make BENCHMARK=1
make BENCHMARK=1 budget
make LIVE_BENCHMARK=1
make LIVE_BENCHMARK=1 budget
python tools/decode-benchmark.py --self-test
python tools/decode-live-benchmark.py --self-test
python tools/check-dda-exact.py
python tools/check-grid-projection.py
python tools/check-live-route.py
python tools/check-portal-transform.py
python tools/check-wall-descriptors.py
```

Release, profile, ray-diagnostic, static benchmark, live benchmark, and
autotest variants use separate object directories and program names so
changing build flags cannot reuse incompatible objects.
