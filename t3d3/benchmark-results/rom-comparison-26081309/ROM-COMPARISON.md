# T3D3 build 0x26081309 CEmu ROM comparison

Tested 2026-08-14 with `cemu-autotester.exe` SHA-256
`342C18EF55C69C7AC7698309BE1ADD440BA5E5B0C5EEF794FB59576D45104496`.

## ROMs

| ROM | Size | SHA-256 |
|---|---:|---|
| `White_TI84.rom` | 4,194,304 | `808F588DB9CAE429B4D3C276490873B70774AFD57E16DD6CE2E6CE8A58A000D6` |
| `TI_5.8.0_ROM.rom` (OS 5.8.0.0022) | 4,194,304 | `1B7B610591B754FF5BEB55A693978A96551853F13A21733A6A5482AA40B570A4` |

OS 5.8 cannot directly launch third-party ASM programs. Its tests transferred
`arTIfiCE_v2.1.8xp`, launched `prgmA`, and selected the same T3D3 binary from
the arTIfiCE shell. A direct `action|launch` test leaves the engine untouched
and therefore is not a valid engine result.

## Deterministic dual-portal/four-cube benchmark

Both runs used the same build, 854-frame route, 80x60 renderer, two visible
portals, and four visible cubes.

| Metric | White ROM | OS 5.8.0 | Difference |
|---|---:|---:|---:|
| Average FPS | 16.08996 | 16.07584 | -0.0877% |
| 1% low FPS | 12.98257 | 12.97400 | -0.0660% |
| Median FPS | 16.22178 | 16.20574 | -0.0989% |
| Mean frame | 62.15057 ms | 62.20513 ms | +0.0878% |

The route fingerprint, route/end-state hash, all section state/logical/presented
hashes, final logical frame (`0xD5BBF829`), and final presented frame
(`0xEDE265BA`) match exactly. The approximately 0.09% timing difference is
negligible and no OS-specific rendering or simulation divergence was found.

## Functional checks

- White ROM normal build: 30/30 visual, cube-angle, near-clip,
  player/body, standing, and noclip checkpoints passed.
- White ROM portal-push fixture: 3/3 checkpoints passed.
- OS 5.8 normal build launched successfully through arTIfiCE. Fixed initial
  scene, palette, and held-body hashes matched. Several later wall-clock input
  checkpoints produced different timing CRCs; the deterministic benchmark
  above remained exact.
- OS 5.8 portal-push fixture caused the CEmu process itself to abort at
  `schedule.c:242` (`sched_active(id)`). No portal-push engine CRC was produced,
  so this is recorded as an emulator/test-harness limitation, not a passing or
  failing engine result. The same fixture passes on the White ROM.

## Artifacts

- `white/white-580-compare.json` and CSV/raw companions
- `os-5.8.0/os580.json` and CSV/raw companions
- `os-5.8.0/os580-compare.csv`
- Full 256 KiB CEmu RAM dumps and autotester logs in each ROM directory
