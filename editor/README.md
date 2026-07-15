# Doom CE Level Workshop

Open `index.html` in a current desktop browser. The editor is deliberately
dependency-free and runs locally without a server.

## Current workflow

- Drag vertices on a quarter-unit grid.
- Edit floor and ceiling heights to make rooms and stairs.
- Add rectangular rooms and link reverse, overlapping wall edges as doorways.
- Pair two sufficiently large solid walls as a working portal pair. Wall
  orientation is derived from each edge, so axis-aligned walls are not
  required. The calculator renders through the pair and teleports the player
  when they cross its opening.
- Place the player spawn and export editable JSON, a raw packed `.dcl` level,
  or the archived `DOOMLVL1.8xv` AppVar loaded directly by the calculator.

The `.dcl` export is the exact packed `DCE1` layout declared in
`../doom/src/level_format.h`: header, vertices, edges, sectors, then portals.
Transfer `DOOMLVL1.8xv` alongside the game program. The calculator validates the
packed data and reads it directly from archive without copying the level into
RAM. If the AppVar is absent or invalid, the built-in three-room test level is
used automatically.

Portal openings are clipped per 80-column render layer and may recurse through
three additional visible portal views. Portals on doorway edges, portals outside
their host room, and openings shorter than the player are rejected before
export.
