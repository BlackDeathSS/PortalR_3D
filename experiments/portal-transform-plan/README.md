# Predecoded portal plan and face-table experiment

This directory is an isolated snapshot of the direct-context renderer. The
release tree is untouched.

- `baseline/` is the exact input snapshot.
- `plan-only/` retains the first, measured eight-byte transform-plan variant.
- `candidate/` adds the retained direction-major portal-face resolver.
- `runs/` contains serial CEmu static/live RAM dumps and decoded A/B results.

## Design

Each linked portal ID owns an eight-byte `PortalTransformPlan`:

| Offset | Bytes | Meaning |
| ---: | ---: | --- |
| 0 | 3 | exit tangent-axis base |
| 3 | 3 | fixed coordinate one unit beyond the exit face |
| 6 | 1 | rotation bits 0-1 and tangent-mirror bit 7 |
| 7 | 1 | nonzero when the tangent maps to output X |

IDs 0-9 are initialized from `render_builtin_portals` once. IDs 10 and 11
are rebuilt only when the dynamic portal faces change. Rotation zero updates
only the transformed origin; ray components, reciprocal deltas, magnitudes,
threshold, and signed map steps are already exact and remain untouched.

The retained resolver uses a 1,024-byte direction-major face table:

```
index = (wall_direction << 8) | padded_map_tile
value = kind[1:0] | linked[2] | portal_id[6:3]
```

The DDA already has both index bytes live, so one table load replaces the
dynamic-primary, dynamic-secondary, and builtin lookup chain. Dynamic portal
updates restore any hidden builtin descriptor before patching the new faces;
secondary is patched first so primary retains the legacy precedence.

The public `_render_asm_transform_ray(entry, exit)` compatibility path remains
unchanged. Only the renderer-specialized state entry consumes a plan.

## Results

All six static frame hashes, all 18 live section frame/state hashes, the final
frame hash, route-state hash, and all three portal crossings match the
baseline.

| Static scene | Baseline | Combined | Delta |
| --- | ---: | ---: | ---: |
| NEAR_WALL | 44.224 ms | 44.121 ms | -0.103 ms |
| MID_DIRECT | 43.007 ms | 42.900 ms | -0.107 ms |
| LONG_DDA | 45.071 ms | 44.964 ms | -0.107 ms |
| PORTAL_CHAIN | 53.905 ms | 53.055 ms | -0.851 ms |
| PORTAL_WIDE | 41.039 ms | 40.779 ms | -0.259 ms |
| CUSTOM_PAIR | 53.459 ms | 52.319 ms | -1.141 ms |

| Live 971-frame route | Baseline | Combined | Change |
| --- | ---: | ---: | ---: |
| Mean frame | 47.233 ms | 46.945 ms | -0.287 ms (-0.608%) |
| Average FPS | 21.172 | 21.301 | +0.612% |
| 1% low | 16.141 FPS | 16.350 FPS | +1.292% |
| Maximum frame | 64.453 ms | 63.721 ms | -0.732 ms |

Every live section improved; section means moved by -0.096 to -0.689 ms.
The plan-only variant improved the live mean by just 0.066 ms, while adding
the face resolver raised the live gain to 0.287 ms and the portal-heavy static
gain to 1.141 ms.

## RAM

Release RAM totals include the 4,096-byte reserved stack.

| Variant | Resident | BSS/data | Total | Headroom |
| --- | ---: | ---: | ---: | ---: |
| Baseline | 17,901 B | 49,404 B | 71,401 B | 26,903 B |
| Combined | 18,994 B | 50,531 B | 73,617 B | 24,687 B |

## Verification

```powershell
python verify_plan.py
python check-portal-transform.py --assembly candidate/src/render_asm.s
python check-dda-exact.py --assembly candidate/src/render_asm.s
```

The host checks cover 982,800 affine plan origins, 1,192,464 exhaustive
normal/tangent boundary cases, one million randomized signed-24-bit cases,
17,668 persistent chain casts, 100,000 exact DDA casts, and 7,196 dynamic
face-table patch/restore checks including builtin overlaps.
