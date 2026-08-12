	.section	.text._raster_fill_lod_segment_80,"ax",@progbits
	.assume	ADL = 1
	.globl	_raster_fill_lod_segment_80
	.type	_raster_fill_lod_segment_80,@function

/* Scan and fill one active edge interval in a half- or quarter-resolution
 * portal destination. The kernel also clamps to the portal bounding box,
 * avoiding scratch pixels which can never be composited.
 *
 *   ix+6   first RasterChain *
 *   ix+9   second RasterChain *
 *   ix+12  RenderLayer *
 *   ix+15  first logical sample row
 *   ix+18  last logical sample row
 *   ix+21  base color
 *   ix+24  horizon shaded flag
 *   ix+27  LOD shift (1 or 2)
 */
_raster_fill_lod_segment_80:
	ld	hl, -12
	call	__frameset
	ld	a, (ix + 15)
	ld	(ix - 1), a
	ld	a, (ix + 18)
	ld	(ix - 2), a
	ld	a, (ix + 21)
	ld	(ix - 3), a

.Llod_row:
	/* Sort signed Q8 intersections. */
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	iy, (ix + 9)
	ld	de, (iy + 4)
	or	a, a
	sbc	hl, de
	jp	m, .Llod_first_is_left
	ld	iy, (ix + 9)
	ld	hl, (iy + 4)
	ld	(ix - 9), hl
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	(ix - 12), hl
	jr	.Llod_convert_first
.Llod_first_is_left:
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	(ix - 9), hl
	ld	iy, (ix + 9)
	ld	hl, (iy + 4)
	ld	(ix - 12), hl

.Llod_convert_first:
	/* raster_first_column: ceil((x-128)/256), clipped to [0,80]. */
	ld	hl, (ix - 9)
	ld	de, -127
	or	a, a
	sbc	hl, de
	jp	m, .Llod_first_zero
	ld	hl, (ix - 9)
	ld	de, 127
	add	hl, de
	ld	de, 0x5000
	or	a, a
	sbc	hl, de
	jp	p, .Llod_first_width
	add	hl, de
	ld	a, h
	jr	.Llod_first_done
.Llod_first_zero:
	xor	a, a
	jr	.Llod_first_done
.Llod_first_width:
	ld	a, 80
.Llod_first_done:
	ld	(ix - 4), a

	/* raster_last_column: negative values retain the empty 255 sentinel. */
	ld	hl, (ix - 12)
	ld	de, 128
	or	a, a
	sbc	hl, de
	jp	m, .Llod_last_empty
	ld	de, 0x5000
	or	a, a
	sbc	hl, de
	jp	p, .Llod_last_width
	add	hl, de
	ld	a, h
	jr	.Llod_last_done
.Llod_last_empty:
	ld	a, 255
	jr	.Llod_last_done
.Llod_last_width:
	ld	a, 79
.Llod_last_done:
	ld	(ix - 5), a
	cp	a, 255
	jp	z, .Llod_advance
	ld	a, (ix - 4)
	cp	a, 80
	jp	nc, .Llod_advance

	/* Clamp to the only columns the portal compositor can consume. */
	ld	iy, (ix + 12)
	ld	de, 1580
	add	iy, de
	ld	a, (ix - 4)
	cp	a, (iy)
	jr	nc, .Llod_left_bound_ready
	ld	a, (iy)
	ld	(ix - 4), a
.Llod_left_bound_ready:
	ld	a, (ix - 5)
	cp	a, (iy + 1)
	jr	c, .Llod_right_bound_ready
	jr	z, .Llod_right_bound_ready
	ld	a, (iy + 1)
	ld	(ix - 5), a
.Llod_right_bound_ready:

	/* Convert logical columns to the packed 40-byte-stride scratch plane. */
	ld	a, (ix + 27)
	cp	a, 1
	jr	z, .Llod_half_columns
	ld	a, (ix - 5)
	cp	a, 2
	jp	c, .Llod_advance
	sub	a, 2
	srl	a
	srl	a
	ld	(ix - 5), a
	ld	a, (ix - 4)
	inc	a
	srl	a
	srl	a
	ld	(ix - 4), a
	jr	.Llod_columns_ready
.Llod_half_columns:
	ld	a, (ix - 5)
	cp	a, 1
	jp	c, .Llod_advance
	dec	a
	srl	a
	ld	(ix - 5), a
	ld	a, (ix - 4)
	srl	a
	ld	(ix - 4), a
.Llod_columns_ready:
	ld	a, (ix - 5)
	ld	c, (ix - 4)
	cp	a, c
	jp	c, .Llod_advance

	/* Select the exact source-row shade before reducing the row index. */
	ld	a, (ix - 3)
	ld	c, a
	ld	a, (ix + 24)
	or	a, a
	ld	a, c
	jr	z, .Llod_color_ready
	ld	iy, _horizon_light_subtract
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, c
	sub	a, (iy)
.Llod_color_ready:
	ld	(ix - 7), a

	/* target = portal_lod_frame + (row >> shift) * 40 + first. */
	ld	a, (ix - 1)
	ld	c, (ix + 27)
.Llod_shift_row:
	srl	a
	dec	c
	jr	nz, .Llod_shift_row
	ld	de, 0
	ld	d, 40
	ld	e, a
	mlt	de
	ld	iy, _portal_lod_frame
	add	iy, de
	ld	de, 0
	ld	e, (ix - 4)
	add	iy, de
	ld	a, (ix - 7)
	ld	(iy), a
	ld	a, (ix - 5)
	sub	a, (ix - 4)
	jr	z, .Llod_advance
	ld	bc, 0
	ld	c, a
	lea	hl, iy + 0
	lea	de, iy + 1
	ldir

.Llod_advance:
	/* x_advance already contains x_step * sample_step. */
	ld	a, (ix - 1)
	ld	c, a
	ld	a, (ix + 27)
	cp	a, 1
	ld	a, c
	jr	nz, .Llod_add_four
	add	a, 2
	jr	.Llod_next_sample_ready
.Llod_add_four:
	add	a, 4
.Llod_next_sample_ready:
	ld	c, a
	ld	iy, (ix + 6)
	ld	a, (iy + 3)
	cp	a, c
	jr	c, .Llod_second_advance
	ld	hl, (iy + 4)
	ld	de, (iy + 7)
	add	hl, de
	ld	(iy + 4), hl
.Llod_second_advance:
	ld	iy, (ix + 9)
	ld	a, (iy + 3)
	cp	a, c
	jr	c, .Llod_next_row
	ld	hl, (iy + 4)
	ld	de, (iy + 7)
	add	hl, de
	ld	(iy + 4), hl
.Llod_next_row:
	ld	a, c
	ld	(ix - 1), a
	ld	c, a
	ld	a, (ix - 2)
	cp	a, c
	jp	nc, .Llod_row
	ld	sp, ix
	pop	ix
	ret

	.size	_raster_fill_lod_segment_80, .-_raster_fill_lod_segment_80
