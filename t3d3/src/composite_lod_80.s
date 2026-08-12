	.section	.text._composite_portal_lod_80,"ax",@progbits
	.assume	ADL = 1
	.globl	_composite_portal_lod_80
	.type	_composite_portal_lod_80,@function

/* Expand the packed half/quarter portal scratch plane only through the exact
 * row aperture. The source has a fixed 40-byte stride at both LODs.
 *
 *   ix+6  RenderLayer *
 *   ix+9  LOD shift (1 or 2)
 */
_composite_portal_lod_80:
	ld	hl, -8
	call	__frameset
	ld	iy, (ix + 6)
	ld	de, 1578
	add	iy, de
	ld	a, (iy)
	ld	(ix - 1), a
	ld	a, (iy + 1)
	ld	(ix - 2), a

.Lcomp_row:
	ld	iy, (ix + 6)
	ld	de, 1456
	add	iy, de
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, (iy)
	ld	(ix - 3), a
	ld	iy, (ix + 6)
	ld	de, 1516
	add	iy, de
	ld	de, 0
	ld	a, (ix - 1)
	ld	e, a
	add	iy, de
	ld	a, (iy)
	ld	(ix - 4), a
	ld	c, (ix - 3)
	cp	a, c
	jp	c, .Lcomp_next_row
	sub	a, c
	inc	a
	ld	(ix - 5), a

	/* HL = logical destination row + left column. */
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
	ld	de, 0
	ld	e, (ix - 3)
	add	hl, de

	/* IY = packed source row + source column. */
	ld	a, (ix - 1)
	ld	c, (ix + 9)
.Lcomp_shift_row:
	srl	a
	dec	c
	jr	nz, .Lcomp_shift_row
	ld	de, 0
	ld	d, 40
	ld	e, a
	mlt	de
	ld	iy, _portal_lod_frame
	add	iy, de
	ld	a, (ix - 3)
	ld	c, (ix + 9)
.Lcomp_shift_column:
	srl	a
	dec	c
	jr	nz, .Lcomp_shift_column
	ld	de, 0
	ld	e, a
	add	iy, de

	ld	a, (ix + 9)
	cp	a, 1
	jr	nz, .Lcomp_quarter

	/* Half LOD: finish an odd leading pixel, then duplicate pairs. */
	ld	a, (ix - 3)
	and	a, 1
	jr	z, .Lcomp_half_pairs
	ld	a, (iy)
	ld	(hl), a
	inc	hl
	inc	iy
	ld	a, (ix - 5)
	dec	a
	ld	(ix - 5), a
	jp	z, .Lcomp_next_row
.Lcomp_half_pairs:
	ld	a, (ix - 5)
	cp	a, 2
	jr	c, .Lcomp_half_tail
	ld	a, (iy)
	inc	iy
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	a, (ix - 5)
	sub	a, 2
	ld	(ix - 5), a
	jr	.Lcomp_half_pairs
.Lcomp_half_tail:
	or	a, a
	jp	z, .Lcomp_next_row
	ld	a, (iy)
	ld	(hl), a
	jp	.Lcomp_next_row

.Lcomp_quarter:
	/* Finish the leading partial four-pixel source group. */
	ld	a, (ix - 3)
	and	a, 3
	jr	z, .Lcomp_quarter_groups
	ld	c, a
	ld	a, 4
	sub	a, c
	ld	(ix - 6), a
	ld	a, (iy)
	ld	(ix - 7), a
.Lcomp_quarter_lead:
	ld	a, (ix - 7)
	ld	(hl), a
	inc	hl
	ld	a, (ix - 5)
	dec	a
	ld	(ix - 5), a
	jp	z, .Lcomp_next_row
	ld	a, (ix - 6)
	dec	a
	ld	(ix - 6), a
	jr	nz, .Lcomp_quarter_lead
	inc	iy

.Lcomp_quarter_groups:
	ld	a, (ix - 5)
	cp	a, 4
	jr	c, .Lcomp_quarter_tail
	ld	a, (iy)
	inc	iy
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	a, (ix - 5)
	sub	a, 4
	ld	(ix - 5), a
	jr	.Lcomp_quarter_groups
.Lcomp_quarter_tail:
	or	a, a
	jr	z, .Lcomp_next_row
	ld	c, a
	ld	a, (iy)
.Lcomp_quarter_tail_loop:
	ld	(hl), a
	inc	hl
	dec	c
	jr	nz, .Lcomp_quarter_tail_loop

.Lcomp_next_row:
	ld	a, (ix - 1)
	inc	a
	ld	(ix - 1), a
	ld	c, a
	ld	a, (ix - 2)
	cp	a, c
	jp	nc, .Lcomp_row
	ld	sp, ix
	pop	ix
	ret

	.size	_composite_portal_lod_80, .-_composite_portal_lod_80
