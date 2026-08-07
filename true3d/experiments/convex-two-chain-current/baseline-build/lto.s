	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._engine_render_benchmark_reset,"ax",@progbits
	.globl	_engine_render_benchmark_reset  ; -- Begin function engine_render_benchmark_reset
	.type	_engine_render_benchmark_reset,@function
_engine_render_benchmark_reset:         ; @engine_render_benchmark_reset
; %bb.0:
	xor	a, a
	ld	bc, 0
	ld	e, a
	ld	hl, _render_benchmark
	ld	(_render_benchmark_active), a
	ld	(_render_benchmark_last), bc
	ld	a, e
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	push	hl
	pop	de
	inc	de
	ld	bc, 85
	ldir
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_engine_render_benchmark_reset, .Lfunc_end0-_engine_render_benchmark_reset
                                        ; -- End function
	.section	.text._engine_render_benchmark_begin,"ax",@progbits
	.globl	_engine_render_benchmark_begin  ; -- Begin function engine_render_benchmark_begin
	.type	_engine_render_benchmark_begin,@function
_engine_render_benchmark_begin:         ; @engine_render_benchmark_begin
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	nz, .LBB1_6
; %bb.1:
	xor	a, a
	ld	iyl, 1
	ld	(_render_benchmark_category), a
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	ld	(ix - 3), de
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	c, .LBB1_5
; %bb.2:
	ld	a, iyl
	ld	iy, (-917472)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 3)
	jr	nc, .LBB1_4
; %bb.3:
	lea	bc, iy + 0
	.local	.LBB1_4
.LBB1_4:
	ld	iyl, a
	.local	.LBB1_5
.LBB1_5:
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	(_render_benchmark_last), bc
	ld	(_render_benchmark_last+3), a
	ld	a, iyl
	ld	(_render_benchmark_active), a
	.local	.LBB1_6
.LBB1_6:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_engine_render_benchmark_begin, .Lfunc_end1-_engine_render_benchmark_begin
                                        ; -- End function
	.section	.text._engine_render_benchmark_end,"ax",@progbits
	.globl	_engine_render_benchmark_end    ; -- Begin function engine_render_benchmark_end
	.type	_engine_render_benchmark_end,@function
_engine_render_benchmark_end:           ; @engine_render_benchmark_end
; %bb.0:
	ld	hl, -8
	call	__frameset
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB2_7
; %bb.1:
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB2_3
; %bb.2:
	push	bc
	pop	hl
	jr	.LBB2_6
	.local	.LBB2_3
.LBB2_3:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB2_5
; %bb.4:
	push	de
	pop	iy
	.local	.LBB2_5
.LBB2_5:
	lea	hl, iy + 0
	.local	.LBB2_6
.LBB2_6:
	ld	(ix - 3), hl
	ld	de, 0
	ld	(ix - 4), e
	ld	bc, (_render_benchmark_last)
	ld	iy, _render_benchmark_last
	lea	iy, iy + 3
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	(ix - 5), e                     ; 1-byte Folded Spill
	ld	a, (_render_benchmark_category)
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 8), iy
	lea	iy, iy + 3
	ld	e, (iy)
	ld	a, (ix - 5)                     ; 1-byte Folded Reload
	call	__ladd
	ld	iy, (ix - 8)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, _render_benchmark+60
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 3)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 4)                     ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	xor	a, a
	ld	(_render_benchmark_active), a
	.local	.LBB2_7
.LBB2_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_engine_render_benchmark_end, .Lfunc_end2-_engine_render_benchmark_end
                                        ; -- End function
	.section	.text._engine_render_benchmark_calibrate,"ax",@progbits
	.globl	_engine_render_benchmark_calibrate ; -- Begin function engine_render_benchmark_calibrate
	.type	_engine_render_benchmark_calibrate,@function
_engine_render_benchmark_calibrate:     ; @engine_render_benchmark_calibrate
; %bb.0:
	ld	hl, -124
	call	__frameset
	ld	e, 0
	or	a, a
	sbc	hl, hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	nz, .LBB3_22
; %bb.1:
	ld	hl, _render_benchmark
	ld	bc, 86
	ld	iy, _render_benchmark_last
	ld	de, -1
	ld	(ix - 91), de
	ld	a, d
	ld	(ix - 88), a
	lea	de, ix - 87
	ld	(ix - 94), de
	ldir
	ld	hl, (_render_benchmark_last)
	ld	(ix - 97), hl
	ld	a, (_render_benchmark_last+3)
	ld	(ix - 99), a                    ; 1-byte Folded Spill
	ld	a, (_render_benchmark_category)
	ld	(ix - 98), a                    ; 1-byte Folded Spill
	lea	hl, iy + 3
	ld	(ix - 102), hl
	ld	iyl, 0
	ld	a, iyl
	ld	iy, _render_benchmark+60
	lea	hl, iy + 3
	ld	iyl, a
	ld	(ix - 106), hl
	.local	.LBB3_2
.LBB3_2:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_4 Depth 2
	cp	a, 8
	jp	z, .LBB3_21
; %bb.3:                                ;   in Loop: Header=BB3_2 Depth=1
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	ld	a, iyl
	ld	(_render_benchmark_active), a
	or	a, a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	hl, (ix - 102)
	ld	(hl), 0
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	bc, _render_benchmark
	push	bc
	pop	hl
	inc	hl
	ex	de, hl
	push	bc
	pop	hl
	ld	bc, 85
	ldir
	call	_engine_render_benchmark_begin
	ld	a, (_render_benchmark_active)
	ld	e, a
	ld	a, (_render_benchmark_category)
	ld	c, a
	ld	iy, (_render_benchmark_last)
	ld	a, (_render_benchmark_last+3)
	ld	h, a
	ld	d, 0
	.local	.LBB3_4
.LBB3_4:                                ;   Parent Loop BB3_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, d
	cp	a, 64
	jp	z, .LBB3_16
; %bb.5:                                ;   in Loop: Header=BB3_4 Depth=2
	bit	0, e
	jp	z, .LBB3_15
; %bb.6:                                ;   in Loop: Header=BB3_4 Depth=2
	ld	l, 1
	ld	a, d
	and	a, l
	ld	l, a
	ld	a, c
	cp	a, l
	ld	a, -1
	jr	nz, .LBB3_8
; %bb.7:                                ;   in Loop: Header=BB3_4 Depth=2
	ld	a, 0
	.local	.LBB3_8
.LBB3_8:                                ;   in Loop: Header=BB3_4 Depth=2
	bit	0, a
	jp	z, .LBB3_15
; %bb.9:                                ;   in Loop: Header=BB3_4 Depth=2
	ld	a, h
	ld	(ix - 112), iy
	ld	(ix - 117), c                   ; 1-byte Folded Spill
	ld	(ix - 114), l                   ; 1-byte Folded Spill
	ld	bc, (-917472)
	ld	hl, (-917472)
	ld	(ix - 120), hl
	ld	(ix - 109), bc
	or	a, a
	sbc	hl, bc
	ld	iy, 2
	lea	bc, iy + 0
	or	a, a
	sbc	hl, bc
	ld	(ix - 113), e
	jr	nc, .LBB3_11
; %bb.10:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	iy, (ix - 120)
	ld	bc, (ix - 112)
	jr	.LBB3_14
	.local	.LBB3_11
.LBB3_11:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	iy, (-917472)
	lea	hl, iy + 0
	ld	bc, (ix - 120)
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 112)
	jr	nc, .LBB3_13
; %bb.12:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	(ix - 109), iy
	.local	.LBB3_13
.LBB3_13:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	iy, (ix - 109)
	.local	.LBB3_14
.LBB3_14:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	(ix - 109), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 120), e
	lea	hl, iy + 0
	call	__lsub
	ld	(ix - 112), hl
	ld	(ix - 121), e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 117)                   ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	iy, _render_benchmark
	add	iy, bc
	ld	bc, (iy)
	ld	(ix - 124), iy
	lea	hl, iy + 3
	ld	(ix - 117), hl
	ld	hl, (ix - 112)
	ld	iy, (ix - 117)
	ld	a, (iy)
	call	__ladd
	ld	iy, (ix - 124)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 106)
	ld	e, (iy)
	ld	bc, (ix - 112)
	ld	a, (ix - 121)                   ; 1-byte Folded Reload
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	iy, (ix - 109)
	ld	(_render_benchmark_last), iy
	ld	e, (ix - 120)                   ; 1-byte Folded Reload
	ld	a, e
	ld	(_render_benchmark_last+3), a
	ld	a, (ix - 114)                   ; 1-byte Folded Reload
	ld	(_render_benchmark_category), a
	ld	l, a
	sla	l
	ld	bc, 0
	ld	c, l
	ld	hl, _render_benchmark+40
	add	hl, bc
	ld	bc, (hl)
	inc.sis	bc
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	h, e
	ld	c, a
	ld	e, (ix - 113)                   ; 1-byte Folded Reload
	.local	.LBB3_15
.LBB3_15:                               ;   in Loop: Header=BB3_4 Depth=2
	inc	d
	jp	.LBB3_4
	.local	.LBB3_16
.LBB3_16:                               ;   in Loop: Header=BB3_2 Depth=1
	call	_engine_render_benchmark_end
	ld	hl, (_render_benchmark+60)
	ld	a, (_render_benchmark+63)
	ld	e, a
	ld	bc, (ix - 91)
	ld	d, (ix - 88)                    ; 1-byte Folded Reload
	ld	a, d
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	bit	0, a
	jr	nz, .LBB3_18
; %bb.17:                               ;   in Loop: Header=BB3_2 Depth=1
	push	bc
	pop	hl
	.local	.LBB3_18
.LBB3_18:                               ;   in Loop: Header=BB3_2 Depth=1
	bit	0, a
	ld	iyl, 0
	jr	nz, .LBB3_20
; %bb.19:                               ;   in Loop: Header=BB3_2 Depth=1
	ld	e, d
	.local	.LBB3_20
.LBB3_20:                               ;   in Loop: Header=BB3_2 Depth=1
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	inc	a
	ld	(ix - 91), hl
	ld	(ix - 88), e                    ; 1-byte Folded Spill
	jp	.LBB3_2
	.local	.LBB3_21
.LBB3_21:
	ld	de, _render_benchmark
	ld	hl, (ix - 94)
	ld	bc, 86
	ldir
	ld	hl, (ix - 97)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 99)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, (ix - 98)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_category), a
	ld	a, iyl
	ld	(_render_benchmark_active), a
	ld	l, 8
	ld	bc, (ix - 91)
	ld	a, (ix - 88)                    ; 1-byte Folded Reload
	call	__lshl
	push	bc
	pop	hl
	ld	e, a
	ld	bc, 65
	ld	a, iyl
	call	__ldivu
	.local	.LBB3_22
.LBB3_22:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_engine_render_benchmark_calibrate, .Lfunc_end3-_engine_render_benchmark_calibrate
                                        ; -- End function
	.section	.text._engine_render_benchmark_read,"ax",@progbits
	.globl	_engine_render_benchmark_read   ; -- Begin function engine_render_benchmark_read
	.type	_engine_render_benchmark_read,@function
_engine_render_benchmark_read:          ; @engine_render_benchmark_read
; %bb.0:
	ld	hl, _render_benchmark
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_engine_render_benchmark_read, .Lfunc_end4-_engine_render_benchmark_read
                                        ; -- End function
	.section	.text._engine_render_benchmark_lod_state,"ax",@progbits
	.globl	_engine_render_benchmark_lod_state ; -- Begin function engine_render_benchmark_lod_state
	.type	_engine_render_benchmark_lod_state,@function
_engine_render_benchmark_lod_state:     ; @engine_render_benchmark_lod_state
; %bb.0:
	ld	l, 3
	ld	b, 2
	ld	e, 12
	ld	a, (_portal_lod_state)
	and	a, l
	ld	l, a
	ld	a, (_portal_lod_state+1)
	call	__bshl
	and	a, e
	ld	e, a
	ld	a, e
	add	a, l
	ld	l, a
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_engine_render_benchmark_lod_state, .Lfunc_end5-_engine_render_benchmark_lod_state
                                        ; -- End function
	.section	.text._engine_render_benchmark_logical_hash,"ax",@progbits
	.globl	_engine_render_benchmark_logical_hash ; -- Begin function engine_render_benchmark_logical_hash
	.type	_engine_render_benchmark_logical_hash,@function
_engine_render_benchmark_logical_hash:  ; @engine_render_benchmark_logical_hash
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	iy, 0
	ld	hl, _low_frame+2
	ld	(ix - 9), hl
	ld	a, (_active_render_width)
	ld	e, a
	lea	bc, iy + 0
	ld	c, e
	ld	a, (_active_render_height)
	ld	(ix - 10), a
	lea	hl, iy + 0
	ld	l, a
	call	__imulu
	ld	(ix - 6), hl
	xor	a, a
	ld	(ix - 3), a
	ld	hl, (ix - 5)
	ld	h, a
	ld	l, e
	ld	d, iyl
	ld	iy, 403
	ld	e, d
	ld	bc, 1875397
	ld	a, -127
	call	__lxor
	lea	bc, iy + 0
	ld	a, iyh
	call	__lmulu
	dec	a
	ld	(ix - 2), a
	ld	bc, (ix - 4)
	ld	b, a
	ld	c, (ix - 10)                    ; 1-byte Folded Reload
	ld	(ix - 10), d                    ; 1-byte Folded Spill
	ld	a, d
	call	__lxor
	.local	.LBB6_1
.LBB6_1:                                ; =>This Inner Loop Header: Depth=1
	lea	bc, iy + 0
	ld	a, 1
	call	__lmulu
	push	hl
	pop	bc
	ld	hl, (ix - 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_3
; %bb.2:                                ;   in Loop: Header=BB6_1 Depth=1
	ld	hl, (ix - 9)
	ld	a, (hl)
	ld	l, 0
	ld	(ix - 1), l
	ld	iy, (ix - 3)
	ex	de, hl
	ld	iyh, e
	ex	de, hl
	ld	iyl, a
	push	bc
	pop	hl
	lea	bc, iy + 0
	ld	iy, 403
	ld	a, (ix - 10)                    ; 1-byte Folded Reload
	call	__lxor
	ld	bc, (ix - 6)
	dec	bc
	ld	(ix - 6), bc
	ld	bc, (ix - 9)
	inc	bc
	ld	(ix - 9), bc
	jr	.LBB6_1
	.local	.LBB6_3
.LBB6_3:
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_engine_render_benchmark_logical_hash, .Lfunc_end6-_engine_render_benchmark_logical_hash
                                        ; -- End function
	.section	.text._engine_init,"ax",@progbits
	.globl	_engine_init                    ; -- Begin function engine_init
	.type	_engine_init,@function
_engine_init:                           ; @engine_init
; %bb.0:
	ld	hl, -62
	call	__frameset
	ld	hl, (ix + 6)
	ld	c, 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB7_5
; %bb.1:
	ld	iy, (ix + 9)
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB7_5
; %bb.2:
	ld	hl, (iy)
	ld	(ix - 12), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB7_5
; %bb.3:
	ld	de, (iy + 3)
	ld	(ix - 21), de
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB7_5
; %bb.4:
	ld	e, -9
	ld	iy, (ix - 12)
	ld	l, (iy + 5)
	ld	a, l
	add	a, e
	ld	e, a
	cp	a, -8
	jr	nc, .LBB7_7
	.local	.LBB7_5
.LBB7_5:
	ld	a, c
	.local	.LBB7_6
.LBB7_6:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB7_7
.LBB7_7:
	ld	(ix - 45), bc
	ld	e, 6
	ld	(ix - 47), e
	ld	(ix - 46), d
	ld	c, 1
	ld	iy, _portals+36
	ld	(ix - 33), iy
	lea	de, ix - 9
	ld	(ix - 62), de
	ld	a, l
	ld	(_room_count), a
	ld	a, c
	ld	de, 0
	ld	e, l
	ld	(ix - 50), de
	ld	bc, 18
	ld	hl, _world_faces
	ld	(ix - 36), hl
	or	a, a
	sbc	hl, hl
	.local	.LBB7_8
.LBB7_8:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_10 Depth 2
                                        ;       Child Loop BB7_12 Depth 3
	push	hl
	pop	iy
	ld	de, (ix - 50)
	or	a, a
	sbc	hl, de
	jp	z, .LBB7_16
; %bb.9:                                ;   in Loop: Header=BB7_8 Depth=1
	lea	de, iy + 0
	push	de
	pop	hl
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 21)
	add	hl, bc
	ld	(ix - 15), hl
	push	de
	pop	hl
	ld	bc, 13
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _rooms
	add	iy, bc
	ld	l, (ix - 47)
	ld	h, (ix - 46)
	ld	(ix - 56), de
	ld	h, e
	ld	a, h
	ld	b, 3
	call	__bshl
	ld	(ix - 47), l
	ld	(ix - 46), h
	mlt	hl
	ld	(ix - 59), l
	ld	(ix - 58), h
	ld	(iy), l
	ld	hl, (ix - 15)
	ld	hl, (hl)
	ld	(ix - 24), hl
	ld	(iy + 1), l
	ld	(iy + 2), h
	lea	bc, iy + 0
	ld	iy, (ix - 15)
	ld	hl, (iy + 2)
	ld	(ix - 30), hl
	push	bc
	pop	iy
	ld	(iy + 3), l
	ld	(iy + 4), h
	ld	iy, (ix - 15)
	ld	de, (iy + 4)
	push	bc
	pop	iy
	ld	(iy + 5), e
	ld	(iy + 6), d
	ld	iy, (ix - 15)
	ld	hl, (iy + 6)
	ld	(ix - 42), hl
	push	bc
	pop	iy
	ld	(iy + 7), l
	ld	(iy + 8), h
	ld	iy, (ix - 15)
	ld	hl, (iy + 8)
	ld	(ix - 27), hl
	push	bc
	pop	iy
	ld	(iy + 9), l
	ld	(iy + 10), h
	ld	iy, (ix - 15)
	ld	hl, (iy + 10)
	ld	(ix - 39), hl
	push	bc
	pop	iy
	ld	(iy + 11), l
	ld	(iy + 12), h
	or	a, a
	sbc	hl, hl
	ld	(ix - 57), a                    ; 1-byte Folded Spill
	ld	l, a
	ld	(ix - 18), hl
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _world_vertices
	add	iy, bc
	ld	hl, (ix - 24)
	ld	(iy), l
	ld	(iy + 1), h
	ld	(ix - 53), de
	ld	(iy + 2), e
	ld	(iy + 3), d
	ld	hl, (ix - 27)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	hl, (ix - 18)
	inc	hl
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _world_vertices
	add	iy, bc
	ld	hl, (ix - 30)
	ld	(iy), l
	ld	(iy + 1), h
	ld	(iy + 2), e
	ld	(iy + 3), d
	ld	hl, (ix - 27)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	hl, (ix - 18)
	ld	bc, 2
	add	hl, bc
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _world_vertices
	add	iy, bc
	ld	hl, (ix - 30)
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, (ix - 42)
	ld	(iy + 2), e
	ld	(iy + 3), d
	ld	hl, (ix - 27)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	hl, (ix - 18)
	ld	bc, 3
	add	hl, bc
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _world_vertices
	add	iy, bc
	ld	hl, (ix - 24)
	ld	(iy), l
	ld	(iy + 1), h
	ld	(iy + 2), e
	ld	(iy + 3), d
	ld	hl, (ix - 27)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	hl, (ix - 18)
	ld	de, 4
	add	hl, de
	ld	bc, 6
	call	__imulu
	ex	de, hl
	ld	iy, _world_vertices
	add	iy, de
	ld	hl, (ix - 24)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 53)
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	hl, (ix - 39)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	hl, (ix - 18)
	ld	de, 5
	add	hl, de
	call	__imulu
	ex	de, hl
	ld	iy, _world_vertices
	add	iy, de
	ld	hl, (ix - 30)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 53)
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	de, (ix - 39)
	ld	(iy + 4), e
	ld	(iy + 5), d
	ld	hl, (ix - 18)
	add	hl, bc
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _world_vertices
	add	iy, bc
	ld	hl, (ix - 30)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 42)
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	(iy + 4), e
	ld	(iy + 5), d
	ld	de, 7
	ld	hl, (ix - 18)
	add	hl, de
	ld	bc, 6
	call	__imulu
	ex	de, hl
	ld	iy, _world_vertices
	add	iy, de
	ld	hl, (ix - 24)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 42)
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	hl, (ix - 39)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	de, 0
	ld	l, (ix - 59)
	ld	h, (ix - 58)
	ld	e, l
	ld	(ix - 27), de
	ld	hl, (ix - 36)
	ld	(ix - 18), hl
	ld	hl, _box_face_vertices
	ld	(ix - 24), hl
	ld	de, 0
	.local	.LBB7_10
.LBB7_10:                               ;   Parent Loop BB7_8 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB7_12 Depth 3
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB7_15
; %bb.11:                               ;   in Loop: Header=BB7_10 Depth=2
	ld	(ix - 30), de
	ex	de, hl
	ld	de, (ix - 27)
	add	hl, de
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _world_faces
	add	hl, bc
	ld	(ix - 39), hl
	ld	bc, 0
	.local	.LBB7_12
.LBB7_12:                               ;   Parent Loop BB7_8 Depth=1
                                        ;     Parent Loop BB7_10 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	jr	z, .LBB7_14
; %bb.13:                               ;   in Loop: Header=BB7_12 Depth=3
	ld	iy, (ix - 24)
	add	iy, bc
	ld	a, (iy)
	ld	l, (ix - 57)
	add	a, l
	ld	l, a
	ld	iy, (ix - 18)
	add	iy, bc
	ld	(iy), l
	inc	bc
	jr	.LBB7_12
	.local	.LBB7_14
.LBB7_14:                               ;   in Loop: Header=BB7_10 Depth=2
	ld	iy, (ix - 15)
	ld	de, (ix - 30)
	add	iy, de
	ld	a, (iy + 12)
	ld	b, 2
	call	__bshl
	ld	l, 16
	add	a, l
	ld	l, a
	ld	iy, (ix - 39)
	ld	(iy + 4), l
	ld	(iy + 5), -1
	inc	de
	ld	iy, (ix - 24)
	lea	iy, iy + 4
	ld	(ix - 24), iy
	ld	iy, (ix - 18)
	lea	iy, iy + 6
	ld	(ix - 18), iy
	ld	hl, 6
	push	hl
	pop	bc
	jr	.LBB7_10
	.local	.LBB7_15
.LBB7_15:                               ;   in Loop: Header=BB7_8 Depth=1
	ld	hl, (ix - 56)
	inc	hl
	ld	iy, (ix - 36)
	lea	iy, iy + 36
	ld	(ix - 36), iy
	ld	e, 1
	ld	a, e
	ld	bc, 18
	jp	.LBB7_8
	.local	.LBB7_16
.LBB7_16:
	ld	(_portals+44), a
	ld	l, 0
	ld	a, l
	ld	(_portals+90), a
	ld	bc, 36
	or	a, a
	sbc	hl, hl
	ld	(ix - 15), hl
	ld	iy, (ix - 12)
	ld	de, 20
	.local	.LBB7_17
.LBB7_17:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB7_22
; %bb.18:                               ;   in Loop: Header=BB7_17 Depth=1
	lea	bc, iy + 0
	push	bc
	pop	hl
	add	hl, de
	ld	(ix - 21), hl
	ld	hl, 384
	ld	iy, (ix - 33)
	ld	(iy), hl
	ld	hl, 448
	ld	(iy + 3), hl
	ld	(iy + 9), 0
	push	bc
	pop	iy
	ld	(ix - 18), de
	ld	(ix - 12), iy
	ld	e, (iy + 7)
	ld	hl, 1
	ld	bc, (ix - 15)
                                        ; kill: def $c killed $c killed $ubc
	call	__ishl
	ld	a, l
	and	a, e
	ld	l, a
	or	a, a
	jp	z, .LBB7_21
; %bb.19:                               ;   in Loop: Header=BB7_17 Depth=1
	ld	iy, (ix - 21)
	ld	a, (iy - 6)
	or	a, a
	sbc	hl, hl
	ld	(ix - 21), a                    ; 1-byte Folded Spill
	ld	l, a
	ld	bc, 13
	call	__imulu
	ex	de, hl
	ld	hl, _rooms
	add	hl, de
	ld	iy, (ix - 12)
	ld	de, (ix - 18)
	add	iy, de
	ld	(ix - 27), iy
	ld	a, (iy - 5)
	ld	(ix - 24), a                    ; 1-byte Folded Spill
	ld	e, a
	push	de
	push	hl
	call	_room_face_holds_portal
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB7_21
; %bb.20:                               ;   in Loop: Header=BB7_17 Depth=1
	ld	iy, (ix - 27)
	ld	de, (iy - 4)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 9), hl
	ld	de, (iy - 2)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 6), hl
	ld	de, (iy)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 3), hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	hl, (ix - 62)
	ld	bc, 9
	ldir
	ld	l, (ix - 24)                    ; 1-byte Folded Reload
	push	hl
	ld	l, (ix - 21)                    ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 45)
	push	hl
	call	_configure_portal_on_face
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix + 9)
	ld	hl, (hl)
	ld	(ix - 12), hl
	.local	.LBB7_21
.LBB7_21:                               ;   in Loop: Header=BB7_17 Depth=1
	ld	hl, (ix - 15)
	inc	hl
	ld	(ix - 15), hl
	ld	hl, (ix - 18)
	ld	de, 8
	add	hl, de
	ld	iy, (ix - 33)
	lea	iy, iy + 46
	ld	(ix - 33), iy
	ld	de, (ix - 45)
	inc	e
	ld	(ix - 45), de
	ex	de, hl
	ld	iy, (ix - 12)
	ld	bc, 36
	jp	.LBB7_17
	.local	.LBB7_22
.LBB7_22:
	ld	de, (iy + 8)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	lea	bc, iy + 0
	ld	iy, (ix + 6)
	ld	(iy), hl
	push	bc
	pop	iy
	ld	de, (iy + 10)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	iy, (ix + 6)
	ld	(iy + 3), hl
	push	bc
	pop	iy
	ld	de, (iy + 12)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	iy, (ix + 6)
	ld	(iy + 6), hl
	or	a, a
	sbc	hl, hl
	ld	(iy + 9), hl
	ld	(iy + 12), hl
	ld	(iy + 15), hl
	ld	(iy + 45), 64
	ld	(iy + 46), h
	push	iy
	call	_rebuild_camera_basis
	pop	hl
	ld	hl, (ix + 9)
	ld	iy, (hl)
	ld	a, (iy + 6)
	ld	iy, (ix + 6)
	ld	(iy + 47), a
	ld	(iy + 48), 0
	ld	(iy + 49), 1
	ld	(iy + 50), 0
	ld	(iy + 51), 0
	lea	de, iy + 0
	ld.sis	hl, 0
	ld	iy, _portal_lod_state
	ld	(iy), l
	ld	(iy + 1), h
	push	de
	push	de
	call	_collide_with_room
	pop	hl
	pop	hl
	ld	a, 1
	jp	.LBB7_6
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_engine_init, .Lfunc_end7-_engine_init
                                        ; -- End function
	.section	.text._room_face_holds_portal,"ax",@progbits
	.type	_room_face_holds_portal,@function ; -- Begin function room_face_holds_portal
_room_face_holds_portal:                ; @room_face_holds_portal
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	iy, (ix + 6)
	ld	a, (ix + 9)
	cp	a, 2
	jr	nc, .LBB8_2
; %bb.1:
	ld	bc, (iy + 3)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (iy + 1)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	(ix - 3), hl
	ld	iy, (ix + 6)
	ld	bc, (iy + 7)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (iy + 5)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ld	iy, (ix - 3)
	ex	de, hl
	or	a, a
	sbc	hl, bc
	jr	.LBB8_6
	.local	.LBB8_2
.LBB8_2:
	ld	bc, (iy + 11)
	ld	l, b
	rlc	l
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (iy + 9)
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	rlc	l
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	(ix - 3), hl
	ld	iy, (ix + 6)
	cp	a, 4
	jr	nc, .LBB8_4
; %bb.3:
	ld	de, (iy + 3)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (iy + 1)
	jr	.LBB8_5
	.local	.LBB8_4
.LBB8_4:
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (iy + 5)
	.local	.LBB8_5
.LBB8_5:
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	ld	hl, (ix - 3)
	.local	.LBB8_6
.LBB8_6:
	ld	de, 896
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, -1
	ld	d, 0
	ld	e, a
	jp	p, .LBB8_8
; %bb.7:
	ld	e, d
	.local	.LBB8_8
.LBB8_8:
	ld	bc, 768
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB8_10
; %bb.9:
	ld	a, d
	.local	.LBB8_10
.LBB8_10:
	and	a, e
	ld	l, a
	ld	e, 1
	ld	a, l
	and	a, e
	ld	l, a
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_room_face_holds_portal, .Lfunc_end8-_room_face_holds_portal
                                        ; -- End function
	.section	.text._configure_portal_on_face,"ax",@progbits
	.type	_configure_portal_on_face,@function ; -- Begin function configure_portal_on_face
_configure_portal_on_face:              ; @configure_portal_on_face
; %bb.0:
	ld	hl, -18
	call	__frameset
	ld	c, (ix + 12)
	ld	a, (_room_count)
	ld	l, a
	ld	a, c
	cp	a, 6
	jp	nc, .LBB9_41
; %bb.1:
	ld	a, (ix + 9)
	cp	a, l
	jp	nc, .LBB9_41
; %bb.2:
	ld	e, (ix + 6)
	lea	hl, ix + 15
	ld	(ix - 12), hl
	ld	hl, _rooms
	ld	(ix - 3), hl
	or	a, a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	iyl, e
	push	hl
	pop	de
	ld	e, c
	ld	(ix - 9), de
	ld	l, a
	ld	bc, 13
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	ld	bc, 46
	lea	hl, iy + 0
	ld	iy, _portals
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	(iy + 42), a
	ld	hl, (ix - 3)
	ld	a, (hl)
	ld	l, (ix + 12)
	add	a, l
	ld	l, a
	ld	(iy + 43), l
	lea	de, iy + 27
	ld	bc, 9
	ld	hl, (ix - 9)
	call	__imulu
	push	hl
	pop	bc
	ld	(ix - 9), bc
	ld	hl, _face_normals
	add	hl, bc
	ld	bc, 9
	ldir
	lea	de, iy + 9
	ld	hl, _face_right_vectors
	ld	bc, (ix - 9)
	add	hl, bc
	ld	bc, 9
	ldir
	lea	de, iy + 18
	ld	hl, _face_up_vectors
	ld	bc, (ix - 9)
	add	hl, bc
	ld	bc, 9
	ldir
	ld	a, (ix + 12)
	ld	(iy + 45), 1
	cp	a, 2
	ld	(ix - 6), iy
	ld	hl, (ix - 3)
	jp	nc, .LBB9_14
; %bb.3:
	ld	iy, (ix - 3)
	ld	de, (iy + 1)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (ix - 6)
	ld	de, (iy + 36)
	push	de
	pop	hl
	add	hl, bc
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 3)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	bc, (ix + 15)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	iy
	jp	m, .LBB9_5
; %bb.4:
	push	de
	pop	iy
	.local	.LBB9_5
.LBB9_5:
	push	bc
	pop	hl
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB9_7
; %bb.6:
	lea	de, iy + 0
	.local	.LBB9_7
.LBB9_7:
	ld	(ix + 15), de
	ld	hl, (ix + 18)
	ld	(ix - 15), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 5)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (ix - 6)
	ld	bc, (iy + 39)
	ld	iy, (ix - 3)
	push	bc
	pop	hl
	add	hl, de
	ld	(ix - 9), hl
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ld	de, (ix - 15)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	call	pe, __setflag
	jp	m, .LBB9_9
; %bb.8:
	push	bc
	pop	de
	.local	.LBB9_9
.LBB9_9:
	ld	(ix - 18), de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	bc, 9
	jp	m, .LBB9_11
; %bb.10:
	ld	de, (ix - 18)
	.local	.LBB9_11
.LBB9_11:
	ld	(ix + 18), de
	ld	a, (ix + 12)
	or	a, a
	push	bc
	pop	de
	ld	bc, (ix - 6)
	jr	z, .LBB9_13
; %bb.12:
	ld	de, 11
	.local	.LBB9_13
.LBB9_13:
	add	iy, de
	ld	iy, (iy)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix + 21), hl
	push	bc
	pop	iy
	jp	.LBB9_37
	.local	.LBB9_14
.LBB9_14:
	cp	a, 4
	jp	nc, .LBB9_25
; %bb.15:
	ld	iy, (ix - 3)
	ld	de, (iy + 1)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (ix - 6)
	ld	de, (iy + 36)
	push	de
	pop	hl
	add	hl, bc
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 3)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	bc, (ix + 15)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	iy
	jp	m, .LBB9_17
; %bb.16:
	push	de
	pop	iy
	.local	.LBB9_17
.LBB9_17:
	push	bc
	pop	hl
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB9_19
; %bb.18:
	lea	de, iy + 0
	.local	.LBB9_19
.LBB9_19:
	ld	(ix + 15), de
	ld	hl, (ix + 21)
	ld	(ix - 15), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 9)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (ix - 6)
	ld	bc, (iy + 39)
	push	bc
	pop	hl
	add	hl, de
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	de, (iy + 11)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ld	de, (ix - 15)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	call	pe, __setflag
	jp	m, .LBB9_21
; %bb.20:
	push	bc
	pop	de
	.local	.LBB9_21
.LBB9_21:
	ld	(ix - 18), de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB9_23
; %bb.22:
	ld	de, (ix - 18)
	.local	.LBB9_23
.LBB9_23:
	ld	(ix + 21), de
	ld	a, (ix + 12)
	cp	a, 2
	ld	iy, (ix - 6)
	jp	z, .LBB9_35
; %bb.24:
	ld	bc, 7
	jp	.LBB9_36
	.local	.LBB9_25
.LBB9_25:
	ld	hl, (ix + 18)
	ld	(ix - 15), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 5)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (ix - 6)
	ld	bc, (iy + 36)
	push	bc
	pop	hl
	add	hl, de
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ld	de, (ix - 15)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	call	pe, __setflag
	jp	m, .LBB9_27
; %bb.26:
	push	bc
	pop	de
	.local	.LBB9_27
.LBB9_27:
	ld	bc, (ix - 9)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB9_29
; %bb.28:
	push	de
	pop	bc
	.local	.LBB9_29
.LBB9_29:
	ld	(ix + 18), bc
	ld	hl, (ix + 21)
	ld	(ix - 15), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 9)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	iy, (ix - 6)
	ld	bc, (iy + 39)
	push	bc
	pop	hl
	add	hl, de
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	de, (iy + 11)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ld	de, (ix - 15)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	call	pe, __setflag
	jp	m, .LBB9_31
; %bb.30:
	push	bc
	pop	de
	.local	.LBB9_31
.LBB9_31:
	ld	(ix - 18), de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	bc, 9
	jp	m, .LBB9_33
; %bb.32:
	ld	de, (ix - 18)
	.local	.LBB9_33
.LBB9_33:
	ld	(ix + 21), de
	ld	a, (ix + 12)
	cp	a, 4
	ld	iy, (ix - 6)
	jr	z, .LBB9_38
; %bb.34:
	ld	de, 3
	jr	.LBB9_39
	.local	.LBB9_35
.LBB9_35:
	ld	bc, 5
	.local	.LBB9_36
.LBB9_36:
	ld	hl, (ix - 3)
	add	hl, bc
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix + 18), hl
	.local	.LBB9_37
.LBB9_37:
	ld	bc, 9
	jr	.LBB9_40
	.local	.LBB9_38
.LBB9_38:
	ld	de, 1
	.local	.LBB9_39
.LBB9_39:
	ld	hl, (ix - 3)
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix + 15), hl
	.local	.LBB9_40
.LBB9_40:
	lea	de, iy + 0
	ld	hl, (ix - 12)
	ldir
	.local	.LBB9_41
.LBB9_41:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_configure_portal_on_face, .Lfunc_end9-_configure_portal_on_face
                                        ; -- End function
	.section	.text._rebuild_camera_basis,"ax",@progbits
	.type	_rebuild_camera_basis,@function ; -- Begin function rebuild_camera_basis
_rebuild_camera_basis:                  ; @rebuild_camera_basis
; %bb.0:
	ld	hl, -26
	call	__frameset
	ld	iy, (ix + 6)
	ld	e, (iy + 46)
	ld	(ix - 18), e
	ld	a, e
	rlc	a
	sbc	a, a
	ld	l, a
	ld	a, e
	add	a, l
	ld	e, a
	ld	a, e
	xor	a, l
	ld	l, a
	ld	(ix - 21), l
	ld	a, (iy + 45)
	ld	(ix - 15), a
	ld	l, a
	push	hl
	call	_angle_sine
	ld	(ix - 12), hl
	pop	hl
	ld	l, 64
	ld	a, (ix - 15)
	add	a, l
	ld	l, a
	push	hl
	call	_angle_sine
	ld	(ix - 15), hl
	pop	hl
	ld	bc, 0
	ld	c, (ix - 21)                    ; 1-byte Folded Reload
	push	bc
	pop	hl
	add	hl, hl
	ex	de, hl
	ld	hl, _quarter_sine
	add	hl, de
	ld	iy, (hl)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ld	hl, 64
	or	a, a
	sbc	hl, bc
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, _quarter_sine
	add	hl, bc
	ld	bc, (hl)
	push	de
	pop	hl
	call	__ineg
	ld	a, (ix - 18)                    ; 1-byte Folded Reload
	cp	a, 0
	call	pe, __setflag
	jp	m, .LBB10_2
; %bb.1:
	ex	de, hl
	.local	.LBB10_2
.LBB10_2:
	ld	(ix - 18), hl
	ld	a, b
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 21), hl
	ld	hl, (ix - 12)
	call	__ineg
	ld	de, (ix + 6)
	push	de
	pop	iy
	ld	(iy + 18), hl
	ld	de, (ix - 15)
	ld	(iy + 21), de
	or	a, a
	sbc	hl, hl
	ld	(iy + 24), hl
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 26), hl
	rlc	a
	sbc	a, a
	ld	iyl, a
	push	de
	pop	bc
	ld	(ix - 9), bc
	ld	a, (ix - 7)
	rlc	a
	sbc	a, a
	ld	(ix - 22), a
	ld	e, iyl
	ld	d, iyl
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	iy, (ix + 6)
	ld	(iy + 36), bc
	ld	bc, (ix - 12)
	ld	(ix - 6), bc
	ld	a, (ix - 4)
	rlc	a
	sbc	a, a
	ld	(ix - 23), a
	ld	hl, (ix - 26)
	ld	e, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	(iy + 39), bc
	ld	hl, (ix - 18)
	ld	(iy + 42), hl
	ld	(ix - 3), hl
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	e, d
	ld	bc, (ix - 15)
	ld	a, (ix - 22)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	bc
	pop	hl
	call	__ineg
	ld	(iy + 27), hl
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	hl, (ix - 18)
	ld	e, d
	ld	bc, (ix - 12)
	ld	a, (ix - 23)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	bc
	pop	hl
	call	__ineg
	ld	(iy + 30), hl
	ld	hl, (ix - 21)
	ld	(iy + 33), hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_rebuild_camera_basis, .Lfunc_end10-_rebuild_camera_basis
                                        ; -- End function
	.section	.text._collide_with_room,"ax",@progbits
	.type	_collide_with_room,@function    ; -- Begin function collide_with_room
_collide_with_room:                     ; @collide_with_room
; %bb.0:
	ld	hl, -19
	call	__frameset
	or	a, a
	sbc	hl, hl
	ld	iy, (ix + 6)
	ld	a, (iy + 47)
	ld	l, a
	ld	bc, 13
	call	__imulu
	ex	de, hl
	ld	iy, _rooms
	add	iy, de
	ld	de, (iy + 1)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 64
	add	hl, bc
	ld	(ix - 12), hl
	ld	de, (iy + 5)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	add	hl, bc
	ld	(ix - 6), hl
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, -64
	add	hl, de
	ld	(ix - 19), hl
	ld	(ix - 3), iy
	ld	de, (iy + 9)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (ix + 6)
	ld	a, (iy + 50)
	ld	(ix - 16), a                    ; 1-byte Folded Spill
	or	a, a
	jr	z, .LBB11_2
; %bb.1:
	ld	hl, 64
	jr	.LBB11_3
	.local	.LBB11_2
.LBB11_2:
	ld	hl, 384
	.local	.LBB11_3
.LBB11_3:
	ld	de, (ix - 6)
	ld	(ix - 15), de
	add	hl, bc
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	bc, (iy + 11)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	de, -64
	add	hl, de
	ld	(ix - 6), hl
	ld	hl, (ix + 9)
	ld	bc, (hl)
	push	bc
	pop	hl
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iy, (ix + 6)
	jp	m, .LBB11_5
; %bb.4:
	ld	iy, (ix - 3)
	ld	de, (iy + 3)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	iyl, e
	ld	iyh, d
	ld	de, -64
	add	iy, de
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	lea	de, iy + 0
	ld	iy, (ix + 6)
	jp	p, .LBB11_6
	.local	.LBB11_5
.LBB11_5:
	ld	hl, (ix + 9)
	ld	(hl), de
	or	a, a
	sbc	hl, hl
	ld	(iy + 9), hl
	.local	.LBB11_6
.LBB11_6:
	ld	iy, (ix + 9)
	ld	bc, (iy + 3)
	push	bc
	pop	hl
	ld	de, (ix - 15)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB11_8
; %bb.7:
	ld	de, (ix - 19)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB11_9
	.local	.LBB11_8
.LBB11_8:
	ld	(iy + 3), de
	or	a, a
	sbc	hl, hl
	ld	iy, (ix + 6)
	ld	(iy + 12), hl
	.local	.LBB11_9
.LBB11_9:
	ld	iy, (ix + 9)
	ld	de, (iy + 6)
	ld	bc, (ix - 9)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB11_11
; %bb.10:
	xor	a, a
	ld	hl, (ix - 6)
	ld	iy, (ix + 6)
	jr	.LBB11_17
	.local	.LBB11_11
.LBB11_11:
	ld	(iy + 6), bc
	ld	iy, (ix + 6)
	ld	hl, (iy + 15)
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB11_13
; %bb.12:
	or	a, a
	sbc	hl, hl
	ld	(iy + 15), hl
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	bc, (iy + 6)
	push	hl
	pop	iy
	.local	.LBB11_13
.LBB11_13:
	ld	a, (ix - 16)                    ; 1-byte Folded Reload
	or	a, a
	jr	z, .LBB11_15
; %bb.14:
	ld	a, 0
	jr	.LBB11_16
	.local	.LBB11_15
.LBB11_15:
	ld	a, 1
	.local	.LBB11_16
.LBB11_16:
	ld	hl, (ix - 6)
	push	bc
	pop	de
	.local	.LBB11_17
.LBB11_17:
	ld	(iy + 49), a
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB11_20
; %bb.18:
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	(iy + 6), bc
	push	hl
	pop	iy
	ld	hl, (iy + 15)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB11_20
; %bb.19:
	or	a, a
	sbc	hl, hl
	ld	(iy + 15), hl
	.local	.LBB11_20
.LBB11_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_collide_with_room, .Lfunc_end11-_collide_with_room
                                        ; -- End function
	.section	.text._angle_sine,"ax",@progbits
	.type	_angle_sine,@function           ; -- Begin function angle_sine
_angle_sine:                            ; @angle_sine
; %bb.0:
	call	__frameset0
	ld	e, (ix + 6)
	ld	c, 63
	ld	hl, _quarter_sine
	ld	a, e
	and	a, c
	ld	c, a
	ld	a, e
	cp	a, 64
	jr	c, .LBB12_3
; %bb.1:
	ld	d, 64
	ld	b, 6
	ld	a, e
	call	__bshru
	cp	a, 1
	jr	nz, .LBB12_4
; %bb.2:
	ld	a, d
	sub	a, c
	ld	c, a
	.local	.LBB12_3
.LBB12_3:
	sla	c
	ld	de, 0
	ld	e, c
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	jr	.LBB12_7
	.local	.LBB12_4
.LBB12_4:
	cp	a, 2
	jr	z, .LBB12_6
; %bb.5:
	ld	a, d
	sub	a, c
	ld	c, a
	.local	.LBB12_6
.LBB12_6:
	sla	c
	ld	de, 0
	ld	e, c
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__ineg
	.local	.LBB12_7
.LBB12_7:
	pop	ix
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_angle_sine, .Lfunc_end12-_angle_sine
                                        ; -- End function
	.section	.text._engine_graphics_init,"ax",@progbits
	.globl	_engine_graphics_init           ; -- Begin function engine_graphics_init
	.type	_engine_graphics_init,@function
_engine_graphics_init:                  ; @engine_graphics_init
; %bb.0:
	ld	hl, -22
	call	__frameset
	ld	hl, _projection_scale_table+16
	ld	(ix - 15), hl
	ld	hl, _far_projection_scale_table+512
	ld	(ix - 12), hl
	ld	hl, _edge_reciprocal_table+2
	ld	(ix - 9), hl
	ld	hl, 1048584
	ld	(ix - 6), hl
	ld	hl, -1900000
	ld	(ix - 3), hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_configure_render_mode
	ld	bc, 16
	pop	hl
	ld	de, 0
	.local	.LBB13_1
.LBB13_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB13_3
; %bb.2:                                ;   in Loop: Header=BB13_1 Depth=1
	ld	hl, _projection_scale_table
	add	hl, de
	ld.sis	bc, -1
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ex	de, hl
	ld	de, 2
	add	hl, de
	ex	de, hl
	ld	hl, 16
	push	hl
	pop	bc
	jr	.LBB13_1
	.local	.LBB13_3
.LBB13_3:
	ld	de, 8192
	ld	iy, 32
	lea	bc, iy + 0
	.local	.LBB13_4
.LBB13_4:                               ; %.preheader7
                                        ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB13_6
; %bb.5:                                ;   in Loop: Header=BB13_4 Depth=1
	ld	hl, 688128
	call	__idivu
	ex	de, hl
	push	bc
	pop	hl
	ld	iy, (ix - 15)
	ld	(iy), e
	ld	(iy + 1), d
	ld	de, 8192
	ld	bc, 4
	add	hl, bc
	lea	iy, iy + 2
	ld	(ix - 15), iy
	push	hl
	pop	bc
	jr	.LBB13_4
	.local	.LBB13_6
.LBB13_6:
	ld	de, 65536
	ld	iy, 8192
	lea	bc, iy + 0
	.local	.LBB13_7
.LBB13_7:                               ; %.preheader6
                                        ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB13_9
; %bb.8:                                ;   in Loop: Header=BB13_7 Depth=1
	ld	hl, 688128
	call	__idivu
	ex	de, hl
	push	bc
	pop	hl
	ld	iy, (ix - 12)
	ld	(iy), e
	ld	(iy + 1), d
	ld	de, 65536
	ld	bc, 32
	add	hl, bc
	lea	iy, iy + 2
	ld	(ix - 12), iy
	push	hl
	pop	bc
	jr	.LBB13_7
	.local	.LBB13_9
.LBB13_9:
	ld.sis	hl, 0
	ld	iy, _edge_reciprocal_table
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, 32768
	ld	iy, 16
	lea	bc, iy + 0
	.local	.LBB13_10
.LBB13_10:                              ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB13_14
; %bb.11:                               ;   in Loop: Header=BB13_10 Depth=1
	ld	hl, (ix - 6)
	ld	(ix - 12), bc
	call	__idivu
	push	hl
	pop	de
	ld	bc, 65535
	or	a, a
	sbc	hl, bc
	jr	c, .LBB13_13
; %bb.12:                               ;   in Loop: Header=BB13_10 Depth=1
	ld	de, 65535
	.local	.LBB13_13
.LBB13_13:                              ;   in Loop: Header=BB13_10 Depth=1
	ld	iy, (ix - 9)
	ld	(iy), e
	ld	(iy + 1), d
	ld	de, 16
	ld	hl, (ix - 12)
	add	hl, de
	push	hl
	pop	bc
	ld	de, 8
	ld	hl, (ix - 6)
	add	hl, de
	ld	(ix - 6), hl
	lea	iy, iy + 2
	ld	(ix - 9), iy
	ld	de, 32768
	jr	.LBB13_10
	.local	.LBB13_14
.LBB13_14:
	ld	de, 13
	ld	bc, 0
	.local	.LBB13_15
.LBB13_15:                              ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB13_17 Depth 2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB13_20
; %bb.16:                               ;   in Loop: Header=BB13_15 Depth=1
	push	bc
	pop	hl
	ld	(ix - 9), bc
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, _base_palette_rgb
	add	iy, de
	ld	a, (iy)
	ld	(ix - 12), a
	ld	b, c
	call	__bshru
	ld	e, a
	ld	d, 0
	ld	l, e
	ld	h, d
	ld	c, 10
	call	__sshl
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	a, (iy + 1)
	ld	(ix - 15), a
	call	__bshru
	ld	e, a
	ld	(ix - 6), de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, (ix - 17)
	ld	d, (ix - 16)
	add.sis	hl, de
	ld	a, (iy + 2)
	ld	(ix - 19), a
	call	__bshru
	ld	c, a
	ld	de, (ix - 6)
	ld	b, d
	add.sis	hl, bc
	ld	iy, (ix - 9)
	add	iy, iy
	lea	bc, iy + 0
	ld	iy, -1900032
	add	iy, bc
	ld	(iy), l
	ld	(iy + 1), h
	ld	e, (ix - 12)                    ; 1-byte Folded Reload
	push	de
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	e, (ix - 15)                    ; 1-byte Folded Reload
	ld	(ix - 6), de
	ld	h, 0
	ld	(ix - 12), l
	ld	(ix - 11), h
                                        ; kill: def $h killed $h killed $hl def $hl
	ld	l, (ix - 19)                    ; 1-byte Folded Reload
	ld	(ix - 19), l
	ld	(ix - 18), h
	ld	hl, (ix - 3)
	ld	(ix - 15), hl
	or	a, a
	sbc	hl, hl
	.local	.LBB13_17
.LBB13_17:                              ;   Parent Loop BB13_15 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	hl
	pop	de
	ld	bc, 4
	or	a, a
	sbc	hl, bc
	jp	z, .LBB13_19
; %bb.18:                               ;   in Loop: Header=BB13_17 Depth=2
	ld	hl, _shade_numerator
	ld	(ix - 22), de
	add	hl, de
	ld	a, (hl)
	ld	e, (ix - 12)
	ld	d, (ix - 11)
	ld	e, a
	ld	l, (ix - 17)
	ld	h, (ix - 16)
	ld	c, e
	ld	b, d
	call	__smulu
	ld.sis	bc, 31744
	call	__sand
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	l, e
	ld	h, d
	ld	bc, (ix - 6)
                                        ; kill: def $bc killed $bc killed $ubc
	call	__smulu
	ld	c, 2
	call	__sshru
	ld.sis	bc, 992
	call	__sand
	ld	c, iyl
	ld	b, iyh
	add.sis	hl, bc
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	(ix - 12), e
	ld	(ix - 11), d
	ex.sis	de, hl
	ld	c, (ix - 19)
	ld	b, (ix - 18)
	call	__smulu
	ld	c, 7
	call	__sshru
	ld.sis	bc, 31
	call	__sand
	ld	c, l
	ld	b, h
	add.sis	iy, bc
	ld	e, iyl
	ld	d, iyh
	ld	hl, (ix - 22)
	ld	iy, (ix - 15)
	ld	(iy), e
	ld	(iy + 1), d
	inc	hl
	lea	iy, iy + 2
	ld	(ix - 15), iy
	jp	.LBB13_17
	.local	.LBB13_19
.LBB13_19:                              ;   in Loop: Header=BB13_15 Depth=1
	ld	bc, (ix - 9)
	inc	bc
	ld	iy, (ix - 3)
	lea	iy, iy + 8
	ld	(ix - 3), iy
	ld	de, 13
	jp	.LBB13_15
	.local	.LBB13_20
.LBB13_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_engine_graphics_init, .Lfunc_end13-_engine_graphics_init
                                        ; -- End function
	.section	.text._configure_render_mode,"ax",@progbits
	.type	_configure_render_mode,@function ; -- Begin function configure_render_mode
_configure_render_mode:                 ; @configure_render_mode
; %bb.0:
	ld	hl, -5
	call	__frameset
	ld	e, (ix + 6)
	ld	a, e
	or	a, a
	jr	nz, .LBB14_2
; %bb.1:
	ld	l, 0
	jr	.LBB14_3
	.local	.LBB14_2
.LBB14_2:
	ld	l, 1
	.local	.LBB14_3
.LBB14_3:
	ld	a, (_active_render_width)
	ld	h, a
	ld	a, (_active_render_shift)
	ld	c, a
	ld	a, h
	or	a, a
	jr	z, .LBB14_6
; %bb.4:
	ld	a, c
	cp	a, l
	jr	nz, .LBB14_6
	.local	.LBB14_5
.LBB14_5:                               ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB14_6
.LBB14_6:
	ld	a, e
	or	a, a
	jr	nz, .LBB14_8
; %bb.7:
	ld	c, 0
	jr	.LBB14_9
	.local	.LBB14_8
.LBB14_8:
	ld	c, -1
	.local	.LBB14_9
.LBB14_9:
	ld	a, l
	ld	(_active_render_shift), a
	bit	0, c
	jr	nz, .LBB14_11
; %bb.10:
	ld	e, 64
	jr	.LBB14_12
	.local	.LBB14_11
.LBB14_11:
	ld	e, 32
	.local	.LBB14_12
.LBB14_12:
	ld	a, e
	ld	(_active_render_width), a
	bit	0, c
	jr	nz, .LBB14_14
; %bb.13:
	ld	l, 48
	jr	.LBB14_15
	.local	.LBB14_14
.LBB14_14:
	ld	l, 24
	.local	.LBB14_15
.LBB14_15:
	ld	a, l
	ld	(_active_render_height), a
	bit	0, c
	jr	nz, .LBB14_17
; %bb.16:
	ld	a, 4
	jr	.LBB14_18
	.local	.LBB14_17
.LBB14_17:
	ld	a, 2
	.local	.LBB14_18
.LBB14_18:
	ld	(_active_horizon_near_limit), a
	bit	0, c
	jr	nz, .LBB14_20
; %bb.19:
	ld	a, 12
	jr	.LBB14_21
	.local	.LBB14_20
.LBB14_20:
	ld	a, 6
	.local	.LBB14_21
.LBB14_21:
	ld	bc, _low_row_offsets
	ld	(ix - 3), bc
	ld.sis	bc, 0
	ld	(ix - 5), c
	ld	(ix - 4), b
	ld	(_active_horizon_far_limit), a
	ld	a, e
	ld	(_low_frame), a
	ld	a, l
	ld	(_low_frame+1), a
	ld	d, b
	ld	bc, 0
	ld	c, l
	.local	.LBB14_22
.LBB14_22:                              ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB14_5
; %bb.23:                               ;   in Loop: Header=BB14_22 Depth=1
	ld	iy, (ix - 3)
	ld	l, (ix - 5)
	ld	h, (ix - 4)
	ld	(iy), l
	ld	(iy + 1), h
	add.sis	hl, de
	ld	(ix - 5), l
	ld	(ix - 4), h
	lea	iy, iy + 2
	ld	(ix - 3), iy
	dec	bc
	jr	.LBB14_22
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_configure_render_mode, .Lfunc_end14-_configure_render_mode
                                        ; -- End function
	.section	.text._engine_update,"ax",@progbits
	.globl	_engine_update                  ; -- Begin function engine_update
	.type	_engine_update,@function
_engine_update:                         ; @engine_update
; %bb.0:
	ld	hl, -237
	call	__frameset
	ld	iy, (ix + 6)
	ld	a, (ix + 18)
	ld	bc, 52
	lea	de, ix - 67
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), de
	pop	ix
	lea	hl, iy + 0
	ldir
	ld	de, (ix + 24)
	ld	c, (iy + 48)
	ld	(iy + 48), a
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB15_2
; %bb.1:
	ld	l, 0
	ld	a, l
	jp	.LBB15_118
	.local	.LBB15_2
.LBB15_2:
	ld	a, c
	ld	l, 0
	ld	bc, -179
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	l, (ix + 12)
	ld	bc, -148
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	(iy + 1), h
	ex	de, hl
	ld	de, (ix + 21)
	ld	c, 3
	call	__ishru
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jr	c, .LBB15_4
; %bb.3:
	push	de
	pop	bc
	.local	.LBB15_4
.LBB15_4:
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	ld	l, d
	xor	a, l
	ld	d, a
	ld	e, (ix + 15)
	ld	c, 1
	ld	l, (ix + 12)
	ld	a, l
	or	a, a
	jr	z, .LBB15_8
; %bb.5:
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), d                     ; 1-byte Folded Spill
	ld	bc, 80
	or	a, a
	sbc	hl, hl
	ld	d, l
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	hl, (iy + 0)
	ld	e, d
	ld	iyl, b
	ld	a, iyl
	call	__lmulu
	push	hl
	pop	iy
	ld	hl, (ix + 24)
	call	__ishru_1
	push	hl
	pop	bc
	lea	hl, iy + 0
	ld	a, d
	call	__ladd
	ld	bc, (ix + 24)
	call	__ldivu
	ld	c, 1
	ex	de, hl
	ld	iy, (ix + 6)
	ld	b, (iy + 45)
	ld	a, e
	or	a, a
	ld	l, (ix + 12)
	ld	h, c
	jr	z, .LBB15_7
; %bb.6:
	ld	h, e
	.local	.LBB15_7
.LBB15_7:
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), l
	ld	(ix - 19), h
	pop	ix
	mlt	hl
	ld	a, l
	add	a, b
	ld	l, a
	ld	(iy + 45), l
	ld	e, (ix + 15)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB15_8
.LBB15_8:
	ld	l, (ix + 18)
	ld	a, d
	and	a, l
	ld	d, a
	ld	a, e
	or	a, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	(iy + 0), d                     ; 1-byte Folded Spill
	jp	z, .LBB15_16
; %bb.9:
	ld	bc, 72
	ld	a, e
	rlc	a
	sbc.sis	hl, hl
	ld	l, e
	ld	de, -154
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	ld	d, l
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	hl, (iy + 0)
	ld	e, d
	ld	iyl, b
	ld	a, iyl
	call	__lmulu
	push	hl
	pop	iy
	ld	hl, (ix + 24)
	call	__ishru_1
	push	hl
	pop	bc
	lea	hl, iy + 0
	ld	a, d
	call	__ladd
	ld	bc, (ix + 24)
	call	__ldivu
	push	hl
	pop	de
	ld.sis	bc, 255
	call	__sand
	ld	c, l
	ld	b, h
	ld	iy, (ix + 6)
	ld	a, (iy + 46)
	ld	l, a
	rlc	l
	sbc.sis	hl, hl
	ld	l, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	a, e
	or	a, a
	jr	nz, .LBB15_11
; %bb.10:
	ld.sis	bc, 1
	.local	.LBB15_11
.LBB15_11:
	ld	l, c
	ld	h, b
	ld	de, -154
	lea	iy, ix + 0
	add	iy, de
	ld	c, (iy + 0)
	ld	b, (iy + 1)
	call	__smulu
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	bc, -151
	lea	hl, ix + 0
	add	hl, bc
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	add.sis	iy, de
	ld.sis	bc, -63
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	ld	bc, -142
	lea	hl, ix + 0
	push	af
	add	hl, bc
	pop	af
	ld	d, (hl)                         ; 1-byte Folded Reload
	jp	p, .LBB15_13
; %bb.12:
	ld.sis	iy, -64
	.local	.LBB15_13
.LBB15_13:
	ld.sis	bc, 64
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB15_15
; %bb.14:
	ld.sis	iy, 64
	.local	.LBB15_15
.LBB15_15:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 23)
	ld	b, (ix - 22)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
	ld	c, 1
	jr	nz, .LBB15_17
	.local	.LBB15_16
.LBB15_16:
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	a, l
	or	a, a
	ld	iy, (ix + 6)
	jr	nz, .LBB15_18
	jr	.LBB15_19
	.local	.LBB15_17
.LBB15_17:
	ld	a, iyl
	ld	iy, (ix + 6)
	ld	(iy + 46), a
	.local	.LBB15_18
.LBB15_18:
	push	iy
	call	_rebuild_camera_basis
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	c, 1
	ld	iy, (ix + 6)
	pop	hl
	.local	.LBB15_19
.LBB15_19:
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 66), hl
	pop	ix
	bit	3, d
	jr	z, .LBB15_24
; %bb.20:
	ld	a, (iy + 50)
	or	a, a
	jr	z, .LBB15_22
; %bb.21:
	ld	a, 0
	jr	.LBB15_23
	.local	.LBB15_22
.LBB15_22:
	ld	a, 1
	.local	.LBB15_23
.LBB15_23:
	ld	(iy + 50), a
	or	a, a
	sbc	hl, hl
	ld	(iy + 9), hl
	ld	(iy + 12), hl
	ld	(iy + 15), hl
	ld	(iy + 49), h
	.local	.LBB15_24
.LBB15_24:
	bit	5, d
	jr	z, .LBB15_26
; %bb.25:
	ld	a, (iy + 51)
	xor	a, c
	ld	l, a
	ld	(iy + 51), l
	.local	.LBB15_26
.LBB15_26:
	bit	1, d
	ld	hl, 0
	jr	z, .LBB15_28
; %bb.27:
	or	a, a
	sbc	hl, hl
	push	hl
	push	iy
	call	_place_portal
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	iy, (ix + 6)
	pop	hl
	pop	hl
	ld	hl, 1
	.local	.LBB15_28
.LBB15_28:
	bit	2, d
	jr	z, .LBB15_30
; %bb.29:
	ld	hl, 1
	push	hl
	push	iy
	call	_place_portal
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	iy, (ix + 6)
	pop	hl
	pop	hl
	ld	hl, 1
	.local	.LBB15_30
.LBB15_30:
	push	ix
	lea	ix, ix - 128
	ld	(ix - 26), hl
	pop	ix
	ld	c, (ix + 9)
	xor	a, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 74), a
	pop	ix
	ld	l, (iy + 50)
	ld	e, 1
	ld	a, d
	and	a, e
	ld	e, a
	bit	0, e
	jr	z, .LBB15_32
; %bb.31:
	ld	a, l
	or	a, a
	jp	z, .LBB15_35
	.local	.LBB15_32
.LBB15_32:
	ld	a, l
	or	a, a
	jp	z, .LBB15_37
; %bb.33:
	ld	de, (iy + 36)
	ld	hl, (iy + 39)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), hl
	pop	ix
	ld	hl, (iy + 42)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 32
	ld	(iy + 0), hl
	ld	a, c
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	bc, 640
	call	__imulu
	push	hl
	pop	iy
	ld	bc, -136
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	ld	bc, -134
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)
	rlc	a
	sbc	a, a
	ld	c, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), iy
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 3)
	pop	ix
	rlc	a
	sbc	a, a
	ex	de, hl
	ld	e, c
	lea	bc, iy + 0
	ld	d, a
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 35), bc
	pop	ix
	call	__lshl
	call	__lshrs
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), bc
	pop	ix
	ld	bc, -148
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a                         ; 1-byte Folded Spill
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	ld	a, (ix - 128)
	rlc	a
	sbc	a, a
	ld	e, a
	lea	bc, iy + 0
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 38), bc
	pop	ix
	call	__lshl
	call	__lshrs
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), bc
	pop	ix
	ld	bc, -157
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a                         ; 1-byte Folded Spill
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 32)
	pop	ix
	ld	(ix - 127), hl
	ld	a, (ix - 125)
	rlc	a
	sbc	a, a
	ld	e, a
	lea	bc, iy + 0
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	iy, (ix + 6)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 35)
	pop	ix
	ld	(iy + 9), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 38)
	pop	ix
	ld	(iy + 12), hl
	ld	l, 1
	ld	a, (ix + 18)
	and	a, l
	ld	l, a
	bit	0, l
	jp	z, .LBB15_38
; %bb.34:
	ld	de, 640
	push	bc
	pop	hl
	add	hl, de
	jp	.LBB15_39
	.local	.LBB15_35
.LBB15_35:
	ld	a, (iy + 49)
	or	a, a
	jr	z, .LBB15_37
; %bb.36:
	ld	hl, 1792
	ld	(iy + 15), hl
	ld	(iy + 49), l
	.local	.LBB15_37
.LBB15_37:
	ld	a, 1
	ld	de, -163
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a
	ld	de, (iy + 21)
	ld	hl, (iy + 18)
	call	__ineg
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	(iy + 0), hl
	ld	a, c
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	bc, 640
	call	__imulu
	ld	(ix - 124), de
	push	de
	pop	iy
	ld	a, (ix - 122)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	(ix - 121), hl
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 29), bc
	pop	ix
	ld	a, (ix - 119)
	rlc	a
	sbc	a, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 32), a
	pop	ix
	lea	hl, iy + 0
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	bc
	pop	de
	call	__lshl
	call	__lshrs
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	(iy + 0), bc
	ld	bc, -148
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	iy, (ix + 6)
	ld	(iy + 9), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	ld	(ix - 118), hl
	ld	a, (ix - 116)
	rlc	a
	sbc	a, a
	ld	e, a
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 29)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 32)                    ; 1-byte Folded Reload
	pop	ix
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	bc
	pop	de
	call	__lshl
	call	__lshrs
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), bc
	pop	ix
	ld	bc, -157
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a                         ; 1-byte Folded Spill
	ld	(iy + 12), de
	or	a, a
	sbc	hl, hl
	ld	d, l
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	e, d
	ld	bc, 2560
	ld	iyl, c
	ld	a, iyl
	call	__lmulu
	ld	iy, (ix + 24)
	lea	bc, iy + 0
	ld	iy, (ix + 6)
	ld	a, d
	call	__ldivu
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 14)
	pop	ix
	ex	de, hl
	ld	hl, (iy + 15)
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 20)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 32), hl
	pop	ix
	ld	(iy + 15), hl
	jr	.LBB15_43
	.local	.LBB15_38
.LBB15_38:
	push	bc
	pop	hl
	.local	.LBB15_39
.LBB15_39:
	ld	iy, (ix + 6)
	ld	(iy + 15), hl
	bit	4, (ix + 18)
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 14)
	pop	ix
	jr	nz, .LBB15_41
; %bb.40:
	xor	a, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 35), a                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 32), hl
	pop	ix
	jr	.LBB15_42
	.local	.LBB15_41
.LBB15_41:
	ld	de, -640
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 32), hl
	pop	ix
	ld	(iy + 15), hl
	xor	a, a
	ld	de, -163
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a                         ; 1-byte Folded Spill
	.local	.LBB15_42
.LBB15_42:
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 20)                    ; 1-byte Folded Reload
	pop	ix
	.local	.LBB15_43
.LBB15_43:
	ld	hl, 8388607
	push	ix
	lea	ix, ix - 128
	ld	(ix - 70), hl
	pop	ix
	ld	a, -128
	push	ix
	lea	ix, ix - 128
	ld	(ix - 67), a
	pop	ix
	lea	hl, ix - 15
	push	ix
	lea	ix, ix - 128
	ld	(ix - 47), hl
	pop	ix
	lea	hl, ix - 76
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), hl
	pop	ix
	ld	hl, (iy)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), hl
	pop	ix
	lea	hl, iy + 9
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 73
	ld	(iy + 0), hl
	or	a, a
	sbc	hl, hl
	ld	d, l
	push	bc
	pop	hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	bc, (iy + 0)
	ld	a, d
	call	__lmulu
	ld	bc, (ix + 24)
	call	__ldivs
	push	hl
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 55
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 20)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 54), bc
	pop	ix
	add	iy, bc
	ld	bc, -169
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	(ix - 76), iy
	ld	iy, (ix + 6)
	ld	iy, (iy + 3)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 29)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 11)
	pop	ix
	call	__lmulu
	ld	bc, (ix + 24)
	call	__ldivs
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 59), e                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 44), iy
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 58), bc
	pop	ix
	add	iy, bc
	ld	bc, -157
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	(ix - 73), iy
	ld	iy, (ix + 6)
	ld	iy, (iy + 6)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 32)
	pop	ix
	ld	(ix - 115), hl
	ld	a, (ix - 113)
	rlc	a
	sbc	a, a
	ld	e, a
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 11)
	pop	ix
	ld	a, d
	call	__lmulu
	ld	bc, (ix + 24)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 48), d                    ; 1-byte Folded Spill
	pop	ix
	call	__ldivs
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 63), e                    ; 1-byte Folded Spill
	pop	ix
	ld	de, -160
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -190
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	add	iy, bc
	ld	de, -166
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	(ix - 70), iy
	ld	de, 92
	ld	bc, 0
	ld	iyl, b
                                        ; kill: def $iyl killed $iyl killed $uiy def $uiy
	.local	.LBB15_44
.LBB15_44:                              ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB15_114
; %bb.45:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -151
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	hl, _portals
	push	hl
	pop	iy
	ld	de, -139
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	add	iy, bc
	ld	a, (iy + 45)
	or	a, a
	jp	z, .LBB15_79
; %bb.46:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	a, (iy + 44)
	ld	de, 0
	ex	de, hl
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 77), hl
	pop	ix
	ld	bc, 46
	call	__imulu
	push	hl
	pop	bc
	lea	de, iy + 0
	ld	iy, _portals
	add	iy, bc
	ld	a, (iy + 45)
	or	a, a
	jp	z, .LBB15_79
; %bb.47:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	iy, (ix + 6)
	ld	l, (iy + 47)
	push	de
	pop	iy
	ld	a, (iy + 42)
	cp	a, l
	jp	nz, .LBB15_79
; %bb.48:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	hl, (iy)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 92), hl
	pop	ix
	ld	bc, (iy + 3)
	ld	de, (iy + 6)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 32)
	pop	ix
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 86), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 95), bc
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 38)
	pop	ix
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld	de, (iy + 27)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB15_51
; %bb.49:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	de, (iy + 30)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB15_52
; %bb.50:                               ;   in Loop: Header=BB15_44 Depth=1
	lea	hl, iy + 0
	ld	iy, _portals
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 11)
	pop	ix
	add	iy, bc
	ld	de, (iy + 33)
	push	hl
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 86)
	pop	ix
	jr	.LBB15_54
	.local	.LBB15_51
.LBB15_51:                              ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 41)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 92)
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 20)
	jr	.LBB15_53
	.local	.LBB15_52
.LBB15_52:                              ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 44)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 95)
	.local	.LBB15_53
.LBB15_53:                              ;   in Loop: Header=BB15_44 Depth=1
	pop	ix
	or	a, a
	sbc	hl, bc
	.local	.LBB15_54
.LBB15_54:                              ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	(ix - 83), hl
	pop	ix
	ex	de, hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	a, -1
	jp	p, .LBB15_56
; %bb.55:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	a, 0
	.local	.LBB15_56
.LBB15_56:                              ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 83)
	pop	ix
	call	__ineg
	bit	0, a
	jr	nz, .LBB15_58
; %bb.57:                               ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	(ix - 83), hl
	pop	ix
	.local	.LBB15_58
.LBB15_58:                              ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	call	__ineg
	bit	0, a
	jr	nz, .LBB15_60
; %bb.59:                               ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	.local	.LBB15_60
.LBB15_60:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -163
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	bit	0, (hl)                         ; 1-byte Folded Reload
	ld	hl, 64
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 89), iy
	pop	ix
	jr	z, .LBB15_66
; %bb.61:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	hl, (iy + 33)
	ld	bc, 129
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	hl, 384
	jp	p, .LBB15_63
; %bb.62:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	hl, 64
	.local	.LBB15_63
.LBB15_63:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -226
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -205
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	bc, 46
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _portals
	add	iy, bc
	ld	hl, (iy + 33)
	ld	de, 129
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, 384
	jp	p, .LBB15_65
; %bb.64:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	hl, 64
	.local	.LBB15_65
.LBB15_65:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -226
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 89)
	pop	ix
	.local	.LBB15_66
.LBB15_66:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -229
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -211
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 77), hl
	pop	ix
	lea	hl, iy + 0
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB15_79
; %bb.67:                               ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 77)
	pop	ix
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB15_79
; %bb.68:                               ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 83)
	pop	ix
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB15_70
; %bb.69:                               ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	or	a, a
	sbc	hl, bc
	jp	z, .LBB15_79
	.local	.LBB15_70
.LBB15_70:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -226
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	ld	de, -190
	lea	hl, ix + 0
	add	hl, de
	ld	bc, (hl)
	dec	de
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	l, 8
	call	__lshl
	call	__lshrs
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 83), a                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 58)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 59)                    ; 1-byte Folded Reload
	pop	ix
	call	__lshl
	call	__lshrs
	push	ix
	lea	ix, ix - 128
	ld	(ix - 104), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 105), a                   ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 54)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 55)                    ; 1-byte Folded Reload
	pop	ix
	call	__lshl
	call	__lshrs
	push	ix
	lea	ix, ix - 128
	ld	(ix - 108), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 109), a                   ; 1-byte Folded Spill
	pop	ix
	lea	bc, iy + 0
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 48)                    ; 1-byte Folded Reload
	pop	ix
	call	__lshl
	lea	hl, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 77
	ld	de, (iy + 0)
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	push	bc
	pop	hl
	ld	e, a
	lea	bc, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 48
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__ldivu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshl
	call	__lshrs
	push	bc
	pop	iy
	ld	d, a
	lea	hl, iy + 0
	ld	e, d
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 108)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 109)                   ; 1-byte Folded Reload
	pop	ix
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 77), bc
	pop	ix
	lea	hl, iy + 0
	ld	e, d
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 104)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 105)                   ; 1-byte Folded Reload
	pop	ix
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 104), bc
	pop	ix
	lea	hl, iy + 0
	ld	e, d
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 80
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 83
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	push	bc
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 20)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 92)
	pop	ix
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 77)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 44)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 95)
	pop	ix
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 104)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 86)
	pop	ix
	lea	de, iy + 0
	add	hl, de
	ld	de, -214
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -217
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	de, iy + 0
	ld	hl, (iy + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 77
	ld	(iy + 0), bc
	push	bc
	pop	iy
	jr	nz, .LBB15_73
; %bb.71:                               ;   in Loop: Header=BB15_44 Depth=1
	push	de
	pop	iy
	ld	hl, (iy + 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	bc, -214
	lea	hl, ix + 0
	push	af
	add	hl, bc
	pop	af
	ld	iy, (hl)
	jr	z, .LBB15_73
; %bb.72:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	bc, -208
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	.local	.LBB15_73
.LBB15_73:                              ;   in Loop: Header=BB15_44 Depth=1
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	call	__ixor
	push	hl
	pop	bc
	push	de
	pop	iy
	ld	hl, (iy + 18)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB15_77
; %bb.74:                               ;   in Loop: Header=BB15_44 Depth=1
	ld	hl, (iy + 21)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB15_76
; %bb.75:                               ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 86), hl
	pop	ix
	.local	.LBB15_76
.LBB15_76:                              ;   in Loop: Header=BB15_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 86)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 77), hl
	pop	ix
	.local	.LBB15_77
.LBB15_77:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	hl, (iy + 36)
	ld	de, -64
	add	hl, de
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB15_79
; %bb.78:                               ;   in Loop: Header=BB15_44 Depth=1
	lea	de, iy + 0
	ld	bc, -205
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	call	__ixor
	push	hl
	pop	bc
	push	de
	pop	iy
	ld	hl, (iy + 39)
	ld	de, -64
	add	hl, de
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB15_80
	.local	.LBB15_79
.LBB15_79:                              ;   in Loop: Header=BB15_44 Depth=1
	ld	de, -151
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	inc	iyl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	ld	de, 46
	add	hl, de
	push	hl
	pop	bc
	ld	de, 92
	jp	.LBB15_44
	.local	.LBB15_80
.LBB15_80:
	ld	hl, _portals
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, -160
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, 9
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	hl, (iy + 0)
	ldir
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_transform_portal_point
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	bc, -175
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	lea	hl, iy + 0
	ld	bc, 9
	ldir
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 73)
	pop	ix
	ld	bc, 9
	ldir
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	push	hl
	push	iy
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, -201
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	bc, -175
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 9
	ldir
	ld	iy, (ix + 6)
	lea	hl, iy + 18
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	de
	push	de
	push	de
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, 9
	ldir
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	bc, -175
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 9
	ldir
	ld	iy, (ix + 6)
	lea	hl, iy + 27
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	de
	push	de
	push	de
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, 9
	ldir
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	bc, -175
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 9
	ldir
	ld	iy, (ix + 6)
	lea	hl, iy + 36
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	de
	push	de
	push	de
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, 9
	ldir
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_transform_portal_vector
	ld	iy, (ix + 6)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, -139
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 47)
	pop	ix
	ld	bc, 9
	ldir
	ld	de, (iy + 42)
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 29), de
	pop	ix
	ex	de, hl
	add	hl, bc
	call	__ixor
	ld	e, 0
	push	ix
	lea	ix, ix - 128
	ld	(ix - 35), hl
	pop	ix
	ld	a, (iy + 45)
	ld	bc, -148
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a
	ld	bc, 130
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), e                    ; 1-byte Folded Spill
	pop	ix
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	a, e
	.local	.LBB15_81
.LBB15_81:                              ; =>This Inner Loop Header: Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	or	a, a
	sbc	hl, bc
	jp	z, .LBB15_87
; %bb.82:                               ;   in Loop: Header=BB15_81 Depth=1
	ld	hl, _quarter_sine
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, (hl)
	ld	l, d
	rlc	l
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	de, -163
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	call	__ixor
	push	hl
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 70
	ld	de, (iy + 0)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	iy
	jp	m, .LBB15_84
; %bb.83:                               ;   in Loop: Header=BB15_81 Depth=1
	push	de
	pop	iy
	.local	.LBB15_84
.LBB15_84:                              ;   in Loop: Header=BB15_81 Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	de, -151
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	ld	b, (hl)                         ; 1-byte Folded Reload
	ld	c, b
	jp	m, .LBB15_86
; %bb.85:                               ;   in Loop: Header=BB15_81 Depth=1
	ld	c, a
	.local	.LBB15_86
.LBB15_86:                              ;   in Loop: Header=BB15_81 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	ld	de, 2
	add	hl, de
	inc	b
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), b
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	de, -198
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	a, c
	ld	iy, (ix + 6)
	ld	e, 0
	ld	bc, 130
	jp	.LBB15_81
	.local	.LBB15_87
.LBB15_87:
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	l, a
	jp	p, .LBB15_89
; %bb.88:
	ld	a, e
	sub	a, l
	ld	l, a
	.local	.LBB15_89
.LBB15_89:
	push	ix
	lea	ix, ix - 128
	ld	(ix - 44), l                    ; 1-byte Folded Spill
	pop	ix
	ld	(iy + 46), l
	ld	de, (iy + 36)
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 41), de
	pop	ix
	ex	de, hl
	add	hl, bc
	call	__ixor
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	de, (iy + 39)
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 35), de
	pop	ix
	ex	de, hl
	add	hl, bc
	call	__ixor
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 11)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 38), hl
	pop	ix
	ld	de, 9
	or	a, a
	sbc	hl, de
	jp	nc, .LBB15_91
; %bb.90:
	ld	iy, (ix + 6)
	ld	iy, (iy + 18)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	call	__ixor
	ex	de, hl
	ld	iy, (ix + 6)
	ld	iy, (iy + 21)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	ld	iy, (ix + 6)
	call	__ixor
	add	hl, de
	ld	de, 9
	or	a, a
	sbc	hl, de
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	de, -202
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a                         ; 1-byte Folded Spill
	.local	.LBB15_91
.LBB15_91:
	ld.sis	hl, 256
	.local	.LBB15_92
.LBB15_92:                              ; =>This Inner Loop Header: Depth=1
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), l
	ld	(ix - 10), h
	pop	ix
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 51)
	pop	ix
	jp	z, .LBB15_113
; %bb.93:                               ;   in Loop: Header=BB15_92 Depth=1
	push	hl
	ld	de, -179
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	call	_angle_sine
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	pop	hl
	ld	l, 64
	ld	bc, -179
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	a, e
	add	a, l
	ld	l, a
	push	hl
	call	_angle_sine
	ld	de, -157
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	pop	hl
	ld	de, -166
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 9
	or	a, a
	sbc	hl, de
	jp	c, .LBB15_95
; %bb.94:                               ;   in Loop: Header=BB15_92 Depth=1
	ld	de, -163
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	(ix - 88), hl
	ld	a, (ix - 86)
	rlc	a
	sbc	a, a
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	ld	(ix - 85), bc
	ld	a, (ix - 83)
	rlc	a
	sbc	a, a
	ld	d, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 29
	ld	hl, (iy + 0)
	ld	(ix - 82), hl
	ld	a, (ix - 80)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	a, d
	call	__lmulu
	push	hl
	pop	iy
	ld	d, e
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	ld	(ix - 79), hl
	ld	a, (ix - 77)
	rlc	a
	sbc	a, a
	ld	e, a
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 35)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 47)                    ; 1-byte Folded Reload
	pop	ix
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy + 0
	ld	e, d
	call	__ladd
	jp	.LBB15_97
	.local	.LBB15_95
.LBB15_95:                              ;   in Loop: Header=BB15_92 Depth=1
	ld	de, -202
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	jp	z, .LBB15_107
; %bb.96:                               ;   in Loop: Header=BB15_92 Depth=1
	ld	hl, (ix + 6)
	ex	de, hl
	push	de
	pop	iy
	ld	hl, (iy + 18)
	ld	(ix - 100), hl
	ld	a, (ix - 98)
	rlc	a
	sbc	a, a
	ld	e, a
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 23)
	pop	ix
	ld	(ix - 97), bc
	ld	a, (ix - 95)
	rlc	a
	sbc	a, a
	call	__lmulu
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), hl
	pop	ix
	ld	d, e
	ld	hl, (iy + 21)
	ld	(ix - 94), hl
	ld	a, (ix - 92)
	rlc	a
	sbc	a, a
	ld	e, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 29
	ld	bc, (iy + 0)
	ld	(ix - 91), bc
	ld	a, (ix - 89)
	rlc	a
	sbc	a, a
	call	__lmulu
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	bc, (iy + 0)
	ld	a, d
	call	__lsub
	.local	.LBB15_97
.LBB15_97:                              ;   in Loop: Header=BB15_92 Depth=1
	push	hl
	pop	bc
	ld	a, e
	.local	.LBB15_98
.LBB15_98:                              ;   in Loop: Header=BB15_92 Depth=1
	ld	de, -194
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 67
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmps
	call	pe, __setflag
	ld	de, -179
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	ld	d, l
	jp	m, .LBB15_100
; %bb.99:                               ;   in Loop: Header=BB15_92 Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB15_100
.LBB15_100:                             ;   in Loop: Header=BB15_92 Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 66
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 67
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmps
	call	pe, __setflag
	ld	l, 1
	ld	iy, (ix + 6)
	jp	m, .LBB15_102
; %bb.101:                              ;   in Loop: Header=BB15_92 Depth=1
	ld	l, 0
	.local	.LBB15_102
.LBB15_102:                             ;   in Loop: Header=BB15_92 Depth=1
	bit	0, l
	jr	nz, .LBB15_104
; %bb.103:                              ;   in Loop: Header=BB15_92 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 66)
	pop	ix
	.local	.LBB15_104
.LBB15_104:                             ;   in Loop: Header=BB15_92 Depth=1
	bit	0, l
	jr	nz, .LBB15_106
; %bb.105:                              ;   in Loop: Header=BB15_92 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	pop	ix
	.local	.LBB15_106
.LBB15_106:                             ;   in Loop: Header=BB15_92 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 51)
	pop	ix
	inc	l
	push	ix
	lea	ix, ix - 128
	ld	(ix - 51), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 11)
	ld	h, (ix - 10)
	pop	ix
	dec.sis	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), d                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 66), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	pop	ix
	jp	.LBB15_92
	.local	.LBB15_107
.LBB15_107:                             ;   in Loop: Header=BB15_92 Depth=1
	ld	de, -172
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	cp	a, 1
	call	pe, __setflag
	ld	a, d
	jp	p, .LBB15_109
; %bb.108:                              ;   in Loop: Header=BB15_92 Depth=1
	ld	a, 0
	.local	.LBB15_109
.LBB15_109:                             ;   in Loop: Header=BB15_92 Depth=1
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a
	ld	iy, (ix + 6)
	ld	hl, (iy + 27)
	ld	(ix - 112), hl
	ld	a, (ix - 110)
	rlc	a
	sbc	a, a
	ld	e, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 29
	ld	bc, (iy + 0)
	ld	(ix - 109), bc
	ld	a, (ix - 107)
	rlc	a
	sbc	a, a
	call	__lmulu
	ld	bc, -157
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	d, e
	ld	iy, (ix + 6)
	ld	hl, (iy + 30)
	ld	(ix - 106), hl
	ld	a, (ix - 104)
	rlc	a
	sbc	a, a
	ld	e, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	bc, (iy + 0)
	ld	(ix - 103), bc
	ld	a, (ix - 101)
	rlc	a
	sbc	a, a
	call	__lmulu
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 29
	ld	bc, (iy + 0)
	ld	a, d
	call	__ladd
	push	hl
	pop	iy
	ld	d, e
	call	__lneg
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 47)                    ; 1-byte Folded Reload
	pop	ix
	ld	a, e
	bit	0, l
	jr	nz, .LBB15_111
; %bb.110:                              ;   in Loop: Header=BB15_92 Depth=1
	lea	bc, iy + 0
	.local	.LBB15_111
.LBB15_111:                             ;   in Loop: Header=BB15_92 Depth=1
	bit	0, l
	jp	nz, .LBB15_98
; %bb.112:                              ;   in Loop: Header=BB15_92 Depth=1
	ld	a, d
	jp	.LBB15_98
	.local	.LBB15_113
.LBB15_113:
	ld	de, -148
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 45), a
	push	iy
	call	_rebuild_camera_basis
	pop	hl
	ld	de, -160
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 44)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 46
	call	__imulu
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	a, (iy + 42)
	lea	hl, iy + 0
	ld	iy, (ix + 6)
	ld	(iy + 47), a
	push	hl
	pop	iy
	lea	hl, iy + 27
	ld	bc, -226
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 101)
	pop	ix
	add	iy, de
	ld	de, 16
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 101), iy
	pop	ix
	push	de
	push	de
	push	de
	push	de
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	ld	bc, 9
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	de, (iy + 0)
	ldir
	ld	de, -139
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 101)
	pop	ix
	ld	(iy + 9), hl
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_add_signed_axis
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix + 6)
	ld	(iy + 49), 0
	.local	.LBB15_114
.LBB15_114:                             ; %.loopexit
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_collide_with_room
	ld	iy, (ix + 6)
	pop	hl
	pop	hl
	lea	de, iy + 0
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	ld	bc, 9
	ldir
	ld	a, (iy + 48)
	ld	(ix - 19), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 26)
	pop	ix
	bit	0, l
	ld	a, 1
	jr	nz, .LBB15_118
; %bb.115:
	ld	hl, 52
	push	hl
	push	iy
	ld	de, -145
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_memcmp
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB15_117
; %bb.116:
	ld	a, 0
	jr	.LBB15_118
	.local	.LBB15_117
.LBB15_117:
	ld	a, 1
	.local	.LBB15_118
.LBB15_118:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_engine_update, .Lfunc_end15-_engine_update
                                        ; -- End function
	.section	.text._place_portal,"ax",@progbits
	.type	_place_portal,@function         ; -- Begin function place_portal
_place_portal:                          ; @place_portal
; %bb.0:
	ld	hl, -83
	call	__frameset
	ld	iy, (ix + 6)
	ld	hl, _world_faces
	ld	(ix - 30), hl
	ld	hl, _face_normals+3
	ld	(ix - 27), hl
	lea	de, ix - 9
	ld	a, (iy + 47)
	or	a, a
	sbc	hl, hl
	ld	(ix - 65), a                    ; 1-byte Folded Spill
	ld	l, a
	ld	bc, 13
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _rooms
	add	iy, bc
	ld	(ix - 68), de
	ld	hl, (ix + 6)
	ld	bc, 9
	ldir
	ld	a, (iy)
	lea	bc, iy + 0
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	iy, (ix + 6)
	lea	de, iy + 36
	push	bc
	pop	iy
	ld	(ix - 58), de
	ld	de, (ix - 9)
	ld	(ix - 42), de
	ld	de, (ix - 6)
	ld	(ix - 48), de
	ld	de, (ix - 3)
	ld	(ix - 45), de
	ld	bc, 6
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 30)
	add	hl, de
	ld	(ix - 30), hl
	ld	de, 0
	ld	bc, 36
	xor	a, a
	ld	l, -1
                                        ; kill: def $l killed $l def $uhl
	ld	(ix - 33), hl
	ld	hl, 8388607
	ld	(ix - 64), hl
	.local	.LBB16_1
.LBB16_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB16_35
; %bb.2:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 39), iy
	ld	(ix - 49), a                    ; 1-byte Folded Spill
	ld	iy, (ix - 27)
	ld	hl, (iy - 3)
	ld	(ix - 52), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB16_4
; %bb.3:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	a, 0
	.local	.LBB16_4
.LBB16_4:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 36), de
	ld	hl, (ix - 27)
	ld	de, (hl)
	ld	(ix - 55), de
	sbc	hl, hl
	adc	hl, de
	ld	c, -1
	jr	z, .LBB16_6
; %bb.5:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	c, 0
	.local	.LBB16_6
.LBB16_6:                               ;   in Loop: Header=BB16_1 Depth=1
	bit	0, c
	ld	de, 42
	jr	nz, .LBB16_8
; %bb.7:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	de, 39
	.local	.LBB16_8
.LBB16_8:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix + 6)
	add	hl, de
	bit	0, c
	jr	nz, .LBB16_10
; %bb.9:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	bc, (ix - 55)
	jr	.LBB16_11
	.local	.LBB16_10
.LBB16_10:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 27)
	ld	bc, (iy + 3)
	.local	.LBB16_11
.LBB16_11:                              ;   in Loop: Header=BB16_1 Depth=1
	bit	0, a
	jr	nz, .LBB16_13
; %bb.12:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 58)
	.local	.LBB16_13
.LBB16_13:                              ;   in Loop: Header=BB16_1 Depth=1
	bit	0, a
	jr	nz, .LBB16_15
; %bb.14:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	bc, (ix - 52)
	.local	.LBB16_15
.LBB16_15:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (hl)
	lea	hl, iy + 0
	call	__ineg
	ex	de, hl
	ld	(ix - 61), bc
	push	bc
	pop	hl
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB16_17
; %bb.16:                               ;   in Loop: Header=BB16_1 Depth=1
	push	de
	pop	iy
	.local	.LBB16_17
.LBB16_17:                              ;   in Loop: Header=BB16_1 Depth=1
	lea	hl, iy + 0
	ld	de, -4
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB16_31
; %bb.18:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 71), iy
	ld	hl, (ix - 30)
	ld	de, (ix - 36)
	add	hl, de
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 6
	call	__imulu
	ex	de, hl
	ld	iy, _world_vertices
	add	iy, de
	ld	de, (iy + 4)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 74), hl
	ld	bc, (iy + 2)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 77), hl
	ld	bc, (iy)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, (ix + 6)
	push	bc
	pop	iy
	ld	de, (iy)
	ld	bc, (iy + 3)
	ld	iy, (iy + 6)
	ld	(ix - 83), de
	or	a, a
	sbc	hl, de
	ld	(ix - 80), hl
	ld	hl, (ix - 77)
	ld	(ix - 77), bc
	or	a, a
	sbc	hl, bc
	ex	de, hl
	ld	hl, (ix - 74)
	lea	bc, iy + 0
	ld	(ix - 74), bc
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ld	hl, (ix - 55)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB16_20
; %bb.19:                               ;   in Loop: Header=BB16_1 Depth=1
	push	de
	pop	bc
	.local	.LBB16_20
.LBB16_20:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 52)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB16_22
; %bb.21:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	bc, (ix - 80)
	.local	.LBB16_22
.LBB16_22:                              ;   in Loop: Header=BB16_1 Depth=1
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ld	hl, (ix - 61)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB16_24
; %bb.23:                               ;   in Loop: Header=BB16_1 Depth=1
	lea	bc, iy + 0
	.local	.LBB16_24
.LBB16_24:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 24), bc
	ld	a, (ix - 22)
	rlc	a
	sbc	a, a
	ld	l, 8
	call	__lshl
	ld	e, a
	ld	iy, (ix - 71)
	ld	(ix - 21), iy
	ld	a, (ix - 19)
	rlc	a
	sbc	a, a
	push	bc
	pop	hl
	lea	bc, iy + 0
	call	__ldivs
	push	hl
	pop	iy
	ld	bc, 33
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB16_31
; %bb.25:                               ;   in Loop: Header=BB16_1 Depth=1
	lea	hl, iy + 0
	ld	bc, (ix - 64)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB16_31
; %bb.26:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix + 6)
	lea	bc, iy + 0
	push	hl
	pop	iy
	ld	(ix - 71), e                    ; 1-byte Folded Spill
	ld	de, (iy + 36)
	ld	hl, (iy + 39)
	ld	(ix - 61), hl
	ld	iy, (ix + 6)
	ld	hl, (iy + 42)
	ld	(ix - 52), hl
	ld	(ix - 18), de
	push	de
	pop	iy
	ld	a, (ix - 16)
	rlc	a
	sbc	a, a
	ld	(ix - 55), a                    ; 1-byte Folded Spill
	ld	(ix - 80), bc
	push	bc
	pop	hl
	ld	e, (ix - 71)                    ; 1-byte Folded Reload
	ld	bc, 8388607
	xor	a, a
	call	__land
	ld	(ix - 71), hl
	ld	d, e
	lea	bc, iy + 0
	ld	a, (ix - 55)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	iyl, 8
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	call	__lshru
	ld	(ix - 55), bc
	ld	bc, (ix - 61)
	ld	(ix - 15), bc
	ld	a, (ix - 13)
	rlc	a
	sbc	a, a
	ld	iy, (ix - 71)
	lea	hl, iy + 0
	ld	e, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	(ix - 61), bc
	ld	bc, (ix - 52)
	ld	(ix - 12), bc
	ld	a, (ix - 10)
	rlc	a
	sbc	a, a
	lea	hl, iy + 0
	ld	e, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	hl, (ix - 83)
	ld	de, (ix - 55)
	add	hl, de
	ld	(ix - 52), hl
	ld	hl, (ix - 77)
	ld	de, (ix - 61)
	add	hl, de
	ld	(ix - 55), hl
	ld	hl, (ix - 74)
	add	hl, bc
	ld	(ix - 61), hl
	ld	iy, (ix - 39)
	ld	de, (iy + 1)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	hl, (ix - 52)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB16_31
; %bb.27:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 39)
	ld	de, (iy + 3)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 52)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB16_31
; %bb.28:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 39)
	ld	de, (iy + 5)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	hl, (ix - 55)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB16_31
; %bb.29:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 55)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB16_31
; %bb.30:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (iy + 9)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB16_33
	.local	.LBB16_31
.LBB16_31:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 36)
	.local	.LBB16_32
.LBB16_32:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 27)
	lea	iy, iy + 9
	ld	(ix - 27), iy
	ld	de, 6
	add	hl, de
	ld	a, (ix - 49)                    ; 1-byte Folded Reload
	inc	a
	ex	de, hl
	ld	bc, 36
	ld	iy, (ix - 39)
	jp	.LBB16_1
	.local	.LBB16_33
.LBB16_33:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (iy + 11)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 61)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, (ix - 36)
	jp	m, .LBB16_32
; %bb.34:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 45), de
	ld	de, (ix - 55)
	ld	(ix - 48), de
	ld	de, (ix - 52)
	ld	(ix - 42), de
	ld	e, (ix - 49)                    ; 1-byte Folded Reload
	ld	(ix - 33), de
	ld	de, (ix - 80)
	ld	(ix - 64), de
	jr	.LBB16_32
	.local	.LBB16_35
.LBB16_35:
	ld	hl, (ix - 48)
	ld	(ix - 6), hl
	ld	hl, (ix - 45)
	ld	(ix - 3), hl
	ld	hl, (ix - 42)
	ld	(ix - 9), hl
	ld	hl, (ix - 33)
	ld	a, l
	cp	a, -1
	jr	z, .LBB16_38
; %bb.36:
	push	hl
	push	iy
	call	_room_face_holds_portal
	pop	hl
	pop	hl
	ld	hl, (ix - 33)
	or	a, a
	jr	z, .LBB16_38
; %bb.37:
	push	hl
	pop	iy
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, 9
	ld	hl, (ix - 68)
	ldir
	push	iy
	ld	l, (ix - 65)                    ; 1-byte Folded Reload
	push	hl
	ld	l, (ix + 9)
	push	hl
	call	_configure_portal_on_face
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB16_38
.LBB16_38:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_place_portal, .Lfunc_end16-_place_portal
                                        ; -- End function
	.section	.text._transform_portal_point,"ax",@progbits
	.type	_transform_portal_point,@function ; -- Begin function transform_portal_point
_transform_portal_point:                ; @transform_portal_point
; %bb.0:
	ld	hl, -30
	call	__frameset
	ld	a, (ix + 9)
	ld	hl, _portals
	ld	(ix - 21), hl
	lea	hl, ix - 9
	ld	(ix - 24), hl
	ld	de, 0
	ld	e, a
	ld	bc, 46
	push	de
	pop	hl
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _portals
	add	iy, bc
	ld	l, (iy + 44)
	ld	e, l
	ex	de, hl
	ld	bc, 46
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 21)
	add	hl, de
	ld	(ix - 21), hl
	ld	de, (iy)
	ld	hl, (iy + 3)
	ld	(ix - 30), hl
	ld	hl, (iy + 6)
	ld	(ix - 27), hl
	ld	hl, (ix + 12)
	ld	bc, (ix + 15)
	ld	iy, (ix + 18)
	or	a, a
	sbc	hl, de
	ld	(ix - 9), hl
	push	bc
	pop	hl
	ld	de, (ix - 30)
	or	a, a
	sbc	hl, de
	ld	(ix - 6), hl
	lea	hl, iy + 0
	ld	de, (ix - 27)
	or	a, a
	sbc	hl, de
	ld	(ix - 3), hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, 9
	ld	hl, (ix - 24)
	ldir
	ld	l, a
	push	hl
	pea	ix - 18
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 18)
	ld	(ix - 30), hl
	ld	hl, (ix - 15)
	ld	(ix - 27), hl
	ld	hl, (ix - 12)
	ld	(ix - 24), hl
	ld	iy, (ix - 21)
	ld	hl, (iy)
	ld	bc, (iy + 3)
	ld	de, (iy + 6)
	ld	(ix - 21), de
	ld	de, (ix - 30)
	add	hl, de
	ld	de, (ix + 6)
	push	de
	pop	iy
	ld	(iy), hl
	push	bc
	pop	hl
	ld	de, (ix - 27)
	add	hl, de
	lea	bc, iy + 0
	ld	(iy + 3), hl
	ld	de, (ix - 24)
	ld	hl, (ix - 21)
	add	hl, de
	ld	(iy + 6), hl
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_transform_portal_point, .Lfunc_end17-_transform_portal_point
                                        ; -- End function
	.section	.text._transform_portal_vector,"ax",@progbits
	.type	_transform_portal_vector,@function ; -- Begin function transform_portal_vector
_transform_portal_vector:               ; @transform_portal_vector
; %bb.0:
	ld	hl, -18
	call	__frameset
	ld	a, (ix + 9)
	lea	de, ix + 12
	ld	iy, _portals
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 46
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	lea	bc, iy + 0
	ld	hl, (iy + 9)
	ld	(ix - 12), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	ld	(ix - 3), de
	jr	nz, .LBB18_4
; %bb.1:
	push	bc
	pop	iy
	ld	de, (iy + 12)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB18_3
; %bb.2:
	push	bc
	pop	iy
	ld	hl, (iy + 15)
	ld	(ix - 12), hl
	ld	iy, (ix - 3)
	lea	hl, iy + 6
	jr	.LBB18_4
	.local	.LBB18_3
.LBB18_3:
	ld	(ix - 12), de
	ld	iy, (ix - 3)
	lea	hl, iy + 3
	.local	.LBB18_4
.LBB18_4:
	ld	(ix - 9), hl
	push	bc
	pop	iy
	ld	de, (iy + 18)
	sbc	hl, hl
	adc	hl, de
	ld	hl, (ix - 3)
	jr	nz, .LBB18_9
; %bb.5:
	push	bc
	pop	iy
	ld	de, (iy + 21)
	sbc	hl, hl
	adc	hl, de
	ld	(ix - 18), bc
	jr	nz, .LBB18_7
; %bb.6:
	push	bc
	pop	iy
	ld	de, (iy + 24)
	ld	iy, (ix - 3)
	lea	hl, iy + 6
	jr	.LBB18_8
	.local	.LBB18_7
.LBB18_7:
	ld	iy, (ix - 3)
	lea	hl, iy + 3
	.local	.LBB18_8
.LBB18_8:
	ld	bc, (ix - 18)
	.local	.LBB18_9
.LBB18_9:
	ld	(ix - 15), de
	ld	de, (hl)
	push	bc
	pop	iy
	ld	hl, (iy + 27)
	ld	(ix - 6), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB18_13
; %bb.10:
	push	bc
	pop	iy
	ld	hl, (iy + 30)
	ld	(ix - 6), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB18_12
; %bb.11:
	ld	iy, (ix - 3)
	lea	iy, iy + 6
	ld	(ix - 3), iy
	push	bc
	pop	iy
	ld	hl, (iy + 33)
	ld	(ix - 6), hl
	jr	.LBB18_13
	.local	.LBB18_12
.LBB18_12:
	ld	iy, (ix - 3)
	lea	iy, iy + 3
	ld	(ix - 3), iy
	.local	.LBB18_13
.LBB18_13:
	push	bc
	pop	iy
	ld	a, (iy + 44)
	ld	hl, (ix - 9)
	ld	bc, (hl)
	ld	(ix - 9), de
	ex	de, hl
	call	__ineg
	push	hl
	pop	iy
	ld	de, 1
	ld	hl, (ix - 15)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB18_15
; %bb.14:
	ld	(ix - 9), iy
	.local	.LBB18_15
.LBB18_15:
	ld	de, 0
	ld	e, a
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ld	hl, (ix - 12)
	ld	(ix - 12), bc
	ld	bc, 1
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB18_17
; %bb.16:
	ld	iy, (ix - 12)
	.local	.LBB18_17
.LBB18_17:
	ld	(ix - 15), iy
	ld	bc, 46
	ex	de, hl
	call	__imulu
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	hl, (ix - 3)
	ld	bc, (hl)
	push	bc
	pop	hl
	call	__ineg
	ld	(ix - 12), hl
	ld	hl, (ix - 6)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB18_19
; %bb.18:
	ld	(ix - 12), bc
	.local	.LBB18_19
.LBB18_19:
	ld	hl, (ix + 6)
	ld	(hl), 0
	push	hl
	pop	bc
	inc	hl
	ex	de, hl
	push	bc
	pop	hl
	ld	bc, 8
	ldir
	lea	hl, iy + 9
	push	de
	push	de
	push	de
	push	de
	ld	(ix - 3), iy
	ld	iy, 0
	add	iy, sp
	lea	de, iy + 0
	ld	bc, 9
	ldir
	ld	hl, (ix - 15)
	ld	(iy + 9), hl
	ld	hl, (ix + 6)
	push	hl
	call	_add_signed_axis
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix - 3)
	lea	hl, iy + 18
	push	de
	push	de
	push	de
	push	de
	ld	iy, 0
	add	iy, sp
	lea	de, iy + 0
	ld	bc, 9
	ldir
	ld	hl, (ix - 9)
	ld	(iy + 9), hl
	ld	hl, (ix + 6)
	push	hl
	call	_add_signed_axis
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix - 3)
	lea	hl, iy + 27
	push	de
	push	de
	push	de
	push	de
	ld	iy, 0
	add	iy, sp
	lea	de, iy + 0
	ld	bc, 9
	ldir
	ld	hl, (ix - 12)
	ld	(iy + 9), hl
	ld	hl, (ix + 6)
	push	hl
	call	_add_signed_axis
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix + 6)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_transform_portal_vector, .Lfunc_end18-_transform_portal_vector
                                        ; -- End function
	.section	.text._add_signed_axis,"ax",@progbits
	.type	_add_signed_axis,@function      ; -- Begin function add_signed_axis
_add_signed_axis:                       ; @add_signed_axis
; %bb.0:
	call	__frameset0
	ld	bc, (ix + 18)
	ld	de, (ix + 9)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB19_5
; %bb.1:
	ld	de, (ix + 12)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB19_8
; %bb.2:
	ld	de, (ix + 15)
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ex	de, hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	bc
	pop	hl
	jp	p, .LBB19_4
; %bb.3:
	lea	hl, iy + 0
	.local	.LBB19_4
.LBB19_4:
	ld	iy, (ix + 6)
	ld	de, (iy + 6)
	add	hl, de
	ld	(iy + 6), hl
	jr	.LBB19_11
	.local	.LBB19_5
.LBB19_5:
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ex	de, hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB19_7
; %bb.6:
	lea	bc, iy + 0
	.local	.LBB19_7
.LBB19_7:
	ld	iy, (ix + 6)
	ld	hl, (iy)
	add	hl, bc
	ld	(iy), hl
	jr	.LBB19_11
	.local	.LBB19_8
.LBB19_8:
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ex	de, hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB19_10
; %bb.9:
	lea	bc, iy + 0
	.local	.LBB19_10
.LBB19_10:
	ld	iy, (ix + 6)
	ld	hl, (iy + 3)
	add	hl, bc
	ld	(iy + 3), hl
	.local	.LBB19_11
.LBB19_11:
	pop	ix
	ret
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_add_signed_axis, .Lfunc_end19-_add_signed_axis
                                        ; -- End function
	.section	.text._engine_render,"ax",@progbits
	.globl	_engine_render                  ; -- Begin function engine_render
	.type	_engine_render,@function
_engine_render:                         ; @engine_render
; %bb.0:
	ld	hl, -60
	call	__frameset
	ld	iy, _render_benchmark_last
	ld	bc, _render_benchmark+60
	lea	hl, ix - 37
	ld	(ix - 40), hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	lea	hl, iy + 3
	ld	(ix - 49), hl
	push	bc
	pop	iy
	lea	hl, iy + 3
	ld	(ix - 46), hl
	jp	z, .LBB20_7
; %bb.1:
	ld	a, (_render_benchmark_category)
	cp	a, 1
	jp	z, .LBB20_7
; %bb.2:
	ld	(ix - 43), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB20_4
; %bb.3:
	push	bc
	pop	hl
	jr	.LBB20_6
	.local	.LBB20_4
.LBB20_4:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB20_6
; %bb.5:
	ex	de, hl
	.local	.LBB20_6
.LBB20_6:
	ld	(ix - 52), hl
	ld	de, 0
	ld	(ix - 55), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 49)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 43)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 43), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 43)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 46)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 52)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 55)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 1
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+42
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB20_7
.LBB20_7:
	ld	l, 3
	ld	(ix - 55), hl
	ld	hl, _render_layers+1208
	ld	(ix - 43), hl
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	a, (iy + 51)
	ld	l, a
	push	hl
	call	_configure_render_mode
	pop	hl
	ld	de, (ix - 40)
	push	de
	pop	iy
	ld	hl, (ix + 6)
	ld	bc, 9
	ldir
	lea	de, iy + 9
	ld	iy, (ix + 6)
	lea	hl, iy + 18
	ld	bc, 9
	ldir
	ld	iy, (ix - 40)
	lea	de, iy + 18
	ld	iy, (ix + 6)
	lea	hl, iy + 27
	ld	bc, 9
	ldir
	ld	iy, (ix - 40)
	lea	de, iy + 27
	ld	iy, (ix + 6)
	lea	hl, iy + 36
	ld	bc, 9
	ldir
	ld	a, (iy + 47)
	ld	(ix - 1), a
	ld	h, 0
	ld	a, h
	ld	(_render_layers+1306), a
	ld	a, (_active_render_height)
	ld	c, a
	dec	a
	ld	(_render_layers+1307), a
	ld	a, h
	ld	(_render_layers+1308), a
	ld	a, (_active_render_width)
	ld	l, a
	dec	a
	ld	(ix - 52), a                    ; 1-byte Folded Spill
	ld	(_render_layers+1309), a
	ld	a, h
	ld	(_render_layers+1310), a
	ld	b, h
	ld	(ix - 57), l
	ld	(ix - 56), h
	call	__smulu
	ld	iy, _render_layers+1312
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, 0
	ld	e, c
	ld	a, (ix - 52)
	.local	.LBB20_8
.LBB20_8:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB20_10
; %bb.9:                                ;   in Loop: Header=BB20_8 Depth=1
	ld	iy, (ix - 43)
	ld	(iy), 0
	ld	(iy + 48), a
	inc	iy
	ld	(ix - 43), iy
	dec	de
	jr	.LBB20_8
	.local	.LBB20_10
.LBB20_10:
	ld	hl, 255
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix - 40)
	push	hl
	call	_render_camera
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB20_18
; %bb.11:
	ld	a, (_render_benchmark_category)
	cp	a, 7
	jp	z, .LBB20_18
; %bb.12:
	ld	(ix - 40), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB20_14
; %bb.13:
	push	bc
	jr	.LBB20_16
	.local	.LBB20_14
.LBB20_14:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB20_17
; %bb.15:
	push	de
	.local	.LBB20_16
.LBB20_16:
	pop	iy
	.local	.LBB20_17
.LBB20_17:
	ld	(ix - 43), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 52), e
	ld	bc, (_render_benchmark_last)
	lea	hl, iy + 0
	ld	iy, (ix - 49)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 40)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 40), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 40)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 46)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 43)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 52)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 7
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+54
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB20_18
.LBB20_18:
	call	_gfx_Wait
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB20_25
; %bb.19:
	ld	a, (_render_benchmark_category)
	cp	a, 8
	jp	z, .LBB20_25
; %bb.20:
	ld	(ix - 40), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB20_22
; %bb.21:
	push	bc
	pop	hl
	jr	.LBB20_24
	.local	.LBB20_22
.LBB20_22:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB20_24
; %bb.23:
	ex	de, hl
	.local	.LBB20_24
.LBB20_24:
	ld	iy, 0
	lea	de, iy + 0
	ld	(ix - 43), hl
	ld	(ix - 52), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 49)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 40)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 40), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 40)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 46)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 43)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 52)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 8
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+56
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB20_25
.LBB20_25:
	ld	a, (_active_render_shift)
	or	a, a
	jr	nz, .LBB20_27
; %bb.26:
	call	_present_low_frame_fast
	jr	.LBB20_28
	.local	.LBB20_27
.LBB20_27:
	call	_present_low_frame_32_fast
	.local	.LBB20_28
.LBB20_28:
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	iy, 0
	lea	de, iy + 0
	jp	z, .LBB20_35
; %bb.29:
	ld	a, (_render_benchmark_category)
	cp	a, 9
	jp	z, .LBB20_35
; %bb.30:
	ld	(ix - 40), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB20_32
; %bb.31:
	push	bc
	pop	hl
	jr	.LBB20_34
	.local	.LBB20_32
.LBB20_32:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB20_34
; %bb.33:
	ex	de, hl
	.local	.LBB20_34
.LBB20_34:
	ld	iy, 0
	ld	(ix - 43), hl
	ld	e, iyl
	ld	(ix - 52), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 49)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 40)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 40), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 40)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 46)
	ld	e, (iy)
	ld	iy, 0
	call	__ladd
	ld	a, e
	lea	de, iy + 0
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 43)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 52)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 9
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+58
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB20_35
.LBB20_35:
	ld	iy, (ix + 6)
	ld	a, (iy + 50)
	ld	(ix - 43), a
	ld	hl, (-1900524)
	ld	(ix - 40), hl
	push	de
	call	_gfx_SetColor
	pop	hl
	ld	hl, 12
	push	hl
	ld	hl, 148
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 12
	push	hl
	call	_gfx_SetTextFGColor
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_SetTextBGColor
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_SetTextTransparentColor
	pop	hl
	ld	hl, 1
	push	hl
	push	hl
	call	_gfx_SetTextScale
	pop	hl
	pop	hl
	ld	de, (ix + 9)
	sbc.sis	hl, hl
	adc.sis	hl, de
	jr	nz, .LBB20_37
; %bb.36:
	ld	hl, 2
	push	hl
	push	hl
	ld	hl, _.str
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	jp	.LBB20_40
	.local	.LBB20_37
.LBB20_37:
	ld	l, e
	ld	h, d
	ld.sis	bc, 10
	call	__sdivu
	ld	bc, 0
	ld	(ix - 52), l
	ld	(ix - 51), h
	ld	c, l
	ld	b, h
	ld	(ix - 60), bc
	push	de
	pop	bc
	ld.sis	de, 100
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	ld.sis	de, 1000
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	jr	nc, .LBB20_39
; %bb.38:
	inc	a
	ld	l, a
	ld	(ix - 55), hl
	.local	.LBB20_39
.LBB20_39:
	ld	hl, 2
	push	hl
	push	hl
	ld	hl, _.str.1
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 55)
	push	hl
	ld	hl, (ix - 60)
	push	hl
	call	_gfx_PrintUInt
	pop	hl
	pop	hl
	ld	hl, 46
	push	hl
	call	_gfx_PrintChar
	pop	hl
	ld	l, (ix - 52)
	ld	h, (ix - 51)
	ld.sis	bc, -10
	call	__smulu
	ld	de, (ix + 9)
	add.sis	hl, de
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, 1
	push	hl
	push	de
	call	_gfx_PrintUInt
	.local	.LBB20_40
.LBB20_40:
	pop	hl
	pop	hl
	ld	a, (ix - 43)                    ; 1-byte Folded Reload
	or	a, a
	ld	hl, 2
	push	hl
	ld	hl, 80
	push	hl
	ld	hl, _.str.2
	push	hl
	call	nz, _gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	de, 38558
	ld	hl, (ix - 40)
	add	hl, de
	ld	(hl), 12
	push	hl
	pop	iy
	inc	iy
	ld	a, (hl)
	ld	(iy), a
	ld	a, (iy)
	lea	de, iy + 0
	inc	iy
	ld	(iy), a
	push	hl
	pop	bc
	push	bc
	pop	iy
	lea	hl, iy + 2
	ld	a, (hl)
	push	de
	pop	iy
	lea	hl, iy + 2
	ld	(hl), a
	push	bc
	pop	iy
	lea	hl, iy + 3
	ld	a, (hl)
	push	de
	pop	iy
	lea	hl, iy + 3
	ld	(hl), a
	ld	de, 1600
	ld	bc, 0
	.local	.LBB20_41
.LBB20_41:                              ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB20_43
; %bb.42:                               ;   in Loop: Header=BB20_41 Depth=1
	ld	hl, (ix - 40)
	add	hl, bc
	push	de
	pop	iy
	ld	de, 37920
	add	hl, de
	lea	de, iy + 0
	ld	(hl), 12
	push	bc
	pop	hl
	ld	bc, 320
	add	hl, bc
	push	hl
	pop	bc
	jr	.LBB20_41
	.local	.LBB20_43
.LBB20_43:
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB20_50
; %bb.44:
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	jp	z, .LBB20_50
; %bb.45:
	ld	(ix - 43), l                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	ld	(ix - 40), de
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB20_47
; %bb.46:
	push	bc
	pop	hl
	jr	.LBB20_49
	.local	.LBB20_47
.LBB20_47:
	ld	iy, (-917472)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	ld	hl, (ix - 40)
	jr	nc, .LBB20_49
; %bb.48:
	lea	hl, iy + 0
	.local	.LBB20_49
.LBB20_49:
	ld	iy, 0
	ld	(ix - 40), hl
	ld	e, iyl
	ld	(ix - 52), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 49)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 43)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 43), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 43)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 46)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 40)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 52)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	l, (ix - 57)
	ld	h, (ix - 56)
	ld	a, h
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+40
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB20_50
.LBB20_50:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_engine_render, .Lfunc_end20-_engine_render
                                        ; -- End function
	.section	.text._render_camera,"ax",@progbits
	.type	_render_camera,@function        ; -- Begin function render_camera
_render_camera:                         ; @render_camera
; %bb.0:
	ld	hl, -172
	call	__frameset
	ld	a, (ix + 9)
	ld	iy, _render_layers
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 1318
	ld	(ix - 91), hl
	call	__imulu
	ld	c, a
	ex	de, hl
	ld	(ix - 94), iy
	add	iy, de
	ld	(ix - 85), iy
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	iy, _render_benchmark_last
	lea	hl, iy + 3
	ld	(ix - 109), hl
	ld	iy, _render_benchmark+60
	lea	hl, iy + 3
	ld	(ix - 112), hl
	jp	z, .LBB21_11
; %bb.1:
	ld	a, c
	or	a, a
	jr	z, .LBB21_3
; %bb.2:
	ld	hl, 5
	jr	.LBB21_4
	.local	.LBB21_3
.LBB21_3:
	ld	hl, 2
	.local	.LBB21_4
.LBB21_4:
	ld	a, (_render_benchmark_category)
	cp	a, l
	jp	z, .LBB21_11
; %bb.5:
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	(ix - 88), hl
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB21_7
; %bb.6:
	push	bc
	pop	hl
	jr	.LBB21_10
	.local	.LBB21_7
.LBB21_7:
	ld	hl, (-917472)
	ld	(ix - 100), hl
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	jr	nc, .LBB21_9
; %bb.8:
	ld	iy, (ix - 100)
	.local	.LBB21_9
.LBB21_9:
	lea	hl, iy + 0
	.local	.LBB21_10
.LBB21_10:
	ld	iy, 0
	ld	e, iyl
	ld	(ix - 100), e
	ld	bc, (_render_benchmark_last)
	ld	(ix - 103), hl
	ld	iy, (ix - 109)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 97), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 97)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 112)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 103)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	hl, (ix - 88)
	ld	a, l
	ld	(_render_benchmark_category), a
	add	hl, hl
	ex	de, hl
	ld	hl, _render_benchmark+40
	add	hl, de
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	c, (ix + 9)
	.local	.LBB21_11
.LBB21_11:
	ld	l, (ix + 12)
	ld	de, 1
	ld	a, c
	or	a, a
	jr	z, .LBB21_13
; %bb.12:
	ld	de, 0
	.local	.LBB21_13
.LBB21_13:
	push	de
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	hl, (ix + 6)
	push	hl
	ld	hl, (ix - 85)
	push	hl
	call	_collect_room_polygons
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	c, (ix + 9)
	jp	z, .LBB21_23
; %bb.14:
	ld	a, c
	or	a, a
	ld	hl, 3
	jr	z, .LBB21_16
; %bb.15:
	ld	hl, 6
	.local	.LBB21_16
.LBB21_16:
	ld	a, (_render_benchmark_category)
	cp	a, l
	jp	z, .LBB21_23
; %bb.17:
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	(ix - 97), hl
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	ld	(ix - 88), de
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB21_19
; %bb.18:
	push	bc
	pop	hl
	ld	iy, 0
	jr	.LBB21_22
	.local	.LBB21_19
.LBB21_19:
	ld	hl, (-917472)
	ld	(ix - 103), hl
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	ld	iy, 0
	jr	nc, .LBB21_21
; %bb.20:
	ld	hl, (ix - 103)
	ld	(ix - 88), hl
	.local	.LBB21_21
.LBB21_21:
	ld	hl, (ix - 88)
	.local	.LBB21_22
.LBB21_22:
	ld	e, iyl
	ld	(ix - 103), e
	ld	bc, (_render_benchmark_last)
	ld	(ix - 88), hl
	ld	iy, (ix - 109)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 100)                   ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 100), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 100)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 112)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 88)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	hl, (ix - 97)
	ld	a, l
	ld	(_render_benchmark_category), a
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark+40
	add	iy, de
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	c, (ix + 9)
	.local	.LBB21_23
.LBB21_23:
	ld	de, _low_frame+2
	ld	a, c
	or	a, a
	ld	bc, 1306
	jp	nz, .LBB21_244
; %bb.24:
	ld	a, (_active_render_width)
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, a
	ld	a, (_active_render_height)
	ld	l, a
	call	__imulu
	push	hl
	ld	hl, 1
	push	hl
	push	de
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	ld	de, (ix - 85)
	.local	.LBB21_25
.LBB21_25:                              ; %.loopexit90
	ld	iy, 0
	lea	hl, ix - 45
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	lea	hl, ix - 82
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	lea	hl, ix - 8
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), hl
	pop	ix
	lea	hl, ix - 45
	ld	(ix - 118), hl
	lea	hl, ix - 82
	ld	(ix - 115), hl
	push	de
	pop	hl
	ld	bc, 1208
	add	hl, bc
	ld	(ix - 124), hl
	push	de
	pop	hl
	ld	bc, 1256
	add	hl, bc
	ld	(ix - 127), hl
	ld	hl, (ix - 91)
	ld	bc, 1318
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 94)
	add	hl, bc
	ld	(ix - 94), hl
	ld	bc, 1305
	.local	.LBB21_26
.LBB21_26:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB21_28 Depth 2
                                        ;     Child Loop BB21_54 Depth 2
                                        ;       Child Loop BB21_70 Depth 3
                                        ;       Child Loop BB21_88 Depth 3
                                        ;     Child Loop BB21_37 Depth 2
	push	de
	pop	hl
	add	hl, bc
	ld	a, (hl)
	ld	bc, 0
	ld	c, a
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB21_95
; %bb.27:                               ;   in Loop: Header=BB21_26 Depth=1
	ld	(ix - 106), iy
	lea	hl, iy + 0
	ld	(ix - 88), bc
	ld	bc, 151
	call	__imulu
	push	hl
	pop	bc
	push	de
	pop	hl
	add	hl, bc
	ld	(ix - 91), hl
	ex	de, hl
	ld	de, 1304
	add	hl, de
	ld	a, (hl)
	ld	iy, 0
	lea	hl, iy + 0
	ld	l, a
	ld	(ix - 97), hl
	ld	hl, (ix - 88)
	ld	bc, 151
	call	__imulu
	ld	bc, (ix - 88)
	ex	de, hl
	ld	hl, (ix - 94)
	add	hl, de
	ld	(ix - 103), hl
	ld	e, iyh
	ld	a, e
	.local	.LBB21_28
.LBB21_28:                              ;   Parent Loop BB21_26 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	de, iy + 0
	ld	e, a
	push	bc
	pop	iy
	push	bc
	pop	hl
	ld	bc, (ix - 97)
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB21_36
; %bb.29:                               ;   in Loop: Header=BB21_28 Depth=2
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	cp	a, 2
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	jp	nc, .LBB21_36
; %bb.30:                               ;   in Loop: Header=BB21_28 Depth=2
	ld	(ix - 88), iy
	ld	hl, (ix - 103)
	ld	bc, 146
	add	hl, bc
	ld	a, (hl)
	cp	a, -1
	jr	nz, .LBB21_32
; %bb.31:                               ;   in Loop: Header=BB21_28 Depth=2
	ld	bc, (ix - 88)
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	ld	iy, 0
	jr	.LBB21_35
	.local	.LBB21_32
.LBB21_32:                              ;   in Loop: Header=BB21_28 Depth=2
	ld	(ix - 121), de
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 46
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _portals
	add	hl, bc
	push	hl
	pop	bc
	ld	iy, (ix - 91)
	ld	de, 147
	add	iy, de
	ld	l, (iy)
	push	bc
	pop	iy
	ld	a, (iy + 43)
	cp	a, l
	jr	nz, .LBB21_34
; %bb.33:                               ;   in Loop: Header=BB21_28 Depth=2
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	inc	a
	ld	hl, (ix - 121)
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	de, (ix - 103)
	ld	(hl), de
	ld	iy, 0
	ld	bc, (ix - 88)
	jr	.LBB21_35
	.local	.LBB21_34
.LBB21_34:                              ;   in Loop: Header=BB21_28 Depth=2
	ld	iy, 0
	ld	bc, (ix - 88)
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	.local	.LBB21_35
.LBB21_35:                              ;   in Loop: Header=BB21_28 Depth=2
	inc	bc
	ld	de, 151
	ld	hl, (ix - 103)
	add	hl, de
	ld	(ix - 103), hl
	jp	.LBB21_28
	.local	.LBB21_36
.LBB21_36:                              ;   in Loop: Header=BB21_26 Depth=1
	ld	(ix - 121), de
	ld	de, (ix - 91)
	push	de
	pop	iy
	ld	bc, 149
	add	iy, bc
	ld	l, (iy)
	push	de
	pop	iy
	lea	de, iy + 48
	ld	(ix - 88), de
	lea	de, iy + 96
	ld	(ix - 97), de
                                        ; kill: def $l killed $l def $uhl
	ld	bc, 1305
	or	a, a
	jp	nz, .LBB21_54
	.local	.LBB21_37
.LBB21_37:                              ; %.preheader86
                                        ;   Parent Loop BB21_26 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	iy, (ix - 91)
	ld	de, 150
	add	iy, de
	ld	a, (iy)
	cp	a, l
	jp	c, .LBB21_94
; %bb.38:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	bc, 0
	ld	c, l
	push	hl
	pop	iy
	ld	hl, (ix - 88)
	add	hl, bc
	ld	e, (hl)
	ld	hl, (ix - 97)
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	ld	(ix - 100), e                   ; 1-byte Folded Spill
	cp	a, e
	jp	c, .LBB21_53
; %bb.39:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1306
	add	hl, de
	ld	l, (hl)
	ld	a, iyl
	cp	a, l
	jp	c, .LBB21_53
; %bb.40:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1307
	add	hl, de
	ld	a, (hl)
	cp	a, iyl
	jp	c, .LBB21_53
; %bb.41:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	(ix - 121), iy
	ld	hl, (ix - 124)
	add	hl, bc
	ld	a, (hl)
	ld	l, (ix - 100)
	cp	a, l
	jr	c, .LBB21_43
; %bb.42:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	.local	.LBB21_43
.LBB21_43:                              ;   in Loop: Header=BB21_37 Depth=2
	ld	hl, (ix - 127)
	add	hl, bc
	ld	l, (hl)
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	cp	a, l
	jr	c, .LBB21_45
; %bb.44:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	(ix - 103), l                   ; 1-byte Folded Spill
	.local	.LBB21_45
.LBB21_45:                              ;   in Loop: Header=BB21_37 Depth=2
	ld	iy, (ix - 91)
	ld	de, 148
	add	iy, de
	ld	a, (iy)
	ld	bc, 0
	ld	c, a
	ld	hl, _face_light_level
	add	hl, bc
	ld	l, (hl)
	cp	a, 2
	jp	nc, .LBB21_52
; %bb.46:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l                     ; 1-byte Folded Spill
	ld	bc, (ix - 85)
	push	bc
	pop	hl
	ld	de, 1316
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	nz, .LBB21_48
; %bb.47:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	jp	.LBB21_52
	.local	.LBB21_48
.LBB21_48:                              ;   in Loop: Header=BB21_37 Depth=2
	ld	iyh, 0
	ld	hl, (ix - 121)
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	push	bc
	pop	hl
	ld	de, 1314
	add	hl, de
	ld	e, iyl
	ld	d, iyh
	ld	bc, (hl)
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	add.sis	hl, hl
	sbc.sis	hl, hl
	ld	c, l
	ld	b, h
	add.sis	iy, bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	call	__sxor
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	a, (_active_horizon_near_limit)
	ld	c, a
	ld	b, d
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB21_50
; %bb.49:                               ;   in Loop: Header=BB21_37 Depth=2
	ld	l, -2
	jp	.LBB21_51
	.local	.LBB21_50
.LBB21_50:                              ;   in Loop: Header=BB21_37 Depth=2
	ld	a, (_active_horizon_far_limit)
	ld	e, a
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, de
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	.local	.LBB21_51
.LBB21_51:                              ;   in Loop: Header=BB21_37 Depth=2
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	ld	a, e
	add	a, l
	ld	e, a
	ld	l, e
	.local	.LBB21_52
.LBB21_52:                              ;   in Loop: Header=BB21_37 Depth=2
	ld	iy, (ix - 91)
	ld	de, 145
	add	iy, de
	ld	a, (iy)
	add	a, l
	ld	l, a
	push	hl
	ld	bc, 0
	push	bc
	pop	hl
	ld	l, (ix - 103)                   ; 1-byte Folded Reload
	push	hl
	push	bc
	pop	hl
	ld	l, (ix - 100)                   ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 121)
	push	hl
	call	_write_frame_span
	ld	iy, (ix - 121)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB21_53
.LBB21_53:                              ;   in Loop: Header=BB21_37 Depth=2
	inc	iyl
	ld	bc, 1305
	lea	hl, iy + 0
	jp	.LBB21_37
	.local	.LBB21_54
.LBB21_54:                              ; %.preheader88
                                        ;   Parent Loop BB21_26 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB21_70 Depth 3
                                        ;       Child Loop BB21_88 Depth 3
	ld	iy, (ix - 91)
	ld	de, 150
	add	iy, de
	ld	a, (iy)
	cp	a, l
	jp	c, .LBB21_94
; %bb.55:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	de, 0
	ld	e, l
	ld	(ix - 100), hl
	ld	hl, (ix - 88)
	add	hl, de
	ld	c, (hl)
	ld	hl, (ix - 97)
	ld	(ix - 103), de
	add	hl, de
	ld	b, (hl)
	ld	a, b
	cp	a, c
	jp	c, .LBB21_93
; %bb.56:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1306
	add	hl, de
	ld	l, (hl)
	ld	de, (ix - 100)
	ld	a, e
	cp	a, l
	jp	c, .LBB21_93
; %bb.57:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1307
	add	hl, de
	ld	a, (hl)
	ld	hl, (ix - 100)
	cp	a, l
	jp	c, .LBB21_93
; %bb.58:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	hl, (ix - 124)
	ld	de, (ix - 103)
	add	hl, de
	ld	a, (hl)
	cp	a, c
	ld	iyl, c
	jr	c, .LBB21_60
; %bb.59:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	iyl, a
	.local	.LBB21_60
.LBB21_60:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	iyh, 0
	ld	hl, (ix - 127)
	ld	de, (ix - 103)
	add	hl, de
	ld	l, (hl)
	ld	a, b
	cp	a, l
	jr	c, .LBB21_62
; %bb.61:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	b, l
	.local	.LBB21_62
.LBB21_62:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	a, b
	cp	a, iyl
	jp	c, .LBB21_93
; %bb.63:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	de, -139
	lea	hl, ix + 0
	add	hl, de
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	dec	hl
	pop	de
	ld	de, -145
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), b                     ; 1-byte Folded Spill
	ld	iy, (ix - 91)
	ld	de, 148
	add	iy, de
	ld	a, (iy)
	ld	bc, 0
	ld	c, a
	ld	hl, _face_light_level
	add	hl, bc
	ld	l, (hl)
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	cp	a, 2
	jp	nc, .LBB21_69
; %bb.64:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	bc, (ix - 85)
	push	bc
	pop	hl
	ld	de, 1316
	add	hl, de
	ld	a, (hl)
	or	a, a
	jp	z, .LBB21_69
; %bb.65:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
                                        ; kill: def $h killed $h killed $hl def $hl
	ld	de, (ix - 100)
	ld	l, e
	push	bc
	pop	iy
	ld	de, 1314
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	pop	ix
	ld	bc, (iy)
	or	a, a
	sbc.sis	hl, bc
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	add.sis	hl, hl
	sbc.sis	hl, hl
	ld	c, l
	ld	b, h
	add.sis	iy, bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	call	__sxor
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	a, (_active_horizon_near_limit)
	ld	c, a
	ld	b, d
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB21_67
; %bb.66:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	l, -2
	jp	.LBB21_68
	.local	.LBB21_67
.LBB21_67:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	a, (_active_horizon_far_limit)
	ld	c, a
	ld	b, d
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	.local	.LBB21_68
.LBB21_68:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)
	ld	a, e
	add	a, l
	ld	e, a
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e
	.local	.LBB21_69
.LBB21_69:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	iy, (ix - 91)
	ld	de, 145
	add	iy, de
	ld	a, (iy)
	ld	de, -148
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a
	ld	de, -130
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	or	a, a
	sbc	hl, hl
	ld	e, h
	ld	bc, (ix - 121)
	.local	.LBB21_70
.LBB21_70:                              ;   Parent Loop BB21_26 Depth=1
                                        ;     Parent Loop BB21_54 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), hl
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 11)
	ld	b, (ix - 10)
	pop	ix
	jp	nc, .LBB21_84
; %bb.71:                               ;   in Loop: Header=BB21_70 Depth=3
	ld	a, e
	cp	a, 2
	jp	nc, .LBB21_84
; %bb.72:                               ;   in Loop: Header=BB21_70 Depth=3
	ld	bc, -157
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e                         ; 1-byte Folded Spill
	ld	de, -154
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	lea	hl, iy + 0
	ld	iy, (hl)
	lea	hl, iy + 0
	ld	de, 149
	add	hl, de
	ld	l, (hl)
	ld	bc, (ix - 100)
	ld	a, c
	cp	a, l
	jr	c, .LBB21_74
; %bb.73:                               ;   in Loop: Header=BB21_70 Depth=3
	lea	hl, iy + 0
	ld	de, 150
	add	hl, de
	ld	a, (hl)
	cp	a, c
	jr	nc, .LBB21_77
	.local	.LBB21_74
.LBB21_74:                              ;   in Loop: Header=BB21_70 Depth=3
	ld	bc, (ix - 121)
	.local	.LBB21_75
.LBB21_75:                              ;   in Loop: Header=BB21_70 Depth=3
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 29
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB21_76
.LBB21_76:                              ;   in Loop: Header=BB21_70 Depth=3
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	hl, (iy + 0)
	inc	hl
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 26)
	pop	ix
	lea	iy, iy + 3
	jp	.LBB21_70
	.local	.LBB21_77
.LBB21_77:                              ;   in Loop: Header=BB21_70 Depth=3
	ld	de, (ix - 103)
	add	iy, de
	ld	e, (iy + 48)
	ld	d, (iy + 96)
	ld	a, d
	cp	a, e
	ld	bc, (ix - 121)
	jr	c, .LBB21_75
; %bb.78:                               ;   in Loop: Header=BB21_70 Depth=3
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	a, l
	cp	a, e
	ld	hl, 0
	push	hl
	pop	iy
	jr	c, .LBB21_80
; %bb.79:                               ;   in Loop: Header=BB21_70 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 11)
	ld	h, (ix - 10)
	pop	ix
	ld	e, l
	.local	.LBB21_80
.LBB21_80:                              ;   in Loop: Header=BB21_70 Depth=3
	ld	a, d
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 17)
	pop	ix
	cp	a, l
	jr	c, .LBB21_82
; %bb.81:                               ;   in Loop: Header=BB21_70 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	d, (ix - 17)                    ; 1-byte Folded Reload
	pop	ix
	.local	.LBB21_82
.LBB21_82:                              ;   in Loop: Header=BB21_70 Depth=3
	ld	a, d
	cp	a, e
	jr	c, .LBB21_75
; %bb.83:                               ;   in Loop: Header=BB21_70 Depth=3
	ld	a, e
	ld	bc, -157
	lea	hl, ix + 0
	add	hl, bc
	ld	e, (hl)                         ; 1-byte Folded Reload
	ld	iyl, e
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	lea	bc, iy + 0
	add	hl, bc
	ld	(hl), a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	hl, (iy + 0)
	add	hl, bc
	ld	bc, (ix - 121)
	ld	(hl), d
	inc	e
	jp	.LBB21_76
	.local	.LBB21_84
.LBB21_84:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	a, e
	cp	a, 2
	jr	nz, .LBB21_87
; %bb.85:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	a, (ix - 81)
	ld	l, (ix - 82)
	cp	a, l
	jr	nc, .LBB21_87
; %bb.86:                               ;   in Loop: Header=BB21_54 Depth=2
	ld	(ix - 82), a
	ld	(ix - 81), l
	ld	a, (ix - 8)
	ld	l, (ix - 7)
	ld	(ix - 8), l
	ld	(ix - 7), a
	.local	.LBB21_87
.LBB21_87:                              ; %.preheader200
                                        ;   in Loop: Header=BB21_54 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	l, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	a, (iy + 0)
	add	a, l
	ld	l, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	(iy + 0), hl
	or	a, a
	sbc	hl, hl
	ld	l, e
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
	ld	de, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	(iy + 0), de
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	de, (iy + 0)
	ld	(ix - 103), de
	ld	e, c
	ld	d, b
	push	ix
	lea	ix, ix - 128
	push	af
	ld	a, (ix - 17)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	pop	ix
	.local	.LBB21_88
.LBB21_88:                              ;   Parent Loop BB21_26 Depth=1
                                        ;     Parent Loop BB21_54 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), hl
	pop	ix
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB21_92
; %bb.89:                               ;   in Loop: Header=BB21_88 Depth=3
	ld	hl, (ix - 103)
	ld	a, (hl)
	ld	c, a
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	jr	c, .LBB21_91
; %bb.90:                               ;   in Loop: Header=BB21_88 Depth=3
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 26
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	a, (hl)
	ld	h, 0
	ld	l, a
	dec.sis	hl
	push	de
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 20)
	pop	ix
	push	de
	push	hl
	push	iy
	ld	hl, (ix - 100)
	push	hl
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c
	ld	(iy + 1), b
	call	_write_frame_span
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	c, (iy + 0)
	ld	b, (iy + 1)
	ld	de, -145
	lea	hl, ix + 0
	add	hl, de
	push	af
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	e, c
	ld	d, b
	inc.sis	de
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 26)                    ; 1-byte Folded Reload
	pop	ix
	cp	a, iyl
	jr	nc, .LBB21_92
	.local	.LBB21_91
.LBB21_91:                              ;   in Loop: Header=BB21_88 Depth=3
	ld	hl, (ix - 103)
	inc	hl
	ld	(ix - 103), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	inc	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	dec	hl
	jp	.LBB21_88
	.local	.LBB21_92
.LBB21_92:                              ;   in Loop: Header=BB21_54 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 20)
	pop	ix
	push	hl
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	push	hl
	push	de
	ld	hl, (ix - 100)
	push	hl
	call	_write_frame_span
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB21_93
.LBB21_93:                              ;   in Loop: Header=BB21_54 Depth=2
	ld	hl, (ix - 100)
	inc	l
	ld	bc, 1305
	jp	.LBB21_54
	.local	.LBB21_94
.LBB21_94:                              ; %.loopexit87
                                        ;   in Loop: Header=BB21_26 Depth=1
	ld	hl, (ix - 106)
	inc	hl
	push	hl
	pop	iy
	ld	de, (ix - 85)
	jp	.LBB21_26
	.local	.LBB21_95
.LBB21_95:
	ld	de, 0
	ld	a, (ix + 9)
	or	a, a
	jp	nz, .LBB21_243
; %bb.96:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	lea	hl, iy + 9
	ld	(ix - 106), hl
	lea	hl, iy + 18
	ld	(ix - 121), hl
	lea	hl, iy + 27
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 2
	ld	(iy + 0), hl
	push	de
	pop	iy
	ld	a, iyl
	ld	(ix - 94), a
	.local	.LBB21_97
.LBB21_97:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB21_110 Depth 2
                                        ;     Child Loop BB21_164 Depth 2
                                        ;     Child Loop BB21_174 Depth 2
                                        ;       Child Loop BB21_176 Depth 3
                                        ;     Child Loop BB21_210 Depth 2
                                        ;       Child Loop BB21_217 Depth 3
                                        ;       Child Loop BB21_221 Depth 3
                                        ;     Child Loop BB21_195 Depth 2
                                        ;       Child Loop BB21_205 Depth 3
                                        ;     Child Loop BB21_236 Depth 2
	ld	hl, (ix - 85)
	ld	de, 1304
	add	hl, de
	ld	a, (hl)
	lea	de, iy + 0
	ld	e, a
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	nc, .LBB21_243
; %bb.98:                               ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 88), bc
	push	bc
	pop	hl
	ld	bc, 151
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 85)
	add	hl, de
	ld	(ix - 91), hl
	ld	a, (_render_benchmark_active)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	bit	0, a
	jp	z, .LBB21_104
; %bb.99:                               ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 4
	jp	z, .LBB21_104
; %bb.100:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	c, .LBB21_103
; %bb.101:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	jr	nc, .LBB21_103
; %bb.102:                              ;   in Loop: Header=BB21_97 Depth=1
	push	de
	pop	bc
	.local	.LBB21_103
.LBB21_103:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 100), bc
	ld	iy, (_render_benchmark_last)
	push	bc
	pop	hl
	ld	e, (ix - 94)                    ; 1-byte Folded Reload
	lea	bc, iy + 0
	ld	iy, (ix - 109)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 97), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 97)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 112)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 100)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 94)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 4
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+48
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB21_104
.LBB21_104:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, -1
	ld	(_render_layers+2526), a
	ld	hl, _render_layers+2526
	push	hl
	pop	iy
	inc	iy
	lea	de, iy + 0
	ld	bc, 47
	ldir
	ld	iyl, 0
	ld	a, iyl
	ld	(_render_layers+2574), a
	ld	bc, _render_layers+2574
	push	bc
	pop	hl
	inc	hl
	ex	de, hl
	push	bc
	pop	hl
	ld	bc, 47
	ldir
	ld	a, (_active_render_height)
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	ld	(_render_layers+2624), a
	ld	a, iyl
	ld	(_render_layers+2625), a
	ld	a, (_active_render_width)
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	(_render_layers+2626), a
	ld	a, iyl
	ld	(_render_layers+2627), a
	ld.sis	hl, 0
	ld	iy, _render_layers+2630
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 91)
	ld	de, 149
	add	hl, de
	ld	e, (hl)
	ld	hl, (ix - 85)
	ld	bc, 1306
	add	hl, bc
	ld	a, (hl)
	cp	a, e
	jr	c, .LBB21_106
; %bb.105:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	e, a
	.local	.LBB21_106
.LBB21_106:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	hl, (ix - 91)
	ld	bc, 150
	add	hl, bc
	ld	a, (hl)
	ld	hl, (ix - 85)
	ld	bc, 1307
	add	hl, bc
	ld	l, (hl)
	cp	a, l
	ld	iy, 0
	jr	c, .LBB21_108
; %bb.107:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, l
	.local	.LBB21_108
.LBB21_108:                             ;   in Loop: Header=BB21_97 Depth=1
	cp	a, e
	ld	bc, (ix - 88)
	jp	c, .LBB21_242
; %bb.109:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld.sis	hl, 0
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), l
	ld	(ix - 10), h
	pop	ix
	ld	d, h
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), d                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), d                    ; 1-byte Folded Spill
	pop	ix
	.local	.LBB21_110
.LBB21_110:                             ;   Parent Loop BB21_97 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	cp	a, e
	jp	c, .LBB21_135
; %bb.111:                              ;   in Loop: Header=BB21_110 Depth=2
	lea	bc, iy + 0
	ld	c, e
	ld	iy, (ix - 91)
	add	iy, bc
	ld	l, (iy + 48)
	ld	a, (iy + 96)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	(iy + 0), l
	ld	(iy + 1), h
	cp	a, l
	jr	nc, .LBB21_113
; %bb.112:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	iy, 0
	ld	bc, (ix - 88)
	jp	.LBB21_134
	.local	.LBB21_113
.LBB21_113:                             ;   in Loop: Header=BB21_110 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	(iy + 0), d                     ; 1-byte Folded Spill
	ld	hl, (ix - 124)
	add	hl, bc
	ld	d, (hl)
	ld	hl, (ix - 127)
	add	hl, bc
	ld	a, (hl)
	ld	iyl, d
	cp	a, d
	jr	c, .LBB21_119
; %bb.114:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	d, a
	ld	a, iyl
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	pop	ix
	cp	a, l
	jr	c, .LBB21_116
; %bb.115:                              ;   in Loop: Header=BB21_110 Depth=2
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	(iy + 0), l
	ld	(iy + 1), h
	.local	.LBB21_116
.LBB21_116:                             ;   in Loop: Header=BB21_110 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	cp	a, d
	jr	c, .LBB21_118
; %bb.117:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	a, d
	.local	.LBB21_118
.LBB21_118:                             ;   in Loop: Header=BB21_110 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	cp	a, l
	jr	nc, .LBB21_120
	.local	.LBB21_119
.LBB21_119:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	iy, 0
	ld	bc, (ix - 88)
	push	ix
	lea	ix, ix - 128
	ld	d, (ix - 20)                    ; 1-byte Folded Reload
	pop	ix
	jp	.LBB21_134
	.local	.LBB21_120
.LBB21_120:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	h, 0
	ld	l, a
	push	ix
	lea	ix, ix - 128
	push	iy
	ex	(sp), hl
	ld	(ix - 8), l
	ld	(ix - 7), h
	pop	hl
	pop	ix
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 26
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	e, (iy + 0)
	ld	d, (iy + 1)
	ld	d, h
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	(iy + 0), e
	ld	(iy + 1), d
	ld	iy, _render_layers+2526
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 8)
	ld	d, (ix - 7)
	pop	ix
	ld	(iy), e
	ld	iy, _render_layers+2574
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), a                    ; 1-byte Folded Spill
	pop	ix
	ld	(iy), a
	ld	iy, _render_layers+2630
	ld	bc, (iy)
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 8)
	ld	d, (ix - 7)
	pop	ix
	or	a, a
	sbc.sis	hl, de
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 26)                    ; 1-byte Folded Reload
	pop	ix
	add.sis	hl, bc
	inc.sis	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), l
	ld	(ix - 10), h
	pop	ix
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_render_layers+2624)
	ld	c, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	a, d
	or	a, a
	jr	z, .LBB21_122
; %bb.121:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	a, e
	cp	a, c
	jr	nc, .LBB21_123
	.local	.LBB21_122
.LBB21_122:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	a, e
	ld	(_render_layers+2624), a
	ld	c, e
	.local	.LBB21_123
.LBB21_123:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	(ix - 103), c
	ld	a, (_render_layers+2625)
	ld	l, a
	ld	a, d
	or	a, a
	jr	z, .LBB21_125
; %bb.124:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	a, l
	cp	a, e
	jr	nc, .LBB21_126
	.local	.LBB21_125
.LBB21_125:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	a, e
	ld	(_render_layers+2625), a
	ld	l, e
	.local	.LBB21_126
.LBB21_126:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	a, (_render_layers+2626)
	ld	l, a
	ld	a, d
	or	a, a
	ld	iy, 0
	ld	bc, (ix - 88)
	jr	z, .LBB21_128
; %bb.127:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	(ix - 100), l                   ; 1-byte Folded Spill
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	pop	ix
	ld	a, l
	ld	l, (ix - 100)                   ; 1-byte Folded Reload
	cp	a, l
	jp	nc, .LBB21_129
	.local	.LBB21_128
.LBB21_128:                             ;   in Loop: Header=BB21_110 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	pop	ix
	ld	a, l
	ld	(_render_layers+2626), a
                                        ; kill: def $l killed $l killed $hl
	.local	.LBB21_129
.LBB21_129:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	(ix - 100), l
	ld	a, (_render_layers+2627)
	ld	l, a
	ld	a, d
	or	a, a
	push	ix
	lea	ix, ix - 128
	ld	d, (ix - 23)                    ; 1-byte Folded Reload
	pop	ix
	jr	z, .LBB21_131
; %bb.130:                              ;   in Loop: Header=BB21_110 Depth=2
	ld	a, l
	cp	a, d
	jr	nc, .LBB21_132
	.local	.LBB21_131
.LBB21_131:                             ;   in Loop: Header=BB21_110 Depth=2
	ld	a, d
	ld	(_render_layers+2627), a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), d                    ; 1-byte Folded Spill
	jr	.LBB21_133
	.local	.LBB21_132
.LBB21_132:                             ;   in Loop: Header=BB21_110 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), l                    ; 1-byte Folded Spill
	.local	.LBB21_133
.LBB21_133:                             ;   in Loop: Header=BB21_110 Depth=2
	pop	ix
	ld	d, 1
	.local	.LBB21_134
.LBB21_134:                             ;   in Loop: Header=BB21_110 Depth=2
	inc	e
	jp	.LBB21_110
	.local	.LBB21_135
.LBB21_135:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, d
	or	a, a
	jp	z, .LBB21_242
; %bb.136:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	hl, (ix - 91)
	ld	de, 146
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), hl
	pop	ix
	ld	a, (hl)
	lea	de, iy + 0
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	e, a
	ld	iy, _portal_lod_state
	ld	bc, -154
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	add	iy, de
	ld	de, -136
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	a, (_active_render_shift)
	or	a, a
	jr	nz, .LBB21_138
; %bb.137:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	b, 0
	.local	.LBB21_138
.LBB21_138:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
                                        ; kill: def $uhl killed $hl
	add	hl, hl
	add	hl, hl
	ld	de, -148
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	bit	0, b
	ld	h, (ix - 103)                   ; 1-byte Folded Reload
	ld	l, (ix - 100)                   ; 1-byte Folded Reload
	ld	de, -142
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	c, (iy + 0)                     ; 1-byte Folded Reload
	jr	nz, .LBB21_140
; %bb.139:                              ;   in Loop: Header=BB21_97 Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	e, (iy + 0)
	ld	d, (iy + 1)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	(iy + 0), e
	ld	(iy + 1), d
	.local	.LBB21_140
.LBB21_140:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -145
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	sub	a, l
	ld	d, a
	inc	d
	ld	a, c
	sub	a, h
	ld	e, a
	inc	e
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	hl, (iy + 0)
	ld	c, (hl)
	ld	a, b
	and	a, 1
	ld	b, a
	ld	a, d
	call	__bshl
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	ld	a, e
	call	__bshl
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	a, c
	or	a, a
	jp	nz, .LBB21_143
; %bb.141:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -148
	lea	hl, ix + 0
	add	hl, de
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	ld	iyl, e
	ld	iyh, d
	pop	de
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 160
	or	a, a
	sbc.sis	hl, bc
	ld	c, 2
	jp	c, .LBB21_150
; %bb.142:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	cp	a, 40
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	c, a
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 960
	or	a, a
	sbc.sis	hl, de
                                        ; kill: def $a killed $a
	sbc	a, a
	or	a, c
	ld	l, a
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	cp	a, 30
	jp	.LBB21_149
	.local	.LBB21_143
.LBB21_143:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, c
	cp	a, 1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	e, (iy + 0)
	ld	d, (iy + 1)
	jp	nz, .LBB21_146
; %bb.144:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	l, e
	ld	h, d
	ld.sis	bc, 160
	or	a, a
	sbc.sis	hl, bc
	ld	c, 2
	jp	c, .LBB21_150
; %bb.145:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	cp	a, 49
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	c, a
	ex.sis	de, hl
	jp	.LBB21_148
	.local	.LBB21_146
.LBB21_146:                             ;   in Loop: Header=BB21_97 Depth=1
	ex.sis	de, hl
	ld.sis	de, 257
	or	a, a
	sbc.sis	hl, de
	ld	de, -148
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	jp	c, .LBB21_150
; %bb.147:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	cp	a, 49
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	c, a
	.local	.LBB21_148
.LBB21_148:                             ;   in Loop: Header=BB21_97 Depth=1
	ld.sis	de, 1281
	or	a, a
	sbc.sis	hl, de
                                        ; kill: def $a killed $a
	sbc	a, a
	or	a, c
	ld	l, a
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	cp	a, 37
	.local	.LBB21_149
.LBB21_149:                             ;   in Loop: Header=BB21_97 Depth=1
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	e, a
	ld	a, l
	or	a, e
	ld	l, a
	ld	e, 1
	ld	a, l
	and	a, e
	ld	c, a
	.local	.LBB21_150
.LBB21_150:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -136
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	ld	(hl), c
	ld	a, c
	ld	(_render_layers+2628), a
	ld	de, -133
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	jr	z, .LBB21_154
; %bb.151:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	iy, _render_benchmark+78
	ld	hl, (iy)
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	pop	ix
	add.sis	hl, de
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, c
	or	a, a
	ld	de, 80
	jr	z, .LBB21_153
; %bb.152:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	de, 82
	.local	.LBB21_153
.LBB21_153:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	hl, _render_benchmark
	add	hl, de
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	.local	.LBB21_154
.LBB21_154:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -154
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 46
	push	de
	pop	bc
	call	__imulu
	ex	de, hl
	ld	hl, _portals
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 44)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 100), hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	hl, (ix + 6)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 115)
	push	hl
	call	_transform_portal_point
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	hl, (ix - 106)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	iy, (ix - 115)
	pea	iy + 9
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	hl, (ix - 121)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	iy, (ix - 115)
	pea	iy + 18
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	iy, (ix - 115)
	pea	iy + 27
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 100)
	ld	bc, 46
	call	__imulu
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	a, (iy + 42)
	ld	(ix - 46), a
	ld	de, (ix - 118)
	ld	hl, (ix - 115)
	ld	bc, 37
	ldir
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 46
	call	__imulu
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	a, (iy + 44)
	or	a, a
	sbc	hl, hl
	ld	l, a
	call	__imulu
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	l, (iy + 43)
	ld	a, (_render_layers+2628)
	ld	c, a
	or	a, a
	jp	nz, .LBB21_156
; %bb.155:                              ;   in Loop: Header=BB21_97 Depth=1
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, (ix - 118)
	push	hl
	call	_render_camera
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	nz, .LBB21_229
	jp	.LBB21_235
	.local	.LBB21_156
.LBB21_156:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 97), l                    ; 1-byte Folded Spill
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	hl, (ix - 118)
	jp	z, .LBB21_163
; %bb.157:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 5
	jp	z, .LBB21_163
; %bb.158:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	(ix - 103), c                   ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB21_160
; %bb.159:                              ;   in Loop: Header=BB21_97 Depth=1
	push	bc
	pop	hl
	jr	.LBB21_162
	.local	.LBB21_160
.LBB21_160:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	hl, (-917472)
	ld	(ix - 100), hl
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	nc, .LBB21_162
; %bb.161:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	hl, (ix - 100)
	.local	.LBB21_162
.LBB21_162:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	bc, (_render_benchmark_last)
	ld	d, (ix - 94)                    ; 1-byte Folded Reload
	ld	e, d
	ld	iy, (ix - 109)
	ld	a, (iy)
	call	__lsub
	ld	(ix - 100), hl
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	iy, _render_benchmark
	add	iy, bc
	ld	hl, (iy)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), iy
	pop	ix
	lea	iy, iy + 3
	ld	e, (iy)
	ld	bc, (ix - 100)
	call	__ladd
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 5)
	pop	ix
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 112)
	ld	e, (iy)
	ld	bc, (ix - 100)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	bc, -136
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	(_render_benchmark_last), hl
	ld	a, d
	ld	(_render_benchmark_last+3), a
	ld	a, 5
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+50
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 118)
	ld	c, (ix - 103)                   ; 1-byte Folded Reload
	.local	.LBB21_163
.LBB21_163:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_active_render_width)
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	call	__ishru
	ld	(ix - 100), hl
	ld	a, (_active_render_height)
	ex	de, hl
	ld	l, a
	call	__ishru
	ex	de, hl
	ld	iy, _portal_lod_frame
	.local	.LBB21_164
.LBB21_164:                             ;   Parent Loop BB21_97 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB21_166
; %bb.165:                              ;   in Loop: Header=BB21_164 Depth=2
	ld	hl, (ix - 100)
	push	hl
	ld	hl, 1
	push	hl
	ld	bc, -133
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	push	iy
	ld	(ix - 103), de
	call	_memset
	ld	de, (ix - 103)
	pop	hl
	pop	hl
	pop	hl
	ld	bc, -133
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	lea	iy, iy + 32
	dec	de
	jr	.LBB21_164
	.local	.LBB21_166
.LBB21_166:                             ;   in Loop: Header=BB21_97 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 118)
	push	hl
	ld	hl, _render_layers+1318
	push	hl
	call	_collect_room_polygons
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_benchmark_active)
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	bit	0, a
	jp	z, .LBB21_173
; %bb.167:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 6
	jp	z, .LBB21_173
; %bb.168:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB21_170
; %bb.169:                              ;   in Loop: Header=BB21_97 Depth=1
	push	bc
	pop	hl
	jr	.LBB21_172
	.local	.LBB21_170
.LBB21_170:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB21_172
; %bb.171:                              ;   in Loop: Header=BB21_97 Depth=1
	ex	de, hl
	.local	.LBB21_172
.LBB21_172:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 100), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 94)                    ; 1-byte Folded Reload
	ld	iy, (ix - 109)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 97), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 97)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 112)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 100)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 94)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 6
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+52
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB21_173
.LBB21_173:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_layers+2623)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	a, (_render_layers+2628)
	ld	e, a
	ld	hl, 1
	ld	c, e
	call	__ishl
	ld	bc, -136
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, 255
	call	__iand
	push	hl
	pop	iy
	call	__ishru_1
	ld	(ix - 100), hl
	ld	a, (_active_render_width)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 97), e                    ; 1-byte Folded Spill
	ld	c, e
	call	__ishru
	dec	l
	push	ix
	lea	ix, ix - 128
	ld	(ix - 26), hl
	pop	ix
	ld	hl, (ix - 100)
	call	__inot
	push	hl
	pop	bc
	add	iy, bc
	ld	de, -151
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	a, (_render_layers+2634)
	ld	de, -158
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	hl, _render_layers+2632
	ld	hl, (hl)
	ld	de, -161
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	a, (_active_horizon_near_limit)
	ld	e, a
	ld	h, 0
	ld	d, h
	ld	bc, -163
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e
	ld	(iy + 1), d
	ld	a, (_active_horizon_far_limit)
	ld	e, a
	ld	bc, -148
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	d, h
	ld	bc, -165
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e
	ld	(iy + 1), d
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l                     ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	ld	bc, 0
	.local	.LBB21_174
.LBB21_174:                             ;   Parent Loop BB21_97 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB21_176 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB21_193
; %bb.175:                              ;   in Loop: Header=BB21_174 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	(iy + 0), de
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	push	bc
	pop	hl
	ld	bc, 151
	call	__imulu
	ex	de, hl
	ld	hl, _render_layers+1318
	push	hl
	pop	iy
	add	iy, de
	lea	hl, iy + 0
	ld	de, 149
	add	hl, de
	ld	c, (hl)
	ld	de, -133
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, 150
	add	iy, de
	.local	.LBB21_176
.LBB21_176:                             ;   Parent Loop BB21_97 Depth=1
                                        ;     Parent Loop BB21_174 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	a, (iy)
	cp	a, c
	jp	c, .LBB21_192
; %bb.177:                              ;   in Loop: Header=BB21_176 Depth=3
	ld	de, -145
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 5)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 29), de
	pop	ix
	add	iy, de
	ld	d, (iy + 48)
	ld	e, (iy + 96)
	push	af
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	ld	a, e
	cp	a, d
	jp	c, .LBB21_191
; %bb.178:                              ;   in Loop: Header=BB21_176 Depth=3
	ld	a, e
	ld	hl, (ix - 100)
	cp	a, l
	jp	c, .LBB21_191
; %bb.179:                              ;   in Loop: Header=BB21_176 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 41), c                    ; 1-byte Folded Spill
	pop	ix
	ld	bc, 0
	ld	c, d
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	add	hl, bc
	ld	c, iyl
	call	__ishru
	ld	bc, 255
	call	__iand
	push	ix
	lea	ix, ix - 128
	ld	(ix - 40), hl
	pop	ix
	ld	hl, (ix - 100)
	ld	a, l
	cp	a, d
	jr	c, .LBB21_181
; %bb.180:                              ;   in Loop: Header=BB21_176 Depth=3
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 40), hl
	pop	ix
	.local	.LBB21_181
.LBB21_181:                             ;   in Loop: Header=BB21_176 Depth=3
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	de, (ix - 100)
	sbc	hl, de
	ld	c, iyl
	call	__ishrs
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 26)
	pop	ix
	ld	a, e
	cp	a, l
	jr	c, .LBB21_183
; %bb.182:                              ;   in Loop: Header=BB21_176 Depth=3
	ld	a, l
	.local	.LBB21_183
.LBB21_183:                             ;   in Loop: Header=BB21_176 Depth=3
	ld	bc, -168
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	cp	a, e
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 41)                    ; 1-byte Folded Reload
	pop	ix
	jp	c, .LBB21_191
; %bb.184:                              ;   in Loop: Header=BB21_176 Depth=3
	or	a, a
	sbc	hl, hl
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 44), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	ld	c, iyl
	call	__ishru
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ex	de, hl
	add	hl, bc
	push	hl
	pop	bc
	ld	iy, _portal_lod_frame
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	ld	bc, 148
	add	hl, bc
	ld	a, (hl)
	ld	bc, 0
	ld	c, a
	ld	hl, _face_light_level
	add	hl, bc
	ld	e, (hl)
	cp	a, 2
	jp	nc, .LBB21_190
; %bb.185:                              ;   in Loop: Header=BB21_176 Depth=3
	ld	bc, -158
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)                         ; 1-byte Folded Reload
	or	a, a
	jp	z, .LBB21_190
; %bb.186:                              ;   in Loop: Header=BB21_176 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 41)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), l
	ld	(ix - 19), h
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 33)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 29), l
	ld	(ix - 28), h
	pop	ix
	add.sis	hl, hl
	sbc.sis	hl, hl
	ld	c, l
	ld	b, h
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 29)
	ld	h, (ix - 28)
	pop	ix
	add.sis	hl, bc
	call	__sxor
	push	ix
	lea	ix, ix - 128
	ld	(ix - 29), l
	ld	(ix - 28), h
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 35)
	ld	b, (ix - 34)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB21_188
; %bb.187:                              ;   in Loop: Header=BB21_176 Depth=3
	ld	l, -2
	jp	.LBB21_189
	.local	.LBB21_188
.LBB21_188:                             ;   in Loop: Header=BB21_176 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 29)
	ld	h, (ix - 28)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 37)
	ld	b, (ix - 36)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	.local	.LBB21_189
.LBB21_189:                             ;   in Loop: Header=BB21_176 Depth=3
	ld	a, e
	add	a, l
	ld	e, a
	.local	.LBB21_190
.LBB21_190:                             ;   in Loop: Header=BB21_176 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	ld	bc, 145
	add	hl, bc
	ld	a, (hl)
	add	a, e
	ld	c, a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 44)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 40)
	pop	ix
	or	a, a
	sbc	hl, de
	inc	hl
	push	hl
	push	bc
	push	iy
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	c, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB21_191
.LBB21_191:                             ;   in Loop: Header=BB21_176 Depth=3
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	a, c
	add	a, l
	ld	c, a
	ld	de, -145
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	jp	.LBB21_176
	.local	.LBB21_192
.LBB21_192:                             ;   in Loop: Header=BB21_174 Depth=2
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	inc	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	de, (iy + 0)
	jp	.LBB21_174
	.local	.LBB21_193
.LBB21_193:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_layers+2624)
	ld	e, a
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	cp	a, 1
	jp	nz, .LBB21_210
; %bb.194:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_layers+2625)
	ld	hl, _render_benchmark+76
	ld	hl, (hl)
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	.local	.LBB21_195
.LBB21_195:                             ;   Parent Loop BB21_97 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB21_205 Depth 3
	cp	a, e
	jp	c, .LBB21_228
; %bb.196:                              ;   in Loop: Header=BB21_195 Depth=2
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	iy, 0
	ld	(ix - 97), e                    ; 1-byte Folded Spill
	ld	iyl, e
	lea	de, iy + 0
	ld	hl, _render_layers+2526
	add	hl, de
	ld	c, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	e, c
	ld	d, b
	ld	c, (hl)
	ld	a, c
	cp	a, e
	jr	nc, .LBB21_198
; %bb.197:                              ;   in Loop: Header=BB21_195 Depth=2
	ld	e, (ix - 97)                    ; 1-byte Folded Reload
	jp	.LBB21_209
	.local	.LBB21_198
.LBB21_198:                             ;   in Loop: Header=BB21_195 Depth=2
	bit	0, (ix - 103)                   ; 1-byte Folded Reload
	jp	z, .LBB21_200
; %bb.199:                              ;   in Loop: Header=BB21_195 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	pop	ix
	ld	d, h
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), e
	ld	(ix - 7), d
	pop	ix
	ld	b, h
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	inc.sis	hl
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
                                        ; kill: def $hl killed $hl def $uhl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), c
	ld	(ix - 13), b
	pop	ix
	add.sis	hl, bc
	ex	de, hl
	ld	hl, _render_benchmark+76
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), de
	pop	ix
	ld	(hl), e
	inc	hl
	ld	(hl), d
	jr	.LBB21_201
	.local	.LBB21_200
.LBB21_200:                             ;   in Loop: Header=BB21_195 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), c
	ld	(ix - 13), b
	pop	ix
	ld	bc, -136
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e
	inc	hl
	ld	(hl), d
	dec	hl
	.local	.LBB21_201
.LBB21_201:                             ;   in Loop: Header=BB21_195 Depth=2
	lea	hl, iy + 0
	add	hl, hl
	ex	de, hl
	ld	hl, _low_row_offsets
	add	hl, de
	ld	de, (hl)
	ld	bc, 0
	push	bc
	pop	hl
	ld	l, e
	ld	h, d
	push	bc
	pop	de
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 8)
	ld	b, (ix - 7)
	pop	ix
	ld	e, c
	add	hl, de
	push	hl
	pop	bc
	ld	hl, _low_frame+2
	add	hl, bc
	ld	(ix - 100), hl
	lea	hl, iy + 0
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	bc, 4064
	call	__iand
	push	hl
	pop	bc
	ex	de, hl
	call	__ishru_1
	add	hl, bc
	ex	de, hl
	ld	hl, _portal_lod_frame
	push	hl
	pop	iy
	add	iy, de
	ld	e, 1
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	pop	ix
	ld	a, l
	and	a, e
	ld	e, a
	bit	0, e
	jr	nz, .LBB21_203
; %bb.202:                              ;   in Loop: Header=BB21_195 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	pop	ix
	jr	.LBB21_204
	.local	.LBB21_203
.LBB21_203:                             ;   in Loop: Header=BB21_195 Depth=2
	ld	a, (iy)
	inc	iy
	ld	hl, (ix - 100)
	ld	(hl), a
	inc	hl
	ld	(ix - 100), hl
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	ld	h, (ix - 7)
	pop	ix
	inc	l
	.local	.LBB21_204
.LBB21_204:                             ; %.preheader181
                                        ;   in Loop: Header=BB21_195 Depth=2
	ld	e, (ix - 97)                    ; 1-byte Folded Reload
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 14)
	ld	b, (ix - 13)
	pop	ix
	.local	.LBB21_205
.LBB21_205:                             ;   Parent Loop BB21_97 Depth=1
                                        ;     Parent Loop BB21_195 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	a, l
	cp	a, c
	jr	nc, .LBB21_207
; %bb.206:                              ;   in Loop: Header=BB21_205 Depth=3
	ld	a, (iy)
	inc	iy
	lea	bc, iy + 0
	ld	iy, (ix - 100)
	ld	(iy), a
	lea	de, iy + 2
	ld	(iy + 1), a
	push	bc
	pop	iy
	ld	c, 2
	ld	a, l
	add	a, c
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 14)
	ld	b, (ix - 13)
	pop	ix
	ld	(ix - 100), de
	ld	e, (ix - 97)                    ; 1-byte Folded Reload
	jr	.LBB21_205
	.local	.LBB21_207
.LBB21_207:                             ;   in Loop: Header=BB21_195 Depth=2
	ld	a, c
	cp	a, l
	jr	c, .LBB21_209
; %bb.208:                              ;   in Loop: Header=BB21_195 Depth=2
	ld	a, (iy)
	ld	hl, (ix - 100)
	ld	(hl), a
	.local	.LBB21_209
.LBB21_209:                             ;   in Loop: Header=BB21_195 Depth=2
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	inc	e
	jp	.LBB21_195
	.local	.LBB21_210
.LBB21_210:                             ; %.preheader
                                        ;   Parent Loop BB21_97 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB21_217 Depth 3
                                        ;       Child Loop BB21_221 Depth 3
	ld	a, (_render_layers+2625)
	cp	a, e
	jp	c, .LBB21_228
; %bb.211:                              ;   in Loop: Header=BB21_210 Depth=2
	ld	bc, 0
	ld	c, e
	ld	hl, _render_layers+2526
	add	hl, bc
	ld	l, (hl)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	hl, _render_layers+2574
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), bc
	pop	ix
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	a, (hl)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	(iy + 1), h
	cp	a, l
	jp	c, .LBB21_227
; %bb.212:                              ;   in Loop: Header=BB21_210 Depth=2
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	(ix - 97), e                    ; 1-byte Folded Spill
	bit	0, (ix - 103)                   ; 1-byte Folded Reload
	jp	z, .LBB21_214
; %bb.213:                              ;   in Loop: Header=BB21_210 Depth=2
	ld	de, -148
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)
	ld	d, (iy + 1)
	ld	d, h
                                        ; kill: def $h killed $h killed $hl def $hl
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	ld	iy, _render_benchmark+76
	ld	bc, (iy)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), e
	ld	(ix - 4), d
	pop	ix
	or	a, a
	sbc.sis	hl, de
	add.sis	hl, bc
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB21_214
.LBB21_214:                             ;   in Loop: Header=BB21_210 Depth=2
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, hl
	ex	de, hl
	ld	hl, _low_row_offsets
	add	hl, de
	ld	de, (hl)
	ld	iy, 0
	lea	hl, iy + 0
	ld	l, e
	ld	h, d
	lea	de, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
	ld	c, (iy + 0)
	ld	b, (iy + 1)
	ld	e, c
	add	hl, de
	push	hl
	pop	bc
	ld	iy, _low_frame+2
	add	iy, bc
	ld	(ix - 100), iy
	ld	bc, -136
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	bc, 2016
	call	__iand
	push	hl
	pop	iy
	ex	de, hl
	ld	c, 2
	call	__ishru
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 5)
	ld	b, (ix - 4)
	pop	ix
	lea	de, iy + 0
	add	hl, de
	ex	de, hl
	ld	iy, _portal_lod_frame
	add	iy, de
	ld	l, 3
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), iy
	pop	ix
	jr	nz, .LBB21_216
; %bb.215:                              ;   in Loop: Header=BB21_210 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	iy, (ix - 100)
	jr	.LBB21_220
	.local	.LBB21_216
.LBB21_216:                             ;   in Loop: Header=BB21_210 Depth=2
	ld	e, (iy)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 14
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	iy, (ix - 100)
	.local	.LBB21_217
.LBB21_217:                             ;   Parent Loop BB21_97 Depth=1
                                        ;     Parent Loop BB21_210 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	(iy), e
	inc	iy
	inc	c
	ld	a, d
	cp	a, c
	jr	c, .LBB21_219
; %bb.218:                              ;   in Loop: Header=BB21_217 Depth=3
	ld	(ix - 100), iy
	ld	iyl, c
	ld	iyh, b
	ld	c, l
	inc	c
	ld	a, l
	cp	a, 3
	ld	l, c
	ld	c, iyl
	ld	b, iyh
	ld	iy, (ix - 100)
	jr	c, .LBB21_217
	.local	.LBB21_219
.LBB21_219:                             ;   in Loop: Header=BB21_210 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 8)
	pop	ix
	inc	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), hl
	pop	ix
	.local	.LBB21_220
.LBB21_220:                             ;   in Loop: Header=BB21_210 Depth=2
	inc	c
	inc	iy
	.local	.LBB21_221
.LBB21_221:                             ;   Parent Loop BB21_97 Depth=1
                                        ;     Parent Loop BB21_210 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	(ix - 100), iy
	ld	e, c
	dec	e
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	iyl, c
	ld	iyh, b
	ld	bc, 3
	add	hl, bc
	push	hl
	pop	bc
	or	a, a
	sbc	hl, hl
	ld	l, d
	sbc	hl, bc
	jr	c, .LBB21_223
; %bb.222:                              ;   in Loop: Header=BB21_221 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 8)
	pop	ix
	ld	a, (hl)
	inc	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), hl
	pop	ix
	ld	c, iyl
	ld	b, iyh
	ld	iy, (ix - 100)
	ld	(iy - 1), a
	ld	(iy), a
	ld	(iy + 1), a
	ld	(iy + 2), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	ld	d, (hl)
	ld	l, 4
	ld	a, c
	add	a, l
	ld	c, a
	lea	iy, iy + 4
	jr	.LBB21_221
	.local	.LBB21_223
.LBB21_223:                             ;   in Loop: Header=BB21_210 Depth=2
	ld	a, d
	cp	a, e
	ld	e, (ix - 97)                    ; 1-byte Folded Reload
	jp	c, .LBB21_227
; %bb.224:                              ;   in Loop: Header=BB21_210 Depth=2
	inc	d
	ld	a, d
	ld	l, d
	ld	e, iyl
	ld	d, iyh
	cp	a, e
	ld	a, e
	jr	c, .LBB21_226
; %bb.225:                              ;   in Loop: Header=BB21_210 Depth=2
	ld	a, l
	.local	.LBB21_226
.LBB21_226:                             ;   in Loop: Header=BB21_210 Depth=2
	ld	iy, (ix - 100)
	dec	iy
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 8)
	pop	ix
	ld	l, (hl)
	sub	a, e
	ld	e, a
	ld	bc, 0
	ld	c, e
	inc	bc
	push	bc
                                        ; kill: def $l killed $l def $uhl
	push	hl
	push	iy
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	ld	e, (ix - 97)                    ; 1-byte Folded Reload
	.local	.LBB21_227
.LBB21_227:                             ;   in Loop: Header=BB21_210 Depth=2
	inc	e
	jp	.LBB21_210
	.local	.LBB21_228
.LBB21_228:                             ; %.loopexit
                                        ;   in Loop: Header=BB21_97 Depth=1
	bit	0, (ix - 103)                   ; 1-byte Folded Reload
	jp	z, .LBB21_235
	.local	.LBB21_229
.LBB21_229:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 6
	jp	z, .LBB21_235
; %bb.230:                              ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	de, (-917472)
	ld	bc, (-917472)
	push	bc
	pop	hl
	push	de
	pop	iy
	or	a, a
	sbc	hl, de
	ld	de, 2
	or	a, a
	sbc	hl, de
	jr	nc, .LBB21_232
; %bb.231:                              ;   in Loop: Header=BB21_97 Depth=1
	push	bc
	pop	hl
	jr	.LBB21_234
	.local	.LBB21_232
.LBB21_232:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB21_234
; %bb.233:                              ;   in Loop: Header=BB21_97 Depth=1
	ex	de, hl
	.local	.LBB21_234
.LBB21_234:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	(ix - 100), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 94)                    ; 1-byte Folded Reload
	ld	iy, (ix - 109)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 97), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 97)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+60)
	ld	iy, (ix - 112)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+60), hl
	ld	(_render_benchmark+63), a
	ld	hl, (ix - 100)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 94)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 6
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+52
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB21_235
.LBB21_235:                             ;   in Loop: Header=BB21_97 Depth=1
	ld	de, 145
	ld	hl, (ix - 91)
	add	hl, de
	ld	b, (hl)
	ld	a, (_render_layers+2624)
	ld	l, a
	ld	a, (_render_layers+2625)
	ld	(ix - 97), hl
	ld	c, l
	ld	iy, 0
	ld	(ix - 91), b
	.local	.LBB21_236
.LBB21_236:                             ;   Parent Loop BB21_97 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	cp	a, c
	jr	c, .LBB21_240
; %bb.237:                              ;   in Loop: Header=BB21_236 Depth=2
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	iyl, c
	lea	de, iy + 0
	ld	hl, _render_layers+2526
	add	hl, de
	ld	b, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	a, (hl)
	cp	a, b
	jr	c, .LBB21_239
; %bb.238:                              ;   in Loop: Header=BB21_236 Depth=2
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 103), hl
	ld	de, 0
	ld	e, b
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), de
	pop	ix
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _low_row_offsets
	add	hl, de
	ld	hl, (hl)
	ld	iy, 0
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	lea	hl, iy + 0
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 5)
	pop	ix
	add	hl, de
	ex	de, hl
	ld	hl, _low_frame+2
	add	hl, de
	ld	a, (ix - 91)                    ; 1-byte Folded Reload
	ld	(hl), a
	ld	de, (ix - 103)
	add	iy, de
	lea	de, iy + 0
	ld	hl, _low_frame+2
	add	hl, de
	ld	(hl), a
	.local	.LBB21_239
.LBB21_239:                             ;   in Loop: Header=BB21_236 Depth=2
	inc	c
	ld	iy, 0
	ld	b, (ix - 91)                    ; 1-byte Folded Reload
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	jr	.LBB21_236
	.local	.LBB21_240
.LBB21_240:                             ;   in Loop: Header=BB21_97 Depth=1
	lea	de, iy + 0
	ld	hl, (ix - 97)
	ld	e, l
	ld	hl, _render_layers+2526
	add	hl, de
	ld	a, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	l, (hl)
	ld	e, b
	push	de
	lea	de, iy + 0
	ld	e, l
	push	de
	ld	iyl, a
	push	iy
	ld	hl, (ix - 97)
	push	hl
	call	_write_frame_span
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_layers+2625)
	ld	e, a
	ld	a, (_render_layers+2624)
	ld	l, a
	ld	a, e
	cp	a, l
	ld	iy, 0
	ld	bc, (ix - 88)
	jr	z, .LBB21_242
; %bb.241:                              ;   in Loop: Header=BB21_97 Depth=1
	push	de
	pop	iy
	ld	de, 0
	ld	e, iyl
	ld	hl, _render_layers+2526
	add	hl, de
	ld	a, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	l, (hl)
	ld	c, (ix - 91)                    ; 1-byte Folded Reload
	push	bc
	ld	e, l
	push	de
	ld	e, a
	push	de
	push	iy
	call	_write_frame_span
	ld	bc, (ix - 88)
	ld	iy, 0
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB21_242
.LBB21_242:                             ;   in Loop: Header=BB21_97 Depth=1
	inc	bc
	jp	.LBB21_97
	.local	.LBB21_243
.LBB21_243:                             ; %.loopexit85
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB21_244
.LBB21_244:
	ld	de, (ix - 85)
	push	de
	pop	hl
	add	hl, bc
	ld	a, (hl)
	ld	l, a
	ld	(ix - 88), hl
	ld	iy, 0
	.local	.LBB21_245
.LBB21_245:                             ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	ld	bc, 1307
	add	hl, bc
	ld	a, (hl)
	ld	hl, (ix - 88)
	cp	a, l
	jp	c, .LBB21_25
; %bb.246:                              ;   in Loop: Header=BB21_245 Depth=1
	lea	bc, iy + 0
	ld	hl, (ix - 88)
	ld	c, l
	push	de
	pop	iy
	add	iy, bc
	lea	hl, iy + 0
	ld	de, 1208
	add	hl, de
	ld	l, (hl)
	ld	de, 1256
	add	iy, de
	ld	a, (iy)
	cp	a, l
	ld	de, 1
	push	de
	ld	bc, 0
	push	bc
	pop	de
	ld	e, a
	push	de
	push	bc
	pop	de
	ld	e, l
	push	de
	ld	hl, (ix - 88)
	push	hl
	call	nc, _write_frame_span
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	inc	(ix - 88)
	ld	iy, 0
	ld	de, (ix - 85)
	jr	.LBB21_245
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_render_camera, .Lfunc_end21-_render_camera
                                        ; -- End function
	.section	.text._collect_room_polygons,"ax",@progbits
	.type	_collect_room_polygons,@function ; -- Begin function collect_room_polygons
_collect_room_polygons:                 ; @collect_room_polygons
; %bb.0:
	ld	hl, -173
	call	__frameset
	ld	hl, _rooms
	ld	(ix - 112), hl
	lea	hl, ix - 42
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	lea	hl, ix - 51
	ld	(ix - 124), hl
	lea	hl, ix - 63
	ld	de, -163
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	iy, (ix + 9)
	ld	a, (iy + 36)
	or	a, a
	sbc	hl, hl
	ld	(ix - 127), a                   ; 1-byte Folded Spill
	ld	l, a
	ld	bc, 13
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 112)
	add	hl, de
	ld	(ix - 112), hl
	ld	(ix - 63), b
	ld	de, -163
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	pop	iy
	inc	iy
	lea	de, iy + 0
	ld	iy, (ix + 9)
	ld	bc, 5
	ldir
	ld	de, 1304
	ld	hl, (ix + 6)
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 32), hl
	pop	ix
	ld	(hl), 0
	ld	de, (iy + 15)
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 118), de
	ex	de, hl
	add	hl, bc
	call	__ixor
	ld	de, 9
	or	a, a
	sbc	hl, de
	ld	de, 1316
	jp	nc, .LBB22_7
; %bb.1:
	ld	iy, (iy + 24)
	ld	(ix - 103), iy
	ld	a, (ix - 101)
	rlc	a
	sbc	a, a
	ld	de, -136
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a                         ; 1-byte Folded Spill
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	lea	hl, iy + 0
	add	hl, bc
	call	__ixor
	push	hl
	pop	de
	ld	bc, 64
	or	a, a
	sbc	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	ld	hl, (ix + 6)
	ld	bc, 1316
	add	hl, bc
	ld	(hl), a
	push	de
	pop	hl
	ld	bc, 64
	or	a, a
	sbc	hl, bc
	ld	bc, -133
	lea	hl, ix + 0
	push	af
	add	hl, bc
	pop	af
	ld	(hl), iy
	jp	c, .LBB22_8
; %bb.2:
	ld	(ix - 121), de
	lea	bc, iy + 0
	ld	iy, (ix + 9)
	ld	hl, (iy + 33)
	push	hl
	pop	de
	call	__ineg
	push	hl
	pop	iy
	push	bc
	pop	hl
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB22_4
; %bb.3:
	push	de
	pop	iy
	.local	.LBB22_4
.LBB22_4:
	ld	(ix - 109), iy
	ld	(ix - 100), iy
	ld	a, (ix - 98)
	rlc	a
	sbc	a, a
	ld	(ix - 115), a                   ; 1-byte Folded Spill
	ld	hl, (ix - 121)
	push	hl
	call	_projection_scale_for_depth
	pop	de
	xor	a, a
	ld	(ix - 97), a
	ld	bc, (ix - 99)
	ld	b, h
	ld	c, l
	sbc	hl, hl
	ld	e, l
	push	bc
	pop	hl
	ld	bc, (ix - 109)
	ld	a, (ix - 115)                   ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 14
	call	__lshru
	push	bc
	pop	iy
	ld.sis	de, 24
	add.sis	iy, de
	ld	a, (_active_render_shift)
	or	a, a
	jr	z, .LBB22_6
; %bb.5:
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	push	hl
	call	_half_projected
	push	hl
	pop	iy
	pop	hl
	.local	.LBB22_6
.LBB22_6:
	ld	de, 1314
	ld	hl, (ix + 6)
	add	hl, de
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	pop	de
	jr	.LBB22_8
	.local	.LBB22_7
.LBB22_7:
	ld	hl, (ix + 6)
	add	hl, de
	ld	(hl), 0
	ld	hl, (iy + 24)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	(ix - 106), hl
	ld	a, (ix - 104)
	rlc	a
	sbc	a, a
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB22_8
.LBB22_8:
	ld	iy, (ix - 112)
	ld	bc, (iy + 1)
	lea	de, iy + 0
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 109), hl
	ld	(ix - 42), hl
	ld	iy, (iy + 5)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ld	(ix - 39), bc
	push	de
	pop	iy
	ld	de, (iy + 9)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 121), hl
	ld	(ix - 36), hl
	ld	de, (iy + 3)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 109)
	or	a, a
	sbc	hl, de
	ld	(ix - 115), hl
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc	hl, bc
	ld	(ix - 109), hl
	ld	de, (iy + 11)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 121)
	or	a, a
	sbc	hl, de
	ld	(ix - 121), hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 9
	ldir
	ld	hl, (ix + 9)
	push	hl
	ld	hl, (ix - 124)
	push	hl
	call	_transform_point
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix + 9)
	ld	hl, (iy + 9)
	ld	bc, (ix - 115)
	ld	(ix - 96), bc
	ld	a, (ix - 94)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	(ix - 93), hl
	ld	a, (ix - 91)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 18)
	ld	(ix - 90), hl
	ld	a, (ix - 88)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 115)
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 23
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 27)
	ld	(ix - 87), hl
	ld	a, (ix - 85)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 115)
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	de, -166
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 12)
	ld	bc, (ix - 109)
	ld	(ix - 84), bc
	ld	a, (ix - 82)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	(ix - 81), hl
	ld	a, (ix - 79)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 2
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 21)
	ld	(ix - 78), hl
	ld	a, (ix - 76)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 109)
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 17
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 30)
	ld	(ix - 75), hl
	ld	a, (ix - 73)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 109)
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	iyl, 8
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	call	__lshru
	ld	de, -148
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	ld	iy, (ix - 121)
	ld	(ix - 72), iy
	ld	a, (ix - 70)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	bc, (ix - 118)
	ld	(ix - 69), bc
	ld	a, (ix - 67)
	rlc	a
	sbc	a, a
	lea	hl, iy + 0
	ld	e, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	(ix - 115), bc
	lea	hl, iy + 0
	ld	e, d
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	(ix - 118), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 33)
	ld	(ix - 66), hl
	ld	a, (ix - 64)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 121)
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	(ix - 121), bc
	ld	a, (ix - 127)                   ; 1-byte Folded Reload
	ld	b, 3
	call	__bshl
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	l, 8
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	add	a, l
	ld	l, a
	dec	de
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB22_10
; %bb.9:
	ld	iy, _render_benchmark+64
	ld.sis	de, 8
	ld	hl, (iy)
	add.sis	hl, de
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB22_10
.LBB22_10:
	ld	bc, 9
	ld	de, -136
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	hl, iy + 0
	call	__imulu
	ex	de, hl
	ld	hl, _camera_vertices
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 124)
	ldir
	lea	de, iy + 0
	inc	de
	ex	de, hl
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	(ix - 109), iy
	ld	iy, (ix - 51)
	ld	de, -157
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	hl, (ix - 48)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	ld	de, (ix - 45)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), de
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 11)
	pop	ix
	add	iy, de
	ld	(ix - 124), iy
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 23)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	de, -154
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 38)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	hl, (ix - 109)
	ld	(hl), iy
	push	hl
	pop	iy
	ld	(iy + 3), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	ld	(iy + 6), hl
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	(ix - 109), hl
	ld	de, 3
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 2)
	pop	ix
	add	hl, de
	ld	(ix - 127), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 17)
	pop	ix
	add	hl, de
	ex	de, hl
	ld	bc, -166
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 20)
	pop	ix
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), hl
	pop	ix
	ld	hl, (ix - 127)
	ld	(iy), hl
	ld	(iy + 3), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	ld	(iy + 6), hl
	ld	hl, (ix - 109)
	ld	de, 2
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	hl, (ix - 124)
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 2)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 26)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 17)
	pop	ix
	add	hl, de
	ex	de, hl
	ld	bc, -173
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 20)
	pop	ix
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	ld	(iy), hl
	ld	(iy + 3), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 17)
	pop	ix
	ld	(iy + 6), hl
	ld	hl, (ix - 109)
	ld	de, 4
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	ld	de, (ix - 115)
	add	hl, de
	ex	de, hl
	ld	bc, (ix - 118)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	ld	bc, (ix - 121)
	add	hl, bc
	ld	(iy), de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 5)
	pop	ix
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	hl, (ix - 109)
	ld	de, 5
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	ld	hl, (ix - 124)
	add	hl, de
	ld	(ix - 124), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 26)
	pop	ix
	ld	bc, (ix - 118)
	add	hl, bc
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	ld	bc, (ix - 121)
	add	hl, bc
	ld	bc, (ix - 124)
	ld	(iy), bc
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	hl, (ix - 109)
	ld	de, 7
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	ld	hl, (ix - 127)
	add	hl, de
	ld	(ix - 127), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 38)
	pop	ix
	ld	bc, (ix - 118)
	add	hl, bc
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 23)
	pop	ix
	ld	bc, (ix - 121)
	add	hl, bc
	ld	bc, (ix - 127)
	ld	(iy), bc
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	de, 6
	ld	hl, (ix - 109)
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 45)
	pop	ix
	ld	bc, (ix - 118)
	add	hl, bc
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 17)
	pop	ix
	ld	bc, (ix - 121)
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 2)
	pop	ix
	ld	(iy), bc
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	de, -170
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	inc	de
	lea	iy, ix + 0
	add	iy, de
	ld	c, (iy + 0)                     ; 1-byte Folded Reload
	cp	a, c
	jr	c, .LBB22_12
; %bb.11:
	ld	c, a
	.local	.LBB22_12
.LBB22_12:
	xor	a, a
	ld	(ix - 124), a
	lea	hl, ix - 42
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	lea	hl, ix - 57
	ld	(ix - 127), hl
	ld	iy, 0
	ld	iyl, c
	ld	bc, -136
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	push	de
	pop	hl
	ld	bc, 9
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _camera_vertices
	add	hl, bc
	ld	(ix - 115), hl
	ld	hl, _vertex_projectable
	add	hl, de
	ld	(ix - 118), hl
	push	de
	pop	hl
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _screen_vertices
	add	hl, bc
	ld	(ix - 121), hl
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	.local	.LBB22_13
.LBB22_13:                              ; =>This Inner Loop Header: Depth=1
	ld	(ix - 109), hl
	ld	hl, (ix - 109)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB22_19
; %bb.14:                               ;   in Loop: Header=BB22_13 Depth=1
	ld	iy, (ix - 115)
	ld	de, (iy + 6)
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	a, 1
	jp	p, .LBB22_16
; %bb.15:                               ;   in Loop: Header=BB22_13 Depth=1
	ld	a, 0
	.local	.LBB22_16
.LBB22_16:                              ;   in Loop: Header=BB22_13 Depth=1
	ld	hl, (ix - 118)
	ld	(hl), a
	ex	de, hl
	ld	de, 32
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB22_18
; %bb.17:                               ;   in Loop: Header=BB22_13 Depth=1
	ld	hl, (ix - 115)
	push	hl
	ld	hl, (ix - 127)
	push	hl
	call	_project_camera_point
	pop	hl
	pop	hl
	ld	de, (ix - 121)
	ld	hl, (ix - 127)
	ld	bc, 6
	ldir
	.local	.LBB22_18
.LBB22_18:                              ;   in Loop: Header=BB22_13 Depth=1
	ld	iy, (ix - 115)
	lea	iy, iy + 9
	ld	(ix - 115), iy
	ld	hl, (ix - 118)
	inc	hl
	ld	(ix - 118), hl
	ld	iy, (ix - 121)
	lea	iy, iy + 6
	ld	(ix - 121), iy
	ld	hl, (ix - 109)
	dec	hl
	jr	.LBB22_13
	.local	.LBB22_19
.LBB22_19:
	xor	a, a
	ld	(ix - 109), a                   ; 1-byte Folded Spill
	ld	de, 0
	ld	bc, 6
	.local	.LBB22_20
.LBB22_20:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB22_24 Depth 2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB22_39
; %bb.21:                               ;   in Loop: Header=BB22_20 Depth=1
	ld	hl, (ix - 112)
	ld	a, (hl)
	ld	(ix - 115), a                   ; 1-byte Folded Spill
	add	a, e
	ld	h, a
	ld	l, (ix + 12)
	cp	a, l
	jp	z, .LBB22_38
; %bb.22:                               ;   in Loop: Header=BB22_20 Depth=1
	ld	(ix - 118), de
	ld	a, h
	or	a, a
	sbc	hl, hl
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	l, a
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _world_faces
	add	hl, bc
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -160
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	a, (hl)
	cp	a, 8
	ld	l, 0
	ld	c, l
	jp	nc, .LBB22_37
; %bb.23:                               ;   in Loop: Header=BB22_20 Depth=1
	ld	iy, 0
	ld	iyl, a
	lea	hl, iy + 0
	ld	bc, 151
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix + 6)
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	ld	l, (ix - 109)
	ld	a, (ix - 115)
	add	a, l
	ld	e, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	bc, 6
	call	__imulu
	ex	de, hl
	ld	hl, _world_faces
	add	hl, de
	ld	(ix - 115), hl
	lea	hl, iy + 0
	ld	bc, 151
	call	__imulu
	ld	(ix - 121), hl
	or	a, a
	sbc	hl, hl
	ld	iyl, b
	.local	.LBB22_24
.LBB22_24:                              ;   Parent Loop BB22_20 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	hl
	pop	bc
	ld	de, 36
	or	a, a
	sbc	hl, de
	jp	z, .LBB22_29
; %bb.25:                               ;   in Loop: Header=BB22_24 Depth=2
	push	af
	ld	a, iyl
	ld	(ix - 127), a                   ; 1-byte Folded Spill
	pop	af
	ld	hl, (ix - 115)
	ld	a, (hl)
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	add	hl, bc
	ld	de, -145
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	iy, 0
	ld	iyl, a
	lea	hl, iy + 0
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	hl, _camera_vertices
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 17)
	pop	ix
	ldir
	lea	bc, iy + 0
	ld	hl, _vertex_projectable
	add	hl, bc
	ld	a, (hl)
	or	a, a
	jr	nz, .LBB22_27
; %bb.26:                               ;   in Loop: Header=BB22_24 Depth=2
	ld	bc, 6
	jr	.LBB22_28
	.local	.LBB22_27
.LBB22_27:                              ;   in Loop: Header=BB22_24 Depth=2
	ld	iy, (ix + 6)
	ld	de, (ix - 121)
	add	iy, de
	push	bc
	pop	hl
	ld	de, 6
	push	de
	pop	bc
	call	__imulu
	ex	de, hl
	ld	hl, _screen_vertices
	add	hl, de
	lea	de, iy + 0
	ld	iy, 6
	lea	bc, iy + 0
	ldir
	lea	bc, iy + 0
	inc	(ix - 127)
	.local	.LBB22_28
.LBB22_28:                              ;   in Loop: Header=BB22_24 Depth=2
	ld	hl, (ix - 115)
	inc	hl
	ld	(ix - 115), hl
	ld	de, -142
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	de, 9
	add	iy, de
	ld	hl, (ix - 121)
	add	hl, bc
	ld	(ix - 121), hl
	lea	hl, iy + 0
	push	af
	ld	a, (ix - 127)                   ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	jp	.LBB22_24
	.local	.LBB22_29
.LBB22_29:                              ;   in Loop: Header=BB22_20 Depth=1
	ld	a, iyl
	or	a, a
	ld	de, -133
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	ld	bc, (hl)
	jr	nz, .LBB22_31
; %bb.30:                               ;   in Loop: Header=BB22_20 Depth=1
	ld	c, iyl
	jp	.LBB22_37
	.local	.LBB22_31
.LBB22_31:                              ;   in Loop: Header=BB22_20 Depth=1
	ld	a, iyl
	cp	a, 4
	jr	nz, .LBB22_33
; %bb.32:                               ;   in Loop: Header=BB22_20 Depth=1
	push	bc
	pop	hl
	ld	de, 144
	add	hl, de
	ld	(hl), 4
	jr	.LBB22_34
	.local	.LBB22_33
.LBB22_33:                              ;   in Loop: Header=BB22_20 Depth=1
	push	bc
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_clip_and_project
	pop	hl
	pop	hl
	or	a, a
	ld	a, 0
	ld	c, a
	jp	z, .LBB22_37
	.local	.LBB22_34
.LBB22_34:                              ;   in Loop: Header=BB22_20 Depth=1
	ld	hl, (ix + 6)
	push	hl
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_polygon_intersects_layer
	pop	hl
	pop	hl
	or	a, a
	ld	a, 0
	ld	c, a
	jr	z, .LBB22_37
; %bb.35:                               ;   in Loop: Header=BB22_20 Depth=1
	ld	de, -139
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 4)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	push	bc
	pop	hl
	ld	de, 145
	add	hl, de
	ld	(hl), a
	push	bc
	pop	hl
	inc	de
	add	hl, de
	ld	(hl), -1
	push	bc
	pop	hl
	inc	de
	add	hl, de
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)
	ld	(hl), a
	push	bc
	pop	hl
	ld	de, 148
	add	hl, de
	ld	de, (ix - 118)
	ld	(hl), e
	ld	hl, (ix + 6)
	push	hl
	push	bc
	call	_rasterize_polygon
	pop	hl
	pop	hl
	or	a, a
	ld	a, 0
	ld	c, a
	jr	z, .LBB22_37
; %bb.36:                               ;   in Loop: Header=BB22_20 Depth=1
	ld	de, -160
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	(hl)
	ld	a, 1
	ld	c, a
	.local	.LBB22_37
.LBB22_37:                              ;   in Loop: Header=BB22_20 Depth=1
	ld	de, -163
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, (ix - 118)
	add	hl, de
	ld	(hl), c
	ld	bc, 6
	.local	.LBB22_38
.LBB22_38:                              ;   in Loop: Header=BB22_20 Depth=1
	inc	de
	inc	(ix - 109)
	jp	.LBB22_20
	.local	.LBB22_39
.LBB22_39:
	ld	de, -160
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	a, (hl)
	ld	de, 1305
	ld	hl, (ix + 6)
	add	hl, de
	ld	(hl), a
	ld	a, (ix + 15)
	or	a, a
	ld	bc, 0
	jr	nz, .LBB22_41
	.local	.LBB22_40
.LBB22_40:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB22_41
.LBB22_41:                              ; =>This Inner Loop Header: Depth=1
	ld	de, 92
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB22_40
; %bb.42:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	hl, _portals
	push	hl
	pop	iy
	add	iy, bc
	ld	(ix - 109), iy
	ld	a, (iy + 45)
	or	a, a
	jp	z, .LBB22_56
; %bb.43:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	iy, (ix - 109)
	ld	a, (iy + 44)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 115), bc
	ld	bc, 46
	call	__imulu
	ld	bc, (ix - 115)
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	a, (iy + 45)
	ld	iy, (ix + 9)
	or	a, a
	jp	z, .LBB22_56
; %bb.44:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	l, (iy + 36)
	lea	de, iy + 0
	ld	iy, (ix - 109)
	ld	a, (iy + 42)
	cp	a, l
	jp	nz, .LBB22_56
; %bb.45:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	iy, (ix - 109)
	ld	a, (iy + 43)
	push	de
	pop	iy
	ld	hl, (ix - 112)
	ld	l, (hl)
	cp	a, l
	jp	c, .LBB22_56
; %bb.46:                               ;   in Loop: Header=BB22_41 Depth=1
	sub	a, l
	ld	l, a
	cp	a, 6
	jp	nc, .LBB22_56
; %bb.47:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	de, 0
	ld	e, l
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 35)
	pop	ix
	add	hl, de
	ld	a, (hl)
	or	a, a
	jp	z, .LBB22_56
; %bb.48:                               ;   in Loop: Header=BB22_41 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 32)
	pop	ix
	ld	a, (hl)
	cp	a, 8
	jp	nc, .LBB22_55
; %bb.49:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	de, -142
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a                         ; 1-byte Folded Spill
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	hl, (ix - 109)
	ld	bc, 9
	ldir
	push	iy
	pea	ix - 42
	call	_transform_point
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 42)
	ld	(ix - 121), hl
	ld	hl, (ix - 39)
	ld	(ix - 118), hl
	ld	hl, (ix - 36)
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, _portals
	push	hl
	pop	iy
	ld	de, (ix - 115)
	add	iy, de
	ld	de, -130
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	lea	hl, iy + 9
	ld	de, (iy + 36)
	ld	(ix - 127), de
	push	de
	push	de
	push	de
	push	de
	ld	iy, 0
	add	iy, sp
	lea	de, iy + 0
	ld	bc, 9
	ldir
	ld	hl, (ix - 127)
	ld	(iy + 9), hl
	ld	hl, (ix + 9)
	push	hl
	pea	ix - 42
	call	_camera_axis_scaled
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 42)
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, (ix - 39)
	ld	(ix - 127), hl
	ld	hl, (ix - 36)
	ld	de, -157
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -130
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	hl, iy + 18
	ld	de, (iy + 39)
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	push	de
	push	de
	push	de
	push	de
	ld	iy, 0
	add	iy, sp
	lea	de, iy + 0
	ld	bc, 9
	ldir
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	ld	(iy + 9), hl
	ld	hl, (ix + 9)
	push	hl
	pea	ix - 42
	call	_camera_axis_scaled
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, (ix - 42)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	ld	hl, (ix - 39)
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	hl
	pop	iy
	ld	hl, (ix - 36)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	ld	hl, (ix - 121)
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 8)
	pop	ix
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), hl
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 38), hl
	pop	ix
	ld	hl, (ix - 118)
	ld	bc, (ix - 127)
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), hl
	pop	ix
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -151
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	hl, iy + 0
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 29)
	pop	ix
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 26), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 2)
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 38)
	pop	ix
	ld	(ix - 42), bc
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 41)
	pop	ix
	ld	(ix - 39), bc
	ld	(ix - 36), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 8)
	pop	ix
	ld	bc, (ix - 121)
	add	hl, bc
	ld	(ix - 121), hl
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 5)
	pop	ix
	or	a, a
	sbc	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), hl
	pop	ix
	ld	hl, (ix - 127)
	ld	bc, (ix - 118)
	add	hl, bc
	ld	(ix - 118), hl
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 11)
	pop	ix
	or	a, a
	sbc	hl, bc
	ld	(ix - 127), hl
	ex	de, hl
	lea	de, iy + 0
	add	hl, de
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	or	a, a
	sbc	hl, de
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	bc, (iy + 0)
	ld	(ix - 33), bc
	ld	bc, (ix - 127)
	ld	(ix - 30), bc
	ld	(ix - 27), hl
	ld	bc, -133
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	(ix - 127), iy
	ld	bc, (ix - 121)
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	ld	(ix - 121), hl
	ld	bc, (ix - 118)
	add	hl, bc
	push	hl
	pop	bc
	ld	(ix - 118), de
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 23)
	pop	ix
	add	hl, de
	ld	(ix - 24), iy
	ld	(ix - 21), bc
	ld	(ix - 18), hl
	ld	bc, -145
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	hl, (ix - 127)
	add	hl, de
	push	hl
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	de, (iy + 0)
	ld	iy, (ix - 121)
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 26)
	pop	ix
	ld	hl, (ix - 118)
	add	hl, de
	ld	(ix - 15), bc
	ld	(ix - 12), iy
	ld	(ix - 9), hl
	or	a, a
	sbc	hl, hl
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	ld	bc, 151
	call	__imulu
	ex	de, hl
	ld	hl, (ix + 6)
	add	hl, de
	ld	(ix - 118), hl
	push	hl
	pea	ix - 42
	call	_clip_and_project
	ld	de, (ix + 6)
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB22_55
; %bb.50:                               ;   in Loop: Header=BB22_41 Depth=1
	push	de
	ld	hl, (ix - 118)
	push	hl
	call	_polygon_intersects_layer
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB22_55
; %bb.51:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	bc, (ix - 118)
	ld	hl, (ix - 115)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 1
	jr	z, .LBB22_53
; %bb.52:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	a, 0
	.local	.LBB22_53
.LBB22_53:                              ;   in Loop: Header=BB22_41 Depth=1
	ld	l, 10
	add	a, l
	ld	iyl, a
	push	bc
	pop	de
	push	de
	pop	hl
	ld	bc, 145
	add	hl, bc
	ld	(hl), a
	push	de
	pop	bc
	push	bc
	pop	hl
	ld	de, 146
	add	hl, de
	ld	a, (ix - 124)
	ld	(hl), a
	ld	iy, (ix - 109)
	ld	a, (iy + 43)
	push	bc
	pop	hl
	inc	de
	add	hl, de
	ld	(hl), a
	push	bc
	pop	hl
	inc	de
	add	hl, de
	ld	(hl), -1
	ld	hl, (ix + 6)
	push	hl
	push	bc
	call	_rasterize_polygon
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB22_55
; %bb.54:                               ;   in Loop: Header=BB22_41 Depth=1
	ld	de, -160
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	(hl)
	.local	.LBB22_55
.LBB22_55:                              ;   in Loop: Header=BB22_41 Depth=1
	ld	bc, (ix - 115)
	.local	.LBB22_56
.LBB22_56:                              ;   in Loop: Header=BB22_41 Depth=1
	push	bc
	pop	hl
	ld	de, 46
	add	hl, de
	inc	(ix - 124)
	push	hl
	pop	bc
	jp	.LBB22_41
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_collect_room_polygons, .Lfunc_end22-_collect_room_polygons
                                        ; -- End function
	.section	.text._write_frame_span,"ax",@progbits
	.type	_write_frame_span,@function     ; -- Begin function write_frame_span
_write_frame_span:                      ; @write_frame_span
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	bc, (ix + 9)
	ld	de, (ix + 12)
	ld	iy, 0
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_4
; %bb.1:
	lea	hl, iy + 0
	ld	l, c
	ld	h, b
	ld	(ix - 3), hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	ex.sis	de, hl
	inc.sis	de
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB23_3
; %bb.2:
	ld	hl, _render_benchmark+72
	ld	iy, _render_benchmark+74
	ld	bc, (hl)
	inc.sis	bc
	ld	(hl), c
	inc	hl
	ld	(hl), b
	lea	hl, iy + 0
	ld	hl, (hl)
	add.sis	hl, de
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, 0
	.local	.LBB23_3
.LBB23_3:
	lea	hl, iy + 0
	ld	l, (ix + 6)
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, _low_row_offsets
	add	hl, bc
	ld	hl, (hl)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	bc, (ix - 3)
	add	iy, bc
	lea	bc, iy + 0
	ld	iy, _low_frame+2
	add	iy, bc
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	push	hl
	ld	l, (ix + 15)
	push	hl
	push	iy
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB23_4
.LBB23_4:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_write_frame_span, .Lfunc_end23-_write_frame_span
                                        ; -- End function
	.section	.text._projection_scale_for_depth,"ax",@progbits
	.type	_projection_scale_for_depth,@function ; -- Begin function projection_scale_for_depth
_projection_scale_for_depth:            ; @projection_scale_for_depth
; %bb.0:
	call	__frameset0
	ld	de, (ix + 6)
	ld	bc, 8192
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB24_4
; %bb.1:
	ld	c, 5
	ex	de, hl
	call	__ishru
	push	hl
	pop	iy
	ld	de, 2047
	or	a, a
	sbc	hl, de
	jr	c, .LBB24_3
; %bb.2:
	ld	iy, 2047
	.local	.LBB24_3
.LBB24_3:
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _far_projection_scale_table
	jr	.LBB24_9
	.local	.LBB24_4
.LBB24_4:
	ld	c, 2
	push	de
	pop	hl
	call	__ishru
	push	hl
	pop	iy
	ld	bc, 2047
	or	a, a
	sbc	hl, bc
	jr	c, .LBB24_6
; %bb.5:
	ld	iy, 2047
	.local	.LBB24_6
.LBB24_6:
	ld	bc, 4
	ex	de, hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB24_8
; %bb.7:
	ld	iy, 1
	.local	.LBB24_8
.LBB24_8:
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _projection_scale_table
	.local	.LBB24_9
.LBB24_9:
	add	hl, de
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	pop	ix
	ret
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_projection_scale_for_depth, .Lfunc_end24-_projection_scale_for_depth
                                        ; -- End function
	.section	.text._half_projected,"ax",@progbits
	.type	_half_projected,@function       ; -- Begin function half_projected
_half_projected:                        ; @half_projected
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	call	__ishrs_1
	pop	ix
	ret
	.local	.Lfunc_end25
.Lfunc_end25:
	.size	_half_projected, .Lfunc_end25-_half_projected
                                        ; -- End function
	.section	.text._transform_point,"ax",@progbits
	.type	_transform_point,@function      ; -- Begin function transform_point
_transform_point:                       ; @transform_point
; %bb.0:
	ld	hl, -56
	call	__frameset
	ld	iy, (ix + 9)
	ld	bc, (iy)
	ld	hl, (iy + 3)
	ld	(ix - 39), hl
	ld	hl, (iy + 6)
	ld	(ix - 42), hl
	ld	hl, (ix + 12)
	ld	iy, (ix + 15)
	ld	de, (ix + 18)
	ld	(ix - 48), de
	or	a, a
	sbc	hl, bc
	ex	de, hl
	lea	hl, iy + 0
	ld	bc, (ix - 39)
	or	a, a
	sbc	hl, bc
	ld	(ix - 39), hl
	ld	hl, (ix - 48)
	ld	bc, (ix - 42)
	or	a, a
	sbc	hl, bc
	ld	(ix - 42), hl
	ld	(ix - 36), de
	push	de
	pop	bc
	ld	(ix - 45), bc
	ld	a, (ix - 34)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	(ix - 48), d
	ld	iy, (ix + 9)
	ld	hl, (iy + 9)
	ld	(ix - 33), hl
	ld	a, (ix - 31)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	a, d
	call	__lmulu
	ld	(ix - 52), hl
	ld	(ix - 55), e                    ; 1-byte Folded Spill
	ld	bc, (ix - 39)
	ld	(ix - 30), bc
	ld	a, (ix - 28)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	(ix - 49), d
	ld	hl, (iy + 12)
	ld	(ix - 27), hl
	ld	a, (ix - 25)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	a, d
	call	__lmulu
	ld	bc, (ix - 52)
	ld	a, (ix - 55)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(ix - 55), hl
	ld	(ix - 56), e                    ; 1-byte Folded Spill
	ld	bc, (ix - 42)
	ld	(ix - 24), bc
	ld	a, (ix - 22)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	(ix - 52), d
	ld	hl, (iy + 15)
	ld	(ix - 21), hl
	ld	a, (ix - 19)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 55)
	ld	e, (ix - 56)                    ; 1-byte Folded Reload
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	hl, (ix + 6)
	ld	(hl), bc
	ld	hl, (iy + 18)
	ld	(ix - 18), hl
	ld	a, (ix - 16)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 45)
	ld	a, (ix - 48)                    ; 1-byte Folded Reload
	call	__lmulu
	ld	(ix - 55), hl
	ld	d, e
	ld	hl, (iy + 21)
	ld	(ix - 15), hl
	ld	a, (ix - 13)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 39)
	ld	a, (ix - 49)                    ; 1-byte Folded Reload
	call	__lmulu
	ld	bc, (ix - 55)
	ld	a, d
	call	__ladd
	ld	(ix - 55), hl
	ld	d, e
	ld	hl, (iy + 24)
	ld	(ix - 12), hl
	ld	a, (ix - 10)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 42)
	ld	a, (ix - 52)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 55)
	ld	e, d
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	iy, (ix + 6)
	ld	(iy + 3), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 27)
	ld	(ix - 9), hl
	ld	a, (ix - 7)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 45)
	ld	a, (ix - 48)                    ; 1-byte Folded Reload
	call	__lmulu
	ld	(ix - 45), hl
	ld	d, e
	ld	hl, (iy + 30)
	ld	(ix - 6), hl
	ld	a, (ix - 4)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 39)
	ld	a, (ix - 49)                    ; 1-byte Folded Reload
	call	__lmulu
	ld	bc, (ix - 45)
	ld	a, d
	call	__ladd
	ld	(ix - 39), hl
	ld	d, e
	ld	hl, (iy + 33)
	ld	(ix - 3), hl
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 42)
	ld	a, (ix - 52)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 39)
	ld	e, d
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	iy, (ix + 6)
	ld	(iy + 6), bc
	lea	hl, iy + 0
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end26
.Lfunc_end26:
	.size	_transform_point, .Lfunc_end26-_transform_point
                                        ; -- End function
	.section	.text._project_camera_point,"ax",@progbits
	.type	_project_camera_point,@function ; -- Begin function project_camera_point
_project_camera_point:                  ; @project_camera_point
; %bb.0:
	ld	hl, -14
	call	__frameset
	ld	iy, (ix + 9)
	ld	hl, (iy + 6)
	push	hl
	call	_projection_scale_for_depth
	ex.sis	de, hl
	pop	hl
	ld	hl, (ix + 9)
	ld	hl, (hl)
	ld	(ix - 7), hl
	ld	a, (ix - 5)
	rlc	a
	sbc	a, a
	ld	c, 0
	ld	(ix - 4), c
	ld	bc, (ix - 6)
	ld	b, d
	ld	c, e
	ld	de, 0
	ld	d, e
	ld	e, a
	ld	(ix - 13), bc
	ld	(ix - 14), d                    ; 1-byte Folded Spill
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 6
	call	__lshrs
	ld	d, a
	push	bc
	pop	iy
	push	bc
	pop	hl
	ld	e, d
	ld	bc, 1040384
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB27_2
; %bb.1:
	ld	a, 0
	jr	.LBB27_3
	.local	.LBB27_2
.LBB27_2:
	ld	a, 1
	.local	.LBB27_3
.LBB27_3:
	bit	0, a
	jr	nz, .LBB27_5
; %bb.4:
	ld	iy, 1040384
	.local	.LBB27_5
.LBB27_5:
	ld	hl, -1056768
	ld	e, -1
	bit	0, a
	jr	nz, .LBB27_7
; %bb.6:
	ld	d, 0
	.local	.LBB27_7
.LBB27_7:
	lea	bc, iy + 0
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB27_9
; %bb.8:
	push	hl
	pop	iy
	.local	.LBB27_9
.LBB27_9:
	ld	de, 8192
	add	iy, de
	ld	(ix - 10), iy
	ld	iy, (ix + 9)
	ld	hl, (iy + 3)
	ld	(ix - 3), hl
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 13)
	ld	a, (ix - 14)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 6
	call	__lshrs
	ld	hl, 6144
	ld	iyl, 0
	ld	e, iyl
	call	__lsub
	ld	d, e
	push	hl
	pop	iy
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB27_11
; %bb.10:
	ld	a, 0
	jr	.LBB27_12
	.local	.LBB27_11
.LBB27_11:
	ld	a, 1
	.local	.LBB27_12
.LBB27_12:
	ld	e, -1
	bit	0, a
	jr	nz, .LBB27_14
; %bb.13:
	ld	iy, 1048576
	.local	.LBB27_14
.LBB27_14:
	ld	hl, -1048576
	bit	0, a
	jr	nz, .LBB27_16
; %bb.15:
	ld	d, 0
	.local	.LBB27_16
.LBB27_16:
	ld	(ix - 13), iy
	lea	bc, iy + 0
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB27_18
; %bb.17:
	ld	(ix - 13), hl
	.local	.LBB27_18
.LBB27_18:
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB27_20
; %bb.19:
	ld	hl, _render_benchmark+66
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	.local	.LBB27_20
.LBB27_20:
	ld	a, (_active_render_shift)
	or	a, a
	jr	nz, .LBB27_22
; %bb.21:
	ld	bc, (ix - 10)
	ld	hl, (ix - 13)
	jr	.LBB27_23
	.local	.LBB27_22
.LBB27_22:
	ld	hl, (ix - 10)
	push	hl
	call	_half_projected
	ld	(ix - 10), hl
	pop	hl
	ld	hl, (ix - 13)
	push	hl
	call	_half_projected
	pop	de
	ld	bc, (ix - 10)
	.local	.LBB27_23
.LBB27_23:
	ld	iy, (ix + 6)
	ld	(iy), bc
	ld	(iy + 3), hl
	lea	hl, iy + 0
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end27
.Lfunc_end27:
	.size	_project_camera_point, .Lfunc_end27-_project_camera_point
                                        ; -- End function
	.section	.text._clip_and_project,"ax",@progbits
	.type	_clip_and_project,@function     ; -- Begin function clip_and_project
_clip_and_project:                      ; @clip_and_project
; %bb.0:
	ld	hl, -78
	call	__frameset
	ld	hl, (ix + 6)
	ld	bc, _clip_input
	ld	iyl, 0
	ld	de, _clip_output
	ld	(ix - 40), de
	lea	de, ix - 6
	ld	(ix - 43), de
	push	bc
	pop	de
	ld	bc, 36
	ldir
	ld	bc, 36
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	(ix - 33), hl
	ld	iyh, iyl
	.local	.LBB28_1
.LBB28_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB28_21
; %bb.2:                                ;   in Loop: Header=BB28_1 Depth=1
	push	af
	ld	a, iyh
	ld	(ix - 34), a                    ; 1-byte Folded Spill
	pop	af
	ld	hl, _clip_input
	ld	(ix - 46), de
	add	hl, de
	ld	(ix - 37), hl
	ld	de, (ix - 33)
	sbc	hl, hl
	adc	hl, de
	ld	hl, 3
	jr	z, .LBB28_4
; %bb.3:                                ;   in Loop: Header=BB28_1 Depth=1
	ex	de, hl
	dec	hl
	.local	.LBB28_4
.LBB28_4:                               ;   in Loop: Header=BB28_1 Depth=1
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _clip_input
	lea	hl, iy + 0
	add	hl, de
	ld	iy, (ix - 37)
	ld	bc, (iy + 6)
	push	hl
	pop	iy
	ld	(ix - 49), iy
	ld	iy, (iy + 6)
	push	bc
	pop	hl
	ld	de, 32
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, -1
	jp	p, .LBB28_6
; %bb.5:                                ;   in Loop: Header=BB28_1 Depth=1
	ld	a, 0
	.local	.LBB28_6
.LBB28_6:                               ;   in Loop: Header=BB28_1 Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	l, -1
	jp	m, .LBB28_8
; %bb.7:                                ;   in Loop: Header=BB28_1 Depth=1
	ld	l, 0
	.local	.LBB28_8
.LBB28_8:                               ;   in Loop: Header=BB28_1 Depth=1
	xor	a, l
	ld	l, a
	bit	0, l
	jp	nz, .LBB28_14
; %bb.9:                                ;   in Loop: Header=BB28_1 Depth=1
	lea	de, iy + 0
	ld	(ix - 55), bc
	ld	iy, (ix - 37)
	ld	hl, (iy)
	ld	(ix - 52), hl
	ld	(ix - 30), hl
	ld	a, (ix - 28)
	rlc	a
	sbc	a, a
	ld	(ix - 62), a                    ; 1-byte Folded Spill
	ld	hl, (iy + 3)
	ld	(ix - 65), hl
	ld	(ix - 27), hl
	ld	a, (ix - 25)
	rlc	a
	sbc	a, a
	ld	(ix - 71), a                    ; 1-byte Folded Spill
	push	de
	pop	bc
	ld	iy, (ix - 49)
	ld	hl, (iy)
	ld	(ix - 68), hl
	ld	(ix - 24), hl
	ld	a, (ix - 22)
	rlc	a
	sbc	a, a
	ld	(ix - 78), a                    ; 1-byte Folded Spill
	ld	de, (iy + 3)
	ld	iy, (ix - 55)
	ld	(ix - 21), de
	ld	a, (ix - 19)
	rlc	a
	sbc	a, a
	lea	hl, iy + 0
	ld	(ix - 61), bc
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB28_11
; %bb.10:                               ;   in Loop: Header=BB28_1 Depth=1
	ld	hl, (ix - 52)
	ld	(ix - 58), hl
	ld	hl, (ix - 61)
	ld	(ix - 74), hl
	ld	(ix - 77), de
	ld	e, a
	ld	bc, (ix - 68)
	ld	a, (ix - 78)
	ld	(ix - 62), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 65)
	ld	(ix - 49), hl
	ld	(ix - 61), iy
	jr	.LBB28_12
	.local	.LBB28_11
.LBB28_11:                              ;   in Loop: Header=BB28_1 Depth=1
	ld	(ix - 49), de
	ld	de, (ix - 68)
	ld	(ix - 58), de
	ld	(ix - 74), iy
	ld	de, (ix - 65)
	ld	(ix - 77), de
	ld	bc, (ix - 52)
	ld	e, (ix - 71)                    ; 1-byte Folded Reload
	.local	.LBB28_12
.LBB28_12:                              ;   in Loop: Header=BB28_1 Depth=1
	push	af
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, iyh
	cp	a, 8
	jp	nc, .LBB28_18
; %bb.13:                               ;   in Loop: Header=BB28_1 Depth=1
	ld	hl, (ix - 49)
	ld	(ix - 18), hl
	ld	a, (ix - 16)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 77)
	ld	(ix - 52), bc
	ld	bc, (ix - 49)
	call	__lsub
	ld	(ix - 65), hl
	ld	(ix - 68), e                    ; 1-byte Folded Spill
	ld	hl, 32
	ld	de, (ix - 61)
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	l, 14
	call	__lshl
	ld	(ix - 71), bc
	ld	(ix - 77), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 74)
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	add	hl, hl
	ccf
	sbc	hl, hl
	inc	hl
	push	hl
	pop	bc
	lea	hl, iy + 0
	add	hl, bc
	call	__ishrs_1
	push	hl
	pop	bc
	ld	(ix - 15), bc
	ld	a, (ix - 13)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 71)
	ld	e, (ix - 77)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(ix - 12), iy
	ld	a, (ix - 10)
	rlc	a
	sbc	a, a
	lea	bc, iy + 0
	call	__ldivs
	ld	(ix - 61), hl
	ld	d, e
	ld	bc, (ix - 65)
	ld	a, (ix - 68)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 14
	call	__lshrs
	ld	hl, (ix - 49)
	add	hl, bc
	ld	(ix - 49), hl
	ld	iy, (ix - 58)
	ld	(ix - 9), iy
	ld	a, (ix - 7)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 52)
	ld	e, (ix - 62)                    ; 1-byte Folded Reload
	lea	bc, iy + 0
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 61)
	ld	e, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 14
	call	__lshrs
	add	iy, bc
	ld	(ix - 58), iy
	or	a, a
	sbc	hl, hl
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	l, a
	inc	a
	ld	(ix - 34), a
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _clip_output
	add	iy, de
	ld	de, 32
	ld	hl, (ix - 58)
	ld	(iy), hl
	ld	hl, (ix - 49)
	ld	(iy + 3), hl
	ld	(iy + 6), de
	ld	bc, (ix - 55)
	.local	.LBB28_14
.LBB28_14:                              ;   in Loop: Header=BB28_1 Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iyl, 0
	ld	hl, (ix - 33)
	jp	m, .LBB28_17
; %bb.15:                               ;   in Loop: Header=BB28_1 Depth=1
	push	af
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, iyh
	cp	a, 8
	jr	nc, .LBB28_20
; %bb.16:                               ;   in Loop: Header=BB28_1 Depth=1
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	inc	iyh
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	hl, _clip_output
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 37)
	ldir
	jr	.LBB28_19
	.local	.LBB28_17
.LBB28_17:                              ;   in Loop: Header=BB28_1 Depth=1
	push	af
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	jr	.LBB28_20
	.local	.LBB28_18
.LBB28_18:                              ;   in Loop: Header=BB28_1 Depth=1
	ld	iyl, 0
	.local	.LBB28_19
.LBB28_19:                              ;   in Loop: Header=BB28_1 Depth=1
	ld	hl, (ix - 33)
	.local	.LBB28_20
.LBB28_20:                              ;   in Loop: Header=BB28_1 Depth=1
	inc	hl
	ld	(ix - 33), hl
	ld	hl, (ix - 46)
	ld	bc, 9
	add	hl, bc
	ex	de, hl
	ld	bc, 36
	jp	.LBB28_1
	.local	.LBB28_21
.LBB28_21:
	ld	a, iyh
	cp	a, 3
	jr	c, .LBB28_26
; %bb.22:
	ld	de, 0
	push	af
	ld	a, iyh
	ld	(ix - 34), a                    ; 1-byte Folded Spill
	pop	af
	ld	e, iyh
	ld	hl, (ix + 9)
	push	hl
	pop	bc
	.local	.LBB28_23
.LBB28_23:                              ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB28_25
; %bb.24:                               ;   in Loop: Header=BB28_23 Depth=1
	ld	hl, (ix - 40)
	push	hl
	ld	hl, (ix - 43)
	push	hl
	ld	(ix - 37), de
	ld	(ix - 33), bc
	call	_project_camera_point
	pop	hl
	pop	hl
	ld	de, (ix - 33)
	ld	hl, (ix - 43)
	ld	bc, 6
	ldir
	ld	de, (ix - 37)
	ld	iy, (ix - 40)
	lea	iy, iy + 9
	ld	(ix - 40), iy
	ld	iy, (ix - 33)
	lea	iy, iy + 6
	lea	bc, iy + 0
	dec	de
	jr	.LBB28_23
	.local	.LBB28_25
.LBB28_25:
	ld	de, 144
	ld	hl, (ix + 9)
	add	hl, de
	ld	a, (ix - 34)
	ld	(hl), a
	ld	iyl, 1
	.local	.LBB28_26
.LBB28_26:
	ld	a, iyl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end28
.Lfunc_end28:
	.size	_clip_and_project, .Lfunc_end28-_clip_and_project
                                        ; -- End function
	.section	.text._polygon_intersects_layer,"ax",@progbits
	.type	_polygon_intersects_layer,@function ; -- Begin function polygon_intersects_layer
_polygon_intersects_layer:              ; @polygon_intersects_layer
; %bb.0:
	ld	hl, -25
	call	__frameset
	ld	de, (ix + 9)
	ld	bc, 1308
	push	de
	pop	hl
	add	hl, bc
	ld	(ix - 12), hl
	inc	bc
	push	de
	pop	hl
	add	hl, bc
	ld	bc, 1306
	push	de
	pop	iy
	add	iy, bc
	ld	(ix - 3), iy
	inc	bc
	push	de
	pop	iy
	add	iy, bc
	ld	(ix - 9), iy
	ld	de, 144
	ld	iy, (ix + 6)
	add	iy, de
	ld	a, (iy)
	cp	a, 2
	jr	nc, .LBB29_2
; %bb.1:
	ld	a, 1
	.local	.LBB29_2
.LBB29_2:
	ld	de, (ix + 6)
	push	de
	pop	iy
	ld	de, (iy)
	ld	bc, (iy + 3)
	ld	(ix - 6), bc
	ld	iy, (ix - 12)
	ld	c, (iy)
	ld	(ix - 20), c
	ld	c, (hl)
	ld	(ix - 22), c
	ld	hl, (ix - 3)
	ld	c, (hl)
	ld	(ix - 21), c
	ld	hl, (ix - 9)
	ld	l, (hl)
	ld	(ix - 19), l
	ld	bc, 0
	ld	c, a
	ld	iy, (ix + 6)
	lea	hl, iy + 9
	ld	(ix - 3), hl
	dec	bc
	ld	(ix - 9), de
	ld	(ix - 12), de
	ld	de, (ix - 6)
	.local	.LBB29_3
.LBB29_3:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	ld	(ix - 18), de
	jp	z, .LBB29_13
; %bb.4:                                ;   in Loop: Header=BB29_3 Depth=1
	ld	iy, (ix - 3)
	ld	iy, (iy - 3)
	lea	hl, iy + 0
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	(ix - 15), iy
	jp	m, .LBB29_6
; %bb.5:                                ;   in Loop: Header=BB29_3 Depth=1
	ld	iy, (ix - 9)
	.local	.LBB29_6
.LBB29_6:                               ;   in Loop: Header=BB29_3 Depth=1
	ld	(ix - 25), bc
	ld	(ix - 9), iy
	ld	iy, (ix - 12)
	lea	hl, iy + 0
	ld	de, (ix - 15)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB29_8
; %bb.7:                                ;   in Loop: Header=BB29_3 Depth=1
	ld	(ix - 15), iy
	.local	.LBB29_8
.LBB29_8:                               ;   in Loop: Header=BB29_3 Depth=1
	ld	hl, (ix - 3)
	ld	de, (hl)
	push	de
	pop	hl
	ld	bc, (ix - 6)
	push	bc
	pop	iy
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	push	de
	pop	hl
	jp	m, .LBB29_10
; %bb.9:                                ;   in Loop: Header=BB29_3 Depth=1
	lea	hl, iy + 0
	.local	.LBB29_10
.LBB29_10:                              ;   in Loop: Header=BB29_3 Depth=1
	ld	(ix - 6), hl
	ld	iy, (ix - 18)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	bc, (ix - 25)
	jp	m, .LBB29_12
; %bb.11:                               ;   in Loop: Header=BB29_3 Depth=1
	lea	de, iy + 0
	.local	.LBB29_12
.LBB29_12:                              ;   in Loop: Header=BB29_3 Depth=1
	ld	iy, (ix - 3)
	lea	iy, iy + 6
	ld	(ix - 3), iy
	dec	bc
	ld	hl, (ix - 15)
	ld	(ix - 12), hl
	jp	.LBB29_3
	.local	.LBB29_13
.LBB29_13:
	ld	de, 1310
	ld	hl, (ix + 9)
	add	hl, de
	ld	c, (hl)
	ld	a, c
	or	a, a
	jr	nz, .LBB29_15
; %bb.14:
	push	af
	ld	a, (ix - 22)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	ld	l, (ix - 21)                    ; 1-byte Folded Reload
	ld	c, l
	ld	a, (ix - 19)                    ; 1-byte Folded Reload
	ld	e, a
	ld	b, (ix - 20)                    ; 1-byte Folded Reload
	jr	.LBB29_20
	.local	.LBB29_15
.LBB29_15:
	scf
	sbc	hl, hl
	call	__ishl
	ld	(ix - 3), hl
	ld	de, 0
	ld	e, (ix - 22)                    ; 1-byte Folded Reload
	push	de
	pop	hl
	call	__ishru
	inc	hl
	call	__ishl
	push	hl
	pop	iy
	dec	iyl
	ld	e, (ix - 19)                    ; 1-byte Folded Reload
	ex	de, hl
	call	__ishru
	inc	hl
	call	__ishl
	ex	de, hl
	dec	e
	ld	a, (_active_render_width)
	ld	l, a
	ld	a, iyl
	cp	a, l
	ld	b, (ix - 20)                    ; 1-byte Folded Reload
	jr	c, .LBB29_17
; %bb.16:
	dec	l
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	.local	.LBB29_17
.LBB29_17:
	ld	hl, (ix - 3)
	ld	c, l
	ld	a, (_active_render_height)
	ld	l, a
	ld	a, e
	cp	a, l
	jr	c, .LBB29_19
; %bb.18:
	dec	l
	ld	e, l
	.local	.LBB29_19
.LBB29_19:
	ld	a, b
	and	a, c
	ld	b, a
	ld	l, (ix - 21)                    ; 1-byte Folded Reload
	ld	a, l
	and	a, c
	ld	c, a
	ld	a, (ix - 19)                    ; 1-byte Folded Reload
	.local	.LBB29_20
.LBB29_20:
	cp	a, l
	jr	nc, .LBB29_22
; %bb.21:
	xor	a, a
	jr	.LBB29_27
	.local	.LBB29_22
.LBB29_22:
	ld	(ix - 3), c                     ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	ld	l, b
	ld	c, 8
	call	__ishl
	push	hl
	pop	bc
	ld	hl, (ix - 12)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	a, 0
	jp	m, .LBB29_27
; %bb.23:
	ld	(ix - 12), de
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	c, 8
	call	__ishl
	ld	de, 256
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB29_27
; %bb.24:
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 3)                     ; 1-byte Folded Reload
	call	__ishl
	ex	de, hl
	ld	hl, (ix - 18)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB29_27
; %bb.25:
	or	a, a
	sbc	hl, hl
	ld	de, (ix - 12)
	ld	l, e
	call	__ishl
	ld	de, 256
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB29_27
; %bb.26:
	ld	a, 1
	.local	.LBB29_27
.LBB29_27:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end29
.Lfunc_end29:
	.size	_polygon_intersects_layer, .Lfunc_end29-_polygon_intersects_layer
                                        ; -- End function
	.section	.text._rasterize_polygon,"ax",@progbits
	.type	_rasterize_polygon,@function    ; -- Begin function rasterize_polygon
_rasterize_polygon:                     ; @rasterize_polygon
; %bb.0:
	ld	hl, -96
	call	__frameset
	ld	iy, (ix + 6)
	ld	hl, (ix + 9)
	xor	a, a
	ld	(ix - 48), a
	ld	de, 1310
	add	hl, de
	ld	c, (hl)
	ld	a, c
	or	a, a
	jp	nz, .LBB30_12
; %bb.1:
	ld	hl, (iy + 3)
	ld	(ix - 27), hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB30_3
; %bb.2:
	ld	iy, _render_benchmark+68
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB30_3
.LBB30_3:
	ld	de, (ix + 6)
	push	de
	pop	hl
	ld	bc, 144
	add	hl, bc
	ld	(ix - 51), hl
	ld	a, (hl)
	ld	bc, 0
	cp	a, 2
	ld	l, a
	jr	nc, .LBB30_5
; %bb.4:
	ld	l, 1
	.local	.LBB30_5
.LBB30_5:
	ld	c, a
	ld	(ix - 42), bc
	ld	bc, 0
	ld	c, l
	push	de
	pop	iy
	lea	hl, iy + 9
	ld	(ix - 30), hl
	dec	bc
	ld	hl, (ix - 27)
	push	hl
	pop	de
	.local	.LBB30_6
.LBB30_6:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 27), hl
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB30_23
; %bb.7:                                ;   in Loop: Header=BB30_6 Depth=1
	ld	hl, (ix - 30)
	ld	hl, (hl)
	ld	(ix - 36), hl
	ld	(ix - 33), de
	or	a, a
	sbc	hl, de
	ld	de, (ix - 36)
	call	pe, __setflag
	push	de
	pop	hl
	jp	m, .LBB30_9
; %bb.8:                                ;   in Loop: Header=BB30_6 Depth=1
	ld	hl, (ix - 33)
	.local	.LBB30_9
.LBB30_9:                               ;   in Loop: Header=BB30_6 Depth=1
	ld	(ix - 33), hl
	ld	iy, (ix - 27)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_11
; %bb.10:                               ;   in Loop: Header=BB30_6 Depth=1
	lea	de, iy + 0
	.local	.LBB30_11
.LBB30_11:                              ;   in Loop: Header=BB30_6 Depth=1
	ld	iy, (ix - 30)
	lea	iy, iy + 6
	ld	(ix - 30), iy
	dec	bc
	ex	de, hl
	ld	de, (ix - 33)
	jr	.LBB30_6
	.local	.LBB30_12
.LBB30_12:
	ld	(ix - 54), hl
	ld	hl, 1
	ld	de, 255
	ld	(ix - 33), c                    ; 1-byte Folded Spill
	call	__ishl
	push	de
	pop	bc
	call	__iand
	ld	(ix - 39), hl
	call	__ishru_1
	ld	de, (iy + 3)
	ld	(ix - 30), de
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB30_14
; %bb.13:
	ld	iy, _render_benchmark+68
	ld	de, (iy)
	inc.sis	de
	ld	(iy), e
	ld	(iy + 1), d
	.local	.LBB30_14
.LBB30_14:
	ld	(ix - 27), hl
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	ld	de, 144
	add	hl, de
	ld	(ix - 57), hl
	ld	a, (hl)
	ld	de, 0
	cp	a, 2
	ld	l, a
	jr	nc, .LBB30_16
; %bb.15:
	ld	l, 1
	.local	.LBB30_16
.LBB30_16:
	lea	bc, iy + 9
	ld	(ix - 36), bc
	ld	e, a
	ld	(ix - 51), de
	ld	bc, 0
	ld	c, l
	dec	bc
	ld	hl, (ix - 30)
	push	hl
	pop	de
	.local	.LBB30_17
.LBB30_17:                              ; =>This Inner Loop Header: Depth=1
	ld	(ix - 30), hl
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB30_25
; %bb.18:                               ;   in Loop: Header=BB30_17 Depth=1
	ld	hl, (ix - 36)
	ld	hl, (hl)
	ld	(ix - 45), hl
	ld	(ix - 42), de
	or	a, a
	sbc	hl, de
	ld	de, (ix - 45)
	call	pe, __setflag
	push	de
	pop	hl
	jp	m, .LBB30_20
; %bb.19:                               ;   in Loop: Header=BB30_17 Depth=1
	ld	hl, (ix - 42)
	.local	.LBB30_20
.LBB30_20:                              ;   in Loop: Header=BB30_17 Depth=1
	ld	(ix - 42), hl
	ld	iy, (ix - 30)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_22
; %bb.21:                               ;   in Loop: Header=BB30_17 Depth=1
	lea	de, iy + 0
	.local	.LBB30_22
.LBB30_22:                              ;   in Loop: Header=BB30_17 Depth=1
	ld	iy, (ix - 36)
	lea	iy, iy + 6
	ld	(ix - 36), iy
	dec	bc
	ex	de, hl
	ld	de, (ix - 42)
	jr	.LBB30_17
	.local	.LBB30_23
.LBB30_23:
	push	de
	pop	hl
	push	de
	pop	bc
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_27
; %bb.24:
	push	bc
	pop	hl
	ld	de, 127
	add	hl, de
	ld	c, 8
	call	__ishru
	jp	.LBB30_28
	.local	.LBB30_25
.LBB30_25:
	push	de
	pop	hl
	push	de
	pop	bc
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_43
; %bb.26:
	push	bc
	pop	hl
	ld	de, 127
	add	hl, de
	ld	c, 8
	call	__ishru
	jp	.LBB30_44
	.local	.LBB30_27
.LBB30_27:
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	c, 8
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB30_28
.LBB30_28:
	ld	(ix - 30), hl
	ld	iy, (ix - 27)
	lea	hl, iy + 0
	ld	de, -129
	add	hl, de
	call	__ishru
	ld	(ix - 33), hl
	ld	hl, 384
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ld	c, l
	ld	b, h
	ex	de, hl
	ld	de, 129
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_30
; %bb.29:
	ld	hl, (ix - 33)
	ld	c, l
	ld	b, h
	.local	.LBB30_30
.LBB30_30:
	ld	(ix - 39), c
	ld	(ix - 38), b
	ld	de, (ix - 30)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	(ix - 30), de
	ld	l, e
	ld	h, d
	ld	iy, (ix + 9)
	ld	de, 1306
	add	iy, de
	ld	(ix - 45), iy
	ld	a, (iy)
	ld	bc, 0
	ld	c, a
	ld	d, b
	ld	e, a
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	(ix - 36), e
	ld	(ix - 35), d
	ld	(ix - 33), e
	ld	(ix - 32), d
	jp	m, .LBB30_32
; %bb.31:
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 33), l
	ld	(ix - 32), h
	.local	.LBB30_32
.LBB30_32:
	push	hl
	ld	l, (ix - 39)
	ld	h, (ix - 38)
	ex	(sp), hl
	pop	iy
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ld	hl, (ix + 9)
	ld	de, 1307
	add	hl, de
	ld	(ix - 54), hl
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	e, (ix - 36)
	ld	d, (ix - 35)
                                        ; kill: def $d killed $d killed $de def $de
	ld	e, a
	ld	(ix - 27), e
	ld	(ix - 26), d
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB30_34
; %bb.33:
	push	iy
	ex	(sp), hl
	ld	(ix - 27), l
	ld	(ix - 26), h
	pop	hl
	.local	.LBB30_34
.LBB30_34:
	ld	e, (ix - 33)
	ld	d, (ix - 32)
	ld	l, e
	ld	h, d
	ld.sis	bc, 1
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	ld	(ix - 30), e
	ld	(ix - 29), d
	jp	p, .LBB30_36
; %bb.35:
	ld.sis	hl, 0
	ld	(ix - 30), l
	ld	(ix - 29), h
	.local	.LBB30_36
.LBB30_36:
	ld	a, (_active_render_height)
	ld	e, (ix - 36)
	ld	d, (ix - 35)
	ld	e, a
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_38
; %bb.37:
	dec.sis	de
	ld	c, e
	ld	b, d
	.local	.LBB30_38
.LBB30_38:
	ld.sis	de, 0
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_58
; %bb.39:
	ld	l, c
	ld	h, b
	ld	e, (ix - 33)
	ld	d, (ix - 32)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_58
; %bb.40:                               ; %.preheader47.preheader
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	(ix - 27), c
	ld	(ix - 26), b
	.local	.LBB30_41
.LBB30_41:                              ; %.preheader47
                                        ; =>This Inner Loop Header: Depth=1
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_60
; %bb.42:                               ;   in Loop: Header=BB30_41 Depth=1
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_left
	add	hl, bc
	ld	iy, 1048577
	ld	(hl), iy
	ld	hl, _span_right
	add	hl, bc
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	ld	iy, -1048577
	ld	(hl), iy
	inc.sis	de
	jr	.LBB30_41
	.local	.LBB30_43
.LBB30_43:
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	c, 8
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB30_44
.LBB30_44:
	ld	(ix - 36), hl
	ld	iy, (ix - 30)
	lea	hl, iy + 0
	ld	de, -129
	add	hl, de
	call	__ishru
	ld	(ix - 42), hl
	ld	hl, 384
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ld	(ix - 45), l
	ld	(ix - 44), h
	ex	de, hl
	ld	de, 129
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_46
; %bb.45:
	ld	hl, (ix - 42)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 45), l
	ld	(ix - 44), h
	.local	.LBB30_46
.LBB30_46:
	ld	de, (ix + 9)
	ex	de, hl
	ld	de, 1306
	add	hl, de
	ld	(ix - 60), hl
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, (ix - 33)                    ; 1-byte Folded Reload
	call	__ishru
	ld	de, (ix - 39)
	push	de
	pop	bc
	call	__imulu
	push	hl
	pop	iy
	ld	bc, (ix - 27)
	add	iy, bc
	ld	hl, (ix + 9)
	ld	bc, 1307
	add	hl, bc
	ld	(ix - 63), hl
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, (ix - 33)                    ; 1-byte Folded Reload
	call	__ishru
	push	de
	pop	bc
	call	__imulu
	ld	de, (ix - 27)
	add	hl, de
	ld	(ix - 30), hl
	ld	bc, (ix - 36)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	(ix - 36), bc
	ld	e, c
	ld	d, b
	ld	(ix - 42), iy
	lea	hl, iy + 0
	ld	bc, 65535
	call	__iand
	push	hl
	pop	bc
	ex	de, hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB30_48
; %bb.47:
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl def $uhl
	ld	(ix - 42), hl
	.local	.LBB30_48
.LBB30_48:
	push	hl
	ld	l, (ix - 45)
	ld	h, (ix - 44)
	ex	(sp), hl
	pop	iy
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ld	hl, (ix - 30)
	ld	bc, 65535
	call	__iand
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_50
; %bb.49:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 30), hl
	.local	.LBB30_50
.LBB30_50:
	ld	bc, (ix - 42)
	ld	l, c
	ld	h, b
	ld.sis	de, 1
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	iy, (ix - 27)
	jp	p, .LBB30_52
; %bb.51:
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	.local	.LBB30_52
.LBB30_52:
	ld	a, (_active_render_height)
	ld	e, a
	ld	d, 0
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_54
; %bb.53:
	dec.sis	de
	ld	l, e
	ld	h, d
	ld	(ix - 30), hl
	.local	.LBB30_54
.LBB30_54:
	ld	de, 0
	ld	e, c
	ld	d, b
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	nc, .LBB30_56
; %bb.55:
	ld	hl, (ix - 39)
	ld	bc, 65535
	add	hl, bc
	ld	bc, (ix - 27)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	add	iy, de
	scf
	sbc	hl, hl
	ld	c, (ix - 33)                    ; 1-byte Folded Reload
	call	__ishl
	push	hl
	pop	bc
	lea	hl, iy + 0
	call	__iand
	push	hl
	pop	iy
	ld	de, (ix - 27)
	add	iy, de
	.local	.LBB30_56
.LBB30_56:
	ld	bc, (ix - 30)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	push	de
	pop	hl
	ld	bc, (ix - 27)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB30_58
; %bb.57:
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ex	de, hl
	scf
	sbc	hl, hl
	ld	c, (ix - 33)                    ; 1-byte Folded Reload
	call	__ishl
	push	hl
	pop	bc
	ex	de, hl
	call	__iand
	lea	de, iy + 0
	push	hl
	pop	iy
	ld	bc, (ix - 27)
	add	iy, bc
	ld	c, 8
	ld	(ix - 33), de
	ex	de, hl
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	(ix - 45), iy
	lea	hl, iy + 0
	call	__ishl
	call	__ishrs
	ld	(ix - 30), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB30_112
	.local	.LBB30_58
.LBB30_58:
	xor	a, a
	.local	.LBB30_59
.LBB30_59:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB30_60
.LBB30_60:
	ld	a, 8
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	bc, (ix - 42)
	.local	.LBB30_61
.LBB30_61:                              ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB30_64 Depth 2
                                        ;     Child Loop BB30_83 Depth 2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	push	de
	pop	iy
	jr	c, .LBB30_63
; %bb.62:                               ; %.preheader
                                        ;   in Loop: Header=BB30_61 Depth=1
	push	bc
	pop	iy
	.local	.LBB30_63
.LBB30_63:                              ; %.preheader
                                        ;   in Loop: Header=BB30_61 Depth=1
	dec	bc
	ld	(ix - 42), bc
	push	de
	pop	hl
	ld	bc, 6
	call	__imulu
	push	de
	pop	bc
	ex	de, hl
	ld	hl, (ix + 6)
	add	hl, de
	ld	(ix - 33), hl
	push	bc
	pop	de
	.local	.LBB30_64
.LBB30_64:                              ;   Parent Loop BB30_61 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	jp	z, .LBB30_115
; %bb.65:                               ;   in Loop: Header=BB30_64 Depth=2
	ld	(ix - 57), iy
	push	de
	pop	bc
	inc	bc
	ld	hl, (ix - 42)
	ld	(ix - 39), de
	or	a, a
	sbc	hl, de
	ld	hl, 0
	jr	z, .LBB30_67
; %bb.66:                               ;   in Loop: Header=BB30_64 Depth=2
	push	bc
	pop	hl
	.local	.LBB30_67
.LBB30_67:                              ;   in Loop: Header=BB30_64 Depth=2
	ld	(ix - 60), bc
	ld	iy, (ix - 33)
	ld	de, (iy)
	ld	(ix - 63), de
	ld	de, (iy + 3)
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, (ix + 6)
	add	iy, bc
	ld	bc, (iy + 3)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB30_81
; %bb.68:                               ;   in Loop: Header=BB30_64 Depth=2
	ld	hl, (iy)
	ld	(ix - 36), hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB30_70
; %bb.69:                               ;   in Loop: Header=BB30_64 Depth=2
	push	de
	pop	iy
	push	bc
	pop	hl
	ld	de, (ix - 36)
	ld	(ix - 69), de
	jr	.LBB30_71
	.local	.LBB30_70
.LBB30_70:                              ;   in Loop: Header=BB30_64 Depth=2
	ex	de, hl
	ld	de, (ix - 63)
	ld	(ix - 69), de
	push	bc
	pop	iy
	ld	de, (ix - 36)
	ld	(ix - 63), de
	.local	.LBB30_71
.LBB30_71:                              ;   in Loop: Header=BB30_64 Depth=2
	push	hl
	pop	de
	ld	bc, 128
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	(ix - 72), de
	jp	m, .LBB30_73
; %bb.72:                               ;   in Loop: Header=BB30_64 Depth=2
	ex	de, hl
	ld	bc, 127
	add	hl, bc
	ld	c, a
	call	__ishru
	jp	.LBB30_74
	.local	.LBB30_73
.LBB30_73:                              ;   in Loop: Header=BB30_64 Depth=2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	ld	c, a
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB30_74
.LBB30_74:                              ;   in Loop: Header=BB30_64 Depth=2
	ld	(ix - 36), hl
	lea	de, iy + 0
	push	de
	pop	hl
	ld	bc, -129
	add	hl, bc
	ld	c, a
	call	__ishru
	ld	(ix - 66), hl
	ld	hl, 384
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	push	de
	pop	hl
	ld	bc, 129
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB30_76
; %bb.75:                               ;   in Loop: Header=BB30_64 Depth=2
	ld	hl, (ix - 66)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB30_76
.LBB30_76:                              ;   in Loop: Header=BB30_64 Depth=2
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	bc, (ix - 36)
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	jp	m, .LBB30_78
; %bb.77:                               ;   in Loop: Header=BB30_64 Depth=2
	ld	l, (ix - 30)
	ld	h, (ix - 29)
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 36), hl
	.local	.LBB30_78
.LBB30_78:                              ;   in Loop: Header=BB30_64 Depth=2
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB30_80
; %bb.79:                               ;   in Loop: Header=BB30_64 Depth=2
	ld	iyl, c
	ld	iyh, b
	.local	.LBB30_80
.LBB30_80:                              ;   in Loop: Header=BB30_64 Depth=2
	push	iy
	ex	(sp), hl
	ld	(ix - 66), l
	ld	(ix - 65), h
	pop	hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	bc, (ix - 36)
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB30_82
	.local	.LBB30_81
.LBB30_81:                              ; %.backedge
                                        ;   in Loop: Header=BB30_64 Depth=2
	ld	iy, (ix - 33)
	lea	iy, iy + 6
	ld	(ix - 33), iy
	ld	de, (ix - 60)
	ld	iy, (ix - 57)
	jp	.LBB30_64
	.local	.LBB30_82
.LBB30_82:                              ;   in Loop: Header=BB30_61 Depth=1
	ld	hl, (ix - 63)
	ld	bc, (ix - 69)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	ex	de, hl
	ld	de, (ix - 72)
	or	a, a
	sbc	hl, de
	ld	de, 0
	push	de
	pop	bc
	ld	de, (ix - 36)
	ld	c, e
	ld	b, d
	ld	(ix - 33), bc
	push	hl
	push	iy
	call	_edge_x_step
	ld	(ix - 42), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 69)
	ld	(ix - 12), hl
	ld	a, (ix - 10)
	rlc	a
	sbc	a, a
	ld	d, a
	ld	hl, (ix - 33)
	ld	c, 8
	call	__ishl
	ld	bc, (ix - 72)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	ld	bc, 128
	add	iy, bc
	ld	(ix - 9), iy
	ld	a, (ix - 7)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 42)
	ld	(ix - 57), e                    ; 1-byte Folded Spill
	lea	bc, iy + 0
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshrs
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix - 69)
	ld	a, d
	call	__ladd
	ld	bc, (ix - 36)
	ld	(ix - 33), hl
	ld	d, e
	ld	hl, (ix - 39)
	inc	hl
	ld	(ix - 39), hl
	.local	.LBB30_83
.LBB30_83:                              ;   Parent Loop BB30_61 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, b
	rlc	a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	l, (ix - 66)
	ld	h, (ix - 65)
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB30_111
; %bb.84:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	(ix - 36), bc
	ld	iyl, c
	ld	iyh, b
	lea	hl, iy + 0
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_left
	add	hl, bc
	ld	(ix - 60), hl
	ld	bc, (hl)
	ld	(ix - 6), bc
	ld	a, (ix - 4)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 33)
	ld	e, d
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB30_94
; %bb.85:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	hl, (ix - 33)
	ld	e, d
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	ld	a, 1
	jp	m, .LBB30_87
; %bb.86:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	a, 0
	.local	.LBB30_87
.LBB30_87:                              ;   in Loop: Header=BB30_83 Depth=2
	bit	0, a
	ld	bc, (ix - 33)
	jr	nz, .LBB30_89
; %bb.88:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	bc, 1048576
	.local	.LBB30_89
.LBB30_89:                              ;   in Loop: Header=BB30_83 Depth=2
	bit	0, a
	ld	a, d
	jr	nz, .LBB30_91
; %bb.90:                               ;   in Loop: Header=BB30_83 Depth=2
	xor	a, a
	.local	.LBB30_91
.LBB30_91:                              ;   in Loop: Header=BB30_83 Depth=2
	ld	hl, -1048576
	ld	e, -1
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB30_93
; %bb.92:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	bc, -1048576
	.local	.LBB30_93
.LBB30_93:                              ;   in Loop: Header=BB30_83 Depth=2
	ld	hl, (ix - 60)
	ld	(hl), bc
	.local	.LBB30_94
.LBB30_94:                              ;   in Loop: Header=BB30_83 Depth=2
	lea	hl, iy + 0
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _span_right
	add	iy, bc
	ld	hl, (iy)
	ld	(ix - 3), hl
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 33)
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB30_104
; %bb.95:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	hl, (ix - 33)
	ld	e, d
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	ld	a, 1
	jp	m, .LBB30_97
; %bb.96:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	a, 0
	.local	.LBB30_97
.LBB30_97:                              ;   in Loop: Header=BB30_83 Depth=2
	bit	0, a
	ld	bc, (ix - 33)
	jr	nz, .LBB30_99
; %bb.98:                               ;   in Loop: Header=BB30_83 Depth=2
	ld	bc, 1048576
	.local	.LBB30_99
.LBB30_99:                              ;   in Loop: Header=BB30_83 Depth=2
	bit	0, a
	ld	a, d
	jr	nz, .LBB30_101
; %bb.100:                              ;   in Loop: Header=BB30_83 Depth=2
	xor	a, a
	.local	.LBB30_101
.LBB30_101:                             ;   in Loop: Header=BB30_83 Depth=2
	ld	hl, -1048576
	ld	e, -1
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB30_103
; %bb.102:                              ;   in Loop: Header=BB30_83 Depth=2
	ld	bc, -1048576
	.local	.LBB30_103
.LBB30_103:                             ;   in Loop: Header=BB30_83 Depth=2
	ld	(iy), bc
	.local	.LBB30_104
.LBB30_104:                             ;   in Loop: Header=BB30_83 Depth=2
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	c, (ix - 66)
	ld	b, (ix - 65)
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	ld	a, -1
	jp	m, .LBB30_106
; %bb.105:                              ;   in Loop: Header=BB30_83 Depth=2
	ld	a, 0
	.local	.LBB30_106
.LBB30_106:                             ;   in Loop: Header=BB30_83 Depth=2
	bit	0, a
	ld	hl, (ix - 42)
	jr	nz, .LBB30_108
; %bb.107:                              ;   in Loop: Header=BB30_83 Depth=2
	or	a, a
	sbc	hl, hl
	.local	.LBB30_108
.LBB30_108:                             ;   in Loop: Header=BB30_83 Depth=2
	bit	0, a
	ld	e, (ix - 57)                    ; 1-byte Folded Reload
	jr	nz, .LBB30_110
; %bb.109:                              ;   in Loop: Header=BB30_83 Depth=2
	ld	e, 0
	.local	.LBB30_110
.LBB30_110:                             ;   in Loop: Header=BB30_83 Depth=2
	ld	bc, (ix - 33)
	ld	a, d
	call	__ladd
	ld	(ix - 33), hl
	ld	d, e
	ld	bc, (ix - 36)
	inc.sis	bc
	jp	.LBB30_83
	.local	.LBB30_111
.LBB30_111:                             ;   in Loop: Header=BB30_61 Depth=1
	ld	hl, (ix - 51)
	ld	a, (hl)
	ld	bc, 0
	ld	c, a
	ld	a, 8
	ld	de, (ix - 39)
	jp	.LBB30_61
	.local	.LBB30_112
.LBB30_112:                             ; %.preheader49.preheader
	ld	(ix - 69), de
	ld	a, 8
	ld	iy, 3
	ld	hl, (ix - 33)
	.local	.LBB30_113
.LBB30_113:                             ; %.preheader49
                                        ; =>This Inner Loop Header: Depth=1
	ld	c, a
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	hl, (ix - 30)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_140
; %bb.114:                              ;   in Loop: Header=BB30_113 Depth=1
	push	de
	pop	hl
	lea	bc, iy + 0
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_left
	add	hl, bc
	ld	iy, 1048577
	ld	(hl), iy
	ld	iy, 3
	ld	hl, _span_right
	add	hl, bc
	ld	bc, -1048577
	ld	(hl), bc
	ex	de, hl
	ld	de, (ix - 39)
	add	hl, de
	jr	.LBB30_113
	.local	.LBB30_115
.LBB30_115:
	ld	de, 149
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	add	iy, de
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	(iy), e
	ld	de, 150
	push	hl
	pop	iy
	add	iy, de
	ld	(iy), c
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB30_117
; %bb.116:
	ld	iy, _render_benchmark+70
	ld	iy, (iy)
	ld	l, c
	ld	h, b
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	or	a, a
	sbc.sis	hl, de
	lea	de, iy + 0
	add.sis	hl, de
	inc.sis	hl
	ld	iy, _render_benchmark+70
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB30_117
.LBB30_117:
	ld	a, (_active_render_width)
	ld	l, a
	ld	d, 0
	ld	(ix - 60), e
	ld	(ix - 59), d
	ld	h, d
	ld	(ix - 42), l
	ld	(ix - 41), h
	dec.sis	hl
	ld	(ix - 51), l
	ld	(ix - 50), h
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	lea	hl, iy + 48
	ld	(ix - 33), hl
	lea	hl, iy + 96
	ld	(ix - 36), hl
	ld	a, 8
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	.local	.LBB30_118
.LBB30_118:                             ; =>This Inner Loop Header: Depth=1
	ld	l, d
	rlc	l
	sbc	hl, hl
	push	hl
	pop	iy
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_194
; %bb.119:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	(ix - 30), e
	ld	(ix - 29), d
	lea	hl, iy + 0
	ld	l, e
	ld	h, d
	push	hl
	pop	iy
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_left
	add	hl, bc
	ld	bc, (hl)
	push	bc
	pop	hl
	ld	de, 1048577
	or	a, a
	sbc	hl, de
	jr	nz, .LBB30_123
; %bb.120:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	hl, (ix - 33)
	lea	de, iy + 0
	add	hl, de
	ld	(hl), -1
	ld	hl, (ix - 36)
	add	hl, de
	ld	(hl), 0
	.local	.LBB30_121
.LBB30_121:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	.local	.LBB30_122
.LBB30_122:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	jp	.LBB30_134
	.local	.LBB30_123
.LBB30_123:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	(ix - 39), iy
	push	bc
	pop	hl
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_125
; %bb.124:                              ;   in Loop: Header=BB30_118 Depth=1
	push	bc
	pop	hl
	ld	bc, 127
	add	hl, bc
	ld	c, a
	call	__ishru
	jp	.LBB30_126
	.local	.LBB30_125
.LBB30_125:                             ;   in Loop: Header=BB30_118 Depth=1
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	c, a
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB30_126
.LBB30_126:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	(ix - 63), hl
	ld	hl, (ix - 39)
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_right
	add	hl, bc
	ld	de, (hl)
	push	de
	pop	hl
	push	de
	pop	iy
	ld	de, -128
	add	hl, de
	ld	c, a
	call	__ishru
	ld	(ix - 57), hl
	ld	hl, 383
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ex	de, hl
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_128
; %bb.127:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	hl, (ix - 57)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB30_128
.LBB30_128:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	bc, (ix - 63)
	ld	l, c
	ld	h, b
	ld.sis	de, 1
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	l, c
	ld	h, b
	ld	e, (ix - 27)
	ld	d, (ix - 26)
	jp	p, .LBB30_130
; %bb.129:                              ;   in Loop: Header=BB30_118 Depth=1
	ld.sis	hl, 0
	.local	.LBB30_130
.LBB30_130:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	(ix - 57), l
	ld	(ix - 56), h
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	e, (ix - 42)
	ld	d, (ix - 41)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	jp	m, .LBB30_132
; %bb.131:                              ;   in Loop: Header=BB30_118 Depth=1
	push	hl
	ld	l, (ix - 51)
	ld	h, (ix - 50)
	ex	(sp), hl
	pop	iy
	.local	.LBB30_132
.LBB30_132:                             ;   in Loop: Header=BB30_118 Depth=1
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	rlc	l
	sbc	hl, hl
	ld	(ix - 66), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	c, (ix - 57)
	ld	b, (ix - 56)
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB30_135
; %bb.133:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	hl, (ix - 33)
	ld	bc, (ix - 39)
	add	hl, bc
	ld	(hl), -1
	ld	hl, (ix - 36)
	add	hl, bc
	ld	(hl), 0
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	.local	.LBB30_134
.LBB30_134:                             ;   in Loop: Header=BB30_118 Depth=1
	inc.sis	de
	jp	.LBB30_118
	.local	.LBB30_135
.LBB30_135:                             ;   in Loop: Header=BB30_118 Depth=1
	ld	hl, (ix - 33)
	ld	bc, (ix - 39)
	add	hl, bc
	ld	e, (ix - 57)
	ld	d, (ix - 56)
	ld	(hl), e
	ld	e, iyl
	ld	hl, (ix - 36)
	add	hl, bc
	ld	(hl), e
	ld	hl, (ix - 45)
	ld	l, (hl)
	ld	de, 0
	ld	e, l
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_121
; %bb.136:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	hl, (ix - 54)
	ld	c, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	bc, (ix - 39)
	sbc	hl, bc
	jp	c, .LBB30_121
; %bb.137:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	hl, (ix - 66)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 66), hl
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	add	iy, bc
	lea	hl, iy + 0
	ld	bc, 1208
	add	hl, bc
	ld	l, (hl)
	ld	de, 0
	ld	e, l
	ld	hl, (ix - 66)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	jp	m, .LBB30_122
; %bb.138:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	de, 1256
	add	iy, de
	ld	e, (iy)
	ld	l, (ix - 60)
	ld	h, (ix - 59)
	ld	l, e
	ld	(ix - 60), l
	ld	(ix - 59), h
	ld	de, (ix - 63)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	jp	m, .LBB30_134
; %bb.139:                              ;   in Loop: Header=BB30_118 Depth=1
	ld	l, 1
	ld	(ix - 48), l                    ; 1-byte Folded Spill
	jp	.LBB30_134
	.local	.LBB30_140
.LBB30_140:
	ld	hl, (ix - 39)
	ld	de, 65535
	add	hl, de
	ld	de, (ix - 27)
	or	a, a
	sbc	hl, de
	ld	(ix - 81), hl
	ld	a, 8
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	iy, (ix + 6)
	ld	de, (ix - 51)
	.local	.LBB30_141
.LBB30_141:                             ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB30_144 Depth 2
                                        ;     Child Loop BB30_165 Depth 2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	(ix - 36), bc
	jr	c, .LBB30_143
; %bb.142:                              ;   in Loop: Header=BB30_141 Depth=1
	ld	(ix - 36), de
	.local	.LBB30_143
.LBB30_143:                             ;   in Loop: Header=BB30_141 Depth=1
	dec	de
	ld	(ix - 51), de
	push	bc
	pop	hl
	push	bc
	pop	de
	ld	bc, 6
	call	__imulu
	push	de
	pop	bc
	ex	de, hl
	lea	hl, iy + 0
	add	hl, de
	ld	(ix - 42), hl
	.local	.LBB30_144
.LBB30_144:                             ;   Parent Loop BB30_141 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	hl, (ix - 36)
	or	a, a
	sbc	hl, bc
	jp	z, .LBB30_195
; %bb.145:                              ;   in Loop: Header=BB30_144 Depth=2
	push	bc
	pop	de
	inc	de
	ld	hl, (ix - 51)
	ld	(ix - 72), bc
	or	a, a
	sbc	hl, bc
	ld	hl, 0
	jr	z, .LBB30_147
; %bb.146:                              ;   in Loop: Header=BB30_144 Depth=2
	push	de
	pop	hl
	.local	.LBB30_147
.LBB30_147:                             ;   in Loop: Header=BB30_144 Depth=2
	ld	(ix - 75), de
	ld	iy, (ix - 42)
	ld	de, (iy)
	ld	(ix - 78), de
	ld	de, (iy + 3)
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, (ix + 6)
	add	iy, bc
	ld	bc, (iy + 3)
	ld	(ix - 66), de
	ex	de, hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB30_163
; %bb.148:                              ;   in Loop: Header=BB30_144 Depth=2
	ld	iy, (iy)
	push	bc
	pop	hl
	ld	de, (ix - 66)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB30_150
; %bb.149:                              ;   in Loop: Header=BB30_144 Depth=2
	ld	(ix - 87), iy
	jr	.LBB30_151
	.local	.LBB30_150
.LBB30_150:                             ;   in Loop: Header=BB30_144 Depth=2
	ld	de, (ix - 66)
	ld	hl, (ix - 78)
	ld	(ix - 87), hl
	ld	(ix - 66), bc
	push	de
	pop	bc
	ld	(ix - 78), iy
	.local	.LBB30_151
.LBB30_151:                             ;   in Loop: Header=BB30_144 Depth=2
	push	bc
	pop	hl
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	(ix - 90), bc
	jp	m, .LBB30_153
; %bb.152:                              ;   in Loop: Header=BB30_144 Depth=2
	push	bc
	pop	hl
	ld	de, 127
	add	hl, de
	ld	c, a
	call	__ishru
	jp	.LBB30_154
	.local	.LBB30_153
.LBB30_153:                             ;   in Loop: Header=BB30_144 Depth=2
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	c, a
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB30_154
.LBB30_154:                             ;   in Loop: Header=BB30_144 Depth=2
	ld	(ix - 84), hl
	ld	de, (ix - 66)
	push	de
	pop	hl
	push	de
	pop	iy
	ld	de, -129
	add	hl, de
	ld	c, a
	call	__ishru
	ld	(ix - 93), hl
	ld	hl, 384
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ex	de, hl
	ld	de, 129
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_156
; %bb.155:                              ;   in Loop: Header=BB30_144 Depth=2
	ld	hl, (ix - 93)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB30_156
.LBB30_156:                             ;   in Loop: Header=BB30_144 Depth=2
	ld	bc, (ix - 84)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	de, (ix - 69)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, (ix - 33)
	ld	e, l
	ld	d, h
	jp	m, .LBB30_158
; %bb.157:                              ;   in Loop: Header=BB30_144 Depth=2
	ld	e, c
	ld	d, b
	.local	.LBB30_158
.LBB30_158:                             ;   in Loop: Header=BB30_144 Depth=2
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ld	hl, (ix - 30)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	hl, (ix - 45)
                                        ; kill: def $hl killed $hl killed $uhl
	jp	m, .LBB30_160
; %bb.159:                              ;   in Loop: Header=BB30_144 Depth=2
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	.local	.LBB30_160
.LBB30_160:                             ;   in Loop: Header=BB30_144 Depth=2
	ld	(ix - 84), l
	ld	(ix - 83), h
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (ix - 27)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB30_162
; %bb.161:                              ;   in Loop: Header=BB30_144 Depth=2
	ld	hl, (ix - 81)
	add	hl, bc
	ex	de, hl
	scf
	sbc	hl, hl
	ld	iy, (ix - 54)
	ld	c, (iy)
	call	__ishl
	push	de
	pop	bc
	call	__iand
	push	hl
	pop	iy
	ld	de, (ix - 27)
	add	iy, de
	.local	.LBB30_162
.LBB30_162:                             ;   in Loop: Header=BB30_144 Depth=2
	lea	hl, iy + 0
	ld	c, 8
	call	__ishl
	ld	(ix - 96), hl
	lea	hl, iy + 0
	call	__ishl
	call	__ishrs
	ld	(ix - 93), hl
	ld	e, (ix - 84)
	ld	d, (ix - 83)
	ld	a, d
	rlc	a
	ld	a, c
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 84), hl
	ld	de, (ix - 93)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	de, (ix - 66)
	jp	p, .LBB30_164
	.local	.LBB30_163
.LBB30_163:                             ; %.backedge148
                                        ;   in Loop: Header=BB30_144 Depth=2
	ld	iy, (ix - 42)
	lea	iy, iy + 6
	ld	(ix - 42), iy
	ld	bc, (ix - 75)
	ld	iy, (ix + 6)
	jp	.LBB30_144
	.local	.LBB30_164
.LBB30_164:                             ;   in Loop: Header=BB30_141 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(ix - 75), l
	ld	hl, (ix - 78)
	ld	bc, (ix - 87)
	sbc	hl, bc
	push	hl
	pop	bc
	ex	de, hl
	ld	de, (ix - 90)
	or	a, a
	sbc	hl, de
	push	hl
	push	bc
	ld	(ix - 66), iy
	call	_edge_x_step
	ld	(ix - 51), hl
	ld	d, e
	pop	hl
	pop	hl
	ld	hl, (ix - 87)
	ld	(ix - 24), hl
	ld	a, (ix - 22)
	rlc	a
	sbc	a, a
	ld	(ix - 36), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 96)
	ld	bc, (ix - 90)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	iy
	ld	bc, 128
	add	iy, bc
	ld	(ix - 21), iy
	ld	a, (ix - 19)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 51)
	lea	bc, iy + 0
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshrs
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix - 87)
	ld	a, (ix - 36)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(ix - 36), hl
	ld	(ix - 42), e                    ; 1-byte Folded Spill
	ld	hl, (ix - 51)
	ld	e, d
	ld	bc, (ix - 39)
	ld	a, (ix - 75)                    ; 1-byte Folded Reload
	call	__lmulu
	ld	c, 8
	ld	(ix - 75), hl
	ld	(ix - 78), e                    ; 1-byte Folded Spill
	ld	hl, (ix - 72)
	inc	hl
	ld	(ix - 72), hl
	ld	hl, (ix - 66)
	ld	iy, (ix + 6)
	.local	.LBB30_165
.LBB30_165:                             ;   Parent Loop BB30_141 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	hl, (ix - 84)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_193
; %bb.166:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	(ix - 51), de
	ex	de, hl
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, _span_left
	add	iy, de
	ld	bc, (iy)
	ld	(ix - 18), bc
	ld	a, (ix - 16)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 36)
	ld	e, (ix - 42)                    ; 1-byte Folded Reload
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB30_176
; %bb.167:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, (ix - 36)
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	ld	a, 1
	jp	m, .LBB30_169
; %bb.168:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	a, 0
	.local	.LBB30_169
.LBB30_169:                             ;   in Loop: Header=BB30_165 Depth=2
	bit	0, a
	ld	bc, (ix - 36)
	jr	nz, .LBB30_171
; %bb.170:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	bc, 1048576
	.local	.LBB30_171
.LBB30_171:                             ;   in Loop: Header=BB30_165 Depth=2
	bit	0, a
	ld	a, e
	jr	nz, .LBB30_173
; %bb.172:                              ;   in Loop: Header=BB30_165 Depth=2
	xor	a, a
	.local	.LBB30_173
.LBB30_173:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, -1048576
	ld	e, -1
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB30_175
; %bb.174:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	bc, -1048576
	.local	.LBB30_175
.LBB30_175:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	(iy), bc
	.local	.LBB30_176
.LBB30_176:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, (ix - 51)
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, _span_right
	add	iy, de
	ld	d, (ix - 42)                    ; 1-byte Folded Reload
	ld	hl, (iy)
	ld	(ix - 15), hl
	ld	a, (ix - 13)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 36)
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB30_186
; %bb.177:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, (ix - 36)
	ld	e, d
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	ld	a, 1
	jp	m, .LBB30_179
; %bb.178:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	a, 0
	.local	.LBB30_179
.LBB30_179:                             ;   in Loop: Header=BB30_165 Depth=2
	bit	0, a
	ld	bc, (ix - 36)
	jr	nz, .LBB30_181
; %bb.180:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	bc, 1048576
	.local	.LBB30_181
.LBB30_181:                             ;   in Loop: Header=BB30_165 Depth=2
	bit	0, a
	ld	a, d
	jr	nz, .LBB30_183
; %bb.182:                              ;   in Loop: Header=BB30_165 Depth=2
	xor	a, a
	.local	.LBB30_183
.LBB30_183:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, -1048576
	ld	e, -1
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB30_185
; %bb.184:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	bc, -1048576
	.local	.LBB30_185
.LBB30_185:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	(iy), bc
	.local	.LBB30_186
.LBB30_186:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, (ix - 51)
	ld	de, (ix - 39)
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 84)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, -1
	jp	m, .LBB30_188
; %bb.187:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	a, 0
	.local	.LBB30_188
.LBB30_188:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	(ix - 51), de
	bit	0, a
	ld	hl, 0
	ld	iy, (ix + 6)
	jr	nz, .LBB30_190
; %bb.189:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	hl, (ix - 75)
	.local	.LBB30_190
.LBB30_190:                             ;   in Loop: Header=BB30_165 Depth=2
	bit	0, a
	ld	e, 0
	ld	a, (ix - 42)                    ; 1-byte Folded Reload
	jr	nz, .LBB30_192
; %bb.191:                              ;   in Loop: Header=BB30_165 Depth=2
	ld	e, (ix - 78)                    ; 1-byte Folded Reload
	.local	.LBB30_192
.LBB30_192:                             ;   in Loop: Header=BB30_165 Depth=2
	ld	bc, (ix - 36)
	call	__ladd
	ld	(ix - 36), hl
	ld	(ix - 42), e                    ; 1-byte Folded Spill
	ld	a, 8
	ld	c, a
	ld	hl, (ix - 51)
	jp	.LBB30_165
	.local	.LBB30_193
.LBB30_193:                             ;   in Loop: Header=BB30_141 Depth=1
	ld	hl, (ix - 57)
	ld	a, (hl)
	ld	de, 0
	ld	e, a
	ld	a, 8
	ld	bc, (ix - 72)
	jp	.LBB30_141
	.local	.LBB30_194
.LBB30_194:
	ld	a, (ix - 48)                    ; 1-byte Folded Reload
	jp	.LBB30_59
	.local	.LBB30_195
.LBB30_195:
	ld	hl, (ix - 33)
	ld	a, l
	ld	de, 149
	lea	hl, iy + 0
	add	iy, de
	ld	(iy), a
	ld	de, (ix - 45)
	ld	a, e
	ld	de, 150
	push	hl
	pop	iy
	add	iy, de
	ld	(iy), a
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB30_197
; %bb.196:
	ld	hl, _render_benchmark+70
	ld	hl, (hl)
	ld	(ix - 27), hl
	ld	hl, (ix - 30)
	ld	de, (ix - 69)
	or	a, a
	sbc	hl, de
	ld	iy, (ix - 54)
	ld	c, (iy)
	call	__ishrs
	ex	de, hl
	ld	hl, (ix - 27)
	add.sis	hl, de
	inc.sis	hl
	ld	iy, _render_benchmark+70
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB30_197
.LBB30_197:
	ld	a, (_active_render_width)
	ld	l, a
	ld	d, 0
	ld	(ix - 57), e
	ld	(ix - 56), d
	ld	h, d
	ld	(ix - 45), l
	ld	(ix - 44), h
	dec.sis	hl
	ld	(ix - 51), l
	ld	(ix - 50), h
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	lea	hl, iy + 48
	ld	(ix - 27), hl
	lea	iy, iy + 96
	ld	c, 8
	xor	a, a
	ld	hl, (ix - 33)
	.local	.LBB30_198
.LBB30_198:                             ; =>This Inner Loop Header: Depth=1
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	hl, (ix - 30)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_59
; %bb.199:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	(ix - 33), iy
	push	de
	pop	hl
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_left
	add	hl, bc
	ld	hl, (hl)
	push	hl
	pop	iy
	push	de
	pop	bc
	ld	de, 1048577
	or	a, a
	sbc	hl, de
	jr	nz, .LBB30_202
; %bb.200:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	hl, (ix - 27)
	add	hl, bc
	ld	(hl), -1
	ld	iy, (ix - 33)
	lea	hl, iy + 0
	add	hl, bc
	ld	(hl), 0
	.local	.LBB30_201
.LBB30_201:                             ;   in Loop: Header=BB30_198 Depth=1
	push	bc
	pop	de
	jp	.LBB30_221
	.local	.LBB30_202
.LBB30_202:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	ld	(ix - 36), bc
	lea	bc, iy + 0
	push	bc
	pop	hl
	ld	iy, 128
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_204
; %bb.203:                              ;   in Loop: Header=BB30_198 Depth=1
	push	bc
	pop	hl
	ld	bc, 127
	add	hl, bc
	ld	a, 8
	ld	c, a
	call	__ishru
	jp	.LBB30_205
	.local	.LBB30_204
.LBB30_204:                             ;   in Loop: Header=BB30_198 Depth=1
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	a, 8
	ld	c, a
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB30_205
.LBB30_205:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	(ix - 48), hl
	ld	hl, (ix - 36)
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_right
	add	hl, bc
	ld	iy, (hl)
	lea	hl, iy + 0
	ld	de, -128
	add	hl, de
	ld	c, a
	call	__ishru
	ld	(ix - 42), hl
	ld	hl, 383
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ld	c, l
	ld	b, h
	ex	de, hl
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_207
; %bb.206:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	hl, (ix - 42)
	ld	c, l
	ld	b, h
	.local	.LBB30_207
.LBB30_207:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	(ix - 42), c
	ld	(ix - 41), b
	ld	iy, (ix - 48)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 1
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	c, iyl
	ld	b, iyh
	jp	p, .LBB30_209
; %bb.208:                              ;   in Loop: Header=BB30_198 Depth=1
	ld.sis	bc, 0
	.local	.LBB30_209
.LBB30_209:                             ;   in Loop: Header=BB30_198 Depth=1
	push	hl
	ld	l, (ix - 42)
	ld	h, (ix - 41)
	ex	(sp), hl
	pop	iy
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	e, (ix - 45)
	ld	d, (ix - 44)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB30_211
; %bb.210:                              ;   in Loop: Header=BB30_198 Depth=1
	push	hl
	ld	l, (ix - 51)
	ld	h, (ix - 50)
	ex	(sp), hl
	pop	iy
	.local	.LBB30_211
.LBB30_211:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ld	(ix - 69), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	ld	de, (ix - 36)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	iy, (ix - 33)
	jp	p, .LBB30_213
; %bb.212:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	hl, (ix - 27)
	add	hl, de
	ld	(hl), -1
	lea	hl, iy + 0
	add	hl, de
	ld	(hl), 0
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	jp	.LBB30_221
	.local	.LBB30_213
.LBB30_213:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	(ix - 42), l
	ld	(ix - 41), h
	ld	hl, (ix - 27)
	add	hl, de
	ld	(hl), c
	ld	l, (ix - 42)
	ld	h, (ix - 41)
	ld	a, l
	lea	hl, iy + 0
	add	hl, de
	ld	(hl), a
	ld	hl, (ix - 54)
	ld	a, (hl)
	or	a, a
	ld	a, 1
	jp	nz, .LBB30_221
; %bb.214:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	hl, (ix - 60)
	ld	a, (hl)
	ex	de, hl
	ld	de, 0
	ld	e, a
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB30_216
; %bb.215:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	hl, (ix - 63)
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	push	bc
	pop	de
	sbc	hl, de
	jr	nc, .LBB30_217
	.local	.LBB30_216
.LBB30_216:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	jp	.LBB30_201
	.local	.LBB30_217
.LBB30_217:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	de, (ix - 69)
	ld	l, (ix - 42)
	ld	h, (ix - 41)
	ld	e, l
	ld	d, h
	ld	hl, (ix + 9)
	add	hl, bc
	ld	(ix - 42), hl
	ld	bc, 1208
	add	hl, bc
	ld	a, (hl)
	ld	bc, 0
	ld	c, a
	ex	de, hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB30_219
; %bb.218:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	de, (ix - 36)
	jr	.LBB30_221
	.local	.LBB30_219
.LBB30_219:                             ;   in Loop: Header=BB30_198 Depth=1
	ld	de, 1256
	ld	hl, (ix - 42)
	add	hl, de
	ld	a, (hl)
	ld	l, (ix - 57)
	ld	h, (ix - 56)
	ld	l, a
	ld	(ix - 57), l
	ld	(ix - 56), h
	ld	de, (ix - 48)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	de, (ix - 36)
	jp	m, .LBB30_221
; %bb.220:                              ;   in Loop: Header=BB30_198 Depth=1
	ld	a, 1
	.local	.LBB30_221
.LBB30_221:                             ;   in Loop: Header=BB30_198 Depth=1
	ex	de, hl
	ld	de, (ix - 39)
	add	hl, de
	ld	c, 8
	jp	.LBB30_198
	.local	.Lfunc_end30
.Lfunc_end30:
	.size	_rasterize_polygon, .Lfunc_end30-_rasterize_polygon
                                        ; -- End function
	.section	.text._camera_axis_scaled,"ax",@progbits
	.type	_camera_axis_scaled,@function   ; -- Begin function camera_axis_scaled
_camera_axis_scaled:                    ; @camera_axis_scaled
; %bb.0:
	ld	hl, -24
	call	__frameset
	ld	iy, (ix + 9)
	ld	de, (ix + 12)
	sbc	hl, hl
	adc	hl, de
	ld	(ix - 21), de
	jr	nz, .LBB31_3
; %bb.1:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB31_4
; %bb.2:
	ld	de, (ix + 18)
	lea	hl, iy + 15
	jr	.LBB31_5
	.local	.LBB31_3
.LBB31_3:
	lea	hl, iy + 9
	jr	.LBB31_5
	.local	.LBB31_4
.LBB31_4:
	lea	hl, iy + 12
	.local	.LBB31_5
.LBB31_5:
	push	de
	pop	iy
	ld	de, (hl)
	push	de
	pop	hl
	call	__ineg
	ld	(ix - 24), hl
	ld	bc, 1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB31_7
; %bb.6:
	ld	de, (ix - 24)
	.local	.LBB31_7
.LBB31_7:
	ld	(ix - 18), de
	ld	a, (ix - 16)
	rlc	a
	sbc	a, a
	ld	iyl, a
	ld	bc, (ix + 21)
	ld	(ix - 15), bc
	ld	a, (ix - 13)
	rlc	a
	sbc	a, a
	ex	de, hl
	ld	e, iyl
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	hl, (ix + 6)
	ld	(hl), bc
	ld	de, (ix + 12)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB31_10
; %bb.8:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	ld	iy, (ix + 9)
	jr	nz, .LBB31_11
; %bb.9:
	ld	de, (ix + 18)
	lea	hl, iy + 24
	jr	.LBB31_12
	.local	.LBB31_10
.LBB31_10:
	ld	iy, (ix + 9)
	lea	hl, iy + 18
	jr	.LBB31_12
	.local	.LBB31_11
.LBB31_11:
	lea	hl, iy + 21
	.local	.LBB31_12
.LBB31_12:
	ld	bc, (ix + 21)
	ld	(ix - 12), bc
	ld	a, (ix - 10)
	rlc	a
	sbc	a, a
	ld	(ix - 24), a                    ; 1-byte Folded Spill
	ld	bc, (hl)
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ex	de, hl
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB31_14
; %bb.13:
	lea	bc, iy + 0
	.local	.LBB31_14
.LBB31_14:
	ld	(ix - 9), bc
	ld	a, (ix - 7)
	rlc	a
	sbc	a, a
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix + 21)
	ld	a, (ix - 24)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	iy, (ix + 6)
	ld	(iy + 3), bc
	ld	hl, (ix + 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB31_17
; %bb.15:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	ld	iy, (ix + 9)
	jr	nz, .LBB31_18
; %bb.16:
	ld	hl, (ix + 18)
	ld	(ix - 21), hl
	lea	hl, iy + 33
	jr	.LBB31_19
	.local	.LBB31_17
.LBB31_17:
	ld	iy, (ix + 9)
	lea	hl, iy + 27
	jr	.LBB31_19
	.local	.LBB31_18
.LBB31_18:
	ld	(ix - 21), de
	lea	hl, iy + 30
	.local	.LBB31_19
.LBB31_19:
	ld	de, (ix + 21)
	ld	(ix - 6), de
	ld	a, (ix - 4)
	rlc	a
	sbc	a, a
	ld	(ix - 24), a                    ; 1-byte Folded Spill
	ld	bc, (hl)
	push	bc
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ld	hl, (ix - 21)
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB31_21
; %bb.20:
	lea	bc, iy + 0
	.local	.LBB31_21
.LBB31_21:
	ld	(ix - 3), bc
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix + 21)
	ld	a, (ix - 24)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	(iy + 6), bc
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end31
.Lfunc_end31:
	.size	_camera_axis_scaled, .Lfunc_end31-_camera_axis_scaled
                                        ; -- End function
	.section	.text._edge_x_step,"ax",@progbits
	.type	_edge_x_step,@function          ; -- Begin function edge_x_step
_edge_x_step:                           ; @edge_x_step
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	hl, (ix + 6)
	ld	iy, (ix + 9)
	ld	de, -32760
	ld	bc, -32768
	add	iy, de
	add	hl, bc
	ld	de, -65535
	or	a, a
	sbc	hl, de
	jr	c, .LBB32_2
; %bb.1:
	ld	de, -32504
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	nc, .LBB32_5
	.local	.LBB32_2
.LBB32_2:
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB32_4
; %bb.3:
	ld	hl, _render_benchmark+84
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	.local	.LBB32_4
.LBB32_4:
	ld	bc, (ix + 6)
	ld	(ix - 6), bc
	ld	a, (ix - 4)
	rlc	a
	sbc	a, a
	ld	l, 8
	call	__lshl
	ld	e, a
	ld	iy, (ix + 9)
	ld	(ix - 3), iy
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	push	bc
	pop	hl
	lea	bc, iy + 0
	call	__ldivs
	jr	.LBB32_6
	.local	.LBB32_5
.LBB32_5:
	ld	de, 8
	ld	iy, _edge_reciprocal_table
	ld	hl, (ix + 9)
	add	hl, de
	ld	c, 4
	call	__ishru
	ld	bc, (ix + 6)
	ld	(ix - 10), bc
	ld	a, (ix - 8)
	rlc	a
	sbc	a, a
	add	hl, hl
	ex	de, hl
	add	iy, de
	ld	de, (iy)
	ld	l, 0
	ld	(ix - 7), l
	ld	hl, (ix - 9)
	ld	h, d
	ld	l, e
	ld	de, 0
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 12
	call	__lshrs
	push	bc
	pop	hl
	ld	e, a
	.local	.LBB32_6
.LBB32_6:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end32
.Lfunc_end32:
	.size	_edge_x_step, .Lfunc_end32-_edge_x_step
                                        ; -- End function
	.section	.text._true3d_level_open,"ax",@progbits
	.globl	_true3d_level_open              ; -- Begin function true3d_level_open
	.type	_true3d_level_open,@function
_true3d_level_open:                     ; @true3d_level_open
; %bb.0:
	ld	hl, -4
	call	__frameset
	ld	hl, (ix + 6)
	xor	a, a
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB33_7
; %bb.1:
	ld	iy, (ix + 9)
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB33_7
; %bb.2:
	ld	hl, _.str.3
	ld	de, _.str.1.4
	ld	(iy), 0
	ld	(iy + 1), 0
	push	de
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB33_5
; %bb.3:
	ld	l, e
	push	hl
	ld	(ix - 1), e                     ; 1-byte Folded Spill
	call	_ti_GetDataPtr
	ld	(ix - 4), hl
	pop	hl
	ld	l, (ix - 1)                     ; 1-byte Folded Reload
	push	hl
	call	_ti_GetSize
	pop	de
	ld	de, 0
	ld	e, l
	ld	d, h
	push	de
	ld	hl, (ix - 4)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_bind_level
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jr	nz, .LBB33_6
; %bb.4:
	ld	l, (ix - 1)                     ; 1-byte Folded Reload
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB33_5
.LBB33_5:
	ld	hl, _builtin_level
	ld	de, 66
	push	de
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_bind_level
	pop	hl
	pop	hl
	pop	hl
	jr	.LBB33_7
	.local	.LBB33_6
.LBB33_6:
	ld	a, 1
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	ld	l, (ix - 1)
	ld	(iy), l
	ld	(iy + 1), a
	.local	.LBB33_7
.LBB33_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end33
.Lfunc_end33:
	.size	_true3d_level_open, .Lfunc_end33-_true3d_level_open
                                        ; -- End function
	.section	.text._bind_level,"ax",@progbits
	.type	_bind_level,@function           ; -- Begin function bind_level
_bind_level:                            ; @bind_level
; %bb.0:
	ld	hl, -19
	call	__frameset
	ld	hl, (ix + 6)
	ld	c, 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB34_20
; %bb.1:
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB34_20
; %bb.2:
	ld	hl, (ix + 12)
	ld	de, 30
	or	a, a
	sbc	hl, de
	jp	c, .LBB34_20
; %bb.3:
	ld	iy, (ix + 9)
	ld	a, (iy)
	cp	a, 84
	jp	nz, .LBB34_20
; %bb.4:
	ld	a, (iy + 1)
	cp	a, 51
	jp	nz, .LBB34_20
; %bb.5:
	ld	a, (iy + 2)
	cp	a, 68
	jp	nz, .LBB34_20
; %bb.6:
	ld	a, (iy + 3)
	cp	a, 49
	jp	nz, .LBB34_20
; %bb.7:
	ld	a, (iy + 4)
	cp	a, 1
	jp	nz, .LBB34_20
; %bb.8:
	ld	l, -9
	ld	h, (iy + 5)
	ld	a, h
	add	a, l
	ld	l, a
	cp	a, -8
	jp	c, .LBB34_20
; %bb.9:
	ld	a, (iy + 6)
	cp	a, h
	jp	nc, .LBB34_20
; %bb.10:
	ld	(ix - 4), a                     ; 1-byte Folded Spill
	ld	bc, 18
	ld	a, h
	or	a, a
	sbc	hl, hl
	ld	(ix - 1), a                     ; 1-byte Folded Spill
	ld	l, a
	call	__imulu
	add	hl, de
	ex	de, hl
	ld	hl, (ix + 12)
	or	a, a
	sbc	hl, de
	jp	c, .LBB34_34
; %bb.11:
	ld	e, 1
	or	a, a
	sbc	hl, hl
	ld	(ix - 16), hl
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	lea	hl, iy + 30
	ld	(ix - 7), hl
	lea	iy, iy + 42
	ld	d, 0
	.local	.LBB34_12
.LBB34_12:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB34_17 Depth 2
	ld	a, d
	ld	l, (ix - 1)
	cp	a, l
	jp	z, .LBB34_22
; %bb.13:                               ;   in Loop: Header=BB34_12 Depth=1
	ld	(ix - 19), iy
	or	a, a
	sbc	hl, hl
	ld	l, d
	call	__imulu
	push	hl
	pop	bc
	ld	iy, (ix - 7)
	add	iy, bc
	ld	bc, (iy + 2)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 10), hl
	ld	hl, (iy)
	ld	(ix - 13), hl
	ld	a, h
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	hl, (ix - 13)
	ld	c, l
	ld	b, h
	ld	hl, (ix - 10)
	or	a, a
	sbc	hl, bc
	ld	bc, 512
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB34_34
; %bb.14:                               ;   in Loop: Header=BB34_12 Depth=1
	ld	bc, (iy + 6)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 10), hl
	ld	hl, (iy + 4)
	ld	(ix - 13), hl
	ld	a, h
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	hl, (ix - 13)
	ld	c, l
	ld	b, h
	ld	hl, (ix - 10)
	or	a, a
	sbc	hl, bc
	ld	bc, 512
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB34_34
; %bb.15:                               ;   in Loop: Header=BB34_12 Depth=1
	ld	bc, (iy + 10)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 10), hl
	ld	iy, (iy + 8)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ld	b, iyh
	ld	hl, (ix - 10)
	or	a, a
	sbc	hl, bc
	ld	bc, 512
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB34_34
; %bb.16:                               ;   in Loop: Header=BB34_12 Depth=1
	ld	iy, 0
	.local	.LBB34_17
.LBB34_17:                              ;   Parent Loop BB34_12 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	bc, 6
	or	a, a
	sbc	hl, bc
	jr	z, .LBB34_19
; %bb.18:                               ;   in Loop: Header=BB34_17 Depth=2
	ld	hl, (ix - 19)
	lea	bc, iy + 0
	add	hl, bc
	inc	bc
	push	bc
	pop	iy
	ld	a, (hl)
	cp	a, 13
	jp	nc, .LBB34_34
	jr	.LBB34_17
	.local	.LBB34_19
.LBB34_19:                              ;   in Loop: Header=BB34_12 Depth=1
	inc	d
	ld	iy, (ix - 19)
	lea	iy, iy + 18
	ld	bc, 18
	jp	.LBB34_12
	.local	.LBB34_20
.LBB34_20:
	ld	e, c
	.local	.LBB34_21
.LBB34_21:                              ; %.loopexit
	ld	a, e
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB34_22
.LBB34_22:
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 4)                     ; 1-byte Folded Reload
	ld	bc, 18
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 7)
	add	hl, bc
	ld	iy, (ix + 9)
	ld	bc, (iy + 8)
	ld	(ix - 4), hl
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB34_34
; %bb.23:
	ld	iy, (ix - 4)
	ld	iy, (iy + 2)
	ld	l, c
	ld	h, b
	lea	bc, iy + 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB34_34
; %bb.24:
	ld	iy, (ix + 9)
	ld	bc, (iy + 10)
	ld	iy, (ix - 4)
	ld	hl, (iy + 4)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB34_34
; %bb.25:
	ld	iy, (ix - 4)
	ld	iy, (iy + 6)
	ld	l, c
	ld	h, b
	lea	bc, iy + 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB34_34
; %bb.26:
	ld	iy, (ix + 9)
	ld	bc, (iy + 12)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	(ix - 13), bc
	ld	l, c
	ld	h, b
	ld	(ix - 10), hl
	ld	iy, (ix - 4)
	ld	bc, (iy + 8)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 64
	add	hl, bc
	push	hl
	pop	bc
	ld	hl, (ix - 10)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB34_34
; %bb.27:
	ld	iy, (ix - 4)
	ld	bc, (iy + 10)
	ld	hl, (ix - 13)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB34_34
; %bb.28:
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	ld	d, (iy + 7)
	lea	iy, iy + 15
	.local	.LBB34_29
.LBB34_29:                              ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 16)
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jp	z, .LBB34_35
; %bb.30:                               ;   in Loop: Header=BB34_29 Depth=1
	ld	hl, 1
	ld	bc, (ix - 16)
                                        ; kill: def $c killed $c killed $ubc
	call	__ishl
	ld	a, l
	and	a, d
	ld	l, a
	or	a, a
	jr	nz, .LBB34_32
	.local	.LBB34_31
.LBB34_31:                              ;   in Loop: Header=BB34_29 Depth=1
	ld	hl, (ix - 16)
	inc	hl
	ld	(ix - 16), hl
	lea	iy, iy + 8
	jp	.LBB34_29
	.local	.LBB34_32
.LBB34_32:                              ;   in Loop: Header=BB34_29 Depth=1
	ld	a, (iy - 1)
	ld	l, (ix - 1)
	cp	a, l
	jr	nc, .LBB34_34
; %bb.33:                               ;   in Loop: Header=BB34_29 Depth=1
	ld	a, (iy)
	cp	a, 6
	jr	c, .LBB34_31
	.local	.LBB34_34
.LBB34_34:
	ld	e, 0
	jp	.LBB34_21
	.local	.LBB34_35
.LBB34_35:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	hl, (ix + 9)
	ld	(iy), hl
	ld	hl, (ix - 7)
	ld	(iy + 3), hl
	jp	.LBB34_21
	.local	.Lfunc_end34
.Lfunc_end34:
	.size	_bind_level, .Lfunc_end34-_bind_level
                                        ; -- End function
	.section	.text._true3d_level_builtin_view,"ax",@progbits
	.globl	_true3d_level_builtin_view      ; -- Begin function true3d_level_builtin_view
	.type	_true3d_level_builtin_view,@function
_true3d_level_builtin_view:             ; @true3d_level_builtin_view
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	de, _builtin_level
	ld	bc, 66
	push	bc
	push	de
	push	hl
	call	_bind_level
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end35
.Lfunc_end35:
	.size	_true3d_level_builtin_view, .Lfunc_end35-_true3d_level_builtin_view
                                        ; -- End function
	.section	.text._true3d_level_close,"ax",@progbits
	.globl	_true3d_level_close             ; -- Begin function true3d_level_close
	.type	_true3d_level_close,@function
_true3d_level_close:                    ; @true3d_level_close
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB36_3
; %bb.1:
	ld	l, (iy)
	ld	a, l
	or	a, a
	jp	z, .LBB36_3
; %bb.2:
                                        ; kill: def $l killed $l def $uhl
	push	hl
	call	_ti_Close
	pop	hl
	ld	iy, (ix + 6)
	ld	(iy), 0
	ld	(iy + 1), 0
	.local	.LBB36_3
.LBB36_3:
	pop	ix
	ret
	.local	.Lfunc_end36
.Lfunc_end36:
	.size	_true3d_level_close, .Lfunc_end36-_true3d_level_close
                                        ; -- End function
	.section	.text._true3d_live_benchmark_run,"ax",@progbits
	.globl	_true3d_live_benchmark_run      ; -- Begin function true3d_live_benchmark_run
	.type	_true3d_live_benchmark_run,@function
_true3d_live_benchmark_run:             ; @true3d_live_benchmark_run
; %bb.0:
	ld	hl, -184
	call	__frameset
	ld	de, 147
	ld	bc, 0
	ld	iyl, b
	scf
	sbc	hl, hl
	ld	(ix - 70), hl
	ld	l, -127
	ld	(ix - 88), hl
	ld	a, 38
	ld	(ix - 74), a
	ld	hl, _.str.27
	ld	(ix - 82), hl
	ld	hl, 1295
	ld	(ix - 85), hl
	ld	hl, 525825
	ld	(ix - 77), hl
	lea	hl, ix - 59
	ld	(ix - 73), hl
	ld.sis	hl, 0
	ld	(ix - 79), l
	ld	(ix - 78), h
	ld	(ix - 64), l
	ld	(ix - 63), h
	push	af
	ld	a, iyl
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	pop	af
	.local	.LBB37_1
.LBB37_1:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB37_7
; %bb.2:                                ;   in Loop: Header=BB37_1 Depth=1
	ld	iy, _live_route
	add	iy, bc
	ld	de, (iy)
	ld	(ix - 91), de
	sbc.sis	hl, hl
	adc.sis	hl, de
	jr	z, .LBB37_10
; %bb.3:                                ;   in Loop: Header=BB37_1 Depth=1
	ld	a, (iy + 6)
	cp	a, 10
	jr	nc, .LBB37_10
; %bb.4:                                ;   in Loop: Header=BB37_1 Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB37_6
; %bb.5:                                ;   in Loop: Header=BB37_1 Depth=1
	ld	l, (ix - 67)
	cp	a, l
	jr	c, .LBB37_10
	.local	.LBB37_6
.LBB37_6:                               ;   in Loop: Header=BB37_1 Depth=1
	ld	e, (ix - 64)
	ld	d, (ix - 63)
	ld	iy, (ix - 91)
	add.sis	iy, de
	push	bc
	pop	hl
	ld	de, 7
	add	hl, de
	push	hl
	pop	bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 64), l
	ld	(ix - 63), h
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	ld	de, 147
	jr	.LBB37_1
	.local	.LBB37_7
.LBB37_7:
	ld.sis	de, 854
	ld	l, (ix - 64)
	ld	h, (ix - 63)
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB37_10
; %bb.8:
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	cp	a, 9
	jr	nz, .LBB37_10
; %bb.9:
	ld	hl, _live_level
	push	hl
	call	_true3d_level_builtin_view
	pop	hl
	or	a, a
	jr	nz, .LBB37_13
	.local	.LBB37_10
.LBB37_10:                              ; %.loopexit22
	ld	hl, _.str.5
	.local	.LBB37_11
.LBB37_11:
	push	hl
	call	_live_show_failure
	pop	hl
	ld	hl, 1
	.local	.LBB37_12
.LBB37_12:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB37_13
.LBB37_13:
	ld	hl, _.str.2.6
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.5.7
	push	hl
	ld	hl, _.str.2.6
	push	hl
	call	_ti_Open
	ld	l, a
	pop	de
	pop	de
	ld	(_live_report_handle), a
	or	a, a
	jr	z, .LBB37_18
; %bb.14:
	push	hl
	ld	hl, 21768
	push	hl
	call	_ti_Resize
	pop	de
	pop	de
	ld	a, (_live_report_handle)
	ld	e, a
	ld	bc, 21768
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB37_17
; %bb.15:
	push	de
	call	_ti_GetDataPtr
	pop	de
	ld	(_live_report), hl
	push	hl
	pop	iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB37_19
; %bb.16:
	ld	a, (_live_report_handle)
	ld	e, a
	.local	.LBB37_17
.LBB37_17:
	push	de
	call	_ti_Close
	pop	hl
	xor	a, a
	ld	(_live_report_handle), a
	ld	hl, _.str.2.6
	push	hl
	call	_ti_Delete
	pop	hl
	.local	.LBB37_18
.LBB37_18:
	ld	hl, _.str.1.8
	jr	.LBB37_11
	.local	.LBB37_19
.LBB37_19:
	ld	(iy), 0
	lea	hl, iy + 0
	inc	hl
	ld	bc, 21767
	ex	de, hl
	ld	(ix - 97), iy
	lea	hl, iy + 0
	ldir
	ld	bc, 10
	ld	de, 0
	xor	a, a
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	ld.sis	hl, 0
	ld	(ix - 91), l
	ld	(ix - 90), h
	.local	.LBB37_20
.LBB37_20:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB37_26 Depth 2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB37_33
; %bb.21:                               ;   in Loop: Header=BB37_20 Depth=1
	push	de
	pop	hl
	ld	bc, 116
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 97)
	add	hl, bc
	ld	(ix - 100), hl
	ld	(ix - 64), de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _live_sections
	add	hl, de
	ld	(ix - 106), hl
	ld	hl, (hl)
	ld	(ix - 103), hl
	push	hl
	call	_strlen
	ld	(ix - 109), hl
	pop	hl
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	cp	a, 22
	jr	nc, .LBB37_23
; %bb.22:                               ;   in Loop: Header=BB37_20 Depth=1
	ld	a, 21
	.local	.LBB37_23
.LBB37_23:                              ;   in Loop: Header=BB37_20 Depth=1
	ld	de, 0
	ld	e, (ix - 67)                    ; 1-byte Folded Reload
	push	de
	pop	hl
	ld	bc, 22
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	ld	bc, 7
	jr	nc, .LBB37_25
; %bb.24:                               ;   in Loop: Header=BB37_20 Depth=1
	ld	hl, 21
	.local	.LBB37_25
.LBB37_25:                              ;   in Loop: Header=BB37_20 Depth=1
	ld	(ix - 94), hl
	push	de
	pop	hl
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _live_route
	add	iy, bc
	ld	hl, (ix - 94)
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld.sis	hl, 0
	.local	.LBB37_26
.LBB37_26:                              ;   Parent Loop BB37_20 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	(ix - 94), l
	ld	(ix - 93), h
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB37_29
; %bb.27:                               ;   in Loop: Header=BB37_26 Depth=2
	ld	l, (iy + 6)
	ld	de, 0
	ld	e, l
	ld	hl, (ix - 64)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB37_30
; %bb.28:                               ;   in Loop: Header=BB37_26 Depth=2
	ld	hl, (iy)
	ld	e, (ix - 94)
	ld	d, (ix - 93)
	add.sis	hl, de
	inc	(ix - 67)
	lea	iy, iy + 7
	dec	bc
                                        ; kill: def $hl killed $hl killed $uhl
	jp	.LBB37_26
	.local	.LBB37_29
.LBB37_29:                              ;   in Loop: Header=BB37_20 Depth=1
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	.local	.LBB37_30
.LBB37_30:                              ; %.loopexit
                                        ;   in Loop: Header=BB37_20 Depth=1
	ld	l, -16
	ld	bc, (ix - 109)
	ld	a, c
	and	a, l
	ld	e, a
	push	bc
	pop	hl
	ld	bc, 255
	call	__iand
	ld	bc, (ix - 64)
	inc	bc
	ld	(ix - 64), bc
	ld	a, c
	ld	iy, (ix - 100)
	ld	(iy + 112), a
	lea	bc, iy + 0
	ld	iy, (ix - 106)
	ld	a, (iy + 3)
	push	bc
	pop	iy
	ld	(iy + 113), a
	ld	c, (ix - 91)
	ld	b, (ix - 90)
	ld	(iy + 114), c
	ld	a, b
	ld	(iy + 115), a
	ld	c, (ix - 94)
	ld	b, (ix - 93)
	ld	(iy + 116), c
	ld	a, b
	ld	(iy + 117), a
	ld	(iy + 118), -1
	ld	(iy + 119), -1
	ld	a, e
	or	a, a
	jr	z, .LBB37_32
; %bb.31:                               ; %.loopexit
                                        ;   in Loop: Header=BB37_20 Depth=1
	ld	hl, 15
	.local	.LBB37_32
.LBB37_32:                              ; %.loopexit
                                        ;   in Loop: Header=BB37_20 Depth=1
	push	hl
	ld	hl, (ix - 103)
	push	hl
	pea	iy + 120
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	l, (ix - 94)
	ld	h, (ix - 93)
	ld	e, (ix - 91)
	ld	d, (ix - 90)
	add.sis	hl, de
	ld	(ix - 91), l
	ld	(ix - 90), h
	ld	de, 10
	push	de
	pop	bc
	ld	de, (ix - 64)
	jp	.LBB37_20
	.local	.LBB37_33
.LBB37_33:
	ld	hl, -917456
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld.sis	bc, 2048
	call	__sand
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB37_35
; %bb.34:
	ld	hl, -917472
	push	hl
	call	_atomic_load_decreasing_32
	jr	.LBB37_36
	.local	.LBB37_35
.LBB37_35:
	ld	hl, -917472
	push	hl
	call	_atomic_load_increasing_32
	.local	.LBB37_36
.LBB37_36:
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	pop	hl
	ld	iy, -917456
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, -65
	call	__sand
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	ld	(-917472), hl
	xor	a, a
	ld	(-917469), a
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, -2497
	call	__sand
	ld.sis	de, 2240
	add.sis	hl, de
	ld	(iy), l
	ld	(iy + 1), h
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	call	_clock
	ld	(ix - 64), hl
	ld	(ix - 67), e                    ; 1-byte Folded Spill
	call	_engine_graphics_init
	call	_clock
	ld	bc, (ix - 64)
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	call	__lsub
	ld	bc, -137
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_engine_render_benchmark_calibrate
	ld	bc, -141
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_live_reset_state
	or	a, a
	jr	z, .LBB37_38
; %bb.37:
	call	_clock
	ld	(ix - 64), hl
	ld	(ix - 67), e                    ; 1-byte Folded Spill
	ld	hl, 300
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	call	_gfx_SwapDraw
	call	_clock
	push	hl
	pop	iy
	ld	d, e
	ld	bc, (ix - 64)
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	call	__lsub
	ld	(ix - 116), hl
	ld	(ix - 117), e                   ; 1-byte Folded Spill
	lea	hl, iy + 0
	ld	e, d
	ld	bc, (ix - 64)
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	call	__lcmpu
	jp	nz, .LBB37_57
	.local	.LBB37_38
.LBB37_38:
	xor	a, a
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -143
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -152
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	dec	de
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB37_39
.LBB37_39:
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	(ix - 94), a                    ; 1-byte Folded Spill
	ld	de, -146
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	dec	de
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -150
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	(ix - 85), a                    ; 1-byte Folded Spill
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	ld	(ix - 88), a                    ; 1-byte Folded Spill
	ld	(ix - 116), a                   ; 1-byte Folded Spill
	ld	(ix - 117), a                   ; 1-byte Folded Spill
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld	(ix - 121), a                   ; 1-byte Folded Spill
	ld	(ix - 124), a                   ; 1-byte Folded Spill
	ld	(ix - 127), a                   ; 1-byte Folded Spill
	ld	(ix - 128), a                   ; 1-byte Folded Spill
	ld	(ix - 106), a                   ; 1-byte Folded Spill
	ld	(ix - 113), a                   ; 1-byte Folded Spill
	ld	(ix - 109), a                   ; 1-byte Folded Spill
	ld	(ix - 112), a                   ; 1-byte Folded Spill
	ld.sis	hl, 0
	ld	(ix - 91), l
	ld	(ix - 90), h
	.local	.LBB37_40
.LBB37_40:
	xor	a, a
	ld	de, -156
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB37_41
.LBB37_41:
	ld	bc, 7
	ld	hl, _.str.16
	ld	iy, (_live_report)
	lea	de, iy + 0
	ldir
	ld	(iy + 8), 1
	ld	(iy + 9), 0
	ld	(iy + 10), 112
	ld	(iy + 11), 0
	ld	(iy + 12), -1
	ld	(iy + 13), 7
	ld	(iy + 14), 0
	ld	(iy + 15), 0
	ld	(iy + 16), 0
	ld	(iy + 17), -128
	ld	(iy + 18), 0
	ld	(iy + 19), 0
	ld	(iy + 20), 0
	ld	(iy + 21), -128
	ld	(iy + 22), 0
	ld	(iy + 23), 0
	ld	(iy + 24), 1
	ld	(iy + 25), 6
	ld	(iy + 26), 8
	ld	(ix - 67), iy
	ld	(iy + 27), 38
	ld	hl, 147
	push	hl
	ld	hl, _live_route
	push	hl
	ld	hl, -127
	push	hl
	ld	hl, 1875397
	push	hl
	call	_live_hash_bytes
	push	hl
	pop	iy
                                        ; kill: def $e killed $e def $ude
	ld	(ix - 64), de
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, 40
	or	a, a
	sbc	hl, hl
	.local	.LBB37_42
.LBB37_42:                              ; =>This Inner Loop Header: Depth=1
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jp	z, .LBB37_44
; %bb.43:                               ;   in Loop: Header=BB37_42 Depth=1
	ld	hl, _live_sections
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 34), hl
	pop	ix
	ld	hl, (hl)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 40), hl
	pop	ix
	push	hl
	ld	de, -159
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	ld	de, -165
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	call	_strlen
	pop	de
	push	hl
	ld	de, -168
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, (ix - 64)
	push	hl
	ld	de, -165
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_live_hash_bytes
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 34)
	pop	ix
	ld	a, (iy + 3)
	ld	c, 0
	ld	d, c
	ld	(ix - 61), d
	ld	bc, (ix - 63)
	ld	b, d
	ld	c, a
	ld	iy, 0
	ld	a, iyl
	call	__lxor
	ld	bc, 403
	ld	a, b
	call	__lmulu
	push	hl
	pop	iy
                                        ; kill: def $e killed $e def $ude
	ld	(ix - 64), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 31)
	pop	ix
	ld	de, 4
	add	hl, de
	ld	de, 40
	jp	.LBB37_42
	.local	.LBB37_44
.LBB37_44:
	ld	a, iyl
	lea	de, iy + 0
	ld	iy, (ix - 67)
	ld	(iy + 28), a
	ld	a, d
	ld	(iy + 29), a
	push	de
	pop	bc
	ld	hl, (ix - 64)
	ld	a, l
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 30), a
	ld	l, 24
	push	de
	pop	bc
	ld	de, (ix - 64)
	ld	a, e
	call	__lshru
	ld	a, c
	ld	(iy + 31), a
	ld	(iy + 32), 8
	ld	(iy + 33), 85
	ld	(iy + 34), 10
	ld	(iy + 35), 0
	ld	(iy + 36), 16
	ld	(iy + 37), 0
	ld	(iy + 38), 86
	ld	(iy + 39), 3
	ld	(iy + 40), 116
	ld	(iy + 41), 0
	ld	(iy + 42), l
	ld	(iy + 43), 0
	ld	(iy + 44), 64
	ld	(iy + 45), 48
	ld	(iy + 46), 5
	ld	(iy + 47), 1
	ld	(iy + 48), 10
	ld	(iy + 49), 11
	ld	(iy + 50), 30
	ld	(iy + 51), 0
	ld	(iy + 52), 1
	ld	(iy + 53), 0
	ld	(iy + 54), 4
	ld	(iy + 55), 0
	ld	bc, -141
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	ld	a, e
	ld	(iy + 56), a
	ld	a, d
	ld	(iy + 57), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	h, (ix - 14)                    ; 1-byte Folded Reload
	pop	ix
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 58), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 59), a
	ld	bc, -137
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	ld	a, e
	ld	(iy + 64), a
	ld	a, d
	ld	(iy + 65), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	h, (ix - 10)                    ; 1-byte Folded Reload
	pop	ix
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 66), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 67), a
	ld	de, -151
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 68), a
	ld	de, -143
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 69), a
	ld	de, -152
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 70), a
	dec	de
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 71), a
	ld	a, (ix - 97)
	ld	(iy + 72), a
	ld	a, (ix - 94)
	ld	(iy + 73), a
	ld	de, -146
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 74), a
	dec	de
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 75), a
	ld	de, -150
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 76), a
	ld	a, (ix - 85)
	ld	(iy + 77), a
	ld	a, (ix - 100)
	ld	(iy + 78), a
	ld	a, (ix - 103)
	ld	(iy + 79), a
	ld	a, (ix - 88)
	ld	(iy + 80), a
	ld	a, (ix - 116)
	ld	(iy + 81), a
	ld	a, (ix - 117)
	ld	(iy + 82), a
	ld	a, (ix - 118)
	ld	(iy + 83), a
	ld	a, (ix - 121)
	ld	(iy + 84), a
	ld	a, (ix - 124)
	ld	(iy + 85), a
	ld	a, (ix - 127)
	ld	(iy + 86), a
	ld	a, (ix - 128)
	ld	(iy + 87), a
	ld	l, (ix - 91)
	ld	h, (ix - 90)
	ld	a, l
	ld	(iy + 88), a
	ld	a, h
	ld	(iy + 89), a
	ld	l, (ix - 79)
	ld	h, (ix - 78)
	ld	(iy + 90), l
	ld	a, h
	ld	(iy + 91), a
	ld	(iy + 92), 8
	ld	(iy + 93), 85
	ld	(iy + 94), 21
	ld	(iy + 95), 0
	ld	a, (ix - 106)
	ld	(iy + 96), a
	ld	a, (ix - 113)
	ld	(iy + 97), a
	ld	a, (ix - 109)
	ld	(iy + 98), a
	ld	a, (ix - 112)
	ld	(iy + 99), a
	ld	(iy + 100), 44
	ld	(iy + 101), 1
	ld	(iy + 102), 0
	ld	(iy + 103), 1
	ld	bc, 21656
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	(ix - 85), a
	ld	(ix - 64), hl
	ld	e, d
	.local	.LBB37_45
.LBB37_45:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB37_47 Depth 2
	ld	hl, (ix - 64)
	or	a, a
	sbc	hl, bc
	jr	z, .LBB37_54
; %bb.46:                               ;   in Loop: Header=BB37_45 Depth=1
	ld	iy, (ix - 67)
	ld	bc, (ix - 64)
	add	iy, bc
	ld	a, (iy + 112)
	ld	l, 0
	ld	(ix - 60), l
	ld	bc, (ix - 62)
	ld	b, l
	ld	c, a
	ld	hl, (ix - 70)
	ld	a, (ix - 85)                    ; 1-byte Folded Reload
	call	__lxor
	ld	d, 8
	.local	.LBB37_47
.LBB37_47:                              ;   Parent Loop BB37_45 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, d
	or	a, a
	jr	z, .LBB37_53
; %bb.48:                               ;   in Loop: Header=BB37_47 Depth=2
	ld	(ix - 70), d                    ; 1-byte Folded Spill
	push	hl
	pop	iy
	ld	d, e
	ld	bc, 1
	xor	a, a
	call	__land
	ld	(ix - 88), hl
	lea	bc, iy + 0
	ld	a, d
	ld	l, 1
	call	__lshru
	ld	iyl, a
	ld	de, (ix - 88)
	ld	a, e
	xor	a, l
	ld	e, a
	bit	0, e
	ld	hl, 0
	jr	nz, .LBB37_50
; %bb.49:                               ;   in Loop: Header=BB37_47 Depth=2
	ld	hl, -4685024
	.local	.LBB37_50
.LBB37_50:                              ;   in Loop: Header=BB37_47 Depth=2
	bit	0, e
	ld	e, 0
	jr	nz, .LBB37_52
; %bb.51:                               ;   in Loop: Header=BB37_47 Depth=2
	ld	e, -19
	.local	.LBB37_52
.LBB37_52:                              ;   in Loop: Header=BB37_47 Depth=2
	ld	a, iyl
	call	__lxor
	ld	d, (ix - 70)                    ; 1-byte Folded Reload
	dec	d
	jr	.LBB37_47
	.local	.LBB37_53
.LBB37_53:                              ;   in Loop: Header=BB37_45 Depth=1
	ld	(ix - 70), hl
	ld	hl, (ix - 64)
	inc	hl
	ld	(ix - 64), hl
	ld	bc, 21656
	jp	.LBB37_45
	.local	.LBB37_54
.LBB37_54:
	ld	hl, (ix - 70)
	call	__lnot
	ld	(ix - 64), e                    ; 1-byte Folded Spill
	ld	a, l
	ld	iy, (ix - 67)
	ld	(iy + 60), a
	ld	a, h
	ex	de, hl
	ld	(iy + 61), a
	ld	l, 16
	push	de
	pop	bc
	ld	h, (ix - 64)                    ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(iy + 62), a
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(iy + 63), a
	call	_gfx_End
	ld	de, -156
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	ld	c, 0
	ld	e, c
	jp	z, .LBB37_67
; %bb.55:
	ld	l, (ix - 91)
	ld	h, (ix - 90)
	ld.sis	de, 4
	or	a, a
	sbc.sis	hl, de
	jp	z, .LBB37_62
; %bb.56:
	ld	a, 0
	jp	.LBB37_63
	.local	.LBB37_57
.LBB37_57:
	call	_live_reset_state
	or	a, a
	ld	de, (ix - 116)
	ld	a, d
	ld	bc, -143
	lea	iy, ix + 0
	push	af
	add	iy, bc
	pop	af
	ld	(iy + 0), a
	jp	z, .LBB37_115
; %bb.58:
	ld	(ix - 59), 0
	ld.sis	hl, 0
	ld	(ix - 57), l
	ld	(ix - 56), h
	ld	(ix - 55), l
	ld	(ix - 54), h
	ld	l, 16
	.local	.LBB37_59
.LBB37_59:                              ; =>This Inner Loop Header: Depth=1
	ld	a, l
	or	a, a
	jp	z, .LBB37_85
; %bb.60:                               ;   in Loop: Header=BB37_59 Depth=1
	ld	(ix - 64), l                    ; 1-byte Folded Spill
	pea	ix - 17
	pea	ix - 16
	pea	ix - 15
	pea	ix - 14
	pea	ix - 13
	pea	ix - 59
	call	_live_controller_next
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB37_114
; %bb.61:                               ;   in Loop: Header=BB37_59 Depth=1
	ld	a, (ix - 13)
	ld	iyl, a
	ld	a, (ix - 14)
	ld	e, (ix - 15)
	ld	c, (ix - 16)
	ld	hl, 30
	push	hl
	ld	hl, 1
	push	hl
                                        ; kill: def $c killed $c def $ubc
	push	bc
                                        ; kill: def $e killed $e def $ude
	push	de
	ld	l, a
	push	hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_update
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	ld	hl, 300
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	call	_gfx_SwapDraw
	ld	l, (ix - 64)                    ; 1-byte Folded Reload
	dec	l
	jp	.LBB37_59
	.local	.LBB37_62
.LBB37_62:
	ld	a, -1
	.local	.LBB37_63
.LBB37_63:
	bit	0, a
	ld	e, c
	jr	z, .LBB37_67
; %bb.64:
	ld.sis	de, 10
	ld	l, (ix - 79)
	ld	h, (ix - 78)
	or	a, a
	sbc.sis	hl, de
	ld	e, c
	jr	nz, .LBB37_67
; %bb.65:
	ld	a, (_live_report_handle)
	ld	l, a
	push	hl
	call	_ti_Close
	pop	hl
	xor	a, a
	ld	(_live_report_handle), a
	sbc	hl, hl
	ld	(_live_report), hl
	ld	hl, _.str.17
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.17
	push	hl
	ld	hl, _.str.2.6
	push	hl
	call	_ti_Rename
	pop	hl
	pop	hl
	or	a, a
	ld	a, 1
	ld	e, a
	jr	z, .LBB37_67
; %bb.66:
	ld	e, 0
	.local	.LBB37_67
.LBB37_67:
	ld	a, (_live_report_handle)
	ld	l, a
	bit	0, e
	ld	(ix - 64), e                    ; 1-byte Folded Spill
	jr	nz, .LBB37_70
; %bb.68:
	ld	a, l
	or	a, a
	jr	z, .LBB37_70
; %bb.69:
	push	hl
	call	_ti_Close
	pop	hl
	xor	a, a
	ld	(_live_report_handle), a
	ld	hl, _.str.2.6
	push	hl
	call	_ti_Delete
	pop	hl
	jr	.LBB37_74
	.local	.LBB37_70
.LBB37_70:
	bit	0, e
	jr	z, .LBB37_74
; %bb.71:
	ld	hl, _.str.18
	push	hl
	ld	hl, _.str.17
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB37_74
; %bb.72:
	push	de
	ld	hl, 1
	push	hl
	ld	(ix - 70), de
	call	_ti_SetArchiveStatus
	ld	(ix - 67), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 70)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 67)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB37_74
; %bb.73:
	ld	hl, _.str.26
	ld	(ix - 82), hl
	.local	.LBB37_74
.LBB37_74:
	ld	iy, -917456
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, -65
	call	__sand
	ld	(iy), l
	ld	(iy + 1), h
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	ld	(-917472), hl
	ld	de, -134
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	(-917469), a
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 2)
	ld	h, (ix - 1)
	pop	ix
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	bit	0, (ix - 64)                    ; 1-byte Folded Reload
	ld	hl, _.str.20
	jr	z, .LBB37_76
; %bb.75:
	ld	hl, _.str.19
	.local	.LBB37_76
.LBB37_76:
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 2
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.21
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 3
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.22
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	l, (ix - 91)
	ld	h, (ix - 90)
	ld.sis	de, 4
	or	a, a
	sbc.sis	hl, de
	ld	hl, _.str.23
	jr	z, .LBB37_78
; %bb.77:
	ld	hl, _.str.24
	.local	.LBB37_78
.LBB37_78:
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 5
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.25
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 6
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, (ix - 82)
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 8
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.28
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	(ix - 51), 0
	ld	de, -1
	ld	iy, 7
	.local	.LBB37_79
.LBB37_79:                              ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB37_81
; %bb.80:                               ;   in Loop: Header=BB37_79 Depth=1
	ld	de, (ix - 77)
	push	de
	pop	hl
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, _live_put_hex32.digits
	add	hl, bc
	ld	a, (hl)
	lea	hl, iy + 0
	ld	bc, 255
	call	__iand
	push	hl
	pop	bc
	ld	hl, (ix - 73)
	add	hl, bc
	ld	(hl), a
	push	de
	pop	bc
	ld	de, -1
	ld	a, (ix - 74)                    ; 1-byte Folded Reload
	ld	l, 4
	call	__lshru
	ld	(ix - 77), bc
	ld	(ix - 74), a                    ; 1-byte Folded Spill
	dec	iy
	jr	.LBB37_79
	.local	.LBB37_81
.LBB37_81:
	ld	hl, (ix - 73)
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 10
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.4
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB37_82
.LBB37_82:                              ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB37_82
	.local	.LBB37_83
.LBB37_83:                              ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB37_83
; %bb.84:
	ld	l, 1
	ld	a, (ix - 64)
	xor	a, l
	ld	e, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	jp	.LBB37_12
	.local	.LBB37_85
.LBB37_85:
	ld	(ix - 59), 0
	ld	hl, (ix - 73)
	push	hl
	pop	iy
	inc	iy
	ld	bc, 39
	lea	de, iy + 0
	ldir
	call	_live_reset_state
	or	a, a
	ld	a, 0
	ld	l, a
	ld	(ix - 97), l                    ; 1-byte Folded Spill
	ld	(ix - 94), l                    ; 1-byte Folded Spill
	ld	e, l
	ld	d, l
	ld	b, l
	ld	(ix - 100), l                   ; 1-byte Folded Spill
	ld	(ix - 103), l                   ; 1-byte Folded Spill
	ld	(ix - 106), l                   ; 1-byte Folded Spill
	ld	c, l
	ld	(ix - 109), l                   ; 1-byte Folded Spill
	ld	(ix - 112), l                   ; 1-byte Folded Spill
	ld.sis	hl, 0
	ld	(ix - 91), l
	ld	(ix - 90), h
	jp	z, .LBB37_146
; %bb.86:
	ld	(ix - 13), 0
	ld	(ix - 11), l
	ld	(ix - 10), h
	ld	(ix - 9), l
	ld	(ix - 8), h
	call	_clock
	ld	(ix - 112), hl
	ld	(ix - 113), e                   ; 1-byte Folded Spill
	ld	de, 21791
	ld	h, 0
	ld	(ix - 100), l
	ld	(ix - 99), h
	xor	a, a
	ld	(ix - 106), a                   ; 1-byte Folded Spill
	ld.sis	iy, 0
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 97), hl
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	push	iy
	ex	(sp), hl
	ld	(ix - 91), l
	ld	(ix - 90), h
	pop	hl
	ld	(ix - 109), hl
	ld	hl, 1875397
	ld	(ix - 103), hl
	.local	.LBB37_87
.LBB37_87:                              ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 85)
	or	a, a
	sbc	hl, de
	ld	(ix - 64), bc
	ld	a, b
	ld	(ix - 94), a
	ld	hl, _render_benchmark
	inc	hl
	ld	de, -156
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	(iy + 0), hl
	jp	z, .LBB37_116
; %bb.88:                               ;   in Loop: Header=BB37_87 Depth=1
	ld	a, (_live_state+47)
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	pea	ix - 18
	pea	ix - 17
	pea	ix - 16
	pea	ix - 15
	pea	ix - 14
	pea	ix - 13
	call	_live_controller_next
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB37_144
; %bb.89:                               ;   in Loop: Header=BB37_87 Depth=1
	call	_clock
	ld	(ix - 94), hl
	ld	(ix - 121), e                   ; 1-byte Folded Spill
	ld	d, (ix - 14)
	ld	c, (ix - 15)
	ld	e, (ix - 16)
	ld	a, (ix - 17)
	ld	hl, 30
	push	hl
	ld	hl, 1
	push	hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 25
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	l, a
	push	hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 31
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	l, e
	push	hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 34
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	ld	l, c
	push	hl
	ld	bc, -165
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), d                     ; 1-byte Folded Spill
	ld	l, d
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_update
	ld	(ix - 124), a                   ; 1-byte Folded Spill
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	call	_clock
	ld	bc, (ix - 94)
	ld	a, (ix - 121)                   ; 1-byte Folded Reload
	call	__lsub
	ld	(ix - 127), hl
	ld	(ix - 128), e                   ; 1-byte Folded Spill
	ld	a, (ix - 124)                   ; 1-byte Folded Reload
	or	a, a
	ld	a, 0
	ld	l, a
	jr	z, .LBB37_91
; %bb.90:                               ;   in Loop: Header=BB37_87 Depth=1
	ld	a, 4
	ld	l, a
	.local	.LBB37_91
.LBB37_91:                              ;   in Loop: Header=BB37_87 Depth=1
	ld	a, (_live_state+47)
	ld	e, (ix - 18)
	ld	c, (ix - 118)
	cp	a, c
	ld	bc, -151
	lea	iy, ix + 0
	push	af
	add	iy, bc
	pop	af
	ld	(iy + 0), e
	jr	nz, .LBB37_93
; %bb.92:                               ;   in Loop: Header=BB37_87 Depth=1
	ld	(ix - 118), l                   ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	de, -150
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	jr	.LBB37_94
	.local	.LBB37_93
.LBB37_93:                              ;   in Loop: Header=BB37_87 Depth=1
	inc	l
	ld	(ix - 118), l
	ld	l, (ix - 91)
	ld	h, (ix - 90)
	inc.sis	hl
	ld	(ix - 91), l
	ld	(ix - 90), h
	ld	iy, (_live_report)
	or	a, a
	sbc	hl, hl
	ld	l, e
	push	ix
	lea	ix, ix - 128
	ld	(ix - 22), hl
	pop	ix
	ld	bc, 116
	call	__imulu
	ex	de, hl
	add	iy, de
	lea	hl, iy + 0
	ld	de, 148
	add	hl, de
	ld	(ix - 94), hl
	ld	e, (ix - 100)
	ld	d, (ix - 99)
	ld	e, (hl)
	ld	bc, 149
	add	iy, bc
	ld	a, (iy)
	lea	bc, iy + 0
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	ld	(ix - 100), e
	ld	(ix - 99), d
	add.sis	hl, de
	inc.sis	hl
	ld	a, l
	ld	iy, (ix - 94)
	ld	(iy), a
	ld	a, h
	push	bc
	pop	hl
	ld	(hl), a
	.local	.LBB37_94
.LBB37_94:                              ;   in Loop: Header=BB37_87 Depth=1
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 97)
	push	hl
	call	_live_section_ends
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB37_96
; %bb.95:                               ;   in Loop: Header=BB37_87 Depth=1
	ld	l, 8
	ld	e, (ix - 118)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 118), e
	.local	.LBB37_96
.LBB37_96:                              ;   in Loop: Header=BB37_87 Depth=1
	ld	a, (_live_state+50)
	or	a, a
	jr	z, .LBB37_98
; %bb.97:                               ;   in Loop: Header=BB37_87 Depth=1
	ld	l, 16
	ld	e, (ix - 118)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 118), e
	.local	.LBB37_98
.LBB37_98:                              ;   in Loop: Header=BB37_87 Depth=1
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	bc, -156
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	hl, _render_benchmark
	ld	bc, 85
	ldir
	call	_clock
	ld	(ix - 94), hl
	ld	(ix - 121), e                   ; 1-byte Folded Spill
	ld	hl, 300
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	call	_clock
	ld	bc, (ix - 94)
	ld	a, (ix - 121)                   ; 1-byte Folded Reload
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	ld	de, -150
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, (ix - 73)
	add	iy, de
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	(ix - 121), bc
	ld	(ix - 124), a                   ; 1-byte Folded Spill
	call	__lcmpu
	jr	nc, .LBB37_100
; %bb.99:                               ;   in Loop: Header=BB37_87 Depth=1
	ld	hl, (ix - 121)
	ld	(iy), hl
	ld	a, (ix - 124)
	ld	(iy + 3), a
	ld	iy, (_live_report)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	ld	bc, 116
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	a, (ix - 106)
	ld	(iy + 118), a
	ld	hl, (ix - 109)
	ld	a, h
	ld	(iy + 119), a
	.local	.LBB37_100
.LBB37_100:                             ;   in Loop: Header=BB37_87 Depth=1
	call	_clock
	ld	(ix - 94), hl
	ld	bc, -146
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_gfx_SwapDraw
	call	_clock
	ld	bc, (ix - 94)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 18
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	ld	bc, -146
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_live_state_hash
	ld	(ix - 94), hl
	ld	bc, -152
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 97)
	push	hl
	call	_live_section_ends
	pop	hl
	pop	hl
	or	a, a
	ld	hl, (ix - 94)
	ld	a, h
	ld	de, -151
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	(iy + 0), a
	jr	nz, .LBB37_102
; %bb.101:                              ;   in Loop: Header=BB37_87 Depth=1
	ld	de, (ix - 94)
	push	de
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 24
	ld	h, (iy + 0)                     ; 1-byte Folded Reload
	ld	a, h
	ld	l, 16
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 22
	ld	(iy + 0), bc
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	iy, (_live_report)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 24), c                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 40), l                    ; 1-byte Folded Spill
	pop	ix
	ld	bc, -156
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e                         ; 1-byte Folded Spill
	jp	.LBB37_103
	.local	.LBB37_102
.LBB37_102:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	iy, (_live_report)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	ld	bc, 116
	call	__imulu
	ex	de, hl
	lea	hl, iy + 0
	add	hl, de
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 22), bc
	pop	ix
	ld	de, 144
	add	hl, de
	ld	de, (ix - 94)
	ld	a, e
	push	ix
	lea	ix, ix - 128
	ld	(ix - 28), a                    ; 1-byte Folded Spill
	pop	ix
	ld	(hl), a
	push	bc
	pop	hl
	ld	de, 145
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 23)
	pop	ix
	ld	(hl), a
	ld	bc, (ix - 94)
	ld	de, -152
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	l, 16
	call	__lshru
	ld	a, c
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	ld	de, 146
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 40), a                    ; 1-byte Folded Spill
	pop	ix
	ld	(hl), a
	ld	bc, (ix - 94)
	ld	de, -152
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	l, 24
	call	__lshru
	ld	a, c
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	ld	de, 147
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 24), a                    ; 1-byte Folded Spill
	pop	ix
	ld	(hl), a
	ld	a, (_portal_lod_state)
	ld	l, 3
	and	a, l
	ld	l, a
	ld	a, (_portal_lod_state+1)
	ld	b, 2
	call	__bshl
	ld	e, 12
	and	a, e
	ld	e, a
	ld	a, e
	add	a, l
	ld	e, a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	ld	bc, 150
	add	hl, bc
	ld	(hl), e
	ld	a, (_live_state+47)
	ld	de, 151
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	add	hl, de
	ld	(hl), a
	.local	.LBB37_103
.LBB37_103:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	de, (ix - 85)
	add	iy, de
	ld	hl, (ix - 121)
	ld	e, (ix - 124)                   ; 1-byte Folded Reload
	ld	bc, (ix - 127)
	ld	a, (ix - 128)                   ; 1-byte Folded Reload
	call	__ladd
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 18)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 19)                    ; 1-byte Folded Reload
	pop	ix
	call	__ladd
	ld	d, e
	ld	bc, 65535
	xor	a, a
	call	__lcmpu
	ld	(ix - 94), hl
	jr	c, .LBB37_105
; %bb.104:                              ;   in Loop: Header=BB37_87 Depth=1
	push	bc
	pop	hl
	.local	.LBB37_105
.LBB37_105:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	a, l
	ld	(iy - 23), a
	ld	a, h
	ld	(iy - 22), a
	ld	hl, (ix - 127)
	ld	e, (ix - 128)                   ; 1-byte Folded Reload
	xor	a, a
	call	__lcmpu
	jr	c, .LBB37_107
; %bb.106:                              ;   in Loop: Header=BB37_87 Depth=1
	push	bc
	pop	hl
	.local	.LBB37_107
.LBB37_107:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	a, l
	ld	(iy - 21), a
	ld	a, h
	ld	(iy - 20), a
	ld	hl, (ix - 121)
	ld	e, (ix - 124)                   ; 1-byte Folded Reload
	xor	a, a
	call	__lcmpu
	jr	c, .LBB37_109
; %bb.108:                              ;   in Loop: Header=BB37_87 Depth=1
	push	bc
	pop	hl
	.local	.LBB37_109
.LBB37_109:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	a, l
	ld	(iy - 19), a
	ld	a, h
	ld	(iy - 18), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 18)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 19)                    ; 1-byte Folded Reload
	pop	ix
	xor	a, a
	call	__lcmpu
	jr	c, .LBB37_111
; %bb.110:                              ;   in Loop: Header=BB37_87 Depth=1
	ld	hl, 65535
	.local	.LBB37_111
.LBB37_111:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	a, l
	ld	(iy - 17), a
	ld	a, h
	ld	(iy - 16), a
	ld	bc, -156
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)
	ld	(iy - 15), a
	ld	bc, -151
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)
	ld	(iy - 14), a
	ld	bc, -168
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)
	ld	(iy - 13), a
	ld	bc, -152
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)
	ld	(iy - 12), a
	ld	hl, (_live_state)
	ld	a, l
	ld	(iy - 11), a
	ld	a, h
	ld	(iy - 10), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(iy - 9), a
	ld	hl, (_live_state+3)
	ld	a, l
	ld	(iy - 8), a
	ld	a, h
	ld	(iy - 7), a
	call	__ishru
	ld	a, l
	ld	(iy - 6), a
	ld	hl, (_live_state+6)
	ld	a, l
	ld	(iy - 5), a
	ld	a, h
	ld	(iy - 4), a
	call	__ishru
	ld	a, l
	ld	(iy - 3), a
	ld	a, (_live_state+47)
	ld	(iy - 2), a
	ld	a, (ix - 118)
	ld	(iy - 1), a
	ld	bc, -165
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)                         ; 1-byte Folded Reload
	inc	a
	ld	l, 3
	and	a, l
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	pop	ix
	ld	b, 2
	call	__bshl
	ld	b, 4
	add	a, b
	ld	e, a
	ld	c, 12
	ld	a, e
	and	a, c
	ld	e, a
	ld	a, e
	add	a, l
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 31)                    ; 1-byte Folded Reload
	pop	ix
	call	__bshl
	ld	e, 16
	add	a, e
	ld	e, a
	ld	c, 48
	ld	a, e
	and	a, c
	ld	e, a
	ld	a, l
	add	a, e
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 25)                    ; 1-byte Folded Reload
	pop	ix
	or	a, a
	ld	e, 0
	jr	z, .LBB37_113
; %bb.112:                              ;   in Loop: Header=BB37_87 Depth=1
	ld	e, 64
	.local	.LBB37_113
.LBB37_113:                             ;   in Loop: Header=BB37_87 Depth=1
	ld	a, l
	add	a, e
	ld	l, a
	ld	(iy), l
	ld	hl, (ix - 94)
	ld	e, d
	ld	bc, (ix - 64)
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(ix - 64), hl
	ld	(ix - 67), e                    ; 1-byte Folded Spill
	ld	hl, 4
	push	hl
	pea	iy - 15
	ld	hl, (ix - 88)
	push	hl
	ld	hl, (ix - 103)
	push	hl
	call	_live_hash_bytes
	ld	bc, (ix - 64)
	ld	(ix - 103), hl
                                        ; kill: def $e killed $e def $ude
	ld	(ix - 88), de
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 109)
	inc	hl
	ld	(ix - 109), hl
	ld	hl, (ix - 97)
	inc.sis	hl
	ld	(ix - 97), hl
	inc	(ix - 106)
	ld	hl, (ix - 85)
	ld	de, 24
	add	hl, de
	ld	(ix - 85), hl
	ld	de, 21791
	jp	.LBB37_87
	.local	.LBB37_114
.LBB37_114:
	ld	de, (ix - 116)
	.local	.LBB37_115
.LBB37_115:
	ld	l, 16
	push	de
	pop	bc
	ld	h, (ix - 117)                   ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	push	bc
	pop	iy
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), e                    ; 1-byte Folded Spill
	pop	ix
	ld	de, -152
	lea	hl, ix + 0
	add	hl, de
	push	af
	ld	a, iyl
	ld	(hl), a                         ; 1-byte Folded Spill
	pop	af
	dec	de
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	xor	a, a
	jp	.LBB37_39
	.local	.LBB37_116
.LBB37_116:
	call	_clock
	ld	bc, (ix - 112)
	ld	a, (ix - 113)                   ; 1-byte Folded Reload
	call	__lsub
	ld	(ix - 112), hl
	ld	(ix - 118), e                   ; 1-byte Folded Spill
	ld	iy, (_live_report)
	ld	bc, 1160
	ld	de, 0
	.local	.LBB37_117
.LBB37_117:                             ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB37_120
; %bb.118:                              ;   in Loop: Header=BB37_117 Depth=1
	ld	(ix - 85), iy
	add	iy, de
	ld	c, (ix - 100)
	ld	b, (ix - 99)
	ld	c, (iy + 118)
	ld	a, (iy + 119)
	ld	h, b
	ld	l, a
	ex	de, hl
	ld	iyh, e
	ex	de, hl
	ld	iyl, b
	ld	(ix - 100), c
	ld	(ix - 99), b
	add.sis	iy, bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 854
	or	a, a
	sbc.sis	hl, bc
	jp	nc, .LBB37_145
; %bb.119:                              ;   in Loop: Header=BB37_117 Depth=1
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	bc, 24
	call	__imulu
	push	hl
	pop	bc
	ld	iy, (ix - 85)
	lea	hl, iy + 0
	add	hl, bc
	ld	bc, 1294
	add	hl, bc
	set	1, (hl)
	ex	de, hl
	ld	de, 116
	add	hl, de
	ex	de, hl
	ld	bc, 1160
	jr	.LBB37_117
	.local	.LBB37_120
.LBB37_120:
	ld	a, (ix - 13)
	ld	(ix - 121), a
	ld	hl, (ix - 9)
	ld	(ix - 124), hl
	ld	de, (ix - 64)
	ld	(ix - 97), e                    ; 1-byte Folded Spill
	ld	a, d
	ld	(ix - 94), a
	ld	l, 16
	push	de
	pop	bc
	ld	h, (ix - 67)                    ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 18
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	ld	h, l
	call	__lshru
	ld	de, -147
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	ld	iy, (ix - 103)
	push	ix
	lea	ix, ix - 128
	push	af
	ld	a, iyl
	ld	(ix - 22), a                    ; 1-byte Folded Spill
	pop	af
	pop	ix
	ld	a, iyh
	ld	(ix - 85), a
	lea	bc, iy + 0
	ld	de, (ix - 88)
	ld	a, e
	ld	l, 16
	call	__lshru
	ld	(ix - 100), c                   ; 1-byte Folded Spill
	lea	bc, iy + 0
	ld	a, e
	ex	de, hl
	ld	iyh, d
	ld	e, iyh
	ex	de, hl
	call	__lshru
	ld	(ix - 103), c                   ; 1-byte Folded Spill
	ld	de, (ix - 112)
	ld	(ix - 106), e                   ; 1-byte Folded Spill
	ld	a, d
	ld	(ix - 113), a
	push	de
	pop	bc
	ld	h, (ix - 118)                   ; 1-byte Folded Reload
	ld	a, h
	ld	iyl, 16
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	call	__lshru
	ld	(ix - 109), c                   ; 1-byte Folded Spill
	push	de
	pop	bc
	ld	a, h
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	call	__lshru
	ld	(ix - 112), c                   ; 1-byte Folded Spill
	ld	de, (ix - 116)
	ld	bc, -151
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e                         ; 1-byte Folded Spill
	push	de
	pop	bc
	ld	h, (ix - 117)                   ; 1-byte Folded Reload
	ld	a, h
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 24), c                    ; 1-byte Folded Spill
	pop	ix
	push	de
	pop	bc
	ld	a, h
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	call	__lshru
	ld	de, -153
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	ld	a, (ix - 121)                   ; 1-byte Folded Reload
	cp	a, 21
	jp	nz, .LBB37_147
; %bb.121:
	ld	hl, (ix - 124)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 854
	or	a, a
	sbc.sis	hl, de
	jp	nz, .LBB37_147
; %bb.122:
	call	_live_reset_state
	or	a, a
	jp	z, .LBB37_147
; %bb.123:
	ld	(ix - 13), 0
	ld.sis	hl, 0
	ld	(ix - 11), l
	ld	(ix - 10), h
	ld	(ix - 9), l
	ld	(ix - 8), h
	ld	a, h
	ld	(ix - 88), a                    ; 1-byte Folded Spill
	ld	(ix - 116), a                   ; 1-byte Folded Spill
	ld	(ix - 117), a                   ; 1-byte Folded Spill
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld	(ix - 121), a                   ; 1-byte Folded Spill
	ld	(ix - 124), a                   ; 1-byte Folded Spill
	ld	(ix - 127), a                   ; 1-byte Folded Spill
	ld	(ix - 128), a                   ; 1-byte Folded Spill
	ld	(ix - 67), l
	ld	(ix - 66), h
	ld	de, 0
	ld	(ix - 64), de
	ld	(ix - 79), l
	ld	(ix - 78), h
	.local	.LBB37_124
.LBB37_124:                             ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB37_130 Depth 2
                                        ;     Child Loop BB37_134 Depth 2
	ld	hl, (ix - 64)
	ld	de, 854
	or	a, a
	sbc	hl, de
	jp	z, .LBB37_148
; %bb.125:                              ;   in Loop: Header=BB37_124 Depth=1
	ld	a, (_live_state+47)
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	pea	ix - 18
	pea	ix - 17
	pea	ix - 16
	pea	ix - 15
	pea	ix - 14
	pea	ix - 13
	call	_live_controller_next
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB37_155
; %bb.126:                              ;   in Loop: Header=BB37_124 Depth=1
	ld	a, (ix - 14)
	ld	iyl, a
	ld	a, (ix - 15)
	ld	e, (ix - 16)
	ld	c, (ix - 17)
	ld	hl, 30
	push	hl
	ld	hl, 1
	push	hl
                                        ; kill: def $c killed $c def $ubc
	push	bc
                                        ; kill: def $e killed $e def $ude
	push	de
	ld	l, a
	push	hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_update
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	ld	a, (_live_state+47)
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	cp	a, l
	ld.sis	de, 1
	jr	nz, .LBB37_128
; %bb.127:                              ;   in Loop: Header=BB37_124 Depth=1
	ld.sis	de, 0
	.local	.LBB37_128
.LBB37_128:                             ;   in Loop: Header=BB37_124 Depth=1
	ld	l, (ix - 79)
	ld	h, (ix - 78)
	add.sis	hl, de
	ld	(ix - 79), l
	ld	(ix - 78), h
	ld	a, (ix - 18)
	ld	iy, (_live_report)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 116
	call	__imulu
	ex	de, hl
	ld	bc, -162
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	add	iy, de
	ld	l, (iy + 118)
	ld	de, 0
	ld	e, l
	ld	c, (iy + 119)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	c, 8
	call	__ishl
	add	hl, de
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	l, a
	push	hl
	ld	hl, (ix - 64)
	push	hl
	call	_live_section_ends
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	pop	hl
	pop	hl
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	bc, -156
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	hl, _render_benchmark
	ld	bc, 85
	ldir
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, (ix - 64)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB37_132
; %bb.129:                              ;   in Loop: Header=BB37_124 Depth=1
	call	_engine_render_benchmark_begin
	ld	hl, 300
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	call	_engine_render_benchmark_end
	ld	bc, (_live_report)
	push	bc
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 34)
	pop	ix
	add	iy, de
	ld	hl, _render_benchmark+64
	ld	hl, (hl)
	ld	(ix - 59), l
	ld	(ix - 58), h
	ld	hl, _render_benchmark+66
	ld	hl, (hl)
	ld	(ix - 57), l
	ld	(ix - 56), h
	ld	hl, _render_benchmark+68
	ld	hl, (hl)
	ld	(ix - 55), l
	ld	(ix - 54), h
	ld	hl, _render_benchmark+70
	ld	hl, (hl)
	ld	(ix - 53), l
	ld	(ix - 52), h
	ld	hl, _render_benchmark+72
	ld	hl, (hl)
	ld	(ix - 51), l
	ld	(ix - 50), h
	ld	hl, _render_benchmark+74
	ld	hl, (hl)
	ld	(ix - 49), l
	ld	(ix - 48), h
	ld	hl, _render_benchmark+76
	ld	hl, (hl)
	ld	(ix - 47), l
	ld	(ix - 46), h
	ld	hl, _render_benchmark+78
	ld	hl, (hl)
	ld	(ix - 45), l
	ld	(ix - 44), h
	ld	hl, _render_benchmark+80
	ld	hl, (hl)
	ld	(ix - 43), l
	ld	(ix - 42), h
	ld	hl, _render_benchmark+82
	ld	hl, (hl)
	ld	(ix - 41), l
	ld	(ix - 40), h
	ld	hl, _render_benchmark+84
	ld	hl, (hl)
	ld	(ix - 39), l
	ld	(ix - 38), h
	ld	de, -172
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, 154
	add	iy, de
	ld	de, -165
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	push	bc
	pop	hl
	ld	bc, -162
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, -175
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	or	a, a
	sbc	hl, hl
	ld	de, -168
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -40
	.local	.LBB37_130
.LBB37_130:                             ;   Parent Loop BB37_124 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB37_133
; %bb.131:                              ;   in Loop: Header=BB37_130 Depth=2
	ld	hl, _render_benchmark+40
	push	hl
	pop	iy
	ld	bc, -178
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	add	iy, de
	ld	bc, (iy)
	ld	a, (iy + 3)
	ld	l, c
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 37)
	pop	ix
	ld	(iy - 2), l
	ld	l, b
	ld	(iy - 1), l
	ld	de, -165
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy), a
	ld	de, -175
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	bc, -168
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	add	iy, de
	ld	bc, -184
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	bc, -168
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	ld	bc, 182
	add	iy, bc
	ld	bc, -181
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	iy, _render_benchmark+40
	add	iy, de
	ld	bc, (iy)
	ld	a, c
	ld	de, -181
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	(hl), a
	ld	a, b
	ld	bc, 183
	ld	de, -184
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	(hl), a
	ld	de, -178
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 4
	add	hl, de
	push	hl
	pop	bc
	ld	de, -165
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	iy, iy + 3
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -168
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 2
	add	hl, de
	ld	de, -168
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	bc
	pop	de
	jp	.LBB37_130
	.local	.LBB37_132
.LBB37_132:                             ;   in Loop: Header=BB37_124 Depth=1
	ld	hl, 300
	push	hl
	ld	hl, _live_state
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	ld	hl, (_live_report)
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	jp	.LBB37_137
	.local	.LBB37_133
.LBB37_133:                             ;   in Loop: Header=BB37_124 Depth=1
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	bc, -162
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, -165
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, 0
	.local	.LBB37_134
.LBB37_134:                             ;   Parent Loop BB37_124 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	ld	bc, 22
	or	a, a
	sbc	hl, bc
	jr	z, .LBB37_136
; %bb.135:                              ;   in Loop: Header=BB37_134 Depth=2
	ld	bc, -165
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	add	iy, de
	ld	bc, -175
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	bc, 202
	add	iy, bc
	ld	bc, -168
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	iy, (ix - 73)
	add	iy, de
	ld	bc, (iy)
	ld	a, c
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 40
	ld	hl, (iy + 0)
	ld	(hl), a
	ld	a, b
	ld	bc, 203
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 47
	ld	hl, (iy + 0)
	add	hl, bc
	ld	(hl), a
	ex	de, hl
	ld	de, 2
	add	hl, de
	ex	de, hl
	jr	.LBB37_134
	.local	.LBB37_136
.LBB37_136:                             ;   in Loop: Header=BB37_124 Depth=1
	ld	de, -172
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	hl, iy + 0
	ld	de, 224
	add	hl, de
	ld	de, (_render_benchmark+60)
	ld	a, (_render_benchmark+63)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 37), a                    ; 1-byte Folded Spill
	pop	ix
	ld	a, e
	ld	(hl), a
	ld	a, d
	lea	hl, iy + 0
	ld	bc, 225
	add	hl, bc
	ld	(hl), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 37)                    ; 1-byte Folded Reload
	pop	ix
	ld	l, 16
	call	__lshru
	ld	a, c
	lea	hl, iy + 0
	ld	bc, 226
	add	hl, bc
	ld	(hl), a
	push	de
	pop	bc
	ld	de, -165
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	de, 227
	add	iy, de
	ld	(iy), a
	ld	l, (ix - 67)
	ld	h, (ix - 66)
	inc.sis	hl
	ld	(ix - 67), l
	ld	(ix - 66), h
	.local	.LBB37_137
.LBB37_137:                             ;   in Loop: Header=BB37_124 Depth=1
	call	_live_state_hash
	ld	bc, -165
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -168
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	hl, (ix - 64)
	ld	bc, 24
	call	__imulu
	ex	de, hl
	ld	bc, -159
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	de, 1280
	add	hl, de
	push	hl
	call	_read_u32
	push	hl
	pop	bc
	ld	a, e
	pop	hl
	ld	de, -165
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 40
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmpu
	jp	nz, .LBB37_155
; %bb.138:                              ;   in Loop: Header=BB37_124 Depth=1
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	or	a, a
	jr	nz, .LBB37_140
	.local	.LBB37_139
.LBB37_139:                             ;   in Loop: Header=BB37_124 Depth=1
	call	_gfx_SwapDraw
	ld	hl, (ix - 64)
	inc	hl
	ld	(ix - 64), hl
	jp	.LBB37_124
	.local	.LBB37_140
.LBB37_140:                             ;   in Loop: Header=BB37_124 Depth=1
	ld	bc, -162
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	bc, -159
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	call	_engine_render_benchmark_logical_hash
	ld	bc, -162
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -175
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	hl, (-1900524)
	ld	de, 76800
	push	de
	push	hl
	ld	hl, -127
	push	hl
	ld	hl, 1875397
	push	hl
	call	_live_hash_bytes
	ld	bc, -172
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -169
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 144
	add	hl, de
	push	hl
	call	_read_u32
	push	hl
	pop	bc
	ld	a, e
	pop	hl
	ld	de, -165
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 40
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmpu
	jp	nz, .LBB37_155
; %bb.141:                              ;   in Loop: Header=BB37_124 Depth=1
	ld	a, (_portal_lod_state)
	ld	l, 3
	and	a, l
	ld	l, a
	ld	a, (_portal_lod_state+1)
	ld	b, 2
	call	__bshl
	ld	e, 12
	and	a, e
	ld	e, a
	ld	a, e
	add	a, l
	ld	e, a
	ld	bc, -159
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 150
	add	hl, bc
	ld	l, (hl)
	cp	a, l
	jp	nz, .LBB37_155
; %bb.142:                              ;   in Loop: Header=BB37_124 Depth=1
	ld	a, (_live_state+47)
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 151
	add	hl, de
	ld	l, (hl)
	cp	a, l
	jp	nz, .LBB37_155
; %bb.143:                              ;   in Loop: Header=BB37_124 Depth=1
	ld	de, -159
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	lea	hl, iy + 0
	ld	de, 136
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 34)
	pop	ix
	ld	a, e
	ld	(ix - 88), a                    ; 1-byte Folded Spill
	ld	(hl), a
	ld	a, d
	lea	hl, iy + 0
	ld	de, 137
	add	hl, de
	ld	(ix - 116), a                   ; 1-byte Folded Spill
	ld	(hl), a
	ld	de, -162
	lea	hl, ix + 0
	add	hl, de
	ld	bc, (hl)
	push	ix
	lea	ix, ix - 128
	ld	d, (ix - 47)                    ; 1-byte Folded Reload
	pop	ix
	ld	a, d
	ld	e, 16
	ld	l, e
	call	__lshru
	ld	a, c
	lea	hl, iy + 0
	ld	bc, 138
	add	hl, bc
	ld	(ix - 117), a                   ; 1-byte Folded Spill
	ld	(hl), a
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 34)
	pop	ix
	ld	a, d
	ld	d, 24
	ld	l, d
	call	__lshru
	ld	a, c
	lea	hl, iy + 0
	ld	bc, 139
	add	hl, bc
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld	(hl), a
	lea	hl, iy + 0
	inc	bc
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 44)
	pop	ix
	ld	a, e
	ld	(ix - 121), a                   ; 1-byte Folded Spill
	ld	(hl), a
	ld	a, d
	lea	hl, iy + 0
	inc	bc
	add	hl, bc
	ld	(ix - 124), a                   ; 1-byte Folded Spill
	ld	(hl), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 41)                    ; 1-byte Folded Reload
	pop	ix
	ld	l, 16
	call	__lshru
	ld	a, c
	lea	hl, iy + 0
	ld	bc, 142
	add	hl, bc
	ld	(ix - 127), a                   ; 1-byte Folded Spill
	ld	(hl), a
	push	de
	pop	bc
	ld	de, -169
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	de, 143
	add	iy, de
	ld	(ix - 128), a                   ; 1-byte Folded Spill
	ld	(iy), a
	jp	.LBB37_139
	.local	.LBB37_144
.LBB37_144:
	ld	l, 16
	ld	de, (ix - 64)
	push	de
	pop	bc
	ld	h, (ix - 67)                    ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	push	bc
	pop	iy
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	(ix - 97), e                    ; 1-byte Folded Spill
	ld	e, iyl
	ld	d, c
	xor	a, a
	ld	l, a
	ld	b, l
	ld	(ix - 100), l                   ; 1-byte Folded Spill
	ld	(ix - 103), l                   ; 1-byte Folded Spill
	ld	(ix - 106), l                   ; 1-byte Folded Spill
	ld	c, l
	ld	(ix - 109), l                   ; 1-byte Folded Spill
	ld	(ix - 112), l                   ; 1-byte Folded Spill
	jp	.LBB37_146
	.local	.LBB37_145
.LBB37_145:
	ld	iy, (ix - 103)
	ld	a, iyh
	ld	(ix - 85), a
	ld	hl, (ix - 112)
	ld	a, h
	ld	(ix - 113), a
	ld	l, 16
	ld	de, (ix - 64)
	push	de
	pop	bc
	ld	h, (ix - 67)                    ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	ld	(ix - 100), bc
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	ld	h, l
	call	__lshru
	ld	(ix - 67), bc
	lea	bc, iy + 0
	ld	de, (ix - 88)
	ld	a, e
	ld	l, 16
	call	__lshru
	ld	(ix - 106), bc
	lea	bc, iy + 0
	ld	a, e
	ld	l, h
	call	__lshru
	ld	(ix - 88), bc
	ld	de, (ix - 112)
	push	de
	pop	bc
	ld	h, (ix - 118)                   ; 1-byte Folded Reload
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	(ix - 109), bc
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	hl, (ix - 64)
	ld	(ix - 97), l                    ; 1-byte Folded Spill
	ld	hl, (ix - 100)
	ld	e, l
	ld	hl, (ix - 67)
	ld	d, l
	ld	a, iyl
	ld	hl, (ix - 106)
	ld	(ix - 100), l                   ; 1-byte Folded Spill
	ld	hl, (ix - 88)
	ld	(ix - 103), l                   ; 1-byte Folded Spill
	ld	hl, (ix - 112)
	ld	(ix - 106), l                   ; 1-byte Folded Spill
	ld	hl, (ix - 109)
	ld	(ix - 109), l                   ; 1-byte Folded Spill
	ld	(ix - 112), c                   ; 1-byte Folded Spill
	ld	b, a
	ld	c, (ix - 113)                   ; 1-byte Folded Reload
	ld	a, (ix - 85)                    ; 1-byte Folded Reload
	.local	.LBB37_146
.LBB37_146:
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 22
	ld	(iy + 0), b
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 19
	ld	(iy + 0), d
	ld	(ix - 113), c
	ld	bc, -146
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e
	ld	(ix - 85), a
	ld	l, 16
	ld	de, (ix - 116)
	push	de
	pop	bc
	ld	h, (ix - 117)                   ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	push	bc
	pop	iy
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), e                    ; 1-byte Folded Spill
	pop	ix
	ld	de, -152
	lea	hl, ix + 0
	add	hl, de
	push	af
	ld	a, iyl
	ld	(hl), a                         ; 1-byte Folded Spill
	pop	af
	dec	de
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	.local	.LBB37_147
.LBB37_147:
	xor	a, a
	ld	(ix - 88), a                    ; 1-byte Folded Spill
	ld	(ix - 116), a                   ; 1-byte Folded Spill
	ld	(ix - 117), a                   ; 1-byte Folded Spill
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld	(ix - 121), a                   ; 1-byte Folded Spill
	ld	(ix - 124), a                   ; 1-byte Folded Spill
	ld	(ix - 127), a                   ; 1-byte Folded Spill
	ld	(ix - 128), a                   ; 1-byte Folded Spill
	jp	.LBB37_40
	.local	.LBB37_148
.LBB37_148:
	ld	a, (ix - 13)
	ld	hl, (ix - 9)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 854
	or	a, a
	sbc.sis	hl, de
	ld	e, -1
	ld	l, e
	jr	z, .LBB37_150
; %bb.149:
	ld	l, 0
	.local	.LBB37_150
.LBB37_150:
	cp	a, 21
	ld	a, e
	jr	z, .LBB37_152
; %bb.151:
	ld	a, 0
	.local	.LBB37_152
.LBB37_152:
	and	a, l
	ld	d, a
	ld	l, (ix - 79)
	ld	h, (ix - 78)
	ld.sis	bc, 4
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB37_154
; %bb.153:
	ld	e, 0
	.local	.LBB37_154
.LBB37_154:
	ld	a, d
	and	a, e
	ld	l, a
	ld	de, -156
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	l, (ix - 67)
	ld	h, (ix - 66)
	ld	(ix - 79), l
	ld	(ix - 78), h
	jp	.LBB37_41
	.local	.LBB37_155
.LBB37_155:
	ld	l, (ix - 67)
	ld	h, (ix - 66)
	ld	(ix - 79), l
	ld	(ix - 78), h
	jp	.LBB37_40
	.local	.Lfunc_end37
.Lfunc_end37:
	.size	_true3d_live_benchmark_run, .Lfunc_end37-_true3d_live_benchmark_run
                                        ; -- End function
	.section	.text._live_show_failure,"ax",@progbits
	.type	_live_show_failure,@function    ; -- Begin function live_show_failure
_live_show_failure:                     ; @live_show_failure
; %bb.0:
	call	__frameset0
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.3.9
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 2
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, (ix + 6)
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 8
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.4
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB38_1
.LBB38_1:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB38_1
	.local	.LBB38_2
.LBB38_2:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB38_2
; %bb.3:
	pop	ix
	ret
	.local	.Lfunc_end38
.Lfunc_end38:
	.size	_live_show_failure, .Lfunc_end38-_live_show_failure
                                        ; -- End function
	.section	.text._live_reset_state,"ax",@progbits
	.type	_live_reset_state,@function     ; -- Begin function live_reset_state
_live_reset_state:                      ; @live_reset_state
; %bb.0:
	ld	hl, _live_state
	ld	de, _live_level
	push	de
	push	hl
	call	_engine_init
	pop	hl
	pop	hl
	ret
	.local	.Lfunc_end39
.Lfunc_end39:
	.size	_live_reset_state, .Lfunc_end39-_live_reset_state
                                        ; -- End function
	.section	.text._live_controller_next,"ax",@progbits
	.type	_live_controller_next,@function ; -- Begin function live_controller_next
_live_controller_next:                  ; @live_controller_next
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	e, (hl)
	ld	a, e
	cp	a, 21
	jr	c, .LBB40_2
; %bb.1:
	xor	a, a
	jp	.LBB40_4
	.local	.LBB40_2
.LBB40_2:
	ld	iy, _live_route
	ld	a, 1
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	bc, 7
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	l, (iy + 2)
	lea	de, iy + 0
	ld	iy, (ix + 9)
	ld	(iy), l
	push	de
	pop	iy
	ld	e, (iy + 3)
	ld	hl, (ix + 12)
	ld	(hl), e
	ld	l, (iy + 4)
	lea	de, iy + 0
	ld	iy, (ix + 15)
	ld	(iy), l
	push	de
	pop	iy
	ld	l, (iy + 5)
	ld	iy, (ix + 18)
	ld	(iy), l
	push	de
	pop	iy
	ld	l, (iy + 6)
	ld	iy, (ix + 21)
	ld	(iy), l
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	hl, (iy + 4)
	inc.sis	hl
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	hl, (iy + 2)
	inc.sis	hl
	ld	(iy + 2), l
	ld	(iy + 3), h
	push	de
	pop	iy
	ld	de, (iy)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB40_4
; %bb.3:
	ld.sis	hl, 0
	ld	de, (ix + 6)
	push	de
	pop	iy
	inc	(iy)
	ld	(iy + 2), l
	ld	(iy + 3), h
	.local	.LBB40_4
.LBB40_4:
	pop	ix
	ret
	.local	.Lfunc_end40
.Lfunc_end40:
	.size	_live_controller_next, .Lfunc_end40-_live_controller_next
                                        ; -- End function
	.section	.text._live_section_ends,"ax",@progbits
	.type	_live_section_ends,@function    ; -- Begin function live_section_ends
_live_section_ends:                     ; @live_section_ends
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	a, (ix + 9)
	ld	bc, 116
	ld	iy, (_live_report)
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 3), iy
	push	de
	pop	hl
	ld	bc, (ix + 6)
	ld	l, c
	ld	h, b
	inc	hl
	ld	(ix - 6), hl
	ld	e, (iy + 114)
	ld	(ix - 9), de
	ld	a, (iy + 115)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, 8
	call	__ishl
	ld	de, (ix - 9)
	add	hl, de
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	a, (iy + 116)
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	e, a
	ld	iy, (ix - 3)
	ld	a, (iy + 117)
	ld	l, a
	call	__ishl
	add	hl, de
	ld	de, (ix - 9)
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	z, .LBB41_2
; %bb.1:
	ld	a, 0
	jr	.LBB41_3
	.local	.LBB41_2
.LBB41_2:
	ld	a, 1
	.local	.LBB41_3
.LBB41_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end41
.Lfunc_end41:
	.size	_live_section_ends, .Lfunc_end41-_live_section_ends
                                        ; -- End function
	.section	.text._live_state_hash,"ax",@progbits
	.type	_live_state_hash,@function      ; -- Begin function live_state_hash
_live_state_hash:                       ; @live_state_hash
; %bb.0:
	ld	hl, -79
	call	__frameset
	ld	de, _live_state+9
	ld	bc, 0
	lea	iy, ix - 52
	lea	hl, ix - 67
	ld	(ix - 76), hl
	ld	hl, _live_state
	ld	(ix - 67), hl
	ld	(ix - 64), de
	ld	hl, _live_state+18
	ld	(ix - 61), hl
	ld	hl, _live_state+27
	ld	(ix - 58), hl
	ld	hl, _live_state+36
	ld	(ix - 55), hl
	ld	(ix - 73), iy
	lea	iy, iy + 4
	.local	.LBB42_1
.LBB42_1:                               ; =>This Inner Loop Header: Depth=1
	ld	de, 15
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB42_3
; %bb.2:                                ;   in Loop: Header=BB42_1 Depth=1
	ld	hl, (ix - 76)
	ld	(ix - 79), bc
	add	hl, bc
	ld	de, (hl)
	push	de
	pop	hl
	ld	hl, (hl)
	ld	a, l
	ld	(iy - 4), a
	ld	a, h
	ld	(iy - 3), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(iy - 2), a
	ld	(ix - 70), iy
	push	de
	pop	iy
	ld	hl, (iy + 3)
	ld	a, l
	ld	iy, (ix - 70)
	ld	(iy - 1), a
	ld	a, h
	ld	iy, (ix - 70)
	ld	(iy), a
	call	__ishru
	ld	a, l
	ld	iy, (ix - 70)
	ld	(iy + 1), a
	push	de
	pop	iy
	ld	hl, (iy + 6)
	ld	iy, (ix - 70)
	ld	a, l
	ld	(iy + 2), a
	ld	a, h
	ld	(iy + 3), a
	call	__ishru
	ld	a, l
	ld	(iy + 4), a
	ld	hl, (ix - 79)
	ld	de, 3
	add	hl, de
	lea	iy, iy + 9
	push	hl
	pop	bc
	jr	.LBB42_1
	.local	.LBB42_3
.LBB42_3:
	ld	a, (_live_state+45)
	ld	(iy - 4), a
	ld	a, (_live_state+46)
	ld	(iy - 3), a
	ld	a, (_live_state+47)
	ld	(iy - 2), a
	ld	a, (_live_state+48)
	ld	(iy - 1), a
	ld	a, (_live_state+49)
	ld	(iy), a
	ld	a, (_live_state+50)
	ld	(iy + 1), a
	ld	a, (_live_state+51)
	ld	(iy + 2), a
	ld	hl, 52
	push	hl
	ld	hl, (ix - 73)
	push	hl
	ld	hl, -127
	push	hl
	ld	hl, 1875397
	push	hl
	call	_live_hash_bytes
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end42
.Lfunc_end42:
	.size	_live_state_hash, .Lfunc_end42-_live_state_hash
                                        ; -- End function
	.section	.text._live_hash_bytes,"ax",@progbits
	.type	_live_hash_bytes,@function      ; -- Begin function live_hash_bytes
_live_hash_bytes:                       ; @live_hash_bytes
; %bb.0:
	ld	hl, -7
	call	__frameset
	ld	hl, (ix + 6)
	ld	(ix - 4), hl
	ld	e, (ix + 9)
	ld	iy, (ix + 12)
	ld	bc, (ix + 15)
	or	a, a
	sbc	hl, hl
	ld	d, l
	.local	.LBB43_1
.LBB43_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB43_3
; %bb.2:                                ;   in Loop: Header=BB43_1 Depth=1
	ld	a, (iy)
	ld	l, 0
	ld	(ix - 1), l
	ld	(ix - 7), bc
	ld	bc, (ix - 3)
	ld	b, l
	ld	c, a
	ld	hl, (ix - 4)
	ld	a, d
	call	__lxor
	ld	bc, 403
	ld	a, b
	call	__lmulu
	ld	bc, (ix - 7)
	ld	(ix - 4), hl
	inc	iy
	dec	bc
	jr	.LBB43_1
	.local	.LBB43_3
.LBB43_3:
	ld	hl, (ix - 4)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end43
.Lfunc_end43:
	.size	_live_hash_bytes, .Lfunc_end43-_live_hash_bytes
                                        ; -- End function
	.section	.text._read_u32,"ax",@progbits
	.type	_read_u32,@function             ; -- Begin function read_u32
_read_u32:                              ; @read_u32
; %bb.0:
	ld	hl, -7
	call	__frameset
	ld	hl, (ix + 6)
	ld	a, (hl)
	ld	e, 0
	ld	(ix - 4), e
	ld	hl, (ix - 6)
	ld	h, e
	ld	l, a
	ld	(ix - 7), hl
	or	a, a
	sbc	hl, hl
	ld	d, l
	ld	iy, (ix + 6)
	ld	a, (iy + 1)
	ld	(ix - 3), e
	ld	bc, (ix - 5)
	ld	b, e
	ld	c, a
	ld	l, 8
	ld	a, d
	call	__lshl
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix - 7)
	ld	a, d
	call	__ladd
	ld	(ix - 7), hl
	ld	a, (iy + 2)
	ld	l, 0
	ld	(ix - 2), l
	ld	bc, (ix - 4)
	ld	b, l
	ld	c, a
	ld	l, 16
	ld	a, d
	call	__lshl
	ld	hl, (ix - 7)
	call	__ladd
	ld	(ix - 7), hl
	ld	a, (iy + 3)
	ld	l, 0
	ld	(ix - 1), l
	ld	bc, (ix - 3)
	ld	b, l
	ld	c, a
	ld	l, 24
	ld	a, d
	call	__lshl
	ld	hl, (ix - 7)
	call	__ladd
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end44
.Lfunc_end44:
	.size	_read_u32, .Lfunc_end44-_read_u32
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	jp	_true3d_live_benchmark_run
	.local	.Lfunc_end45
.Lfunc_end45:
	.size	_main, .Lfunc_end45-_main
                                        ; -- End function
	.section	.bss._render_benchmark_active,"aw",@nobits
	.balign	1
	.local	_render_benchmark_active
_render_benchmark_active:
	.zero	1

	.section	.bss._render_benchmark_last,"aw",@nobits
	.balign	1
	.local	_render_benchmark_last
_render_benchmark_last:
	.zero	4

	.section	.bss._render_benchmark_category,"aw",@nobits
	.balign	1
	.local	_render_benchmark_category
_render_benchmark_category:
	.zero	1

	.section	.bss._render_benchmark,"aw",@nobits
	.balign	2
	.local	_render_benchmark
_render_benchmark:
	.zero	86

	.section	.bss._portal_lod_state,"aw",@nobits
	.balign	1
	.local	_portal_lod_state
_portal_lod_state:
	.zero	2

	.section	.bss._active_render_width,"aw",@nobits
	.balign	1
	.local	_active_render_width
_active_render_width:
	.zero	1

	.section	.bss._active_render_height,"aw",@nobits
	.balign	1
	.local	_active_render_height
_active_render_height:
	.zero	1

	.section	.bss._low_frame,"aw",@nobits
	.balign	1
	.globl	_low_frame
_low_frame:
	.zero	3074

	.section	.bss._projection_scale_table,"aw",@nobits
	.balign	2
	.local	_projection_scale_table
_projection_scale_table:
	.zero	4096

	.section	.bss._far_projection_scale_table,"aw",@nobits
	.balign	2
	.local	_far_projection_scale_table
_far_projection_scale_table:
	.zero	4096

	.section	.bss._edge_reciprocal_table,"aw",@nobits
	.balign	2
	.local	_edge_reciprocal_table
_edge_reciprocal_table:
	.zero	4096

	.section	.rodata._base_palette_rgb,"a",@progbits
	.balign	1
	.local	_base_palette_rgb
_base_palette_rgb:
	.zero	3
	.ascii	"\f\016\031"
	.ascii	"69>"
	.ascii	" #0"
	.ascii	"&\315K"
	.ascii	"\030v4"
	.ascii	"A96"
	.ascii	"0 #"
	.ascii	"\32744"
	.ascii	"}\036\042"
	.ascii	"-i\365"
	.ascii	"\360\221\034"
	.zero	3,240

	.section	.rodata._shade_numerator,"a",@progbits
	.balign	1
	.local	_shade_numerator
_shade_numerator:
	.ascii	"\t\013\016\020"

	.section	.bss._render_layers,"aw",@nobits
	.balign	2
	.local	_render_layers
_render_layers:
	.zero	2636

	.section	.bss._active_render_shift,"aw",@nobits
	.balign	1
	.local	_active_render_shift
_active_render_shift:
	.zero	1

	.section	.bss._room_count,"aw",@nobits
	.balign	1
	.local	_room_count
_room_count:
	.zero	1

	.section	.bss._rooms,"aw",@nobits
	.balign	1
	.local	_rooms
_rooms:
	.zero	104

	.section	.bss._world_vertices,"aw",@nobits
	.balign	1
	.local	_world_vertices
_world_vertices:
	.zero	384

	.section	.bss._world_faces,"aw",@nobits
	.balign	1
	.local	_world_faces
_world_faces:
	.zero	288

	.section	.rodata._box_face_vertices,"a",@progbits
	.balign	1
	.local	_box_face_vertices
_box_face_vertices:
	.ascii	"\000\003\002\001"
	.ascii	"\004\005\006\007"
	.ascii	"\000\001\005\004"
	.ascii	"\003\007\006\002"
	.ascii	"\000\004\007\003"
	.ascii	"\001\002\006\005"

	.section	.data._portals,"aw",@progbits
	.balign	1
	.local	_portals
_portals:
	d24	0                               ; 0x0
	d24	2560                            ; 0xa00
	d24	640                             ; 0x280
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	384                             ; 0x180
	d24	448                             ; 0x1c0
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	1                               ; 0x1
	db	1                               ; 0x1
	d24	3072                            ; 0xc00
	d24	1024                            ; 0x400
	d24	1280                            ; 0x500
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	384                             ; 0x180
	d24	448                             ; 0x1c0
	db	1                               ; 0x1
	db	7                               ; 0x7
	db	0                               ; 0x0
	db	1                               ; 0x1

	.section	.rodata._face_normals,"a",@progbits
	.balign	1
	.local	_face_normals
_face_normals:
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	0                               ; 0x0

	.section	.rodata._face_right_vectors,"a",@progbits
	.balign	1
	.local	_face_right_vectors
_face_right_vectors:
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0

	.section	.rodata._face_up_vectors,"a",@progbits
	.balign	1
	.local	_face_up_vectors
_face_up_vectors:
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	16776960                        ; 0xffff00
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100
	d24	0                               ; 0x0
	d24	0                               ; 0x0
	d24	256                             ; 0x100

	.section	.rodata._quarter_sine,"a",@progbits
	.balign	2
	.local	_quarter_sine
_quarter_sine:
	dw	0                               ; 0x0
	dw	6                               ; 0x6
	dw	13                              ; 0xd
	dw	19                              ; 0x13
	dw	25                              ; 0x19
	dw	31                              ; 0x1f
	dw	38                              ; 0x26
	dw	44                              ; 0x2c
	dw	50                              ; 0x32
	dw	56                              ; 0x38
	dw	62                              ; 0x3e
	dw	68                              ; 0x44
	dw	74                              ; 0x4a
	dw	80                              ; 0x50
	dw	86                              ; 0x56
	dw	92                              ; 0x5c
	dw	98                              ; 0x62
	dw	104                             ; 0x68
	dw	109                             ; 0x6d
	dw	115                             ; 0x73
	dw	121                             ; 0x79
	dw	126                             ; 0x7e
	dw	132                             ; 0x84
	dw	137                             ; 0x89
	dw	142                             ; 0x8e
	dw	147                             ; 0x93
	dw	152                             ; 0x98
	dw	157                             ; 0x9d
	dw	162                             ; 0xa2
	dw	167                             ; 0xa7
	dw	172                             ; 0xac
	dw	177                             ; 0xb1
	dw	181                             ; 0xb5
	dw	185                             ; 0xb9
	dw	190                             ; 0xbe
	dw	194                             ; 0xc2
	dw	198                             ; 0xc6
	dw	202                             ; 0xca
	dw	206                             ; 0xce
	dw	209                             ; 0xd1
	dw	213                             ; 0xd5
	dw	216                             ; 0xd8
	dw	220                             ; 0xdc
	dw	223                             ; 0xdf
	dw	226                             ; 0xe2
	dw	229                             ; 0xe5
	dw	231                             ; 0xe7
	dw	234                             ; 0xea
	dw	237                             ; 0xed
	dw	239                             ; 0xef
	dw	241                             ; 0xf1
	dw	243                             ; 0xf3
	dw	245                             ; 0xf5
	dw	247                             ; 0xf7
	dw	248                             ; 0xf8
	dw	250                             ; 0xfa
	dw	251                             ; 0xfb
	dw	252                             ; 0xfc
	dw	253                             ; 0xfd
	dw	254                             ; 0xfe
	dw	255                             ; 0xff
	dw	255                             ; 0xff
	dw	256                             ; 0x100
	dw	256                             ; 0x100
	dw	256                             ; 0x100

	.section	.bss._active_horizon_near_limit,"aw",@nobits
	.balign	1
	.local	_active_horizon_near_limit
_active_horizon_near_limit:
	.zero	1

	.section	.bss._active_horizon_far_limit,"aw",@nobits
	.balign	1
	.local	_active_horizon_far_limit
_active_horizon_far_limit:
	.zero	1

	.section	.bss._low_row_offsets,"aw",@nobits
	.balign	2
	.local	_low_row_offsets
_low_row_offsets:
	.zero	96

	.section	.bss._camera_vertices,"aw",@nobits
	.balign	1
	.local	_camera_vertices
_camera_vertices:
	.zero	576

	.section	.bss._vertex_projectable,"aw",@nobits
	.balign	1
	.local	_vertex_projectable
_vertex_projectable:
	.zero	64

	.section	.bss._screen_vertices,"aw",@nobits
	.balign	1
	.local	_screen_vertices
_screen_vertices:
	.zero	384

	.section	.bss._clip_input,"aw",@nobits
	.balign	1
	.local	_clip_input
_clip_input:
	.zero	72

	.section	.bss._clip_output,"aw",@nobits
	.balign	1
	.local	_clip_output
_clip_output:
	.zero	72

	.section	.bss._span_left,"aw",@nobits
	.balign	1
	.local	_span_left
_span_left:
	.zero	144

	.section	.bss._span_right,"aw",@nobits
	.balign	1
	.local	_span_right
_span_right:
	.zero	144

	.section	.rodata._face_light_level,"a",@progbits
	.balign	1
	.local	_face_light_level
_face_light_level:
	.ascii	"\003\002\003\002\002\001"

	.section	.bss._portal_lod_frame,"aw",@nobits
	.balign	1
	.local	_portal_lod_frame
_portal_lod_frame:
	.zero	768

	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"FPS --.-"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"FPS "

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"FREECAM"

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"T3DLVL1"

	.section	.rodata._.str.1.4,"a",@progbits
	.balign	1
	.local	_.str.1.4
_.str.1.4:
	.asciz	"r"

	.section	.rodata._builtin_level,"a",@progbits
	.balign	1
	.local	_builtin_level
_builtin_level:
	.ascii	"T3D1"
	db	1                               ; 0x1
	db	2                               ; 0x2
	db	0                               ; 0x0
	db	3                               ; 0x3
	dw	0                               ; 0x0
	dw	512                             ; 0x200
	dw	384                             ; 0x180
	db	0                               ; 0x0
	db	3                               ; 0x3
	dw	0                               ; 0x0
	dw	2560                            ; 0xa00
	dw	640                             ; 0x280
	db	1                               ; 0x1
	db	1                               ; 0x1
	dw	3072                            ; 0xc00
	dw	1024                            ; 0x400
	dw	1280                            ; 0x500
	dw	64512                           ; 0xfc00
	dw	1024                            ; 0x400
	dw	0                               ; 0x0
	dw	2560                            ; 0xa00
	dw	0                               ; 0x0
	dw	1280                            ; 0x500
	.ascii	"\002\003\005\004\005\005"
	dw	2048                            ; 0x800
	dw	4096                            ; 0x1000
	dw	0                               ; 0x0
	dw	2048                            ; 0x800
	dw	0                               ; 0x0
	dw	1280                            ; 0x500
	.ascii	"\006\007\t\b\t\t"

	.section	.bss._live_level,"aw",@nobits
	.balign	1
	.local	_live_level
_live_level:
	.zero	6

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"Route or built-in level invalid."

	.section	.rodata._.str.1.8,"a",@progbits
	.balign	1
	.local	_.str.1.8
_.str.1.8:
	.asciz	"No room for T3DLIVE."

	.section	.bss._live_report_handle,"aw",@nobits
	.balign	1
	.local	_live_report_handle
_live_report_handle:
	.zero	1

	.section	.rodata._.str.2.6,"a",@progbits
	.balign	1
	.local	_.str.2.6
_.str.2.6:
	.asciz	"T3DTMP"

	.section	.rodata._live_route,"a",@progbits
	.balign	1
	.local	_live_route
_live_route:
	dw	64                              ; 0x40
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	dw	64                              ; 0x40
	db	0                               ; 0x0
	db	255                             ; 0xff
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	dw	24                              ; 0x18
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	1                               ; 0x1
	dw	48                              ; 0x30
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	255                             ; 0xff
	db	0                               ; 0x0
	db	1                               ; 0x1
	dw	24                              ; 0x18
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	1                               ; 0x1
	dw	56                              ; 0x38
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	2                               ; 0x2
	dw	36                              ; 0x24
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	3                               ; 0x3
	dw	4                               ; 0x4
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	4                               ; 0x4
	dw	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	8                               ; 0x8
	db	5                               ; 0x5
	dw	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	5                               ; 0x5
	dw	8                               ; 0x8
	db	255                             ; 0xff
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	5                               ; 0x5
	dw	48                              ; 0x30
	db	255                             ; 0xff
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	6                               ; 0x6
	dw	60                              ; 0x3c
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	7                               ; 0x7
	dw	64                              ; 0x40
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	8                               ; 0x8
	dw	64                              ; 0x40
	db	0                               ; 0x0
	db	255                             ; 0xff
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	8                               ; 0x8
	dw	48                              ; 0x30
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	9                               ; 0x9
	dw	96                              ; 0x60
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	255                             ; 0xff
	db	0                               ; 0x0
	db	9                               ; 0x9
	dw	48                              ; 0x30
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	9                               ; 0x9
	dw	24                              ; 0x18
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	9                               ; 0x9
	dw	48                              ; 0x30
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	16                              ; 0x10
	db	9                               ; 0x9
	dw	24                              ; 0x18
	db	1                               ; 0x1
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	9                               ; 0x9

	.section	.rodata._.str.3.9,"a",@progbits
	.balign	1
	.local	_.str.3.9
_.str.3.9:
	.asciz	"True3D benchmark failed"

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"Press any key"

	.section	.rodata._.str.5.7,"a",@progbits
	.balign	1
	.local	_.str.5.7
_.str.5.7:
	.asciz	"w"

	.section	.bss._live_report,"aw",@nobits
	.balign	1
	.local	_live_report
_live_report:
	.zero	3

	.section	.rodata._live_sections,"a",@progbits
	.balign	1
	.local	_live_sections
_live_sections:
	d24	_.str.6
	db	4                               ; 0x4
	d24	_.str.7
	db	8                               ; 0x8
	d24	_.str.8
	db	33                              ; 0x21
	d24	_.str.9
	db	33                              ; 0x21
	d24	_.str.10
	db	131                             ; 0x83
	d24	_.str.11
	db	147                             ; 0x93
	d24	_.str.12
	db	49                              ; 0x31
	d24	_.str.13
	db	179                             ; 0xb3
	d24	_.str.14
	db	20                              ; 0x14
	d24	_.str.15
	db	216                             ; 0xd8

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"OPEN_YAW"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"PITCH_SWEEP"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"PORTAL_FAR"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"PORTAL_NEAR"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"CROSS_DOWN"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"RETURN_UP"

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"LOD_RETREAT"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"LOD_APPROACH"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"FREECAM_YAW"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"FREECAM_3D"

	.section	.bss._live_state,"aw",@nobits
	.balign	1
	.local	_live_state
_live_state:
	.zero	52

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"T3DLIV1"

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"T3DLIVE"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"r+"

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"True3D live benchmark done"

	.section	.rodata._.str.20,"a",@progbits
	.balign	1
	.local	_.str.20
_.str.20:
	.asciz	"True3D benchmark save failed"

	.section	.rodata._.str.21,"a",@progbits
	.balign	1
	.local	_.str.21
_.str.21:
	.asciz	"Frames: 854"

	.section	.rodata._.str.22,"a",@progbits
	.balign	1
	.local	_.str.22
_.str.22:
	.asciz	"Portal crossings: "

	.section	.rodata._.str.23,"a",@progbits
	.balign	1
	.local	_.str.23
_.str.23:
	.asciz	"4"

	.section	.rodata._.str.24,"a",@progbits
	.balign	1
	.local	_.str.24
_.str.24:
	.asciz	"unexpected"

	.section	.rodata._.str.25,"a",@progbits
	.balign	1
	.local	_.str.25
_.str.25:
	.asciz	"Result: T3DLIVE"

	.section	.rodata._.str.26,"a",@progbits
	.balign	1
	.local	_.str.26
_.str.26:
	.asciz	"Archived safely"

	.section	.rodata._.str.27,"a",@progbits
	.balign	1
	.local	_.str.27
_.str.27:
	.asciz	"Stored in RAM"

	.section	.rodata._.str.28,"a",@progbits
	.balign	1
	.local	_.str.28
_.str.28:
	.asciz	"Build: "

	.section	.rodata._live_put_hex32.digits,"a",@progbits
	.balign	1
	.local	_live_put_hex32.digits
_live_put_hex32.digits:
	.asciz	"0123456789ABCDEF"

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	__ldivu
	.extern	_llvm.smin.i24
	.extern	_ti_Rename
	.extern	_llvm.lifetime.end.p0
	.extern	__ishru
	.extern	__Unwind_SjLj_Unregister
	.extern	__lshrs
	.extern	_memset
	.extern	_llvm.memset.p0.i64
	.extern	__land
	.extern	_llvm.smax.i16
	.extern	__ineg
	.extern	_llvm.umax.i8
	.extern	__sneg
	.extern	_gfx_Wait
	.extern	_os_GetCSC
	.extern	__lsub
	.extern	_llvm.smin.i32
	.extern	__inot
	.extern	_os_PutStrFull
	.extern	_llvm.abs.i24
	.extern	_ti_Open
	.extern	__ladd
	.extern	_llvm.umin.i24
	.extern	__idivu
	.extern	__ldivs
	.extern	__lxor
	.extern	_ti_SetArchiveStatus
	.extern	_llvm.eh.sjlj.lsda
	.extern	_ti_Delete
	.extern	__iand
	.extern	__setflag
	.extern	__lneg
	.extern	__lnot
	.extern	_ti_Resize
	.extern	_llvm.smax.i32
	.extern	_os_ClrLCD
	.extern	_llvm.stacksave.p0
	.extern	_ti_Close
	.extern	_memcmp
	.extern	_llvm.lifetime.start.p0
	.extern	_present_low_frame_32_fast
	.extern	_llvm.smin.i16
	.extern	_gfx_SetTextTransparentColor
	.extern	__lshru
	.extern	__ixor
	.extern	_os_HomeUp
	.extern	_llvm.abs.i8
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_ti_GetSize
	.extern	_os_SetCursorPos
	.extern	_memcpy
	.extern	_llvm.umin.i32
	.extern	__sdivu
	.extern	_llvm.umax.i24
	.extern	_gfx_FillRectangle_NoClip
	.extern	__bshru
	.extern	_gfx_PrintStringXY
	.extern	_llvm.umin.i8
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_llvm.memset.p0.i24
	.extern	_gfx_End
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.abs.i16
	.extern	_llvm.frameaddress.p0
	.extern	_os_DrawStatusBar
	.extern	__lshl
	.extern	__sand
	.extern	__sxor
	.extern	_llvm.stackrestore.p0
	.extern	__lcmpu
	.extern	_atomic_load_decreasing_32
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_SetTextScale
	.extern	_gfx_PrintChar
	.extern	_gfx_Begin
	.extern	_atomic_load_increasing_32
	.extern	_clock
	.extern	_llvm.smax.i24
	.extern	__ishru_1
	.extern	__lcmps
	.extern	_gfx_SetTextBGColor
	.extern	_gfx_SwapDraw
	.extern	__sshru
	.extern	_strlen
	.extern	_llvm.experimental.noalias.scope.decl
	.extern	__frameset
	.extern	__ishrs_1
	.extern	__imulu
	.extern	_llvm.eh.sjlj.callsite
	.extern	_ti_GetDataPtr
	.extern	__lmulu
	.extern	__frameset0
	.extern	_gfx_PrintUInt
	.extern	__Unwind_SjLj_Register
	.extern	__sshl
	.extern	__bshl
	.extern	__ishrs
	.extern	__smulu
	.extern	_gfx_SetDraw
	.extern	__ishl
	.extern	_present_low_frame_fast
