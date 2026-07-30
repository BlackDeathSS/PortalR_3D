# PortalR 3D optimization pass 2

The submitted `P3DRES-new.8xv` and optimized `P3DOPT2.raw` payloads are stored
in this directory with the immediate pre-pass `P3DBASE.raw` payload, so both
comparisons are reproducible.

- Wrapper and payload checksums: valid
- Configuration: 80 rays, four-pixel columns, 16×16 textures, depth 6
- Suite fingerprint: `0xB203060E`
- All six optimized framebuffer hashes match
- The submitted wrapper says `Exported via CEmu`; it is not confirmed
  physical-calculator timing

## Clean-frame results

| Scene | Submitted | Optimized | Change | Optimized FPS |
|---|---:|---:|---:|---:|
| NEAR_WALL | 66.51 ms | 60.33 ms | -9.28% | 16.57 |
| MID_DIRECT | 66.68 ms | 61.32 ms | -8.05% | 16.31 |
| LONG_DDA | 71.51 ms | 65.78 ms | -8.01% | 15.20 |
| PORTAL_CHAIN | 83.77 ms | 79.40 ms | -5.21% | 12.59 |
| PORTAL_WIDE | 66.75 ms | 61.68 ms | -7.60% | 16.21 |
| CUSTOM_PAIR | 83.55 ms | 78.84 ms | -5.63% | 12.68 |

Against the immediate pre-pass build under the same local CEmu cadence, this
pass saves 0.75–1.57 ms per frame (1.22–2.40%).

## Accepted changes

1. Fused near/far grid projection, segment culling/storage, and floor drawing
   into one assembly transition for non-axis grid lines.
2. Replaced separate wall texel and run-end arrays with one interleaved
   descriptor table, removing a table lookup in normal walls and portal masks.
3. Kept the framebuffer destination resident in `IY` throughout each texture
   range instead of saving and reloading it for every run.

All production detail settings remain unchanged. A four-row writer unroll was
rejected because it improved close walls but slowed the long and portal-heavy
worst cases by 0.08–0.13 ms.
