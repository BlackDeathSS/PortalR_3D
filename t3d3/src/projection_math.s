	.section	.text._project_camera_xy_exact,"ax",@progbits
	.assume	ADL = 1
	.globl	_project_camera_xy_exact
	.type	_project_camera_xy_exact,@function
	.globl	_project_camera_xy_pair_exact
	.type	_project_camera_xy_pair_exact,@function

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
	.extern	__frameset
