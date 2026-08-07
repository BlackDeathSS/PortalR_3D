	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_present_low_frame_fast
	.type	_present_low_frame_fast,@function
	.globl	_present_low_frame_32_fast
	.type	_present_low_frame_32_fast,@function

/* Expand the 64x48 software framebuffer to the hidden 320x240 VRAM page.
 * Every source pixel becomes 5x5 physical pixels. */
_present_low_frame_fast:
	push	iy
	ld	iy, _low_frame + 2
	ld	de, (0xE30014)
	ld	bc, 48

.Lpresent_row:
	push	bc
	ld	b, 64
.Lpresent_run:
	ld	a, (iy)
	inc	iy
	ld	c, 1
	dec	b
	jr	z, .Lpresent_emit_run
.Lpresent_scan_run:
	cp	a, (iy)
	jr	nz, .Lpresent_emit_run
	inc	iy
	inc	c
	djnz	.Lpresent_scan_run
.Lpresent_emit_run:
	/* BC currently holds remaining logical pixels in B and the run length in
	 * C.  Preserve it, then expand one seed byte across run_length*5 bytes
	 * with a forward-overlapping LDIR.  UBC is zero from the row counter. */
	push	bc
	ld	b, 5
	mlt	bc
	dec	bc
	ld	(de), a
	inc	de
	push	de
	pop	hl
	dec	hl
	ldir
	pop	bc
	ld	a, b
	or	a, a
	jr	nz, .Lpresent_run

	/* Replicate the expanded row four more times.  The forward-overlapping
	 * LDIR reads each completed 320-byte row while writing the next one. */
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 1280
	ldir

	pop	bc
	dec	c
	jr	nz, .Lpresent_row

	pop	iy
	ret
	.size	_present_low_frame_fast, .-_present_low_frame_fast

/* Expand the packed 32x24 performance framebuffer to 320x240.
 * Every source pixel becomes 10x10 physical pixels. */
_present_low_frame_32_fast:
	push	iy
	ld	iy, _low_frame + 2
	ld	de, (0xE30014)
	ld	bc, 24

.Lpresent32_row:
	push	bc
	ld	b, 32
.Lpresent32_run:
	ld	a, (iy)
	inc	iy
	ld	c, 1
	dec	b
	jr	z, .Lpresent32_emit_run
.Lpresent32_scan_run:
	cp	a, (iy)
	jr	nz, .Lpresent32_emit_run
	inc	iy
	inc	c
	djnz	.Lpresent32_scan_run
.Lpresent32_emit_run:
	push	bc
	ld	b, 10
	mlt	bc
	dec	bc
	ld	(de), a
	inc	de
	push	de
	pop	hl
	dec	hl
	ldir
	pop	bc
	ld	a, b
	or	a, a
	jr	nz, .Lpresent32_run

	/* Replicate the expanded row nine more times with one forward-overlapping
	 * transfer. */
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 2880
	ldir

	pop	bc
	dec	c
	jp	nz, .Lpresent32_row

	pop	iy
	ret
	.size	_present_low_frame_32_fast, .-_present_low_frame_32_fast
