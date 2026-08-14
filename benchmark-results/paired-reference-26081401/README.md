# Paired-ray experiment 0x26081401

This is the rejected half-horizontal-resolution experiment retained for performance reference only. It casts 40 independent rays and writes each result across eight physical pixels. Production Portal3D returns to 80 independent rays across 320 pixels.

White-ROM live benchmark: 35.165 FPS average, 26.708 FPS 1% low, 28.438 ms mean frame, 971 clean frames, and three portal crossings. The matching detailed results remain in `../paired-final-26081401-white/`.

`PORTAL3D-paired-26081401.8xp` is the exact calculator program, and `source.patch` is the source delta from Git `28fe046`.
