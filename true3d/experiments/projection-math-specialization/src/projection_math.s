	.section	.text._project_camera_xy_exact,"ax",@progbits
	.assume	ADL = 1
	.globl	_project_camera_xy_exact
	.type	_project_camera_xy_exact,@function

/* Exact fused camera projection for one X/Y pair.
 *
 * C ABI arguments:
 *   ix+6   CameraPoint *point  (signed 24-bit x/y/depth)
 *   ix+9   unsigned 24-bit scale; projection tables guarantee <= 65535
 *   ix+12  ScreenPoint *result
 *   ix+15  render shift (0 or 1)
 *
 * The local multiply implements the target's existing expression exactly:
 *
 *   ((int32_t)value * (uint16_t)scale) >> 6
 *
 * It sign-extends the 24-bit value, retains the low 32 product bits, and
 * performs an arithmetic shift.  Six native 8x8 MLT operations replace each
 * generic __lmulu/__lshrs pair.  Projection centers, signed clamps, and the
 * optional half-resolution shift remain in the same order as the C path.
 */
_project_camera_xy_exact:
	ld	hl, -4
	call	__frameset

	ld	iy, (ix + 6)
	call	.Lproject_mul_shift6
	ld	bc, 8192                 /* VIEW_CENTER_X * 256 */
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
	ld	hl, 6144                 /* VIEW_CENTER_Y * 256 */
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

	/* Arithmetic int24 >> 1 after clamping, matching half_projected. */
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

/* Input IY points at one signed 24-bit camera component.  Return E:HL is the
 * exact signed 32-bit multiply/shift result.  ix-4..ix-1 hold the little-
 * endian low-32 product while its byte columns are assembled. */
.Lproject_mul_shift6:
	/* Column 0 and carry into column 1: x0*s0. */
	ld	bc, 0
	ld	b, (iy)
	ld	c, (ix + 9)
	mlt	bc
	ld	(ix - 4), c
	ld	hl, 0
	ld	l, b

	/* Column 1; retain high(x0*s1) and high(x1*s0) in D:E. */
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

	/* Column 2. */
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

	/* Column 3 plus the implicit 0xff sign-extension byte contribution. */
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

	/* Fixed arithmetic shift of accessible product bytes. */
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

/* Clamp signed E:HL to [-1048576, 1048576], returning the int24 value in HL. */
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
	.extern	__frameset
