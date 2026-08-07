	.section	.text._edge_divide_q8_exact,"ax",@progbits
	.assume	ADL = 1
	.globl	_edge_divide_q8_exact
	.type	_edge_divide_q8_exact,@function

/* Exact signed (delta_x * 256) / delta_y for raster edges.
 *
 * The caller guarantees:
 *   -2097152 <= delta_x <= 2097152
 *             1 <= delta_y <= 2097152
 *
 * The generic 32-bit CRT divider carries a 32-bit remainder and always runs
 * 32 iterations.  Here the positive denominator is at most 21 bits, so the
 * remainder always fits in one 24-bit ADL register.  The dividend has at
 * most 30 significant bits after the fixed-point shift, so two known-zero
 * leading iterations can also be omitted.
 *
 * C ABI arguments after __frameset0:
 *   ix+6  signed 24-bit delta_x
 *   ix+9  unsigned 24-bit delta_y
 * Return: signed 32-bit quotient in E:HL, truncated toward zero.
 */
_edge_divide_q8_exact:
	call	__frameset0

	/* Form abs(delta_x), retaining its sign in C. */
	ld	hl, (ix + 6)
	ld	c, 0
	bit	7, (ix + 8)
	jr	z, .Ledge_magnitude_ready
	inc	c
	ex	de, hl
	or	a, a
	sbc	hl, hl
	sbc	hl, de
.Ledge_magnitude_ready:

	/* A:IY = abs(delta_x) << 10.  This is (abs(delta_x) << 8)
	 * pre-shifted past the two guaranteed-zero leading divide iterations. */
	push	hl
	pop	iy
	xor	a, a
	.rept	10
	add	iy, iy
	rla
	.endr

	/* Restoring unsigned division.  IY/A is the in-place dividend/quotient,
	 * HL is the exact 24-bit remainder, and DE is the positive denominator. */
	or	a, a
	sbc	hl, hl
	ld	de, (ix + 9)
	ld	b, 30
.Ledge_divide_loop:
	add	iy, iy
	rla
	adc	hl, hl
	sbc	hl, de
	jr	nc, .Ledge_divide_accept
	add	hl, de
	jr	.Ledge_divide_next
.Ledge_divide_accept:
	inc	iy
.Ledge_divide_next:
	djnz	.Ledge_divide_loop

	/* Apply the original numerator sign.  Magnitude division is floor;
	 * negating that quotient exactly matches C truncation toward zero. */
	push	iy
	pop	hl
	bit	0, c
	jr	z, .Ledge_positive_result
	ld	c, a
	ex	de, hl
	xor	a, a
	sbc	hl, hl
	sbc	hl, de
	sbc	a, c
.Ledge_positive_result:
	ld	e, a
	pop	ix
	ret

	.size	_edge_divide_q8_exact, .-_edge_divide_q8_exact
	.extern	__frameset0
