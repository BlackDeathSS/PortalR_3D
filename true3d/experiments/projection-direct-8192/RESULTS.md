# Direct near-depth projection table

## Verdict

Retain provisionally pending the planned projection-assembly work.  Exact
CEmu A/B shows a small but real improvement: -0.527% mean render time with
matching hashes.  Unlike the rejected edge-divider experiment, this removes a
helper call from every near-depth projection.  The compiler generates a direct
doubled-index load with no `__ishru`.

The tradeoff is 12 KiB for 0.364 ms, so this is not especially efficient use
of RAM.  It still fits the requested 96 KiB working ceiling with 29,547 bytes
left in release and 16,725 bytes left in the instrumented live build.  A later
projection assembly path may obtain the same indexing win without the table;
keep this change only while it remains faster than that replacement.

This directory is an isolated experiment; root sources were not modified.

## Method

The baseline stores 2,048 near scales and indexes it with `depth >> 2`.
The candidate stores 8,192 entries and repeats each legacy scale four times:

```text
direct[4*i + 0] = legacy[i]
direct[4*i + 1] = legacy[i]
direct[4*i + 2] = legacy[i]
direct[4*i + 3] = legacy[i]
```

Near projection therefore becomes `direct[depth]`.  This preserves the old
four-depth quantization exactly; it does not increase or decrease visual
detail.  The far table, its `depth >> 5` indexing, and its saturation behavior
are unchanged.

Depths 0--3 remain exact despite the legacy `index == 0 ? 1 : index` rule,
because legacy entries zero and one are both initialized to 65,535 under the
current 32-unit near plane.

## Exact CEmu A/B

The parent task integrated this candidate temporarily on top of the current
pass and ran the exact benchmark:

| metric | baseline | direct table | change |
|---|---:|---:|---:|
| mean render | 69.136 ms | 68.772 ms | -0.364 ms (-0.527%) |
| mean FPS | 14.46 | 14.54 | +0.08 |
| 1% low | 8.53 FPS | 8.57 FPS | +0.04 FPS |

Render and state hashes matched exactly.

## Generated code

Baseline near lookup dynamically performs:

1. a C-ABI call to `_projection_scale_for_depth`;
2. that function's `__frameset0` prologue;
3. `call __ishru` for `depth >> 2`;
4. clamp/index setup and return.

Candidate near lookup is inlined at both callers and generates:

```asm
ld  hl, _projection_scale_table
add iy, iy
lea de, iy + 0
add hl, de
ld  de, (hl)
```

There is no near-path shift, multiply, or projection-scale helper call.

| generated item | baseline | candidate | delta |
|---|---:|---:|---:|
| static calls to `_projection_scale_for_depth` | 2 | 0 | -2 |
| `_projection_scale_for_depth` body | 114 B | eliminated | -114 B |
| `_project_camera_point` release body | 325 B | 379 B | +54 B |
| `_collect_room_polygons` release body | 3,797 B | 3,859 B | +62 B |
| `_engine_graphics_init` release body | 669 B | 676 B | +7 B |
| total release `.text` | 30,234 B | 30,243 B | +9 B |

The static count of `call __ishru` in the whole assembly remains 38 in release
(44 live), but this is not an equal-cost result: the baseline has one shared
helper body containing separate near and far shifts, while the candidate
inlines only the still-required far shift at two call sites.  Dynamically,
every near lookup loses one `_projection_scale_for_depth` call, one
`__frameset0`, and one `__ishru`.  Far lookup behavior retains `__ishru`.

## RAM and build size

The near table grows from 4,096 to 16,384 bytes: exactly +12,288 B of BSS.

| configuration | baseline | candidate | delta |
|---|---:|---:|---:|
| release resident program | 31,202 B | 31,211 B | +9 B |
| release `.bss` | 21,162 B | 33,450 B | +12,288 B |
| release budgeted total | 56,460 B | 68,757 B | +12,297 B |
| release headroom to 96 KiB | 41,844 B | 29,547 B | -12,297 B |
| release headroom to 150 KiB hard limit | 97,140 B | 84,843 B | -12,297 B |
| release AppVar | 31,279 B | 31,287 B | +8 B |
| live resident program | 43,930 B | 43,939 B | +9 B |
| live `.bss` | 21,256 B | 33,544 B | +12,288 B |
| live budgeted total | 69,282 B | 81,579 B | +12,297 B |
| live headroom to 96 KiB | 29,022 B | 16,725 B | -12,297 B |
| live headroom to 150 KiB hard limit | 84,318 B | 72,021 B | -12,297 B |
| live AppVar | 44,006 B | 44,016 B | +10 B |

The reserved stack remains 4,096 bytes and the largest attributed frame stays
237 bytes.  `project_camera_point` remains 14 bytes of attributed stack;
`collect_room_polygons` and `render_camera` are unchanged.  Initialization
grows from 22 to 23 attributed bytes because it carries the direct-table fill
pointer.

## Exactness tests

`check_exact.py` compares the original and direct lookup models and then hashes
complete projected point outputs:

```text
near depths checked: 8,192
far/boundary depths checked: 57,365
projected point cases checked: 200,000
projection SHA-256: 642f893477dde49d24faa312f34bba50b250c9b1b9d0cd8b843722ee2e6e161a
```

Coverage includes every near depth, every unsaturated far depth, near/far and
far-saturation boundaries, signed coordinate extrema, both render resolutions,
and random depths through the full nonnegative signed-24-bit range.

## Validation performed

- Release build: passed.
- Live benchmark build: passed.
- Release/live 153,600-byte RAM checks with 4,096-byte reserved stack: passed.
- Host scale and projected-output exactness: passed.
- Exact CEmu A/B was run by the parent integration pass: hashes passed and
  mean render improved by 0.527%.
