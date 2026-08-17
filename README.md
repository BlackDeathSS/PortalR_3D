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

## All-in-one level editor

[`editor`](editor/README.md) is the shared multi-level studio for Portal3D and
T3D3. It edits both engines' level formats, embeds all authored levels in the
calculator programs, runs both CEdev builds, and creates transfer-ready ZIP
packages. Start it from PowerShell with:

```powershell
.\editor\start-editor.ps1
```

Both games now open with a packaged-level selector. Use Up/Down and `2nd` to
start a level, or `Clear` to exit.

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

## Raycaster gameplay controls

- `Mode`: fire the equipped weapon
- `Math`: open a nearby door
- `1` / `2`: equip the pistol / shotgun
- Arrow keys: move and turn
- `2nd` / `Alpha`: place primary / secondary portals
- `Del`: clear both placed portals

Each raycaster chamber now contains enemies, pickups, animated security doors,
and a boss-gated exit. Defeat the boss (or bosses), then walk into the green
exit beacon to advance. The HUD tracks health, ammunition, lives, weapon, and
level. If all lives are lost—or the last chamber is cleared—press `Mode` to
restart the campaign.
