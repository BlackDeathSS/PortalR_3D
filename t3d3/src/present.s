	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.globl	_present_low_frame_fast
	.type	_present_low_frame_fast,@function
	.globl	_present_low_frame_32_fast
	.type	_present_low_frame_32_fast,@function
	.globl	_present_low_frame_dirty_fast
	.type	_present_low_frame_dirty_fast,@function
	.globl	_present_low_frame_dirty_80_fast
	.type	_present_low_frame_dirty_80_fast,@function
	.globl	_present_low_frame_40_fast
	.type	_present_low_frame_40_fast,@function
	.globl	_present_low_frame_80_fast
	.type	_present_low_frame_80_fast,@function
	.globl	_present_low_frame_160_fast
	.type	_present_low_frame_160_fast,@function

	.macro	present_byte_pixel
	ld	a, (hl)
	inc	hl
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	.endm

/* Unroll all 64 source pixels to remove the per-pixel DJNZ overhead. */
_present_low_frame_fast:
	push	ix
	ld	hl, _low_frame + 2
	ld	de, (0xE30014)
	ld	ixh, 48

.Lpresent_row:
	.rept	64
	present_byte_pixel
	.endr

	/* Preserve the next source row while HL replicates the expanded row. */
	push	hl
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 1280
	ldir
	pop	hl

	dec	ixh
	jp	nz, .Lpresent_row

	pop	ix
	ret
	.size	_present_low_frame_fast, .-_present_low_frame_fast

	.macro	present_dirty_pixel
	ld	a, (ix)
	inc	ix
	ld	(iy), a
	inc	iy
	.rept	5
	ld	(de), a
	inc	de
	.endr
	.endm

/* Expand only changed 8x1 logical groups into their 40x5 physical blocks.
 *
 * The cache belongs to the current GraphX draw buffer. C invalidates the
 * groups touched by the HUD before entering, so skipped groups are guaranteed
 * to already contain the correct physical pixels even though overlays were
 * drawn after the previous presentation.
 *
 * C ABI argument:
 *   ix+6   64x48 cached logical frame for the current draw buffer
 */
_present_low_frame_dirty_fast:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, (ix + 6)
	push	iy
	push	hl
	pop	iy

	ld	ix, _low_frame + 2
	ld	de, (0xE30014)
	ld	b, 48

.Ldirty_row:
	ld	c, 8
.Ldirty_group:
	/* Compare six bytes as two native ADL words. The alternate register set
	 * leaves BC's row/group counters and DE's destination pointer untouched. */
	exx
	ld	hl, (ix)
	ld	bc, (iy)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty_compare_alt
	ld	hl, (ix + 3)
	ld	bc, (iy + 3)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty_compare_alt
	exx
	ld	a, (ix + 6)
	cp	a, (iy + 6)
	jp	nz, .Ldirty_draw_group
	ld	a, (ix + 7)
	cp	a, (iy + 7)
	jp	nz, .Ldirty_draw_group
	jp	.Ldirty_group_unchanged

.Ldirty_compare_alt:
	exx
	jp	.Ldirty_draw_group

.Ldirty_group_unchanged:
	lea	ix, ix + 8
	lea	iy, iy + 8
	push	bc
	push	de
	pop	hl
	ld	bc, 40
	add	hl, bc
	push	hl
	pop	de
	pop	bc
	jp	.Ldirty_group_done

.Ldirty_draw_group:
	push	bc
	.rept	8
	present_dirty_pixel
	.endr

	/* Copy the expanded 40-byte row into the four rows below it. IX is
	 * restored to the next group in the first physical row afterwards. */
	push	ix
	push	iy
	push	de
	push	de
	pop	hl
	ld	bc, 40
	or	a, a
	sbc	hl, bc
	ex	de, hl
	ld	bc, 280
	add	hl, bc
	ex	de, hl
	ld	bc, 40
	ldir
	.rept	3
	push	de
	pop	hl
	ld	bc, 40
	or	a, a
	sbc	hl, bc
	ex	de, hl
	ld	bc, 280
	add	hl, bc
	ex	de, hl
	ld	bc, 40
	ldir
	.endr
	pop	de
	pop	iy
	pop	ix
	pop	bc

.Ldirty_group_done:
	dec	c
	jp	nz, .Ldirty_group

	/* Each source row occupies five physical rows. The group loop advanced
	 * through the first; skip the four replicated rows. */
	push	bc
	push	de
	pop	hl
	ld	bc, 1280
	add	hl, bc
	push	hl
	pop	de
	pop	bc
	dec	b
	jp	nz, .Ldirty_row

	pop	iy
	pop	ix
	ret
	.size	_present_low_frame_dirty_fast, .-_present_low_frame_dirty_fast

	.macro	present_dirty_pixel_4
	ld	a, (ix)
	inc	ix
	ld	(iy), a
	inc	iy
	.rept	4
	ld	(de), a
	inc	de
	.endr
	.endm

/* Draw one changed eight-pixel half group and replicate its 32-pixel physical
 * row three times.  The caller keeps BC as the row/group counters. */
	.macro	present_dirty_half_4
	push	bc
	/* Flat walls frequently change as one solid run.  Detect that case after
	 * the cache mismatch and expand one source value directly. */
	ld	a, (ix)
	/* Test the far endpoint first: mixed edge groups usually reject after one
	 * comparison, while truly solid groups still take the direct-fill path. */
	.irp	offset,7,4,1,2,3,5,6
	cp	a, (ix + \offset)
	jp	nz, .Ldirty80_half_pixels\@
	.endr
	lea	ix, ix + 8
	.rept	8
	ld	(iy), a
	inc	iy
	.endr
	/* Seed one physical pixel, then use an overlapping LDIR as a 32-byte
	 * constant-color fill.  This is substantially cheaper than expanding the
	 * eight identical logical pixels one at a time. */
	ld	(de), a
	push	de
	pop	hl
	inc	de
	ld	bc, 31
	ldir
	jp	.Ldirty80_half_expand\@
.Ldirty80_half_pixels\@:
	.rept	8
	present_dirty_pixel_4
	.endr
.Ldirty80_half_expand\@:
	push	ix
	push	iy
	push	de
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	ex	de, hl
	ld	bc, 288
	add	hl, bc
	ex	de, hl
	ld	bc, 32
	ldir
	.rept	2
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	ex	de, hl
	ld	bc, 288
	add	hl, bc
	ex	de, hl
	ld	bc, 32
	ldir
	.endr
	pop	de
	pop	iy
	pop	ix
	pop	bc
	.endm

/* 80x60 hierarchical dirty presenter. Sixteen logical pixels remain the
 * outer group, but each eight-pixel half is compared and copied separately.
 * Sparse wall/portal edges therefore update 32x4 instead of 64x4 pixels. */
	.section	.text._present_low_frame_dirty_80_fast,"ax",@progbits
_present_low_frame_dirty_80_fast:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, (ix + 6)
	push	iy
	push	hl
	pop	iy
	ld	ix, _low_frame + 2
	ld	de, (0xE30014)
	ld	b, 60
.Ldirty80_row:
	ld	c, 5
.Ldirty80_group:
	/* Cheap outer rejection: unchanged 16-pixel groups never pay either
	 * eight-pixel comparison. */
	exx
	ld	hl, (ix)
	ld	bc, (iy)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_outer_compare_alt
	ld	hl, (ix + 3)
	ld	bc, (iy + 3)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_outer_compare_alt
	ld	hl, (ix + 6)
	ld	bc, (iy + 6)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_outer_compare_alt
	ld	hl, (ix + 9)
	ld	bc, (iy + 9)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_outer_compare_alt
	ld	hl, (ix + 12)
	ld	bc, (iy + 12)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_outer_compare_alt
	exx
	ld	a, (ix + 15)
	cp	a, (iy + 15)
	jp	nz, .Ldirty80_split_group
	lea	ix, ix + 16
	lea	iy, iy + 16
	push	bc
	ex	de, hl
	ld	bc, 64
	add	hl, bc
	ex	de, hl
	pop	bc
	jp	.Ldirty80_group_done
.Ldirty80_outer_compare_alt:
	exx
.Ldirty80_split_group:
	/* First eight-pixel half. */
	exx
	ld	hl, (ix)
	ld	bc, (iy)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_first_compare_alt
	ld	hl, (ix + 3)
	ld	bc, (iy + 3)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_first_compare_alt
	exx
	ld	a, (ix + 6)
	cp	a, (iy + 6)
	jr	nz, .Ldirty80_draw_first
	ld	a, (ix + 7)
	cp	a, (iy + 7)
	jr	nz, .Ldirty80_draw_first
	lea	ix, ix + 8
	lea	iy, iy + 8
	push	bc
	ex	de, hl
	ld	bc, 32
	add	hl, bc
	ex	de, hl
	pop	bc
	jp	.Ldirty80_second
.Ldirty80_first_compare_alt:
	exx

.Ldirty80_draw_first:
	present_dirty_half_4

.Ldirty80_second:
	/* Second eight-pixel half. */
	exx
	ld	hl, (ix)
	ld	bc, (iy)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_second_compare_alt
	ld	hl, (ix + 3)
	ld	bc, (iy + 3)
	or	a, a
	sbc	hl, bc
	jr	nz, .Ldirty80_second_compare_alt
	exx
	ld	a, (ix + 6)
	cp	a, (iy + 6)
	jr	nz, .Ldirty80_draw_second
	ld	a, (ix + 7)
	cp	a, (iy + 7)
	jr	nz, .Ldirty80_draw_second
	lea	ix, ix + 8
	lea	iy, iy + 8
	push	bc
	ex	de, hl
	ld	bc, 32
	add	hl, bc
	ex	de, hl
	pop	bc
	jp	.Ldirty80_group_done
.Ldirty80_second_compare_alt:
	exx

.Ldirty80_draw_second:
	present_dirty_half_4

.Ldirty80_group_done:
	dec	c
	jp	nz, .Ldirty80_group
	push	bc
	ex	de, hl
	ld	bc, 960
	add	hl, bc
	ex	de, hl
	pop	bc
	dec	b
	jp	nz, .Ldirty80_row
	pop	iy
	pop	ix
	ret
	.size	_present_low_frame_dirty_80_fast, .-_present_low_frame_dirty_80_fast

	.macro	present_pixel_8
	ld	a, (iy)
	inc	iy
	.rept	8
	ld	(de), a
	inc	de
	.endr
	.endm

/* Expand a packed 40x30 logical frame by 8x. */
	.section	.text._present_low_frame_40_fast,"ax",@progbits
_present_low_frame_40_fast:
	push	iy
	ld	iy, _low_frame + 2
	ld	de, (0xE30014)
	ld	bc, 30
.Lpresent40_row:
	push	bc
	ld	b, 40
.Lpresent40_pixel:
	present_pixel_8
	djnz	.Lpresent40_pixel
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 2240
	ldir
	pop	bc
	dec	c
	jp	nz, .Lpresent40_row
	pop	iy
	ret
	.size	_present_low_frame_40_fast, .-_present_low_frame_40_fast

	.macro	present_pixel_4
	ld	a, (iy)
	inc	iy
	.rept	4
	ld	(de), a
	inc	de
	.endr
	.endm

/* Expand a packed 80x60 logical frame by 4x. */
	.section	.text._present_low_frame_80_fast,"ax",@progbits
_present_low_frame_80_fast:
	push	iy
	ld	iy, _low_frame + 2
	ld	de, (0xE30014)
	ld	bc, 60
.Lpresent80_row:
	push	bc
	/* The 64x48 and 160x120 presenters already avoid a branch per source
	 * pixel. Do the same here: this removes 4,800 DJNZ executions from every
	 * full 80x60 presentation. */
	.rept	80
	present_pixel_4
	.endr
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 960
	ldir
	pop	bc
	dec	c
	jp	nz, .Lpresent80_row
	pop	iy
	ret
	.size	_present_low_frame_80_fast, .-_present_low_frame_80_fast

	.macro	present_pixel_2
	ld	a, (iy)
	inc	iy
	.rept	2
	ld	(de), a
	inc	de
	.endr
	.endm

/* Expand a packed 160x120 logical frame by 2x. */
	.section	.text._present_low_frame_160_fast,"ax",@progbits
_present_low_frame_160_fast:
	push	iy
	ld	iy, _low_frame + 2
	ld	de, (0xE30014)
	ld	bc, 120
.Lpresent160_row:
	push	bc
	.rept	160
	present_pixel_2
	.endr
	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 320
	ldir
	pop	bc
	dec	c
	jp	nz, .Lpresent160_row
	pop	iy
	ret
	.size	_present_low_frame_160_fast, .-_present_low_frame_160_fast

/* Expand the packed 32x24 performance framebuffer to 320x240. */
	.section	.text._present_low_frame_32_fast,"ax",@progbits
_present_low_frame_32_fast:
	push	iy
	ld	iy, _low_frame + 2
	ld	de, (0xE30014)
	ld	bc, 24

.Lpresent32_row:
	push	bc
	ld	b, 32
.Lpresent32_pixel:
	ld	a, (iy)
	inc	iy
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	ld	(de), a
	inc	de
	djnz	.Lpresent32_pixel

	push	de
	pop	hl
	ld	bc, 320
	or	a, a
	sbc	hl, bc
	ld	bc, 2880
	ldir

	pop	bc
	dec	c
	jp	nz, .Lpresent32_row

	pop	iy
	ret
	.size	_present_low_frame_32_fast, .-_present_low_frame_32_fast
