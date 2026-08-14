# PortalR_3D
Portal TI_84

Performance benchmark instructions: [BENCHMARK.md](BENCHMARK.md)

The production raycaster keeps its original 80 independent rays, four-pixel
columns, 16-by-8 wall textures, and six visual portal layers. Build
`26081403` measures 23.01 FPS average and 17.10 FPS 1% low on the retained
971-frame White-ROM CEmu route. The faster 40-ray experiment is archived as a
non-production reference under `benchmark-results/paired-reference-26081401`.

The compatibility-first successor based on the working True3D engine is in
[`t3d3`](t3d3/README.md). T3D3 is developed alongside the original engines;
it does not replace or modify them.

## Full 3D Special Controls

`Trace` (`F4`) toggles noclip so the camera can leave the room bounds.
- `math`: spawn box, pickup/drop box (if pointing at box)
- `vars`: throw box
  
## Controls Universal for both Raycaster and Full 3D

- Arrow keys: move and turn
- `Trace` (`F4`) toggles noclip so the camera can leave the room bounds.
- `2nd`: fire the primary portal
- `Alpha`: fire the secondary portal
- `Del`: clear portals
- `Graph` (`F5`): toggle the release FPS counter
- `Clear`: exit
