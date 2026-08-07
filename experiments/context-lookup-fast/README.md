# Exact distance-context lookup experiment

This directory is an isolated snapshot of the renderer used to compare the
existing 2,048-entry shifted wall-context table with an 8,192-entry direct
distance table. Nothing here is a release source file.

- `baseline/`: unchanged source snapshot.
- `byte8192/`: 8 KiB direct profile-index table. It removes the same shift and
  reconstructs the profile pointer with an 8-byte element-size scale.

The discarded 16 KiB offset-table form was indistinguishable in speed from
the byte table (0.004 ms faster in the six-scene mean, below one timer tick),
but left only 8,934 bytes in the static autotest RAM budget. It is not kept.

## Result

The 8 KiB byte table is exact and faster. Algebraically, its entries are
`direct[d] = old[d >> 2]` for `d < 8192`, and both forms clamp every larger
24-bit value to the final profile. The benchmark confirms the same six frame
hashes:

| Scene | Baseline | Byte table | Delta |
| --- | ---: | ---: | ---: |
| NEAR_WALL | 44.570923 ms | 44.223785 ms | -0.347137 ms |
| MID_DIRECT | 43.373108 ms | 43.006897 ms | -0.366211 ms |
| LONG_DDA | 45.433044 ms | 45.070648 ms | -0.362396 ms |
| PORTAL_CHAIN | 54.660797 ms | 53.905487 ms | -0.755310 ms |
| PORTAL_WIDE | 41.500092 ms | 41.038513 ms | -0.461578 ms |
| CUSTOM_PAIR | 54.241180 ms | 53.459167 ms | -0.782013 ms |
| Equal-scene mean | 47.296524 ms | 46.784083 ms | -0.512441 ms (-1.083%) |

The 971-frame live route also preserved all 18 section endpoint frame/state
hashes, the final frame hash, route-state hash, and three portal crossings:

| Metric | Baseline | Byte table | Change |
| --- | ---: | ---: | ---: |
| Mean frame | 47.687346 ms | 47.232505 ms | -0.454841 ms (-0.954%) |
| Average FPS | 20.969924 | 21.171860 | +0.963% |
| 1% low | 15.950932 FPS | 16.141077 FPS | +1.192% |
| Range | 36.621-65.155 ms | 36.163-64.453 ms | lower at both ends |
| Graphics init | 466.033936 ms | 434.051514 ms | -31.982422 ms |

## RAM

All totals include the project's 4,096-byte reserved stack.

| Build | Variant | Resident | BSS | Budget total | Headroom |
| --- | --- | ---: | ---: | ---: | ---: |
| Release | Baseline | 17,917 B | 45,308 B | 67,321 B | 30,983 B |
| Release | Byte table | 17,901 B | 49,404 B | 71,401 B | 26,903 B |
| Static autotest | Baseline | 21,514 B | 51,452 B | 77,062 B | 21,242 B |
| Static autotest | Byte table | 21,486 B | 55,548 B | 81,130 B | 17,174 B |
| Live autotest | Baseline | 30,152 B | 45,392 B | 79,640 B | 18,664 B |
| Live autotest | Byte table | 30,124 B | 49,488 B | 83,708 B | 14,596 B |

Static benchmark artifacts and decoded comparisons are written below this
directory so concurrent work in the repository root remains untouched.
