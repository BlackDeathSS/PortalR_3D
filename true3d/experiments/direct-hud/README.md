# Direct HUD experiment

This isolated candidate replaces only `draw_hud` in the snapshotted True3D
engine.  The renderer, presenter, portal state, level data, and crosshair are
unchanged.  Production `true3d/src` is not modified.

Snapshot engine SHA-256:

- `C7670A1575F64B2B2BFCF3EDBD3CA0E729A62F4B17C03E88D0E1252D278DC354`

## Design

- Reuses the engine's original readable 3-by-5 `F/P/S` and digit glyphs.
- Adds only `R/E/C/A/M`, space, dash, and decimal point.
- Keeps the text anchors at `(2, 2)` for `FPS` and `(80, 2)` for `FREECAM`.
- Keeps the exact `FPS --.-` startup form, a variable one-to-three-digit whole
  FPS value, one decimal digit, and the conditional `FREECAM` label.
- Stores the font transposed by row, so selecting a glyph is a pointer add
  rather than a multiply.
- Expands each three-bit row through three eight-byte color LUTs.  Release
  disassembly confirms there are no multiply, divide, or shift helper calls in
  the glyph-row loop.
- Clears only the fixed `38x8` FPS rectangle.  The `31x8` free-camera rectangle
  is cleared only while `FREECAM` is visible.  This is safe because the full
  presenter refreshes the screen before each HUD draw.

The original HUD always cleared `148x12 = 1,776` pixels before GraphX text.
For the common `FPS 30.0` frame, this candidate performs:

| Mode | Background bytes | Glyph bytes | Crosshair writes | Total writes |
|---|---:|---:|---:|---:|
| normal | 304 | 120 | 10 | 434 |
| `FREECAM` | 552 | 225 | 10 | 787 |

That is 75.6% fewer writes in normal play and 55.7% fewer in freecam than the
old background fill alone, before counting the removed GraphX glyph work.

## Static comparison

The baseline was built from the identical engine snapshot before the HUD edit.

| Item | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| release AppVar | 30,293 B | 30,706 B | +413 B |
| live AppVar | 42,794 B | 43,173 B | +379 B |
| release `.text` | `0x7241` | `0x7387` | +326 B |
| live `.text` | `0xA0D3` | `0xA1F7` | +292 B |
| release `engine_render` | `0x26D` | `0x325` | +184 B |
| live `engine_render` | `0x6B2` | `0x748` | +150 B |
| `draw_hud_text` | absent | `0x8E` | +142 B |
| release BSS | `0x818A` | `0x818A` | unchanged |
| live BSS | `0x81E8` | `0x81E8` | unchanged |
| release `engine_render` frame | 47 B | 58 B | +11 B |
| live `engine_render` frame | 60 B | 68 B | +8 B |
| `draw_hud_text` frame | absent | 13 B | +13 B while called |

The code-size cost is intentional: it trades a small read-only font/LUT and a
specialized loop for substantially less per-frame library and VRAM work.  It
does not consume additional persistent RAM.

## Verification

Builds completed cleanly in both configurations:

```powershell
make build
make LIVE_BENCHMARK=1 build
```

The host test parses the candidate font itself and covers startup, one-, two-,
and three-digit FPS, overflow behavior, and both freecam states.  It verifies
exact label content, deterministic framebuffer hashes, rectangle bounds, no
changes to scene pixels outside the HUD bounds, and the original nine-pixel
crosshair:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test-direct-hud.ps1
```

Result: `10` content/bounds/determinism cases passed.  No CEmu run was made for
this experiment.  A production A/B should compare the benchmark `OVERLAY`
phase against the measured GraphX baseline (about 1.25 ms normal and 2.04 ms in
freecam) before retaining it.

## Minimal production diff

Only the HUD region of `src/engine.c` is required.  The exact patch can be
reviewed with:

```powershell
git diff --no-index -- ../present-wide24-baseline/src/engine.c src/engine.c
```

`tools/test-direct-hud.ps1` is experiment-only verification and is not needed
in the production build.
