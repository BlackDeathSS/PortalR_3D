# Layer-major portal prototype

This directory is an isolated compileable experiment. It snapshots only the
release sources needed by CEdev and enables `RENDER_LAYER_MAJOR_PORTALS`.
Root renderer and benchmark files are intentionally untouched.

The experiment traces every layer-zero ray first. Terminal columns are drawn
immediately. Traversable first hits retain an exact 55-byte assembly DDA state
and are coalesced into contiguous runs with one predecoded affine portal plan.
Each run then restores its rays, applies that shared plan, and resumes the
existing exact persistent DDA. Deeper portals use the established transform.

Build only this experiment with:

```powershell
make -C experiments/layer-major -B
```

No CEmu benchmark is run by this experiment.
