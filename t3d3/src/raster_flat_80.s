	.section	.text._raster_flat_body_80,"ax",@progbits
	.assume	ADL = 1
	.globl	_raster_flat_body_80
	.type	_raster_flat_body_80,@function

/* Fill a clipped, flat-shaded body silhouette without returning to C for
 * every row. RenderLayer offsets are guarded by static assertions in
 * engine.c. All scalar ABI arguments occupy three stack bytes.
 *
 *   ix+6   RenderLayer *
 *   ix+9   first column
 *   ix+12  last column
 *   ix+15  first row
 *   ix+18  last row
 *   ix+21  last light row
 *   ix+24  has light rows
 *   ix+27  base color
 */
_raster_flat_body_80:
	ld	hl, -9
	call	__frameset
	ld	a, (ix + 15)
	ld	(ix - 1), a
	ld	a, (ix + 18)
	ld	(ix - 2), a

.Lflat_row:
	/* Intersect the body bounds with this row's portal/root aperture. */
	ld	iy, (ix + 6)
	ld	de, 1456
	add	iy, de
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, (ix + 9)
	cp	a, (iy)
	jr	nc, .Lflat_left_ready
	ld	a, (iy)
.Lflat_left_ready:
	ld	(ix - 3), a

	ld	iy, (ix + 6)
	ld	de, 1516
	add	iy, de
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, (ix + 12)
	cp	a, (iy)
	jr	c, .Lflat_right_ready
	jr	z, .Lflat_right_ready
	ld	a, (iy)
.Lflat_right_ready:
	ld	(ix - 4), a
	ld	c, (ix - 3)
	cp	a, c
	jr	c, .Lflat_next_row

	/* The upper quarter of the projected body uses the light shade. */
	ld	a, (ix + 27)
	add	a, 2
	ld	(ix - 5), a
	ld	a, (ix + 24)
	or	a, a
	jr	z, .Lflat_color_ready
	ld	a, (ix - 1)
	ld	c, a
	ld	a, (ix + 21)
	cp	a, c
	jr	c, .Lflat_color_ready
	ld	a, (ix + 27)
	add	a, 3
	ld	(ix - 5), a
.Lflat_color_ready:

	/* Resolve the logical row and duplicate the first pixel with LDIR. */
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
	ld	a, (ix - 3)
	ld	e, a
	add	iy, de
	ld	a, (ix - 5)
	ld	(iy), a
	ld	a, (ix - 4)
	sub	a, (ix - 3)
	jr	z, .Lflat_next_row
	ld	bc, 0
	ld	c, a
	lea	hl, iy + 0
	lea	de, iy + 1
	ldir

.Lflat_next_row:
	ld	a, (ix - 1)
	inc	a
	ld	(ix - 1), a
	ld	c, a
	ld	a, (ix - 2)
	cp	a, c
	jp	nc, .Lflat_row
	ld	sp, ix
	pop	ix
	ret

	.size	_raster_flat_body_80, .-_raster_flat_body_80
