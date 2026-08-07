# Depth-one portal raster/fill result

Baseline: `face-reuse-pass22-build-26080601` (CEmu live route, 844 clean
frames). Candidate source was copied from that exact root revision before the
two small hot-loop edits in this directory.

## Retained candidate

- Clean mean: 38.708040 ms -> 38.630373 ms (-0.2007%).
- Average FPS: 25.8344 -> 25.8864 (+0.2011%).
- 1% low: 16.1154 -> 16.2432 FPS.
- Autotest executable: 46,060 -> 46,136 bytes (+76 bytes).
- All 854 recorded state hashes match the baseline.
- Every section's logical framebuffer, presented framebuffer, state, and
  portal-LOD hashes match the baseline.

The useful change hoists the constant wall shade out of the full-resolution
depth-one scanline loop. Only the two horizontal faces call
`face_color_for_row`, and only when horizon shading is enabled. Caching
`layer->lod_shift` in the LOD loop was neutral (a color-only run measured
38.632 ms), but is harmless and two bytes smaller in this build.

The detailed full-portal geometry samples improved by about four percent:

- CROSS_DOWN: 16.663 ms -> 15.961 ms.
- RETURN_UP: 15.289 ms -> 14.679 ms.
- LOD_RETREAT: 17.059 ms -> 16.357 ms.

Artifacts are in `results/`. The intentional CEmu RAM dump is retained as
`T3DLIVE-cemu-ram.bin` after archival.

## Earlier direct-fusion prototype lesson

The isolated pass18 prototype established that consuming depth-one spans
directly is output-exact for both full-resolution and portal-LOD targets.
Letting LTO inline the now-nonrecursive renderer made it slower. Keeping
`render_camera`, room collection, and the fused raster loops out of the root
caller changed the same direct-fusion idea from a 3.46% regression to a 1.46%
win. The integrated renderer keeps a syntactically recursive `render_camera`,
so the compiler already preserves that favorable function boundary. If that
recursion is removed later, re-check the map and force the renderer boundary
`noinline` before trusting a benchmark.
