	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_present_low_frame_fast
	.type	_present_low_frame_fast,@function
	.globl	_present_low_frame_32_fast
	.type	_present_low_frame_32_fast,@function

	/* One 5x horizontal expansion.  HL is the source pointer and DE is the
	 * destination pointer.  Expanding this macro 64 times removes both DJNZ
	 * and the indexed-source penalty while retaining the exact five byte
	 * stores of the production presenter. */
	.macro	present_byte_pixel
	ld	a, (hl)
	inc	hl
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	.endm

/* Expand the 64x48 software framebuffer to the hidden 320x240 VRAM page.
 * Every source pixel becomes 5x5 physical pixels. */
_present_low_frame_fast:
	push	ix
	ld	hl, _low_frame + 2
	ld	de, (0xE30014)
	ld	ixh, 48

.Lpresent_row:
	.rept	64
	present_byte_pixel
	.endr

	/* Replicate the expanded row four more times.  The forward-overlapping
	 * LDIR reads each completed 320-byte row while writing the next one.
	 * Preserve the next logical source row while HL is reused by LDIR. */
	push	hl
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 1280
	ldir
	pop	hl

	dec	ixh
	jp	nz, .Lpresent_row

	pop	ix
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
.Lpresent32_pixel:
	ld	a, (iy)
	inc	iy
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	djnz	.Lpresent32_pixel

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
