	.section	.text._raster_fill_root_segment_80,"ax",@progbits
	.assume	ADL = 1
	.globl	_raster_fill_root_segment_80
	.type	_raster_fill_root_segment_80,@function

/* Root-only 80x60 scan conversion.  The root layer always clips to [0,79],
 * so this kernel omits two aperture-array lookups and keeps a running logical
 * row pointer instead of resolving low_row_offsets on every scanline.
 *
 * C ABI (three stack bytes per argument):
 *   ix+6   first RasterChain *
 *   ix+9   second RasterChain *
 *   ix+12  first row
 *   ix+15  last row
 *   ix+18  base color
 *   ix+21  horizon shaded flag
 */
_raster_fill_root_segment_80:
	ld	hl, -15
	call	__frameset
	ld	a, (ix + 12)
	ld	(ix - 1), a
	ld	a, (ix + 15)
	ld	(ix - 2), a
	ld	a, (ix + 18)
	ld	(ix - 3), a

	/* Cache the first logical row address; subsequent rows are exactly 80
	 * bytes apart in native 80x60 mode. */
	ld	iy, _low_row_offsets
	ld	de, 0
	ld	a, (ix - 1)
	add	a, a
	ld	e, a
	add	iy, de
	ld	de, 0
	ld	e, (iy)
	ld	d, (iy + 1)
	ld	hl, _low_frame+2
	add	hl, de
	ld	(ix - 15), hl

.Lroot_fill_row:
	/* Sort the signed Q8 intersections. */
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	iy, (ix + 9)
	ld	de, (iy + 4)
	or	a, a
	sbc	hl, de
	jp	m, .Lroot_first_is_left
	ld	iy, (ix + 9)
	ld	hl, (iy + 4)
	ld	(ix - 9), hl
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	(ix - 12), hl
	jr	.Lroot_convert_first
.Lroot_first_is_left:
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	(ix - 9), hl
	ld	iy, (ix + 9)
	ld	hl, (iy + 4)
	ld	(ix - 12), hl

.Lroot_convert_first:
	/* Exact raster_first_column for the fixed 80-pixel root width. */
	ld	hl, (ix - 9)
	ld	de, -127
	or	a, a
	sbc	hl, de
	jp	m, .Lroot_first_zero
	ld	hl, (ix - 9)
	ld	de, 127
	add	hl, de
	ld	de, 0x5000
	or	a, a
	sbc	hl, de
	jp	p, .Lroot_first_width
	add	hl, de
	ld	a, h
	jr	.Lroot_first_done
.Lroot_first_zero:
	xor	a, a
	jr	.Lroot_first_done
.Lroot_first_width:
	ld	a, 80
.Lroot_first_done:
	ld	(ix - 4), a

	/* Exact raster_last_column, with 255 as the empty sentinel. */
	ld	hl, (ix - 12)
	ld	de, 128
	or	a, a
	sbc	hl, de
	jp	m, .Lroot_last_empty
	ld	de, 0x5000
	or	a, a
	sbc	hl, de
	jp	p, .Lroot_last_width
	add	hl, de
	ld	a, h
	jr	.Lroot_last_done
.Lroot_last_empty:
	ld	a, 255
	jr	.Lroot_last_done
.Lroot_last_width:
	ld	a, 79
.Lroot_last_done:
	ld	(ix - 5), a
	cp	a, 255
	jp	z, .Lroot_advance
	ld	a, (ix - 4)
	cp	a, 80
	jp	nc, .Lroot_advance
	ld	c, a
	ld	a, (ix - 5)
	cp	a, c
	jp	c, .Lroot_advance

	/* Floors and ceilings use the precomputed horizon shade subtraction. */
	ld	a, (ix - 3)
	ld	c, a
	ld	a, (ix + 21)
	or	a, a
	ld	a, c
	jr	z, .Lroot_color_ready
	ld	iy, _horizon_light_subtract
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, c
	sub	a, (iy)
.Lroot_color_ready:
	ld	(ix - 6), a

	/* Fill the inclusive span from the cached row base. */
	ld	iy, (ix - 15)
	ld	de, 0
	ld	a, (ix - 4)
	ld	e, a
	add	iy, de
	ld	a, (ix - 6)
	ld	(iy), a
	ld	a, (ix - 5)
	sub	a, (ix - 4)
	jr	z, .Lroot_advance
	ld	bc, 0
	ld	c, a
	lea	hl, iy + 0
	lea	de, iy + 1
	ldir

.Lroot_advance:
	/* Advance both active edges exactly as the reference C rasterizer does. */
	ld	iy, (ix + 6)
	ld	a, (ix - 1)
	cp	a, (iy + 3)
	jr	nc, .Lroot_second_advance
	ld	hl, (iy + 4)
	ld	de, (iy + 7)
	add	hl, de
	ld	(iy + 4), hl
.Lroot_second_advance:
	ld	iy, (ix + 9)
	ld	a, (ix - 1)
	cp	a, (iy + 3)
	jr	nc, .Lroot_next_row
	ld	hl, (iy + 4)
	ld	de, (iy + 7)
	add	hl, de
	ld	(iy + 4), hl

.Lroot_next_row:
	ld	hl, (ix - 15)
	ld	de, 80
	add	hl, de
	ld	(ix - 15), hl
	ld	a, (ix - 1)
	inc	a
	ld	(ix - 1), a
	ld	c, a
	ld	a, (ix - 2)
	cp	a, c
	jp	nc, .Lroot_fill_row
	ld	sp, ix
	pop	ix
	ret

	.size	_raster_fill_root_segment_80, .-_raster_fill_root_segment_80
