	.section	.text._fill_root_color_rows_exact,"ax",@progbits
	.assume	ADL = 1
	.globl	_fill_root_color_rows_exact
	.type	_fill_root_color_rows_exact,@function
	.extern	__frameset0

/* Fill an unclipped, solid root-layer polygon row band exactly.
 *
 * The C root fast path guarantees a 64x48 target and supplies only rows
 * between polygon->first_row and polygon->last_row.  Each valid convex row is
 * one inclusive [left,right] span.  Keeping both span cursors in the alternate
 * register set avoids rebuilding row offsets and calling memset once per row.
 * A forward-overlapping LDIR broadcasts the first color byte across the span.
 *
 * C ABI arguments:
 *   ix+6   DrawPolygon *polygon
 *   ix+9   uint8_t first_row
 *   ix+12  uint8_t row_count (nonzero)
 *   ix+15  uint8_t color
 *
 * DrawPolygon layout used here is guarded by C static assertions:
 *   span_left  offset 48
 *   span_right offset 96
 */
_fill_root_color_rows_exact:
	call	__frameset0

	/* IY = first target row. */
	ld	hl, 0
	ld	l, (ix + 9)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, _low_frame + 2
	add	hl, de
	push	hl
	pop	iy

	/* HL/DE are the left/right span cursors.  Park them in the alternate set
	 * while the primary registers drive LDIR. */
	ld	hl, 0
	ld	l, (ix + 9)
	ld	de, (ix + 6)
	add	hl, de
	ld	de, 48
	add	hl, de
	push	hl
	ld	bc, 48
	add	hl, bc
	ex	de, hl
	pop	hl
	exx

.Lroot_row:
	/* Read one inclusive span and pack width:left into B:C. */
	exx
	ld	bc, 0
	ld	c, (hl)
	inc	hl
	ld	a, (de)
	inc	de
	sub	a, c
	jr	nc, .Lroot_valid_span
	xor	a, a
	jr	.Lroot_span_ready
.Lroot_valid_span:
	inc	a
.Lroot_span_ready:
	ld	b, a
	push	bc
	exx
	pop	bc

	/* Invalid rows are represented as left=255,right=0 and remain untouched. */
	ld	a, b
	or	a, a
	jr	z, .Lroot_next_row

	/* DE = row base + left. */
	push	iy
	pop	de
	ld	hl, 0
	ld	l, c
	add	hl, de
	ex	de, hl

	/* Seed one byte, then duplicate it forward over width-1 bytes. */
	ld	a, (ix + 15)
	ld	(de), a
	ld	c, b
	ld	b, 0
	dec	c
	jr	z, .Lroot_next_row
	push	de
	pop	hl
	inc	de
	ldir

.Lroot_next_row:
	lea	iy, iy + 64
	dec	(ix + 12)
	jp	nz, .Lroot_row

	pop	ix
	ret
	.size	_fill_root_color_rows_exact, .-_fill_root_color_rows_exact

	.section	.text._fill_clipped_color_rows_exact,"ax",@progbits
	.globl	_fill_clipped_color_rows_exact
	.type	_fill_clipped_color_rows_exact,@function

/* Fill a solid child-layer row band after intersecting each polygon span with
 * the portal clip span.  The pointer set lives in alternate HL/DE/BC while
 * the primary registers perform the same exact inclusive span broadcast.
 *
 * C ABI arguments:
 *   ix+6   DrawPolygon *polygon
 *   ix+9   RenderLayer *layer
 *   ix+12  uint8_t first_row
 *   ix+15  uint8_t row_count (nonzero)
 *   ix+18  uint8_t color
 */
_fill_clipped_color_rows_exact:
	ld	hl, -4
	call	__frameset

	/* HL/DE = polygon left/right cursors. */
	ld	hl, 0
	ld	l, (ix + 12)
	ld	de, (ix + 6)
	add	hl, de
	ld	de, 48
	add	hl, de
	push	hl
	ld	de, 48
	add	hl, de
	ex	de, hl
	pop	hl

	/* BC = layer clip-left cursor. */
	push	hl
	push	de
	ld	hl, 0
	ld	l, (ix + 12)
	ld	de, (ix + 9)
	add	hl, de
	ld	de, 1264
	add	hl, de
	push	hl
	pop	bc
	pop	de
	pop	hl
	exx

	/* IY = first target row. */
	ld	hl, 0
	ld	l, (ix + 12)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, _low_frame + 2
	add	hl, de
	push	hl
	pop	iy

.Lclipped_row:
	/* Advance all three state cursors and cache the four one-byte bounds. */
	exx
	ld	a, (hl)
	inc	hl
	ld	(ix - 1), a
	ld	a, (de)
	inc	de
	ld	(ix - 2), a
	ld	a, (bc)
	ld	(ix - 3), a
	push	hl
	ld	hl, 48
	add	hl, bc
	ld	a, (hl)
	pop	hl
	ld	(ix - 4), a
	inc	bc
	exx

	/* C=max(polygon_left,clip_left), B=min(polygon_right,clip_right). */
	ld	bc, 0
	ld	a, (ix - 1)
	ld	c, a
	ld	a, (ix - 3)
	cp	a, c
	jr	c, .Lclipped_left_ready
	ld	c, a
.Lclipped_left_ready:
	ld	a, (ix - 2)
	ld	b, a
	ld	a, (ix - 4)
	cp	a, b
	jr	nc, .Lclipped_right_ready
	ld	b, a
.Lclipped_right_ready:
	ld	a, b
	cp	a, c
	jr	c, .Lclipped_next_row
	sub	a, c
	inc	a
	ld	b, a

	/* DE = row base + left. */
	push	iy
	pop	de
	ld	hl, 0
	ld	l, c
	add	hl, de
	ex	de, hl

	ld	a, (ix + 18)
	ld	(de), a
	ld	c, b
	ld	b, 0
	dec	c
	jr	z, .Lclipped_next_row
	push	de
	pop	hl
	inc	de
	ldir

.Lclipped_next_row:
	lea	iy, iy + 64
	dec	(ix + 15)
	jp	nz, .Lclipped_row

	ld	sp, ix
	pop	ix
	ret
	.size	_fill_clipped_color_rows_exact, .-_fill_clipped_color_rows_exact

	.section	.text._fill_root_one_aperture_rows_exact,"ax",@progbits
	.globl	_fill_root_one_aperture_rows_exact
	.type	_fill_root_one_aperture_rows_exact,@function

/* Root-layer host-wall specialization for one portal aperture.  Both polygon
 * span cursors remain in the alternate set.  Each row emits either one solid
 * span or the two exact spans on either side of the aperture.
 *
 * C ABI arguments:
 *   ix+6   DrawPolygon *polygon
 *   ix+9   DrawPolygon *aperture
 *   ix+12  uint8_t first_row
 *   ix+15  uint8_t row_count (nonzero)
 *   ix+18  uint8_t color
 */
_fill_root_one_aperture_rows_exact:
	ld	hl, -7
	call	__frameset

	/* Preserve the aperture's valid row range before advancing to span_left. */
	ld	hl, (ix + 9)
	ld	bc, 149
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 6), a
	inc	hl
	ld	a, (hl)
	ld	(ix - 7), a
	ld	a, (ix + 12)
	ld	(ix - 5), a

	/* HL/DE = polygon/aperture span-left cursors. */
	ld	hl, 0
	ld	l, (ix + 12)
	ld	bc, (ix + 6)
	add	hl, bc
	ld	bc, 48
	add	hl, bc
	push	hl
	ld	hl, 0
	ld	l, (ix + 12)
	ld	bc, (ix + 9)
	add	hl, bc
	ld	bc, 48
	add	hl, bc
	ex	de, hl
	pop	hl
	exx

	/* IY = first target row. */
	ld	hl, 0
	ld	l, (ix + 12)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, _low_frame + 2
	add	hl, de
	push	hl
	pop	iy

.Laperture_row:
	/* Cache polygon and aperture bounds while advancing both left cursors. */
	exx
	ld	bc, 48
	ld	a, (hl)
	ld	(ix - 1), a
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 2), a
	or	a, a
	sbc	hl, bc
	inc	hl
	ex	de, hl
	ld	a, (hl)
	ld	(ix - 3), a
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 4), a
	or	a, a
	sbc	hl, bc
	inc	hl
	ex	de, hl
	exx

	/* Rows outside the aperture's initialized span range are fully solid. */
	ld	a, (ix - 5)
	ld	c, (ix - 6)
	cp	a, c
	jr	c, .Laperture_full_row
	ld	c, (ix - 7)
	cp	a, c
	jr	z, .Laperture_test_hole
	jr	nc, .Laperture_full_row

.Laperture_test_hole:
	/* Clip the hole itself to the host polygon row. */
	ld	bc, 0
	ld	a, (ix - 3)
	ld	c, a
	ld	a, (ix - 1)
	cp	a, c
	jr	c, .Laperture_hole_left_ready
	ld	c, a
.Laperture_hole_left_ready:
	ld	a, (ix - 4)
	ld	b, a
	ld	a, (ix - 2)
	cp	a, b
	jr	nc, .Laperture_hole_right_ready
	ld	b, a
.Laperture_hole_right_ready:
	ld	a, b
	cp	a, c
	jr	c, .Laperture_full_row

	/* Solid span before the hole, when nonempty. */
	ld	a, (ix - 1)
	cp	a, c
	jr	nc, .Laperture_after_hole
	push	bc
	dec	c
	ld	b, c
	ld	c, a
	call	.Lfill_root_span
	pop	bc

.Laperture_after_hole:
	/* Solid span after the hole, when nonempty. */
	ld	a, (ix - 2)
	cp	a, b
	jr	z, .Laperture_next_row
	jr	c, .Laperture_next_row
	ld	c, b
	inc	c
	ld	b, a
	call	.Lfill_root_span
	jr	.Laperture_next_row

.Laperture_full_row:
	ld	bc, 0
	ld	c, (ix - 1)
	ld	b, (ix - 2)
	call	.Lfill_root_span

.Laperture_next_row:
	lea	iy, iy + 64
	inc	(ix - 5)
	dec	(ix + 15)
	jp	nz, .Laperture_row

	ld	sp, ix
	pop	ix
	ret

/* Fill inclusive B:C = right:left in the current IY row. */
.Lfill_root_span:
	ld	a, b
	sub	a, c
	inc	a
	ld	b, a
	push	iy
	pop	de
	ld	hl, 0
	ld	l, c
	add	hl, de
	ex	de, hl
	ld	a, (ix + 18)
	ld	(de), a
	ld	c, b
	ld	b, 0
	dec	c
	ret	z
	push	de
	pop	hl
	inc	de
	ldir
	ret

	.size	_fill_root_one_aperture_rows_exact, .-_fill_root_one_aperture_rows_exact

	.section	.text._fill_clipped_one_aperture_rows_exact,"ax",@progbits
	.globl	_fill_clipped_one_aperture_rows_exact
	.type	_fill_clipped_one_aperture_rows_exact,@function

/* Child-layer host-wall specialization for one aperture.  Alternate HL, DE,
 * and BC walk polygon, clip, and aperture span-left arrays respectively.
 *
 * C ABI arguments:
 *   ix+6   DrawPolygon *polygon
 *   ix+9   RenderLayer *layer
 *   ix+12  DrawPolygon *aperture
 *   ix+15  uint8_t first_row
 *   ix+18  uint8_t row_count (nonzero)
 *   ix+21  uint8_t color
 */
_fill_clipped_one_aperture_rows_exact:
	ld	hl, -9
	call	__frameset

	ld	hl, (ix + 12)
	ld	bc, 149
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 8), a
	inc	hl
	ld	a, (hl)
	ld	(ix - 9), a
	ld	a, (ix + 15)
	ld	(ix - 7), a

	/* HL = polygon left cursor. */
	ld	hl, 0
	ld	l, (ix + 15)
	ld	de, (ix + 6)
	add	hl, de
	ld	de, 48
	add	hl, de
	push	hl

	/* DE = layer clip-left cursor. */
	ld	hl, 0
	ld	l, (ix + 15)
	ld	de, (ix + 9)
	add	hl, de
	ld	de, 1264
	add	hl, de
	ex	de, hl
	pop	hl
	push	hl
	push	de

	/* BC = aperture left cursor. */
	ld	hl, 0
	ld	l, (ix + 15)
	ld	de, (ix + 12)
	add	hl, de
	ld	de, 48
	add	hl, de
	push	hl
	pop	bc
	pop	de
	pop	hl
	exx

	/* IY = first target row. */
	ld	hl, 0
	ld	l, (ix + 15)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, _low_frame + 2
	add	hl, de
	push	hl
	pop	iy

.Lclip_aperture_row:
	exx
	/* Polygon bounds; preserve DE's clip cursor. */
	ld	a, (hl)
	ld	(ix - 1), a
	push	de
	ld	de, 48
	add	hl, de
	ld	a, (hl)
	ld	(ix - 2), a
	or	a, a
	sbc	hl, de
	inc	hl
	pop	de

	/* Clip bounds; preserve the updated polygon cursor. */
	ex	de, hl
	ld	a, (hl)
	ld	(ix - 3), a
	push	de
	ld	de, 48
	add	hl, de
	ld	a, (hl)
	ld	(ix - 4), a
	or	a, a
	sbc	hl, de
	inc	hl
	pop	de
	ex	de, hl

	/* Aperture bounds; preserve both other cursors. */
	push	hl
	push	de
	push	bc
	pop	hl
	ld	a, (hl)
	ld	(ix - 5), a
	ld	de, 48
	add	hl, de
	ld	a, (hl)
	ld	(ix - 6), a
	or	a, a
	sbc	hl, de
	inc	hl
	push	hl
	pop	bc
	pop	de
	pop	hl
	exx

	/* BC = the host polygon intersected with this portal layer's row clip. */
	ld	bc, 0
	ld	a, (ix - 1)
	ld	c, a
	ld	a, (ix - 3)
	cp	a, c
	jr	c, .Lclip_host_left_ready
	ld	c, a
.Lclip_host_left_ready:
	ld	a, (ix - 2)
	ld	b, a
	ld	a, (ix - 4)
	cp	a, b
	jr	nc, .Lclip_host_right_ready
	ld	b, a
.Lclip_host_right_ready:
	ld	a, b
	cp	a, c
	jr	c, .Lclip_aperture_next

	/* Outside initialized aperture rows, emit the full clipped host span. */
	ld	a, (ix - 7)
	ld	e, (ix - 8)
	cp	a, e
	jr	c, .Lclip_aperture_full
	ld	e, (ix - 9)
	cp	a, e
	jr	z, .Lclip_aperture_test
	jr	nc, .Lclip_aperture_full

.Lclip_aperture_test:
	/* DE = aperture hole clipped to the already-clipped host span. */
	ld	de, 0
	ld	a, (ix - 5)
	ld	e, a
	ld	a, c
	cp	a, e
	jr	c, .Lclip_hole_left_ready
	ld	e, a
.Lclip_hole_left_ready:
	ld	a, (ix - 6)
	ld	d, a
	ld	a, b
	cp	a, d
	jr	nc, .Lclip_hole_right_ready
	ld	d, a
.Lclip_hole_right_ready:
	ld	a, d
	cp	a, e
	jr	c, .Lclip_aperture_full

	/* Emit the solid segment before the hole. */
	ld	a, c
	cp	a, e
	jr	nc, .Lclip_after_hole
	push	bc
	push	de
	ld	b, e
	dec	b
	call	.Lfill_clipped_aperture_span
	pop	de
	pop	bc

.Lclip_after_hole:
	/* Emit the solid segment after the hole. */
	ld	a, b
	cp	a, d
	jr	z, .Lclip_aperture_next
	jr	c, .Lclip_aperture_next
	ld	c, d
	inc	c
	call	.Lfill_clipped_aperture_span
	jr	.Lclip_aperture_next

.Lclip_aperture_full:
	call	.Lfill_clipped_aperture_span

.Lclip_aperture_next:
	lea	iy, iy + 64
	inc	(ix - 7)
	dec	(ix + 18)
	jp	nz, .Lclip_aperture_row

	ld	sp, ix
	pop	ix
	ret

/* Fill inclusive B:C = right:left in the current IY row. */
.Lfill_clipped_aperture_span:
	ld	a, b
	sub	a, c
	inc	a
	ld	b, a
	push	iy
	pop	de
	ld	hl, 0
	ld	l, c
	add	hl, de
	ex	de, hl
	ld	a, (ix + 21)
	ld	(de), a
	ld	c, b
	ld	b, 0
	dec	c
	ret	z
	push	de
	pop	hl
	inc	de
	ldir
	ret

	.size	_fill_clipped_one_aperture_rows_exact, .-_fill_clipped_one_aperture_rows_exact
