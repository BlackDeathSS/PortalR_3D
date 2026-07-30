# Compiler speed audit (build 0x26072903)

Static `BENCHMARK_AUTOTEST` builds were compiled from one unchanged source
snapshot and run with:

```text
C:\CEdev\bin\cemu-autotester.exe -d <absolute autotest.json>
ROM: D:\White_TI84.rom
libraries: C:\Users\refiorlk_admin\Downloads\clibs.8xg
```

Each successful test intentionally failed a full `ram_start` / `ram_size`
hash after 30,000 emulated milliseconds so that the autotester emitted a
262,144-byte RAM dump. The dumps were decoded with
`tools/decode-benchmark.py`.

## Result

`-Oz` remains the best safe whole-program setting.

| Setting | Status | Mean total | Background | Columns | Program | Budgeted RAM |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| `-Oz` | valid, all 6 hashes match | 50.380707 ms | 13.127009 ms | 37.129084 ms | 22,039 B | 77,606 B |
| `-Os` | valid, all 6 hashes match | 51.588694 ms | 13.104121 ms | 38.358688 ms | 22,575 B | 78,143 B |
| `-O1` | valid, all 6 hashes match | 51.722209 ms | 13.142904 ms | 38.479487 ms | 23,155 B | 78,723 B |
| `-O2` | unsafe: CEmu NMI/null write; dump has no valid report | no valid report | - | - | 29,585 B | 85,152 B |
| `-O3` | unsafe: CEmu NMI/null write; dump has no valid report | no valid report | - | - | 27,137 B | 82,705 B |

Relative to `-Oz`, `-Os` is 1.207987 ms / 2.398% slower overall. Its
background is effectively unchanged (-0.022888 ms), while columns are
1.229604 ms / 3.312% slower.

Relative to `-Oz`, `-O1` is 1.341502 ms / 2.663% slower overall. Its
background is effectively unchanged (+0.015895 ms), while columns are
1.350403 ms / 3.637% slower.

The six matching framebuffer hashes are:

```text
AA5E6985 1538F381 125784EE AD3E19C6 0099C767 7CD87316
```

All successful variants report:

```text
build: 0x26072903
suite: 0xB203060E
configuration: 80 logical columns, 4-pixel columns, 8-row textures, depth 6
```

The `-O2` and `-O3` failures mean those settings must not be selected merely
because the 96 KiB RAM budget can accommodate their larger code. They need a
separate optimizer/undefined-behavior investigation before they are candidates
for a release.

## Source snapshot

The compared builds used these SHA-256 hashes:

```text
src/game.c        B7CA5BA5E49EEA361628E4A0B4E65370F92DB88FFBDE1D41431E1324692A10DE
src/render_asm.s  3A74F5918F7AF6C93537730B885197B0FF349E09DB2A8E6156EC2626CCB91778
src/benchmark.c   49C64FDD81F7B1758CBDA278F62B1754A07C3C5BACA52F324DF54FF4B3A77AC5
src/game.h        ECF61DF50E013036D404FB20E41A07195D10F0B4F9C8A8A2C85A60ECE135E0B5
makefile          917A81B8559BE37B1A1F0CF3B0E197392782CAEF29E219A47D55FFD63C5265E5
```

The isolated object directories are under `obj/compiler-speed-audit/`; the
isolated final-matrix program names are `P3AOZ`, `P3AOS`, `P3AO1`, `P3AO2`,
and `P3AO3`.

The final matrix was rebuilt after the last `src/game.c` edit at
2026-07-29 13:48:27. Both optimization agents then confirmed the source was
frozen. The final decoded outputs are:

```text
oz/oz-final.*
os/os-final2-vs-oz.*
o1/o1-final2-vs-oz.*
```
