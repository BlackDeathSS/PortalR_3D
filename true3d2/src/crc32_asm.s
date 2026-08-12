	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_t3d2_crc32_asm
	.type	_t3d2_crc32_asm,@function

/* Table-driven IEEE CRC32. The bit-at-a-time C reference consumed more than
   one second for a single 80x60 logical frame on the CE. Keep CRC bytes in
   directly accessible 8-bit registers: L,H,C,A' = low..high. */
_t3d2_crc32_asm:
	push	ix
	push	iy
	ld	ix, (_t3d2_crc32_data)
	ld	iy, (_t3d2_crc32_size)
	ld	hl, 0xFFFFFF
	ld	c, 0xFF
	ld	a, 0xFF
	ex	af, af'
	lea	de, iy + 0
	ld	a, d
	or	a, e
	jr	z, .Lcrc_done

.Lcrc_byte:
	ld	a, (ix)
	xor	a, l
	inc	ix

	/* Shift the four-byte CRC right by one byte. A' temporarily carries the
	   fourth byte while A carries the table index. */
	ld	l, h
	ld	h, c
	ex	af, af'
	ld	c, a
	ex	af, af'

	/* Fetch one little-endian table entry. L/H are saved while HL addresses
	   the table; C can be XORed with byte two immediately. */
	push	hl
	ld	hl, 0
	ld	l, a
	add	hl, hl
	add	hl, hl
	ld	de, _t3d2_crc32_table
	add	hl, de
	ld	b, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	a, (hl)
	xor	a, c
	ld	c, a
	inc	hl
	ld	a, (hl)
	ex	af, af'
	pop	hl
	ld	a, l
	xor	a, b
	ld	l, a
	ld	a, h
	xor	a, d
	ld	h, a

	lea	iy, iy - 1
	lea	de, iy + 0
	ld	a, d
	or	a, e
	jp	nz, .Lcrc_byte

.Lcrc_done:
	ld	a, l
	cpl
	ld	(_t3d2_crc32_result), a
	ld	a, h
	cpl
	ld	(_t3d2_crc32_result + 1), a
	ld	a, c
	cpl
	ld	(_t3d2_crc32_result + 2), a
	ex	af, af'
	cpl
	ld	(_t3d2_crc32_result + 3), a
	pop	iy
	pop	ix
	ret
	.size	_t3d2_crc32_asm, .-_t3d2_crc32_asm
