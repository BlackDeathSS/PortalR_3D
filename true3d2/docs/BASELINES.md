# Frozen source and benchmark baselines

Recorded on 2026-08-10 before True3D2 certification work.

## True3D

- Repository baseline commit: `3e5be3317d4bea745a2113c95405d9194c2e473d`
- `true3d/src/engine.c` SHA-256:
  `C23445BD8A548E8B242E8A8D02EA5C9A970D54DBBF2833C87A742302491A249C`
- `true3d/src/present.s` SHA-256:
  `4FB953B1FF0603181414545B0E9F7B5614E8D33BB99F9140E1A0F4469554FE6E`
- `true3d/src/level.c` SHA-256:
  `5FAA21E929ACC38BA1D7AD0D6C895A42A9002EBC0B0A3BB598D27B24F3A84528`
- Development binary `TRUE3D06.8xp`: 30,293 bytes.
- Route fingerprint: `0x90ABD6C8`; build: `0x26080601`; 854 observed
  frames, 844 clean frames, four portal crossings.

The retained optimization artifacts bracket the plan's approximate baseline:

| Capture | Clean average | Median | 1% low |
| --- | ---: | ---: | ---: |
| face-reuse pass 22 | 25.834 FPS | 28.469 FPS | 16.115 FPS |
| fused-projection pass 26 | 26.040 FPS | 28.544 FPS | 16.385 FPS |

The detailed route frames commonly attribute about 15-24 ms to root geometry,
5-11 ms to root fill, and roughly 14.65 ms to present, depending on section.
These captures are CEmu evidence, not real-calculator certification.

## MinecraftTI / Virtual3D

- Repository commit: `986675a3f20fbbfcb5c02b7f858b93e15b09c6ba`
- `example/MineTI.asm` SHA-256:
  `74ADC5E6C6E3B6D05F52DB031B30164D18A2427A4E4D131923563170E845AB59`
- `example/render.asm` SHA-256:
  `0C0AD7AB472DBDD91C57B31CCAB6F0EE8BEEC52A9BCC2CD6FAFA4BBD67C63043`
- Existing `MineTI.8xp`: 26,320 bytes.
- License: MIT, copyright 2017-2021 TheMachine02; `ports.asm` alone is
  BSD 3-Clause, copyright 2015-2021 Matt "MateoConLechuga" Waltz.

No repeatable saved phase/FPS route accompanies the checked-out MinecraftTI
binary. Adding one remains an explicit baseline task; absence of that number is
not treated as evidence for or against True3D2's target.

## True3D2 host reference

`python tools/t3d2_reference.py --frames 854` produces:

- route CRC32: `0x4FB0B9DA`
- final logical-frame CRC32: `0xD18E3AF0`
- sample totals by layer: `1,737,826 / 362,766 / 60,100`
- final body: position `[0, 0, 64]`, zero velocity, asleep at 30 ticks

These values freeze correctness behavior only. Python runtime is not a CE
performance measurement.
