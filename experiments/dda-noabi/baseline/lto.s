	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._game_render_benchmark_reset,"ax",@progbits
	.globl	_game_render_benchmark_reset    ; -- Begin function game_render_benchmark_reset
	.type	_game_render_benchmark_reset,@function
_game_render_benchmark_reset:           ; @game_render_benchmark_reset
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
	ld	bc, 65
	ldir
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_game_render_benchmark_reset, .Lfunc_end0-_game_render_benchmark_reset
                                        ; -- End function
	.section	.text._game_render_benchmark_begin,"ax",@progbits
	.globl	_game_render_benchmark_begin    ; -- Begin function game_render_benchmark_begin
	.type	_game_render_benchmark_begin,@function
_game_render_benchmark_begin:           ; @game_render_benchmark_begin
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	nz, .LBB1_6
; %bb.1:
	xor	a, a
	ld	hl, _render_benchmark+28
	ld	iyl, 1
	ld	(_render_benchmark_category), a
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
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
	.size	_game_render_benchmark_begin, .Lfunc_end1-_game_render_benchmark_begin
                                        ; -- End function
	.section	.text._game_render_benchmark_end,"ax",@progbits
	.globl	_game_render_benchmark_end      ; -- Begin function game_render_benchmark_end
	.type	_game_render_benchmark_end,@function
_game_render_benchmark_end:             ; @game_render_benchmark_end
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
	ld	hl, (_render_benchmark+42)
	ld	iy, _render_benchmark+42
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
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
	.size	_game_render_benchmark_end, .Lfunc_end2-_game_render_benchmark_end
                                        ; -- End function
	.section	.text._game_render_benchmark_calibrate,"ax",@progbits
	.globl	_game_render_benchmark_calibrate ; -- Begin function game_render_benchmark_calibrate
	.type	_game_render_benchmark_calibrate,@function
_game_render_benchmark_calibrate:       ; @game_render_benchmark_calibrate
; %bb.0:
	ld	hl, -106
	call	__frameset
	ld	e, 0
	or	a, a
	sbc	hl, hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	nz, .LBB3_23
; %bb.1:
	ld	hl, _render_benchmark
	ld	bc, 66
	ld	iy, _render_benchmark_last
	ld	de, -1
	ld	(ix - 71), de
	ld	a, d
	ld	(ix - 68), a
	lea	de, ix - 67
	ld	(ix - 74), de
	ldir
	ld	hl, (_render_benchmark_last)
	ld	(ix - 77), hl
	ld	a, (_render_benchmark_last+3)
	ld	(ix - 79), a                    ; 1-byte Folded Spill
	ld	a, (_render_benchmark_category)
	ld	(ix - 78), a                    ; 1-byte Folded Spill
	lea	hl, iy + 3
	ld	(ix - 82), hl
	ld	iyl, 0
	ld	a, iyl
	ld	iy, _render_benchmark+42
	lea	hl, iy + 3
	ld	iyl, a
	ld	(ix - 86), hl
	.local	.LBB3_2
.LBB3_2:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_4 Depth 2
	cp	a, 8
	jp	z, .LBB3_22
; %bb.3:                                ;   in Loop: Header=BB3_2 Depth=1
	ld	(ix - 83), a                    ; 1-byte Folded Spill
	ld	a, iyl
	ld	(_render_benchmark_active), a
	or	a, a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	hl, (ix - 82)
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
	ld	bc, 65
	ldir
	call	_game_render_benchmark_begin
	ld	a, (_render_benchmark_active)
	ld	h, a
	ld	a, (_render_benchmark_category)
	ld	b, a
	ld	iy, (_render_benchmark_last)
	ld	a, (_render_benchmark_last+3)
	ld	e, a
	ld	d, 0
	.local	.LBB3_4
.LBB3_4:                                ;   Parent Loop BB3_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, d
	cp	a, 64
	jp	z, .LBB3_17
; %bb.5:                                ;   in Loop: Header=BB3_4 Depth=2
	bit	0, h
	jp	z, .LBB3_16
; %bb.6:                                ;   in Loop: Header=BB3_4 Depth=2
	ld	(ix - 89), e                    ; 1-byte Folded Spill
	ld	c, -1
	ld	a, d
	xor	a, c
	ld	l, a
	ld	e, 1
	ld	a, l
	and	a, e
	ld	l, a
	ld	a, b
	cp	a, l
	ld	a, c
	jr	nz, .LBB3_8
; %bb.7:                                ;   in Loop: Header=BB3_4 Depth=2
	ld	a, 0
	.local	.LBB3_8
.LBB3_8:                                ;   in Loop: Header=BB3_4 Depth=2
	bit	0, a
	jr	z, .LBB3_11
; %bb.9:                                ;   in Loop: Header=BB3_4 Depth=2
	ld	(ix - 100), iy
	ld	(ix - 97), b                    ; 1-byte Folded Spill
	ld	(ix - 94), l                    ; 1-byte Folded Spill
	ld	(ix - 93), h                    ; 1-byte Folded Spill
	ld	bc, (-917472)
	ld	hl, (-917472)
	ld	(ix - 103), hl
	ld	(ix - 92), bc
	or	a, a
	sbc	hl, bc
	ld	iy, 2
	lea	bc, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB3_12
; %bb.10:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	iy, (ix - 103)
	ld	bc, (ix - 100)
	jr	.LBB3_15
	.local	.LBB3_11
.LBB3_11:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	e, (ix - 89)                    ; 1-byte Folded Reload
	jp	.LBB3_16
	.local	.LBB3_12
.LBB3_12:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	iy, (-917472)
	lea	hl, iy + 0
	ld	bc, (ix - 103)
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 100)
	jr	nc, .LBB3_14
; %bb.13:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	(ix - 92), iy
	.local	.LBB3_14
.LBB3_14:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	iy, (ix - 92)
	.local	.LBB3_15
.LBB3_15:                               ;   in Loop: Header=BB3_4 Depth=2
	ld	(ix - 92), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 100), e
	lea	hl, iy + 0
	ld	a, (ix - 89)                    ; 1-byte Folded Reload
	call	__lsub
	ld	(ix - 89), hl
	ld	(ix - 103), e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	iy, _render_benchmark
	add	iy, bc
	ld	bc, (iy)
	ld	(ix - 106), iy
	lea	hl, iy + 3
	ld	(ix - 97), hl
	ld	hl, (ix - 89)
	ld	iy, (ix - 97)
	ld	a, (iy)
	call	__ladd
	ld	iy, (ix - 106)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 86)
	ld	e, (iy)
	ld	bc, (ix - 89)
	ld	a, (ix - 103)                   ; 1-byte Folded Reload
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	iy, (ix - 92)
	ld	(_render_benchmark_last), iy
	ld	e, (ix - 100)                   ; 1-byte Folded Reload
	ld	a, e
	ld	(_render_benchmark_last+3), a
	ld	a, (ix - 94)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_category), a
	ld	l, a
	sla	l
	ld	bc, 0
	ld	c, l
	ld	hl, _render_benchmark+28
	add	hl, bc
	ld	bc, (hl)
	inc.sis	bc
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	b, a
	ld	h, (ix - 93)                    ; 1-byte Folded Reload
	.local	.LBB3_16
.LBB3_16:                               ;   in Loop: Header=BB3_4 Depth=2
	inc	d
	jp	.LBB3_4
	.local	.LBB3_17
.LBB3_17:                               ;   in Loop: Header=BB3_2 Depth=1
	call	_game_render_benchmark_end
	ld	hl, (_render_benchmark+42)
	ld	a, (_render_benchmark+45)
	ld	e, a
	ld	bc, (ix - 71)
	ld	d, (ix - 68)                    ; 1-byte Folded Reload
	ld	a, d
	call	__lcmpu
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	bit	0, a
	jr	nz, .LBB3_19
; %bb.18:                               ;   in Loop: Header=BB3_2 Depth=1
	push	bc
	pop	hl
	.local	.LBB3_19
.LBB3_19:                               ;   in Loop: Header=BB3_2 Depth=1
	bit	0, a
	ld	iyl, 0
	jr	nz, .LBB3_21
; %bb.20:                               ;   in Loop: Header=BB3_2 Depth=1
	ld	e, d
	.local	.LBB3_21
.LBB3_21:                               ;   in Loop: Header=BB3_2 Depth=1
	ld	a, (ix - 83)                    ; 1-byte Folded Reload
	inc	a
	ld	(ix - 71), hl
	ld	(ix - 68), e                    ; 1-byte Folded Spill
	jp	.LBB3_2
	.local	.LBB3_22
.LBB3_22:
	ld	de, _render_benchmark
	ld	hl, (ix - 74)
	ld	bc, 66
	ldir
	ld	hl, (ix - 77)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 79)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, (ix - 78)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_category), a
	ld	a, iyl
	ld	(_render_benchmark_active), a
	ld	l, 8
	ld	bc, (ix - 71)
	ld	a, (ix - 68)                    ; 1-byte Folded Reload
	call	__lshl
	push	bc
	pop	hl
	ld	e, a
	ld	bc, 65
	ld	a, iyl
	call	__ldivu
	.local	.LBB3_23
.LBB3_23:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_game_render_benchmark_calibrate, .Lfunc_end3-_game_render_benchmark_calibrate
                                        ; -- End function
	.section	.text._game_render_benchmark_read,"ax",@progbits
	.globl	_game_render_benchmark_read     ; -- Begin function game_render_benchmark_read
	.type	_game_render_benchmark_read,@function
_game_render_benchmark_read:            ; @game_render_benchmark_read
; %bb.0:
	ld	hl, _render_benchmark
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_game_render_benchmark_read, .Lfunc_end4-_game_render_benchmark_read
                                        ; -- End function
	.section	.text._game_init,"ax",@progbits
	.globl	_game_init                      ; -- Begin function game_init
	.type	_game_init,@function
_game_init:                             ; @game_init
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	hl, 384
	ld	de, 640
	ld.sis	bc, 8192
	ld	(iy), hl
	ld	(iy + 3), de
	ld	(iy + 6), c
	ld	(iy + 7), b
	ld	(iy + 11), c
	ld	(iy + 15), c
	ld	(iy + 16), c
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_game_init, .Lfunc_end5-_game_init
                                        ; -- End function
	.section	.text._game_graphics_init,"ax",@progbits
	.globl	_game_graphics_init             ; -- Begin function game_graphics_init
	.type	_game_graphics_init,@function
_game_graphics_init:                    ; @game_graphics_init
; %bb.0:
	ld	hl, -67
	call	__frameset
	or	a, a
	sbc	hl, hl
	ld	e, 3
	ld	(ix - 16), e
	ld	(ix - 15), d
	ld	de, _render_direction_y_by_angle
	ld	(ix - 14), de
	ld	de, _render_fov_by_direction
	ld	(ix - 25), de
	ld	de, _render_screen_rows+4
	ld	(ix - 22), de
	ld	a, 18
	ld	(ix - 33), a
	ld	de, 1184274
	ld	(ix - 36), de
	ld	de, _render_wall_colors
	ld	(ix - 39), de
	ld	de, _game_graphics_init.wall_palette_rgb+2
	ld	(ix - 28), de
	ld	de, -1899996
	ld	(ix - 31), de
	lea	de, ix - 8
	ld	(ix - 45), de
	ld	de, 64
	push	hl
	pop	bc
	.local	.LBB6_1
.LBB6_1:                                ; %.loopexit24
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_5 Depth 2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_12
; %bb.2:                                ;   in Loop: Header=BB6_1 Depth=1
	push	bc
	pop	hl
	add	hl, hl
	ex	de, hl
	ld	iy, _direction_y
	lea	hl, iy + 0
	add	hl, de
	ld	iy, (hl)
	inc	bc
	ld	(ix - 48), bc
	push	bc
	pop	hl
	ld	bc, 63
	call	__iand
	add	hl, hl
	ex	de, hl
	ld	hl, _direction_y
	add	hl, de
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	lea	de, iy + 0
	ld	(ix - 42), de
	or	a, a
	sbc.sis	hl, de
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	add.sis	hl, hl
	sbc.sis	hl, hl
	ld	c, l
	ld	b, h
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	add.sis	hl, bc
	call	__sxor
	ld.sis	bc, 255
	call	__sand
	ld	c, l
	ld	b, h
	or	a, a
	sbc	hl, hl
	ld	(ix - 19), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 0
	sbc.sis	hl, de
	call	pe, __setflag
	ld.sis	hl, -1
	jp	m, .LBB6_4
; %bb.3:                                ;   in Loop: Header=BB6_1 Depth=1
	ld.sis	hl, 0
	.local	.LBB6_4
.LBB6_4:                                ;   in Loop: Header=BB6_1 Depth=1
	ld	de, (ix - 19)
	ld	e, c
	ld	d, b
	ld	(ix - 19), de
	ld.sis	bc, 1
	call	__sor
	ld	(ix - 51), l
	ld	(ix - 50), h
	or	a, a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	(ix - 11), hl
	.local	.LBB6_5
.LBB6_5:                                ;   Parent Loop BB6_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	lea	bc, iy + 0
	ld	de, 512
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_11
; %bb.6:                                ;   in Loop: Header=BB6_5 Depth=2
	ld	hl, (ix - 14)
	ld	(ix - 54), bc
	add	hl, bc
	ld	de, (ix - 42)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	bc, (ix - 19)
	ld	hl, (ix - 11)
	add	hl, bc
	ld	(ix - 11), hl
	ld	bc, 65535
	call	__iand
	push	hl
	pop	iy
	ld	bc, 256
	or	a, a
	sbc	hl, bc
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	bc, -256
	add	iy, bc
	lea	bc, iy + 0
	bit	0, a
	jr	nz, .LBB6_8
; %bb.7:                                ;   in Loop: Header=BB6_5 Depth=2
	ld	bc, (ix - 11)
	.local	.LBB6_8
.LBB6_8:                                ;   in Loop: Header=BB6_5 Depth=2
	bit	0, a
	ld	l, (ix - 51)
	ld	h, (ix - 50)
	jr	nz, .LBB6_10
; %bb.9:                                ;   in Loop: Header=BB6_5 Depth=2
	ld.sis	hl, 0
	.local	.LBB6_10
.LBB6_10:                               ;   in Loop: Header=BB6_5 Depth=2
	add.sis	hl, de
	ld	iy, (ix - 54)
	ld	de, 2
	add	iy, de
	ld	(ix - 11), bc
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 42), hl
	jp	.LBB6_5
	.local	.LBB6_11
.LBB6_11:                               ; %.loopexit24.loopexit
                                        ;   in Loop: Header=BB6_1 Depth=1
	ld	hl, (ix - 14)
	add	hl, de
	ld	(ix - 14), hl
	ld	de, 64
	ld	bc, (ix - 48)
	jp	.LBB6_1
	.local	.LBB6_12
.LBB6_12:
	ld	bc, 257
	ld	a, 8
	ld	de, -256
	or	a, a
	sbc	hl, hl
	ld	(ix - 11), hl
	.local	.LBB6_13
.LBB6_13:                               ; %.preheader23
                                        ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_17
; %bb.14:                               ;   in Loop: Header=BB6_13 Depth=1
	ld	hl, (ix - 11)
	ld	c, a
	call	__ishl
	ld	bc, -65536
	add	hl, bc
	ld	c, a
	call	__ishrs
	ld	(ix - 19), hl
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 14), de
	ex	de, hl
	add	hl, bc
	call	__ixor
	ld	bc, 169
	call	__imulu
	push	hl
	pop	iy
	ld	bc, 8388352
	call	__iand
	call	__ineg
	push	hl
	pop	bc
	ld	hl, (ix - 19)
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB6_16
; %bb.15:                               ;   in Loop: Header=BB6_13 Depth=1
	lea	bc, iy + 0
	.local	.LBB6_16
.LBB6_16:                               ;   in Loop: Header=BB6_13 Depth=1
	push	bc
	pop	hl
	ld	c, a
	call	__ishru
	ld	iy, (ix - 25)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 11)
	inc	hl
	ld	(ix - 11), hl
	ld	de, (ix - 14)
	inc	de
	lea	iy, iy + 2
	ld	(ix - 25), iy
	ld	bc, 257
	jp	.LBB6_13
	.local	.LBB6_17
.LBB6_17:
	or	a, a
	sbc	hl, hl
	ld	(_render_screen_rows), hl
	ld	de, 76800
	ld	iy, 320
	ld.sis	bc, 960
	.local	.LBB6_18
.LBB6_18:                               ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_20
; %bb.19:                               ;   in Loop: Header=BB6_18 Depth=1
	lea	hl, iy + 0
	ld	iy, (ix - 22)
	ld	(iy), hl
	ld	de, 320
	add	hl, de
	ld	de, 76800
	lea	iy, iy + 4
	ld	(ix - 22), iy
	push	hl
	pop	iy
	jr	.LBB6_18
	.local	.LBB6_20
.LBB6_20:
	ld.sis	hl, 0
	ld	(ix - 14), l
	ld	(ix - 13), h
	ld	(ix - 22), l
	ld	(ix - 21), h
	or	a, a
	sbc	hl, hl
	ex	de, hl
	.local	.LBB6_21
.LBB6_21:                               ; %.preheader22
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_24 Depth 2
                                        ;     Child Loop BB6_36 Depth 2
	sbc	hl, hl
	adc	hl, de
	ld	(ix - 11), de
	jr	z, .LBB6_27
; %bb.22:                               ; %.preheader22
                                        ;   in Loop: Header=BB6_21 Depth=1
	ex	de, hl
	ld	de, 2048
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_42
; %bb.23:                               ; %.preheader20.preheader
                                        ;   in Loop: Header=BB6_21 Depth=1
	ld	e, c
	ld	d, b
	.local	.LBB6_24
.LBB6_24:                               ; %.preheader20
                                        ;   Parent Loop BB6_21 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	iyl, e
	ld	iyh, d
	ld	bc, 0
	ld	c, iyl
	ld	b, iyh
	ld	hl, (ix - 11)
	call	__imulu
	push	hl
	pop	bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 2
	or	a, a
	sbc.sis	hl, de
	jr	c, .LBB6_26
; %bb.25:                               ; %.preheader20
                                        ;   in Loop: Header=BB6_24 Depth=2
	ld	e, iyl
	ld	d, iyh
	dec.sis	de
	push	bc
	pop	hl
	ld	bc, 15361
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB6_24
	.local	.LBB6_26
.LBB6_26:                               ; %.loopexit21.loopexit
                                        ;   in Loop: Header=BB6_21 Depth=1
	ld	c, iyl
	ld	b, iyh
	ld	de, (ix - 11)
	.local	.LBB6_27
.LBB6_27:                               ; %.loopexit21
                                        ;   in Loop: Header=BB6_21 Depth=1
	ld	l, c
	ld	h, b
	ld	iyl, c
	ld	iyh, b
	ld	c, (ix - 22)
	ld	b, (ix - 21)
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB6_29
; %bb.28:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	l, (ix - 14)
	ld	h, (ix - 13)
	ld	c, iyl
	ld	b, iyh
	jp	.LBB6_41
	.local	.LBB6_29
.LBB6_29:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	de, 0
	ld	l, (ix - 14)
	ld	h, (ix - 13)
	ld	e, l
	ld	d, h
	ld	(ix - 25), de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	c, iyl
	ld	b, iyh
	ld	iy, _render_wall_scale_profiles
	add	iy, de
	ld.sis	hl, 2048
	ld	(ix - 19), c
	ld	(ix - 18), b
	ld	c, (ix - 19)
	ld	b, (ix - 18)
	call	__sdivu
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	(ix - 42), l
	ld	(ix - 41), h
	ld	l, e
	ld	h, d
	ld.sis	bc, 240
	or	a, a
	sbc.sis	hl, bc
	ld	l, e
	ld	h, d
	jr	c, .LBB6_31
; %bb.30:                               ;   in Loop: Header=BB6_21 Depth=1
	ld.sis	hl, 240
	.local	.LBB6_31
.LBB6_31:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	(ix - 48), l
	ld	(ix - 47), h
	ld	(iy), e
	ld	(iy + 1), d
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	ld	d, e
	ld	a, -16
	sub	a, d
	ld	h, a
	srl	h
	bit	0, l
	ld	a, 0
	ld	c, a
	jr	nz, .LBB6_33
; %bb.32:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	c, h
	.local	.LBB6_33
.LBB6_33:                               ;   in Loop: Header=BB6_21 Depth=1
	bit	0, l
	ld	e, -16
	ld	a, e
	jr	nz, .LBB6_35
; %bb.34:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	a, h
	add	a, d
	ld	l, a
	.local	.LBB6_35
.LBB6_35:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	(ix - 22), c
	ld	(ix - 21), b
	ld	(iy + 2), c
	ld	(iy + 3), a
	ld	hl, (ix - 25)
	ld	bc, 9
	call	__imulu
	ld	(ix - 51), hl
	ld	hl, _render_wall_texture_boundaries
	ld	de, (ix - 51)
	add	hl, de
	ld	(iy + 4), hl
	ld	e, (ix - 22)
	ld	d, (ix - 21)
	ld	d, b
	ld	h, d
	ld	l, a
	ld	(ix - 22), e
	ld	(ix - 21), d
	add.sis	hl, de
	ld	a, h
                                        ; kill: def $l killed $l killed $hl
	srl	a
	rr	l
                                        ; kill: def $l killed $l def $hl
	ld	h, a
	ld	a, l
	ld	(iy + 7), a
	or	a, a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	e, (ix - 42)
	ld	d, (ix - 41)
	ld	iyl, e
	ld	iyh, d
	ld	e, (ix - 48)
	ld	d, (ix - 47)
	ld	l, e
	ld	h, d
	ld	(ix - 42), hl
	ld	hl, (ix - 25)
	call	__imulu
	ex	de, hl
	ld	hl, _render_wall_texture_boundaries
	add	hl, de
	ld	(ix - 48), hl
	ld	de, 0
	.local	.LBB6_36
.LBB6_36:                               ;   Parent Loop BB6_21 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_40
; %bb.37:                               ;   in Loop: Header=BB6_36 Depth=2
	push	de
	pop	hl
	ld	c, 8
	call	__ishl
	push	hl
	pop	bc
	lea	hl, iy + 0
	add	hl, bc
	dec	hl
	ld	(ix - 25), iy
	lea	bc, iy + 0
	call	__idivu
	push	hl
	pop	iy
	ld	bc, (ix - 42)
	or	a, a
	sbc	hl, bc
	jr	c, .LBB6_39
; %bb.38:                               ;   in Loop: Header=BB6_36 Depth=2
	ld	iy, (ix - 42)
	.local	.LBB6_39
.LBB6_39:                               ;   in Loop: Header=BB6_36 Depth=2
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	c, (ix - 22)
	ld	b, (ix - 21)
	ld	a, c
	add	a, l
	ld	c, a
	ld	hl, (ix - 48)
	add	hl, de
	ld	(hl), c
	inc	de
	ld	bc, 9
	ld	iy, (ix - 25)
	jr	.LBB6_36
	.local	.LBB6_40
.LBB6_40:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	l, (ix - 14)
	ld	h, (ix - 13)
	inc.sis	hl
	ld	c, (ix - 19)
	ld	b, (ix - 18)
	ld	(ix - 22), c
	ld	(ix - 21), b
	ld	de, (ix - 11)
	.local	.LBB6_41
.LBB6_41:                               ;   in Loop: Header=BB6_21 Depth=1
	ld	(ix - 14), l
	ld	(ix - 13), h
	ld	a, l
	dec	a
	ex	de, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_wall_scale_profile_index
	add	iy, de
	ld	de, (ix - 11)
	ld	(iy), a
	ld	(iy + 1), a
	ld	(iy + 2), a
	ld	(iy + 3), a
	inc	de
	jp	.LBB6_21
	.local	.LBB6_42
.LBB6_42:
	ld	hl, 260
	push	hl
	ld	hl, _render_grid_near_projection
	push	hl
	call	_grid_projection_init
	pop	hl
	pop	hl
	ld	hl, 4096
	push	hl
	ld	hl, _grid_far_projection
	push	hl
	call	_grid_projection_init
	pop	hl
	pop	hl
	ld	a, 7
	ld	de, 0
	ld	bc, 256
	.local	.LBB6_43
.LBB6_43:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB6_45
; %bb.44:                               ;   in Loop: Header=BB6_43 Depth=1
	push	bc
	pop	hl
	push	bc
	pop	iy
	push	de
	pop	bc
	call	__imulu
	ld	c, a
	call	__ishru
	ld	c, l
	ld	hl, _render_portal_profile_by_u
	add	hl, de
	ld	(hl), c
	lea	bc, iy + 0
	inc	de
	dec	bc
	jr	.LBB6_43
	.local	.LBB6_45
.LBB6_45:
	ld	bc, 0
	.local	.LBB6_46
.LBB6_46:                               ; %.preheader19
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_48 Depth 2
                                        ;       Child Loop BB6_50 Depth 3
                                        ;       Child Loop BB6_89 Depth 3
                                        ;         Child Loop BB6_91 Depth 4
	ld	de, 4
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_97
; %bb.47:                               ;   in Loop: Header=BB6_46 Depth=1
	ld	(ix - 51), bc
	push	bc
	pop	hl
	ld	c, 7
	call	__ishl
	ld	(ix - 57), hl
	ld	de, 0
	push	de
	pop	iy
	xor	a, a
	ld	(ix - 14), a                    ; 1-byte Folded Spill
	ld	(ix - 19), a                    ; 1-byte Folded Spill
	.local	.LBB6_48
.LBB6_48:                               ;   Parent Loop BB6_46 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB6_50 Depth 3
                                        ;       Child Loop BB6_89 Depth 3
                                        ;         Child Loop BB6_91 Depth 4
	push	de
	pop	hl
	ld	bc, 16
	or	a, a
	sbc	hl, bc
	jp	z, .LBB6_96
; %bb.49:                               ;   in Loop: Header=BB6_48 Depth=2
	ld	l, 7
	ld	a, e
	and	a, l
	ld	l, a
	ld	(ix - 60), l
	push	de
	pop	hl
	ld	bc, 7
	call	__iand
	ld	(ix - 63), hl
	ld	l, 1
	ld	(ix - 11), de
	ld	a, e
	and	a, l
	ld	l, a
	dec	c
	ld	a, l
	add	a, c
	ld	l, a
	ld	(ix - 64), l
	ld	(ix - 54), iy
	ld	(ix - 25), iy
	ld	iyh, b
	ld	a, (ix - 14)                    ; 1-byte Folded Reload
	ld	(ix - 48), a                    ; 1-byte Folded Spill
	ld	(ix - 42), a                    ; 1-byte Folded Spill
	push	af
	ld	a, (ix - 19)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 22), bc
	.local	.LBB6_50
.LBB6_50:                               ;   Parent Loop BB6_46 Depth=1
                                        ;     Parent Loop BB6_48 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_88
; %bb.51:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	hl, (ix - 51)
	ld	a, l
	or	a, a
	ld	de, (ix - 11)
	jp	nz, .LBB6_60
; %bb.52:                               ;   in Loop: Header=BB6_50 Depth=3
	sbc	hl, hl
	adc	hl, de
	ld	l, 1
	jp	z, .LBB6_57
; %bb.53:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	ld	l, 1
	jp	z, .LBB6_57
; %bb.54:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	hl, (ix - 11)
	ld	de, 8
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB6_56
; %bb.55:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, 0
	.local	.LBB6_56
.LBB6_56:                               ;   in Loop: Header=BB6_50 Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	ccf
	ld	e, a
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	ld	a, e
	and	a, l
	ld	l, a
	.local	.LBB6_57
.LBB6_57:                               ;   in Loop: Header=BB6_50 Depth=3
	bit	0, l
	ld	d, 0
	jp	nz, .LBB6_87
; %bb.58:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	ld	hl, (ix - 11)
	push	af
	ld	a, iyh
	ld	(ix - 65), a                    ; 1-byte Folded Spill
	pop	af
	push	af
	ld	a, iyl
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	pop	af
	push	bc
	pop	iy
	ld	bc, (ix - 22)
	ld	a, c
	xor	a, l
	ld	d, a
	lea	bc, iy + 0
	push	af
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	push	af
	ld	a, (ix - 65)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	l, e
	ld	h, d
	mlt	hl
	ld	a, iyl
	add	a, l
	ld	l, a
	ld	(ix - 16), e
	ld	(ix - 15), d
	.local	.LBB6_59
.LBB6_59:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, l
	and	a, e
	ld	l, a
	ld	e, 2
	ld	a, l
	add	a, e
	ld	d, a
	jp	.LBB6_87
	.local	.LBB6_60
.LBB6_60:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, l
	cp	a, 1
	jp	nz, .LBB6_72
; %bb.61:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, (ix - 60)                    ; 1-byte Folded Reload
	or	a, a
	ld	a, -1
	jr	z, .LBB6_63
; %bb.62:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, 0
	.local	.LBB6_63
.LBB6_63:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	(ix - 67), a
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	a, iyh
	and	a, l
	ld	l, a
	or	a, a
	ld	l, -1
	jr	z, .LBB6_65
; %bb.64:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	l, 0
	.local	.LBB6_65
.LBB6_65:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	de, (ix - 63)
	ld	a, e
	cp	a, 2
	jr	z, .LBB6_67
; %bb.66:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	de, (ix - 63)
	ld	a, e
	cp	a, 6
	ld	h, 0
	jr	nz, .LBB6_68
	.local	.LBB6_67
.LBB6_67:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	e, 1
	ld	a, iyh
	and	a, e
	ld	h, a
	.local	.LBB6_68
.LBB6_68:                               ;   in Loop: Header=BB6_50 Depth=3
	bit	0, h
	ld	h, 7
	jr	nz, .LBB6_70
; %bb.69:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	de, (ix - 11)
	push	af
	ld	a, iyh
	ld	(ix - 65), a                    ; 1-byte Folded Spill
	pop	af
	push	af
	ld	a, iyl
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	pop	af
	push	bc
	pop	iy
	ld	bc, (ix - 22)
	ld	a, c
	xor	a, e
	ld	h, a
	lea	bc, iy + 0
	push	af
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	push	af
	ld	a, (ix - 65)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, (ix - 42)
	add	a, h
	ld	h, a
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	ld	a, h
	and	a, e
	ld	h, a
	ld	e, 2
	ld	a, h
	add	a, e
	ld	h, a
	.local	.LBB6_70
.LBB6_70:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, (ix - 67)
	or	a, l
	ld	l, a
	bit	0, l
	ld	d, 0
	jp	nz, .LBB6_87
; %bb.71:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	d, h
	jp	.LBB6_87
	.local	.LBB6_72
.LBB6_72:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, l
	cp	a, 2
	jp	nz, .LBB6_83
; %bb.73:                               ;   in Loop: Header=BB6_50 Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	ld	hl, 0
	ex	de, hl
	jr	c, .LBB6_75
; %bb.74:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	hl, 8
	ex	de, hl
	.local	.LBB6_75
.LBB6_75:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	ld	a, -1
	ld	hl, (ix - 11)
	jr	z, .LBB6_77
; %bb.76:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, 0
	.local	.LBB6_77
.LBB6_77:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	(ix - 67), a
	or	a, a
	sbc	hl, de
	ld	h, -1
	jr	z, .LBB6_79
; %bb.78:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	h, 0
	.local	.LBB6_79
.LBB6_79:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	l, 31
	ld	de, (ix - 25)
	ld	a, e
	and	a, l
	ld	l, a
	or	a, a
	ld	l, 1
	jr	z, .LBB6_81
; %bb.80:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	de, (ix - 11)
	push	af
	ld	a, iyh
	ld	(ix - 65), a                    ; 1-byte Folded Spill
	pop	af
	push	af
	ld	a, iyl
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	pop	af
	push	bc
	pop	iy
	ld	bc, (ix - 22)
	ld	a, c
	xor	a, e
	ld	l, a
	lea	bc, iy + 0
	push	af
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	push	af
	ld	a, (ix - 65)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, (ix - 48)
	add	a, l
	ld	l, a
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	ld	a, l
	and	a, e
	ld	l, a
	ld	e, 2
	ld	a, l
	add	a, e
	ld	l, a
	.local	.LBB6_81
.LBB6_81:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, (ix - 67)
	or	a, h
	ld	h, a
	bit	0, h
	ld	d, 0
	jr	nz, .LBB6_87
; %bb.82:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	d, l
	jr	.LBB6_87
	.local	.LBB6_83
.LBB6_83:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	a, (ix - 60)                    ; 1-byte Folded Reload
	or	a, a
	ld	d, 0
	jr	z, .LBB6_87
; %bb.84:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB6_87
; %bb.85:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	l, 6
	ld	a, iyl
	and	a, l
	ld	l, a
	or	a, a
	ld	d, (ix - 64)                    ; 1-byte Folded Reload
	jr	z, .LBB6_87
; %bb.86:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	hl, (ix - 11)
	ld	de, (ix - 22)
	ld	a, e
	xor	a, l
	ld	l, a
	ld	a, iyl
	add	a, l
	ld	l, a
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	jp	.LBB6_59
	.local	.LBB6_87
.LBB6_87:                               ;   in Loop: Header=BB6_50 Depth=3
	ld	hl, (ix - 45)
	add	hl, bc
	ld	(hl), d
	inc	bc
	ld	de, 2
	ld	hl, (ix - 22)
	add	hl, de
	ld	(ix - 22), hl
	ld	a, e
	ld	l, a
	ld	a, iyl
	add	a, l
	ld	iyl, a
	ld	e, (ix - 42)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 42), e
	ld	l, 6
	ld	e, (ix - 48)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 48), e
	inc	iyh
	ld	de, 10
	ld	hl, (ix - 25)
	add	hl, de
	ld	(ix - 25), hl
	jp	.LBB6_50
	.local	.LBB6_88
.LBB6_88:                               ;   in Loop: Header=BB6_48 Depth=2
	ld	hl, (ix - 11)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, (ix - 57)
	add	hl, de
	ld	(ix - 25), hl
	ld	hl, 1
	ld	(ix - 22), hl
	ld	d, h
	ld	a, d
	ld	de, 0
	.local	.LBB6_89
.LBB6_89:                               ;   Parent Loop BB6_46 Depth=1
                                        ;     Parent Loop BB6_48 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB6_91 Depth 4
	push	de
	pop	hl
	ld	bc, 8
	or	a, a
	sbc	hl, bc
	ld	iy, (ix - 54)
	jr	z, .LBB6_95
; %bb.90:                               ;   in Loop: Header=BB6_89 Depth=3
	push	de
	pop	hl
	push	de
	pop	bc
	ld	de, (ix - 25)
	add	hl, de
	add	hl, hl
	ld	(ix - 60), hl
	ld	hl, (ix - 45)
	ld	(ix - 48), bc
	add	hl, bc
	ld	h, (hl)
	ld	bc, (ix - 22)
	ld	(ix - 42), a                    ; 1-byte Folded Spill
	.local	.LBB6_91
.LBB6_91:                               ;   Parent Loop BB6_46 Depth=1
                                        ;     Parent Loop BB6_48 Depth=2
                                        ;       Parent Loop BB6_89 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ex	de, hl
	ld	iyl, d
	ex	de, hl
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_93
; %bb.92:                               ;   in Loop: Header=BB6_91 Depth=4
	ld	hl, (ix - 45)
	add	hl, bc
	inc	a
	inc	bc
	ld	e, a
	ld	a, (hl)
	ex	de, hl
	ld	d, iyl
	ex	de, hl
	cp	a, h
	ld	a, e
	jr	z, .LBB6_91
	jr	.LBB6_94
	.local	.LBB6_93
.LBB6_93:                               ;   in Loop: Header=BB6_89 Depth=3
	ld	e, 8
	ld	a, e
	ex	de, hl
	ld	d, iyl
	ex	de, hl
	.local	.LBB6_94
.LBB6_94:                               ; %.loopexit
                                        ;   in Loop: Header=BB6_89 Depth=3
	ld	l, a
	ld	a, h
	ld	b, 2
	call	__bshl
	ld	iy, _render_wall_texture_runs
	ld	de, (ix - 60)
	add	iy, de
	ld	(iy), a
	ld	(iy + 1), l
	ld	de, (ix - 48)
	inc	de
	ld	a, (ix - 42)                    ; 1-byte Folded Reload
	inc	a
	ld	hl, (ix - 22)
	inc	hl
	ld	(ix - 22), hl
	jr	.LBB6_89
	.local	.LBB6_95
.LBB6_95:                               ;   in Loop: Header=BB6_48 Depth=2
	ld	bc, (ix - 11)
	inc	bc
	inc	(ix - 19)
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	e, (ix - 14)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 14), e
	ld	de, 13
	add	iy, de
	push	bc
	pop	de
	jp	.LBB6_48
	.local	.LBB6_96
.LBB6_96:                               ;   in Loop: Header=BB6_46 Depth=1
	ld	bc, (ix - 51)
	inc	bc
	jp	.LBB6_46
	.local	.LBB6_97
.LBB6_97:
	ld	iy, 0
	.local	.LBB6_98
.LBB6_98:                               ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_100 Depth 2
                                        ;       Child Loop BB6_102 Depth 3
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_106
; %bb.99:                               ;   in Loop: Header=BB6_98 Depth=1
	ld	a, (ix - 33)                    ; 1-byte Folded Reload
	ld	(ix - 11), a
	ld	hl, (ix - 36)
	ld	(ix - 14), hl
	ld	hl, (ix - 39)
	ld	(ix - 19), hl
	ld	bc, 0
	.local	.LBB6_100
.LBB6_100:                              ;   Parent Loop BB6_98 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB6_102 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_105
; %bb.101:                              ;   in Loop: Header=BB6_100 Depth=2
	ld	(ix - 25), bc
	ld	(ix - 22), iy
	ld	a, (ix - 11)                    ; 1-byte Folded Reload
	ld	iy, (ix - 14)
	ld	de, 0
	.local	.LBB6_102
.LBB6_102:                              ;   Parent Loop BB6_98 Depth=1
                                        ;     Parent Loop BB6_100 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_104
; %bb.103:                              ;   in Loop: Header=BB6_102 Depth=3
	lea	hl, iy + 0
	ld	iy, (ix - 19)
	add	iy, de
	ld	(iy + 3), a
	ld	(iy), hl
	push	hl
	pop	iy
	ex	de, hl
	ld	de, 4
	add	hl, de
	ld	de, 65793
	add	iy, de
	inc	a
	ex	de, hl
	jr	.LBB6_102
	.local	.LBB6_104
.LBB6_104:                              ;   in Loop: Header=BB6_100 Depth=2
	ld	bc, (ix - 25)
	inc	bc
	ld	iy, (ix - 19)
	lea	iy, iy + 32
	ld	(ix - 19), iy
	ld	de, 526344
	ld	hl, (ix - 14)
	add	hl, de
	ld	(ix - 14), hl
	ld	l, d
	ld	e, (ix - 11)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 11), e
	ld	de, 4
	ld	iy, (ix - 22)
	jr	.LBB6_100
	.local	.LBB6_105
.LBB6_105:                              ;   in Loop: Header=BB6_98 Depth=1
	inc	iy
	ld	hl, (ix - 39)
	ld	bc, 128
	add	hl, bc
	ld	(ix - 39), hl
	ld	bc, 2105376
	ld	hl, (ix - 36)
	add	hl, bc
	ld	(ix - 36), hl
	ld	l, b
	ld	c, (ix - 33)
	ld	a, c
	add	a, l
	ld	c, a
	ld	(ix - 33), c
	jp	.LBB6_98
	.local	.LBB6_106
.LBB6_106:
	ld.sis	hl, 0
	ld	iy, -1900032
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 3174
	ld	iy, -1900030
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 6345
	ld	iy, -1900028
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 6342
	ld	iy, -1900026
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 4228
	ld	iy, -1900024
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 5503
	ld	iy, -1900022
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 2226
	ld	iy, -1900020
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 5994
	ld	iy, -1900018
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 2533
	ld	iy, -1900016
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 30918
	ld	iy, -1900014
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 16483
	ld	iy, -1900012
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 3930
	ld	iy, -1900010
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 2510
	ld	iy, -1900008
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 32288
	ld	iy, -1900006
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 543
	ld	iy, -1900004
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 23254
	ld	iy, -1900002
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 2148
	ld	iy, -1900000
	ld	(iy), l
	ld	(iy + 1), h
	ld.sis	hl, 5320
	ld	iy, -1899998
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	.local	.LBB6_107
.LBB6_107:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_109 Depth 2
                                        ;       Child Loop BB6_111 Depth 3
	ld	(ix - 19), hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_115
; %bb.108:                              ;   in Loop: Header=BB6_107 Depth=1
	ld	hl, (ix - 31)
	ld	(ix - 11), hl
	ld	bc, 0
	.local	.LBB6_109
.LBB6_109:                              ;   Parent Loop BB6_107 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB6_111 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_114
; %bb.110:                              ;   in Loop: Header=BB6_109 Depth=2
	ld	hl, _game_graphics_init.shade_offsets
	ld	(ix - 25), bc
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 39), a
	ld	iy, (ix - 28)
	or	a, a
	sbc	hl, hl
	.local	.LBB6_111
.LBB6_111:                              ;   Parent Loop BB6_107 Depth=1
                                        ;     Parent Loop BB6_109 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	(ix - 22), hl
	ld	de, 16
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_113
; %bb.112:                              ;   in Loop: Header=BB6_111 Depth=3
	ld	a, (iy - 2)
	ld	c, (ix - 39)                    ; 1-byte Folded Reload
	sub	a, c
	ld	l, a
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	b, l
	call	__bshru
	ld	(ix - 14), iy
	ld	e, a
	ld	d, 0
	ld	l, e
	ld	h, d
	ld	a, c
	ld	c, 10
	call	__sshl
	ld	c, a
	ld	(ix - 33), l
	ld	(ix - 32), h
	ld	iy, (ix - 14)
	ld	a, (iy - 1)
	sub	a, c
	ld	l, a
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ld	b, l
	call	__bshru
	ld	e, a
	ld	(ix - 36), de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, (ix - 33)
	ld	d, (ix - 32)
	add.sis	hl, de
	ld	iy, (ix - 14)
	ld	a, (iy)
	sub	a, c
	ld	b, a
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	ld	b, e
	call	__bshru
	ld	e, a
	ld	bc, (ix - 36)
	ld	d, b
	add.sis	hl, de
	ld	iy, (ix - 11)
	ld	de, (ix - 22)
	add	iy, de
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 14)
	ex	de, hl
	ld	de, 2
	add	hl, de
	lea	iy, iy + 3
	jp	.LBB6_111
	.local	.LBB6_113
.LBB6_113:                              ;   in Loop: Header=BB6_109 Depth=2
	ld	bc, (ix - 25)
	inc	bc
	ld	iy, (ix - 11)
	lea	iy, iy + 16
	ld	(ix - 11), iy
	ld	de, 4
	jp	.LBB6_109
	.local	.LBB6_114
.LBB6_114:                              ;   in Loop: Header=BB6_107 Depth=1
	ld	hl, (ix - 19)
	inc	hl
	ld	iy, (ix - 31)
	lea	iy, iy + 64
	ld	(ix - 31), iy
	ld	iy, (ix - 28)
	lea	iy, iy + 24
	ld	(ix - 28), iy
	jp	.LBB6_107
	.local	.LBB6_115
.LBB6_115:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_game_graphics_init, .Lfunc_end6-_game_graphics_init
                                        ; -- End function
	.section	.text._grid_projection_init,"ax",@progbits
	.type	_grid_projection_init,@function ; -- Begin function grid_projection_init
_grid_projection_init:                  ; @grid_projection_init
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	bc, (ix + 9)
	ld	iy, _render_wall_scale_profile_index
	ld	de, 8191
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	c, .LBB7_2
; %bb.1:
	ld	bc, 8191
	.local	.LBB7_2
.LBB7_2:
	add	iy, bc
	ld	a, (iy)
	ld	bc, 0
	ld	c, a
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _render_wall_scale_profiles
	add	hl, de
	ld	hl, (hl)
	ld	(ix - 3), hl
	ld	iy, (ix + 6)
	ld	(iy + 6), l
	ld	(iy + 7), h
	ld	a, h
	srl	a
	ld	e, l
	rr	e
                                        ; kill: def $e killed $e def $de
	ld	d, a
	ld	l, 120
	ld	a, e
	add	a, l
	ld	e, a
	ld	(iy + 8), e
	ld	hl, (ix - 3)
	ld	c, l
	ld	b, h
	ld	hl, 1007616
	call	__idivu
	ld	(iy), hl
	ld	hl, 1089536
	call	__idivu
	ld	(iy + 3), hl
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_grid_projection_init, .Lfunc_end7-_grid_projection_init
                                        ; -- End function
	.section	.text._game_update,"ax",@progbits
	.globl	_game_update                    ; -- Begin function game_update
	.type	_game_update,@function
_game_update:                           ; @game_update
; %bb.0:
	ld	hl, -35
	call	__frameset
	ld	iy, (ix + 6)
	ld	c, (ix + 15)
	ld	hl, (iy)
	ld	(ix - 6), hl
	ld	hl, (iy + 3)
	ld	(ix - 12), hl
	ld	hl, (iy + 6)
	ld	(ix - 15), hl
	ld	a, (iy + 8)
	ld	(ix - 16), a
	ld	a, (iy + 9)
	ld	(ix - 17), a
	ld	a, (iy + 10)
	ld	(ix - 18), a
	ld	a, (iy + 11)
	ld	(ix - 19), a
	ld	a, (iy + 12)
	ld	(ix - 20), a
	ld	a, (iy + 13)
	ld	(ix - 21), a
	ld	d, (iy + 14)
	ld	e, (iy + 15)
	ld	a, (iy + 16)
	ld	b, c
	ld	(iy + 16), c
	ld	hl, (ix + 21)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB8_2
	.local	.LBB8_1
.LBB8_1:
	ld	c, 0
	jp	.LBB8_29
	.local	.LBB8_2
.LBB8_2:
	ld	(ix - 28), d                    ; 1-byte Folded Spill
	ld	(ix - 29), e                    ; 1-byte Folded Spill
	ld	de, (ix + 18)
	ld	l, -1
	xor	a, l
	ld	l, a
	ld	a, l
	and	a, b
	ld	l, a
	ld	(ix - 3), l
	ld	a, 3
	ld	hl, (ix + 21)
	ld	c, a
	call	__ishru
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jr	c, .LBB8_4
; %bb.3:
	push	de
	pop	bc
	.local	.LBB8_4
.LBB8_4:
	ld	(ix - 9), bc
	ld	l, 1
	ld	a, (ix - 3)
	and	a, l
	ld	l, a
	bit	0, l
	ld	hl, 1
	push	hl
	push	iy
	call	nz, _place_portal
	pop	hl
	pop	hl
	bit	1, (ix - 3)                     ; 1-byte Folded Reload
	jr	z, .LBB8_6
; %bb.5:
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_place_portal
	pop	hl
	pop	hl
	.local	.LBB8_6
.LBB8_6:
	ld	bc, 3072
	bit	2, (ix - 3)                     ; 1-byte Folded Reload
	jr	z, .LBB8_8
; %bb.7:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	(iy + 11), 0
	ld	(iy + 15), 0
	.local	.LBB8_8
.LBB8_8:
	or	a, a
	sbc	hl, hl
	ld	d, l
	ld	hl, (ix - 9)
	ld	e, d
	xor	a, a
	call	__lmulu
	ld	bc, (ix + 21)
	ld	a, d
	call	__ldivu
	ld	(ix - 3), hl
	ld	iy, (ix + 6)
	ld	iy, (iy + 6)
	ld	e, (ix + 12)
	ld	a, e
	rlc	a
	sbc.sis	hl, hl
	ld	c, l
	ld	b, h
	ld	c, e
	ld	hl, (ix - 3)
                                        ; kill: def $hl killed $hl killed $uhl
	call	__smulu
	lea	bc, iy + 0
	add.sis	hl, bc
	ld	(ix - 27), l
	ld	(ix - 26), h
	ld.sis	bc, 16383
	call	__sand
	ld	(ix - 24), l
	ld	(ix - 23), h
	ld	iy, (ix + 6)
	ld	(iy + 6), l
	ld	(iy + 7), h
	ld	hl, (ix - 9)
	ld	e, d
	ld	bc, 600
	xor	a, a
	call	__lmulu
	ld	bc, (ix + 21)
	ld	a, d
	call	__ldivu
	ex	de, hl
	push	af
	ld	a, (ix + 9)
	ld	iyl, a
	pop	af
	ld	a, iyl
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, iyl
	ex	de, hl
	call	__imulu
	ex	de, hl
	ld	(ix - 3), de
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB8_18
; %bb.9:
	ld	bc, _render_direction_y_by_angle
	ld.sis	iy, 4096
	ld	l, (ix - 24)
	ld	h, (ix - 23)
	add.sis	hl, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	push	bc
	pop	hl
	add	hl, de
	ld	bc, (hl)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 9), hl
	ld	l, (ix - 27)
	ld	h, (ix - 26)
	ld	c, iyl
	ld	b, iyh
	add.sis	hl, bc
	ld.sis	bc, 16383
	call	__sand
	add.sis	hl, hl
	ld	e, l
	ld	d, h
	ld	hl, _render_direction_y_by_angle
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	de, (ix - 3)
	push	de
	pop	hl
	call	__imulu
	ld	(ix - 24), hl
	ex	de, hl
	ld	bc, (ix - 9)
	call	__imulu
	push	hl
	pop	de
	add	hl, hl
	sbc	hl, hl
	ld	c, iyh
	call	__ishru
	push	hl
	pop	bc
	push	de
	pop	hl
	add	hl, bc
	ld	c, 8
	call	__ishrs
	ld	iy, (ix + 6)
	ld	bc, (iy + 3)
	ld	iy, 44
	ld	(ix - 32), bc
	add	hl, bc
	ld	(ix - 9), hl
	ld	bc, 256
	ld	(ix - 27), de
	ex	de, hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	lea	bc, iy + 0
	jp	p, .LBB8_11
; %bb.10:
	ld	bc, -44
	.local	.LBB8_11
.LBB8_11:
	ld	hl, (ix - 9)
	add	hl, bc
	ld	(ix - 9), hl
	ld	de, (ix - 24)
	push	de
	pop	hl
	ld	bc, 255
	add	hl, bc
	ld	bc, 511
	or	a, a
	sbc	hl, bc
	jr	c, .LBB8_15
; %bb.12:
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	push	hl
	pop	bc
	push	de
	pop	hl
	add	hl, bc
	ld	c, 8
	call	__ishrs
	push	hl
	pop	bc
	ld	hl, (ix + 6)
	ld	hl, (hl)
	ld	(ix - 35), hl
	ex	de, hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB8_14
; %bb.13:
	ld	iy, -44
	.local	.LBB8_14
.LBB8_14:
	add	iy, bc
	ld	de, (ix - 35)
	add	iy, de
	ld	hl, (ix - 3)
	push	hl
	ld	hl, (ix - 32)
	push	hl
	push	iy
	ld	hl, (ix + 6)
	push	hl
	call	_try_player_portal
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	ld	bc, 511
	jr	nz, .LBB8_18
	.local	.LBB8_15
.LBB8_15:
	ld	de, 255
	ld	hl, (ix - 27)
	add	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .LBB8_17
; %bb.16:
	ld	hl, (ix + 6)
	ld	de, (hl)
	ld	bc, (ix - 3)
	push	bc
	ld	bc, (ix - 9)
	push	bc
	push	de
	push	hl
	call	_try_player_portal
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jr	nz, .LBB8_18
	.local	.LBB8_17
.LBB8_17:
	ld	hl, (ix - 3)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_move_without_portal
	pop	hl
	pop	hl
	.local	.LBB8_18
.LBB8_18:
	ld	c, 1
	ld	iy, (ix + 6)
	ld	hl, (iy)
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB8_29
; %bb.19:
	ld	hl, (iy + 3)
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB8_29
; %bb.20:
	ld	hl, (iy + 6)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	de, (ix - 15)
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB8_29
; %bb.21:
	ld	a, (iy + 8)
	ld	l, (ix - 16)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.22:
	ld	a, (iy + 9)
	ld	l, (ix - 17)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.23:
	ld	a, (iy + 10)
	ld	l, (ix - 18)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.24:
	ld	a, (iy + 11)
	ld	l, (ix - 19)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.25:
	ld	a, (iy + 12)
	ld	l, (ix - 20)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.26:
	ld	a, (iy + 13)
	ld	l, (ix - 21)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.27:
	ld	a, (iy + 14)
	ld	l, (ix - 28)
	cp	a, l
	jr	nz, .LBB8_29
; %bb.28:
	ld	a, (iy + 15)
	ld	l, (ix - 29)
	cp	a, l
	jp	z, .LBB8_1
	.local	.LBB8_29
.LBB8_29:
	ld	a, c
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_game_update, .Lfunc_end8-_game_update
                                        ; -- End function
	.section	.text._place_portal,"ax",@progbits
	.type	_place_portal,@function         ; -- Begin function place_portal
_place_portal:                          ; @place_portal
; %bb.0:
	ld	hl, -38
	call	__frameset
	ld	iy, (ix + 6)
	ld.sis	bc, 16383
	ld	hl, (iy)
	ld	(ix - 17), hl
	ld	hl, (iy + 3)
	ld	(ix - 20), hl
	ld	iy, (iy + 6)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	call	__sand
	add.sis	hl, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _render_direction_y_by_angle
	add	hl, de
	ld	hl, (hl)
	ld	(ix - 26), hl
	ld	a, h
	rlc	a
	sbc	hl, hl
	ld	(ix - 23), hl
	ld.sis	de, 4096
	add.sis	iy, de
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	iy, (ix + 6)
	call	__sand
	add.sis	hl, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _render_direction_y_by_angle
	add	hl, de
	ld	hl, (hl)
	ld	(ix - 29), hl
	ld	a, h
	rlc	a
	sbc	hl, hl
	ld	(_render_ray_state+43), iy
	ld	a, (iy + 11)
	or	a, a
	ld	b, c
	jr	z, .LBB9_2
; %bb.1:
	ld	a, (iy + 9)
	ld	de, 0
	ld	e, a
	ld	iy, _map_row_offsets
	add	iy, de
	ld	e, (iy)
	ld	iy, (ix + 6)
	ld	a, (iy + 8)
	add	a, e
	ld	c, a
	.local	.LBB9_2
.LBB9_2:
	ld	a, c
	ld	(_render_ray_state+46), a
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB9_4
; %bb.3:
	ld	de, 0
	ld	e, (iy + 13)
	lea	bc, iy + 0
	ld	iy, _map_row_offsets
	add	iy, de
	ld	e, (iy)
	push	bc
	pop	iy
	ld	a, (iy + 12)
	add	a, e
	ld	b, a
	.local	.LBB9_4
.LBB9_4:
	ld	de, 12
	ld	(ix - 38), de
	inc	de
	ld	(ix - 35), de
	inc	de
	ld	(ix - 32), de
	ld	c, 12
	ld	iy, (ix - 23)
	ld	de, (ix - 26)
	ld	iyl, e
	ld	iyh, d
	ld	de, (ix - 29)
	ld	l, e
	ld	h, d
	ld	a, b
	ld	(_render_ray_state+47), a
	.local	.LBB9_5
.LBB9_5:                                ; =>This Inner Loop Header: Depth=1
	ld	a, c
	or	a, a
	jp	z, .LBB9_21
; %bb.6:                                ;   in Loop: Header=BB9_5 Depth=1
	ld	(ix - 23), c                    ; 1-byte Folded Spill
	pea	ix - 14
	push	iy
	push	hl
	ld	hl, (ix - 20)
	push	hl
	ld	hl, (ix - 17)
	push	hl
	call	_render_asm_cast_wall_begin
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_ray_state+54)
	or	a, a
	jr	z, .LBB9_8
; %bb.7:                                ;   in Loop: Header=BB9_5 Depth=1
	call	_render_asm_transform_ray_state
	ld	hl, (_render_ray_state)
	ld	(ix - 17), hl
	ld	hl, (_render_ray_state+3)
	ld	(ix - 20), hl
	ld	hl, (_render_ray_state+6)
	ld	iy, (_render_ray_state+9)
	ld	c, (ix - 23)                    ; 1-byte Folded Reload
	dec	c
	jr	.LBB9_5
	.local	.LBB9_8
.LBB9_8:
	ld	a, (_render_ray_state+52)
	or	a, a
	jr	nz, .LBB9_21
; %bb.9:
	ld	a, (ix + 9)
	or	a, a
	jr	z, .LBB9_11
; %bb.10:
	ld	a, 0
	jr	.LBB9_12
	.local	.LBB9_11
.LBB9_11:
	ld	a, -1
	.local	.LBB9_12
.LBB9_12:
	ld	hl, (ix + 6)
	ld	bc, 15
	bit	0, a
	jr	nz, .LBB9_14
; %bb.13:
	ld	de, 8
	ld	(ix - 38), de
	.local	.LBB9_14
.LBB9_14:
	bit	0, a
	jr	nz, .LBB9_16
; %bb.15:
	ld	de, 9
	ld	(ix - 35), de
	.local	.LBB9_16
.LBB9_16:
	bit	0, a
	jr	nz, .LBB9_18
; %bb.17:
	ld	de, 10
	ld	(ix - 32), de
	.local	.LBB9_18
.LBB9_18:
	ld	e, (ix - 11)
	bit	0, a
	jr	nz, .LBB9_20
; %bb.19:
	ld	bc, 11
	.local	.LBB9_20
.LBB9_20:
	ld	(ix - 17), bc
	push	hl
	pop	iy
	ld	bc, (ix - 38)
	add	iy, bc
	ld	(iy), e
	ld	a, (ix - 10)
	push	hl
	pop	iy
	ld	de, (ix - 35)
	add	iy, de
	ld	(iy), a
	ld	a, (ix - 5)
	push	hl
	pop	iy
	ld	de, (ix - 32)
	add	iy, de
	ld	(iy), a
	ld	de, (ix - 17)
	add	hl, de
	ld	(hl), 1
	.local	.LBB9_21
.LBB9_21:                               ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_place_portal, .Lfunc_end9-_place_portal
                                        ; -- End function
	.section	.text._try_player_portal,"ax",@progbits
	.type	_try_player_portal,@function    ; -- Begin function try_player_portal
_try_player_portal:                     ; @try_player_portal
; %bb.0:
	ld	hl, -23
	call	__frameset
	ld	l, 0
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	hl, (ix + 6)
	ld	iy, (hl)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	b, 16
	ld	c, b
	call	__ishru
	ex	de, hl
	add	iy, de
	ld	a, 8
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	ld	(ix - 9), hl
	ld	iy, (ix + 6)
	ld	iy, (iy + 3)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	c, b
	call	__ishru
	ex	de, hl
	add	iy, de
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	ld	(ix - 12), hl
	ld	iy, (ix + 9)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	c, b
	call	__ishru
	ex	de, hl
	add	iy, de
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	ex	de, hl
	ld	iy, (ix + 12)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	c, b
	call	__ishru
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	push	hl
	pop	iy
	ld	(ix - 15), de
	ex	de, hl
	ld	bc, (ix - 9)
	push	bc
	pop	de
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB10_4
; %bb.1:
	lea	hl, iy + 0
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	jr	z, .LBB10_13
; %bb.2:
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB10_8
; %bb.3:
	ld	a, 0
	jr	.LBB10_9
	.local	.LBB10_4
.LBB10_4:
	ld	hl, (ix - 15)
	push	de
	pop	bc
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB10_6
; %bb.5:
	ld	l, 0
	jr	.LBB10_7
	.local	.LBB10_6
.LBB10_6:
	ld	l, 1
	.local	.LBB10_7
.LBB10_7:
	ld	(ix - 9), hl
	ld	de, (ix - 15)
	jr	.LBB10_10
	.local	.LBB10_8
.LBB10_8:
	ld	a, 1
	.local	.LBB10_9
.LBB10_9:
	ld	de, (ix - 9)
	ld	l, 2
	add	a, l
	ld	l, a
	ld	(ix - 9), hl
	ld	(ix - 12), iy
	.local	.LBB10_10
.LBB10_10:
	ld	bc, 15
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB10_13
; %bb.11:
	ld	iy, (ix - 12)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB10_13
; %bb.12:
	pea	ix - 6
	pea	ix - 5
	pea	ix - 4
	ld	hl, (ix - 9)
	push	hl
	push	iy
	push	de
	ld	hl, (ix + 6)
	push	hl
	call	_render_asm_find_portal
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	or	a, a
	jr	nz, .LBB10_15
	.local	.LBB10_13
.LBB10_13:
	ld	l, 0
	ld	a, l
	.local	.LBB10_14
.LBB10_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB10_15
.LBB10_15:
	ld	bc, 256
	ld	iy, (ix + 6)
	ld	hl, (iy)
	call	__irems
	ex	de, hl
	ld	hl, (iy + 3)
	push	bc
	pop	iy
	call	__irems
	push	hl
	pop	bc
	ld	a, (ix - 2)
	ld	(ix - 15), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 9)
	cp	a, l
	jr	nz, .LBB10_17
; %bb.16:
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	ld	hl, 256
	or	a, a
	sbc	hl, bc
	ld	(ix - 20), hl
	ld	a, 2
	ld	l, a
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	(ix - 12), iy
	jp	.LBB10_33
	.local	.LBB10_17
.LBB10_17:
	ld	(ix - 12), bc
	ld	(ix - 20), de
	ld	de, 0
	ld	e, l
	ld	hl, JTI10_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB10_18
.LBB10_18:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	cp	a, 1
	jp	nz, .LBB10_28
; %bb.19:
	ld	a, (ix - 4)
	ld	de, 0
	ld	e, a
	ld	c, 8
	push	de
	pop	hl
	call	__ishl
	ld	(ix - 9), hl
	ld	a, (ix - 3)
	ld	e, a
	ex	de, hl
	call	__ishl
	ld	(ix - 23), hl
	ld	de, (ix - 12)
	add	hl, de
	ld	iy, (ix + 6)
	ld	(ix - 20), hl
	ld	(iy + 3), hl
	jp	.LBB10_36
	.local	.LBB10_20
.LBB10_20:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	or	a, a
	ld	de, (ix - 12)
	jp	z, .LBB10_31
; %bb.21:
	ld	a, l
	cp	a, 3
	jp	nz, .LBB10_32
; %bb.22:
	ld	a, (ix - 4)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 15), hl
	ld	c, 8
	call	__ishl
	push	hl
	pop	iy
	ld	(ix - 9), iy
	ld	de, (ix - 20)
	add	iy, de
	ld	hl, (ix + 6)
	ld	(ix - 12), iy
	ld	(hl), iy
	ld	a, (ix - 3)
	ld	hl, (ix - 15)
	ld	l, a
	call	__ishl
	ld	(ix - 23), hl
	jp	.LBB10_45
	.local	.LBB10_23
.LBB10_23:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	cp	a, 1
	ld	de, (ix - 12)
	jp	z, .LBB10_31
; %bb.24:
	ld	a, l
	cp	a, 2
	jp	nz, .LBB10_32
; %bb.25:
	ld	a, (ix - 4)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 15), hl
	ld	c, 8
	call	__ishl
	push	hl
	pop	iy
	ld	(ix - 9), iy
	ld	de, (ix - 20)
	add	iy, de
	ld	hl, (ix + 6)
	ld	(ix - 12), iy
	ld	(hl), iy
	ld	a, (ix - 3)
	ld	hl, (ix - 15)
	ld	l, a
	call	__ishl
	ld	(ix - 23), hl
	jp	.LBB10_44
	.local	.LBB10_26
.LBB10_26:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	or	a, a
	jr	nz, .LBB10_29
; %bb.27:
	ld	a, (ix - 4)
	ld	de, 0
	ld	e, a
	ld	c, 8
	push	de
	pop	hl
	call	__ishl
	ld	(ix - 9), hl
	ld	a, (ix - 3)
	ld	e, a
	ex	de, hl
	call	__ishl
	push	hl
	pop	de
	ld	(ix - 23), de
	ld	de, (ix - 12)
	add	hl, de
	ld	iy, (ix + 6)
	ld	(ix - 20), hl
	ld	(iy + 3), hl
	jp	.LBB10_35
	.local	.LBB10_28
.LBB10_28:
	ld	a, l
	cp	a, 3
	jr	.LBB10_30
	.local	.LBB10_29
.LBB10_29:
	ld	a, l
	cp	a, 2
	.local	.LBB10_30
.LBB10_30:
	ld	de, (ix - 12)
	jr	nz, .LBB10_32
	.local	.LBB10_31
.LBB10_31:
	ld	hl, 256
	or	a, a
	sbc	hl, de
	ld	(ix - 12), hl
	ld	a, 1
	ld	l, a
	ld	(ix - 17), l
	ld	(ix - 16), h
	jr	.LBB10_33
	.local	.LBB10_32
.LBB10_32:
	ld	l, -1
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	hl, 256
	ld	de, (ix - 20)
	or	a, a
	sbc	hl, de
	ld	(ix - 20), hl
	.local	.LBB10_33
.LBB10_33:
	ld	a, (ix - 4)
	ld	iy, 0
	lea	hl, iy + 0
	ld	l, a
	ld	c, 8
	call	__ishl
	ld	(ix - 9), hl
	ld	de, (ix - 12)
	add	hl, de
	lea	de, iy + 0
	ld	iy, (ix + 6)
	ld	(ix - 12), hl
	ld	(iy), hl
	ld	a, (ix - 3)
	push	de
	pop	hl
	ld	l, a
	call	__ishl
	ld	(ix - 23), hl
	ld	bc, (ix - 20)
	add	hl, bc
	ld	(ix - 20), hl
	ld	(iy + 3), hl
	ld	a, (ix - 15)                    ; 1-byte Folded Reload
	cp	a, 4
	jp	nc, .LBB10_47
; %bb.34:
	ld	e, a
	ld	iy, JTI10_1
	add	iy, de
	add	iy, de
	add	iy, de
	ld	iy, (iy)
	jp	(iy)
	.local	.LBB10_35
.LBB10_35:
	ld	de, -45
	jr	.LBB10_37
	.local	.LBB10_36
.LBB10_36:
	ld	de, 301
	.local	.LBB10_37
.LBB10_37:
	ld	hl, (ix - 9)
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 20)
	ld	(ix - 9), hl
	ld	iy, (ix + 6)
	ld	(iy), de
	ld	iy, (ix - 23)
	lea	hl, iy + 0
	ld	de, 45
	add	hl, de
	push	hl
	pop	bc
	ld	de, 211
	add	iy, de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	de
	pop	hl
	jp	m, .LBB10_39
; %bb.38:
	push	bc
	pop	de
	.local	.LBB10_39
.LBB10_39:
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	jp	m, .LBB10_41
; %bb.40:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB10_54
	.local	.LBB10_41
.LBB10_41:
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix + 6)
	jr	c, .LBB10_43
; %bb.42:
	push	bc
	pop	de
	.local	.LBB10_43
.LBB10_43:
	ld	(iy + 3), de
	jr	.LBB10_55
	.local	.LBB10_44
.LBB10_44:
	ld	de, -45
	jr	.LBB10_46
	.local	.LBB10_45
.LBB10_45:
	ld	de, 301
	.local	.LBB10_46
.LBB10_46:
	ld	hl, (ix - 23)
	add	hl, de
	ld	iy, (ix + 6)
	ld	(iy + 3), hl
	.local	.LBB10_47
.LBB10_47:
	ld	iy, (ix - 9)
	lea	hl, iy + 0
	ld	de, 45
	add	hl, de
	push	hl
	pop	bc
	ld	de, 211
	add	iy, de
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	push	de
	pop	hl
	jp	m, .LBB10_49
; %bb.48:
	push	bc
	pop	de
	.local	.LBB10_49
.LBB10_49:
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	jp	m, .LBB10_51
; %bb.50:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB10_54
	.local	.LBB10_51
.LBB10_51:
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix + 6)
	jr	c, .LBB10_53
; %bb.52:
	push	bc
	pop	de
	.local	.LBB10_53
.LBB10_53:
	ld	(iy), de
	jr	.LBB10_55
	.local	.LBB10_54
.LBB10_54:
	ld	iy, (ix + 6)
	.local	.LBB10_55
.LBB10_55:
	ld	l, (ix - 17)
	ld	h, (ix - 16)
	ld	h, 0
	ld	de, (iy + 6)
	ld	c, 12
	call	__sshl
	add.sis	hl, de
	ld.sis	bc, 16383
	call	__sand
	ld	(iy + 6), l
	ld	(iy + 7), h
	ld	hl, (ix + 15)
	push	hl
	push	iy
	call	_move_without_portal
	pop	hl
	pop	hl
	ld	a, 1
	jp	.LBB10_14
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_try_player_portal, .Lfunc_end10-_try_player_portal
	.section	.rodata._try_player_portal,"a",@progbits
JTI10_0:
	d24	.LBB10_18
	d24	.LBB10_26
	d24	.LBB10_20
	d24	.LBB10_23
JTI10_1:
	d24	.LBB10_35
	d24	.LBB10_36
	d24	.LBB10_44
	d24	.LBB10_45
                                        ; -- End function
	.section	.text._move_without_portal,"ax",@progbits
	.type	_move_without_portal,@function  ; -- Begin function move_without_portal
_move_without_portal:                   ; @move_without_portal
; %bb.0:
	ld	hl, -15
	call	__frameset
	ld	iy, (ix + 6)
	ld.sis	bc, 16383
	ld	hl, 44
	ld	(ix - 9), hl
	ld	iy, (iy + 6)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	call	__sand
	add.sis	hl, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _render_direction_y_by_angle
	add	hl, de
	ld	bc, (hl)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 3), hl
	ld.sis	bc, 4096
	add.sis	iy, bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 16383
	call	__sand
	add.sis	hl, hl
	ld	e, l
	ld	d, h
	ld	hl, _render_direction_y_by_angle
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, (ix + 9)
	call	__imulu
	ld	(ix - 6), hl
	ld	hl, (ix - 3)
	call	__imulu
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	ex	de, hl
	ld	(ix - 3), iy
	add	iy, de
	ld	c, 8
	lea	hl, iy + 0
	call	__ishrs
	ld	(ix - 12), hl
	ld	hl, (ix - 6)
	push	hl
	pop	bc
	ld	de, 255
	add	hl, de
	ld	de, 511
	or	a, a
	sbc	hl, de
	jp	c, .LBB11_7
; %bb.1:
	push	bc
	pop	de
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	push	hl
	pop	bc
	push	de
	pop	hl
	add	hl, bc
	ld	a, 8
	ld	c, a
	call	__ishrs
	push	hl
	pop	bc
	ld	hl, (ix + 6)
	ld	iy, (hl)
	add	iy, bc
	ex	de, hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	de, 44
	jp	p, .LBB11_3
; %bb.2:
	ld	de, -44
	.local	.LBB11_3
.LBB11_3:
	ld	(ix - 15), iy
	add	iy, de
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	b, 16
	ld	c, b
	call	__ishru
	ex	de, hl
	add	iy, de
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	ld	(ix - 6), hl
	ld	iy, (ix + 6)
	ld	iy, (iy + 3)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	c, b
	call	__ishru
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	push	hl
	pop	bc
	ld	de, 15
	or	a, a
	sbc	hl, de
	jr	nc, .LBB11_7
; %bb.4:
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	nc, .LBB11_7
; %bb.5:
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	bc, (ix - 6)
	call	__ior
	ex	de, hl
	ld	hl, _render_wall_map
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	nz, .LBB11_7
; %bb.6:
	ld	hl, (ix + 6)
	ld	de, (ix - 15)
	ld	(hl), de
	.local	.LBB11_7
.LBB11_7:
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	ld	de, 255
	add	hl, de
	ld	de, 511
	or	a, a
	sbc	hl, de
	jp	c, .LBB11_14
; %bb.8:
	push	bc
	pop	hl
	ld	iy, (ix + 6)
	ld	iy, (iy + 3)
	ld	de, (ix - 12)
	add	iy, de
	ld	de, 256
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB11_10
; %bb.9:
	ld	hl, -44
	ld	(ix - 9), hl
	.local	.LBB11_10
.LBB11_10:
	ld	(ix - 6), iy
	ld	de, (ix - 9)
	add	iy, de
	ld	(ix - 3), iy
	ld	hl, (ix + 6)
	ld	iy, (hl)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	ld	b, 16
	ld	c, b
	call	__ishru
	ex	de, hl
	add	iy, de
	ld	a, 8
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	push	hl
	pop	iy
	ld	de, (ix - 3)
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	ld	c, b
	call	__ishru
	push	hl
	pop	bc
	ex	de, hl
	add	hl, bc
	ld	c, a
	call	__ishrs
	push	hl
	pop	bc
	lea	hl, iy + 0
	ld	de, 15
	or	a, a
	sbc	hl, de
	jr	nc, .LBB11_14
; %bb.11:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB11_14
; %bb.12:
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	lea	bc, iy + 0
	call	__ior
	ex	de, hl
	ld	hl, _render_wall_map
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	nz, .LBB11_14
; %bb.13:
	ld	iy, (ix + 6)
	ld	hl, (ix - 6)
	ld	(iy + 3), hl
	.local	.LBB11_14
.LBB11_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_move_without_portal, .Lfunc_end11-_move_without_portal
                                        ; -- End function
	.section	.text._game_render,"ax",@progbits
	.globl	_game_render                    ; -- Begin function game_render
	.type	_game_render,@function
_game_render:                           ; @game_render
; %bb.0:
	ld	hl, -92
	call	__frameset
	ld.sis	de, 0
	ld	hl, _render_profile+12
	xor	a, a
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	(_render_profile+14), a
	call	_clock
	ld	(ix - 30), hl
	ld	(ix - 33), e                    ; 1-byte Folded Spill
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	iy, _render_benchmark_last
	lea	hl, iy + 3
	ld	(ix - 78), hl
	ld	iy, _render_benchmark+42
	lea	hl, iy + 3
	ld	(ix - 75), hl
	jp	z, .LBB12_7
; %bb.1:
	ld	a, (_render_benchmark_category)
	cp	a, 1
	jp	z, .LBB12_7
; %bb.2:
	ld	(ix - 36), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB12_4
; %bb.3:
	push	bc
	pop	hl
	jr	.LBB12_6
	.local	.LBB12_4
.LBB12_4:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB12_6
; %bb.5:
	ex	de, hl
	.local	.LBB12_6
.LBB12_6:
	ld	(ix - 39), hl
	ld	de, 0
	ld	(ix - 42), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 78)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 36)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 36), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 36)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 75)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 39)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 42)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 1
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+30
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB12_7
.LBB12_7:
	call	_gfx_Wait
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB12_14
; %bb.8:
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	jp	z, .LBB12_14
; %bb.9:
	ld	(ix - 36), l                    ; 1-byte Folded Spill
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
	jr	nc, .LBB12_11
; %bb.10:
	push	bc
	pop	hl
	jr	.LBB12_13
	.local	.LBB12_11
.LBB12_11:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB12_13
; %bb.12:
	ex	de, hl
	.local	.LBB12_13
.LBB12_13:
	ld	(ix - 39), hl
	ld	de, 0
	ld	(ix - 42), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 78)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 36)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 36), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 36)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 75)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 39)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 42)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	xor	a, a
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+28
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB12_14
.LBB12_14:
	call	_clock
	ld	bc, (ix - 30)
	ld	a, (ix - 33)                    ; 1-byte Folded Reload
	call	__lsub
	ld	a, e
	ld	(_render_profile), hl
	ld	(_render_profile+3), a
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	hl, (iy + 6)
	ld	(ix - 36), hl
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 16383
	call	__sand
	add.sis	hl, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	iy, _render_direction_y_by_angle
	lea	hl, iy + 0
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	(ix - 30), de
	ld	l, e
	ld	h, d
	ld	(ix - 33), hl
	ld.sis	de, 4096
	ld	hl, (ix - 36)
	add.sis	hl, de
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sand
	add.sis	hl, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	add	iy, de
	ld	de, (iy)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	(ix - 36), de
	ld	l, e
	ld	h, d
	ld	(ix - 42), hl
	ld	hl, (ix - 33)
	ld	de, 256
	add	hl, de
	ld	bc, 65535
	call	__iand
	add	hl, hl
	ex	de, hl
	ld	iy, _render_fov_by_direction
	lea	hl, iy + 0
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__ineg
	ld	(ix - 39), hl
	ld	hl, (ix - 42)
	ld	de, 256
	add	hl, de
	call	__iand
	add	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	ld	bc, (iy)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 45), hl
	ld	hl, (ix - 39)
	push	hl
	ld	hl, (ix - 42)
	push	hl
	pea	ix - 19
	call	_ray_stepper_init
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 45)
	push	hl
	ld	hl, (ix - 33)
	push	hl
	pea	ix - 27
	call	_ray_stepper_init
	ld	c, -1
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	pop	hl
	pop	hl
	pop	hl
	ld	a, (iy + 11)
	or	a, a
	ld	l, c
	jr	z, .LBB12_16
; %bb.15:
	ld	a, (iy + 9)
	ld	de, 0
	ld	e, a
	ld	hl, _map_row_offsets
	add	hl, de
	ld	l, (hl)
	ld	a, (iy + 8)
	add	a, l
	ld	l, a
	.local	.LBB12_16
.LBB12_16:
	ld	a, l
	ld	(_render_scratch+14), a
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB12_18
; %bb.17:
	ld	a, (iy + 13)
	ld	de, 0
	ld	e, a
	lea	bc, iy + 0
	ld	iy, _map_row_offsets
	add	iy, de
	ld	e, (iy)
	push	bc
	pop	iy
	ld	a, (iy + 12)
	add	a, e
	ld	c, a
	.local	.LBB12_18
.LBB12_18:
	ld	a, c
	ld	(_render_scratch+15), a
	ld	(_render_ray_state+43), iy
	ld	a, l
	ld	(_render_ray_state+46), a
	ld	a, c
	ld	(_render_ray_state+47), a
	call	_clock
	ld	(ix - 81), hl
	ld	(ix - 82), e                    ; 1-byte Folded Spill
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB12_26
; %bb.19:
	ld	a, (_render_benchmark_category)
	cp	a, 2
	jp	z, .LBB12_26
; %bb.20:
	ld	(ix - 39), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB12_22
; %bb.21:
	push	bc
	jr	.LBB12_24
	.local	.LBB12_22
.LBB12_22:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB12_25
; %bb.23:
	push	de
	.local	.LBB12_24
.LBB12_24:
	pop	iy
	.local	.LBB12_25
.LBB12_25:
	ld	(ix - 45), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 48), e
	ld	bc, (_render_benchmark_last)
	lea	hl, iy + 0
	ld	iy, (ix - 78)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 39)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 39), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 39)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 75)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 45)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 48)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 2
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+32
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB12_26
.LBB12_26:
	ld	de, 0
	ld	hl, (ix - 36)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	hl, (ix - 42)
	push	hl
	ex	de, hl
	call	nz, _delta_for_component
	ld	(ix - 63), hl
	pop	hl
	ld	hl, (ix - 30)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	de, (ix - 33)
	push	de
	ld	hl, 0
	call	nz, _delta_for_component
	ld	(ix - 39), hl
	pop	hl
	lea	hl, ix - 4
	ld	(ix - 54), hl
	lea	hl, ix - 8
	ld	(ix - 60), hl
	ld	hl, (ix - 33)
	ld	de, 260
	push	de
	pop	bc
	call	__imulu
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	ex	de, hl
	add	iy, de
	ld	c, 8
	lea	hl, iy + 0
	ld	iyl, c
	call	__ishrs
	call	__ineg
	ld	(ix - 48), hl
	ld	hl, (ix - 33)
	ld	bc, -16
	call	__imulu
	ld	(ix - 33), hl
	ld	a, (_render_grid_near_projection+8)
	ld	(ix - 83), a                    ; 1-byte Folded Spill
	ld	hl, _grid_segments
	ld	(ix - 11), hl
	ld	de, (ix - 63)
	push	de
	pop	hl
	ld	c, iyl
	call	__ishru
	ld	(ix - 4), hl
	ld	a, e
	ld	(ix - 1), a
	ld	de, (ix - 39)
	push	de
	pop	hl
	call	__ishru
	ld	bc, (ix - 54)
	ld	(ix - 8), hl
	ld	a, e
	ld	(ix - 5), a
	ld	hl, (ix - 30)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	de, (ix - 60)
	jp	nz, .LBB12_29
; %bb.27:
	ld	hl, (ix + 6)
	ld	hl, (hl)
	call	__ineg
	push	bc
	ld	(ix - 51), hl
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	bc
	pop	hl
	pop	hl
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB12_31
; %bb.28:
	push	bc
	pop	hl
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 63)
	call	__ineg
	ld	(ix - 72), hl
	ld	(ix - 45), de
	ld	(ix - 42), de
	ld	hl, (ix - 51)
	ld	(ix - 69), hl
	ld	iy, (ix + 6)
	jp	.LBB12_37
	.local	.LBB12_29
.LBB12_29:
	ld	bc, (ix - 42)
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	(ix - 45), hl
	push	bc
	pop	hl
	ld	bc, 260
	call	__imulu
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	push	hl
	pop	bc
	add	iy, bc
	ld	c, 8
	lea	hl, iy + 0
	call	__ishrs
	push	hl
	pop	bc
	ld	hl, (ix + 6)
	ld	hl, (hl)
	push	hl
	pop	iy
	add	iy, bc
	ld	bc, (ix - 45)
	add	hl, bc
	ld	(ix - 69), hl
	push	de
	ld	(ix - 51), iy
	push	iy
	call	_fixed_scale_mul
	ld	(ix - 45), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 60)
	push	hl
	ld	hl, (ix - 69)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	ld	bc, (ix - 39)
	push	bc
	pop	hl
	call	__ineg
	ld	(ix - 72), hl
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB12_32
; %bb.30:
	ld	hl, (ix - 45)
	call	__ineg
	ld	(ix - 45), hl
	lea	hl, iy + 0
	call	__ineg
	ld	(ix - 42), hl
	ld	(ix - 72), bc
	jr	.LBB12_33
	.local	.LBB12_31
.LBB12_31:
	ld	hl, (ix - 51)
	ld	(ix - 69), hl
	ld	hl, (ix - 63)
	ld	(ix - 72), hl
	ld	(ix - 42), bc
	ld	(ix - 45), bc
	ld	iy, (ix + 6)
	ld	de, (ix - 60)
	ld	bc, (ix - 39)
	jr	.LBB12_34
	.local	.LBB12_32
.LBB12_32:
	ld	(ix - 42), iy
	.local	.LBB12_33
.LBB12_33:
	ld	iy, (ix + 6)
	ld	de, (ix - 60)
	.local	.LBB12_34
.LBB12_34:
	ld	hl, (ix - 36)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jp	nz, .LBB12_37
; %bb.35:
	ld	hl, (iy + 3)
	call	__ineg
	push	de
	ld	(ix - 33), hl
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	bc
	pop	hl
	pop	hl
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB12_41
; %bb.36:
	push	bc
	pop	hl
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 39)
	call	__ineg
	ld	(ix - 39), hl
	ld	hl, (ix - 33)
	ld	(ix - 66), hl
	ld	(ix - 48), de
	ld	(ix - 57), de
	jp	.LBB12_42
	.local	.LBB12_37
.LBB12_37:
	ld	de, (iy + 3)
	ld	hl, (ix - 48)
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld	hl, (ix - 33)
	or	a, a
	sbc	hl, de
	ld	(ix - 33), hl
	ld	hl, (ix - 54)
	push	hl
	ld	(ix - 66), bc
	push	bc
	call	_fixed_scale_mul
	ld	(ix - 57), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 54)
	push	hl
	ld	hl, (ix - 33)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	bc
	pop	hl
	pop	hl
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB12_39
; %bb.38:
	ld	hl, (ix - 57)
	call	__ineg
	ld	(ix - 57), hl
	push	bc
	pop	hl
	call	__ineg
	ld	(ix - 48), hl
	ld	hl, (ix - 63)
	call	__ineg
	jr	.LBB12_40
	.local	.LBB12_39
.LBB12_39:
	ld	(ix - 48), bc
	ld	hl, (ix - 63)
	.local	.LBB12_40
.LBB12_40:
	ld	(ix - 39), hl
	jr	.LBB12_42
	.local	.LBB12_41
.LBB12_41:
	ld	hl, (ix - 33)
	ld	(ix - 66), hl
	ld	(ix - 48), bc
	ld	(ix - 57), bc
	.local	.LBB12_42
.LBB12_42:
	lea	hl, ix - 11
	ld	(ix - 86), hl
	call	_render_asm_clear_background
	ld	hl, 4
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	a, 16
	ld	de, (ix - 30)
	ld	iy, (ix - 42)
	ld	hl, (ix - 51)
	ld	bc, (ix - 45)
	.local	.LBB12_43
.LBB12_43:                              ; =>This Inner Loop Header: Depth=1
	ld	(ix - 63), a                    ; 1-byte Folded Spill
	or	a, a
	jp	z, .LBB12_63
; %bb.44:                               ;   in Loop: Header=BB12_43 Depth=1
	ld	(ix - 51), hl
	sbc.sis	hl, hl
	adc.sis	hl, de
	ld	(ix - 42), iy
	jp	nz, .LBB12_52
; %bb.45:                               ;   in Loop: Header=BB12_43 Depth=1
	push	bc
	pop	hl
	ld	de, -260
	add	hl, de
	ld	de, 3837
	or	a, a
	sbc	hl, de
	jp	nc, .LBB12_48
; %bb.46:                               ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, _render_wall_scale_profile_index
	add	hl, bc
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _render_wall_scale_profiles
	add	hl, de
	ld	de, (hl)
	ld	l, e
	ld	h, d
	ld	(ix - 45), bc
	ld.sis	bc, 240
	or	a, a
	sbc.sis	hl, bc
	ld	bc, (ix - 45)
	jp	nc, .LBB12_48
; %bb.47:                               ;   in Loop: Header=BB12_43 Depth=1
	ld	a, d
	ld	l, e
	srl	a
	rr	l
                                        ; kill: def $l killed $l def $hl
	ld	h, a
	ld	e, 120
	ld	a, l
	add	a, e
	ld	l, a
	push	hl
	call	_render_asm_draw_horizontal_grid_pair
	ld	bc, (ix - 45)
	pop	hl
	.local	.LBB12_48
.LBB12_48:                              ;   in Loop: Header=BB12_43 Depth=1
	push	bc
	pop	hl
	ld	de, (ix - 72)
	add	hl, de
	ld	(ix - 45), hl
	ld	hl, (ix - 42)
	add	hl, de
	push	hl
	pop	bc
	ld	hl, (ix - 51)
	push	hl
	pop	iy
	ld	de, 256
	add	iy, de
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB12_61
; %bb.49:                               ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, (ix - 54)
	push	hl
	ld	(ix - 42), iy
	push	iy
	call	_fixed_scale_mul
	ex	de, hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB12_51
; %bb.50:                               ;   in Loop: Header=BB12_43 Depth=1
	push	de
	pop	iy
	.local	.LBB12_51
.LBB12_51:                              ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, (ix - 42)
	lea	bc, iy + 0
	jp	.LBB12_60
	.local	.LBB12_52
.LBB12_52:                              ;   in Loop: Header=BB12_43 Depth=1
	push	iy
	push	bc
	ld	hl, (ix - 86)
	push	hl
	ld	(ix - 45), bc
	call	_render_asm_add_projected_grid_segment
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 45)
	ld	de, (ix - 72)
	add	hl, de
	ld	(ix - 89), hl
	ld	hl, (ix - 42)
	add	hl, de
	ld	(ix - 42), hl
	ld	bc, (ix - 51)
	push	bc
	pop	iy
	ld	hl, -256
	ex	de, hl
	add	iy, de
	ld	(ix - 45), iy
	ld	iy, (ix - 42)
	ld	hl, (ix - 69)
	add	hl, de
	ld	(ix - 92), hl
	dec	bc
	push	bc
	pop	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	jp	nc, .LBB12_56
; %bb.53:                               ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, (ix - 60)
	push	hl
	ld	hl, (ix - 45)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	lea	hl, iy + 0
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB12_55
; %bb.54:                               ;   in Loop: Header=BB12_43 Depth=1
	lea	de, iy + 0
	.local	.LBB12_55
.LBB12_55:                              ;   in Loop: Header=BB12_43 Depth=1
	ld	(ix - 89), de
	ld	iy, (ix - 42)
	.local	.LBB12_56
.LBB12_56:                              ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, (ix - 69)
	dec	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	jp	nc, .LBB12_59
; %bb.57:                               ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, (ix - 60)
	push	hl
	ld	hl, (ix - 92)
	push	hl
	call	_fixed_scale_mul
	ex	de, hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	call	__ineg
	push	hl
	pop	iy
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB12_59
; %bb.58:                               ;   in Loop: Header=BB12_43 Depth=1
	push	de
	pop	iy
	.local	.LBB12_59
.LBB12_59:                              ;   in Loop: Header=BB12_43 Depth=1
	ld	hl, (ix - 92)
	ld	(ix - 69), hl
	ld	hl, (ix - 45)
	ld	bc, (ix - 89)
	.local	.LBB12_60
.LBB12_60:                              ;   in Loop: Header=BB12_43 Depth=1
	ld	de, (ix - 30)
	jr	.LBB12_62
	.local	.LBB12_61
.LBB12_61:                              ;   in Loop: Header=BB12_43 Depth=1
	lea	hl, iy + 0
	ld	de, (ix - 30)
	push	bc
	pop	iy
	ld	bc, (ix - 45)
	.local	.LBB12_62
.LBB12_62:                              ;   in Loop: Header=BB12_43 Depth=1
	ld	a, (ix - 63)                    ; 1-byte Folded Reload
	dec	a
	jp	.LBB12_43
	.local	.LBB12_63
.LBB12_63:
	ld	hl, (ix - 33)
	ld	e, 16
	ld	bc, (ix - 57)
	.local	.LBB12_64
.LBB12_64:                              ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	ld	a, e
	or	a, a
	jp	z, .LBB12_84
; %bb.65:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	(ix - 42), e                    ; 1-byte Folded Spill
	ld	(ix - 33), hl
	ld	hl, (ix - 36)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jp	nz, .LBB12_73
; %bb.66:                               ;   in Loop: Header=BB12_64 Depth=1
	push	bc
	pop	hl
	ld	de, -260
	add	hl, de
	ld	de, 3837
	or	a, a
	sbc	hl, de
	jp	nc, .LBB12_69
; %bb.67:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, _render_wall_scale_profile_index
	add	hl, bc
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _render_wall_scale_profiles
	add	hl, de
	ld	de, (hl)
	ld	l, e
	ld	h, d
	ld	(ix - 57), bc
	ld.sis	bc, 240
	or	a, a
	sbc.sis	hl, bc
	ld	bc, (ix - 57)
	jp	nc, .LBB12_69
; %bb.68:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	a, d
	ld	l, e
	srl	a
	rr	l
                                        ; kill: def $l killed $l def $hl
	ld	h, a
	ld	e, 120
	ld	a, l
	add	a, e
	ld	l, a
	push	hl
	call	_render_asm_draw_horizontal_grid_pair
	ld	bc, (ix - 57)
	pop	hl
	.local	.LBB12_69
.LBB12_69:                              ;   in Loop: Header=BB12_64 Depth=1
	push	bc
	pop	hl
	ld	de, (ix - 39)
	add	hl, de
	push	hl
	pop	bc
	ld	hl, (ix - 48)
	add	hl, de
	ld	(ix - 48), hl
	ld	hl, (ix - 66)
	push	hl
	pop	iy
	ld	de, 256
	add	iy, de
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB12_81
; %bb.70:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, (ix - 60)
	push	hl
	ld	(ix - 45), iy
	push	iy
	call	_fixed_scale_mul
	ex	de, hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	call	__ineg
	ld	(ix - 48), hl
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB12_72
; %bb.71:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	(ix - 48), de
	.local	.LBB12_72
.LBB12_72:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, (ix - 45)
	ld	(ix - 66), hl
	ld	bc, (ix - 48)
	jp	.LBB12_82
	.local	.LBB12_73
.LBB12_73:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, (ix - 48)
	push	hl
	push	bc
	ld	hl, (ix - 86)
	push	hl
	ld	(ix - 57), bc
	call	_render_asm_add_projected_grid_segment
	ld	de, (ix - 39)
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 57)
	add	hl, de
	ld	(ix - 51), hl
	ld	(ix - 39), de
	ld	hl, (ix - 48)
	add	hl, de
	ld	(ix - 48), hl
	ld	bc, (ix - 66)
	push	bc
	pop	iy
	ld	de, 256
	add	iy, de
	ld	(ix - 45), iy
	ld	iy, (ix - 33)
	lea	hl, iy + 0
	add	hl, de
	ld	(ix - 57), hl
	push	bc
	pop	hl
	ld	bc, -256
	or	a, a
	sbc	hl, bc
	jp	c, .LBB12_77
; %bb.74:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, (ix - 54)
	push	hl
	ld	hl, (ix - 45)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	lea	hl, iy + 0
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB12_76
; %bb.75:                               ;   in Loop: Header=BB12_64 Depth=1
	lea	de, iy + 0
	.local	.LBB12_76
.LBB12_76:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	(ix - 51), de
	ld	iy, (ix - 33)
	.local	.LBB12_77
.LBB12_77:                              ;   in Loop: Header=BB12_64 Depth=1
	lea	hl, iy + 0
	ld	de, -256
	or	a, a
	sbc	hl, de
	ld	hl, (ix - 54)
	jp	c, .LBB12_80
; %bb.78:                               ;   in Loop: Header=BB12_64 Depth=1
	push	hl
	ld	hl, (ix - 57)
	push	hl
	call	_fixed_scale_mul
	ex	de, hl
	pop	hl
	pop	hl
	push	de
	pop	hl
	call	__ineg
	ld	(ix - 48), hl
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB12_80
; %bb.79:                               ;   in Loop: Header=BB12_64 Depth=1
	ld	(ix - 48), de
	.local	.LBB12_80
.LBB12_80:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, (ix - 57)
	ld	de, (ix - 45)
	ld	(ix - 66), de
	ld	bc, (ix - 51)
	jr	.LBB12_83
	.local	.LBB12_81
.LBB12_81:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	(ix - 66), iy
	.local	.LBB12_82
.LBB12_82:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	hl, (ix - 33)
	.local	.LBB12_83
.LBB12_83:                              ;   in Loop: Header=BB12_64 Depth=1
	ld	e, (ix - 42)                    ; 1-byte Folded Reload
	dec	e
	jp	.LBB12_64
	.local	.LBB12_84
.LBB12_84:
	ld	hl, 17
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	l, (ix - 83)
	ld	a, -16
	sub	a, l
	ld	l, a
	ld	de, 0
	ld	e, l
	ld	(ix - 30), de
	ld	hl, _grid_segments
	push	hl
	pop	iy
	.local	.LBB12_85
.LBB12_85:                              ; =>This Inner Loop Header: Depth=1
	ld	de, (ix - 11)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB12_87
; %bb.86:                               ;   in Loop: Header=BB12_85 Depth=1
	ld	bc, (iy)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	bc, (iy + 2)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, (ix - 30)
	push	bc
	push	hl
	ld	hl, 113
	push	hl
	push	de
	ld	(ix - 33), iy
	call	_gfx_Line
	ld	iy, (ix - 33)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	lea	iy, iy + 4
	jr	.LBB12_85
	.local	.LBB12_87
.LBB12_87:
	call	_render_asm_repair_horizon
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB12_95
; %bb.88:
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	jp	z, .LBB12_95
; %bb.89:
	ld	(ix - 30), l                    ; 1-byte Folded Spill
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
	jr	nc, .LBB12_91
; %bb.90:
	push	bc
	jr	.LBB12_93
	.local	.LBB12_91
.LBB12_91:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB12_94
; %bb.92:
	push	de
	.local	.LBB12_93
.LBB12_93:
	pop	iy
	.local	.LBB12_94
.LBB12_94:
	ld	(ix - 33), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 36), e
	ld	bc, (_render_benchmark_last)
	lea	hl, iy + 0
	ld	iy, (ix - 78)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 30)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 30), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 30)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 75)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 33)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 36)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	xor	a, a
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+28
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB12_95
.LBB12_95:
	call	_clock
	ld	(ix - 45), hl
	ld	(ix - 48), e                    ; 1-byte Folded Spill
	ld	bc, (ix - 81)
	ld	a, (ix - 82)                    ; 1-byte Folded Reload
	call	__lsub
	ld	a, e
	ld	(_render_profile+4), hl
	ld	(_render_profile+7), a
	ld	hl, (ix - 19)
	ld	(ix - 33), hl
	ld	hl, (ix - 27)
	ld	(ix - 30), hl
	ld	hl, (ix - 16)
	ld	(ix - 51), hl
	ld	a, (ix - 12)
	ld	(ix - 54), a
	ld	hl, (ix - 24)
	ld	(ix - 57), hl
	ld	a, (ix - 20)
	ld	(ix - 60), a
	ld	a, (ix - 13)
	ld	(ix - 36), a
	ld	a, (ix - 21)
	ld	(ix - 39), a
	ld	de, 320
	ld	bc, (ix + 6)
	ld	iy, 0
	.local	.LBB12_96
.LBB12_96:                              ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB12_102
; %bb.97:                               ;   in Loop: Header=BB12_96 Depth=1
	ld	hl, (ix - 30)
	push	hl
	ld	hl, (ix - 33)
	push	hl
	ld	(ix - 42), iy
	push	iy
	push	bc
	call	_render_column
	ld	iy, (ix - 33)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, (ix - 51)
	add	iy, de
	ld	l, (ix - 54)
	ld	c, (ix - 36)                    ; 1-byte Folded Reload
	ld	a, c
	add	a, l
	ld	c, a
	cp	a, 80
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	bit	0, l
	jr	z, .LBB12_99
; %bb.98:                               ;   in Loop: Header=BB12_96 Depth=1
	ld	e, -80
	ld	a, c
	add	a, e
	ld	c, a
	.local	.LBB12_99
.LBB12_99:                              ;   in Loop: Header=BB12_96 Depth=1
	ld	(ix - 36), c
	ld	a, l
	and	a, 1
	ld	de, 0
	ld	e, a
	add	iy, de
	ld	(ix - 33), iy
	ld	hl, (ix - 30)
	ld	de, (ix - 57)
	add	hl, de
	ld	(ix - 30), hl
	ld	l, (ix - 60)
	ld	h, (ix - 39)                    ; 1-byte Folded Reload
	ld	a, h
	add	a, l
	ld	h, a
	cp	a, 80
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	bit	0, l
	ld	bc, (ix + 6)
	ld	iy, (ix - 42)
	jr	z, .LBB12_101
; %bb.100:                              ;   in Loop: Header=BB12_96 Depth=1
	ld	e, -80
	ld	a, h
	add	a, e
	ld	h, a
	.local	.LBB12_101
.LBB12_101:                             ;   in Loop: Header=BB12_96 Depth=1
	ld	(ix - 39), h
	ld	a, l
	and	a, 1
	ld	de, 0
	ld	e, a
	ld	hl, (ix - 30)
	add	hl, de
	ld	(ix - 30), hl
	ld	de, 4
	add	iy, de
	ld	de, 320
	jp	.LBB12_96
	.local	.LBB12_102
.LBB12_102:
	call	_clock
	ld	bc, (ix - 45)
	ld	a, (ix - 48)                    ; 1-byte Folded Reload
	call	__lsub
	ld	a, e
	ld	(_render_profile+8), hl
	ld	(_render_profile+11), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_game_render, .Lfunc_end12-_game_render
                                        ; -- End function
	.section	.text._ray_stepper_init,"ax",@progbits
	.type	_ray_stepper_init,@function     ; -- Begin function ray_stepper_init
_ray_stepper_init:                      ; @ray_stepper_init
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	iy, (ix + 9)
	ld	de, (ix + 12)
	ld	bc, 0
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB13_3
; %bb.1:
	ld	bc, 160
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	c, .LBB13_5
; %bb.2:
	ld	l, 96
	ld	bc, 2
	jp	.LBB13_9
	.local	.LBB13_3
.LBB13_3:
	ld	bc, -160
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB13_7
; %bb.4:
	ld	l, -16
	ld	bc, -3
	jp	.LBB13_9
	.local	.LBB13_5
.LBB13_5:
	ld	bc, 80
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	c, a
	and	a, 1
	ld	b, a
	bit	0, c
	jr	nz, .LBB13_11
; %bb.6:
	push	de
	pop	hl
	ld	c, e
	jr	.LBB13_12
	.local	.LBB13_7
.LBB13_7:
	ld	bc, -80
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB13_16
; %bb.8:
	ld	l, -96
	ld	bc, -2
	.local	.LBB13_9
.LBB13_9:
	ld	(ix - 3), bc
	.local	.LBB13_10
.LBB13_10:
	ld	a, e
	add	a, l
	ld	c, a
	jr	.LBB13_13
	.local	.LBB13_11
.LBB13_11:
	ld	c, -80
	push	de
	pop	hl
	ld	a, e
	add	a, c
	ld	c, a
	.local	.LBB13_12
.LBB13_12:
	ld	iy, 0
	ld	iyl, b
	ld	(ix - 3), iy
	ld	iy, (ix + 9)
	ex	de, hl
	.local	.LBB13_13
.LBB13_13:
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	ld	hl, (ix - 3)
	push	hl
	pop	de
	add	iy, de
	lea	de, iy + 0
	ld	iy, (ix + 6)
	ld	(iy), de
	ld	(iy + 6), c
	add	hl, hl
	ld	(iy + 3), hl
	ld	a, c
	cp	a, 40
	jr	c, .LBB13_15
; %bb.14:
	ex	de, hl
	ld	l, -40
	inc	de
	ld	(iy + 3), de
	ld	a, c
	add	a, l
	ld	c, a
	.local	.LBB13_15
.LBB13_15:
	sla	c
	ld	(iy + 7), c
	pop	hl
	pop	ix
	ret
	.local	.LBB13_16
.LBB13_16:
	scf
	sbc	hl, hl
	ld	(ix - 3), hl
	ld	l, 80
	jr	.LBB13_10
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_ray_stepper_init, .Lfunc_end13-_ray_stepper_init
                                        ; -- End function
	.section	.text._delta_for_component,"ax",@progbits
	.type	_delta_for_component,@function  ; -- Begin function delta_for_component
_delta_for_component:                   ; @delta_for_component
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	lea	hl, iy + 0
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	call	__ixor
	ex	de, hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB14_2
; %bb.1:
	ld	hl, 4194303
	jr	.LBB14_7
	.local	.LBB14_2
.LBB14_2:
	ld	bc, 1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB14_4
; %bb.3:
	ld	hl, 65536
	jr	.LBB14_7
	.local	.LBB14_4
.LBB14_4:
	ld	iy, _render_reciprocal_delta
	ld	bc, 425
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ex	de, hl
	jr	c, .LBB14_6
; %bb.5:
	ld	hl, 425
	.local	.LBB14_6
.LBB14_6:
	add	hl, hl
	ex	de, hl
	add	iy, de
	ld	de, (iy)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	.local	.LBB14_7
.LBB14_7:
	pop	ix
	ret
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_delta_for_component, .Lfunc_end14-_delta_for_component
                                        ; -- End function
	.section	.text._fixed_scale_mul,"ax",@progbits
	.type	_fixed_scale_mul,@function      ; -- Begin function fixed_scale_mul
_fixed_scale_mul:                       ; @fixed_scale_mul
; %bb.0:
	call	__frameset0
	ld	bc, (ix + 6)
	ld	iy, (ix + 9)
	ld	hl, (iy)
	call	__imulu
	ex	de, hl
	ld	a, (iy + 3)
	or	a, a
	sbc	hl, hl
	ld	l, a
	call	__imulu
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	ld	c, 16
	call	__ishru
	push	hl
	pop	bc
	add	iy, bc
	ld	c, 8
	lea	hl, iy + 0
	call	__ishrs
	add	hl, de
	pop	ix
	ret
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_fixed_scale_mul, .Lfunc_end15-_fixed_scale_mul
                                        ; -- End function
	.section	.text._render_column,"ax",@progbits
	.type	_render_column,@function        ; -- Begin function render_column
_render_column:                         ; @render_column
; %bb.0:
	ld	hl, -58
	call	__frameset
	ld	h, 0
	ld	iy, _render_benchmark+58
	ld	de, 4
	ld	(ix - 40), de
	ld	e, 13
	ld	(ix - 52), de
	ld	e, -16
	lea	bc, iy + 3
	ld	(ix - 37), bc
	ld	c, h
	ld	(ix - 16), de
	ld	(ix - 31), e                    ; 1-byte Folded Spill
	ld	(ix - 34), h                    ; 1-byte Folded Spill
	ld	e, h
	ld	(ix - 49), h                    ; 1-byte Folded Spill
	ld	(ix - 30), l
	ld	(ix - 29), h
	ld	(ix - 48), h                    ; 1-byte Folded Spill
	ld	iy, 0
	ld	(ix - 25), iy
	.local	.LBB16_1
.LBB16_1:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 12), bc
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	a, iyl
	ld	(ix - 9), a
	ld	iy, _render_benchmark_last
	lea	hl, iy + 3
	ld	(ix - 22), hl
	ld	iy, _render_benchmark+42
	lea	hl, iy + 3
	ld	(ix - 19), hl
	ld	(ix - 13), e
	jp	z, .LBB16_9
; %bb.2:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 3
	jp	z, .LBB16_9
; %bb.3:                                ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 28), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB16_5
; %bb.4:                                ;   in Loop: Header=BB16_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB16_8
	.local	.LBB16_5
.LBB16_5:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_7
; %bb.6:                                ;   in Loop: Header=BB16_1 Depth=1
	push	de
	pop	iy
	.local	.LBB16_7
.LBB16_7:                               ;   in Loop: Header=BB16_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB16_8
.LBB16_8:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 43), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 28)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 28), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 28)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 43)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 3
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+34
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB16_9
.LBB16_9:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, e
	or	a, a
	jr	nz, .LBB16_11
; %bb.10:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	hl, (iy)
	ld	de, (iy + 3)
	ld	bc, _render_scratch
	push	bc
	ld	bc, (ix + 15)
	push	bc
	ld	bc, (ix + 12)
	push	bc
	push	de
	push	hl
	call	_render_asm_cast_wall_begin
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	jr	.LBB16_12
	.local	.LBB16_11
.LBB16_11:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_cast_wall_continue
	.local	.LBB16_12
.LBB16_12:                              ;   in Loop: Header=BB16_1 Depth=1
	pop	hl
	ld	a, (_render_benchmark_active)
	ld	b, a
	bit	0, b
	ld	hl, _render_profile+12
	jp	z, .LBB16_35
; %bb.13:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	ld	(ix - 28), b                    ; 1-byte Folded Spill
	jp	z, .LBB16_20
; %bb.14:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 43), l                    ; 1-byte Folded Spill
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
	jr	nc, .LBB16_16
; %bb.15:                               ;   in Loop: Header=BB16_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB16_19
	.local	.LBB16_16
.LBB16_16:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_18
; %bb.17:                               ;   in Loop: Header=BB16_1 Depth=1
	push	de
	pop	iy
	.local	.LBB16_18
.LBB16_18:                              ;   in Loop: Header=BB16_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB16_19
.LBB16_19:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 46), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	ld	iy, (ix - 22)
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
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 46)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	a, h
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+28
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB16_20
.LBB16_20:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (_render_ray_state+1)
	ld	e, a
	ld	a, (_render_ray_state+4)
	ld	l, a
	ld	a, (_render_scratch+3)
	ld	c, a
	cp	a, e
	jr	c, .LBB16_22
; %bb.21:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, c
	sub	a, e
	jr	.LBB16_23
	.local	.LBB16_22
.LBB16_22:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, e
	sub	a, c
	.local	.LBB16_23
.LBB16_23:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	e, a
	ld	(ix - 43), e
	ld	a, (_render_scratch+4)
	ld	h, a
	cp	a, l
	jr	c, .LBB16_25
; %bb.24:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, h
	sub	a, l
	jr	.LBB16_26
	.local	.LBB16_25
.LBB16_25:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, l
	sub	a, h
	.local	.LBB16_26
.LBB16_26:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	l, a
	ld	(ix - 46), l
	ld	de, 0
	ld	e, h
	ld	hl, _map_row_offsets
	add	hl, de
	ld	a, (hl)
	add	a, c
	ld	d, a
	ld	iy, _render_benchmark+46
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, (ix - 43)                    ; 1-byte Folded Reload
	ld	l, (ix - 46)                    ; 1-byte Folded Reload
	add	hl, bc
	push	hl
	pop	bc
	ld	hl, (_render_benchmark+58)
	ld	iy, (ix - 37)
	ld	e, (iy)
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+58), hl
	ld	(_render_benchmark+61), a
	ld	bc, 0
	ld	c, d
	ld	hl, _render_builtin_portal_by_tile
	add	hl, bc
	ld	a, (_render_scratch+14)
	ld	e, a
	ld	a, (_render_scratch+15)
	ld	c, a
	ld	a, (hl)
	or	a, a
	jr	nz, .LBB16_29
; %bb.27:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, d
	cp	a, e
	jr	z, .LBB16_29
; %bb.28:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, d
	cp	a, c
	jr	nz, .LBB16_30
	.local	.LBB16_29
.LBB16_29:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, _render_benchmark+48
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB16_30
.LBB16_30:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, _render_profile+12
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
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
	jr	nc, .LBB16_32
; %bb.31:                               ;   in Loop: Header=BB16_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB16_34
	.local	.LBB16_32
.LBB16_32:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (-917472)
	ld	(ix - 43), hl
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	nc, .LBB16_34
; %bb.33:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 43)
	.local	.LBB16_34
.LBB16_34:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 43), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	d, e
	ld	hl, (_render_benchmark)
	ld	iy, _render_benchmark
	lea	iy, iy + 3
	ld	e, (iy)
	ld	a, d
	call	__ladd
	ld	a, e
	ld	(_render_benchmark), hl
	ld	(_render_benchmark+3), a
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	ld	a, d
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 43)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 4
	ld	(_render_benchmark_category), a
	ld	hl, _render_benchmark+36
	ld	b, (ix - 28)                    ; 1-byte Folded Reload
	.local	.LBB16_35
.LBB16_35:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (hl)
	inc.sis	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	iy, (_render_scratch)
	ld	de, (ix - 25)
	add	iy, de
	ld	(_render_scratch), iy
	ld	a, (_render_ray_state+52)
	ld	c, a
	ld	a, (_render_ray_state+53)
	ld	(ix - 47), a                    ; 1-byte Folded Spill
	ld	a, (_render_ray_state+54)
	ld	e, a
	bit	0, b
	ld	(ix - 43), iy
	jr	z, .LBB16_40
; %bb.36:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, e
	or	a, a
	ld	a, -1
	jr	nz, .LBB16_38
; %bb.37:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, 0
	.local	.LBB16_38
.LBB16_38:                              ;   in Loop: Header=BB16_1 Depth=1
	bit	0, a
	jr	z, .LBB16_40
; %bb.39:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, _render_benchmark+50
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 43)
	.local	.LBB16_40
.LBB16_40:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 28), e                    ; 1-byte Folded Spill
	ld	a, c
	ld	(_render_scratch+10), a
	lea	hl, iy + 0
	ld	de, 8191
	or	a, a
	sbc	hl, de
	lea	de, iy + 0
	jr	c, .LBB16_42
; %bb.41:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	de, 8191
	.local	.LBB16_42
.LBB16_42:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, _render_wall_scale_profile_index
	add	hl, de
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _render_wall_scale_profiles
	add	hl, de
	ld	(ix - 46), c                    ; 1-byte Folded Spill
	ld	a, c
	or	a, a
	pea	ix - 2
	pea	ix - 1
	ld	(ix - 25), hl
	push	hl
	ld	hl, _render_scratch
	push	hl
	call	nz, _render_asm_portal_opening
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (ix - 28)                    ; 1-byte Folded Reload
	or	a, a
	ld	iy, (ix - 12)
	ld	bc, (ix - 16)
	jp	z, .LBB16_116
; %bb.43:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, iyl
	cp	a, c
	jp	nc, .LBB16_90
; %bb.44:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	e, (ix - 1)
	ld	c, (ix - 2)
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB16_82
; %bb.45:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, _render_benchmark+56
	push	hl
	pop	iy
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, c
	sub	a, e
	ld	l, a
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	ld	(ix - 28), e                    ; 1-byte Folded Spill
	add	a, e
	ld	l, a
	inc	l
	ld	iy, (ix - 25)
	ld	e, (iy + 2)
	ld	a, l
	ld	(ix - 46), c                    ; 1-byte Folded Spill
	cp	a, c
	ld	bc, (ix - 16)
	jp	nc, .LBB16_54
; %bb.46:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 12)
	ld	a, l
	cp	a, e
	jr	c, .LBB16_48
; %bb.47:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	e, l
	.local	.LBB16_48
.LBB16_48:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (ix - 28)                    ; 1-byte Folded Reload
	cp	a, c
	ld	l, a
	jr	c, .LBB16_50
; %bb.49:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	l, c
	.local	.LBB16_50
.LBB16_50:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	c, (ix - 30)
	ld	b, (ix - 29)
	ld	h, b
	ld	d, b
	ld	a, e
	cp	a, l
                                        ; kill: def $a killed $a
	sbc	a, a
	or	a, a
	sbc.sis	hl, de
	ld	(ix - 5), b
	ld	bc, (ix - 7)
	ld	b, h
	ld	c, l
	bit	0, a
	jr	nz, .LBB16_52
; %bb.51:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	bc, 0
	.local	.LBB16_52
.LBB16_52:                              ;   in Loop: Header=BB16_1 Depth=1
	bit	0, a
	jp	nz, .LBB16_62
; %bb.53:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	d, h
	jp	.LBB16_63
	.local	.LBB16_54
.LBB16_54:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 12)
	ld	a, l
	cp	a, e
	jr	c, .LBB16_56
; %bb.55:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	e, l
	.local	.LBB16_56
.LBB16_56:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 25)
	ld	l, (iy + 3)
	ld	a, l
	cp	a, c
	jr	c, .LBB16_58
; %bb.57:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	l, c
	.local	.LBB16_58
.LBB16_58:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	c, (ix - 30)
	ld	b, (ix - 29)
	ld	c, l
	ld	d, b
	ld	a, e
	cp	a, l
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	ex.sis	de, hl
	ld	(ix - 30), c
	ld	(ix - 29), b
	ld	(ix - 6), b
	ld	hl, (ix - 8)
	ld	h, d
	ld	l, e
	bit	0, a
	jr	nz, .LBB16_60
; %bb.59:                               ;   in Loop: Header=BB16_1 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB16_60
.LBB16_60:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 12)
	bit	0, a
	jp	nz, .LBB16_71
; %bb.61:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	e, d
	jp	.LBB16_72
	.local	.LBB16_62
.LBB16_62:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	d, (ix - 9)                     ; 1-byte Folded Reload
	.local	.LBB16_63
.LBB16_63:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (_render_benchmark+62)
	ld	a, (_render_benchmark+65)
	ld	e, a
	ld	a, d
	call	__ladd
	ld	(ix - 55), hl
	ld	iy, (ix - 25)
	ld	d, (iy + 3)
	ld	iy, (ix - 12)
	ld	a, iyl
	ld	l, (ix - 46)                    ; 1-byte Folded Reload
	cp	a, l
	ld	c, l
	jr	c, .LBB16_65
; %bb.64:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	c, iyl
	.local	.LBB16_65
.LBB16_65:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, d
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB16_67
; %bb.66:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 16)
	ld	d, l
	.local	.LBB16_67
.LBB16_67:                              ;   in Loop: Header=BB16_1 Depth=1
	push	hl
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ex	(sp), hl
	pop	iy
	ex	de, hl
	ld	d, iyh
	ex	de, hl
	ld	l, d
	ld	b, iyh
	ld	a, c
	cp	a, d
                                        ; kill: def $a killed $a
	sbc	a, a
	or	a, a
	sbc.sis	hl, bc
	push	af
	ld	a, iyh
	ld	(ix - 4), a
	pop	af
	ld	bc, (ix - 6)
	ld	b, h
	ld	c, l
	bit	0, a
	jr	nz, .LBB16_69
; %bb.68:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	bc, 0
	.local	.LBB16_69
.LBB16_69:                              ;   in Loop: Header=BB16_1 Depth=1
	bit	0, a
	ld	iy, (ix - 12)
	jr	nz, .LBB16_73
; %bb.70:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	a, h
	jr	.LBB16_74
	.local	.LBB16_71
.LBB16_71:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	.local	.LBB16_72
.LBB16_72:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	bc, (_render_benchmark+62)
	ld	a, (_render_benchmark+65)
	jr	.LBB16_75
	.local	.LBB16_73
.LBB16_73:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	.local	.LBB16_74
.LBB16_74:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	hl, (ix - 55)
	.local	.LBB16_75
.LBB16_75:                              ;   in Loop: Header=BB16_1 Depth=1
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+62), hl
	ld	(_render_benchmark+65), a
	ld	a, (_render_benchmark_category)
	cp	a, 6
	ld	e, (ix - 28)                    ; 1-byte Folded Reload
	ld	c, (ix - 46)                    ; 1-byte Folded Reload
	jp	z, .LBB16_82
; %bb.76:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 55), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB16_78
; %bb.77:                               ;   in Loop: Header=BB16_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB16_81
	.local	.LBB16_78
.LBB16_78:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_80
; %bb.79:                               ;   in Loop: Header=BB16_1 Depth=1
	push	de
	pop	iy
	.local	.LBB16_80
.LBB16_80:                              ;   in Loop: Header=BB16_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB16_81
.LBB16_81:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 58), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 55)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 55), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 55)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 58)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 6
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+40
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 12)
	ld	e, (ix - 28)                    ; 1-byte Folded Reload
	ld	c, (ix - 46)                    ; 1-byte Folded Reload
	.local	.LBB16_82
.LBB16_82:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	l, c
	push	hl
	ld	l, e
	push	hl
	ld	hl, (ix - 16)
	push	hl
	push	iy
	ld	hl, (ix + 9)
	push	hl
	ld	hl, (ix - 25)
	push	hl
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_draw_portal_mask
	ld	iy, (ix - 12)
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB16_90
; %bb.83:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 4
	jp	z, .LBB16_90
; %bb.84:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 25), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB16_86
; %bb.85:                               ;   in Loop: Header=BB16_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB16_89
	.local	.LBB16_86
.LBB16_86:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_88
; %bb.87:                               ;   in Loop: Header=BB16_1 Depth=1
	push	de
	pop	iy
	.local	.LBB16_88
.LBB16_88:                              ;   in Loop: Header=BB16_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB16_89
.LBB16_89:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 28), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 25)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 25), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 25)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 28)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 4
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+36
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 12)
	.local	.LBB16_90
.LBB16_90:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	c, (ix - 1)
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	cp	a, c
	ld	d, c
	jr	c, .LBB16_92
; %bb.91:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	d, a
	.local	.LBB16_92
.LBB16_92:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	l, (ix - 2)
	ld	a, l
	ld	e, (ix - 31)                    ; 1-byte Folded Reload
	cp	a, e
	ld	a, e
	ld	b, l
	jr	c, .LBB16_94
; %bb.93:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	b, a
	.local	.LBB16_94
.LBB16_94:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, d
	cp	a, b
	jp	nc, .LBB16_129
; %bb.95:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	a, l
	sub	a, c
	ld	e, a
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	h, a
	inc	h
	inc	h
	ld	a, h
	add	a, c
	ld	e, a
	cp	a, l
	jr	nc, .LBB16_103
; %bb.96:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 9), b                     ; 1-byte Folded Spill
	ld	a, iyl
	cp	a, e
	ld	bc, (ix - 16)
	jr	c, .LBB16_98
; %bb.97:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	e, iyl
	.local	.LBB16_98
.LBB16_98:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, l
	sub	a, h
	ld	h, a
	cp	a, c
	ld	l, (ix - 13)                    ; 1-byte Folded Reload
	jr	c, .LBB16_100
; %bb.99:                               ;   in Loop: Header=BB16_1 Depth=1
	ld	h, c
	.local	.LBB16_100
.LBB16_100:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	a, h
	cp	a, e
	ex	de, hl
	ld	iyl, d
	ex	de, hl
	jr	c, .LBB16_102
; %bb.101:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iyl, e
	.local	.LBB16_102
.LBB16_102:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	b, (ix - 9)                     ; 1-byte Folded Reload
	jp	.LBB16_104
	.local	.LBB16_103
.LBB16_103:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, (ix - 16)
	ex	de, hl
	ld	d, iyl
	ex	de, hl
                                        ; kill: def $iyl killed $iyl killed $uiy def $uiy
	ld	l, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB16_104
.LBB16_104:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	a, l
	cp	a, 5
	jp	z, .LBB16_129
; %bb.105:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, b
	sub	a, d
	ld	l, a
	cp	a, 3
	jp	c, .LBB16_129
; %bb.106:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 16), h                    ; 1-byte Folded Spill
	ld	(ix - 25), d                    ; 1-byte Folded Spill
	ld	a, (ix - 47)                    ; 1-byte Folded Reload
	cp	a, 8
	ld	c, (ix - 48)                    ; 1-byte Folded Reload
	jr	c, .LBB16_108
; %bb.107:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	c, (ix - 49)                    ; 1-byte Folded Reload
	.local	.LBB16_108
.LBB16_108:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	l, 7
	ld	a, (ix - 47)
	and	a, l
	ld	l, a
	ld	de, 0
	ld	e, l
	ld	hl, _portal_visit_bits
	add	hl, de
	ld	e, (hl)
	ld	a, e
	and	a, c
	ld	l, a
	or	a, a
	jp	nz, .LBB16_129
; %bb.109:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	a, (ix - 47)                    ; 1-byte Folded Reload
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	bit	0, a
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	l, h
	jr	nz, .LBB16_111
; %bb.110:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	l, e
	.local	.LBB16_111
.LBB16_111:                             ;   in Loop: Header=BB16_1 Depth=1
	bit	0, a
	jr	nz, .LBB16_113
; %bb.112:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	e, d
	.local	.LBB16_113
.LBB16_113:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	(ix - 9), b                     ; 1-byte Folded Spill
	ld	(ix - 12), iy
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB16_115
; %bb.114:                              ;   in Loop: Header=BB16_1 Depth=1
	ld	iy, _render_benchmark+52
	ld	bc, (iy)
	inc.sis	bc
	ld	(iy), c
	ld	(iy + 1), b
	.local	.LBB16_115
.LBB16_115:                             ;   in Loop: Header=BB16_1 Depth=1
	ld	c, (ix - 49)
	ld	a, l
	or	a, c
	ld	c, a
	ld	(ix - 49), c
	ld	l, (ix - 48)
	ld	a, e
	or	a, l
	ld	l, a
	ld	(ix - 48), l
	call	_render_asm_transform_ray_state
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	inc	e
	ld	l, (ix - 16)                    ; 1-byte Folded Reload
	ld	(ix - 16), hl
	ld	a, (ix - 9)
	ld	(ix - 31), a                    ; 1-byte Folded Spill
	ld	a, (ix - 25)
	ld	(ix - 34), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 43)
	ld	(ix - 25), hl
	ld	bc, (ix - 12)
	ld	iy, 0
	jp	.LBB16_1
	.local	.LBB16_116
.LBB16_116:
	ld	a, (_render_benchmark_active)
	ld	l, a
	ld	a, iyl
	cp	a, c
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	jp	nc, .LBB16_130
; %bb.117:
	bit	0, l
	jp	z, .LBB16_131
; %bb.118:
	ld	hl, _render_benchmark+54
	push	hl
	pop	iy
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 25)
	ld	e, (iy + 2)
	ld	a, (iy + 3)
	ld	iyl, a
	ld	hl, (ix - 12)
	ld	a, l
	ld	(ix - 9), de
	cp	a, e
	jp	c, .LBB16_120
; %bb.119:
                                        ; kill: def $l killed $l killed $uhl def $uhl
	ld	(ix - 9), hl
	.local	.LBB16_120
.LBB16_120:
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	a, l
	cp	a, c
	jr	c, .LBB16_122
; %bb.121:
	ld	l, c
	.local	.LBB16_122
.LBB16_122:
	ld	b, 0
	ld	c, l
	ld	de, (ix - 9)
	ld	d, b
	ld	a, e
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	cp	a, l
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, c
	ld	h, b
	ld	(ix - 9), de
	or	a, a
	sbc.sis	hl, de
	ex.sis	de, hl
	ld	(ix - 3), b
	ld	hl, (ix - 5)
	ld	h, d
	ld	l, e
	ld	de, 0
	bit	0, a
	jr	nz, .LBB16_124
; %bb.123:
	or	a, a
	sbc	hl, hl
	.local	.LBB16_124
.LBB16_124:
	bit	0, a
	ld	(ix - 31), e
	jr	nz, .LBB16_126
; %bb.125:
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	e, d
	.local	.LBB16_126
.LBB16_126:
	ld	c, iyl
	ld	(ix - 28), bc
	ld	bc, (_render_benchmark+62)
	ld	iy, _render_benchmark+62
	lea	iy, iy + 3
	ld	a, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+62), hl
	ld	(_render_benchmark+65), a
	ld	a, (_render_benchmark_category)
	cp	a, 5
	jp	z, .LBB16_140
; %bb.127:
	ld	(ix - 34), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB16_136
; %bb.128:
	push	bc
	pop	hl
	jr	.LBB16_139
	.local	.LBB16_129
.LBB16_129:                             ; %.loopexit.loopexit
	ld	a, (_render_benchmark_active)
	ld	c, a
	jp	.LBB16_142
	.local	.LBB16_130
.LBB16_130:
	ld	c, l
	jp	.LBB16_143
	.local	.LBB16_131
.LBB16_131:
	ld	iy, (ix - 25)
	ld	h, (iy + 2)
	ld	l, (iy + 3)
	ld	de, (ix - 12)
	ld	a, e
	cp	a, h
	jr	c, .LBB16_133
; %bb.132:
	ld	h, e
	.local	.LBB16_133
.LBB16_133:
	ld	a, l
	cp	a, c
	jr	c, .LBB16_135
; %bb.134:
	ld	l, c
	.local	.LBB16_135
.LBB16_135:
	ld	e, h
	ld	c, l
	ld	hl, (ix - 25)
	jp	.LBB16_141
	.local	.LBB16_136
.LBB16_136:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_138
; %bb.137:
	push	de
	pop	iy
	.local	.LBB16_138
.LBB16_138:
	lea	hl, iy + 0
	.local	.LBB16_139
.LBB16_139:
	ld	(ix - 37), hl
	ld	bc, (_render_benchmark_last)
	ld	e, (ix - 31)                    ; 1-byte Folded Reload
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 34)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 34), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 34)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 37)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 31)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 5
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+38
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB16_140
.LBB16_140:
	ld	hl, (ix - 25)
	ld	de, (ix - 9)
	ld	bc, (ix - 28)
	.local	.LBB16_141
.LBB16_141:
	push	hl
	push	bc
	push	de
	ld	hl, (ix + 9)
	push	hl
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_draw_wall_segment_registers
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_benchmark_active)
	ld	c, a
	ld	a, (ix - 46)                    ; 1-byte Folded Reload
	or	a, a
	jp	nz, .LBB16_156
	.local	.LBB16_142
.LBB16_142:                             ; %.loopexit
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB16_143
.LBB16_143:                             ; %.loopexit
	ld	a, (_render_benchmark_category)
	ld	l, a
	bit	0, c
	jp	z, .LBB16_153
; %bb.144:                              ; %.loopexit
	ld	a, l
	or	a, a
	jp	z, .LBB16_153
; %bb.145:
	ld	de, 0
	ld	e, l
	ld	(ix - 40), de
	.local	.LBB16_146
.LBB16_146:
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
	jr	nc, .LBB16_148
; %bb.147:
	push	bc
	jr	.LBB16_150
	.local	.LBB16_148
.LBB16_148:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_151
; %bb.149:
	push	de
	.local	.LBB16_150
.LBB16_150:
	pop	iy
	.local	.LBB16_151
.LBB16_151:
	ld	(ix - 9), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 12), e
	ld	bc, (_render_benchmark_last)
	lea	hl, iy + 0
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 40)
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 16), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 16)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 9)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 12)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	a, h
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+28
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB16_152
.LBB16_152:
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB16_153
.LBB16_153:
	ld	a, (_render_profile+14)
	ld	l, a
	ld	a, e
	cp	a, l
	jr	c, .LBB16_155
; %bb.154:
	inc	e
	ld	a, e
	ld	(_render_profile+14), a
	.local	.LBB16_155
.LBB16_155:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB16_156
.LBB16_156:
	bit	0, c
	jp	z, .LBB16_164
; %bb.157:
	ld	a, (_render_benchmark_category)
	cp	a, 6
	jp	z, .LBB16_164
; %bb.158:
	ld	(ix - 9), a                     ; 1-byte Folded Spill
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
	jr	nc, .LBB16_160
; %bb.159:
	push	bc
	jr	.LBB16_162
	.local	.LBB16_160
.LBB16_160:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_163
; %bb.161:
	push	de
	.local	.LBB16_162
.LBB16_162:
	pop	iy
	.local	.LBB16_163
.LBB16_163:
	ld	(ix - 28), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 31), e
	ld	bc, (_render_benchmark_last)
	lea	hl, iy + 0
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 9)                     ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 9), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 9)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 28)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 31)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 6
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+40
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB16_164
.LBB16_164:
	ld	a, (_render_scratch+10)
	ld	l, a
	or	a, a
	ld	bc, (ix - 12)
	jp	z, .LBB16_194
; %bb.165:
	ld	a, l
	cp	a, 2
	jr	z, .LBB16_167
; %bb.166:
	ld	e, 0
	jr	.LBB16_168
	.local	.LBB16_167
.LBB16_167:
	ld	e, -1
	.local	.LBB16_168
.LBB16_168:
	ld	d, (ix - 1)
	ld	c, (ix - 2)
	ld	a, l
	cp	a, 1
	jr	z, .LBB16_170
; %bb.169:
	ld	l, 15
	ld	a, e
	add	a, l
	ld	l, a
	ld	(ix - 52), hl
	.local	.LBB16_170
.LBB16_170:
	ld	(ix - 9), c                     ; 1-byte Folded Spill
	ld	a, c
	sub	a, d
	ld	l, a
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	b, a
	inc	b
	inc	b
	or	a, a
	sbc	hl, hl
	ld	a, d
	push	hl
	pop	de
	ld	(ix - 28), a                    ; 1-byte Folded Spill
	ld	e, a
	ld	l, b
	add	hl, de
	ld	iy, (ix - 25)
	ld	a, (iy + 3)
	cp	a, l
	jr	c, .LBB16_172
; %bb.171:
	ld	a, l
	.local	.LBB16_172
.LBB16_172:
	ld	(ix - 31), a
	ld	de, 0
	ld	c, (ix - 9)                     ; 1-byte Folded Reload
	ld	e, c
	or	a, a
	sbc	hl, de
	jr	nc, .LBB16_187
; %bb.173:
	ld	a, c
	sub	a, b
	ld	l, a
	ld	iy, (ix - 25)
	ld	a, (iy + 2)
	ld	(ix - 25), hl
	cp	a, l
	ld	iyl, c
	ld	c, (ix - 28)                    ; 1-byte Folded Reload
	jr	c, .LBB16_175
; %bb.174:
	ld	l, a
	ld	(ix - 25), hl
	.local	.LBB16_175
.LBB16_175:
	ld	de, (ix - 12)
	ld	a, e
	cp	a, c
	jr	c, .LBB16_177
; %bb.176:
	ld	c, e
	.local	.LBB16_177
.LBB16_177:
	ld	b, (ix - 31)                    ; 1-byte Folded Reload
	ld	a, b
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB16_179
; %bb.178:
	ld	hl, (ix - 16)
	ld	b, l
	.local	.LBB16_179
.LBB16_179:
	ld	a, c
	cp	a, b
	jr	nc, .LBB16_181
; %bb.180:
	ld	hl, (ix - 52)
	push	hl
	ld	l, b
	push	hl
	ld	l, c
	push	hl
	ld	hl, (ix + 9)
	push	hl
	call	_render_asm_draw_solid_segment
	push	af
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	ld	de, (ix - 12)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB16_181
.LBB16_181:
	ld	a, e
	ld	bc, (ix - 25)
	cp	a, c
	jr	c, .LBB16_183
; %bb.182:
	ld	c, e
	.local	.LBB16_183
.LBB16_183:
	ld	a, iyl
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB16_185
; %bb.184:
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	.local	.LBB16_185
.LBB16_185:
	ld	a, c
	cp	a, iyl
	jr	nc, .LBB16_194
; %bb.186:
	ld	hl, (ix - 52)
	push	hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	push	hl
	push	bc
	jr	.LBB16_193
	.local	.LBB16_187
.LBB16_187:
	ld	hl, (ix - 12)
	ld	a, l
	ld	e, (ix - 28)                    ; 1-byte Folded Reload
	cp	a, e
	jr	c, .LBB16_189
; %bb.188:
	ld	e, l
	.local	.LBB16_189
.LBB16_189:
	ld	c, (ix - 31)                    ; 1-byte Folded Reload
	ld	a, c
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB16_191
; %bb.190:
	ld	c, l
	.local	.LBB16_191
.LBB16_191:
	ld	a, e
	cp	a, c
	jr	nc, .LBB16_194
; %bb.192:
	ld	hl, (ix - 52)
	push	hl
	ld	l, c
	push	hl
	ld	l, e
	push	hl
	.local	.LBB16_193
.LBB16_193:
	ld	hl, (ix + 9)
	push	hl
	call	_render_asm_draw_solid_segment
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB16_194
.LBB16_194:
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB16_152
; %bb.195:
	ld	a, (_render_benchmark_category)
	cp	a, 4
	jp	z, .LBB16_146
; %bb.196:
	ld	(ix - 9), a                     ; 1-byte Folded Spill
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
	jr	nc, .LBB16_198
; %bb.197:
	push	bc
	jr	.LBB16_200
	.local	.LBB16_198
.LBB16_198:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB16_201
; %bb.199:
	push	de
	.local	.LBB16_200
.LBB16_200:
	pop	iy
	.local	.LBB16_201
.LBB16_201:
	ld	(ix - 12), iy
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	(ix - 16), e
	ld	bc, (_render_benchmark_last)
	lea	hl, iy + 0
	ld	iy, (ix - 22)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 9)                     ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 9), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 9)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 19)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 12)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 16)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 4
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+36
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	ld	c, 1
	jp	.LBB16_143
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_render_column, .Lfunc_end16-_render_column
                                        ; -- End function
	.section	.text._game_get_render_profile,"ax",@progbits
	.globl	_game_get_render_profile        ; -- Begin function game_get_render_profile
	.type	_game_get_render_profile,@function
_game_get_render_profile:               ; @game_get_render_profile
; %bb.0:
	ld	hl, _render_profile
	ret
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_game_get_render_profile, .Lfunc_end17-_game_get_render_profile
                                        ; -- End function
	.section	.text._live_benchmark_run,"ax",@progbits
	.globl	_live_benchmark_run             ; -- Begin function live_benchmark_run
	.type	_live_benchmark_run,@function
_live_benchmark_run:                    ; @live_benchmark_run
; %bb.0:
	ld	hl, -221
	call	__frameset
	ld	bc, 0
	xor	a, a
	scf
	sbc	hl, hl
	ld	(ix - 127), hl
	ld.sis	iy, 0
	inc	l
	push	ix
	lea	ix, ix - 128
	ld	(ix - 10), l
	pop	ix
	ld	l, -127
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	ld	hl, _.str.35
	push	ix
	lea	ix, ix - 128
	ld	(ix - 13), hl
	pop	ix
	ld	hl, 1629
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	lea	hl, ix - 87
	lea	de, ix - 105
	push	ix
	lea	ix, ix - 128
	push	iy
	ex	(sp), hl
	ld	(ix - 7), l
	ld	(ix - 6), h
	pop	hl
	pop	ix
	push	iy
	ex	(sp), hl
	ld	(ix - 115), l
	ld	(ix - 114), h
	pop	hl
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld	(ix - 121), hl
	ld	(ix - 124), de
	.local	.LBB18_1
.LBB18_1:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	ld	de, 126
	or	a, a
	sbc	hl, de
	jr	z, .LBB18_6
; %bb.2:                                ;   in Loop: Header=BB18_1 Depth=1
	ld	iy, _live_route
	add	iy, bc
	ld	a, (iy + 4)
	cp	a, 18
	jr	nc, .LBB18_8
; %bb.3:                                ;   in Loop: Header=BB18_1 Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB18_5
; %bb.4:                                ;   in Loop: Header=BB18_1 Depth=1
	ld	l, (ix - 118)
	cp	a, l
	jr	c, .LBB18_8
	.local	.LBB18_5
.LBB18_5:                               ;   in Loop: Header=BB18_1 Depth=1
	ld	iy, (iy)
	ld	e, (ix - 115)
	ld	d, (ix - 114)
	add.sis	iy, de
	push	bc
	pop	hl
	ld	de, 6
	add	hl, de
	push	hl
	pop	bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	(ix - 115), l
	ld	(ix - 114), h
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld	hl, (ix - 121)
	ld	de, (ix - 124)
	jr	.LBB18_1
	.local	.LBB18_6
.LBB18_6:
	ld.sis	de, 971
	ld	l, (ix - 115)
	ld	h, (ix - 114)
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB18_8
; %bb.7:
	ld	a, (ix - 118)                   ; 1-byte Folded Reload
	cp	a, 17
	jr	z, .LBB18_11
	.local	.LBB18_8
.LBB18_8:                               ; %.loopexit17
	ld	hl, _.str
	.local	.LBB18_9
.LBB18_9:
	push	hl
	call	_live_show_failure
	pop	hl
	ld	hl, 1
	.local	.LBB18_10
.LBB18_10:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB18_11
.LBB18_11:
	ld	hl, _.str.2
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.5
	push	hl
	ld	hl, _.str.2
	push	hl
	call	_ti_Open
	ld	l, a
	pop	de
	pop	de
	ld	(_live_report_handle), a
	or	a, a
	jr	z, .LBB18_16
; %bb.12:
	push	hl
	ld	hl, 24912
	push	hl
	call	_ti_Resize
	pop	de
	pop	de
	ld	a, (_live_report_handle)
	ld	e, a
	ld	bc, 24912
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB18_15
; %bb.13:
	push	de
	call	_ti_GetDataPtr
	pop	de
	ld	(_live_report), hl
	push	hl
	pop	iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB18_17
; %bb.14:
	ld	a, (_live_report_handle)
	ld	e, a
	.local	.LBB18_15
.LBB18_15:
	push	de
	call	_ti_Close
	pop	hl
	xor	a, a
	ld	(_live_report_handle), a
	ld	hl, _.str.2
	push	hl
	call	_ti_Delete
	pop	hl
	.local	.LBB18_16
.LBB18_16:
	ld	hl, _.str.1
	jr	.LBB18_9
	.local	.LBB18_17
.LBB18_17:
	ld	(iy), 0
	lea	hl, iy + 0
	inc	hl
	ld	bc, 24911
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 22), iy
	pop	ix
	lea	hl, iy + 0
	ldir
	ld	iy, 0
	xor	a, a
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	ld.sis	hl, 0
	push	ix
	lea	ix, ix - 128
	ld	(ix - 16), l
	ld	(ix - 15), h
	pop	ix
	.local	.LBB18_18
.LBB18_18:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB18_24 Depth 2
	lea	hl, iy + 0
	ld	de, 18
	or	a, a
	sbc	hl, de
	jp	z, .LBB18_31
; %bb.19:                               ;   in Loop: Header=BB18_18 Depth=1
	lea	hl, iy + 0
	ld	bc, 84
	call	__imulu
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 22)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 25), hl
	pop	ix
	ld	(ix - 115), iy
	lea	hl, iy + 0
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _live_sections
	add	hl, de
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, (hl)
	ld	de, -156
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	hl
	call	_strlen
	ld	de, -162
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	pop	hl
	ld	a, (ix - 118)                   ; 1-byte Folded Reload
	cp	a, 22
	jr	nc, .LBB18_21
; %bb.20:                               ;   in Loop: Header=BB18_18 Depth=1
	ld	a, 21
	.local	.LBB18_21
.LBB18_21:                              ;   in Loop: Header=BB18_18 Depth=1
	ld	de, 0
	ld	e, (ix - 118)                   ; 1-byte Folded Reload
	push	de
	pop	hl
	ld	bc, 22
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	jr	nc, .LBB18_23
; %bb.22:                               ;   in Loop: Header=BB18_18 Depth=1
	ld	hl, 21
	.local	.LBB18_23
.LBB18_23:                              ;   in Loop: Header=BB18_18 Depth=1
	ld	bc, -147
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	push	de
	pop	hl
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _live_route+4
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 19)
	pop	ix
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld.sis	hl, 0
	.local	.LBB18_24
.LBB18_24:                              ;   Parent Loop BB18_18 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	ix
	lea	ix, ix - 128
	ld	(ix - 19), l
	ld	(ix - 18), h
	pop	ix
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB18_27
; %bb.25:                               ;   in Loop: Header=BB18_24 Depth=2
	ld	l, (iy)
	ld	de, 0
	ld	e, l
	ld	hl, (ix - 115)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB18_28
; %bb.26:                               ;   in Loop: Header=BB18_24 Depth=2
	ld	hl, (iy - 4)
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	pop	ix
	add.sis	hl, de
	inc	(ix - 118)
	lea	iy, iy + 6
	dec	bc
                                        ; kill: def $hl killed $hl killed $uhl
	jp	.LBB18_24
	.local	.LBB18_27
.LBB18_27:                              ;   in Loop: Header=BB18_18 Depth=1
	ld	(ix - 118), a                   ; 1-byte Folded Spill
	.local	.LBB18_28
.LBB18_28:                              ; %.loopexit
                                        ;   in Loop: Header=BB18_18 Depth=1
	ld	l, -16
	ld	de, -162
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	ld	a, c
	and	a, l
	ld	e, a
	push	bc
	pop	hl
	ld	bc, 255
	call	__iand
	ld	bc, (ix - 115)
	inc	bc
	ld	(ix - 115), bc
	ld	a, c
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 25)
	pop	ix
	ld	(iy + 96), a
	lea	bc, iy + 0
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 31)
	pop	ix
	ld	a, (iy + 3)
	push	bc
	pop	iy
	ld	(iy + 97), a
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 16)
	ld	b, (ix - 15)
	pop	ix
	ld	(iy + 98), c
	ld	a, b
	ld	(iy + 99), a
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 19)
	ld	b, (ix - 18)
	pop	ix
	ld	(iy + 100), c
	ld	a, b
	ld	(iy + 101), a
	ld	(iy + 102), d
	ld	(iy + 103), d
	ld	a, e
	or	a, a
	jr	z, .LBB18_30
; %bb.29:                               ; %.loopexit
                                        ;   in Loop: Header=BB18_18 Depth=1
	ld	hl, 15
	.local	.LBB18_30
.LBB18_30:                              ; %.loopexit
                                        ;   in Loop: Header=BB18_18 Depth=1
	push	hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 28)
	pop	ix
	push	hl
	pea	iy + 104
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	de, -147
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	bc, -144
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)
	ld	d, (iy + 1)
	add.sis	hl, de
	ld	de, -144
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	iy, (ix - 115)
	jp	.LBB18_18
	.local	.LBB18_31
.LBB18_31:
	ld	hl, -917456
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld.sis	bc, 2048
	call	__sand
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB18_33
; %bb.32:
	ld	hl, -917472
	push	hl
	call	_atomic_load_decreasing_32
	jr	.LBB18_34
	.local	.LBB18_33
.LBB18_33:
	ld	hl, -917472
	push	hl
	call	_atomic_load_increasing_32
	.local	.LBB18_34
.LBB18_34:
	ld	bc, -162
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
	ld	bc, -144
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -150
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_game_graphics_init
	call	_clock
	ld	bc, -153
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -156
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_game_render_benchmark_calibrate
	ld	bc, -166
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	iyl, 0
	ld	a, iyl
	ld	(_live_game+8), a
	ld	hl, _live_game+8
	push	hl
	pop	de
	inc	de
	ld	(ix - 118), de
	ld	bc, 9
	ldir
	ld	hl, 384
	ld	(_live_game), hl
	ld	hl, 640
	ld	(_live_game+3), hl
	ld.sis	hl, 8192
	ex.sis	de, hl
	ld	hl, _live_game+6
	ld	(hl), e
	inc	hl
	ld	(hl), d
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	a, iyl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	hl, _render_benchmark
	push	hl
	pop	de
	inc	de
	ld	bc, 65
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 19
	ld	(iy + 0), de
	ldir
	call	_clock
	ld	bc, -170
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	hl, _live_game
	push	hl
	call	_game_render
	pop	hl
	call	_clock
	ld	bc, -178
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -181
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_gfx_SwapDraw
	xor	a, a
	ld	(_live_game+8), a
	ld	de, (ix - 118)
	ld	hl, _live_game+8
	ld	bc, 9
	ldir
	ld	hl, 384
	ld	(_live_game), hl
	ld	hl, 640
	ld	(_live_game+3), hl
	ld.sis	hl, 8192
	ld	iy, _live_game+6
	ld	(iy), l
	ld	(iy + 1), h
	ld	(ix - 87), a
	ld.sis	hl, 0
	ld	(ix - 85), l
	ld	(ix - 84), h
	ld	(ix - 83), l
	ld	(ix - 82), h
	ld	l, 16
	.local	.LBB18_35
.LBB18_35:                              ; =>This Inner Loop Header: Depth=1
	ld	a, l
	or	a, a
	jp	z, .LBB18_37
; %bb.36:                               ;   in Loop: Header=BB18_35 Depth=1
	pea	ix - 7
	pea	ix - 15
	pea	ix - 105
	pea	ix - 87
	ld	(ix - 115), l                   ; 1-byte Folded Spill
	call	_live_controller_next
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (ix - 105)
	ld	l, (ix - 15)
	ld	de, 30
	push	de
	ld	de, 1
	push	de
	dec	de
	push	de
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	l, a
	push	hl
	ld	hl, _live_game
	push	hl
	call	_game_update
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	bc, -147
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	hl, _render_benchmark
	ld	bc, 65
	ldir
	ld	hl, _live_game
	push	hl
	call	_game_render
	pop	hl
	call	_gfx_SwapDraw
	ld	l, (ix - 115)                   ; 1-byte Folded Reload
	dec	l
	jp	.LBB18_35
	.local	.LBB18_37
.LBB18_37:
	ld	de, -153
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	bc, -156
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 16
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 22
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	ld	bc, -174
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	de, -178
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	bc, -181
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 42
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 43
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	ld	bc, -170
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	(ix - 87), 0
	ld	hl, (ix - 121)
	push	hl
	pop	iy
	inc	iy
	ld	bc, 71
	lea	de, iy + 0
	ldir
	xor	a, a
	ld	(_live_game+8), a
	ld	bc, 9
	ld	de, (ix - 118)
	ld	hl, _live_game+8
	ldir
	ld	hl, 384
	ld	(_live_game), hl
	ld	hl, 640
	ld	(_live_game+3), hl
	ld.sis	hl, 8192
	ld	iy, _live_game+6
	ld	(iy), l
	ld	(iy + 1), h
	ld	(ix - 15), a
	ld.sis	hl, 0
	ld	(ix - 13), l
	ld	(ix - 12), h
	ld	(ix - 11), l
	ld	(ix - 10), h
	call	_clock
	ld	bc, -181
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -184
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	de, 24933
	ld	h, 0
	ld	bc, -144
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	c, h
	ld	a, c
	ld.sis	iy, 0
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 50), hl
	pop	ix
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 25), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 28), c                    ; 1-byte Folded Spill
	pop	ix
	push	iy
	ex	(sp), hl
	ld	(ix - 115), l
	ld	(ix - 114), h
	pop	hl
	push	hl
	pop	bc
	ld	hl, 1875397
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 22
	ld	(iy + 0), hl
	.local	.LBB18_38
.LBB18_38:                              ; =>This Inner Loop Header: Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
	ld	hl, (iy + 0)
	or	a, a
	sbc	hl, de
	jp	z, .LBB18_60
; %bb.39:                               ;   in Loop: Header=BB18_38 Depth=1
	ld	de, -193
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, (ix - 124)
	ld	hl, _live_game
	ld	bc, 18
	ldir
	pea	ix - 106
	pea	ix - 8
	pea	ix - 7
	pea	ix - 15
	call	_live_controller_next
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB18_65
; %bb.40:                               ;   in Loop: Header=BB18_38 Depth=1
	call	_clock
	ld	bc, -196
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -199
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	e, (ix - 7)
	ld	a, (ix - 8)
	ld	hl, 30
	push	hl
	ld	hl, 1
	push	hl
	dec	hl
	push	hl
	ld	bc, -214
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	l, a
	push	hl
	dec	bc
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	l, e
	push	hl
	ld	hl, _live_game
	push	hl
	call	_game_update
	ld	de, -187
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	call	_clock
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 68
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 71
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	ld	bc, -202
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -205
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	hl, (ix - 124)
	push	hl
	call	_live_crossed_portal
	ld	de, -196
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	pop	hl
	ld	a, (ix - 106)
	ld	de, -199
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	l, a
	push	hl
	ld	de, -178
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_live_section_ends
	ld	e, a
	pop	hl
	pop	hl
	ld	bc, -187
	lea	iy, ix + 0
	add	iy, bc
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	or	a, a
	ld	a, 0
	ld	c, a
	jr	z, .LBB18_42
; %bb.41:                               ;   in Loop: Header=BB18_38 Depth=1
	ld	a, 4
	ld	c, a
	.local	.LBB18_42
.LBB18_42:                              ;   in Loop: Header=BB18_38 Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 68
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	or	a, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 83
	ld	(iy + 0), e
	jr	nz, .LBB18_44
; %bb.43:                               ;   in Loop: Header=BB18_38 Depth=1
	or	a, a
	sbc	hl, hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 71
	ld	l, (iy + 0)                     ; 1-byte Folded Reload
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 80
	ld	(iy + 0), hl
	jp	.LBB18_45
	.local	.LBB18_44
.LBB18_44:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	iy, (_live_report)
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 71)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	ld	a, c
	ld	bc, 84
	call	__imulu
	ex	de, hl
	add	iy, de
	lea	hl, iy + 0
	ld	de, 178
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 59), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	pop	ix
	ld	e, (hl)
	ld	bc, 179
	add	iy, bc
	ld	bc, -196
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	c, a
	ld	a, (iy)
	ld	h, d
	ld	l, a
	ld	h, l
	ld	l, d
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 16
	ld	(iy + 0), e
	ld	(iy + 1), d
	add.sis	hl, de
	inc	c
	ld	e, (ix - 115)
	ld	d, (ix - 114)
	inc.sis	de
	ld	(ix - 115), e
	ld	(ix - 114), d
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 83
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	inc.sis	hl
	ld	a, l
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 59)
	pop	ix
	ld	(iy), a
	ld	a, h
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 68
	ld	hl, (iy + 0)
	ld	(hl), a
	.local	.LBB18_45
.LBB18_45:                              ;   in Loop: Header=BB18_38 Depth=1
	or	a, a
	sbc	hl, hl
	ld	a, e
	or	a, a
	jr	z, .LBB18_47
; %bb.46:                               ;   in Loop: Header=BB18_38 Depth=1
	ld	e, 8
	ld	a, c
	add	a, e
	ld	c, a
	.local	.LBB18_47
.LBB18_47:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	de, -216
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c
	xor	a, a
	ld	(_render_benchmark_active), a
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	bc, -147
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	hl, _render_benchmark
	ld	bc, 65
	ldir
	call	_clock
	ld	bc, -187
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -196
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	hl, _live_game
	push	hl
	call	_game_render
	pop	hl
	call	_clock
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 59
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 68
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	push	hl
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 59
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	hl, _render_profile+12
	ld	hl, (hl)
	ld	de, -220
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	a, (_render_profile+14)
	ld	de, -217
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -208
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, (ix - 121)
	add	iy, de
	ld	hl, (iy)
	ld	e, (iy + 3)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 68), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 59)                    ; 1-byte Folded Reload
	pop	ix
	call	__lcmpu
	jr	nc, .LBB18_49
; %bb.48:                               ;   in Loop: Header=BB18_38 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 68)
	pop	ix
	ld	(iy), hl
	ld	de, -187
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 3), a
	ld	iy, (_live_report)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	ld	bc, 84
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	de, -190
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 102), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 65)
	pop	ix
	ld	a, h
	ld	(iy + 103), a
	.local	.LBB18_49
.LBB18_49:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	de, -211
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	or	a, a
	jp	z, .LBB18_51
; %bb.50:                               ;   in Loop: Header=BB18_38 Depth=1
	ld	iy, (_live_report)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	ld	bc, 84
	call	__imulu
	ex	de, hl
	add	iy, de
	ld	de, -208
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, 174
	add	iy, de
	ld	de, -211
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	call	_live_game_hash
	push	hl
	pop	iy
	ld	a, iyl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 83)
	pop	ix
	ld	(hl), a
	ld	a, iyh
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	ld	bc, 175
	add	hl, bc
	ld	(hl), a
	lea	bc, iy + 0
	ld	a, e
	ld	l, 16
	call	__lshru
	ld	a, c
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	ld	bc, 176
	add	hl, bc
	ld	(hl), a
	lea	bc, iy + 0
	ld	a, e
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	de, 177
	ld	bc, -208
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	(hl), a
	.local	.LBB18_51
.LBB18_51:                              ;   in Loop: Header=BB18_38 Depth=1
	call	_clock
	ld	bc, -208
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -211
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	call	_gfx_SwapDraw
	call	_clock
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 80
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 83
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	ld	bc, -208
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	d, e
	ld	iy, (_live_report)
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 5)
	pop	ix
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 68)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 59)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 74)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 77)                    ; 1-byte Folded Reload
	pop	ix
	call	__ladd
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 80)
	pop	ix
	ld	a, d
	call	__ladd
	push	ix
	lea	ix, ix - 128
	ld	(ix - 93), e                    ; 1-byte Folded Spill
	pop	ix
	ld	bc, 65535
	xor	a, a
	call	__lcmpu
	push	ix
	lea	ix, ix - 128
	ld	(ix - 83), hl
	pop	ix
	jr	c, .LBB18_53
; %bb.52:                               ;   in Loop: Header=BB18_38 Depth=1
	push	bc
	pop	hl
	.local	.LBB18_53
.LBB18_53:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	a, l
	ld	(iy - 21), a
	ld	a, h
	ld	(iy - 20), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 74)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 77)                    ; 1-byte Folded Reload
	pop	ix
	ld	bc, 65535
	xor	a, a
	call	__lcmpu
	push	hl
	pop	bc
	ld	hl, 65535
	jr	c, .LBB18_55
; %bb.54:                               ;   in Loop: Header=BB18_38 Depth=1
	push	hl
	pop	bc
	.local	.LBB18_55
.LBB18_55:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	a, c
	ld	(iy - 19), a
	ld	a, b
	ld	(iy - 18), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 68)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 59)                    ; 1-byte Folded Reload
	pop	ix
	ld	bc, 65535
	xor	a, a
	call	__lcmpu
	jr	c, .LBB18_57
; %bb.56:                               ;   in Loop: Header=BB18_38 Depth=1
	push	bc
	pop	hl
	.local	.LBB18_57
.LBB18_57:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	a, l
	ld	(iy - 17), a
	ld	a, h
	ld	(iy - 16), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	ld	e, d
	xor	a, a
	call	__lcmpu
	jr	c, .LBB18_59
; %bb.58:                               ;   in Loop: Header=BB18_38 Depth=1
	ld	hl, 65535
	.local	.LBB18_59
.LBB18_59:                              ;   in Loop: Header=BB18_38 Depth=1
	ld	a, l
	ld	(iy - 15), a
	ld	a, h
	ld	(iy - 14), a
	ld	hl, (_live_game)
	ld	a, l
	ld	(iy - 13), a
	ld	a, h
	ld	(iy - 12), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(iy - 11), a
	ld	hl, (_live_game+3)
	ld	a, l
	ld	(iy - 10), a
	ld	a, h
	ld	(iy - 9), a
	call	__ishru
	ld	a, l
	ld	(iy - 8), a
	ld	hl, _live_game+6
	ld	hl, (hl)
	ld	a, l
	ld	(iy - 7), a
	ld	a, h
	ld	(iy - 6), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 92)
	pop	ix
	ld	a, l
	ld	(iy - 5), a
	ld	a, h
	ld	(iy - 4), a
	ld	de, -217
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy - 3), a
	ld	de, -199
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	inc	a
	ld	(iy - 2), a
	ld	de, -216
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy - 1), a
	inc	de
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	inc	a
	ld	l, 3
	and	a, l
	ld	l, a
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 86)                    ; 1-byte Folded Reload
	pop	ix
	ld	b, 2
	call	__bshl
	ld	e, 4
	add	a, e
	ld	e, a
	ld	c, 12
	ld	a, e
	and	a, c
	ld	e, a
	ld	a, e
	add	a, l
	ld	l, a
	ld	(iy), l
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 83)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 93)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 25)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 28)                    ; 1-byte Folded Reload
	pop	ix
	call	__ladd
	push	ix
	lea	ix, ix - 128
	ld	(ix - 25), hl
	pop	ix
	ld	bc, -156
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), e                         ; 1-byte Folded Spill
	ld	hl, 10
	push	hl
	pea	iy - 13
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -150
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_live_hash_bytes
	ld	bc, -150
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
                                        ; kill: def $e killed $e def $ude
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -193
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	inc	bc
	ld	de, -178
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc.sis	hl
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	inc	a
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 24
	add	hl, de
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, 24933
	jp	.LBB18_38
	.local	.LBB18_60
.LBB18_60:
	call	_clock
	ld	bc, -178
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	a, e
	ld	hl, (_live_report)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, 1512
	or	a, a
	sbc	hl, hl
	.local	.LBB18_61
.LBB18_61:                              ; =>This Inner Loop Header: Depth=1
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jr	z, .LBB18_63
; %bb.62:                               ;   in Loop: Header=BB18_61 Depth=1
	ld	de, -133
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	add	iy, bc
	ld	l, (iy + 102)
	ld	de, 0
	ld	e, l
	push	ix
	lea	ix, ix - 128
	ld	(ix - 59), bc
	pop	ix
	ld	c, (iy + 103)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	c, 8
	call	__ishl
	add	hl, de
	ld	bc, 24
	call	__imulu
	ex	de, hl
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	de, 1628
	add	hl, de
	set	1, (hl)
	ld	de, -187
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 84
	add	hl, de
	ld	de, 1512
	jr	.LBB18_61
	.local	.LBB18_63
.LBB18_63:
	ld	de, -178
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	e, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 53
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 56
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lsub
	push	hl
	pop	iy
	ld	h, (ix - 15)
	ld	bc, (ix - 11)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 53), bc
	pop	ix
	ld	a, iyh
	push	ix
	lea	ix, ix - 128
	ld	(ix - 50), a
	pop	ix
	ld	l, 16
	lea	bc, iy + 0
	ld	a, e
	call	__lshru
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), bc
	pop	ix
	ld	l, 24
	lea	bc, iy + 0
	ld	a, e
	call	__lshru
	ld	a, h
	cp	a, 21
	jp	z, .LBB18_66
; %bb.64:
	ld	de, -211
	lea	hl, ix + 0
	add	hl, de
	push	af
	ld	a, iyl
	ld	(hl), a                         ; 1-byte Folded Spill
	pop	af
	jp	.LBB18_68
	.local	.LBB18_65
.LBB18_65:
                                        ; implicit-def: $a
                                        ; kill: killed $a
	xor	a, a
	ld	de, -178
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -187
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -193
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	jp	.LBB18_69
	.local	.LBB18_66
.LBB18_66:
	ld	de, -187
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -181
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 971
	or	a, a
	sbc.sis	hl, de
	jp	z, .LBB18_109
; %bb.67:
	ld	de, -187
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, -211
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l                     ; 1-byte Folded Spill
	.local	.LBB18_68
.LBB18_68:
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, -187
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l                     ; 1-byte Folded Spill
	ld	de, -193
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	xor	a, a
	.local	.LBB18_69
.LBB18_69:
	ld	de, -181
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -184
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	de, -196
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	bc, 7
	ld	hl, _.str.24
	.local	.LBB18_70
.LBB18_70:
	ld	iy, (_live_report)
	lea	de, iy + 0
	ldir
	ld	(iy + 8), 1
	ld	(iy + 9), 0
	ld	(iy + 10), 96
	ld	(iy + 11), 0
	ld	(iy + 12), -1
	ld	(iy + 13), 3
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
	ld	(iy + 24), 4
	ld	(iy + 25), 41
	ld	(iy + 26), 7
	ld	de, -133
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	(iy + 27), 38
	ld	hl, 126
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
	ld	(ix - 118), de
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, 72
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	bc, -147
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a
	or	a, a
	sbc	hl, hl
	.local	.LBB18_71
.LBB18_71:                              ; =>This Inner Loop Header: Depth=1
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jp	z, .LBB18_73
; %bb.72:                               ;   in Loop: Header=BB18_71 Depth=1
	ld	hl, _live_sections
	add	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 74), hl
	pop	ix
	ld	hl, (hl)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	push	hl
	ld	de, -199
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	ld	de, -205
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	call	_strlen
	pop	de
	push	hl
	ld	de, -208
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, (ix - 118)
	push	hl
	ld	de, -205
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
	ld	iy, (ix - 74)
	pop	ix
	ld	a, (iy + 3)
	push	ix
	lea	ix, ix - 128
	push	hl
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	ex	(sp), hl
	pop	iy
	pop	ix
	push	af
	ld	a, iyh
	ld	(ix - 108), a
	pop	af
	ld	bc, (ix - 110)
	ld	b, iyh
	ld	c, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 19
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lxor
	ld	bc, 403
	ld	a, b
	call	__lmulu
	push	hl
	pop	iy
                                        ; kill: def $e killed $e def $ude
	ld	(ix - 118), de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 71)
	pop	ix
	ld	de, 4
	add	hl, de
	ld	de, 72
	jp	.LBB18_71
	.local	.LBB18_73
.LBB18_73:
	ld	a, iyl
	lea	de, iy + 0
	ld	bc, -133
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	(iy + 28), a
	ld	a, d
	ld	(iy + 29), a
	push	de
	pop	bc
	ld	hl, (ix - 118)
	ld	a, l
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 30), a
	ld	l, 24
	push	de
	pop	bc
	ld	de, (ix - 118)
	ld	a, e
	call	__lshru
	ld	a, c
	ld	(iy + 31), a
	ld	(iy + 32), 80
	ld	(iy + 33), 97
	ld	(iy + 34), 18
	ld	(iy + 35), 0
	ld	(iy + 36), 16
	ld	(iy + 37), 0
	ld	(iy + 38), -53
	ld	(iy + 39), 3
	ld	(iy + 40), 84
	ld	(iy + 41), 0
	ld	(iy + 42), l
	ld	(iy + 43), 0
	ld	(iy + 44), 80
	ld	(iy + 45), 0
	ld	(iy + 46), 4
	ld	(iy + 47), 8
	ld	(iy + 48), 6
	ld	(iy + 49), 7
	ld	(iy + 50), 30
	ld	(iy + 51), 0
	ld	(iy + 52), 1
	ld	(iy + 53), 0
	ld	(iy + 54), 3
	ld	(iy + 55), 0
	ld	bc, -166
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
	ld	h, (ix - 39)                    ; 1-byte Folded Reload
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
	ld	bc, -174
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
	ld	h, (ix - 47)                    ; 1-byte Folded Reload
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
	ld	bc, -170
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	ld	a, e
	ld	(iy + 68), a
	ld	a, d
	ld	(iy + 69), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	h, (ix - 43)                    ; 1-byte Folded Reload
	pop	ix
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 70), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 71), a
	ld	bc, -153
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	ld	a, e
	ld	(iy + 72), a
	ld	a, d
	ld	(iy + 73), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	h, (ix - 28)                    ; 1-byte Folded Reload
	pop	ix
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 74), a
	push	de
	pop	bc
	ld	a, h
	ld	h, 24
	ld	l, h
	call	__lshru
	ld	a, c
	ld	(iy + 75), a
	ld	bc, -150
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	ld	a, e
	ld	(iy + 76), a
	ld	a, d
	ld	(iy + 77), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	ld	a, l
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 78), a
	push	de
	pop	bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	ld	a, l
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 79), a
	ld	de, -181
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 80), a
	ld	de, -184
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 81), a
	ld	de, -190
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 82), a
	ld	de, -196
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 83), a
	ld	l, (ix - 115)
	ld	h, (ix - 114)
	ld	a, l
	ld	(iy + 84), a
	ld	a, h
	ld	(iy + 85), a
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 7)
	ld	h, (ix - 6)
	pop	ix
	ld	(iy + 86), l
	ld	a, h
	ld	(iy + 87), a
	ld	(iy + 88), 80
	ld	(iy + 89), 97
	ld	de, -211
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 92), a
	ld	de, -178
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 93), a
	ld	de, -187
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 94), a
	ld	de, -193
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)
	ld	(iy + 95), a
	ld	bc, 24816
	or	a, a
	sbc	hl, hl
	ld	(ix - 118), hl
	ld	e, d
	.local	.LBB18_74
.LBB18_74:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB18_76 Depth 2
	ld	hl, (ix - 118)
	or	a, a
	sbc	hl, bc
	jp	z, .LBB18_83
; %bb.75:                               ;   in Loop: Header=BB18_74 Depth=1
	ld	bc, -133
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	bc, (ix - 118)
	add	iy, bc
	ld	a, (iy + 96)
	ld	bc, -144
	lea	iy, ix + 0
	add	iy, bc
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	(ix - 107), h
	ld	bc, (ix - 109)
	ld	b, h
	ld	c, a
	ld	hl, (ix - 127)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 19
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lxor
	ld	d, 8
	.local	.LBB18_76
.LBB18_76:                              ;   Parent Loop BB18_74 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, d
	or	a, a
	jr	z, .LBB18_82
; %bb.77:                               ;   in Loop: Header=BB18_76 Depth=2
	ld	(ix - 127), d                   ; 1-byte Folded Spill
	push	hl
	pop	iy
	ld	d, e
	ld	bc, 1
	xor	a, a
	call	__land
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	lea	bc, iy + 0
	ld	a, d
	ld	l, 1
	call	__lshru
	ld	iyl, a
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 2)
	pop	ix
	ld	a, e
	xor	a, l
	ld	e, a
	bit	0, e
	ld	hl, 0
	jr	nz, .LBB18_79
; %bb.78:                               ;   in Loop: Header=BB18_76 Depth=2
	ld	hl, -4685024
	.local	.LBB18_79
.LBB18_79:                              ;   in Loop: Header=BB18_76 Depth=2
	bit	0, e
	ld	e, 0
	jr	nz, .LBB18_81
; %bb.80:                               ;   in Loop: Header=BB18_76 Depth=2
	ld	e, -19
	.local	.LBB18_81
.LBB18_81:                              ;   in Loop: Header=BB18_76 Depth=2
	ld	a, iyl
	call	__lxor
	ld	d, (ix - 127)                   ; 1-byte Folded Reload
	dec	d
	jr	.LBB18_76
	.local	.LBB18_82
.LBB18_82:                              ;   in Loop: Header=BB18_74 Depth=1
	ld	(ix - 127), hl
	ld	hl, (ix - 118)
	inc	hl
	ld	(ix - 118), hl
	ld	bc, 24816
	jp	.LBB18_74
	.local	.LBB18_83
.LBB18_83:
	ld	hl, (ix - 127)
	call	__lnot
	ld	(ix - 118), e                   ; 1-byte Folded Spill
	ld	a, l
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 5)
	pop	ix
	ld	(iy + 60), a
	ld	a, h
	ex	de, hl
	ld	(iy + 61), a
	ld	l, 16
	push	de
	pop	bc
	ld	h, (ix - 118)                   ; 1-byte Folded Reload
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
	ld	de, -138
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	ld	a, 0
	ld	e, a
	jr	z, .LBB18_90
; %bb.84:
	ld	l, (ix - 115)
	ld	h, (ix - 114)
	ld.sis	de, 3
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB18_86
; %bb.85:
	ld	a, -1
	.local	.LBB18_86
.LBB18_86:
	bit	0, a
	ld	a, 0
	ld	e, a
	jr	z, .LBB18_90
; %bb.87:
	ld.sis	de, 18
	ld	bc, -135
	lea	iy, ix + 0
	add	iy, bc
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	or	a, a
	sbc.sis	hl, de
	ld	e, a
	jr	nz, .LBB18_90
; %bb.88:
	ld	a, (_live_report_handle)
	ld	l, a
	push	hl
	call	_ti_Close
	pop	hl
	xor	a, a
	ld	(_live_report_handle), a
	sbc	hl, hl
	ld	(_live_report), hl
	ld	hl, _.str.25
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.25
	push	hl
	ld	hl, _.str.2
	push	hl
	call	_ti_Rename
	pop	hl
	pop	hl
	or	a, a
	ld	a, 1
	ld	e, a
	jr	z, .LBB18_90
; %bb.89:
	ld	e, 0
	.local	.LBB18_90
.LBB18_90:
	ld	a, (_live_report_handle)
	ld	l, a
	bit	0, e
	ld	(ix - 127), e
	jr	nz, .LBB18_93
; %bb.91:
	ld	a, l
	or	a, a
	jr	z, .LBB18_93
; %bb.92:
	push	hl
	call	_ti_Close
	pop	hl
	xor	a, a
	ld	(_live_report_handle), a
	ld	hl, _.str.2
	push	hl
	call	_ti_Delete
	pop	hl
	jr	.LBB18_97
	.local	.LBB18_93
.LBB18_93:
	bit	0, e
	jr	z, .LBB18_97
; %bb.94:
	ld	hl, _.str.26
	push	hl
	ld	hl, _.str.25
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB18_97
; %bb.95:
	push	de
	ld	hl, 1
	push	hl
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	call	_ti_SetArchiveStatus
	ld	(ix - 118), hl
	pop	hl
	pop	hl
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 118)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB18_97
; %bb.96:
	ld	hl, _.str.34
	ld	de, -141
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	.local	.LBB18_97
.LBB18_97:
	ld	iy, -917456
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, -65
	call	__sand
	ld	(iy), l
	ld	(iy + 1), h
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 34)
	pop	ix
	ld	(-917472), hl
	ld	de, -163
	lea	hl, ix + 0
	add	hl, de
	ld	a, (hl)                         ; 1-byte Folded Reload
	ld	(-917469), a
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 31)
	ld	h, (ix - 30)
	pop	ix
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 124)
	lea	iy, iy + 5
	ld	(ix - 100), 0
	ld	e, -10
	ld	l, (ix - 115)
	ld	h, (ix - 114)
	.local	.LBB18_98
.LBB18_98:                              ; =>This Inner Loop Header: Depth=1
	ld	(ix - 115), l
	ld	(ix - 114), h
	ld.sis	bc, 10
	call	__sdivu
	ld	(ix - 118), l
	ld	(ix - 117), h
	ld	d, l
	ld	l, e
	ld	h, d
	mlt	hl
	ld	c, (ix - 115)
	ld	b, (ix - 114)
                                        ; kill: def $c killed $c killed $bc
	ld	a, l
	add	a, c
	ld	l, a
	ld	c, 48
	ld	a, l
	or	a, c
	ld	l, a
	ld	(iy - 1), l
	dec	iy
	ld	l, (ix - 115)
	ld	h, (ix - 114)
	ld.sis	bc, 10
	or	a, a
	sbc.sis	hl, bc
	ld	l, (ix - 118)
	ld	h, (ix - 117)
	jp	nc, .LBB18_98
; %bb.99:
	ld	(ix - 118), iy
	ld	l, 1
	ld	a, (ix - 127)
	xor	a, l
	ld	l, a
	ld	(ix - 115), l
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
	bit	0, (ix - 115)                   ; 1-byte Folded Reload
	ld	hl, _.str.28
	jr	nz, .LBB18_101
; %bb.100:
	ld	hl, _.str.27
	.local	.LBB18_101
.LBB18_101:
	push	hl
	call	_os_PutStrFull
	pop	hl
	bit	0, (ix - 115)                   ; 1-byte Folded Reload
	jp	nz, .LBB18_105
; %bb.102:
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 2
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.29
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
	ld	hl, _.str.30
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	hl, (ix - 118)
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
	ld	hl, _.str.31
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
	ld	hl, _.str.32
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	(ix - 79), 0
	ld	de, 7
	ld	a, 38
	ld	bc, 469252
	.local	.LBB18_103
.LBB18_103:                             ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	push	bc
	pop	iy
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, _live_put_hex32.digits
	add	hl, bc
	ld	c, (hl)
	ld	hl, (ix - 121)
	add	hl, de
	ld	(hl), c
	lea	bc, iy + 0
	ld	l, 4
	call	__lshru
	dec	de
	push	de
	pop	hl
	push	de
	pop	iy
	ld	de, -1
	or	a, a
	sbc	hl, de
	lea	de, iy + 0
	jr	nz, .LBB18_103
; %bb.104:
	ld	hl, (ix - 121)
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 7
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.33
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
	ld	de, -141
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB18_105
.LBB18_105:
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 9
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.4
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB18_106
.LBB18_106:                             ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB18_106
	.local	.LBB18_107
.LBB18_107:                             ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB18_107
; %bb.108:
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 115)                   ; 1-byte Folded Reload
	jp	.LBB18_10
	.local	.LBB18_109
.LBB18_109:
	ld	de, -193
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	xor	a, a
	ld	(_live_game+8), a
	ld	bc, 9
	ld	de, (ix - 118)
	ld	hl, _live_game+8
	ldir
	ld	hl, 384
	ld	(_live_game), hl
	ld	hl, 640
	ld	(_live_game+3), hl
	ld.sis	hl, 8192
	ld	iy, _live_game+6
	ld	(iy), l
	ld	(iy + 1), h
	ld	(ix - 105), a
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	ld	(ix - 103), c
	ld	(ix - 102), b
	ld	(ix - 101), c
	ld	(ix - 100), b
	ld	iy, 971
	ld	de, 0
	ex	de, hl
	lea	de, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 53
	ld	(iy + 0), c
	ld	(iy + 1), b
	ld	iy, (ix - 121)
	ld	bc, _live_game
	.local	.LBB18_110
.LBB18_110:                             ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB18_117 Depth 2
	ld	(ix - 118), hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB18_131
; %bb.111:                              ;   in Loop: Header=BB18_110 Depth=1
	lea	de, iy + 0
	push	bc
	pop	hl
	ld	bc, 18
	ldir
	pea	ix - 8
	pea	ix - 7
	pea	ix - 15
	pea	ix - 105
	call	_live_controller_next
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB18_138
; %bb.112:                              ;   in Loop: Header=BB18_110 Depth=1
	ld	a, (ix - 15)
	ld	l, (ix - 7)
	ld	de, 30
	push	de
	ld	de, 1
	push	de
	dec	de
	push	de
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	l, a
	push	hl
	ld	hl, _live_game
	push	hl
	call	_game_update
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 121)
	push	hl
	call	_live_crossed_portal
	ld	de, -144
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	l, a
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	pop	hl
	ld	a, (ix - 8)
	ld	hl, (_live_report)
	ld	de, -184
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 84
	call	__imulu
	ex	de, hl
	ld	bc, -184
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	bc, -199
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	add	iy, de
	ld	l, (iy + 102)
	ld	de, 0
	ld	e, l
	ld	c, (iy + 103)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	c, 8
	call	__ishl
	add	hl, de
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	l, a
	push	hl
	ld	hl, (ix - 118)
	push	hl
	call	_live_section_ends
	ld	de, -196
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	pop	hl
	pop	hl
	ld	hl, (ix - 118)
	ld	bc, 24
	call	__imulu
	ex	de, hl
	ld	bc, -184
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	push	ix
	lea	ix, ix - 128
	push	hl
	ld	l, (ix - 53)
	ld	h, (ix - 52)
	ex	(sp), hl
	pop	iy
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 16)
	ld	b, (ix - 15)
	pop	ix
	add.sis	iy, bc
	ld	de, 1628
	add	hl, de
	ld	a, (hl)
	ld	l, 1
	and	a, l
	ld	l, a
	cp	a, c
	jp	nz, .LBB18_138
; %bb.113:                              ;   in Loop: Header=BB18_110 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 62)
	pop	ix
	ld	de, (ix - 118)
	or	a, a
	sbc	hl, de
	ld	de, -181
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	push	de
	ld	e, iyl
	ld	d, iyh
	ld	(hl), e
	inc	hl
	ld	(hl), d
	dec	hl
	pop	de
	jr	z, .LBB18_115
; %bb.114:                              ;   in Loop: Header=BB18_110 Depth=1
	ld	de, -196
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	or	a, a
	jp	z, .LBB18_129
	.local	.LBB18_115
.LBB18_115:                             ;   in Loop: Header=BB18_110 Depth=1
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	bc, -147
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	hl, _render_benchmark
	ld	bc, 65
	ldir
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, (ix - 118)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB18_119
; %bb.116:                              ;   in Loop: Header=BB18_110 Depth=1
	call	_game_render_benchmark_begin
	ld	hl, _live_game
	push	hl
	call	_game_render
	pop	hl
	call	_game_render_benchmark_end
	ld	hl, (_live_report)
	push	hl
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 71)
	pop	ix
	add	iy, de
	ld	bc, (ix - 118)
	ld	(iy + 102), c
	ld	a, b
	ld	(iy + 103), a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 62), iy
	pop	ix
	lea	bc, iy + 122
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 56
	ld	(iy + 0), bc
	add	hl, de
	ld	de, -205
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	bc, 0
	ld	de, -28
	.local	.LBB18_117
.LBB18_117:                             ;   Parent Loop BB18_110 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB18_120
; %bb.118:                              ;   in Loop: Header=BB18_117 Depth=2
	ld	hl, _render_benchmark+28
	push	hl
	pop	iy
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 74), bc
	pop	ix
	ld	bc, (iy)
	ld	a, (iy + 3)
	ld	l, c
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 56)
	pop	ix
	ld	(iy - 2), l
	ld	l, b
	ld	(iy - 1), l
	push	ix
	lea	ix, ix - 128
	ld	(ix - 56), iy
	pop	ix
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy), a
	ld	bc, -205
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	bc, -208
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	ld	bc, -202
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	add	iy, de
	ld	bc, -214
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	bc, 142
	add	iy, bc
	ld	bc, -211
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), iy
	ld	iy, _render_benchmark+28
	add	iy, de
	ld	bc, (iy)
	ld	a, c
	ld	de, -211
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	(hl), a
	ld	a, b
	ld	bc, 143
	ld	de, -214
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	(hl), a
	ld	de, -208
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 4
	add	hl, de
	ld	de, -208
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -202
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 2
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 56)
	pop	ix
	lea	iy, iy + 3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 56), iy
	pop	ix
	push	hl
	pop	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 80
	ld	de, (iy + 0)
	jp	.LBB18_117
	.local	.LBB18_119
.LBB18_119:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	hl, _live_game
	push	hl
	call	_game_render
	ld	bc, _live_game
	pop	hl
	jp	.LBB18_125
	.local	.LBB18_120
.LBB18_120:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	push	bc
	pop	iy
	ld	de, 160
	add	iy, de
	ld	hl, _render_benchmark+52
	ld	hl, (hl)
	ld	a, l
	ld	(iy), a
	ld	a, h
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	(iy), a
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	hl, _render_benchmark+54
	ld	hl, (hl)
	ld	a, l
	ld	(iy), a
	ld	a, h
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	(iy), a
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	hl, _render_benchmark+56
	ld	hl, (hl)
	ld	a, l
	ld	(iy), a
	ld	a, h
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	(iy), a
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	hl, _render_benchmark+48
	ld	hl, (hl)
	ld	a, l
	ld	(iy), a
	ld	a, h
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	(iy), a
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	hl, _render_benchmark+50
	ld	hl, (hl)
	ld	a, l
	ld	(iy), a
	ld	a, h
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	(iy), a
	push	bc
	pop	iy
	inc	de
	add	iy, de
	ld	hl, (_render_benchmark+62)
	ld	a, (_render_benchmark+65)
	ld	e, a
	ld	bc, 65535
	xor	a, a
	call	__lcmpu
	jr	c, .LBB18_122
; %bb.121:                              ;   in Loop: Header=BB18_110 Depth=1
	push	bc
	pop	hl
	.local	.LBB18_122
.LBB18_122:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	a, l
	ld	(iy), a
	ld	a, h
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	pop	iy
	ld	de, 171
	add	iy, de
	ld	(iy), a
	push	hl
	pop	iy
	inc	de
	add	iy, de
	ld	hl, (_render_benchmark+58)
	ld	a, (_render_benchmark+61)
	ld	e, a
	xor	a, a
	call	__lcmpu
	jr	c, .LBB18_124
; %bb.123:                              ;   in Loop: Header=BB18_110 Depth=1
	ld	hl, 65535
	.local	.LBB18_124
.LBB18_124:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	a, l
	ld	(iy), a
	ld	a, h
	ld	de, 173
	ld	bc, -190
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	(hl), a
	ld	de, -135
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	inc.sis	hl
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	bc, _live_game
	.local	.LBB18_125
.LBB18_125:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	de, 971
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 68
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	or	a, a
	jr	nz, .LBB18_127
; %bb.126:                              ;   in Loop: Header=BB18_110 Depth=1
	ld	iy, (ix - 121)
	jp	.LBB18_130
	.local	.LBB18_127
.LBB18_127:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	hl, (_live_report)
	ld	bc, -199
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, -184
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	call	_live_game_hash
	ld	bc, -190
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -196
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	ld	de, -184
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	push	bc
	pop	hl
	ld	de, 174
	add	hl, de
	ld	a, (hl)
	ld	de, -144
	lea	iy, ix + 0
	add	iy, de
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	(ix - 112), h
	ld	iy, (ix - 114)
	ex	de, hl
	ld	iyh, d
	ex	de, hl
	ld	iyl, a
	or	a, a
	sbc	hl, hl
	ld	d, l
	push	bc
	pop	hl
	ld	bc, 175
	add	hl, bc
	ld	a, (hl)
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 16)
	ld	h, (ix - 15)
	pop	ix
	ld	(ix - 111), h
	ld	bc, (ix - 113)
	ld	b, h
	ld	c, a
	ld	a, d
	ld	l, 8
	call	__lshl
	push	bc
	pop	hl
	ld	e, a
	lea	bc, iy + 0
	ld	a, d
	call	__ladd
	ld	bc, -199
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -184
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	bc, 176
	add	hl, bc
	ld	a, (hl)
	ld	bc, -144
	lea	hl, ix + 0
	add	hl, bc
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	ld	iyl, e
	ld	iyh, d
	pop	de
	push	af
	ld	a, iyh
	ld	(ix - 110), a
	pop	af
	ld	bc, (ix - 112)
	ld	b, iyh
	ld	c, a
	ld	a, d
	ld	l, 16
	call	__lshl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 71)
	pop	ix
	call	__ladd
	push	ix
	lea	ix, ix - 128
	ld	(ix - 71), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 56)
	pop	ix
	ld	bc, 177
	add	hl, bc
	ld	a, (hl)
	push	af
	ld	a, iyh
	ld	(ix - 109), a
	pop	af
	ld	bc, (ix - 111)
	ld	b, iyh
	ld	c, a
	ld	a, d
	ld	l, 24
	call	__lshl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 71
	ld	hl, (iy + 0)
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 68
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmpu
	jp	nz, .LBB18_138
; %bb.128:                              ;   in Loop: Header=BB18_110 Depth=1
	ld	de, -184
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, 156
	add	hl, de
	ld	de, -190
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	hl, (-1900524)
	ld	de, 76800
	push	de
	push	hl
	ld	hl, -127
	push	hl
	ld	hl, 1875397
	push	hl
	call	_live_hash_bytes
	push	hl
	pop	iy
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, iyl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 62)
	pop	ix
	ld	(hl), a
	ld	a, iyh
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 56)
	pop	ix
	ld	bc, 157
	add	hl, bc
	ld	(hl), a
	lea	bc, iy + 0
	ld	a, e
	ld	l, 16
	call	__lshru
	ld	a, c
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 56)
	pop	ix
	ld	bc, 158
	add	hl, bc
	ld	(hl), a
	lea	bc, iy + 0
	ld	a, e
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	de, 159
	ld	bc, -184
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	(hl), a
	.local	.LBB18_129
.LBB18_129:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	iy, (ix - 121)
	ld	bc, _live_game
	ld	de, 971
	.local	.LBB18_130
.LBB18_130:                             ;   in Loop: Header=BB18_110 Depth=1
	ld	hl, (ix - 118)
	inc	hl
	jp	.LBB18_110
	.local	.LBB18_131
.LBB18_131:
	ld	iy, (_live_report)
	ld	de, 1584
	lea	hl, iy + 0
	add	hl, de
	ld	(ix - 118), hl
	inc	de
	lea	hl, iy + 0
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 10), hl
	pop	ix
	inc	de
	lea	hl, iy + 0
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 19), hl
	pop	ix
	inc	de
	add	iy, de
	ld	a, (ix - 105)
	ld	hl, (ix - 101)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 971
	or	a, a
	sbc.sis	hl, de
	ld	e, -1
	ld	c, 0
	ld	l, e
	jr	z, .LBB18_133
; %bb.132:
	ld	l, c
	.local	.LBB18_133
.LBB18_133:
	cp	a, 21
	ld	a, e
	jr	z, .LBB18_135
; %bb.134:
	ld	a, c
	.local	.LBB18_135
.LBB18_135:
	and	a, l
	ld	d, a
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 53)
	ld	h, (ix - 52)
	pop	ix
	ld.sis	bc, 3
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB18_137
; %bb.136:
	ld	e, 0
	.local	.LBB18_137
.LBB18_137:
	ld	hl, (ix - 118)
	ld	a, (hl)
	ld	bc, -181
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 10)
	pop	ix
	ld	a, (hl)
	ld	bc, -184
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 19)
	pop	ix
	ld	a, (hl)
	ld	bc, -190
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a
	ld	a, (iy)
	ld	bc, -196
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), a
	ld	a, d
	and	a, e
	ld	l, a
	ld	de, -138
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	bc, 7
	ld	hl, _.str.24
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 59
	ld	de, (iy + 0)
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 5)
	jr	.LBB18_139
	.local	.LBB18_138
.LBB18_138:
	ld	bc, 7
	ld	hl, _.str.24
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 59
	ld	de, (iy + 0)
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 5)
	pop	ix
	xor	a, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 53), a                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 56), a                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 62), a                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 68), a                    ; 1-byte Folded Spill
	.local	.LBB18_139
.LBB18_139:
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 83), e                    ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	push	af
	ld	a, iyl
	ld	(ix - 59), a                    ; 1-byte Folded Spill
	pop	af
	pop	ix
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 65
	ld	de, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 65
	ld	(iy + 0), e                     ; 1-byte Folded Spill
	jp	.LBB18_70
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_live_benchmark_run, .Lfunc_end18-_live_benchmark_run
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
	ld	hl, _.str.3
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
	.local	.LBB19_1
.LBB19_1:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB19_1
	.local	.LBB19_2
.LBB19_2:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB19_2
; %bb.3:
	pop	ix
	ret
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_live_show_failure, .Lfunc_end19-_live_show_failure
                                        ; -- End function
	.section	.text._live_controller_next,"ax",@progbits
	.type	_live_controller_next,@function ; -- Begin function live_controller_next
_live_controller_next:                  ; @live_controller_next
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	a, (hl)
	cp	a, 21
	jr	c, .LBB20_2
; %bb.1:
	xor	a, a
	jp	.LBB20_8
	.local	.LBB20_2
.LBB20_2:
	ld	iy, _live_route
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 6
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	a, (iy + 2)
	ld	hl, (ix + 9)
	ld	(hl), a
	ld	a, (iy + 3)
	ld	hl, (ix + 12)
	ld	(hl), a
	lea	de, iy + 0
	ld	a, (iy + 5)
	ld	l, 1
	and	a, l
	ld	l, a
	bit	0, l
	jr	z, .LBB20_5
; %bb.3:
	ld	iy, (ix + 6)
	ld	bc, (iy + 2)
	ld	l, c
	ld	h, b
	ld.sis	bc, 1
	call	__sand
	bit	0, l
	jr	z, .LBB20_5
; %bb.4:
	ld	hl, (ix + 12)
	ld	(hl), 0
	.local	.LBB20_5
.LBB20_5:
	push	de
	pop	iy
	ld	a, (iy + 4)
	ld	hl, (ix + 15)
	ld	(hl), a
	ld	hl, (ix + 6)
	push	hl
	pop	bc
	push	bc
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
	ld	bc, (iy)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB20_7
; %bb.6:
	ld.sis	hl, 0
	ld	bc, (ix + 6)
	push	bc
	pop	iy
	inc	(iy)
	ld	(iy + 2), l
	ld	(iy + 3), h
	.local	.LBB20_7
.LBB20_7:
	ld	a, 1
	.local	.LBB20_8
.LBB20_8:
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_live_controller_next, .Lfunc_end20-_live_controller_next
                                        ; -- End function
	.section	.text._live_crossed_portal,"ax",@progbits
	.type	_live_crossed_portal,@function  ; -- Begin function live_crossed_portal
_live_crossed_portal:                   ; @live_crossed_portal
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	hl, (_live_game)
	ld	de, (iy)
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	call	__ixor
	ld	de, 65
	or	a, a
	sbc	hl, de
	jr	c, .LBB21_2
; %bb.1:
	ld	a, 1
	jp	.LBB21_3
	.local	.LBB21_2
.LBB21_2:
	ld	hl, (_live_game+3)
	ld	iy, (ix + 6)
	ld	bc, (iy + 3)
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
	or	a, a
	sbc	hl, de
                                        ; kill: def $a killed $a
	sbc	a, a
	inc	a
	.local	.LBB21_3
.LBB21_3:
	pop	ix
	ret
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_live_crossed_portal, .Lfunc_end21-_live_crossed_portal
                                        ; -- End function
	.section	.text._live_section_ends,"ax",@progbits
	.type	_live_section_ends,@function    ; -- Begin function live_section_ends
_live_section_ends:                     ; @live_section_ends
; %bb.0:
	ld	hl, -9
	call	__frameset
	ld	a, (ix + 9)
	ld	bc, 84
	ld	iy, (_live_report)
	ld	de, 0
	ld	e, a
	push	de
	pop	hl
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 3), iy
	ld	e, (iy + 98)
	ld	(ix - 6), de
	ld	a, (iy + 99)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, 8
	call	__ishl
	ld	de, (ix - 6)
	add	hl, de
	ld	(ix - 6), hl
	ld	iy, (ix - 3)
	ld	a, (iy + 100)
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	ld	(ix - 9), hl
	ld	iy, (ix - 3)
	ld	a, (iy + 101)
	ld	e, a
	push	de
	pop	hl
	call	__ishl
	ld	bc, (ix - 9)
	add	hl, bc
	ld	bc, (ix + 6)
	ld	e, c
	ld	d, b
	inc	de
	ld	bc, (ix - 6)
	add	hl, bc
	push	hl
	pop	bc
	ex	de, hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB22_2
; %bb.1:
	ld	a, 0
	jr	.LBB22_3
	.local	.LBB22_2
.LBB22_2:
	ld	a, 1
	.local	.LBB22_3
.LBB22_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_live_section_ends, .Lfunc_end22-_live_section_ends
                                        ; -- End function
	.section	.text._live_game_hash,"ax",@progbits
	.type	_live_game_hash,@function       ; -- Begin function live_game_hash
_live_game_hash:                        ; @live_game_hash
; %bb.0:
	ld	hl, -17
	call	__frameset
	ld	iy, _live_game+6
	ld	de, 17
	ld	hl, (_live_game)
	ld	a, l
	ld	(ix - 17), a
	ld	a, h
	ld	(ix - 16), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(ix - 15), a
	ld	hl, (_live_game+3)
	ld	a, l
	ld	(ix - 14), a
	ld	a, h
	ld	(ix - 13), a
	call	__ishru
	ld	a, l
	ld	(ix - 12), a
	ld	hl, (iy)
	ld	a, l
	ld	(ix - 11), a
	ld	a, h
	ld	(ix - 10), a
	ld	hl, (_live_game+8)
	ld	a, (_live_game+11)
	ld	(ix - 9), hl
	ld	(ix - 6), a
	ld	hl, (_live_game+12)
	ld	a, (_live_game+15)
	ld	(ix - 5), hl
	ld	(ix - 2), a
	ld	a, (_live_game+16)
	ld	(ix - 1), a
	push	de
	pea	ix - 17
	ld	hl, -127
	push	hl
	ld	hl, 1875397
	push	hl
	call	_live_hash_bytes
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_live_game_hash, .Lfunc_end23-_live_game_hash
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
	.local	.LBB24_1
.LBB24_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB24_3
; %bb.2:                                ;   in Loop: Header=BB24_1 Depth=1
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
	jr	.LBB24_1
	.local	.LBB24_3
.LBB24_3:
	ld	hl, (ix - 4)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_live_hash_bytes, .Lfunc_end24-_live_hash_bytes
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	jp	_live_benchmark_run
	.local	.Lfunc_end25
.Lfunc_end25:
	.size	_main, .Lfunc_end25-_main
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
	.zero	66

	.section	.rodata._render_wall_map,"a",@progbits
	.balign	1
	.globl	_render_wall_map
_render_wall_map:
	.ascii	"\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\000\000\000\000\000\000\000\000\001\001\001\001\000\000\000\000\000\000\001\000\000\000\000\000\000\001\001\001\000\000\000\000\000\000\000\000\000\000\001\000\000\001\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\001\001\001\001\001\001\001\001\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\001\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\001\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\001\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\000\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\001\000\000\000\000\000\000\000\000\001\001\001\000\000\000\000\001\000\000\000\000\000\000\000\000\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001\001"

	.section	.rodata._render_builtin_portal_by_tile,"a",@progbits
	.balign	1
	.globl	_render_builtin_portal_by_tile
_render_builtin_portal_by_tile:
	.ascii	"\000\000\000\n\000\005\000\006\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\t\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\001\000\000\000\000\002"
	.zero	42

	.section	.rodata._render_reciprocal_delta,"a",@progbits
	.balign	2
	.globl	_render_reciprocal_delta
_render_reciprocal_delta:
	dw	0                               ; 0x0
	dw	0                               ; 0x0
	dw	32768                           ; 0x8000
	dw	21845                           ; 0x5555
	dw	16384                           ; 0x4000
	dw	13107                           ; 0x3333
	dw	10922                           ; 0x2aaa
	dw	9362                            ; 0x2492
	dw	8192                            ; 0x2000
	dw	7281                            ; 0x1c71
	dw	6553                            ; 0x1999
	dw	5957                            ; 0x1745
	dw	5461                            ; 0x1555
	dw	5041                            ; 0x13b1
	dw	4681                            ; 0x1249
	dw	4369                            ; 0x1111
	dw	4096                            ; 0x1000
	dw	3855                            ; 0xf0f
	dw	3640                            ; 0xe38
	dw	3449                            ; 0xd79
	dw	3276                            ; 0xccc
	dw	3120                            ; 0xc30
	dw	2978                            ; 0xba2
	dw	2849                            ; 0xb21
	dw	2730                            ; 0xaaa
	dw	2621                            ; 0xa3d
	dw	2520                            ; 0x9d8
	dw	2427                            ; 0x97b
	dw	2340                            ; 0x924
	dw	2259                            ; 0x8d3
	dw	2184                            ; 0x888
	dw	2114                            ; 0x842
	dw	2048                            ; 0x800
	dw	1985                            ; 0x7c1
	dw	1927                            ; 0x787
	dw	1872                            ; 0x750
	dw	1820                            ; 0x71c
	dw	1771                            ; 0x6eb
	dw	1724                            ; 0x6bc
	dw	1680                            ; 0x690
	dw	1638                            ; 0x666
	dw	1598                            ; 0x63e
	dw	1560                            ; 0x618
	dw	1524                            ; 0x5f4
	dw	1489                            ; 0x5d1
	dw	1456                            ; 0x5b0
	dw	1424                            ; 0x590
	dw	1394                            ; 0x572
	dw	1365                            ; 0x555
	dw	1337                            ; 0x539
	dw	1310                            ; 0x51e
	dw	1285                            ; 0x505
	dw	1260                            ; 0x4ec
	dw	1236                            ; 0x4d4
	dw	1213                            ; 0x4bd
	dw	1191                            ; 0x4a7
	dw	1170                            ; 0x492
	dw	1149                            ; 0x47d
	dw	1129                            ; 0x469
	dw	1110                            ; 0x456
	dw	1092                            ; 0x444
	dw	1074                            ; 0x432
	dw	1057                            ; 0x421
	dw	1040                            ; 0x410
	dw	1024                            ; 0x400
	dw	1008                            ; 0x3f0
	dw	992                             ; 0x3e0
	dw	978                             ; 0x3d2
	dw	963                             ; 0x3c3
	dw	949                             ; 0x3b5
	dw	936                             ; 0x3a8
	dw	923                             ; 0x39b
	dw	910                             ; 0x38e
	dw	897                             ; 0x381
	dw	885                             ; 0x375
	dw	873                             ; 0x369
	dw	862                             ; 0x35e
	dw	851                             ; 0x353
	dw	840                             ; 0x348
	dw	829                             ; 0x33d
	dw	819                             ; 0x333
	dw	809                             ; 0x329
	dw	799                             ; 0x31f
	dw	789                             ; 0x315
	dw	780                             ; 0x30c
	dw	771                             ; 0x303
	dw	762                             ; 0x2fa
	dw	753                             ; 0x2f1
	dw	744                             ; 0x2e8
	dw	736                             ; 0x2e0
	dw	728                             ; 0x2d8
	dw	720                             ; 0x2d0
	dw	712                             ; 0x2c8
	dw	704                             ; 0x2c0
	dw	697                             ; 0x2b9
	dw	689                             ; 0x2b1
	dw	682                             ; 0x2aa
	dw	675                             ; 0x2a3
	dw	668                             ; 0x29c
	dw	661                             ; 0x295
	dw	655                             ; 0x28f
	dw	648                             ; 0x288
	dw	642                             ; 0x282
	dw	636                             ; 0x27c
	dw	630                             ; 0x276
	dw	624                             ; 0x270
	dw	618                             ; 0x26a
	dw	612                             ; 0x264
	dw	606                             ; 0x25e
	dw	601                             ; 0x259
	dw	595                             ; 0x253
	dw	590                             ; 0x24e
	dw	585                             ; 0x249
	dw	579                             ; 0x243
	dw	574                             ; 0x23e
	dw	569                             ; 0x239
	dw	564                             ; 0x234
	dw	560                             ; 0x230
	dw	555                             ; 0x22b
	dw	550                             ; 0x226
	dw	546                             ; 0x222
	dw	541                             ; 0x21d
	dw	537                             ; 0x219
	dw	532                             ; 0x214
	dw	528                             ; 0x210
	dw	524                             ; 0x20c
	dw	520                             ; 0x208
	dw	516                             ; 0x204
	dw	512                             ; 0x200
	dw	508                             ; 0x1fc
	dw	504                             ; 0x1f8
	dw	500                             ; 0x1f4
	dw	496                             ; 0x1f0
	dw	492                             ; 0x1ec
	dw	489                             ; 0x1e9
	dw	485                             ; 0x1e5
	dw	481                             ; 0x1e1
	dw	478                             ; 0x1de
	dw	474                             ; 0x1da
	dw	471                             ; 0x1d7
	dw	468                             ; 0x1d4
	dw	464                             ; 0x1d0
	dw	461                             ; 0x1cd
	dw	458                             ; 0x1ca
	dw	455                             ; 0x1c7
	dw	451                             ; 0x1c3
	dw	448                             ; 0x1c0
	dw	445                             ; 0x1bd
	dw	442                             ; 0x1ba
	dw	439                             ; 0x1b7
	dw	436                             ; 0x1b4
	dw	434                             ; 0x1b2
	dw	431                             ; 0x1af
	dw	428                             ; 0x1ac
	dw	425                             ; 0x1a9
	dw	422                             ; 0x1a6
	dw	420                             ; 0x1a4
	dw	417                             ; 0x1a1
	dw	414                             ; 0x19e
	dw	412                             ; 0x19c
	dw	409                             ; 0x199
	dw	407                             ; 0x197
	dw	404                             ; 0x194
	dw	402                             ; 0x192
	dw	399                             ; 0x18f
	dw	397                             ; 0x18d
	dw	394                             ; 0x18a
	dw	392                             ; 0x188
	dw	390                             ; 0x186
	dw	387                             ; 0x183
	dw	385                             ; 0x181
	dw	383                             ; 0x17f
	dw	381                             ; 0x17d
	dw	378                             ; 0x17a
	dw	376                             ; 0x178
	dw	374                             ; 0x176
	dw	372                             ; 0x174
	dw	370                             ; 0x172
	dw	368                             ; 0x170
	dw	366                             ; 0x16e
	dw	364                             ; 0x16c
	dw	362                             ; 0x16a
	dw	360                             ; 0x168
	dw	358                             ; 0x166
	dw	356                             ; 0x164
	dw	354                             ; 0x162
	dw	352                             ; 0x160
	dw	350                             ; 0x15e
	dw	348                             ; 0x15c
	dw	346                             ; 0x15a
	dw	344                             ; 0x158
	dw	343                             ; 0x157
	dw	341                             ; 0x155
	dw	339                             ; 0x153
	dw	337                             ; 0x151
	dw	336                             ; 0x150
	dw	334                             ; 0x14e
	dw	332                             ; 0x14c
	dw	330                             ; 0x14a
	dw	329                             ; 0x149
	dw	327                             ; 0x147
	dw	326                             ; 0x146
	dw	324                             ; 0x144
	dw	322                             ; 0x142
	dw	321                             ; 0x141
	dw	319                             ; 0x13f
	dw	318                             ; 0x13e
	dw	316                             ; 0x13c
	dw	315                             ; 0x13b
	dw	313                             ; 0x139
	dw	312                             ; 0x138
	dw	310                             ; 0x136
	dw	309                             ; 0x135
	dw	307                             ; 0x133
	dw	306                             ; 0x132
	dw	304                             ; 0x130
	dw	303                             ; 0x12f
	dw	302                             ; 0x12e
	dw	300                             ; 0x12c
	dw	299                             ; 0x12b
	dw	297                             ; 0x129
	dw	296                             ; 0x128
	dw	295                             ; 0x127
	dw	293                             ; 0x125
	dw	292                             ; 0x124
	dw	291                             ; 0x123
	dw	289                             ; 0x121
	dw	288                             ; 0x120
	dw	287                             ; 0x11f
	dw	286                             ; 0x11e
	dw	284                             ; 0x11c
	dw	283                             ; 0x11b
	dw	282                             ; 0x11a
	dw	281                             ; 0x119
	dw	280                             ; 0x118
	dw	278                             ; 0x116
	dw	277                             ; 0x115
	dw	276                             ; 0x114
	dw	275                             ; 0x113
	dw	274                             ; 0x112
	dw	273                             ; 0x111
	dw	271                             ; 0x10f
	dw	270                             ; 0x10e
	dw	269                             ; 0x10d
	dw	268                             ; 0x10c
	dw	267                             ; 0x10b
	dw	266                             ; 0x10a
	dw	265                             ; 0x109
	dw	264                             ; 0x108
	dw	263                             ; 0x107
	dw	262                             ; 0x106
	dw	261                             ; 0x105
	dw	260                             ; 0x104
	dw	259                             ; 0x103
	dw	258                             ; 0x102
	dw	257                             ; 0x101
	dw	256                             ; 0x100
	dw	255                             ; 0xff
	dw	254                             ; 0xfe
	dw	253                             ; 0xfd
	dw	252                             ; 0xfc
	dw	251                             ; 0xfb
	dw	250                             ; 0xfa
	dw	249                             ; 0xf9
	dw	248                             ; 0xf8
	dw	247                             ; 0xf7
	dw	246                             ; 0xf6
	dw	245                             ; 0xf5
	dw	244                             ; 0xf4
	dw	243                             ; 0xf3
	dw	242                             ; 0xf2
	dw	241                             ; 0xf1
	dw	240                             ; 0xf0
	dw	240                             ; 0xf0
	dw	239                             ; 0xef
	dw	238                             ; 0xee
	dw	237                             ; 0xed
	dw	236                             ; 0xec
	dw	235                             ; 0xeb
	dw	234                             ; 0xea
	dw	234                             ; 0xea
	dw	233                             ; 0xe9
	dw	232                             ; 0xe8
	dw	231                             ; 0xe7
	dw	230                             ; 0xe6
	dw	229                             ; 0xe5
	dw	229                             ; 0xe5
	dw	228                             ; 0xe4
	dw	227                             ; 0xe3
	dw	226                             ; 0xe2
	dw	225                             ; 0xe1
	dw	225                             ; 0xe1
	dw	224                             ; 0xe0
	dw	223                             ; 0xdf
	dw	222                             ; 0xde
	dw	222                             ; 0xde
	dw	221                             ; 0xdd
	dw	220                             ; 0xdc
	dw	219                             ; 0xdb
	dw	219                             ; 0xdb
	dw	218                             ; 0xda
	dw	217                             ; 0xd9
	dw	217                             ; 0xd9
	dw	216                             ; 0xd8
	dw	215                             ; 0xd7
	dw	214                             ; 0xd6
	dw	214                             ; 0xd6
	dw	213                             ; 0xd5
	dw	212                             ; 0xd4
	dw	212                             ; 0xd4
	dw	211                             ; 0xd3
	dw	210                             ; 0xd2
	dw	210                             ; 0xd2
	dw	209                             ; 0xd1
	dw	208                             ; 0xd0
	dw	208                             ; 0xd0
	dw	207                             ; 0xcf
	dw	206                             ; 0xce
	dw	206                             ; 0xce
	dw	205                             ; 0xcd
	dw	204                             ; 0xcc
	dw	204                             ; 0xcc
	dw	203                             ; 0xcb
	dw	202                             ; 0xca
	dw	202                             ; 0xca
	dw	201                             ; 0xc9
	dw	201                             ; 0xc9
	dw	200                             ; 0xc8
	dw	199                             ; 0xc7
	dw	199                             ; 0xc7
	dw	198                             ; 0xc6
	dw	197                             ; 0xc5
	dw	197                             ; 0xc5
	dw	196                             ; 0xc4
	dw	196                             ; 0xc4
	dw	195                             ; 0xc3
	dw	195                             ; 0xc3
	dw	194                             ; 0xc2
	dw	193                             ; 0xc1
	dw	193                             ; 0xc1
	dw	192                             ; 0xc0
	dw	192                             ; 0xc0
	dw	191                             ; 0xbf
	dw	191                             ; 0xbf
	dw	190                             ; 0xbe
	dw	189                             ; 0xbd
	dw	189                             ; 0xbd
	dw	188                             ; 0xbc
	dw	188                             ; 0xbc
	dw	187                             ; 0xbb
	dw	187                             ; 0xbb
	dw	186                             ; 0xba
	dw	186                             ; 0xba
	dw	185                             ; 0xb9
	dw	185                             ; 0xb9
	dw	184                             ; 0xb8
	dw	184                             ; 0xb8
	dw	183                             ; 0xb7
	dw	183                             ; 0xb7
	dw	182                             ; 0xb6
	dw	182                             ; 0xb6
	dw	181                             ; 0xb5
	dw	181                             ; 0xb5
	dw	180                             ; 0xb4
	dw	180                             ; 0xb4
	dw	179                             ; 0xb3
	dw	179                             ; 0xb3
	dw	178                             ; 0xb2
	dw	178                             ; 0xb2
	dw	177                             ; 0xb1
	dw	177                             ; 0xb1
	dw	176                             ; 0xb0
	dw	176                             ; 0xb0
	dw	175                             ; 0xaf
	dw	175                             ; 0xaf
	dw	174                             ; 0xae
	dw	174                             ; 0xae
	dw	173                             ; 0xad
	dw	173                             ; 0xad
	dw	172                             ; 0xac
	dw	172                             ; 0xac
	dw	172                             ; 0xac
	dw	171                             ; 0xab
	dw	171                             ; 0xab
	dw	170                             ; 0xaa
	dw	170                             ; 0xaa
	dw	169                             ; 0xa9
	dw	169                             ; 0xa9
	dw	168                             ; 0xa8
	dw	168                             ; 0xa8
	dw	168                             ; 0xa8
	dw	167                             ; 0xa7
	dw	167                             ; 0xa7
	dw	166                             ; 0xa6
	dw	166                             ; 0xa6
	dw	165                             ; 0xa5
	dw	165                             ; 0xa5
	dw	165                             ; 0xa5
	dw	164                             ; 0xa4
	dw	164                             ; 0xa4
	dw	163                             ; 0xa3
	dw	163                             ; 0xa3
	dw	163                             ; 0xa3
	dw	162                             ; 0xa2
	dw	162                             ; 0xa2
	dw	161                             ; 0xa1
	dw	161                             ; 0xa1
	dw	161                             ; 0xa1
	dw	160                             ; 0xa0
	dw	160                             ; 0xa0
	dw	159                             ; 0x9f
	dw	159                             ; 0x9f
	dw	159                             ; 0x9f
	dw	158                             ; 0x9e
	dw	158                             ; 0x9e
	dw	157                             ; 0x9d
	dw	157                             ; 0x9d
	dw	157                             ; 0x9d
	dw	156                             ; 0x9c
	dw	156                             ; 0x9c
	dw	156                             ; 0x9c
	dw	155                             ; 0x9b
	dw	155                             ; 0x9b
	dw	154                             ; 0x9a
	dw	154                             ; 0x9a
	dw	154                             ; 0x9a

	.section	.rodata._render_builtin_portals,"a",@progbits
	.balign	1
	.globl	_render_builtin_portals
_render_builtin_portals:
	db	0                               ; 0x0
	db	13                              ; 0xd
	db	1                               ; 0x1
	db	5                               ; 0x5
	db	13                              ; 0xd
	db	0                               ; 0x0
	db	5                               ; 0x5
	db	13                              ; 0xd
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	13                              ; 0xd
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	4                               ; 0x4
	db	1                               ; 0x1
	db	5                               ; 0x5
	db	9                               ; 0x9
	db	0                               ; 0x0
	db	5                               ; 0x5
	db	9                               ; 0x9
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	4                               ; 0x4
	db	1                               ; 0x1
	db	5                               ; 0x5
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	7                               ; 0x7
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	7                               ; 0x7
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	5                               ; 0x5
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	14                              ; 0xe
	db	5                               ; 0x5
	db	0                               ; 0x0
	db	14                              ; 0xe
	db	6                               ; 0x6
	db	0                               ; 0x0
	db	14                              ; 0xe
	db	6                               ; 0x6
	db	0                               ; 0x0
	db	14                              ; 0xe
	db	5                               ; 0x5
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	2                               ; 0x2
	db	1                               ; 0x1
	db	3                               ; 0x3
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	3                               ; 0x3
	db	0                               ; 0x0
	db	3                               ; 0x3
	db	0                               ; 0x0
	db	2                               ; 0x2
	db	1                               ; 0x1

	.section	.rodata._game_graphics_init.shade_offsets,"a",@progbits
	.balign	1
	.local	_game_graphics_init.shade_offsets
_game_graphics_init.shade_offsets:
	.ascii	"\000\b\020\030"

	.section	.rodata._game_graphics_init.wall_palette_rgb,"a",@progbits
	.balign	1
	.local	_game_graphics_init.wall_palette_rgb
_game_graphics_init.wall_palette_rgb:
	.ascii	"@60"
	.ascii	"VA6"
	.ascii	"\200D-"
	.ascii	"\226N4"
	.ascii	"\252\\<"
	.ascii	"\276lF"
	.ascii	"\322}T"
	.ascii	"\354\226d"
	.ascii	"*16"
	.ascii	"7AF"
	.ascii	"HSX"
	.ascii	"Xdi"
	.ascii	"iw|"
	.ascii	"z\212\216"
	.ascii	"\227\251\253"
	.ascii	"\316\335\332"
	.ascii	"740"
	.ascii	"HE@"
	.ascii	"`]V"
	.ascii	"tpg"
	.ascii	"\210\204z"
	.ascii	"\236\231\216"
	.ascii	"\270\263\247"
	.ascii	"\332\325\311"
	.ascii	"\031\035#"
	.ascii	"(.6"
	.ascii	"6AN"
	.ascii	"DP\\"
	.ascii	"R`l"
	.ascii	"hw\200"
	.ascii	"\276\221#"
	.ascii	"\360\310A"

	.section	.rodata._direction_y,"a",@progbits
	.balign	2
	.local	_direction_y
_direction_y:
	dw	0                               ; 0x0
	dw	25                              ; 0x19
	dw	50                              ; 0x32
	dw	74                              ; 0x4a
	dw	98                              ; 0x62
	dw	121                             ; 0x79
	dw	142                             ; 0x8e
	dw	162                             ; 0xa2
	dw	181                             ; 0xb5
	dw	198                             ; 0xc6
	dw	213                             ; 0xd5
	dw	226                             ; 0xe2
	dw	237                             ; 0xed
	dw	245                             ; 0xf5
	dw	251                             ; 0xfb
	dw	255                             ; 0xff
	dw	256                             ; 0x100
	dw	255                             ; 0xff
	dw	251                             ; 0xfb
	dw	245                             ; 0xf5
	dw	237                             ; 0xed
	dw	226                             ; 0xe2
	dw	213                             ; 0xd5
	dw	198                             ; 0xc6
	dw	181                             ; 0xb5
	dw	162                             ; 0xa2
	dw	142                             ; 0x8e
	dw	121                             ; 0x79
	dw	98                              ; 0x62
	dw	74                              ; 0x4a
	dw	50                              ; 0x32
	dw	25                              ; 0x19
	dw	0                               ; 0x0
	dw	65511                           ; 0xffe7
	dw	65486                           ; 0xffce
	dw	65462                           ; 0xffb6
	dw	65438                           ; 0xff9e
	dw	65415                           ; 0xff87
	dw	65394                           ; 0xff72
	dw	65374                           ; 0xff5e
	dw	65355                           ; 0xff4b
	dw	65338                           ; 0xff3a
	dw	65323                           ; 0xff2b
	dw	65310                           ; 0xff1e
	dw	65299                           ; 0xff13
	dw	65291                           ; 0xff0b
	dw	65285                           ; 0xff05
	dw	65281                           ; 0xff01
	dw	65280                           ; 0xff00
	dw	65281                           ; 0xff01
	dw	65285                           ; 0xff05
	dw	65291                           ; 0xff0b
	dw	65299                           ; 0xff13
	dw	65310                           ; 0xff1e
	dw	65323                           ; 0xff2b
	dw	65338                           ; 0xff3a
	dw	65355                           ; 0xff4b
	dw	65374                           ; 0xff5e
	dw	65394                           ; 0xff72
	dw	65415                           ; 0xff87
	dw	65438                           ; 0xff9e
	dw	65462                           ; 0xffb6
	dw	65486                           ; 0xffce
	dw	65511                           ; 0xffe7

	.section	.bss._render_direction_y_by_angle,"aw",@nobits
	.balign	2
	.local	_render_direction_y_by_angle
_render_direction_y_by_angle:
	.zero	32768

	.section	.bss._render_fov_by_direction,"aw",@nobits
	.balign	2
	.local	_render_fov_by_direction
_render_fov_by_direction:
	.zero	1026

	.section	.bss._render_screen_rows,"aw",@nobits
	.balign	1
	.globl	_render_screen_rows
_render_screen_rows:
	.zero	960

	.section	.bss._render_wall_scale_profiles,"aw",@nobits
	.balign	2
	.local	_render_wall_scale_profiles
_render_wall_scale_profiles:
	.zero	2048

	.section	.bss._render_wall_texture_boundaries,"aw",@nobits
	.balign	1
	.globl	_render_wall_texture_boundaries
_render_wall_texture_boundaries:
	.zero	2304

	.section	.bss._render_wall_scale_profile_index,"aw",@nobits
	.balign	1
	.local	_render_wall_scale_profile_index
_render_wall_scale_profile_index:
	.zero	8192

	.section	.bss._render_grid_near_projection,"aw",@nobits
	.balign	2
	.globl	_render_grid_near_projection
_render_grid_near_projection:
	.zero	10

	.section	.bss._grid_far_projection,"aw",@nobits
	.balign	2
	.globl	_grid_far_projection
_grid_far_projection:
	.zero	10

	.section	.bss._render_portal_profile_by_u,"aw",@nobits
	.balign	1
	.globl	_render_portal_profile_by_u
_render_portal_profile_by_u:
	.zero	256

	.section	.bss._render_wall_texture_runs,"aw",@nobits
	.balign	1
	.globl	_render_wall_texture_runs
_render_wall_texture_runs:
	.zero	1025

	.section	.bss._render_wall_colors,"aw",@nobits
	.balign	1
	.globl	_render_wall_colors
_render_wall_colors:
	.zero	512

	.section	.bss._render_profile,"aw",@nobits
	.balign	2
	.local	_render_profile
_render_profile:
	.zero	16

	.section	.rodata._map_row_offsets,"a",@progbits
	.balign	1
	.local	_map_row_offsets
_map_row_offsets:
	.ascii	"\000\020 0@P`p\200\220\240\260\300\320\340\360"

	.section	.bss._render_scratch,"aw",@nobits
	.balign	1
	.local	_render_scratch
_render_scratch:
	.zero	16

	.section	.bss._grid_segments,"aw",@nobits
	.balign	2
	.local	_grid_segments
_grid_segments:
	.zero	128

	.section	.rodata._portal_visit_bits,"a",@progbits
	.balign	1
	.local	_portal_visit_bits
_portal_visit_bits:
	.ascii	"\001\002\004\b\020 @\200"

	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"Route table invalid."

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"No room for P3DLIVE."

	.section	.bss._live_report_handle,"aw",@nobits
	.balign	1
	.local	_live_report_handle
_live_report_handle:
	.zero	1

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"P3DLTMP"

	.section	.rodata._live_route,"a",@progbits
	.balign	2
	.local	_live_route
_live_route:
	dw	8                               ; 0x8
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	0                               ; 0x0
	db	0                               ; 0x0
	dw	20                              ; 0x14
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	0                               ; 0x0
	dw	80                              ; 0x50
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	2                               ; 0x2
	db	1                               ; 0x1
	dw	40                              ; 0x28
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	3                               ; 0x3
	db	0                               ; 0x0
	dw	28                              ; 0x1c
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	4                               ; 0x4
	db	0                               ; 0x0
	dw	40                              ; 0x28
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	5                               ; 0x5
	db	0                               ; 0x0
	dw	36                              ; 0x24
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	5                               ; 0x5
	db	0                               ; 0x0
	dw	40                              ; 0x28
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	6                               ; 0x6
	db	0                               ; 0x0
	dw	20                              ; 0x14
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	7                               ; 0x7
	db	0                               ; 0x0
	dw	80                              ; 0x50
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	8                               ; 0x8
	db	0                               ; 0x0
	dw	20                              ; 0x14
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	9                               ; 0x9
	db	0                               ; 0x0
	dw	120                             ; 0x78
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	10                              ; 0xa
	db	0                               ; 0x0
	dw	40                              ; 0x28
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	11                              ; 0xb
	db	0                               ; 0x0
	dw	24                              ; 0x18
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	11                              ; 0xb
	db	0                               ; 0x0
	dw	40                              ; 0x28
	db	0                               ; 0x0
	db	255                             ; 0xff
	db	11                              ; 0xb
	db	0                               ; 0x0
	dw	105                             ; 0x69
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	12                              ; 0xc
	db	0                               ; 0x0
	dw	20                              ; 0x14
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	13                              ; 0xd
	db	0                               ; 0x0
	dw	80                              ; 0x50
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	14                              ; 0xe
	db	0                               ; 0x0
	dw	10                              ; 0xa
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	15                              ; 0xf
	db	0                               ; 0x0
	dw	80                              ; 0x50
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	16                              ; 0x10
	db	1                               ; 0x1
	dw	40                              ; 0x28
	db	1                               ; 0x1
	db	0                               ; 0x0
	db	17                              ; 0x11
	db	0                               ; 0x0

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"Live benchmark failed"

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"Press any key"

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
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
	db	114                             ; 0x72
	d24	_.str.7
	db	2                               ; 0x2
	d24	_.str.8
	db	22                              ; 0x16
	d24	_.str.9
	db	154                             ; 0x9a
	d24	_.str.10
	db	114                             ; 0x72
	d24	_.str.11
	db	34                              ; 0x22
	d24	_.str.12
	db	26                              ; 0x1a
	d24	_.str.13
	db	113                             ; 0x71
	d24	_.str.14
	db	153                             ; 0x99
	d24	_.str.15
	db	113                             ; 0x71
	d24	_.str.16
	db	2                               ; 0x2
	d24	_.str.17
	db	10                              ; 0xa
	d24	_.str.18
	db	50                              ; 0x32
	d24	_.str.19
	db	242                             ; 0xf2
	d24	_.str.20
	db	154                             ; 0x9a
	d24	_.str.21
	db	242                             ; 0xf2
	d24	_.str.22
	db	150                             ; 0x96
	d24	_.str.23
	db	2                               ; 0x2

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"A_APPROACH"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"LARGE_ENTRY"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"SLOW_SWEEP"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"FAST_SWEEP"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"A_RETURN"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"B_APPROACH"

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"B_VIEW"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"B_TO_SMALL"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"SMALL_SWEEP"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"B_RETURN"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"OPEN_TRAVERSE"

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"OPEN_NAV"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"D_APPROACH"

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"D_CROSS"

	.section	.rodata._.str.20,"a",@progbits
	.balign	1
	.local	_.str.20
_.str.20:
	.asciz	"D_TURN_BACK"

	.section	.rodata._.str.21,"a",@progbits
	.balign	1
	.local	_.str.21
_.str.21:
	.asciz	"D_RETURN"

	.section	.rodata._.str.22,"a",@progbits
	.balign	1
	.local	_.str.22
_.str.22:
	.asciz	"BOUNDARY_SLOW"

	.section	.rodata._.str.23,"a",@progbits
	.balign	1
	.local	_.str.23
_.str.23:
	.asciz	"OPEN_EXIT"

	.section	.bss._live_game,"aw",@nobits
	.balign	2
	.local	_live_game
_live_game:
	.zero	18

	.section	.rodata._.str.24,"a",@progbits
	.balign	1
	.local	_.str.24
_.str.24:
	.asciz	"P3DLIV1"

	.section	.rodata._.str.25,"a",@progbits
	.balign	1
	.local	_.str.25
_.str.25:
	.asciz	"P3DLIVE"

	.section	.rodata._.str.26,"a",@progbits
	.balign	1
	.local	_.str.26
_.str.26:
	.asciz	"r+"

	.section	.rodata._.str.27,"a",@progbits
	.balign	1
	.local	_.str.27
_.str.27:
	.asciz	"Live benchmark done"

	.section	.rodata._.str.28,"a",@progbits
	.balign	1
	.local	_.str.28
_.str.28:
	.asciz	"Live save failed"

	.section	.rodata._.str.29,"a",@progbits
	.balign	1
	.local	_.str.29
_.str.29:
	.asciz	"971 rendered frames"

	.section	.rodata._.str.30,"a",@progbits
	.balign	1
	.local	_.str.30
_.str.30:
	.asciz	"Portal crossings: "

	.section	.rodata._.str.31,"a",@progbits
	.balign	1
	.local	_.str.31
_.str.31:
	.asciz	"Format: P3DLIV1"

	.section	.rodata._.str.32,"a",@progbits
	.balign	1
	.local	_.str.32
_.str.32:
	.asciz	"Build: 0x"

	.section	.rodata._.str.33,"a",@progbits
	.balign	1
	.local	_.str.33
_.str.33:
	.asciz	"Result: P3DLIVE"

	.section	.rodata._.str.34,"a",@progbits
	.balign	1
	.local	_.str.34
_.str.34:
	.asciz	"Archived safely"

	.section	.rodata._.str.35,"a",@progbits
	.balign	1
	.local	_.str.35
_.str.35:
	.asciz	"Saved in RAM"

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
	.extern	_render_asm_cast_wall_continue
	.extern	__ldivu
	.extern	_ti_Rename
	.extern	_llvm.lifetime.end.p0
	.extern	__ishru
	.extern	_render_ray_state
	.extern	_render_asm_draw_horizontal_grid_pair
	.extern	__sor
	.extern	__Unwind_SjLj_Unregister
	.extern	_render_asm_repair_horizon
	.extern	_render_asm_cast_wall_begin
	.extern	_llvm.memset.p0.i64
	.extern	__land
	.extern	_llvm.umax.i8
	.extern	__ineg
	.extern	_gfx_Wait
	.extern	__ior
	.extern	_os_GetCSC
	.extern	__lsub
	.extern	_gfx_Line
	.extern	_llvm.abs.i24
	.extern	_os_PutStrFull
	.extern	_ti_Open
	.extern	_render_asm_clear_background
	.extern	__ladd
	.extern	_llvm.umin.i24
	.extern	__idivu
	.extern	__lxor
	.extern	_render_asm_find_portal
	.extern	__irems
	.extern	_llvm.eh.sjlj.lsda
	.extern	_ti_SetArchiveStatus
	.extern	_ti_Delete
	.extern	__iand
	.extern	__setflag
	.extern	__lnot
	.extern	_ti_Resize
	.extern	_os_ClrLCD
	.extern	_llvm.stacksave.p0
	.extern	_ti_Close
	.extern	_llvm.lifetime.start.p0
	.extern	_render_asm_draw_portal_mask
	.extern	_llvm.umin.i16
	.extern	__lshru
	.extern	__ixor
	.extern	_render_asm_draw_solid_segment
	.extern	_os_HomeUp
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_memcpy
	.extern	_os_SetCursorPos
	.extern	_llvm.umin.i32
	.extern	__sdivu
	.extern	_llvm.umax.i24
	.extern	__bshru
	.extern	_llvm.umin.i8
	.extern	_llvm.memset.p0.i24
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_gfx_End
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.abs.i16
	.extern	_llvm.frameaddress.p0
	.extern	_os_DrawStatusBar
	.extern	__lshl
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	__sxor
	.extern	_render_asm_draw_wall_segment_registers
	.extern	__lcmpu
	.extern	_atomic_load_decreasing_32
	.extern	_render_asm_transform_ray_state
	.extern	_gfx_Begin
	.extern	_atomic_load_increasing_32
	.extern	_clock
	.extern	_render_asm_add_projected_grid_segment
	.extern	_llvm.smax.i24
	.extern	_gfx_SwapDraw
	.extern	_strlen
	.extern	_render_asm_portal_opening
	.extern	__frameset
	.extern	__imulu
	.extern	_llvm.eh.sjlj.callsite
	.extern	_ti_GetDataPtr
	.extern	__lmulu
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	__sshl
	.extern	__bshl
	.extern	__ishrs
	.extern	__smulu
	.extern	_gfx_SetDraw
	.extern	__ishl
