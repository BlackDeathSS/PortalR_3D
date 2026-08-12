	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_t3d2_present_80x60
	.type	_t3d2_present_80x60,@function

	.macro	t3d2_present_pixel
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
	.endm

/* Expand 80x60 logical pixels to the 320x240 GraphX back buffer. */
_t3d2_present_80x60:
	push	ix
	ld	hl, _t3d2_root_color
	ld	de, (0xE30014)
	ld	ixh, 60

.Lpresent_row:
	.rept	80
	t3d2_present_pixel
	.endr

	/* Duplicate the expanded row three more times. */
	push	hl
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 960
	ldir
	pop	hl

	dec	ixh
	jp	nz, .Lpresent_row
	pop	ix
	ret
	.size	_t3d2_present_80x60, .-_t3d2_present_80x60

	.globl	_t3d2_clear_depth_80x60
	.type	_t3d2_clear_depth_80x60,@function
/* The reference raster treats zero as infinitely far away. */
_t3d2_clear_depth_80x60:
	ld	hl, _t3d2_root_depth
	ld	(hl), 0
	push	hl
	pop	de
	inc	de
	ld	bc, 9599
	ldir
	ret
	.size	_t3d2_clear_depth_80x60, .-_t3d2_clear_depth_80x60
