	.section	.text._transform_point_exact,"ax",@progbits
	.assume	ADL = 1
	.globl	_transform_point_exact
	.type	_transform_point_exact,@function

/* Exact Q8 camera transform specialized for engine camera bases.
 *
 * C ABI arguments:
 *   ix+6   Camera *camera
 *   ix+9   Vec3 *point
 *   ix+12  CameraPoint *result
 *
 * Camera basis components are always in [-256, 256]. For one component,
 * split c = c0 + 256*c1, where c0 is its unsigned low byte and c1 is one of
 * -1, 0, or 1. Three native byte multiplies form a signed 24x8 product;
 * a*c1<<8 completes the exact signed 24x9 product. Products are accumulated
 * as 32-bit values before the single arithmetic Q8 shift, matching vec_dot.
 */
_transform_point_exact:
	ld	hl, -30
	call	__frameset

	/* relative = point - camera->position, with fixed_t's 24-bit wrap. */
	ld	iy, (ix + 9)
	ld	hl, (iy)
	ld	iy, (ix + 6)
	ld	de, (iy)
	or	a, a
	sbc	hl, de
	ld	(ix - 30), hl

	ld	iy, (ix + 9)
	ld	hl, (iy + 3)
	ld	iy, (ix + 6)
	ld	de, (iy + 3)
	or	a, a
	sbc	hl, de
	ld	(ix - 27), hl

	ld	iy, (ix + 9)
	ld	hl, (iy + 6)
	ld	iy, (ix + 6)
	ld	de, (iy + 6)
	or	a, a
	sbc	hl, de
	ld	(ix - 24), hl

	/* right dot relative */
	ld	iy, (ix + 6)
	lea	hl, iy + 9
	call	.Ldot_q8
	ld	iy, (ix + 12)
	ld	(iy), hl

	/* up dot relative */
	ld	iy, (ix + 6)
	lea	hl, iy + 18
	call	.Ldot_q8
	ld	iy, (ix + 12)
	ld	(iy + 3), hl

	/* forward dot relative */
	ld	iy, (ix + 6)
	lea	hl, iy + 27
	call	.Ldot_q8
	ld	iy, (ix + 12)
	ld	(iy + 6), hl

	ld	sp, ix
	pop	ix
	ret

/* Input HL points to one three-component camera basis. Return the exact
 * fixed-point dot product in HL. IX remains the outer function's frame. */
.Ldot_q8:
	ld	(ix - 18), hl             /* current coefficient pointer */
	lea	iy, ix - 30              /* current relative component */
	xor	a, a
	ld	(ix - 11), a              /* 32-bit accumulator */
	ld	(ix - 10), a
	ld	(ix - 9), a
	ld	(ix - 8), a
	ld	a, 3
	ld	(ix - 2), a

.Ldot_component:
	/* Load c0/c1 and advance the packed fixed_t coefficient pointer. */
	ld	hl, (ix - 18)
	ld	a, (hl)
	ld	(ix - 7), a
	inc	hl
	ld	a, (hl)
	ld	(ix - 6), a
	inc	hl
	inc	hl
	ld	(ix - 18), hl

	/* Unsigned U24(relative) * c0 into the four product bytes. */
	ld	bc, 0
	ld	b, (iy)
	ld	c, (ix - 7)
	mlt	bc
	ld	de, 0
	ld	d, (iy + 1)
	ld	e, (ix - 7)
	mlt	de
	ld	hl, 0
	ld	h, (iy + 2)
	ld	l, (ix - 7)
	mlt	hl
	ld	(ix - 15), c
	ld	a, b
	add	a, e
	ld	(ix - 14), a
	ld	a, d
	adc	a, l
	ld	(ix - 13), a
	ld	a, h
	adc	a, 0
	bit	7, (iy + 2)
	jr	z, .Lunsigned_product_ready
	sub	a, (ix - 7)             /* signed-a correction */
.Lunsigned_product_ready:
	ld	(ix - 12), a

	/* Add a*c1<<8. c1 is -1, 0, or 1 for every valid camera basis. */
	ld	a, (ix - 6)
	or	a, a
	jr	z, .Lproduct_ready
	inc	a
	jr	z, .Lnegative_high_byte
	ld	a, (ix - 14)
	add	a, (iy)
	ld	(ix - 14), a
	ld	a, (ix - 13)
	adc	a, (iy + 1)
	ld	(ix - 13), a
	ld	a, (ix - 12)
	adc	a, (iy + 2)
	ld	(ix - 12), a
	jr	.Lproduct_ready
.Lnegative_high_byte:
	ld	a, (ix - 14)
	sub	a, (iy)
	ld	(ix - 14), a
	ld	a, (ix - 13)
	sbc	a, (iy + 1)
	ld	(ix - 13), a
	ld	a, (ix - 12)
	sbc	a, (iy + 2)
	ld	(ix - 12), a

.Lproduct_ready:
	/* Accumulate all four bytes so cross-product fractional carries survive. */
	ld	hl, (ix - 15)
	ld	bc, (ix - 11)
	add	hl, bc
	ld	(ix - 11), hl
	ld	a, (ix - 12)
	adc	a, (ix - 8)
	ld	(ix - 8), a

	lea	iy, iy + 3
	dec	(ix - 2)
	jp	nz, .Ldot_component

	/* Arithmetic 32-bit >> 8: bytes 1..3 are the signed fixed_t result. */
	ld	hl, (ix - 10)
	ret

	.size	_transform_point_exact, .-_transform_point_exact

	.section	.text._scale_camera_axis_exact,"ax",@progbits
	.globl	_scale_camera_axis_exact
	.type	_scale_camera_axis_exact,@function

/* Compute the camera-space edge for one room axis.
 *
 * Room bounds are signed 16-bit Q8 coordinates, so their nonnegative extent
 * is at most 65535. Camera coefficients remain in [-256, 256]. Splitting
 * c = c0 + 256*c1 reduces each exact `(extent*c)>>8` to two byte multiplies
 * plus an add/subtract of the extent.
 *
 * C ABI arguments:
 *   ix+6   Camera *camera
 *   ix+9   uint8_t axis (0=x, 1=y, 2=z)
 *   ix+12  fixed_t extent
 *   ix+15  CameraPoint *result
 */
_scale_camera_axis_exact:
	ld	hl, -15
	call	__frameset

	/* coefficient = &camera->right[axis], then stride across right/up/forward */
	ld	hl, 0
	ld	l, (ix + 9)
	push	hl
	pop	de
	add	hl, hl
	add	hl, de
	ld	de, 9
	add	hl, de
	ld	de, (ix + 6)
	add	hl, de
	push	hl
	pop	iy

	ld	hl, (ix + 15)
	ld	(ix - 6), hl
	ld	a, 3
	ld	(ix - 7), a

.Lscale_axis_component:
	ld	a, (iy)
	ld	(ix - 9), a              /* c0 */
	ld	a, (iy + 1)
	ld	(ix - 8), a              /* c1: -1, 0, or 1 */

	ld	bc, 0
	ld	b, (ix + 12)
	ld	c, (ix - 9)
	mlt	bc
	ld	de, 0
	ld	d, (ix + 13)
	ld	e, (ix - 9)
	mlt	de

	ld	hl, 0
	ld	a, b
	add	a, e
	ld	l, a
	ld	a, d
	adc	a, 0
	ld	h, a

	ld	a, (ix - 8)
	or	a, a
	jr	z, .Lscale_axis_store
	ld	bc, (ix + 12)
	inc	a
	jr	z, .Lscale_axis_subtract
	add	hl, bc
	jr	.Lscale_axis_store
.Lscale_axis_subtract:
	or	a, a
	sbc	hl, bc

.Lscale_axis_store:
	ld	(ix - 12), hl
	ld	(ix - 3), iy
	ld	iy, (ix - 6)
	ld	hl, (ix - 12)
	ld	(iy), hl
	lea	iy, iy + 3
	ld	(ix - 6), iy
	ld	iy, (ix - 3)
	lea	iy, iy + 9
	dec	(ix - 7)
	jr	nz, .Lscale_axis_component

	ld	sp, ix
	pop	ix
	ret

	.size	_scale_camera_axis_exact, .-_scale_camera_axis_exact

	.section	.text._scale_camera_room_edges_exact,"ax",@progbits
	.globl	_scale_camera_room_edges_exact
	.type	_scale_camera_room_edges_exact,@function

/* Batch all three room axes under one ABI/frame setup.
 *
 * C ABI arguments:
 *   ix+6   Camera *camera
 *   ix+9   fixed_t extent_x
 *   ix+12  fixed_t extent_y
 *   ix+15  fixed_t extent_z
 *   ix+18  CameraPoint result[3]
 */
_scale_camera_room_edges_exact:
	ld	hl, -15
	call	__frameset

	ld	hl, (ix + 9)
	ld	(ix - 15), hl
	ld	iy, (ix + 6)
	lea	iy, iy + 9
	ld	hl, (ix + 18)
	ld	(ix - 6), hl
	call	.Lscale_room_axis

	ld	hl, (ix + 12)
	ld	(ix - 15), hl
	ld	iy, (ix + 6)
	lea	iy, iy + 12
	ld	hl, (ix + 18)
	ld	de, 9
	add	hl, de
	ld	(ix - 6), hl
	call	.Lscale_room_axis

	ld	hl, (ix + 15)
	ld	(ix - 15), hl
	ld	iy, (ix + 6)
	lea	iy, iy + 15
	ld	hl, (ix + 18)
	ld	de, 18
	add	hl, de
	ld	(ix - 6), hl
	call	.Lscale_room_axis

	ld	sp, ix
	pop	ix
	ret

/* IY selects right[axis]. IX-15 holds the unsigned 16-bit extent and IX-6
 * the output pointer. Step IY by nine to visit up/forward for this axis. */
.Lscale_room_axis:
	ld	a, 3
	ld	(ix - 7), a
.Lscale_room_component:
	ld	a, (iy)
	ld	(ix - 9), a
	ld	a, (iy + 1)
	ld	(ix - 8), a

	ld	bc, 0
	ld	b, (ix - 15)
	ld	c, (ix - 9)
	mlt	bc
	ld	de, 0
	ld	d, (ix - 14)
	ld	e, (ix - 9)
	mlt	de

	ld	hl, 0
	ld	a, b
	add	a, e
	ld	l, a
	ld	a, d
	adc	a, 0
	ld	h, a

	ld	a, (ix - 8)
	or	a, a
	jr	z, .Lscale_room_store
	ld	bc, (ix - 15)
	inc	a
	jr	z, .Lscale_room_subtract
	add	hl, bc
	jr	.Lscale_room_store
.Lscale_room_subtract:
	or	a, a
	sbc	hl, bc

.Lscale_room_store:
	ld	(ix - 12), hl
	ld	(ix - 3), iy
	ld	iy, (ix - 6)
	ld	hl, (ix - 12)
	ld	(iy), hl
	lea	iy, iy + 3
	ld	(ix - 6), iy
	ld	iy, (ix - 3)
	lea	iy, iy + 9
	dec	(ix - 7)
	jr	nz, .Lscale_room_component
	ret

	.size	_scale_camera_room_edges_exact, .-_scale_camera_room_edges_exact
	.extern	__frameset
