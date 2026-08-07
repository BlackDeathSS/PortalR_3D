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
.Lpresent_pixel:
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
	djnz	.Lpresent_pixel

	/* Copy the expanded row four more times. */
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 320
	ldir
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 320
	ldir
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 320
	ldir
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 320
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

	/* Copy the expanded row nine more times. */
	.rept	9
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 320
	ldir
	.endr

	pop	bc
	dec	c
	jp	nz, .Lpresent32_row

	pop	iy
	ret
	.size	_present_low_frame_32_fast, .-_present_low_frame_32_fast
