# Retained 16x8 texture and paired-grid replay

This directory contains the retained CEmu 971-frame gameplay replay after:

- pairing exact in-bounds floor/ceiling grid rasterization;
- pairing horizontal floor/ceiling rows;
- compacting deferred clipped-grid endpoints; and
- changing wall textures from 16x16 to 16x8 while retaining all 16 horizontal
  samples.

The rejected four-row wall writer is not present in this replay.

| Metric | Uploaded matched CEmu | Retained replay | Change |
| --- | ---: | ---: | ---: |
| Mean frame time | 74.715 ms | 62.822 ms | -15.9% |
| Average FPS | 13.384 | 15.918 | +18.9% |
| 1% low FPS | 9.939 | 11.753 | +18.2% |
| Maximum frame time | 101.532 ms | 86.761 ms | -14.5% |

All 971 frames completed cleanly with 18 validated sections, six portal
crossings, and unchanged route/state hashes. Framebuffer hashes intentionally
changed because vertical texture sampling changed from 16 to 8 samples.

The raw replay has autotest build fingerprint `0x268633BB`. The production
`P3DLIVE.8xp` built from the retained source shows its own fingerprint on the
completion screen; use that displayed value when returning a real-calculator
result.
