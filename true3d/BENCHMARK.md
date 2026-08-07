# True3D live benchmark

The live benchmark runs a deterministic 854-frame gameplay route against the
built-in level. It keeps the 64 by 48 renderer at full detail, performs the
normal fixed-step player update, renders and presents every frame, crosses the
portal pair four times, exercises portal LOD, and finishes with free-camera yaw,
pitch, vertical motion, and a final portal crossing.

Build the calculator version from `true3d`:

```sh
make clean
make LIVE_BENCHMARK=1
```

Transfer and run `bin/T3DLIVE.8xp`. The program creates and archives
`T3DLIVE.8xv`, then shows both the rendered-frame count and the hexadecimal
`TRUE3D_BUILD_VERSION` on its completion screen. Transfer that AppVar back to
the PC before testing another build.

Validate and export the result with:

```sh
python tools/decode-live-benchmark.py path/to/T3DLIVE.8xv \
  --output-dir benchmark-results/run-name --prefix run-name
```

The decoder accepts a transferred `.8xv`, a raw AppVar/report payload, or a
full CEmu RAM dump. It validates the container checksum, report CRC, schema,
route fingerprint, four exact crossing frames, per-frame state, section-end
logical and presented hashes, portal LOD state, and build metadata. It exports
the validated raw report, JSON, and CSV files for the overall summary,
sections, frames, and portal-crossing windows.

For an exact A/B comparison:

```sh
python tools/decode-live-benchmark.py candidate/T3DLIVE.8xv \
  --compare baseline/T3DLIVE.8xv \
  --output-dir benchmark-results/candidate --prefix candidate
```

Comparison is rejected if route state or rendered endpoint hashes differ. The
CSV reports clean mean and median frame time, average FPS, 1% low FPS, and the
corrected render phases: setup, root geometry/fill, portal setup/geometry/fill,
wait, presentation, and overlay. One diagnostic frame per section is excluded
from clean aggregate timing.

The normal live target omits fine-grained counter branches from the renderer's
hot loops so its clean-frame FPS closely represents the release engine. Phase
timers remain available for hotspot attribution. For a deeper diagnostic build
that also records transformed vertices, projected points, polygons, raster
rows, spans, pixels, portal composite/clip pixels, LOD views, and edge-divider
fallbacks, build with:

```sh
make LIVE_BENCHMARK=1 LIVE_BENCHMARK_COUNTERS=1
```

Use the release's always-on FPS counter to confirm the final player-visible
result on hardware.

The route model can be checked without a calculator:

```sh
python tools/check-live-route.py
python tools/decode-live-benchmark.py --self-test
```

For unattended CEmu capture, build with
`LIVE_BENCHMARK=1 LIVE_BENCHMARK_AUTOTEST=1`. That target intentionally remains
on its result screen so an external CEmu harness can dump RAM and pass the dump
to the same decoder.
