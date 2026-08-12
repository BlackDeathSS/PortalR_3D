# T3DRECOV

`T3DRECOV` is a deliberately non-restoring calculator-side inspector. It
validates the journal CRC, all five archived chunk sizes/CRCs, and the complete
snapshot CRC. It will never copy an unverified or incomplete snapshot over RAM.

Transfer `T3DBKM.8xv` and `T3DBK0.8xv` ... `T3DBK4.8xv` to a PC and use
`../tools/t3d2_recovery.py <directory> --extract snapshot.bin` for a verified
raw extraction. On-calculator `Del`, followed by a second confirmation, removes
the journal set only after inspection; `Clear` exits without changing it.

This utility does not make full-RAM takeover safe by itself. Raw restoration is
intentionally absent until the OS allowlist, protected restore stub, and reset
tests are complete.

The normal `T3D2DEV` build does not take over RAM and never creates `T3DBKM` or
`T3DBK0` ... `T3DBK4`. After resetting that build, the inspector is therefore
expected to say that the journal is missing and do nothing. It is not a generic
calculator-reset recovery program. Do not enable `FULL_TAKEOVER=1` to change
this: the engine deliberately rejects that unproven mode.
