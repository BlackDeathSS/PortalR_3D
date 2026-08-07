	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_present_low_frame_fast
	.type	_present_low_frame_fast,@function
	.globl	_present_low_frame_32_fast
	.type	_present_low_frame_32_fast,@function
	.globl	_present_init_color_table
	.type	_present_init_color_table,@function

	/* The program owns the calculator RAM arena while it runs.  Keep the
	 * replicated-color lookup on a 64 KiB boundary so MLT HL can replace only
	 * HL[15:0] with 3*color while retaining UHL=0xD1.  The current linked BSS
	 * ends below 0xD10000 and the program performs no dynamic allocation. */
	.equ	PRESENT_COLOR_TABLE, 0xD10000

	/* One cached 24-bit color write.  BC contains the preceding packed color,
	 * so C is also the preceding eight-bit palette index. */
	.macro	present_wide_pixel offset
	ld	a, (de)
	inc	de
	cp	a, c
	jr	z, .Lpresent_packed_\@
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	bc, (hl)
.Lpresent_packed_\@:
	ld	(iy + \offset), bc
	ld	(iy + \offset + 2), bc
	.endm

	/* The first pixel of each row cannot reuse BC because vertical LDIR leaves
	 * it at zero. */
	.macro	present_wide_first offset
	ld	a, (de)
	inc	de
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	bc, (hl)
	ld	(iy + \offset), bc
	ld	(iy + \offset + 2), bc
	.endm

/* Initialize 256 little-endian CCC entries.  This runs once at graphics
 * startup, outside the timed presenter. */
_present_init_color_table:
	ld	hl, PRESENT_COLOR_TABLE
	xor	a, a
.Lpresent_init_color:
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	inc	a
	jr	nz, .Lpresent_init_color
	ret
	.size	_present_init_color_table, .-_present_init_color_table

/* Expand the 64x48 software framebuffer to the hidden 320x240 VRAM page.
 * Every source pixel becomes 5x5 physical pixels. */
_present_low_frame_fast:
	push	iy
	push	ix
	ld	de, _low_frame + 2
	ld	iy, (0xE30014)
	ld	ixh, 48

.Lpresent_row:
	ld	hl, PRESENT_COLOR_TABLE

	/* Twenty-five pixels fit in signed IY displacements 0..122. */
	present_wide_first 0
	present_wide_pixel 5
	present_wide_pixel 10
	present_wide_pixel 15
	present_wide_pixel 20
	present_wide_pixel 25
	present_wide_pixel 30
	present_wide_pixel 35
	present_wide_pixel 40
	present_wide_pixel 45
	present_wide_pixel 50
	present_wide_pixel 55
	present_wide_pixel 60
	present_wide_pixel 65
	present_wide_pixel 70
	present_wide_pixel 75
	present_wide_pixel 80
	present_wide_pixel 85
	present_wide_pixel 90
	present_wide_pixel 95
	present_wide_pixel 100
	present_wide_pixel 105
	present_wide_pixel 110
	present_wide_pixel 115
	present_wide_pixel 120
	lea	iy, iy + 125

	present_wide_pixel 0
	present_wide_pixel 5
	present_wide_pixel 10
	present_wide_pixel 15
	present_wide_pixel 20
	present_wide_pixel 25
	present_wide_pixel 30
	present_wide_pixel 35
	present_wide_pixel 40
	present_wide_pixel 45
	present_wide_pixel 50
	present_wide_pixel 55
	present_wide_pixel 60
	present_wide_pixel 65
	present_wide_pixel 70
	present_wide_pixel 75
	present_wide_pixel 80
	present_wide_pixel 85
	present_wide_pixel 90
	present_wide_pixel 95
	present_wide_pixel 100
	present_wide_pixel 105
	present_wide_pixel 110
	present_wide_pixel 115
	present_wide_pixel 120
	lea	iy, iy + 125

	present_wide_pixel 0
	present_wide_pixel 5
	present_wide_pixel 10
	present_wide_pixel 15
	present_wide_pixel 20
	present_wide_pixel 25
	present_wide_pixel 30
	present_wide_pixel 35
	present_wide_pixel 40
	present_wide_pixel 45
	present_wide_pixel 50
	present_wide_pixel 55
	present_wide_pixel 60
	present_wide_pixel 65
	lea	iy, iy + 70

	/* Replicate the expanded row four more times.  The forward-overlapping
	 * LDIR reads each completed 320-byte row while writing the next one. */
	push	de
	lea	de, iy + 0
	lea	hl, iy + 0
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 1280
	add	iy, bc
	ldir
	pop	de

	dec	ixh
	jp	nz, .Lpresent_row

	pop	ix
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
