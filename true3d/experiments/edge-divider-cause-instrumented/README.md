# Edge fallback cause diagnostic

This is an optional live-benchmark-only diagnostic build.  It leaves every
rendering calculation unchanged, but temporarily packs three per-frame cause
counts into the existing `edge_division_fallbacks` field:

```text
short dy (<256)       = packed & 31
tall dy (table miss)  = (packed >> 5) & 31
wide dx               = (packed >> 10) & 31
total                 = short + tall + wide
```

The precedence is the same as the renderer's fallback predicate, so each
fallback belongs to exactly one bucket.  Do not compare this build's raw
`edge_division_fallbacks` number with a normal benchmark; unpack it first.
No root source is modified by this diagnostic.
