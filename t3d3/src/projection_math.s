	.section	.text._project_camera_xy_exact,"ax",@progbits
	.assume	ADL = 1
	.globl	_project_camera_xy_exact
	.type	_project_camera_xy_exact,@function
	.globl	_project_camera_xy_pair_exact
	.type	_project_camera_xy_pair_exact,@function
	.globl	_project_box_vertices_80
	.type	_project_box_vertices_80,@function

/* Exact fused X/Y projection for one camera-space point. */
_project_camera_xy_exact:
	ld	hl, -4
	call	__frameset

	ld	iy, (ix + 6)
	call	.Lproject_mul_shift6
	ld	bc, 8192
	add	hl, bc
	ld	a, e
	adc	a, 0
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix + 12)
	ld	(iy), hl

	ld	iy, (ix + 6)
	lea	iy, iy + 3
	call	.Lproject_mul_shift6
	ld	(ix - 1), e
	push	hl
	pop	de
	xor	a, a
	ld	hl, 6144
	sbc	hl, de
	ld	c, (ix - 1)
	sbc	a, c
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix + 12)
	ld	(iy + 3), hl

	ld	a, (ix + 15)
	or	a, a
	jr	z, .Lproject_pair_done

	ld	iy, (ix + 12)
	ld	a, (iy + 2)
	sra	a
	ld	(iy + 2), a
	ld	a, (iy + 1)
	rr	a
	ld	(iy + 1), a
	ld	a, (iy)
	rr	a
	ld	(iy), a
	ld	a, (iy + 5)
	sra	a
	ld	(iy + 5), a
	ld	a, (iy + 4)
	rr	a
	ld	(iy + 4), a
	ld	a, (iy + 3)
	rr	a
	ld	(iy + 3), a

.Lproject_pair_done:
	ld	sp, ix
	pop	ix
	ret

.Lproject_mul_shift6:
	ld	bc, 0
	ld	b, (iy)
	ld	c, (ix + 9)
	mlt	bc
	ld	(ix - 4), c
	ld	hl, 0
	ld	l, b

	ld	bc, 0
	ld	b, (iy)
	ld	c, (ix + 10)
	mlt	bc
	ld	d, b
	ld	b, 0
	add	hl, bc
	ld	bc, 0
	ld	b, (iy + 1)
	ld	c, (ix + 9)
	mlt	bc
	ld	e, b
	ld	b, 0
	add	hl, bc
	ld	(ix - 3), l
	ld	a, h

	ld	hl, 0
	ld	l, a
	ld	bc, 0
	ld	c, d
	add	hl, bc
	ld	c, e
	add	hl, bc
	ld	bc, 0
	ld	b, (iy + 1)
	ld	c, (ix + 10)
	mlt	bc
	ld	a, b
	ld	b, 0
	add	hl, bc
	ld	bc, 0
	ld	b, (iy + 2)
	ld	c, (ix + 9)
	mlt	bc
	ld	d, b
	ld	b, 0
	add	hl, bc
	ld	(ix - 2), l
	ld	e, h

	ld	bc, 0
	ld	b, (iy + 2)
	ld	c, (ix + 10)
	mlt	bc
	ld	hl, 0
	ld	l, e
	ld	b, 0
	add	hl, bc
	ld	c, a
	add	hl, bc
	ld	c, d
	add	hl, bc
	bit	7, (iy + 2)
	jr	z, .Lproject_product_ready
	ld	a, l
	sub	a, (ix + 9)
	ld	l, a
.Lproject_product_ready:
	ld	(ix - 1), l

	ld	d, (ix - 4)
	ld	c, (ix - 3)
	ld	b, (ix - 2)
	ld	a, (ix - 1)
	.rept	6
	sra	a
	rr	b
	rr	c
	rr	d
	.endr
	ld	(ix - 4), d
	ld	(ix - 3), c
	ld	(ix - 2), b
	ld	hl, (ix - 4)
	ld	e, a
	ret

.Lproject_clamp:
	bit	7, e
	jr	nz, .Lproject_clamp_negative
	ld	a, e
	or	a, a
	jr	nz, .Lproject_clamp_maximum
	ld	bc, 1048576
	or	a, a
	sbc	hl, bc
	jr	c, .Lproject_restore_maximum_compare
	jr	z, .Lproject_restore_maximum_compare
.Lproject_clamp_maximum:
	ld	hl, 1048576
	ret
.Lproject_restore_maximum_compare:
	add	hl, bc
	ret

.Lproject_clamp_negative:
	ld	a, e
	inc	a
	jr	nz, .Lproject_clamp_minimum
	ld	bc, 0xf00000
	or	a, a
	sbc	hl, bc
	jr	c, .Lproject_clamp_minimum
	add	hl, bc
	ret
.Lproject_clamp_minimum:
	ld	hl, 0xf00000
	ret

	.size	_project_camera_xy_exact, .-_project_camera_xy_exact

/* Project two points that share one scale under a single ABI frame. This is
 * used by distant-body bounds, whose conservative corners have equal depth.
 *
 * C ABI arguments retain the single-point layout for the first point:
 *   ix+6   first CameraPoint *
 *   ix+9   shared scale
 *   ix+12  first ScreenPoint *
 *   ix+15  render shift
 *   ix+18  second CameraPoint *
 *   ix+21  second ScreenPoint *
 */
_project_camera_xy_pair_exact:
	ld	hl, -4
	call	__frameset

	ld	iy, (ix + 6)
	call	.Lproject_mul_shift6
	ld	bc, 8192
	add	hl, bc
	ld	a, e
	adc	a, 0
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix + 12)
	ld	(iy), hl

	ld	iy, (ix + 6)
	lea	iy, iy + 3
	call	.Lproject_mul_shift6
	ld	(ix - 1), e
	push	hl
	pop	de
	xor	a, a
	ld	hl, 6144
	sbc	hl, de
	ld	c, (ix - 1)
	sbc	a, c
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix + 12)
	ld	(iy + 3), hl

	ld	iy, (ix + 18)
	call	.Lproject_mul_shift6
	ld	bc, 8192
	add	hl, bc
	ld	a, e
	adc	a, 0
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix + 21)
	ld	(iy), hl

	ld	iy, (ix + 18)
	lea	iy, iy + 3
	call	.Lproject_mul_shift6
	ld	(ix - 1), e
	push	hl
	pop	de
	xor	a, a
	ld	hl, 6144
	sbc	hl, de
	ld	c, (ix - 1)
	sbc	a, c
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix + 21)
	ld	(iy + 3), hl

	ld	a, (ix + 15)
	or	a, a
	jr	z, .Lproject_pair_two_done
	ld	iy, (ix + 12)
	call	.Lproject_half_output
	ld	iy, (ix + 21)
	call	.Lproject_half_output

.Lproject_pair_two_done:
	ld	sp, ix
	pop	ix
	ret

.Lproject_half_output:
	ld	a, (iy + 2)
	sra	a
	ld	(iy + 2), a
	ld	a, (iy + 1)
	rr	a
	ld	(iy + 1), a
	ld	a, (iy)
	rr	a
	ld	(iy), a
	ld	a, (iy + 5)
	sra	a
	ld	(iy + 5), a
	ld	a, (iy + 4)
	rr	a
	ld	(iy + 4), a
	ld	a, (iy + 3)
	rr	a
	ld	(iy + 3), a
	ret

	.size	_project_camera_xy_pair_exact, .-_project_camera_xy_pair_exact

/* Project the selected vertices of the engine's fixed eight-corner box cache
 * in one ABI frame. The 80x60 full-resolution path always uses the 64x48
 * projection core followed by an exact signed 5/4 scale. Keeping the fixed
 * 9-byte CameraPoint and 6-byte ScreenPoint strides here avoids the compiler's
 * repeated index multiplies, scale dispatch, calls and structure copies.
 *
 * C ABI:
 *   ix+6   vertex mask
 *   ix+9   CameraPoint[8] *
 *   ix+12  ScreenPoint[8] *
 *   ix+15  uint8_t projectable[8] *
 *   ix+18  near projection scale table *
 *   ix+21  far projection scale table *
 */
_project_box_vertices_80:
	ld	hl, -18
	call	__frameset
	ld	hl, (ix + 9)
	ld	(ix - 3), hl
	ld	hl, (ix + 12)
	ld	(ix - 6), hl
	ld	hl, (ix + 15)
	ld	(ix - 9), hl
	ld	a, (ix + 6)
	ld	(ix - 10), a
	ld	(ix - 11), 1
	ld	(ix - 12), 8

.Lbox_vertex_loop:
	ld	iy, (ix - 9)
	ld	a, (ix - 10)
	ld	b, (ix - 11)
	and	a, b
	jp	z, .Lbox_not_projectable

	ld	iy, (ix - 3)
	ld	hl, (iy + 6)
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	jp	m, .Lbox_not_projectable
	ld	iy, (ix - 9)
	ld	(iy), 1

	/* Select the exact near or far reciprocal entry from positive depth. */
	ld	iy, (ix - 3)
	ld	hl, (iy + 6)
	ld	bc, 8192
	or	a, a
	sbc	hl, bc
	jr	nc, .Lbox_far_scale
	add	hl, bc
	add	hl, hl
	ld	de, (ix + 18)
	add	hl, de
	jr	.Lbox_scale_ready

.Lbox_far_scale:
	add	hl, bc
	ld	b, 5
.Lbox_far_shift:
	srl	h
	rr	l
	djnz	.Lbox_far_shift
	ld	de, 2047
	or	a, a
	sbc	hl, de
	jr	c, .Lbox_far_in_range
	ld	hl, 2047
	jr	.Lbox_far_index_ready
.Lbox_far_in_range:
	add	hl, de
.Lbox_far_index_ready:
	add	hl, hl
	ld	de, (ix + 21)
	add	hl, de

.Lbox_scale_ready:
	ld	a, (hl)
	ld	(ix - 14), a
	inc	hl
	ld	a, (hl)
	ld	(ix - 13), a

	/* X = 32 + x * scale / 64. */
	ld	iy, (ix - 3)
	call	.Lbox_project_mul_shift6
	ld	bc, 8192
	add	hl, bc
	ld	a, e
	adc	a, 0
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix - 6)
	ld	(iy), hl

	/* Y = 24 - y * scale / 64. */
	ld	iy, (ix - 3)
	lea	iy, iy + 3
	call	.Lbox_project_mul_shift6
	ld	(ix - 15), e
	push	hl
	pop	de
	xor	a, a
	ld	hl, 6144
	sbc	hl, de
	ld	c, (ix - 15)
	sbc	a, c
	ld	e, a
	call	.Lproject_clamp
	ld	iy, (ix - 6)
	ld	(iy + 3), hl

	/* Exact signed ((value * 5) >> 2) used by the 80x60 C path. */
	ld	iy, (ix - 6)
	call	.Lbox_scale_five_quarters
	lea	iy, iy + 3
	call	.Lbox_scale_five_quarters
	jr	.Lbox_advance

.Lbox_not_projectable:
	ld	iy, (ix - 9)
	ld	(iy), 0

.Lbox_advance:
	ld	hl, (ix - 3)
	ld	de, 9
	add	hl, de
	ld	(ix - 3), hl
	ld	hl, (ix - 6)
	ld	de, 6
	add	hl, de
	ld	(ix - 6), hl
	ld	hl, (ix - 9)
	inc	hl
	ld	(ix - 9), hl
	sla	(ix - 11)
	dec	(ix - 12)
	jp	nz, .Lbox_vertex_loop

	ld	sp, ix
	pop	ix
	ret

/* Signed 24-bit point component times 5/4, in place at IY. */
.Lbox_scale_five_quarters:
	ld	de, (iy)
	.rept	2
	ld	a, (iy + 2)
	sra	a
	ld	(iy + 2), a
	ld	a, (iy + 1)
	rr	a
	ld	(iy + 1), a
	ld	a, (iy)
	rr	a
	ld	(iy), a
	.endr
	ld	hl, (iy)
	add	hl, de
	ld	(iy), hl
	ret

/* Signed CameraPoint component times the local unsigned 16-bit scale, then
 * arithmetic shift right by six. Result is E:HL, matching .Lproject_clamp. */
.Lbox_project_mul_shift6:
	ld	bc, 0
	ld	b, (iy)
	ld	c, (ix - 14)
	mlt	bc
	ld	(ix - 18), c
	ld	hl, 0
	ld	l, b

	ld	bc, 0
	ld	b, (iy)
	ld	c, (ix - 13)
	mlt	bc
	ld	d, b
	ld	b, 0
	add	hl, bc
	ld	bc, 0
	ld	b, (iy + 1)
	ld	c, (ix - 14)
	mlt	bc
	ld	e, b
	ld	b, 0
	add	hl, bc
	ld	(ix - 17), l
	ld	a, h

	ld	hl, 0
	ld	l, a
	ld	bc, 0
	ld	c, d
	add	hl, bc
	ld	c, e
	add	hl, bc
	ld	bc, 0
	ld	b, (iy + 1)
	ld	c, (ix - 13)
	mlt	bc
	ld	a, b
	ld	b, 0
	add	hl, bc
	ld	bc, 0
	ld	b, (iy + 2)
	ld	c, (ix - 14)
	mlt	bc
	ld	d, b
	ld	b, 0
	add	hl, bc
	ld	(ix - 16), l
	ld	e, h

	ld	bc, 0
	ld	b, (iy + 2)
	ld	c, (ix - 13)
	mlt	bc
	ld	hl, 0
	ld	l, e
	ld	b, 0
	add	hl, bc
	ld	c, a
	add	hl, bc
	ld	c, d
	add	hl, bc
	bit	7, (iy + 2)
	jr	z, .Lbox_product_ready
	ld	a, l
	sub	a, (ix - 14)
	ld	l, a
.Lbox_product_ready:
	ld	(ix - 15), l

	ld	d, (ix - 18)
	ld	c, (ix - 17)
	ld	b, (ix - 16)
	ld	a, (ix - 15)
	.rept	6
	sra	a
	rr	b
	rr	c
	rr	d
	.endr
	ld	(ix - 18), d
	ld	(ix - 17), c
	ld	(ix - 16), b
	ld	hl, (ix - 18)
	ld	e, a
	ret

	.size	_project_box_vertices_80, .-_project_box_vertices_80
	.extern	__frameset
