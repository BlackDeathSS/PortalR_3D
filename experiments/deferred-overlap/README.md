# Pre-wait deferred draw-job experiment

This isolated snapshot tests whether the raycaster can hide its DDA and portal
compositor behind the LCD scan. `DEFERRED_OVERLAP=0` is the untouched snapshot
baseline. `DEFERRED_OVERLAP=1` converts each high-level wall, wall-plus-ring, or
portal-mask operation to an ordered job before `gfx_Wait()`, then draws the
unchanged background and replays those jobs through the existing assembly
raster kernels.

The current compact job is 20 bytes: the complete 14-byte `RayHit`, an 8-bit
logical column, two clip bounds, two portal-opening bounds, and an operation
type. The exact immutable `WallContext` is recovered from the saved distance.
There can be at most one high-level operation per ray/depth pair, so 80 rays
times six layers gives a hard limit of 480 jobs, or 9,600 bytes plus the 2-byte
count.

The initially preferred 24-byte format also stored a context pointer and
16-bit X coordinate. Its 11,520-byte buffer is safe under the 96 KiB project
budget, but the snapshot's tighter default linker BSS window rejects it by
1,231 bytes. The 20-byte layout links in release mode.

No CEmu timing or framebuffer-hash run has been performed yet because the
shared autotester dump path is reserved by another experiment.
