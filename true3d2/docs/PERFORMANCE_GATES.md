# Performance gates

Build `T3D2KERN` with `make KERNEL_BENCHMARK=1`, run it on the target, transfer
the resulting `T3DKERN` AppVar, then decode it with:

```sh
python tools/decode_kernel.py T3DKERN.8xv
```

The report contains the timer frequency, raw ticks, sample/triangle counts,
frame hashes, build ID, pass bits, and CRC. It returns success only when:

- eight presenter iterations average at most 12.5 ms;
- the raster covers exactly 4,800 textured depth-tested samples in at most 8 ms;
- the 96-triangle transform/clip/project setup finishes in at most 4 ms.

Host timings are not accepted. CEmu results are useful for repeatable A/B work,
but real hardware must pass. Optimization attempts must keep the 80x60 root,
40x30 and 20x15 portal tiers, depth-two recursion, and FPS contract fixed.

The latest supplied-ROM CEmu run measures 13.767 ms presenter, 40.100 ms
4,800-sample raster (25.055 ms span-only), and 117.401 ms geometry. All gates
still fail. See `CEMU_PERFORMANCE_2026-08-10.md`; development must redesign the
transform/setup/raster kernels rather than proceeding to feature certification.
