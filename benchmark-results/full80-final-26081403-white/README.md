# Full-resolution final build 0x26081403

Production configuration: 80 independent rays, four physical pixels per ray,
16-by-8 wall textures, one-cell grid spacing, and portal depth six.

This directory contains the release program, live autotest program, raw
White-ROM CEmu memory dump, decoded frame/section reports, and the exact
comparison against restored build `0x26081402`.

- 971 clean frames and three expected portal crossings
- 43.4518 ms mean, 23.0140 FPS average
- 17.0952 FPS 1% low, 60.9741 ms worst frame
- zero timing spikes
- all 18 framebuffer and state endpoint hashes exact
- release RAM audit: 93,181 / 153,600 bytes, including 8 KiB stack
- release SHA-256: `A4091679AF83DDFF658A57FB7C3466236032584FA1B7D16B6532D9A501CF68D8`

Only `C:/Users/refiorlk_admin/Documents/White_TI84.rom` was used for the final
emulator run. OS 5.8 is not part of the current test matrix.
