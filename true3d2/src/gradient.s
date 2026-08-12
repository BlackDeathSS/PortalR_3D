	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_t3d2_triangle_gradients
	.type	_t3d2_triangle_gradients,@function
	.globl	_t3d2_triangle_normalize
	.type	_t3d2_triangle_normalize,@function

/* Six signed Q7 numerator * unsigned Q16 reciprocal products. The setup below
   normalizes every numerator to [-127,127], allowing two native 8x8 MLT
   instructions instead of the compiler's six general 24-bit helpers. */
	.macro	t3d2_gradient_one offset
	ld	a, (_t3d2_gradient_input + \offset)
	ld	h, 0
	bit	7, a
	jr	z, .Lgradient_positive\@
	neg
	inc	h
.Lgradient_positive\@:
	ld	l, a
	ld	de, 0
	ld	d, l
	ld	a, (_t3d2_gradient_reciprocal)
	ld	e, a
	mlt	de
	ld	bc, 0
	ld	b, l
	ld	a, (_t3d2_gradient_reciprocal + 1)
	ld	c, a
	mlt	bc
	ld	e, d
	ld	d, 0
	ld	a, h
	ld	h, b
	ld	l, c
	add	hl, de
	srl	h
	rr	l
	or	a, a
	jr	z, .Lgradient_store\@
	ex	de, hl
	ld	hl, 0
	or	a, a
	sbc	hl, de
	ld	(_t3d2_gradient_output + \offset), hl
	jr	.Lgradient_done\@
.Lgradient_store\@:
	ld	(_t3d2_gradient_output + \offset), hl
.Lgradient_done\@:
	.endm

	.macro	t3d2_gradient_needs_shift offset
	ld	a, (_t3d2_gradient_input + \offset + 2)
	or	a, a
	jr	z, .Lgradient_check_positive\@
	inc	a
	jp	nz, .Lgradient_normalize_shift
	ld	a, (_t3d2_gradient_input + \offset + 1)
	inc	a
	jp	nz, .Lgradient_normalize_shift
	ld	a, (_t3d2_gradient_input + \offset)
	cp	a, 0x81
	jp	c, .Lgradient_normalize_shift
	jr	.Lgradient_check_done\@
.Lgradient_check_positive\@:
	ld	a, (_t3d2_gradient_input + \offset + 1)
	or	a, a
	jp	nz, .Lgradient_normalize_shift
	ld	a, (_t3d2_gradient_input + \offset)
	cp	a, 0x80
	jp	nc, .Lgradient_normalize_shift
.Lgradient_check_done\@:
	.endm

	/* Signed division by two with C's truncation toward zero. Adding one to a
	   negative value before an arithmetic shift handles both odd and even input. */
	.macro	t3d2_gradient_divide_signed offset
	ld	a, (_t3d2_gradient_input + \offset + 2)
	bit	7, a
	jr	z, .Lgradient_divide_ready\@
	ld	hl, (_t3d2_gradient_input + \offset)
	inc	hl
	ld	(_t3d2_gradient_input + \offset), hl
.Lgradient_divide_ready\@:
	ld	a, (_t3d2_gradient_input + \offset + 2)
	sra	a
	ld	(_t3d2_gradient_input + \offset + 2), a
	ld	a, (_t3d2_gradient_input + \offset + 1)
	rra
	ld	(_t3d2_gradient_input + \offset + 1), a
	ld	a, (_t3d2_gradient_input + \offset)
	rra
	ld	(_t3d2_gradient_input + \offset), a
	.endm

/* Generic projected-triangle setup: normalize the doubled area to one byte and
   all six signed attribute numerators to Q7 without changing their ratio. */
_t3d2_triangle_normalize:
.Lgradient_normalize_check:
	ld	a, (_t3d2_gradient_area + 2)
	or	a, a
	jp	nz, .Lgradient_normalize_shift
	ld	a, (_t3d2_gradient_area + 1)
	or	a, a
	jp	nz, .Lgradient_normalize_shift
	t3d2_gradient_needs_shift 0
	t3d2_gradient_needs_shift 3
	t3d2_gradient_needs_shift 6
	t3d2_gradient_needs_shift 9
	t3d2_gradient_needs_shift 12
	t3d2_gradient_needs_shift 15
	ret

.Lgradient_normalize_shift:
	ld	hl, (_t3d2_gradient_area)
	inc	hl
	ld	(_t3d2_gradient_area), hl
	ld	a, (_t3d2_gradient_area + 2)
	srl	a
	ld	(_t3d2_gradient_area + 2), a
	ld	a, (_t3d2_gradient_area + 1)
	rra
	ld	(_t3d2_gradient_area + 1), a
	ld	a, (_t3d2_gradient_area)
	rra
	ld	(_t3d2_gradient_area), a
	t3d2_gradient_divide_signed 0
	t3d2_gradient_divide_signed 3
	t3d2_gradient_divide_signed 6
	t3d2_gradient_divide_signed 9
	t3d2_gradient_divide_signed 12
	t3d2_gradient_divide_signed 15
	jp	.Lgradient_normalize_check
	.size	_t3d2_triangle_normalize, .-_t3d2_triangle_normalize

/* C retains only the reciprocal table selection. Assembly owns signed range
   normalization above and all six hot numerator products below. */
_t3d2_triangle_gradients:
	t3d2_gradient_one 0
	t3d2_gradient_one 3
	t3d2_gradient_one 6
	t3d2_gradient_one 9
	t3d2_gradient_one 12
	t3d2_gradient_one 15
	ret
	.size	_t3d2_triangle_gradients, .-_t3d2_triangle_gradients
