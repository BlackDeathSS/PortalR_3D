# PortalR 3D benchmark comparison

Source result: `bin/P3DRES.8xv`

`P3DOPT.raw` is the optimized result payload and `P3DPRE.raw` is the immediate
pre-change payload used by the second comparison, so both reports can be
regenerated without files from the temporary directory.

- Wrapper checksum: valid (`0xA4D3`)
- Payload CRC32: valid (`0x19403E2B`)
- Render configuration: 80 rays, 4-pixel columns, 16×16 textures, depth 6
- Suite fingerprint: `0xB203060E`
- All six optimized framebuffer hashes match the submitted result
- The wrapper comment says `Exported via CEmu`; these timings are not confirmed
  physical-calculator measurements

## Clean-frame results

| Scene | Submitted | Optimized | Change | Optimized FPS |
|---|---:|---:|---:|---:|
| NEAR_WALL | 66.65 ms | 61.08 ms | -8.36% | 16.37 |
| MID_DIRECT | 66.92 ms | 62.60 ms | -6.46% | 15.98 |
| LONG_DDA | 74.62 ms | 67.32 ms | -9.78% | 14.85 |
| PORTAL_CHAIN | 88.29 ms | 80.97 ms | -8.30% | 12.35 |
| PORTAL_WIDE | 67.45 ms | 63.19 ms | -6.31% | 15.82 |
| CUSTOM_PAIR | 86.11 ms | 80.38 ms | -6.65% | 12.44 |

The comparison uses clean samples. Fine-grained tracing adds 31–44% overhead
and is useful for locating costs, not for deciding whole-frame speedups.

## Accepted changes in this pass

1. The wall texture walker retains its next run index and reuses the packed
   fourth color byte. This saves 0.38–1.29 ms against the immediate pre-change
   build.
2. Floor/ceiling grid X projection now uses exact 8-bit partial products in
   assembly. This saves another 0.75–1.51 ms and passes exhaustive arithmetic
   checking for all supported projection heights.

An assembly ceiling-grid replay experiment was rejected because it was
pixel-exact but 0.01–0.03 ms slower.

## Next measured targets

The remaining largest clean-frame costs are the background grid/fills
(17.5–31.0 ms) and textured columns (35.9–62.6 ms). The next low-risk direction
is to fuse near projection, far projection, and segment insertion into one
assembly transition. The larger potential gain is a differential-tested paired
floor/ceiling clip-rasterizer that preserves GraphX rounding exactly.
