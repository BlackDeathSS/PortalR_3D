	.section	.text._raster_fill_segment_80,"ax",@progbits
	.assume	ADL = 1
	.globl	_raster_fill_segment_80
	.type	_raster_fill_segment_80,@function

/* Draw one row interval for two already-active convex polygon chains.
 * Structure offsets are guarded by C static assertions in engine.c.
 *
 * C ABI (three stack bytes per argument):
 *   ix+6   first RasterChain *
 *   ix+9   second RasterChain *
 *   ix+12  RenderLayer *
 *   ix+15  first row
 *   ix+18  last row
 *   ix+21  base color
 *   ix+24  horizon shaded flag
 */
_raster_fill_segment_80:
	ld	hl, -12
	call	__frameset
	ld	a, (ix + 15)
	ld	(ix - 1), a
	ld	a, (ix + 18)
	ld	(ix - 2), a
	ld	a, (ix + 21)
	ld	(ix - 3), a

.Lfill_row:
	/* Sort the two signed Q8 intersections. Their clamped range makes the
	 * 24-bit subtraction safe from signed overflow. */
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	iy, (ix + 9)
	ld	de, (iy + 4)
	or	a, a
	sbc	hl, de
	jp	m, .Lfill_first_is_left
	ld	iy, (ix + 9)
	ld	hl, (iy + 4)
	ld	(ix - 9), hl
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	(ix - 12), hl
	jr	.Lfill_convert_first
.Lfill_first_is_left:
	ld	iy, (ix + 6)
	ld	hl, (iy + 4)
	ld	(ix - 9), hl
	ld	iy, (ix + 9)
	ld	hl, (iy + 4)
	ld	(ix - 12), hl

.Lfill_convert_first:
	/* Exact raster_first_column: clip ceil((x-128)/256) to [0,width]. */
	ld	hl, (ix - 9)
	ld	de, -127
	or	a, a
	sbc	hl, de
	jp	m, .Lfill_first_zero
	ld	hl, (ix - 9)
	ld	de, 127
	add	hl, de
	ld	de, 0
	ld	a, (_active_render_width)
	ld	d, a
	or	a, a
	sbc	hl, de
	jp	p, .Lfill_first_width
	add	hl, de
	ld	a, h
	jr	.Lfill_first_done
.Lfill_first_zero:
	xor	a, a
	jr	.Lfill_first_done
.Lfill_first_width:
	ld	a, (_active_render_width)
.Lfill_first_done:
	ld	(ix - 4), a

	/* Exact raster_last_column: negative values use the 255 sentinel. */
	ld	hl, (ix - 12)
	ld	de, 128
	or	a, a
	sbc	hl, de
	jp	m, .Lfill_last_empty
	ld	de, 0
	ld	a, (_active_render_width)
	ld	d, a
	or	a, a
	sbc	hl, de
	jp	p, .Lfill_last_width
	add	hl, de
	ld	a, h
	jr	.Lfill_last_done
.Lfill_last_empty:
	ld	a, 255
	jr	.Lfill_last_done
.Lfill_last_width:
	ld	a, (_active_render_width)
	dec	a
.Lfill_last_done:
	ld	(ix - 5), a
	cp	a, 255
	jp	z, .Lfill_advance
	ld	a, (ix - 4)
	ld	bc, 0
	ld	c, a
	ld	a, (_active_render_width)
	cp	a, c
	jp	z, .Lfill_advance
	jp	c, .Lfill_advance

	/* Intersect with the exact per-row portal/root aperture. */
	ld	iy, (ix + 12)
	ld	de, 1456
	add	iy, de
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, (ix - 4)
	cp	a, (iy)
	jr	nc, .Lfill_left_clipped
	ld	a, (iy)
	ld	(ix - 4), a
.Lfill_left_clipped:
	ld	iy, (ix + 12)
	ld	de, 1516
	add	iy, de
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, (ix - 5)
	cp	a, (iy)
	jr	c, .Lfill_right_clipped
	jr	z, .Lfill_right_clipped
	ld	a, (iy)
	ld	(ix - 5), a
.Lfill_right_clipped:
	ld	a, (ix - 5)
	ld	c, (ix - 4)
	cp	a, c
	jp	c, .Lfill_advance

	/* Floors and ceilings use base_color minus the precomputed 0..2 row
	 * subtraction. Other faces keep their constant base color. */
	ld	a, (ix - 3)
	ld	c, a
	ld	a, (ix + 24)
	or	a, a
	ld	a, c
	jr	z, .Lfill_color_ready
	ld	iy, _horizon_light_subtract
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, c
	sub	a, (iy)
.Lfill_color_ready:
	ld	(ix - 6), a

	/* Resolve the logical row address and fill inclusively. LDIR starts at
	 * the second pixel, so a one-pixel span does not enter it. */
	ld	iy, _low_row_offsets
	ld	de, 0
	ld	a, (ix - 1)
	add	a, a
	ld	e, a
	add	iy, de
	ld	de, 0
	ld	e, (iy)
	ld	d, (iy + 1)
	ld	iy, _low_frame+2
	add	iy, de
	ld	de, 0
	ld	a, (ix - 4)
	ld	e, a
	add	iy, de
	ld	a, (ix - 6)
	ld	(iy), a
	ld	a, (ix - 5)
	sub	a, (ix - 4)
	jr	z, .Lfill_advance
	ld	bc, 0
	ld	c, a
	lea	hl, iy + 0
	lea	de, iy + 1
	ldir

.Lfill_advance:
	/* Match the C rule: advance a chain only when another sampled row lies
	 * on its current edge. */
	ld	iy, (ix + 6)
	ld	a, (ix - 1)
	cp	a, (iy + 3)
	jr	nc, .Lfill_second_advance
	ld	hl, (iy + 4)
	ld	de, (iy + 7)
	add	hl, de
	ld	(iy + 4), hl
.Lfill_second_advance:
	ld	iy, (ix + 9)
	ld	a, (ix - 1)
	cp	a, (iy + 3)
	jr	nc, .Lfill_next_row
	ld	hl, (iy + 4)
	ld	de, (iy + 7)
	add	hl, de
	ld	(iy + 4), hl

.Lfill_next_row:
	ld	a, (ix - 1)
	inc	a
	ld	(ix - 1), a
	ld	c, a
	ld	a, (ix - 2)
	cp	a, c
	jp	nc, .Lfill_row
	ld	sp, ix
	pop	ix
	ret

	.size	_raster_fill_segment_80, .-_raster_fill_segment_80
