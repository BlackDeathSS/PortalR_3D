# Large-room depth cues

## Finding

T3D3 rooms are rendered as six flat-color convex faces. Room-face brightness
comes from face orientation, not camera-space distance. Floor and ceiling faces
have three screen-row bands around the horizon, but those bands do not expose a
repeatable world-unit scale.

Perspective cannot solve that by itself. If a room and the camera's relative
placement are scaled by the same amount, every projected corner has the same
screen position. With no repeating texture, seam, object, or distance-dependent
wall shade, a large empty room can therefore look like a small empty room.

Run `python tests/check-room-depth-cues.py` from `t3d3` to verify that case.

## Captured evidence

The current Big Room is 30 by 30 by 30 units, with the camera only 1.5 units
above its floor. In the captured root frame, the far wall fills the view and
only four display colors are present (wall, overlay black/white, and cursor).
The 20 by 20 by 10 Medium Room exposes side walls, ceiling, and floor, so its
silhouette supplies much stronger perspective cues.

A controlled capture retained the Big Room's 30 by 30 footprint while reducing
only its height to 5 units. That makes ceiling and floor visible, but the far
wall is still one uninterrupted flat-color band. This separates the geometry
issue from the renderer issue: more conventional room proportions help, while
large flat faces still need a repeatable scale cue.

The three captures are in `benchmark-results/depth-cues-current/`.

## Implemented fix

Two complementary cues are enabled without introducing a depth buffer:

1. Root-room floors and ceilings draw up to two visible depth seams anchored to
   four-unit world-grid planes. The renderer selects the dominant horizontal
   camera axis, projects only the seam center row, and lets the later wall
   fills trim that row to the room. This preserves a repeatable ruler without
   general line clipping or per-pixel texture work. Portal destination views
   omit the seams to keep the pathological dual-portal route bounded.
2. Every room wall, including walls visible through portals, caps its authored
   orientation light using its representative camera-space depth. The existing
   four palette shades step down beyond 8, 16, and 24 units.

The seams provide an actual ruler, while distance shading makes the far wall
read immediately. Both reuse the current palette and convex-room renderer; no
per-pixel depth buffer or texture sampling is required. The implemented Big
Room capture is `benchmark-results/depth-cues-26081501/candidate/big-room-candidate.png`.

## Performance validation

The deterministic CEmu benchmark compares fresh baseline and candidate builds
from the same working tree:

| Route | Baseline FPS | Candidate FPS | Tick regression |
| --- | ---: | ---: | ---: |
| No body | 36.91 | 36.10 | 2.25% |
| Four root bodies | 30.44 | 29.87 | 1.93% |
| Dual portal, four bodies | 20.07 | 19.19 | 4.59% |

All three routes remain below the 5% limit and retain their exact simulation
state hash. From `t3d3`, run:

```text
python tests/compare-depth-cue-benchmarks.py benchmark-results/depth-cues-26081501/baseline benchmark-results/depth-cues-26081501/candidate
```

This reproduces the comparison from the retained CRC-valid RAM reports.
