	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_t3d2_raster_span
	.type	_t3d2_raster_span,@function

/* Opaque affine texture/depth span. Inputs live in the documented private
   scratch block in renderer.c. UV uses signed/unsigned 16.8 values; inverse
   depth is the full interpolated 16-bit value. */
_t3d2_raster_span:
	push	ix
	push	iy
	ld	ix, (_t3d2_span_color)
	ld	iy, (_t3d2_span_depth)
	ld	a, (_t3d2_span_length)
	or	a, a
	jp	z, .Lspan_done
	ld	b, a
	ld	a, (_t3d2_span_texture_loaded)
	or	a, a
	jr	z, .Lspan_pixel
	ld	a, (_t3d2_span_texture_shift)
	cp	a, 1
	jp	z, .Lmip_start

.Lspan_pixel:
	/* Compare the current 16-bit inverse depth against the destination. */
	ld.s	de, (_t3d2_span_depth_value)
	ld.s	hl, (iy)
	or	a, a
	sbc.s	hl, de
	jr	nc, .Lspan_skip_write
	ld.s	(iy), de

	/* Build the atlas offset from the integer bytes of 8.8 U and V. */
	ld	hl, 0
	ld	a, (_t3d2_span_u_value + 1)
	ld	l, a
	ld	a, (_t3d2_span_v_value + 1)
	ld	d, a
	ld	a, (_t3d2_span_texture_shift)
	or	a, a
	ld	a, d
	jr	z, .Lspan_v_ready
	srl	a
.Lspan_v_ready:
	ld	h, a
	ld	a, (_t3d2_span_texture_loaded)
	or	a, a
	jr	z, .Lspan_checker
	bit	7, h
	jr	z, .Lspan_texture0
	res	7, h
	ld	de, (_t3d2_span_texture1)
	jr	.Lspan_sample
.Lspan_texture0:
	ld	de, (_t3d2_span_texture0)
.Lspan_sample:
	add	hl, de
	ld	a, (hl)
	cp	a, 60
	jr	c, .Lspan_shade
	xor	a, a
	jr	.Lspan_shade

.Lspan_checker:
	ld	a, (_t3d2_span_u_value + 1)
	ld	d, a
	ld	a, (_t3d2_span_v_value + 1)
	xor	a, d
	and	a, 0x10
	ld	a, 18
	jr	z, .Lspan_shade
	ld	a, 34

.Lspan_shade:
	ld	d, a
	ld	a, (_t3d2_span_shade_offset)
	add	a, d
	ld	(ix), a

.Lspan_skip_write:
	inc	ix
	lea	iy, iy + 2

	ld.s	hl, (_t3d2_span_depth_value)
	ld.s	de, (_t3d2_span_depth_step)
	add.s	hl, de
	ld.s	(_t3d2_span_depth_value), hl
	ld	hl, (_t3d2_span_u_value)
	ld	de, (_t3d2_span_u_step)
	add	hl, de
	ld	(_t3d2_span_u_value), hl
	ld	hl, (_t3d2_span_v_value)
	ld	de, (_t3d2_span_v_step)
	add	hl, de
	ld	(_t3d2_span_v_value), hl
	dec	b
	jp	nz, .Lspan_pixel
	jp	.Lspan_done

/* Resident opaque 128x128 mip expanded to a 256-byte row stride. Dispatching
   once per span removes texture-state, atlas-half, and cutout checks from the
   production per-pixel path. */
.Lmip_start:
	ld	hl, (_t3d2_span_v_step)
	ld	a, l
	or	a, h
	jp	z, .Lmip_v_constant_start
	exx
	ld.s	hl, (_t3d2_span_depth_value)
	ld.s	de, (_t3d2_span_depth_step)
	exx
.Lmip_pixel:
	exx
	ld	a, (iy + 1)
	cp	a, h
	jr	c, .Lmip_depth_write
	jr	nz, .Lmip_depth_reject
	ld	a, (iy)
	cp	a, l
	jr	nc, .Lmip_depth_reject
.Lmip_depth_write:
	ld	(iy), l
	ld	(iy + 1), h
	add.s	hl, de
	exx

	ld	hl, 0
	ld	a, (_t3d2_span_u_value + 1)
	ld	l, a
	ld	a, (_t3d2_span_v_value + 1)
	srl	a
	ld	h, a
	ld	de, (_t3d2_span_texture0)
	add	hl, de
	ld	a, (hl)
	ld	d, a
	ld	a, (_t3d2_span_shade_offset)
	add	a, d
	ld	(ix), a
	jr	.Lmip_advance

.Lmip_depth_reject:
	add.s	hl, de
	exx
.Lmip_advance:
	inc	ix
	lea	iy, iy + 2
	ld	hl, (_t3d2_span_u_value)
	ld	de, (_t3d2_span_u_step)
	add	hl, de
	ld	(_t3d2_span_u_value), hl
	ld	hl, (_t3d2_span_v_value)
	ld	de, (_t3d2_span_v_step)
	add	hl, de
	ld	(_t3d2_span_v_value), hl
	dec	b
	jp	nz, .Lmip_pixel
	jp	.Lspan_done

/* Common wall/floor spans have no V change across X. Keep that row in the
   otherwise unused alternate C register and remove the V accumulator traffic
   from every covered pixel. */
.Lmip_v_constant_start:
	ld	a, (_t3d2_span_v_value + 1)
	srl	a
	exx
	ld	c, a
	ld.s	hl, (_t3d2_span_depth_value)
	ld.s	de, (_t3d2_span_depth_step)
	exx
.Lmip_v_constant_pixel:
	exx
	ld	a, (iy + 1)
	cp	a, h
	jr	c, .Lmip_v_constant_write
	jr	nz, .Lmip_v_constant_reject
	ld	a, (iy)
	cp	a, l
	jr	nc, .Lmip_v_constant_reject
.Lmip_v_constant_write:
	ld	(iy), l
	ld	(iy + 1), h
	add.s	hl, de
	ld	a, c
	exx
	ld	d, a
	ld	hl, 0
	ld	a, (_t3d2_span_u_value + 1)
	ld	l, a
	ld	h, d
	ld	de, (_t3d2_span_texture0)
	add	hl, de
	ld	a, (hl)
	ld	d, a
	ld	a, (_t3d2_span_shade_offset)
	add	a, d
	ld	(ix), a
	jr	.Lmip_v_constant_advance
.Lmip_v_constant_reject:
	add.s	hl, de
	exx
.Lmip_v_constant_advance:
	inc	ix
	lea	iy, iy + 2
	ld	hl, (_t3d2_span_u_value)
	ld	de, (_t3d2_span_u_step)
	add	hl, de
	ld	(_t3d2_span_u_value), hl
	dec	b
	jp	nz, .Lmip_v_constant_pixel

.Lspan_done:
	pop	iy
	pop	ix
	ret
	.size	_t3d2_raster_span, .-_t3d2_raster_span

	.globl	_t3d2_solid_span
	.type	_t3d2_solid_span,@function
_t3d2_solid_span:
	push	ix
	push	iy
	ld	ix, (_t3d2_solid_color_pointer)
	ld	iy, (_t3d2_solid_depth_pointer)
	ld	a, (_t3d2_solid_length)
	or	a, a
	jr	z, .Lsolid_done
	ld	b, a
	ld	a, (_t3d2_solid_color)
	ld	c, a

.Lsolid_pixel:
	ld.s	de, (_t3d2_solid_depth_value)
	ld.s	hl, (iy)
	or	a, a
	sbc.s	hl, de
	jr	nc, .Lsolid_skip
	ld.s	(iy), de
	ld	a, c
	ld	(ix), a
.Lsolid_skip:
	inc	ix
	lea	iy, iy + 2
	djnz	.Lsolid_pixel

.Lsolid_done:
	pop	iy
	pop	ix
	ret
	.size	_t3d2_solid_span, .-_t3d2_solid_span
