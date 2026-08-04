	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._benchmark_run,"ax",@progbits
	.globl	_benchmark_run                  ; -- Begin function benchmark_run
	.type	_benchmark_run,@function
_benchmark_run:                         ; @benchmark_run
; %bb.0:
	ld	hl, -65
	call	__frameset
	ld	hl, _benchmark_report
	xor	a, a
	ld	iy, -917456
	ld	(ix - 18), a                    ; 1-byte Folded Spill
	ld	(_benchmark_report), a
	push	hl
	pop	de
	inc	de
	ld	bc, 6063
	ldir
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	(ix - 34), l
	ld	(ix - 33), h
	ld.sis	bc, 2048
	call	__sand
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jr	nz, .LBB0_2
; %bb.1:
	ld	hl, -917472
	push	hl
	call	_atomic_load_decreasing_32
	jr	.LBB0_3
	.local	.LBB0_2
.LBB0_2:
	ld	hl, -917472
	push	hl
	call	_atomic_load_increasing_32
	.local	.LBB0_3
.LBB0_3:
	ld	(ix - 37), hl
	ld	(ix - 38), e                    ; 1-byte Folded Spill
	pop	hl
	ld	l, 12
	ld	(ix - 23), l
	ld	(ix - 22), h
	scf
	sbc	hl, hl
	ld	(ix - 21), hl
	ld	hl, _.str.18
	ld	(ix - 65), hl
	lea	hl, ix - 9
	ld	(ix - 32), hl
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
	call	_game_graphics_init
	call	_game_render_benchmark_calibrate
	ld	(ix - 41), hl
	ld	(ix - 42), e                    ; 1-byte Folded Spill
	ld	de, 6
	ld.sis	hl, 0
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	bc, 0
	.local	.LBB0_4
.LBB0_4:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_8 Depth 2
                                        ;     Child Loop BB0_11 Depth 2
                                        ;     Child Loop BB0_14 Depth 2
                                        ;     Child Loop BB0_17 Depth 2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB0_20
; %bb.5:                                ;   in Loop: Header=BB0_4 Depth=1
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _benchmark_scenes
	push	hl
	pop	iy
	add	iy, de
	ld	(ix - 29), iy
	ld	hl, (iy + 15)
	ld	(ix - 62), hl
	ld	(_benchmark_game), hl
	ld	hl, (iy + 18)
	ld	(ix - 59), hl
	ld	(_benchmark_game+3), hl
	ld	de, (iy + 22)
	ld	(ix - 49), de
	ld	hl, _benchmark_game+6
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, (iy + 24)
	ld	(ix - 45), hl
	ld	a, (iy + 27)
	ld	(ix - 46), a
	ld	(_benchmark_game+8), hl
	ld	(_benchmark_game+11), a
	ld	hl, (iy + 28)
	ld	(ix - 52), hl
	ld	a, (iy + 31)
	ld	(ix - 53), a
	ld	(_benchmark_game+12), hl
	ld	(_benchmark_game+15), a
	xor	a, a
	ld	(_benchmark_game+16), a
	push	bc
	pop	hl
	ld	(ix - 14), bc
	ld	bc, 40
	call	__imulu
	ex	de, hl
	ld	hl, _benchmark_report+64
	add	hl, de
	ld	(ix - 26), hl
	ld	iy, (ix - 29)
	lea	hl, iy + 2
	ld	(ix - 56), hl
	push	hl
	call	_strlen
	pop	de
	ld	bc, 255
	call	__iand
	ex	de, hl
	ld	hl, (ix - 29)
	ld	a, (hl)
	ld	hl, (ix - 26)
	ld	(hl), a
	ld	iy, (ix - 29)
	ld	a, (iy + 1)
	push	hl
	pop	iy
	ld	(iy + 1), a
	ld	(iy + 2), 12
	ld	(iy + 3), b
	ld	l, (ix - 23)
	ld	h, (ix - 22)
	ld	bc, (ix - 14)
	ld	h, c
	ld	(ix - 23), l
	ld	(ix - 22), h
	mlt	hl
	ld	(iy + 4), l
	ld	(iy + 5), 0
	ld	hl, (ix - 62)
	ld	a, l
	ld	(iy + 12), a
	ld	a, h
	ld	(iy + 13), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(iy + 14), a
	ld	hl, (ix - 59)
	ld	a, l
	ld	(iy + 15), a
	ld	a, h
	ld	(iy + 16), a
	call	__ishru
	ld	a, l
	ld	(iy + 17), a
	ld	hl, (ix - 49)
	ld	a, l
	ld	(iy + 18), a
	ld	a, h
	ld	(iy + 19), a
	ld	hl, (ix - 45)
	ld	(iy + 20), hl
	ld	a, (ix - 46)
	ld	(iy + 23), a
	ld	hl, (ix - 52)
	ld	(iy + 24), hl
	ld	a, (ix - 53)
	ld	(iy + 27), a
	push	de
	pop	hl
	ld	bc, 12
	or	a, a
	sbc	hl, bc
	jr	c, .LBB0_7
; %bb.6:                                ;   in Loop: Header=BB0_4 Depth=1
	ld	de, 12
	.local	.LBB0_7
.LBB0_7:                                ;   in Loop: Header=BB0_4 Depth=1
	push	de
	ld	hl, (ix - 56)
	push	hl
	ld	iy, (ix - 26)
	pea	iy + 28
	call	_memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _.str
	push	hl
	ld	hl, (ix - 14)
	push	hl
	call	_benchmark_render_progress
	pop	hl
	pop	hl
	ld	iyl, 2
	ld	bc, _render_benchmark
	.local	.LBB0_8
.LBB0_8:                                ;   Parent Loop BB0_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, iyl
	or	a, a
	push	bc
	pop	de
	inc	de
	jr	z, .LBB0_10
; %bb.9:                                ;   in Loop: Header=BB0_8 Depth=2
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	push	bc
	pop	hl
	ld	bc, 65
	ldir
	ld	hl, _benchmark_game
	push	hl
	push	af
	ld	a, iyl
	ld	(ix - 29), a                    ; 1-byte Folded Spill
	pop	af
	call	_game_render
	pop	hl
	call	_gfx_SwapDraw
	ld	bc, _render_benchmark
	push	af
	ld	a, (ix - 29)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	dec	iyl
	jr	.LBB0_8
	.local	.LBB0_10
.LBB0_10:                               ;   in Loop: Header=BB0_4 Depth=1
	ld	(ix - 29), de
	ld	hl, _.str.1
	push	hl
	ld	hl, (ix - 14)
	push	hl
	call	_benchmark_render_progress
	pop	hl
	pop	hl
	ld.sis	hl, 0
	ld	c, l
	ld	b, h
	.local	.LBB0_11
.LBB0_11:                               ;   Parent Loop BB0_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	l, c
	ld	h, b
	ld.sis	de, 8
	or	a, a
	sbc.sis	hl, de
	jp	z, .LBB0_13
; %bb.12:                               ;   in Loop: Header=BB0_11 Depth=2
	ld	l, (ix - 17)
	ld	h, (ix - 16)
                                        ; kill: def $hl killed $hl def $uhl
	add.sis	hl, bc
	ld	de, 0
	push	de
	push	hl
	ld	(ix - 45), c
	ld	(ix - 44), b
	call	_benchmark_render_sample
	ld	c, (ix - 45)
	ld	b, (ix - 44)
	pop	hl
	pop	hl
	inc.sis	bc
	jp	.LBB0_11
	.local	.LBB0_13
.LBB0_13:                               ;   in Loop: Header=BB0_4 Depth=1
	ld	hl, _.str.2
	push	hl
	ld	hl, (ix - 14)
	push	hl
	call	_benchmark_render_progress
	pop	hl
	pop	hl
	ld.sis	hl, 8
	ld	c, l
	ld	b, h
	.local	.LBB0_14
.LBB0_14:                               ;   Parent Loop BB0_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	l, c
	ld	h, b
	ld.sis	de, 12
	or	a, a
	sbc.sis	hl, de
	jp	z, .LBB0_16
; %bb.15:                               ;   in Loop: Header=BB0_14 Depth=2
	ld	l, (ix - 17)
	ld	h, (ix - 16)
                                        ; kill: def $hl killed $hl def $uhl
	add.sis	hl, bc
	ld	de, 1
	push	de
	push	hl
	ld	(ix - 45), c
	ld	(ix - 44), b
	call	_benchmark_render_sample
	ld	c, (ix - 45)
	ld	b, (ix - 44)
	pop	hl
	pop	hl
	inc.sis	bc
	jp	.LBB0_14
	.local	.LBB0_16
.LBB0_16:                               ;   in Loop: Header=BB0_4 Depth=1
	xor	a, a
	ld	(_render_benchmark_active), a
	sbc	hl, hl
	ld	(_render_benchmark_last), hl
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	ld	de, (ix - 29)
	ld	hl, _render_benchmark
	ld	bc, 65
	ldir
	ld	hl, _benchmark_game
	push	hl
	call	_game_render
	pop	hl
	ld	hl, (-1900524)
	ld	(ix - 45), hl
	ld	iy, 1875397
	ld	(ix - 29), iy
	ld	e, -127
	ld	bc, 0
	.local	.LBB0_17
.LBB0_17:                               ;   Parent Loop BB0_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	bc
	pop	iy
	push	bc
	pop	hl
	ld	bc, 76800
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_19
; %bb.18:                               ;   in Loop: Header=BB0_17 Depth=2
	ld	hl, (ix - 45)
	lea	bc, iy + 0
	add	hl, bc
	ld	a, (hl)
	ld	l, 0
	ld	(ix - 11), l
	ld	bc, (ix - 13)
	ld	b, l
	ld	c, a
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	hl, (ix - 29)
	call	__lxor
	ld	bc, 403
	ld	a, b
	call	__lmulu
	lea	bc, iy + 0
	ld	(ix - 29), hl
	inc	bc
	jr	.LBB0_17
	.local	.LBB0_19
.LBB0_19:                               ;   in Loop: Header=BB0_4 Depth=1
	ld	bc, (ix - 29)
	ld	a, c
	ld	h, e
	push	bc
	pop	de
	ld	iy, (ix - 26)
	ld	(iy + 8), a
	ld	a, d
	ld	(iy + 9), a
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 10), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 11), a
	call	_gfx_SwapDraw
	ld	bc, (ix - 14)
	inc	bc
	ld.sis	de, 12
	ld	l, (ix - 17)
	ld	h, (ix - 16)
	add.sis	hl, de
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	de, 6
	jp	.LBB0_4
	.local	.LBB0_20
.LBB0_20:
	ld	de, _benchmark_report
	ld	hl, _.str.7
	ld	bc, 7
	ldir
	ld	iyl, 2
	ld	a, iyl
	ld	(_benchmark_report+8), a
	ld	l, 0
	ld	a, l
	ld	(_benchmark_report+9), a
	ld	a, 64
	ld	(_benchmark_report+10), a
	ld	a, l
	ld	(_benchmark_report+11), a
	ld	a, 127
	ld	(_benchmark_report+12), a
	ld	de, 0
	ld	(_benchmark_report+13), de
	ld	a, l
	ld	(_benchmark_report+16), a
	ld	e, -128
	ld	a, e
	ld	(_benchmark_report+17), a
	ld	a, l
	ld	(_benchmark_report+18), a
	ld	(_benchmark_report+19), a
	ld	(_benchmark_report+20), a
	ld	a, e
	ld	(_benchmark_report+21), a
	ld	a, l
	ld	(_benchmark_report+22), a
	ld	(_benchmark_report+23), a
	ld	h, 4
	ld	a, h
	ld	(_benchmark_report+24), a
	ld	a, 41
	ld	(_benchmark_report+25), a
	ld	c, 7
	ld	a, c
	ld	(_benchmark_report+26), a
	ld	a, 38
	ld	(_benchmark_report+27), a
	ld	a, 14
	ld	(_benchmark_report+28), a
	ld	b, 6
	ld	a, b
	ld	(_benchmark_report+29), a
	ld	a, 3
	ld	(_benchmark_report+30), a
	ld	a, -78
	ld	(_benchmark_report+31), a
	ld	a, -80
	ld	(_benchmark_report+32), a
	ld	a, 23
	ld	(_benchmark_report+33), a
	ld	a, b
	ld	(_benchmark_report+34), a
	ld	a, l
	ld	(_benchmark_report+35), a
	ld	a, iyl
	ld	(_benchmark_report+36), a
	ld	a, l
	ld	(_benchmark_report+37), a
	ld	e, (ix - 23)
	ld	d, (ix - 22)
	ld	a, e
	ld	(_benchmark_report+38), a
	ld	a, l
	ld	(_benchmark_report+39), a
	ld	a, 40
	ld	(_benchmark_report+40), a
	ld	a, l
	ld	(_benchmark_report+41), a
	ld	e, 80
	ld	a, e
	ld	(_benchmark_report+42), a
	ld	a, l
	ld	(_benchmark_report+43), a
	ld	a, e
	ld	(_benchmark_report+44), a
	ld	a, l
	ld	(_benchmark_report+45), a
	ld	a, h
	ld	(_benchmark_report+46), a
	ld	a, 8
	ld	(_benchmark_report+47), a
	ld	a, b
	ld	(_benchmark_report+48), a
	ld	a, 1
	ld	(_benchmark_report+49), a
	ld	a, c
	ld	(_benchmark_report+50), a
	ld	de, (ix - 41)
	ld	a, e
	ld	(_benchmark_report+52), a
	ld	a, d
	ld	(_benchmark_report+53), a
	ld	l, 16
	push	de
	pop	bc
	ld	h, (ix - 42)                    ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(_benchmark_report+54), a
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(_benchmark_report+55), a
	ld	bc, 6000
	or	a, a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	e, -1
	.local	.LBB0_21
.LBB0_21:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_23 Depth 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_30
; %bb.22:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	hl, _benchmark_report+64
	lea	bc, iy + 0
	ld	(ix - 14), bc
	add	hl, bc
	ld	a, (hl)
	ld	l, 0
	ld	(ix - 10), l
	ld	bc, (ix - 12)
	ld	b, l
	ld	c, a
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	hl, (ix - 21)
	call	__lxor
	ld	d, 8
	.local	.LBB0_23
.LBB0_23:                               ;   Parent Loop BB0_21 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, d
	or	a, a
	jr	z, .LBB0_29
; %bb.24:                               ;   in Loop: Header=BB0_23 Depth=2
	ld	(ix - 17), d                    ; 1-byte Folded Spill
	push	hl
	pop	iy
	ld	d, e
	ld	bc, 1
	xor	a, a
	call	__land
	ld	(ix - 21), hl
	lea	bc, iy + 0
	ld	a, d
	ld	l, 1
	call	__lshru
	ld	iyl, a
	ld	de, (ix - 21)
	ld	a, e
	xor	a, l
	ld	e, a
	bit	0, e
	ld	hl, 0
	jr	nz, .LBB0_26
; %bb.25:                               ;   in Loop: Header=BB0_23 Depth=2
	ld	hl, -4685024
	.local	.LBB0_26
.LBB0_26:                               ;   in Loop: Header=BB0_23 Depth=2
	bit	0, e
	ld	e, 0
	jr	nz, .LBB0_28
; %bb.27:                               ;   in Loop: Header=BB0_23 Depth=2
	ld	e, -19
	.local	.LBB0_28
.LBB0_28:                               ;   in Loop: Header=BB0_23 Depth=2
	ld	a, iyl
	call	__lxor
	ld	d, (ix - 17)                    ; 1-byte Folded Reload
	dec	d
	jr	.LBB0_23
	.local	.LBB0_29
.LBB0_29:                               ;   in Loop: Header=BB0_21 Depth=1
	ld	(ix - 21), hl
	ld	iy, (ix - 14)
	inc	iy
	ld	bc, 6000
	jp	.LBB0_21
	.local	.LBB0_30
.LBB0_30:
	ld	hl, (ix - 21)
	call	__lnot
	push	hl
	pop	iy
	ld	a, iyl
	ld	(_benchmark_report+56), a
	ld	a, iyh
	ld	(_benchmark_report+57), a
	ld	l, 16
	lea	bc, iy + 0
	ld	a, e
	call	__lshru
	ld	a, c
	ld	(_benchmark_report+58), a
	ld	l, 24
	lea	bc, iy + 0
	ld	a, e
	call	__lshru
	ld	a, c
	ld	(_benchmark_report+59), a
	ld	hl, _.str.8
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.9
	push	hl
	ld	hl, _.str.8
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB0_36
; %bb.31:
	ld	(ix - 14), de
	push	de
	ld	hl, 1
	push	hl
	ld	hl, 6064
	push	hl
	ld	hl, _benchmark_report
	push	hl
	call	_ti_Write
	pop	de
	pop	de
	pop	de
	pop	de
	ld	de, 1
	or	a, a
	sbc	hl, de
	jr	nz, .LBB0_35
; %bb.32:
	ld	hl, (ix - 14)
	push	hl
	call	_ti_GetSize
	pop	de
	ld.sis	de, 6064
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB0_35
; %bb.33:
	ld	hl, (ix - 14)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, _.str.10
	push	hl
	call	_ti_Delete
	pop	hl
	ld	hl, _.str.10
	push	hl
	ld	hl, _.str.8
	push	hl
	call	_ti_Rename
	pop	hl
	pop	hl
	or	a, a
	ld	a, 1
	ld	(ix - 18), a                    ; 1-byte Folded Spill
	jr	z, .LBB0_36
; %bb.34:
	ld	a, 0
	ld	(ix - 18), a
	jr	.LBB0_36
	.local	.LBB0_35
.LBB0_35:
	ld	hl, (ix - 14)
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB0_36
.LBB0_36:
	call	_gfx_End
	bit	0, (ix - 18)                    ; 1-byte Folded Reload
	jr	nz, .LBB0_38
; %bb.37:
	ld	hl, _.str.13
	jr	.LBB0_42
	.local	.LBB0_38
.LBB0_38:
	ld	hl, _.str.11
	push	hl
	ld	hl, _.str.10
	push	hl
	call	_ti_Open
	ld	e, a
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB0_41
; %bb.39:
	push	de
	ld	hl, 1
	push	hl
	ld	(ix - 17), de
	call	_ti_SetArchiveStatus
	ld	(ix - 14), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 17)
	push	hl
	call	_ti_Close
	pop	hl
	ld	hl, (ix - 14)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_41
; %bb.40:
	ld	hl, _.str.17
	ld	(ix - 65), hl
	.local	.LBB0_41
.LBB0_41:
	ld	hl, _.str.12
	.local	.LBB0_42
.LBB0_42:
	ld	(ix - 14), hl
	ld	iy, -917456
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, -65
	call	__sand
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 37)
	ld	(-917472), hl
	ld	a, (ix - 38)                    ; 1-byte Folded Reload
	ld	(-917469), a
	ld	l, (ix - 34)
	ld	h, (ix - 33)
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
	ld	hl, (ix - 14)
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
	bit	0, (ix - 18)                    ; 1-byte Folded Reload
	jr	nz, .LBB0_44
; %bb.43:
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
	jp	.LBB0_47
	.local	.LBB0_44
.LBB0_44:
	ld	hl, _.str.14
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
	ld	hl, _.str.15
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	(ix - 1), 0
	ld	de, 7
	ld	a, 38
	ld	bc, 469252
	.local	.LBB0_45
.LBB0_45:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	push	bc
	pop	iy
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, _benchmark_put_hex32.digits
	add	hl, bc
	ld	c, (hl)
	ld	hl, (ix - 32)
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
	jr	nz, .LBB0_45
; %bb.46:
	ld	hl, (ix - 32)
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 4
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.16
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
	ld	hl, (ix - 65)
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
	ld	hl, _.str.19
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
	ld	hl, _.str.20
	.local	.LBB0_47
.LBB0_47:
	push	hl
	call	_os_PutStrFull
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 9
	push	hl
	call	_os_SetCursorPos
	pop	hl
	pop	hl
	ld	hl, _.str.23
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB0_48
.LBB0_48:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB0_48
	.local	.LBB0_49
.LBB0_49:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB0_49
; %bb.50:
	ld	a, (ix - 18)
	ld	l, 1
	xor	a, l
	ld	e, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_benchmark_run, .Lfunc_end0-_benchmark_run
                                        ; -- End function
	.section	.text._benchmark_render_progress,"ax",@progbits
	.type	_benchmark_render_progress,@function ; -- Begin function benchmark_render_progress
_benchmark_render_progress:             ; @benchmark_render_progress
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	a, (ix + 6)
	ld	(ix - 6), a
	ld	hl, (ix + 9)
	ld	(ix - 3), hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_SetColor
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_FillScreen
	pop	hl
	ld	hl, 15
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
	ld	hl, 8
	push	hl
	push	hl
	ld	hl, _.str.3
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 32
	push	hl
	ld	hl, 8
	push	hl
	ld	hl, _.str.4
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 6)                     ; 1-byte Folded Reload
	ld	(ix - 6), hl
	inc	hl
	ld	de, 1
	push	de
	push	hl
	call	_gfx_PrintUInt
	pop	hl
	pop	hl
	ld	hl, _.str.5
	push	hl
	call	_gfx_PrintString
	pop	hl
	ld	hl, 1
	push	hl
	ld	hl, 6
	push	hl
	call	_gfx_PrintUInt
	pop	hl
	pop	hl
	ld	hl, (ix - 6)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _benchmark_scenes
	add	iy, de
	ld	hl, 48
	push	hl
	ld	hl, 8
	push	hl
	pea	iy + 2
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 72
	push	hl
	ld	hl, 8
	push	hl
	ld	hl, (ix - 3)
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 96
	push	hl
	ld	hl, 8
	push	hl
	ld	hl, _.str.6
	push	hl
	call	_gfx_PrintStringXY
	ld	sp, ix
	pop	ix
	jp	_gfx_SwapDraw
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_benchmark_render_progress, .Lfunc_end1-_benchmark_render_progress
                                        ; -- End function
	.section	.text._benchmark_render_sample,"ax",@progbits
	.type	_benchmark_render_sample,@function ; -- Begin function benchmark_render_sample
_benchmark_render_sample:               ; @benchmark_render_sample
; %bb.0:
	ld	hl, -39
	call	__frameset
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	a, (ix + 9)
	ld	(ix - 9), a
	xor	a, a
	ld	bc, 0
	ld	e, a
	ld	hl, _render_benchmark
	ld	(_render_benchmark_active), a
	ld	(ix - 12), bc
	ld	(_render_benchmark_last), bc
	ld	a, e
	ld	(_render_benchmark_last+3), a
	ld	(_render_benchmark_category), a
	ld	(_render_benchmark), a
	push	hl
	pop	de
	inc	de
	ld	bc, 65
	ld	(ix - 6), hl
	ldir
	call	_clock
	ld	(ix - 15), hl
	ld	(ix - 18), e                    ; 1-byte Folded Spill
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	or	a, a
	jr	nz, .LBB2_2
; %bb.1:
	ld	hl, _benchmark_game
	push	hl
	call	_game_render
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	(ix - 6), hl
	jr	.LBB2_3
	.local	.LBB2_2
.LBB2_2:
	call	_game_render_benchmark_begin
	ld	hl, _benchmark_game
	push	hl
	call	_game_render
	pop	hl
	call	_game_render_benchmark_end
	.local	.LBB2_3
.LBB2_3:
	call	_clock
	ld	bc, (ix - 15)
	ld	a, (ix - 18)                    ; 1-byte Folded Reload
	call	__lsub
	ld	(ix - 36), hl
	ld	(ix - 33), e                    ; 1-byte Folded Spill
	ld	hl, (_render_profile)
	ld	(ix - 32), hl
	ld	a, (_render_profile+3)
	ld	(ix - 29), a                    ; 1-byte Folded Spill
	ld	hl, (_render_profile+4)
	ld	(ix - 28), hl
	ld	a, (_render_profile+7)
	ld	(ix - 25), a                    ; 1-byte Folded Spill
	ld	hl, (_render_profile+8)
	ld	(ix - 24), hl
	ld	a, (_render_profile+11)
	ld	(ix - 21), a                    ; 1-byte Folded Spill
	ld	hl, _render_profile+12
	ld	hl, (hl)
	ld	(ix - 18), hl
	ld	a, (_render_profile+14)
	ld	(ix - 15), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 3)
	ld	bc, 0
	ld	c, l
	ld	b, h
	push	bc
	pop	hl
	ld	bc, 80
	call	__imulu
	push	hl
	pop	bc
	ld	iy, _benchmark_report+304
	ld	(ix - 39), bc
	add	iy, bc
	ld	de, (ix - 36)
	ld	a, e
	ld	(iy), a
	ld	a, d
	ld	(iy + 1), a
	ld	l, 16
	push	de
	pop	bc
	ld	h, (ix - 33)                    ; 1-byte Folded Reload
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(iy + 2), a
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	(iy + 3), a
	ld	de, (ix - 32)
	ld	a, e
	ld	(iy + 4), a
	ld	a, d
	ld	(iy + 5), a
	push	de
	pop	bc
	ld	h, (ix - 29)                    ; 1-byte Folded Reload
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 6), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 7), a
	ld	de, (ix - 28)
	ld	a, e
	ld	(iy + 8), a
	ld	a, d
	ld	(iy + 9), a
	push	de
	pop	bc
	ld	h, (ix - 25)                    ; 1-byte Folded Reload
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 10), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 11), a
	ld	de, (ix - 24)
	ld	a, e
	ld	(iy + 12), a
	ld	a, d
	ld	(iy + 13), a
	push	de
	pop	bc
	ld	h, (ix - 21)                    ; 1-byte Folded Reload
	ld	a, h
	ld	l, 16
	call	__lshru
	ld	a, c
	ld	(iy + 14), a
	push	de
	pop	bc
	ld	a, h
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	(iy + 15), a
	ld	hl, (ix - 18)
	ld	a, l
	ld	(iy + 16), a
	ld	a, h
	ld	(iy + 17), a
	ld	a, (ix - 15)
	ld	(iy + 18), a
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	or	a, a
	jr	nz, .LBB2_5
; %bb.4:
	ld	a, 0
	jr	.LBB2_6
	.local	.LBB2_5
.LBB2_5:
	ld	a, 1
	.local	.LBB2_6
.LBB2_6:
	ld	(iy + 19), a
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	or	a, a
	jp	z, .LBB2_15
; %bb.7:
	ld	hl, _benchmark_report
	ld	(ix - 9), hl
	ld	(ix - 3), iy
	ld	iy, (ix - 6)
	ld	de, (iy + 42)
	ld	iy, (ix - 6)
	ld	h, (iy + 45)
	ld	a, e
	ld	iy, (ix - 3)
	ld	(iy + 20), a
	ld	a, d
	ld	iy, (ix - 3)
	ld	(iy + 21), a
	ld	l, 16
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	iy, (ix - 3)
	ld	(iy + 22), a
	ld	l, 24
	push	de
	pop	bc
	ld	a, h
	call	__lshru
	ld	a, c
	ld	iy, (ix - 3)
	ld	(iy + 23), a
	ld	iy, (ix - 6)
	lea	hl, iy + 28
	ld	iy, (ix - 3)
	ld	(ix - 15), hl
	ld	de, (ix - 39)
	ld	hl, (ix - 9)
	add	hl, de
	ld	(ix - 9), hl
	ld	de, -28
	.local	.LBB2_8
.LBB2_8:                                ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB2_10
; %bb.9:                                ;   in Loop: Header=BB2_8 Depth=1
	ld	hl, (ix - 9)
	add	hl, de
	ld	(ix - 24), hl
	ld	bc, 356
	add	hl, bc
	ld	iy, (ix - 15)
	add	iy, de
	ld	(ix - 21), de
	ld	de, (iy)
	ld	a, (iy + 3)
	ld	(ix - 18), a
	ld	a, e
	ld	(hl), a
	ld	a, d
	ld	iy, (ix - 24)
	lea	hl, iy + 0
	inc	bc
	add	hl, bc
	ld	(hl), a
	push	de
	pop	bc
	ld	a, (ix - 18)                    ; 1-byte Folded Reload
	ld	l, 16
	call	__lshru
	ld	a, c
	lea	hl, iy + 0
	ld	bc, 358
	add	hl, bc
	ld	(hl), a
	push	de
	pop	bc
	ld	a, (ix - 18)                    ; 1-byte Folded Reload
	ld	l, 24
	call	__lshru
	ld	a, c
	ld	de, 359
	lea	hl, iy + 0
	add	hl, de
	ld	(hl), a
	ld	iy, (ix - 9)
	ld	bc, (ix - 12)
	add	iy, bc
	ld	(ix - 24), iy
	ld	de, 356
	add	iy, de
	ld	(ix - 18), iy
	ld	iy, (ix - 15)
	add	iy, bc
	ld	de, (iy)
	ld	a, e
	ld	hl, (ix - 18)
	ld	(hl), a
	ld	a, d
	ld	de, 357
	ld	hl, (ix - 24)
	add	hl, de
	ld	(hl), a
	ld	iy, (ix - 21)
	ld	de, 4
	add	iy, de
	push	bc
	pop	hl
	ld	de, 2
	add	hl, de
	ld	(ix - 12), hl
	lea	de, iy + 0
	ld	iy, (ix - 3)
	jp	.LBB2_8
	.local	.LBB2_10
.LBB2_10:
	ld	de, (ix - 6)
	lea	bc, iy + 0
	push	de
	pop	iy
	ld	hl, (iy + 52)
	ld	a, l
	push	bc
	pop	iy
	ld	(iy + 66), a
	ld	a, h
	ld	(iy + 67), a
	push	de
	pop	iy
	ld	hl, (iy + 54)
	ld	a, l
	push	bc
	pop	iy
	ld	(iy + 68), a
	ld	a, h
	ld	(iy + 69), a
	push	de
	pop	iy
	ld	hl, (iy + 56)
	ld	a, l
	push	bc
	pop	iy
	ld	(iy + 70), a
	ld	a, h
	ld	(iy + 71), a
	push	de
	pop	iy
	ld	hl, (iy + 48)
	ld	a, l
	push	bc
	pop	iy
	ld	(iy + 72), a
	ld	a, h
	ld	(iy + 73), a
	push	de
	pop	iy
	ld	hl, (iy + 50)
	ld	a, l
	push	bc
	pop	iy
	ld	(iy + 74), a
	ld	a, h
	ld	(iy + 75), a
	push	de
	pop	iy
	ld	hl, (iy + 62)
	ld	e, (iy + 65)
	ld	bc, 65535
	xor	a, a
	call	__lcmpu
	jr	c, .LBB2_12
; %bb.11:
	push	bc
	pop	hl
	.local	.LBB2_12
.LBB2_12:
	ld	e, l
	ld	iy, (ix - 3)
	ld	(iy + 76), e
	ld	l, h
	ld	(iy + 77), l
	ld	iy, (ix - 6)
	ld	hl, (iy + 58)
	ld	e, (iy + 61)
	call	__lcmpu
	jr	c, .LBB2_14
; %bb.13:
	push	bc
	pop	hl
	.local	.LBB2_14
.LBB2_14:
	ld	a, l
	ld	iy, (ix - 3)
	ld	(iy + 78), a
	ld	a, h
	ld	(iy + 79), a
	.local	.LBB2_15
.LBB2_15:
	ld	sp, ix
	pop	ix
	jp	_gfx_SwapDraw
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_benchmark_render_sample, .Lfunc_end2-_benchmark_render_sample
                                        ; -- End function
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
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_game_render_benchmark_reset, .Lfunc_end3-_game_render_benchmark_reset
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
	jr	nz, .LBB4_6
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
	jr	c, .LBB4_5
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
	jr	nc, .LBB4_4
; %bb.3:
	lea	bc, iy + 0
	.local	.LBB4_4
.LBB4_4:
	ld	iyl, a
	.local	.LBB4_5
.LBB4_5:
	or	a, a
	sbc	hl, hl
	ld	a, l
	ld	(_render_benchmark_last), bc
	ld	(_render_benchmark_last+3), a
	ld	a, iyl
	ld	(_render_benchmark_active), a
	.local	.LBB4_6
.LBB4_6:
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_game_render_benchmark_begin, .Lfunc_end4-_game_render_benchmark_begin
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
	jp	z, .LBB5_7
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
	jr	nc, .LBB5_3
; %bb.2:
	push	bc
	pop	hl
	jr	.LBB5_6
	.local	.LBB5_3
.LBB5_3:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB5_5
; %bb.4:
	push	de
	pop	iy
	.local	.LBB5_5
.LBB5_5:
	lea	hl, iy + 0
	.local	.LBB5_6
.LBB5_6:
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
	.local	.LBB5_7
.LBB5_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_game_render_benchmark_end, .Lfunc_end5-_game_render_benchmark_end
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
	jp	nz, .LBB6_23
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
	.local	.LBB6_2
.LBB6_2:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_4 Depth 2
	cp	a, 8
	jp	z, .LBB6_22
; %bb.3:                                ;   in Loop: Header=BB6_2 Depth=1
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
	.local	.LBB6_4
.LBB6_4:                                ;   Parent Loop BB6_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, d
	cp	a, 64
	jp	z, .LBB6_17
; %bb.5:                                ;   in Loop: Header=BB6_4 Depth=2
	bit	0, h
	jp	z, .LBB6_16
; %bb.6:                                ;   in Loop: Header=BB6_4 Depth=2
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
	jr	nz, .LBB6_8
; %bb.7:                                ;   in Loop: Header=BB6_4 Depth=2
	ld	a, 0
	.local	.LBB6_8
.LBB6_8:                                ;   in Loop: Header=BB6_4 Depth=2
	bit	0, a
	jr	z, .LBB6_11
; %bb.9:                                ;   in Loop: Header=BB6_4 Depth=2
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
	jr	nc, .LBB6_12
; %bb.10:                               ;   in Loop: Header=BB6_4 Depth=2
	ld	iy, (ix - 103)
	ld	bc, (ix - 100)
	jr	.LBB6_15
	.local	.LBB6_11
.LBB6_11:                               ;   in Loop: Header=BB6_4 Depth=2
	ld	e, (ix - 89)                    ; 1-byte Folded Reload
	jp	.LBB6_16
	.local	.LBB6_12
.LBB6_12:                               ;   in Loop: Header=BB6_4 Depth=2
	ld	iy, (-917472)
	lea	hl, iy + 0
	ld	bc, (ix - 103)
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	ld	bc, (ix - 100)
	jr	nc, .LBB6_14
; %bb.13:                               ;   in Loop: Header=BB6_4 Depth=2
	ld	(ix - 92), iy
	.local	.LBB6_14
.LBB6_14:                               ;   in Loop: Header=BB6_4 Depth=2
	ld	iy, (ix - 92)
	.local	.LBB6_15
.LBB6_15:                               ;   in Loop: Header=BB6_4 Depth=2
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
	.local	.LBB6_16
.LBB6_16:                               ;   in Loop: Header=BB6_4 Depth=2
	inc	d
	jp	.LBB6_4
	.local	.LBB6_17
.LBB6_17:                               ;   in Loop: Header=BB6_2 Depth=1
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
	jr	nz, .LBB6_19
; %bb.18:                               ;   in Loop: Header=BB6_2 Depth=1
	push	bc
	pop	hl
	.local	.LBB6_19
.LBB6_19:                               ;   in Loop: Header=BB6_2 Depth=1
	bit	0, a
	ld	iyl, 0
	jr	nz, .LBB6_21
; %bb.20:                               ;   in Loop: Header=BB6_2 Depth=1
	ld	e, d
	.local	.LBB6_21
.LBB6_21:                               ;   in Loop: Header=BB6_2 Depth=1
	ld	a, (ix - 83)                    ; 1-byte Folded Reload
	inc	a
	ld	(ix - 71), hl
	ld	(ix - 68), e                    ; 1-byte Folded Spill
	jp	.LBB6_2
	.local	.LBB6_22
.LBB6_22:
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
	.local	.LBB6_23
.LBB6_23:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_game_render_benchmark_calibrate, .Lfunc_end6-_game_render_benchmark_calibrate
                                        ; -- End function
	.section	.text._game_render_benchmark_read,"ax",@progbits
	.globl	_game_render_benchmark_read     ; -- Begin function game_render_benchmark_read
	.type	_game_render_benchmark_read,@function
_game_render_benchmark_read:            ; @game_render_benchmark_read
; %bb.0:
	ld	hl, _render_benchmark
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_game_render_benchmark_read, .Lfunc_end7-_game_render_benchmark_read
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
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_game_init, .Lfunc_end8-_game_init
                                        ; -- End function
	.section	.text._game_graphics_init,"ax",@progbits
	.globl	_game_graphics_init             ; -- Begin function game_graphics_init
	.type	_game_graphics_init,@function
_game_graphics_init:                    ; @game_graphics_init
; %bb.0:
	ld	hl, -68
	call	__frameset
	ld	iy, _render_portal_faces
	xor	a, a
	ld	l, 3
	ld	(ix - 19), l
	ld	(ix - 18), h
	ld	hl, _render_builtin_portals+2
	ld	(ix - 14), hl
	ld	hl, _render_direction_y_by_angle
	ld	(ix - 17), hl
	ld	hl, _render_fov_by_direction
	ld	(ix - 43), hl
	ld	hl, _render_screen_rows+4
	ld	(ix - 25), hl
	ld.sis	hl, 960
	ld	(ix - 11), l
	ld	(ix - 10), h
	ld	l, 18
	ld	(ix - 34), l
	ld	hl, 1184274
	ld	(ix - 37), hl
	ld	hl, _render_wall_colors
	ld	(ix - 40), hl
	ld	hl, _game_graphics_init.wall_palette_rgb+2
	ld	(ix - 28), hl
	ld	hl, -1899996
	ld	(ix - 31), hl
	lea	hl, ix - 8
	ld	(ix - 46), hl
	ld	(_render_portal_faces), a
	lea	hl, iy + 0
	inc	hl
	ld	bc, 1023
	ex	de, hl
	lea	hl, iy + 0
	ldir
	ld.sis	hl, -1
	ex.sis	de, hl
	ld	hl, _render_primary_face
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, _render_secondary_face
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	a, 7
	ld	(ix - 22), a                    ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	.local	.LBB9_1
.LBB9_1:                                ; =>This Inner Loop Header: Depth=1
	push	hl
	pop	de
	ld	bc, 80
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_3
; %bb.2:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	hl, _render_portal_transform_plans
	ld	(ix - 49), de
	add	hl, de
	ld	iy, (ix - 14)
	ld	a, (iy)
	ld	(ix - 52), a
	ld	e, (iy + 1)
	ld	(ix - 55), e
	ld	e, (iy + 2)
	ld	c, (iy + 3)
                                        ; kill: def $c killed $c def $ubc
	push	bc
                                        ; kill: def $e killed $e def $ude
	push	de
	ld	e, (ix - 55)                    ; 1-byte Folded Reload
	push	de
	ld	e, a
	push	de
	push	hl
	call	_render_portal_transform_plan_init
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix - 14)
	ld	a, (iy - 2)
	ld	b, (iy - 1)
	ld	de, 0
	ld	e, (ix - 52)                    ; 1-byte Folded Reload
	push	de
	pop	hl
	ld	c, 8
	call	__ishl
	push	hl
	pop	iy
	ld	e, b
	push	de
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	e, a
	add	iy, de
	lea	hl, iy + 0
	call	__ior
	ld	c, (ix - 22)                    ; 1-byte Folded Reload
	ex	de, hl
	ld	hl, _render_portal_faces
	add	hl, de
	ld	(hl), c
	ld	hl, (ix - 49)
	ld	de, 8
	add	hl, de
	ld	a, c
	add	a, e
	ld	c, a
	ld	(ix - 22), c
	ld	iy, (ix - 14)
	lea	iy, iy + 6
	ld	(ix - 14), iy
	jp	.LBB9_1
	.local	.LBB9_3
.LBB9_3:
	ld	de, 64
	ld	bc, 0
	.local	.LBB9_4
.LBB9_4:                                ; %.preheader26
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_8 Depth 2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_15
; %bb.5:                                ;   in Loop: Header=BB9_4 Depth=1
	push	bc
	pop	hl
	add	hl, hl
	ex	de, hl
	ld	iy, _direction_y
	lea	hl, iy + 0
	add	hl, de
	ld	iy, (hl)
	inc	bc
	ld	(ix - 52), bc
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
	ld	(ix - 14), de
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
	ld	(ix - 22), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 0
	sbc.sis	hl, de
	call	pe, __setflag
	ld.sis	hl, -1
	jp	m, .LBB9_7
; %bb.6:                                ;   in Loop: Header=BB9_4 Depth=1
	ld.sis	hl, 0
	.local	.LBB9_7
.LBB9_7:                                ;   in Loop: Header=BB9_4 Depth=1
	ld	de, (ix - 22)
	ld	e, c
	ld	d, b
	ld	(ix - 22), de
	ld.sis	bc, 1
	call	__sor
	ld	(ix - 55), l
	ld	(ix - 54), h
	ld	iy, 0
	lea	de, iy + 0
	.local	.LBB9_8
.LBB9_8:                                ;   Parent Loop BB9_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	bc, 512
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_14
; %bb.9:                                ;   in Loop: Header=BB9_8 Depth=2
	ld	hl, (ix - 17)
	add	hl, de
	ld	bc, (ix - 14)
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	bc, (ix - 22)
	add	iy, bc
	ld	(ix - 58), iy
	lea	hl, iy + 0
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
	ld	(ix - 49), iy
	bit	0, a
	jr	nz, .LBB9_11
; %bb.10:                               ;   in Loop: Header=BB9_8 Depth=2
	ld	hl, (ix - 58)
	ld	(ix - 49), hl
	.local	.LBB9_11
.LBB9_11:                               ;   in Loop: Header=BB9_8 Depth=2
	bit	0, a
	ld	l, (ix - 55)
	ld	h, (ix - 54)
	jr	nz, .LBB9_13
; %bb.12:                               ;   in Loop: Header=BB9_8 Depth=2
	ld.sis	hl, 0
	.local	.LBB9_13
.LBB9_13:                               ;   in Loop: Header=BB9_8 Depth=2
	ld	bc, (ix - 14)
	add.sis	hl, bc
	push	de
	pop	iy
	ld	de, 2
	add	iy, de
	lea	de, iy + 0
	ld	iy, (ix - 49)
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 14), hl
	jp	.LBB9_8
	.local	.LBB9_14
.LBB9_14:                               ; %.preheader26.loopexit
                                        ;   in Loop: Header=BB9_4 Depth=1
	ld	hl, (ix - 17)
	add	hl, bc
	ld	(ix - 17), hl
	ld	de, 64
	ld	bc, (ix - 52)
	jp	.LBB9_4
	.local	.LBB9_15
.LBB9_15:
	ld	bc, 257
	ld	a, 8
	ld	de, -256
	or	a, a
	sbc	hl, hl
	ld	(ix - 14), hl
	.local	.LBB9_16
.LBB9_16:                               ; %.preheader24
                                        ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB9_20
; %bb.17:                               ;   in Loop: Header=BB9_16 Depth=1
	ld	hl, (ix - 14)
	ld	c, a
	call	__ishl
	ld	bc, -65536
	add	hl, bc
	ld	c, a
	call	__ishrs
	ld	(ix - 22), hl
	push	de
	pop	hl
	add	hl, hl
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 17), de
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
	ld	hl, (ix - 22)
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB9_19
; %bb.18:                               ;   in Loop: Header=BB9_16 Depth=1
	lea	bc, iy + 0
	.local	.LBB9_19
.LBB9_19:                               ;   in Loop: Header=BB9_16 Depth=1
	push	bc
	pop	hl
	ld	c, a
	call	__ishru
	ld	iy, (ix - 43)
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 14)
	inc	hl
	ld	(ix - 14), hl
	ld	de, (ix - 17)
	inc	de
	lea	iy, iy + 2
	ld	(ix - 43), iy
	ld	bc, 257
	jp	.LBB9_16
	.local	.LBB9_20
.LBB9_20:
	or	a, a
	sbc	hl, hl
	ld	(_render_screen_rows), hl
	ld	de, 76800
	ld	iy, 320
	lea	hl, iy + 0
	.local	.LBB9_21
.LBB9_21:                               ; =>This Inner Loop Header: Depth=1
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jr	z, .LBB9_23
; %bb.22:                               ;   in Loop: Header=BB9_21 Depth=1
	ld	iy, (ix - 25)
	push	bc
	pop	hl
	ld	(iy), hl
	ld	bc, 320
	add	hl, bc
	lea	iy, iy + 4
	ld	(ix - 25), iy
	jr	.LBB9_21
	.local	.LBB9_23
.LBB9_23:
	ld.sis	hl, 0
	ld	(ix - 14), l
	ld	(ix - 13), h
	ld	(ix - 22), l
	ld	(ix - 21), h
	ld	de, 0
	.local	.LBB9_24
.LBB9_24:                               ; %.preheader23
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_39 Depth 2
                                        ;     Child Loop BB9_34 Depth 2
	sbc	hl, hl
	adc	hl, de
	ld	(ix - 17), de
	jp	nz, .LBB9_38
; %bb.25:                               ;   in Loop: Header=BB9_24 Depth=1
	push	hl
	ld	l, (ix - 11)
	ld	h, (ix - 10)
	ex	(sp), hl
	pop	iy
	.local	.LBB9_26
.LBB9_26:                               ; %.loopexit22.loopexit
                                        ;   in Loop: Header=BB9_24 Depth=1
	ld	e, (ix - 14)
	ld	d, (ix - 13)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	c, (ix - 22)
	ld	b, (ix - 21)
	or	a, a
	sbc.sis	hl, bc
	push	iy
	ex	(sp), hl
	ld	(ix - 11), l
	ld	(ix - 10), h
	pop	hl
	jp	z, .LBB9_42
; %bb.27:                               ;   in Loop: Header=BB9_24 Depth=1
	or	a, a
	sbc	hl, hl
	ld	(ix - 14), e
	ld	(ix - 13), d
	ld	l, e
	ld	h, d
	ld	(ix - 25), hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	c, iyl
	ld	b, iyh
	ld	iy, _render_wall_scale_profiles
	add	iy, de
	ld.sis	hl, 2048
	call	__sdivu
	ld	(ix - 43), l
	ld	(ix - 42), h
	ld	l, c
	ld	h, b
	ld.sis	de, 240
	or	a, a
	sbc.sis	hl, de
	jr	c, .LBB9_29
; %bb.28:                               ;   in Loop: Header=BB9_24 Depth=1
	ld.sis	hl, 240
	ld	c, l
	ld	b, h
	.local	.LBB9_29
.LBB9_29:                               ;   in Loop: Header=BB9_24 Depth=1
	ld	(ix - 49), c
	ld	(ix - 48), b
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	ld	(iy), e
	ld	(iy + 1), d
	ld	l, e
	ld	h, d
	ld.sis	bc, 240
	or	a, a
	sbc.sis	hl, bc
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	ld	d, e
	ld	a, c
	sub	a, d
	ld	h, a
	srl	h
	bit	0, l
	ld	a, b
	ld	c, a
	jr	nz, .LBB9_31
; %bb.30:                               ;   in Loop: Header=BB9_24 Depth=1
	ld	c, h
	.local	.LBB9_31
.LBB9_31:                               ;   in Loop: Header=BB9_24 Depth=1
	bit	0, l
	ld	e, -16
	ld	a, e
	jr	nz, .LBB9_33
; %bb.32:                               ;   in Loop: Header=BB9_24 Depth=1
	ld	a, h
	add	a, d
	ld	l, a
	.local	.LBB9_33
.LBB9_33:                               ;   in Loop: Header=BB9_24 Depth=1
	ld	(ix - 22), c
	ld	(ix - 21), b
	ld	(iy + 2), c
	ld	(iy + 3), a
	ld	hl, (ix - 25)
	ld	bc, 9
	call	__imulu
	ld	(ix - 52), hl
	ld	hl, _render_wall_texture_boundaries
	ld	de, (ix - 52)
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
	ld	e, (ix - 43)
	ld	d, (ix - 42)
	ld	iyl, e
	ld	iyh, d
	ld	e, (ix - 49)
	ld	d, (ix - 48)
	ld	l, e
	ld	h, d
	ld	(ix - 43), hl
	ld	hl, (ix - 25)
	call	__imulu
	ex	de, hl
	ld	hl, _render_wall_texture_boundaries
	add	hl, de
	ld	(ix - 49), hl
	ld	de, 0
	.local	.LBB9_34
.LBB9_34:                               ;   Parent Loop BB9_24 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_41
; %bb.35:                               ;   in Loop: Header=BB9_34 Depth=2
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
	ld	bc, (ix - 43)
	or	a, a
	sbc	hl, bc
	jr	c, .LBB9_37
; %bb.36:                               ;   in Loop: Header=BB9_34 Depth=2
	ld	iy, (ix - 43)
	.local	.LBB9_37
.LBB9_37:                               ;   in Loop: Header=BB9_34 Depth=2
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	c, (ix - 22)
	ld	b, (ix - 21)
	ld	a, c
	add	a, l
	ld	c, a
	ld	hl, (ix - 49)
	add	hl, de
	ld	(hl), c
	inc	de
	ld	bc, 9
	ld	iy, (ix - 25)
	jr	.LBB9_34
	.local	.LBB9_38
.LBB9_38:                               ; %.preheader23
                                        ;   in Loop: Header=BB9_24 Depth=1
	ex	de, hl
	ld	de, 2048
	or	a, a
	sbc	hl, de
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	jr	z, .LBB9_43
	.local	.LBB9_39
.LBB9_39:                               ; %.preheader21
                                        ;   Parent Loop BB9_24 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	iyl, e
	ld	iyh, d
	ld	bc, 0
	ld	c, iyl
	ld	b, iyh
	ld	hl, (ix - 17)
	call	__imulu
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 2
	or	a, a
	sbc.sis	hl, bc
	jp	c, .LBB9_26
; %bb.40:                               ; %.preheader21
                                        ;   in Loop: Header=BB9_39 Depth=2
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	dec.sis	de
	ld	bc, 15361
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB9_39
	jp	.LBB9_26
	.local	.LBB9_41
.LBB9_41:                               ;   in Loop: Header=BB9_24 Depth=1
	ld	e, (ix - 14)
	ld	d, (ix - 13)
	inc.sis	de
	ld	l, (ix - 11)
	ld	h, (ix - 10)
	ld	(ix - 22), l
	ld	(ix - 21), h
	.local	.LBB9_42
.LBB9_42:                               ;   in Loop: Header=BB9_24 Depth=1
	ld	(ix - 14), e
	ld	(ix - 13), d
	ld	a, e
	dec	a
	ld	de, (ix - 17)
	push	de
	pop	hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	bc
	ld	iy, _render_wall_scale_profile_index
	add	iy, bc
	ld	(iy), a
	ld	(iy + 1), a
	ld	(iy + 2), a
	ld	(iy + 3), a
	inc	de
	jp	.LBB9_24
	.local	.LBB9_43
.LBB9_43:
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
	.local	.LBB9_44
.LBB9_44:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB9_46
; %bb.45:                               ;   in Loop: Header=BB9_44 Depth=1
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
	jr	.LBB9_44
	.local	.LBB9_46
.LBB9_46:
	ld	bc, 0
	.local	.LBB9_47
.LBB9_47:                               ; %.preheader20
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_49 Depth 2
                                        ;       Child Loop BB9_51 Depth 3
                                        ;       Child Loop BB9_90 Depth 3
                                        ;         Child Loop BB9_92 Depth 4
	ld	de, 4
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_98
; %bb.48:                               ;   in Loop: Header=BB9_47 Depth=1
	ld	(ix - 52), bc
	push	bc
	pop	hl
	ld	c, 7
	call	__ishl
	ld	(ix - 58), hl
	ld	bc, 0
	push	bc
	pop	iy
	xor	a, a
	ld	(ix - 14), a                    ; 1-byte Folded Spill
	ld	(ix - 17), a                    ; 1-byte Folded Spill
	.local	.LBB9_49
.LBB9_49:                               ;   Parent Loop BB9_47 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB9_51 Depth 3
                                        ;       Child Loop BB9_90 Depth 3
                                        ;         Child Loop BB9_92 Depth 4
	push	bc
	pop	hl
	ld	de, 16
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_97
; %bb.50:                               ;   in Loop: Header=BB9_49 Depth=2
	ld	l, 7
	ld	a, c
	and	a, l
	ld	l, a
	ld	(ix - 61), l
	push	bc
	pop	hl
	push	bc
	pop	de
	ld	bc, 7
	call	__iand
	ld	(ix - 64), hl
	ld	l, 1
	ld	(ix - 11), de
	ld	a, e
	and	a, l
	ld	l, a
	ld	e, 6
	ld	a, l
	add	a, e
	ld	l, a
	ld	(ix - 65), l
	ld	(ix - 55), iy
	ld	(ix - 25), iy
	ld	iyh, b
	ld	a, (ix - 14)                    ; 1-byte Folded Reload
	ld	(ix - 49), a                    ; 1-byte Folded Spill
	ld	(ix - 43), a                    ; 1-byte Folded Spill
	push	af
	ld	a, (ix - 17)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 22), bc
	.local	.LBB9_51
.LBB9_51:                               ;   Parent Loop BB9_47 Depth=1
                                        ;     Parent Loop BB9_49 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_89
; %bb.52:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	hl, (ix - 52)
	ld	a, l
	or	a, a
	jp	nz, .LBB9_61
; %bb.53:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	hl, (ix - 11)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	l, 1
	jp	z, .LBB9_58
; %bb.54:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	ld	l, 1
	jp	z, .LBB9_58
; %bb.55:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	hl, (ix - 11)
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB9_57
; %bb.56:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, 0
	.local	.LBB9_57
.LBB9_57:                               ;   in Loop: Header=BB9_51 Depth=3
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
	.local	.LBB9_58
.LBB9_58:                               ;   in Loop: Header=BB9_51 Depth=3
	bit	0, l
	ld	d, 0
	jp	nz, .LBB9_88
; %bb.59:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	hl, (ix - 11)
	push	af
	ld	a, iyh
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	pop	af
	push	af
	ld	a, iyl
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	pop	af
	push	bc
	pop	iy
	ld	bc, (ix - 22)
	ld	a, c
	xor	a, l
	ld	d, a
	lea	bc, iy + 0
	push	af
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	push	af
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	l, e
	ld	h, d
	mlt	hl
	ld	a, iyl
	add	a, l
	ld	l, a
	ld	(ix - 19), e
	ld	(ix - 18), d
	.local	.LBB9_60
.LBB9_60:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, l
	and	a, e
	ld	l, a
	ld	e, 2
	ld	a, l
	add	a, e
	ld	d, a
	jp	.LBB9_88
	.local	.LBB9_61
.LBB9_61:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, l
	cp	a, 1
	jp	nz, .LBB9_73
; %bb.62:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, (ix - 61)                    ; 1-byte Folded Reload
	or	a, a
	ld	a, -1
	jr	z, .LBB9_64
; %bb.63:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, 0
	.local	.LBB9_64
.LBB9_64:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	(ix - 68), a
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, iyh
	and	a, l
	ld	l, a
	or	a, a
	ld	l, -1
	jr	z, .LBB9_66
; %bb.65:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	l, 0
	.local	.LBB9_66
.LBB9_66:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	de, (ix - 64)
	ld	a, e
	cp	a, 2
	jr	z, .LBB9_68
; %bb.67:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	de, (ix - 64)
	ld	a, e
	cp	a, 6
	ld	h, 0
	jr	nz, .LBB9_69
	.local	.LBB9_68
.LBB9_68:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	e, 1
	ld	a, iyh
	and	a, e
	ld	h, a
	.local	.LBB9_69
.LBB9_69:                               ;   in Loop: Header=BB9_51 Depth=3
	bit	0, h
	ld	h, 7
	jr	nz, .LBB9_71
; %bb.70:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	de, (ix - 11)
	push	af
	ld	a, iyh
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	pop	af
	push	af
	ld	a, iyl
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	pop	af
	push	bc
	pop	iy
	ld	bc, (ix - 22)
	ld	a, c
	xor	a, e
	ld	h, a
	lea	bc, iy + 0
	push	af
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	push	af
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, (ix - 43)
	add	a, h
	ld	h, a
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	a, h
	and	a, e
	ld	h, a
	ld	e, 2
	ld	a, h
	add	a, e
	ld	h, a
	.local	.LBB9_71
.LBB9_71:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, (ix - 68)
	or	a, l
	ld	l, a
	bit	0, l
	ld	d, 0
	jp	nz, .LBB9_88
; %bb.72:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	d, h
	jp	.LBB9_88
	.local	.LBB9_73
.LBB9_73:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, l
	cp	a, 2
	jp	nz, .LBB9_84
; %bb.74:                               ;   in Loop: Header=BB9_51 Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	ld	hl, 0
	ex	de, hl
	jr	c, .LBB9_76
; %bb.75:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	hl, 8
	ex	de, hl
	.local	.LBB9_76
.LBB9_76:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	ld	a, -1
	jr	z, .LBB9_78
; %bb.77:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, 0
	.local	.LBB9_78
.LBB9_78:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	(ix - 68), a
	ld	hl, (ix - 11)
	or	a, a
	sbc	hl, de
	ld	h, -1
	jr	z, .LBB9_80
; %bb.79:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	h, 0
	.local	.LBB9_80
.LBB9_80:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	l, 31
	ld	de, (ix - 25)
	ld	a, e
	and	a, l
	ld	l, a
	or	a, a
	ld	l, 1
	jr	z, .LBB9_82
; %bb.81:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	de, (ix - 11)
	push	af
	ld	a, iyh
	ld	(ix - 66), a                    ; 1-byte Folded Spill
	pop	af
	push	af
	ld	a, iyl
	ld	(ix - 67), a                    ; 1-byte Folded Spill
	pop	af
	push	bc
	pop	iy
	ld	bc, (ix - 22)
	ld	a, c
	xor	a, e
	ld	l, a
	lea	bc, iy + 0
	push	af
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	push	af
	ld	a, (ix - 66)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, (ix - 49)
	add	a, l
	ld	l, a
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	a, l
	and	a, e
	ld	l, a
	ld	e, 2
	ld	a, l
	add	a, e
	ld	l, a
	.local	.LBB9_82
.LBB9_82:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, (ix - 68)
	or	a, h
	ld	h, a
	bit	0, h
	ld	d, 0
	jr	nz, .LBB9_88
; %bb.83:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	d, l
	jr	.LBB9_88
	.local	.LBB9_84
.LBB9_84:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	a, (ix - 61)                    ; 1-byte Folded Reload
	or	a, a
	ld	d, 0
	jr	z, .LBB9_88
; %bb.85:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB9_88
; %bb.86:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	l, 6
	ld	a, iyl
	and	a, l
	ld	l, a
	or	a, a
	ld	d, (ix - 65)                    ; 1-byte Folded Reload
	jr	z, .LBB9_88
; %bb.87:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	hl, (ix - 11)
	ld	de, (ix - 22)
	ld	a, e
	xor	a, l
	ld	l, a
	ld	a, iyl
	add	a, l
	ld	l, a
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	jp	.LBB9_60
	.local	.LBB9_88
.LBB9_88:                               ;   in Loop: Header=BB9_51 Depth=3
	ld	hl, (ix - 46)
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
	ld	e, (ix - 43)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 43), e
	ld	l, 6
	ld	e, (ix - 49)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 49), e
	inc	iyh
	ld	de, 10
	ld	hl, (ix - 25)
	add	hl, de
	ld	(ix - 25), hl
	jp	.LBB9_51
	.local	.LBB9_89
.LBB9_89:                               ;   in Loop: Header=BB9_49 Depth=2
	ld	hl, (ix - 11)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, (ix - 58)
	add	hl, de
	ld	(ix - 25), hl
	ld	hl, 1
	ld	(ix - 22), hl
	ld	d, h
	ld	a, d
	ld	de, 0
	.local	.LBB9_90
.LBB9_90:                               ;   Parent Loop BB9_47 Depth=1
                                        ;     Parent Loop BB9_49 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB9_92 Depth 4
	push	de
	pop	hl
	ld	bc, 8
	or	a, a
	sbc	hl, bc
	ld	iy, (ix - 55)
	jr	z, .LBB9_96
; %bb.91:                               ;   in Loop: Header=BB9_90 Depth=3
	push	de
	pop	hl
	push	de
	pop	bc
	ld	de, (ix - 25)
	add	hl, de
	add	hl, hl
	ld	(ix - 61), hl
	ld	hl, (ix - 46)
	ld	(ix - 49), bc
	add	hl, bc
	ld	h, (hl)
	ld	bc, (ix - 22)
	ld	(ix - 43), a                    ; 1-byte Folded Spill
	.local	.LBB9_92
.LBB9_92:                               ;   Parent Loop BB9_47 Depth=1
                                        ;     Parent Loop BB9_49 Depth=2
                                        ;       Parent Loop BB9_90 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ex	de, hl
	ld	iyl, d
	ex	de, hl
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jr	z, .LBB9_94
; %bb.93:                               ;   in Loop: Header=BB9_92 Depth=4
	ld	hl, (ix - 46)
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
	jr	z, .LBB9_92
	jr	.LBB9_95
	.local	.LBB9_94
.LBB9_94:                               ;   in Loop: Header=BB9_90 Depth=3
	ld	e, 8
	ld	a, e
	ex	de, hl
	ld	d, iyl
	ex	de, hl
	.local	.LBB9_95
.LBB9_95:                               ; %.loopexit
                                        ;   in Loop: Header=BB9_90 Depth=3
	ld	l, a
	ld	a, h
	ld	b, 2
	call	__bshl
	ld	iy, _render_wall_texture_runs
	ld	de, (ix - 61)
	add	iy, de
	ld	(iy), a
	ld	(iy + 1), l
	ld	de, (ix - 49)
	inc	de
	ld	a, (ix - 43)                    ; 1-byte Folded Reload
	inc	a
	ld	hl, (ix - 22)
	inc	hl
	ld	(ix - 22), hl
	jr	.LBB9_90
	.local	.LBB9_96
.LBB9_96:                               ;   in Loop: Header=BB9_49 Depth=2
	ld	bc, (ix - 11)
	inc	bc
	inc	(ix - 17)
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	e, (ix - 14)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 14), e
	ld	de, 13
	add	iy, de
	jp	.LBB9_49
	.local	.LBB9_97
.LBB9_97:                               ;   in Loop: Header=BB9_47 Depth=1
	ld	bc, (ix - 52)
	inc	bc
	jp	.LBB9_47
	.local	.LBB9_98
.LBB9_98:
	ld	iy, 0
	.local	.LBB9_99
.LBB9_99:                               ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_101 Depth 2
                                        ;       Child Loop BB9_103 Depth 3
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_107
; %bb.100:                              ;   in Loop: Header=BB9_99 Depth=1
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	(ix - 11), a
	ld	hl, (ix - 37)
	ld	(ix - 14), hl
	ld	hl, (ix - 40)
	ld	(ix - 17), hl
	ld	bc, 0
	.local	.LBB9_101
.LBB9_101:                              ;   Parent Loop BB9_99 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB9_103 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB9_106
; %bb.102:                              ;   in Loop: Header=BB9_101 Depth=2
	ld	(ix - 25), bc
	ld	(ix - 22), iy
	ld	a, (ix - 11)                    ; 1-byte Folded Reload
	ld	iy, (ix - 14)
	ld	de, 0
	.local	.LBB9_103
.LBB9_103:                              ;   Parent Loop BB9_99 Depth=1
                                        ;     Parent Loop BB9_101 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	jr	z, .LBB9_105
; %bb.104:                              ;   in Loop: Header=BB9_103 Depth=3
	lea	hl, iy + 0
	ld	iy, (ix - 17)
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
	jr	.LBB9_103
	.local	.LBB9_105
.LBB9_105:                              ;   in Loop: Header=BB9_101 Depth=2
	ld	bc, (ix - 25)
	inc	bc
	ld	iy, (ix - 17)
	lea	iy, iy + 32
	ld	(ix - 17), iy
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
	jr	.LBB9_101
	.local	.LBB9_106
.LBB9_106:                              ;   in Loop: Header=BB9_99 Depth=1
	inc	iy
	ld	hl, (ix - 40)
	ld	bc, 128
	add	hl, bc
	ld	(ix - 40), hl
	push	de
	pop	bc
	ld	de, 2105376
	ld	hl, (ix - 37)
	add	hl, de
	ld	(ix - 37), hl
	ld	l, d
	ld	e, (ix - 34)
	ld	a, e
	add	a, l
	ld	e, a
	ld	(ix - 34), e
	push	bc
	pop	de
	jp	.LBB9_99
	.local	.LBB9_107
.LBB9_107:
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
	.local	.LBB9_108
.LBB9_108:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_110 Depth 2
                                        ;       Child Loop BB9_112 Depth 3
	push	hl
	pop	iy
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_116
; %bb.109:                              ;   in Loop: Header=BB9_108 Depth=1
	ld	hl, (ix - 31)
	ld	(ix - 11), hl
	or	a, a
	sbc	hl, hl
	push	de
	pop	bc
	ex	de, hl
	.local	.LBB9_110
.LBB9_110:                              ;   Parent Loop BB9_108 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB9_112 Depth 3
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_115
; %bb.111:                              ;   in Loop: Header=BB9_110 Depth=2
	ld	(ix - 25), iy
	ld	hl, _game_graphics_init.shade_offsets
	ld	(ix - 34), de
	add	hl, de
	ld	a, (hl)
	ld	(ix - 17), a
	ld	iy, (ix - 28)
	or	a, a
	sbc	hl, hl
	.local	.LBB9_112
.LBB9_112:                              ;   Parent Loop BB9_108 Depth=1
                                        ;     Parent Loop BB9_110 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	(ix - 22), hl
	ld	de, 16
	or	a, a
	sbc	hl, de
	jp	z, .LBB9_114
; %bb.113:                              ;   in Loop: Header=BB9_112 Depth=3
	ld	a, (iy - 2)
	ld	l, (ix - 17)
	sub	a, l
	ld	l, a
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	b, l
	call	__bshru
	ld	(ix - 14), iy
	ld	e, a
	ld	d, 0
	ld	l, e
	ld	h, d
	ld	c, 10
	call	__sshl
	ld	(ix - 37), l
	ld	(ix - 36), h
	ld	iy, (ix - 14)
	ld	a, (iy - 1)
	ld	c, (ix - 17)                    ; 1-byte Folded Reload
	sub	a, c
	ld	l, a
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	b, l
	call	__bshru
	ld	e, a
	ld	(ix - 40), de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, (ix - 37)
	ld	d, (ix - 36)
	add.sis	hl, de
	ld	iy, (ix - 14)
	ld	a, (iy)
	sub	a, c
	ld	b, a
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	b, e
	call	__bshru
	ld	e, a
	ld	bc, (ix - 40)
	ld	d, b
	add.sis	hl, de
	ld	bc, 4
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
	jp	.LBB9_112
	.local	.LBB9_114
.LBB9_114:                              ;   in Loop: Header=BB9_110 Depth=2
	ld	de, (ix - 34)
	inc	de
	ld	iy, (ix - 11)
	lea	iy, iy + 16
	ld	(ix - 11), iy
	ld	iy, (ix - 25)
	jp	.LBB9_110
	.local	.LBB9_115
.LBB9_115:                              ;   in Loop: Header=BB9_108 Depth=1
	lea	hl, iy + 0
	inc	hl
	ld	iy, (ix - 31)
	lea	iy, iy + 64
	ld	(ix - 31), iy
	ld	iy, (ix - 28)
	lea	iy, iy + 24
	ld	(ix - 28), iy
	push	bc
	pop	de
	jp	.LBB9_108
	.local	.LBB9_116
.LBB9_116:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_game_graphics_init, .Lfunc_end9-_game_graphics_init
                                        ; -- End function
	.section	.text._render_portal_transform_plan_init,"ax",@progbits
	.type	_render_portal_transform_plan_init,@function ; -- Begin function render_portal_transform_plan_init
_render_portal_transform_plan_init:     ; @render_portal_transform_plan_init
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	c, (ix + 15)
	ld	e, (ix + 18)
	ld	b, 2
	ld	hl, _render_portal_transform_flags
	ld	a, (ix + 9)
	call	__bshl
	add	a, e
	ld	b, a
	ld	a, e
	ld	de, 0
	ld	e, b
	add	hl, de
	ld	d, a
	ld	a, (hl)
	ld	(iy + 6), a
	ld	(iy), 0
	ld	(iy + 2), 0
	ld	a, d
	cp	a, 2
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	and	a, 1
	ld	e, a
	ld	a, (ix + 12)
	bit	0, l
	ld	h, a
	jr	nz, .LBB10_2
; %bb.1:
	ld	h, c
	.local	.LBB10_2
.LBB10_2:
	sla	e
	bit	0, l
	jr	nz, .LBB10_4
; %bb.3:
	ld	c, a
	.local	.LBB10_4
.LBB10_4:
	ld	a, l
	and	a, 1
	ld	l, a
	ld	a, e
	cp	a, d
	ld	e, -1
	ld	a, 0
	ld	b, e
	jr	z, .LBB10_6
; %bb.5:
	ld	b, a
	.local	.LBB10_6
.LBB10_6:
	ld	(iy + 1), h
	ld	a, b
	rrc	a
	sbc	a, a
	ld	h, 1
	or	a, h
	ld	h, a
	ld	a, h
	add	a, c
	ld	d, a
	ld	a, c
	or	a, a
	jr	z, .LBB10_8
; %bb.7:
	ld	e, 0
	.local	.LBB10_8
.LBB10_8:
	ld	a, b
	and	a, e
	ld	e, a
	ld	b, 7
	call	__bshl
	rlc	a
	sbc	a, a
	ld	(iy + 3), h
	ld	(iy + 4), d
	ld	(iy + 5), a
	ld	(iy + 7), l
	pop	ix
	ret
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_render_portal_transform_plan_init, .Lfunc_end10-_render_portal_transform_plan_init
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
	jr	c, .LBB11_2
; %bb.1:
	ld	bc, 8191
	.local	.LBB11_2
.LBB11_2:
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
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_grid_projection_init, .Lfunc_end11-_grid_projection_init
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
	jr	nz, .LBB12_2
	.local	.LBB12_1
.LBB12_1:
	ld	c, 0
	jp	.LBB12_29
	.local	.LBB12_2
.LBB12_2:
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
	jr	c, .LBB12_4
; %bb.3:
	push	de
	pop	bc
	.local	.LBB12_4
.LBB12_4:
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
	jr	z, .LBB12_6
; %bb.5:
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_place_portal
	pop	hl
	pop	hl
	.local	.LBB12_6
.LBB12_6:
	ld	bc, 3072
	bit	2, (ix - 3)                     ; 1-byte Folded Reload
	jr	z, .LBB12_8
; %bb.7:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	(iy + 11), 0
	ld	(iy + 15), 0
	.local	.LBB12_8
.LBB12_8:
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
	jp	z, .LBB12_18
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
	jp	p, .LBB12_11
; %bb.10:
	ld	bc, -44
	.local	.LBB12_11
.LBB12_11:
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
	jr	c, .LBB12_15
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
	jp	p, .LBB12_14
; %bb.13:
	ld	iy, -44
	.local	.LBB12_14
.LBB12_14:
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
	jr	nz, .LBB12_18
	.local	.LBB12_15
.LBB12_15:
	ld	de, 255
	ld	hl, (ix - 27)
	add	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .LBB12_17
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
	jr	nz, .LBB12_18
	.local	.LBB12_17
.LBB12_17:
	ld	hl, (ix - 3)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_move_without_portal
	pop	hl
	pop	hl
	.local	.LBB12_18
.LBB12_18:
	ld	c, 1
	ld	iy, (ix + 6)
	ld	hl, (iy)
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB12_29
; %bb.19:
	ld	hl, (iy + 3)
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB12_29
; %bb.20:
	ld	hl, (iy + 6)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	de, (ix - 15)
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB12_29
; %bb.21:
	ld	a, (iy + 8)
	ld	l, (ix - 16)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.22:
	ld	a, (iy + 9)
	ld	l, (ix - 17)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.23:
	ld	a, (iy + 10)
	ld	l, (ix - 18)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.24:
	ld	a, (iy + 11)
	ld	l, (ix - 19)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.25:
	ld	a, (iy + 12)
	ld	l, (ix - 20)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.26:
	ld	a, (iy + 13)
	ld	l, (ix - 21)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.27:
	ld	a, (iy + 14)
	ld	l, (ix - 28)
	cp	a, l
	jr	nz, .LBB12_29
; %bb.28:
	ld	a, (iy + 15)
	ld	l, (ix - 29)
	cp	a, l
	jp	z, .LBB12_1
	.local	.LBB12_29
.LBB12_29:
	ld	a, c
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_game_update, .Lfunc_end12-_game_update
                                        ; -- End function
	.section	.text._place_portal,"ax",@progbits
	.type	_place_portal,@function         ; -- Begin function place_portal
_place_portal:                          ; @place_portal
; %bb.0:
	ld	hl, -44
	call	__frameset
	ld	iy, (ix + 6)
	ld.sis	bc, 16383
	ld	hl, (iy)
	ld	(ix - 20), hl
	ld	hl, (iy + 3)
	ld	(ix - 23), hl
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
	ld	(ix - 32), hl
	ld	a, h
	rlc	a
	sbc	hl, hl
	ld	(ix - 26), hl
	ld.sis	de, 4096
	add.sis	iy, de
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
	ld	(ix - 35), hl
	ld	a, h
	rlc	a
	sbc	hl, hl
	ld	(ix - 29), hl
	ld	hl, (ix + 6)
	push	hl
	call	_render_portal_tables_prepare_dynamic
	ld	iy, (ix + 6)
	pop	hl
	ld	(_render_ray_state+43), iy
	ld	a, (iy + 11)
	or	a, a
	ld	a, -1
	ld	(ix - 17), a                    ; 1-byte Folded Spill
	ld	l, a
	jr	z, .LBB13_2
; %bb.1:
	ld	a, (iy + 9)
	ld	de, 0
	ld	e, a
	ld	hl, _map_row_offsets
	add	hl, de
	ld	l, (hl)
	ld	a, (iy + 8)
	add	a, l
	ld	l, a
	.local	.LBB13_2
.LBB13_2:
	ld	a, l
	ld	(_render_ray_state+46), a
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB13_4
; %bb.3:
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, (iy + 13)
	ld	hl, _map_row_offsets
	add	hl, de
	ld	l, (hl)
	ld	a, (iy + 12)
	add	a, l
	ld	l, a
	ld	(ix - 17), l
	.local	.LBB13_4
.LBB13_4:
	ld	hl, 12
	ld	(ix - 44), hl
	inc	hl
	ld	(ix - 41), hl
	inc	hl
	ld	(ix - 38), hl
	ld	l, 12
	ld	iy, (ix - 26)
	ld	de, (ix - 32)
	ld	iyl, e
	ld	iyh, d
	ld	bc, (ix - 29)
	ld	de, (ix - 35)
	ld	c, e
	ld	b, d
	ld	a, (ix - 17)                    ; 1-byte Folded Reload
	ld	(_render_ray_state+47), a
	.local	.LBB13_5
.LBB13_5:                               ; =>This Inner Loop Header: Depth=1
	ld	a, l
	or	a, a
	jp	z, .LBB13_21
; %bb.6:                                ;   in Loop: Header=BB13_5 Depth=1
	ld	(ix - 17), l                    ; 1-byte Folded Spill
	pea	ix - 14
	push	iy
	push	bc
	ld	hl, (ix - 23)
	push	hl
	ld	hl, (ix - 20)
	push	hl
	call	_render_asm_cast_wall_begin
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_ray_state+54)
	or	a, a
	jr	z, .LBB13_8
; %bb.7:                                ;   in Loop: Header=BB13_5 Depth=1
	call	_render_asm_transform_ray_state
	ld	hl, (_render_ray_state)
	ld	(ix - 20), hl
	ld	hl, (_render_ray_state+3)
	ld	(ix - 23), hl
	ld	bc, (_render_ray_state+6)
	ld	iy, (_render_ray_state+9)
	ld	l, (ix - 17)                    ; 1-byte Folded Reload
	dec	l
	jr	.LBB13_5
	.local	.LBB13_8
.LBB13_8:
	ld	a, (_render_ray_state+52)
	or	a, a
	jr	nz, .LBB13_21
; %bb.9:
	ld	a, (ix + 9)
	or	a, a
	jr	z, .LBB13_11
; %bb.10:
	ld	a, 0
	jr	.LBB13_12
	.local	.LBB13_11
.LBB13_11:
	ld	a, -1
	.local	.LBB13_12
.LBB13_12:
	ld	hl, (ix + 6)
	ld	bc, 15
	bit	0, a
	jr	nz, .LBB13_14
; %bb.13:
	ld	de, 8
	ld	(ix - 44), de
	.local	.LBB13_14
.LBB13_14:
	bit	0, a
	jr	nz, .LBB13_16
; %bb.15:
	ld	de, 9
	ld	(ix - 41), de
	.local	.LBB13_16
.LBB13_16:
	bit	0, a
	jr	nz, .LBB13_18
; %bb.17:
	ld	de, 10
	ld	(ix - 38), de
	.local	.LBB13_18
.LBB13_18:
	ld	e, (ix - 11)
	bit	0, a
	jr	nz, .LBB13_20
; %bb.19:
	ld	bc, 11
	.local	.LBB13_20
.LBB13_20:
	ld	(ix - 17), bc
	push	hl
	pop	iy
	ld	bc, (ix - 44)
	add	iy, bc
	ld	(iy), e
	ld	a, (ix - 10)
	push	hl
	pop	iy
	ld	de, (ix - 41)
	add	iy, de
	ld	(iy), a
	ld	a, (ix - 5)
	push	hl
	pop	iy
	ld	de, (ix - 38)
	add	iy, de
	ld	(iy), a
	ld	de, (ix - 17)
	add	hl, de
	ld	(hl), 1
	.local	.LBB13_21
.LBB13_21:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_place_portal, .Lfunc_end13-_place_portal
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
	jr	nz, .LBB14_4
; %bb.1:
	lea	hl, iy + 0
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	jr	z, .LBB14_13
; %bb.2:
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB14_8
; %bb.3:
	ld	a, 0
	jr	.LBB14_9
	.local	.LBB14_4
.LBB14_4:
	ld	hl, (ix - 15)
	push	de
	pop	bc
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB14_6
; %bb.5:
	ld	l, 0
	jr	.LBB14_7
	.local	.LBB14_6
.LBB14_6:
	ld	l, 1
	.local	.LBB14_7
.LBB14_7:
	ld	(ix - 9), hl
	ld	de, (ix - 15)
	jr	.LBB14_10
	.local	.LBB14_8
.LBB14_8:
	ld	a, 1
	.local	.LBB14_9
.LBB14_9:
	ld	de, (ix - 9)
	ld	l, 2
	add	a, l
	ld	l, a
	ld	(ix - 9), hl
	ld	(ix - 12), iy
	.local	.LBB14_10
.LBB14_10:
	ld	bc, 15
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB14_13
; %bb.11:
	ld	iy, (ix - 12)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB14_13
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
	jr	nz, .LBB14_15
	.local	.LBB14_13
.LBB14_13:
	ld	l, 0
	ld	a, l
	.local	.LBB14_14
.LBB14_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB14_15
.LBB14_15:
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
	jr	nz, .LBB14_17
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
	jp	.LBB14_33
	.local	.LBB14_17
.LBB14_17:
	ld	(ix - 12), bc
	ld	(ix - 20), de
	ld	de, 0
	ld	e, l
	ld	hl, JTI14_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB14_18
.LBB14_18:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	cp	a, 1
	jp	nz, .LBB14_28
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
	jp	.LBB14_36
	.local	.LBB14_20
.LBB14_20:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	or	a, a
	ld	de, (ix - 12)
	jp	z, .LBB14_31
; %bb.21:
	ld	a, l
	cp	a, 3
	jp	nz, .LBB14_32
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
	jp	.LBB14_45
	.local	.LBB14_23
.LBB14_23:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	cp	a, 1
	ld	de, (ix - 12)
	jp	z, .LBB14_31
; %bb.24:
	ld	a, l
	cp	a, 2
	jp	nz, .LBB14_32
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
	jp	.LBB14_44
	.local	.LBB14_26
.LBB14_26:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	or	a, a
	jr	nz, .LBB14_29
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
	jp	.LBB14_35
	.local	.LBB14_28
.LBB14_28:
	ld	a, l
	cp	a, 3
	jr	.LBB14_30
	.local	.LBB14_29
.LBB14_29:
	ld	a, l
	cp	a, 2
	.local	.LBB14_30
.LBB14_30:
	ld	de, (ix - 12)
	jr	nz, .LBB14_32
	.local	.LBB14_31
.LBB14_31:
	ld	hl, 256
	or	a, a
	sbc	hl, de
	ld	(ix - 12), hl
	ld	a, 1
	ld	l, a
	ld	(ix - 17), l
	ld	(ix - 16), h
	jr	.LBB14_33
	.local	.LBB14_32
.LBB14_32:
	ld	l, -1
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	hl, 256
	ld	de, (ix - 20)
	or	a, a
	sbc	hl, de
	ld	(ix - 20), hl
	.local	.LBB14_33
.LBB14_33:
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
	jp	nc, .LBB14_47
; %bb.34:
	ld	e, a
	ld	iy, JTI14_1
	add	iy, de
	add	iy, de
	add	iy, de
	ld	iy, (iy)
	jp	(iy)
	.local	.LBB14_35
.LBB14_35:
	ld	de, -45
	jr	.LBB14_37
	.local	.LBB14_36
.LBB14_36:
	ld	de, 301
	.local	.LBB14_37
.LBB14_37:
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
	jp	m, .LBB14_39
; %bb.38:
	push	bc
	pop	de
	.local	.LBB14_39
.LBB14_39:
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	jp	m, .LBB14_41
; %bb.40:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB14_54
	.local	.LBB14_41
.LBB14_41:
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix + 6)
	jr	c, .LBB14_43
; %bb.42:
	push	bc
	pop	de
	.local	.LBB14_43
.LBB14_43:
	ld	(iy + 3), de
	jr	.LBB14_55
	.local	.LBB14_44
.LBB14_44:
	ld	de, -45
	jr	.LBB14_46
	.local	.LBB14_45
.LBB14_45:
	ld	de, 301
	.local	.LBB14_46
.LBB14_46:
	ld	hl, (ix - 23)
	add	hl, de
	ld	iy, (ix + 6)
	ld	(iy + 3), hl
	.local	.LBB14_47
.LBB14_47:
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
	jp	m, .LBB14_49
; %bb.48:
	push	bc
	pop	de
	.local	.LBB14_49
.LBB14_49:
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	jp	m, .LBB14_51
; %bb.50:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB14_54
	.local	.LBB14_51
.LBB14_51:
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix + 6)
	jr	c, .LBB14_53
; %bb.52:
	push	bc
	pop	de
	.local	.LBB14_53
.LBB14_53:
	ld	(iy), de
	jr	.LBB14_55
	.local	.LBB14_54
.LBB14_54:
	ld	iy, (ix + 6)
	.local	.LBB14_55
.LBB14_55:
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
	jp	.LBB14_14
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_try_player_portal, .Lfunc_end14-_try_player_portal
	.section	.rodata._try_player_portal,"a",@progbits
JTI14_0:
	d24	.LBB14_18
	d24	.LBB14_26
	d24	.LBB14_20
	d24	.LBB14_23
JTI14_1:
	d24	.LBB14_35
	d24	.LBB14_36
	d24	.LBB14_44
	d24	.LBB14_45
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
	jp	c, .LBB15_7
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
	jp	p, .LBB15_3
; %bb.2:
	ld	de, -44
	.local	.LBB15_3
.LBB15_3:
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
	jr	nc, .LBB15_7
; %bb.4:
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	nc, .LBB15_7
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
	jr	nz, .LBB15_7
; %bb.6:
	ld	hl, (ix + 6)
	ld	de, (ix - 15)
	ld	(hl), de
	.local	.LBB15_7
.LBB15_7:
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	ld	de, 255
	add	hl, de
	ld	de, 511
	or	a, a
	sbc	hl, de
	jp	c, .LBB15_14
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
	jp	p, .LBB15_10
; %bb.9:
	ld	hl, -44
	ld	(ix - 9), hl
	.local	.LBB15_10
.LBB15_10:
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
	jr	nc, .LBB15_14
; %bb.11:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB15_14
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
	jr	nz, .LBB15_14
; %bb.13:
	ld	iy, (ix + 6)
	ld	hl, (ix - 6)
	ld	(iy + 3), hl
	.local	.LBB15_14
.LBB15_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_move_without_portal, .Lfunc_end15-_move_without_portal
                                        ; -- End function
	.section	.text._render_portal_tables_prepare_dynamic,"ax",@progbits
	.type	_render_portal_tables_prepare_dynamic,@function ; -- Begin function render_portal_tables_prepare_dynamic
_render_portal_tables_prepare_dynamic:  ; @render_portal_tables_prepare_dynamic
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	iy, (ix + 6)
	ld.sis	de, -1
	ld	a, (iy + 11)
	or	a, a
	ld	(ix - 2), e
	ld	(ix - 1), d
	jp	z, .LBB16_2
; %bb.1:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	a, (iy + 8)
	ld	l, (iy + 9)
	ld	e, (iy + 10)
	ld	b, 0
	ld	c, e
	ld	d, c
	ld	e, b
	ld	c, l
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	c, a
                                        ; kill: def $bc killed $bc killed $ubc
	call	__sor
	ld	c, e
	ld	b, d
	ld.sis	de, -1
	call	__sor
	ld	(ix - 2), l
	ld	(ix - 1), h
	.local	.LBB16_2
.LBB16_2:
	ld	iy, (ix + 6)
	ld	a, (iy + 15)
	or	a, a
	jp	z, .LBB16_4
; %bb.3:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	a, (iy + 12)
	ld	l, (iy + 13)
	ld	e, (iy + 14)
	ld	b, 0
	ld	c, e
	ld	d, c
	ld	e, b
	ld	c, l
	push	bc
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	c, a
                                        ; kill: def $bc killed $bc killed $ubc
	call	__sor
	ld	c, e
	ld	b, d
	call	__sor
	ex.sis	de, hl
	.local	.LBB16_4
.LBB16_4:
	ld	hl, _render_primary_face
	ld	bc, (hl)
	ld	hl, _render_secondary_face
	ld	iy, (hl)
	ld	l, (ix - 2)
	ld	h, (ix - 1)
	ld	(ix - 5), bc
	or	a, a
	sbc.sis	hl, bc
	lea	bc, iy + 0
	jr	nz, .LBB16_6
; %bb.5:
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jp	z, .LBB16_23
	.local	.LBB16_6
.LBB16_6:
	ld	(ix - 8), bc
	ld.sis	bc, -1
	ld	iy, (ix - 5)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 10), e
	ld	(ix - 9), d
	jr	z, .LBB16_8
; %bb.7:
	push	iy
	call	_render_builtin_face_value
	pop	hl
	ld	de, 0
	ld	hl, (ix - 5)
	ld	e, l
	ld	d, h
	ld	hl, _render_portal_faces
	add	hl, de
	ld	e, (ix - 10)
	ld	d, (ix - 9)
	ld	(hl), a
	.local	.LBB16_8
.LBB16_8:
	ld	iy, (ix - 8)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, -1
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB16_10
; %bb.9:
	push	iy
	call	_render_builtin_face_value
	pop	hl
	ld	de, 0
	ld	hl, (ix - 8)
	ld	e, l
	ld	d, h
	ld	hl, _render_portal_faces
	add	hl, de
	ld	e, (ix - 10)
	ld	d, (ix - 9)
	ld	(hl), a
	.local	.LBB16_10
.LBB16_10:
	ld	hl, _render_primary_face
	ld	c, (ix - 2)
	ld	b, (ix - 1)
	ld	(hl), c
	inc	hl
	ld	(hl), b
	ld	hl, _render_secondary_face
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	l, e
	ld	h, d
	ld.sis	bc, -1
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB16_15
; %bb.11:
	ex.sis	de, hl
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	iy, (ix + 6)
	ld	a, (iy + 11)
	or	a, a
	jr	z, .LBB16_13
; %bb.12:
	ld	a, 94
	jr	.LBB16_14
	.local	.LBB16_13
.LBB16_13:
	ld	a, 90
	.local	.LBB16_14
.LBB16_14:
	ld	hl, _render_portal_faces
	add	hl, de
	ld	(hl), a
	.local	.LBB16_15
.LBB16_15:
	ld	l, (ix - 2)
	ld	h, (ix - 1)
	ld.sis	de, -1
	or	a, a
	sbc.sis	hl, de
	jr	z, .LBB16_20
; %bb.16:
	or	a, a
	sbc	hl, hl
	ld	e, (ix - 2)
	ld	d, (ix - 1)
	ld	l, e
	ld	h, d
	ld	iy, (ix + 6)
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB16_18
; %bb.17:
	ld	a, 85
	jr	.LBB16_19
	.local	.LBB16_18
.LBB16_18:
	ld	a, 81
	.local	.LBB16_19
.LBB16_19:
	ex	de, hl
	ld	hl, _render_portal_faces
	add	hl, de
	ld	(hl), a
	.local	.LBB16_20
.LBB16_20:
	ld	iy, (ix + 6)
	ld	a, (iy + 11)
	or	a, a
	jp	z, .LBB16_23
; %bb.21:
	ld	a, (iy + 15)
	or	a, a
	jp	z, .LBB16_23
; %bb.22:
	ld	a, (iy + 10)
	ld	e, (iy + 12)
	ld	c, (iy + 13)
	ld	d, (iy + 14)
	ld	l, d
	push	hl
	ld	l, c
	push	hl
	ld	l, e
	push	hl
	ld	l, a
	push	hl
	ld	hl, _render_portal_transform_plans+80
	push	hl
	call	_render_portal_transform_plan_init
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix + 6)
	ld	a, (iy + 14)
	ld	l, (iy + 8)
	ld	e, (iy + 9)
	ld	c, (iy + 10)
                                        ; kill: def $c killed $c def $ubc
	push	bc
                                        ; kill: def $e killed $e def $ude
	push	de
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	l, a
	push	hl
	ld	hl, _render_portal_transform_plans+88
	push	hl
	call	_render_portal_transform_plan_init
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB16_23
.LBB16_23:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_render_portal_tables_prepare_dynamic, .Lfunc_end16-_render_portal_tables_prepare_dynamic
                                        ; -- End function
	.section	.text._render_builtin_face_value,"ax",@progbits
	.type	_render_builtin_face_value,@function ; -- Begin function render_builtin_face_value
_render_builtin_face_value:             ; @render_builtin_face_value
; %bb.0:
	ld	hl, -4
	call	__frameset
	ld	iy, _render_builtin_portals
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	ld	a, 7
	ld	d, h
	.local	.LBB17_1
.LBB17_1:                               ; =>This Inner Loop Header: Depth=1
	ld	bc, 60
	ld	hl, (ix - 3)
	or	a, a
	sbc	hl, bc
	jr	z, .LBB17_4
; %bb.2:                                ;   in Loop: Header=BB17_1 Depth=1
	ld	bc, (ix - 3)
	add	iy, bc
	ld	l, (iy)
	ld	(ix - 4), l
	ld	c, (iy + 1)
	ld	l, (iy + 2)
	ld	e, l
	ld	iyh, e
	ld	iyl, d
	ld	h, d
	ld	l, c
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, d
	ld	c, (ix - 4)                     ; 1-byte Folded Reload
	call	__sor
	ld	c, iyl
	ld	b, iyh
	call	__sor
	ld	bc, (ix + 6)
	or	a, a
	sbc.sis	hl, bc
	jr	z, .LBB17_5
; %bb.3:                                ;   in Loop: Header=BB17_1 Depth=1
	ld	c, a
	ld	a, 8
	ld	l, a
	ld	a, c
	add	a, l
	ld	c, a
	ld	hl, (ix - 3)
	ld	bc, 6
	add	hl, bc
	ld	(ix - 3), hl
	ld	iy, _render_builtin_portals
	jr	.LBB17_1
	.local	.LBB17_4
.LBB17_4:
	ld	a, d
	.local	.LBB17_5
.LBB17_5:                               ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_render_builtin_face_value, .Lfunc_end17-_render_builtin_face_value
                                        ; -- End function
	.section	.text._game_render,"ax",@progbits
	.globl	_game_render                    ; -- Begin function game_render
	.type	_game_render,@function
_game_render:                           ; @game_render
; %bb.0:
	ld	hl, -85
	call	__frameset
	ld.sis	de, 0
	ld	hl, _render_profile+12
	xor	a, a
	ld.sis	bc, 16383
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	(_render_profile+14), a
	ld	iy, (ix + 6)
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
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	(ix - 27), de
	ld	l, e
	ld	h, d
	ld	(ix - 33), hl
	ld.sis	de, 4096
	add.sis	iy, de
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
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	iy
	ld	(ix - 36), de
	ld	iyl, e
	ld	iyh, d
	ld	hl, (ix - 33)
	ld	de, 256
	add	hl, de
	ld	bc, 65535
	call	__iand
	add	hl, hl
	ex	de, hl
	ld	hl, _render_fov_by_direction
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__ineg
	ld	(ix - 30), hl
	lea	hl, iy + 0
	ld	de, 256
	add	hl, de
	call	__iand
	add	hl, hl
	ex	de, hl
	ld	hl, _render_fov_by_direction
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix - 42), hl
	ld	hl, (ix - 30)
	push	hl
	ld	(ix - 39), iy
	push	iy
	pea	ix - 16
	call	_ray_stepper_init
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 42)
	push	hl
	ld	hl, (ix - 33)
	push	hl
	pea	ix - 24
	call	_ray_stepper_init
	ld	c, -1
	ld	iy, (ix + 6)
	pop	hl
	pop	hl
	pop	hl
	ld	a, (iy + 11)
	or	a, a
	ld	l, c
	jr	z, .LBB18_2
; %bb.1:
	ld	a, (iy + 9)
	ld	de, 0
	ld	e, a
	ld	hl, _map_row_offsets
	add	hl, de
	ld	l, (hl)
	ld	a, (iy + 8)
	add	a, l
	ld	l, a
	.local	.LBB18_2
.LBB18_2:
	ld	a, l
	ld	(_render_scratch+14), a
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB18_4
; %bb.3:
	ld	a, (iy + 13)
	ld	de, 0
	ld	e, a
	ld	hl, _map_row_offsets
	add	hl, de
	ld	l, (hl)
	ld	a, (iy + 12)
	add	a, l
	ld	c, a
	.local	.LBB18_4
.LBB18_4:
	ld	a, c
	ld	(_render_scratch+15), a
	push	iy
	call	_render_portal_tables_prepare_dynamic
	pop	hl
	ld	hl, (ix + 6)
	ld	(_render_ray_state+43), hl
	ld	a, (_render_scratch+14)
	ld	(_render_ray_state+46), a
	ld	a, (_render_scratch+15)
	ld	(_render_ray_state+47), a
	call	_clock
	ld	(ix - 30), hl
	ld	(ix - 42), e                    ; 1-byte Folded Spill
	ld	a, (_render_benchmark_active)
	bit	0, a
	ld	iy, _render_benchmark_last
	lea	hl, iy + 3
	ld	(ix - 75), hl
	ld	iy, _render_benchmark+42
	lea	hl, iy + 3
	ld	(ix - 72), hl
	jp	z, .LBB18_11
; %bb.5:
	ld	a, (_render_benchmark_category)
	cp	a, 1
	jp	z, .LBB18_11
; %bb.6:
	ld	(ix - 45), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB18_8
; %bb.7:
	push	bc
	pop	hl
	jr	.LBB18_10
	.local	.LBB18_8
.LBB18_8:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB18_10
; %bb.9:
	ex	de, hl
	.local	.LBB18_10
.LBB18_10:
	ld	(ix - 48), hl
	ld	iy, 0
	ld	e, iyl
	ld	(ix - 51), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 75)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 45)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 45), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 45)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 72)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 48)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 51)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 1
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+30
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB18_11
.LBB18_11:
	call	_gfx_Wait
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB18_18
; %bb.12:
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	jp	z, .LBB18_18
; %bb.13:
	ld	(ix - 45), l                    ; 1-byte Folded Spill
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
	jr	nc, .LBB18_15
; %bb.14:
	push	bc
	pop	hl
	jr	.LBB18_17
	.local	.LBB18_15
.LBB18_15:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB18_17
; %bb.16:
	ex	de, hl
	.local	.LBB18_17
.LBB18_17:
	ld	(ix - 48), hl
	ld	iy, 0
	ld	e, iyl
	ld	(ix - 51), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 75)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 45)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 45), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 45)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 72)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 48)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 51)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	xor	a, a
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+28
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB18_18
.LBB18_18:
	call	_clock
	ld	(ix - 78), hl
	ld	(ix - 79), e                    ; 1-byte Folded Spill
	ld	bc, (ix - 30)
	ld	a, (ix - 42)                    ; 1-byte Folded Reload
	call	__lsub
	ld	a, e
	ld	(_render_profile), hl
	ld	(_render_profile+3), a
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB18_25
; %bb.19:
	ld	a, (_render_benchmark_category)
	cp	a, 2
	jp	z, .LBB18_25
; %bb.20:
	ld	(ix - 30), a                    ; 1-byte Folded Spill
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
	jr	nc, .LBB18_22
; %bb.21:
	push	bc
	pop	hl
	jr	.LBB18_24
	.local	.LBB18_22
.LBB18_22:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB18_24
; %bb.23:
	ex	de, hl
	.local	.LBB18_24
.LBB18_24:
	ld	(ix - 42), hl
	ld	iy, 0
	ld	e, iyl
	ld	(ix - 45), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 75)
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
	ld	iy, (ix - 72)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 42)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 45)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	ld	a, 2
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+32
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB18_25
.LBB18_25:
	ld	de, 0
	ld	hl, (ix - 36)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	hl, (ix - 39)
	push	hl
	ex	de, hl
	call	nz, _delta_for_component
	ld	(ix - 63), hl
	pop	hl
	ld	hl, (ix - 27)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	de, (ix - 33)
	push	de
	ld	hl, 0
	call	nz, _delta_for_component
	ld	(ix - 30), hl
	pop	hl
	lea	hl, ix - 4
	ld	(ix - 54), hl
	lea	hl, ix - 8
	ld	(ix - 57), hl
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
	ld	a, 8
	lea	hl, iy + 0
	ld	c, a
	call	__ishrs
	call	__ineg
	ld	(ix - 42), hl
	ld	hl, (ix - 33)
	ld	bc, -16
	call	__imulu
	ld	(ix - 33), hl
	ld	de, (ix - 63)
	push	de
	pop	hl
	ld	c, a
	call	__ishru
	ld	(ix - 4), hl
	ld	l, e
	ld	(ix - 1), l
	ld	de, (ix - 30)
	push	de
	pop	hl
	call	__ishru
	ld	bc, (ix - 54)
	ld	(ix - 8), hl
	ld	a, e
	ld	(ix - 5), a
	ld	hl, (ix - 27)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	de, (ix - 57)
	jp	nz, .LBB18_28
; %bb.26:
	ld	hl, (ix + 6)
	ld	hl, (hl)
	call	__ineg
	push	bc
	ld	(ix - 48), hl
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
	jp	p, .LBB18_30
; %bb.27:
	push	bc
	pop	hl
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 63)
	call	__ineg
	ld	(ix - 69), hl
	ld	(ix - 45), de
	ld	(ix - 39), de
	ld	hl, (ix - 48)
	ld	(ix - 66), hl
	ld	iy, (ix + 6)
	jp	.LBB18_36
	.local	.LBB18_28
.LBB18_28:
	ld	bc, (ix - 39)
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
	ld	(ix - 66), hl
	push	de
	ld	(ix - 48), iy
	push	iy
	call	_fixed_scale_mul
	ld	(ix - 45), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 57)
	push	hl
	ld	hl, (ix - 66)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	ld	bc, (ix - 30)
	push	bc
	pop	hl
	call	__ineg
	ld	(ix - 69), hl
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB18_31
; %bb.29:
	ld	hl, (ix - 45)
	call	__ineg
	ld	(ix - 45), hl
	lea	hl, iy + 0
	call	__ineg
	ld	(ix - 39), hl
	ld	(ix - 69), bc
	jr	.LBB18_32
	.local	.LBB18_30
.LBB18_30:
	ld	hl, (ix - 48)
	ld	(ix - 66), hl
	ld	hl, (ix - 63)
	ld	(ix - 69), hl
	ld	(ix - 39), bc
	ld	(ix - 45), bc
	ld	iy, (ix + 6)
	ld	de, (ix - 57)
	ld	bc, (ix - 30)
	jr	.LBB18_33
	.local	.LBB18_31
.LBB18_31:
	ld	(ix - 39), iy
	.local	.LBB18_32
.LBB18_32:
	ld	iy, (ix + 6)
	ld	de, (ix - 57)
	.local	.LBB18_33
.LBB18_33:
	ld	hl, (ix - 36)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jp	nz, .LBB18_36
; %bb.34:
	ld	hl, (iy + 3)
	call	__ineg
	push	de
	ld	(ix - 51), hl
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	bc
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB18_40
; %bb.35:
	push	bc
	pop	hl
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 30)
	call	__ineg
	ld	(ix - 30), hl
	ld	hl, (ix - 51)
	ld	(ix - 60), hl
	ld	(ix - 33), de
	ld	(ix - 42), de
	jp	.LBB18_41
	.local	.LBB18_36
.LBB18_36:
	ld	de, (iy + 3)
	ld	hl, (ix - 42)
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld	hl, (ix - 33)
	or	a, a
	sbc	hl, de
	ld	(ix - 60), hl
	ld	hl, (ix - 54)
	push	hl
	ld	(ix - 51), bc
	push	bc
	call	_fixed_scale_mul
	ld	(ix - 42), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 54)
	push	hl
	ld	hl, (ix - 60)
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
	jp	p, .LBB18_38
; %bb.37:
	ld	hl, (ix - 42)
	call	__ineg
	ld	(ix - 42), hl
	push	bc
	pop	hl
	call	__ineg
	ld	(ix - 33), hl
	ld	hl, (ix - 63)
	call	__ineg
	jr	.LBB18_39
	.local	.LBB18_38
.LBB18_38:
	ld	(ix - 33), bc
	ld	hl, (ix - 63)
	.local	.LBB18_39
.LBB18_39:
	ld	(ix - 30), hl
	jr	.LBB18_41
	.local	.LBB18_40
.LBB18_40:
	ld	hl, (ix - 51)
	ld	(ix - 60), hl
	ld	(ix - 33), bc
	ld	(ix - 42), bc
	.local	.LBB18_41
.LBB18_41:
	call	_render_asm_clear_background
	ld	a, 16
	ld	de, (ix - 27)
	ld	iy, (ix - 39)
	ld	hl, (ix - 48)
	ld	bc, (ix - 45)
	.local	.LBB18_42
.LBB18_42:                              ; =>This Inner Loop Header: Depth=1
	ld	(ix - 63), a                    ; 1-byte Folded Spill
	or	a, a
	jp	z, .LBB18_62
; %bb.43:                               ;   in Loop: Header=BB18_42 Depth=1
	ld	(ix - 48), hl
	sbc.sis	hl, hl
	adc.sis	hl, de
	ld	(ix - 39), iy
	jp	nz, .LBB18_51
; %bb.44:                               ;   in Loop: Header=BB18_42 Depth=1
	push	bc
	pop	hl
	ld	de, -260
	add	hl, de
	ld	de, 3837
	or	a, a
	sbc	hl, de
	jp	nc, .LBB18_47
; %bb.45:                               ;   in Loop: Header=BB18_42 Depth=1
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
	jp	nc, .LBB18_47
; %bb.46:                               ;   in Loop: Header=BB18_42 Depth=1
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
	.local	.LBB18_47
.LBB18_47:                              ;   in Loop: Header=BB18_42 Depth=1
	push	bc
	pop	hl
	ld	de, (ix - 69)
	add	hl, de
	ld	(ix - 45), hl
	ld	hl, (ix - 39)
	add	hl, de
	push	hl
	pop	bc
	ld	hl, (ix - 48)
	push	hl
	pop	iy
	ld	de, 256
	add	iy, de
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB18_60
; %bb.48:                               ;   in Loop: Header=BB18_42 Depth=1
	ld	hl, (ix - 54)
	push	hl
	ld	(ix - 39), iy
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
	jp	m, .LBB18_50
; %bb.49:                               ;   in Loop: Header=BB18_42 Depth=1
	push	de
	pop	iy
	.local	.LBB18_50
.LBB18_50:                              ;   in Loop: Header=BB18_42 Depth=1
	ld	hl, (ix - 39)
	lea	bc, iy + 0
	jp	.LBB18_59
	.local	.LBB18_51
.LBB18_51:                              ;   in Loop: Header=BB18_42 Depth=1
	push	iy
	push	bc
	ld	(ix - 45), bc
	call	_render_asm_add_projected_grid_segment
	pop	hl
	pop	hl
	ld	hl, (ix - 45)
	ld	de, (ix - 69)
	add	hl, de
	ld	(ix - 82), hl
	ld	hl, (ix - 39)
	add	hl, de
	ld	(ix - 39), hl
	ld	bc, (ix - 48)
	push	bc
	pop	iy
	ld	hl, -256
	ex	de, hl
	add	iy, de
	ld	(ix - 45), iy
	ld	iy, (ix - 39)
	ld	hl, (ix - 66)
	add	hl, de
	ld	(ix - 85), hl
	dec	bc
	push	bc
	pop	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	jp	nc, .LBB18_55
; %bb.52:                               ;   in Loop: Header=BB18_42 Depth=1
	ld	hl, (ix - 57)
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
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB18_54
; %bb.53:                               ;   in Loop: Header=BB18_42 Depth=1
	lea	de, iy + 0
	.local	.LBB18_54
.LBB18_54:                              ;   in Loop: Header=BB18_42 Depth=1
	ld	(ix - 82), de
	ld	iy, (ix - 39)
	.local	.LBB18_55
.LBB18_55:                              ;   in Loop: Header=BB18_42 Depth=1
	ld	hl, (ix - 66)
	dec	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	jp	nc, .LBB18_58
; %bb.56:                               ;   in Loop: Header=BB18_42 Depth=1
	ld	hl, (ix - 57)
	push	hl
	ld	hl, (ix - 85)
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
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB18_58
; %bb.57:                               ;   in Loop: Header=BB18_42 Depth=1
	push	de
	pop	iy
	.local	.LBB18_58
.LBB18_58:                              ;   in Loop: Header=BB18_42 Depth=1
	ld	hl, (ix - 85)
	ld	(ix - 66), hl
	ld	hl, (ix - 45)
	ld	bc, (ix - 82)
	.local	.LBB18_59
.LBB18_59:                              ;   in Loop: Header=BB18_42 Depth=1
	ld	de, (ix - 27)
	jr	.LBB18_61
	.local	.LBB18_60
.LBB18_60:                              ;   in Loop: Header=BB18_42 Depth=1
	lea	hl, iy + 0
	ld	de, (ix - 27)
	push	bc
	pop	iy
	ld	bc, (ix - 45)
	.local	.LBB18_61
.LBB18_61:                              ;   in Loop: Header=BB18_42 Depth=1
	ld	a, (ix - 63)                    ; 1-byte Folded Reload
	dec	a
	jp	.LBB18_42
	.local	.LBB18_62
.LBB18_62:
	ld	bc, (ix - 30)
	ld	iy, (ix - 33)
	ld	hl, (ix - 51)
	ld	e, 16
	.local	.LBB18_63
.LBB18_63:                              ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	ld	a, e
	or	a, a
	jp	z, .LBB18_83
; %bb.64:                               ;   in Loop: Header=BB18_63 Depth=1
	ld	(ix - 39), e                    ; 1-byte Folded Spill
	ld	(ix - 51), hl
	ld	hl, (ix - 36)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 33), iy
	jp	nz, .LBB18_72
; %bb.65:                               ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 42)
	ld	de, -260
	add	hl, de
	ld	de, 3837
	or	a, a
	sbc	hl, de
	jp	nc, .LBB18_68
; %bb.66:                               ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, _render_wall_scale_profile_index
	ld	de, (ix - 42)
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
	ld	iy, (hl)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 240
	or	a, a
	sbc.sis	hl, de
	jp	nc, .LBB18_68
; %bb.67:                               ;   in Loop: Header=BB18_63 Depth=1
	ld	a, iyh
	ex	de, hl
	ld	e, iyl
	ex	de, hl
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
	ld	bc, (ix - 30)
	pop	hl
	.local	.LBB18_68
.LBB18_68:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 42)
	add	hl, bc
	ld	(ix - 42), hl
	ld	hl, (ix - 33)
	add	hl, bc
	ld	(ix - 33), hl
	ld	hl, (ix - 51)
	push	hl
	pop	iy
	ld	de, 256
	add	iy, de
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB18_81
; %bb.69:                               ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 57)
	push	hl
	ld	(ix - 33), iy
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
	ld	hl, (ix - 27)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB18_71
; %bb.70:                               ;   in Loop: Header=BB18_63 Depth=1
	push	de
	pop	iy
	.local	.LBB18_71
.LBB18_71:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 33)
	ld	(ix - 42), iy
	jp	.LBB18_80
	.local	.LBB18_72
.LBB18_72:                              ;   in Loop: Header=BB18_63 Depth=1
	push	iy
	ld	hl, (ix - 42)
	push	hl
	call	_render_asm_add_projected_grid_segment
	ld	de, (ix - 30)
	pop	hl
	pop	hl
	ld	hl, (ix - 42)
	add	hl, de
	ld	(ix - 48), hl
	ld	(ix - 30), de
	ld	hl, (ix - 33)
	add	hl, de
	ld	(ix - 33), hl
	ld	de, (ix - 51)
	push	de
	pop	iy
	ld	hl, 256
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 42), iy
	ld	iy, (ix - 33)
	ld	hl, (ix - 60)
	add	hl, bc
	ld	(ix - 45), hl
	ex	de, hl
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB18_76
; %bb.73:                               ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 54)
	push	hl
	ld	hl, (ix - 42)
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
	jp	m, .LBB18_75
; %bb.74:                               ;   in Loop: Header=BB18_63 Depth=1
	lea	de, iy + 0
	.local	.LBB18_75
.LBB18_75:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	(ix - 48), de
	ld	iy, (ix - 33)
	.local	.LBB18_76
.LBB18_76:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 60)
	ld	de, -256
	or	a, a
	sbc	hl, de
	ld	hl, (ix - 54)
	jp	c, .LBB18_79
; %bb.77:                               ;   in Loop: Header=BB18_63 Depth=1
	push	hl
	ld	hl, (ix - 45)
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
	ld	hl, (ix - 36)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB18_79
; %bb.78:                               ;   in Loop: Header=BB18_63 Depth=1
	push	de
	pop	iy
	.local	.LBB18_79
.LBB18_79:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	hl, (ix - 42)
	ld	de, (ix - 45)
	ld	(ix - 60), de
	ld	de, (ix - 48)
	ld	(ix - 42), de
	.local	.LBB18_80
.LBB18_80:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	bc, (ix - 30)
	jr	.LBB18_82
	.local	.LBB18_81
.LBB18_81:                              ;   in Loop: Header=BB18_63 Depth=1
	lea	hl, iy + 0
	ld	iy, (ix - 33)
	.local	.LBB18_82
.LBB18_82:                              ;   in Loop: Header=BB18_63 Depth=1
	ld	e, (ix - 39)                    ; 1-byte Folded Reload
	dec	e
	jp	.LBB18_63
	.local	.LBB18_83
.LBB18_83:
	call	_render_asm_repair_horizon
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB18_90
; %bb.84:
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	jp	z, .LBB18_90
; %bb.85:
	ld	(ix - 27), l                    ; 1-byte Folded Spill
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
	jr	nc, .LBB18_87
; %bb.86:
	push	bc
	pop	hl
	jr	.LBB18_89
	.local	.LBB18_87
.LBB18_87:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	lea	hl, iy + 0
	jr	nc, .LBB18_89
; %bb.88:
	ex	de, hl
	.local	.LBB18_89
.LBB18_89:
	ld	(ix - 30), hl
	ld	iy, 0
	ld	e, iyl
	ld	(ix - 33), e
	ld	bc, (_render_benchmark_last)
	ld	iy, (ix - 75)
	ld	a, (iy)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 27)                    ; 1-byte Folded Reload
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_benchmark
	add	iy, de
	ld	hl, (iy)
	ld	(ix - 27), iy
	lea	iy, iy + 3
	ld	e, (iy)
	call	__ladd
	ld	iy, (ix - 27)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (_render_benchmark+42)
	ld	iy, (ix - 72)
	ld	e, (iy)
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+42), hl
	ld	(_render_benchmark+45), a
	ld	hl, (ix - 30)
	ld	(_render_benchmark_last), hl
	ld	a, (ix - 33)                    ; 1-byte Folded Reload
	ld	(_render_benchmark_last+3), a
	xor	a, a
	ld	(_render_benchmark_category), a
	ld	iy, _render_benchmark+28
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB18_90
.LBB18_90:
	call	_clock
	ld	(ix - 42), hl
	ld	(ix - 45), e                    ; 1-byte Folded Spill
	ld	bc, (ix - 78)
	ld	a, (ix - 79)                    ; 1-byte Folded Reload
	call	__lsub
	ld	a, e
	ld	(_render_profile+4), hl
	ld	(_render_profile+7), a
	ld	hl, (ix - 16)
	ld	(ix - 30), hl
	ld	hl, (ix - 24)
	ld	(ix - 27), hl
	ld	hl, (ix - 13)
	ld	(ix - 48), hl
	ld	a, (ix - 9)
	ld	(ix - 51), a
	ld	hl, (ix - 21)
	ld	(ix - 54), hl
	ld	a, (ix - 17)
	ld	(ix - 57), a
	ld	a, (ix - 10)
	ld	(ix - 33), a
	ld	a, (ix - 18)
	ld	(ix - 36), a
	ld	de, 320
	ld	bc, (ix + 6)
	ld	iy, 0
	.local	.LBB18_91
.LBB18_91:                              ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB18_97
; %bb.92:                               ;   in Loop: Header=BB18_91 Depth=1
	ld	hl, (ix - 27)
	push	hl
	ld	hl, (ix - 30)
	push	hl
	ld	(ix - 39), iy
	push	iy
	push	bc
	call	_render_column
	ld	iy, (ix - 30)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, (ix - 48)
	add	iy, de
	ld	l, (ix - 51)
	ld	c, (ix - 33)                    ; 1-byte Folded Reload
	ld	a, c
	add	a, l
	ld	c, a
	cp	a, 80
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	bit	0, l
	jr	z, .LBB18_94
; %bb.93:                               ;   in Loop: Header=BB18_91 Depth=1
	ld	e, -80
	ld	a, c
	add	a, e
	ld	c, a
	.local	.LBB18_94
.LBB18_94:                              ;   in Loop: Header=BB18_91 Depth=1
	ld	(ix - 33), c
	ld	a, l
	and	a, 1
	ld	de, 0
	ld	e, a
	add	iy, de
	ld	(ix - 30), iy
	ld	hl, (ix - 27)
	ld	de, (ix - 54)
	add	hl, de
	ld	(ix - 27), hl
	ld	l, (ix - 57)
	ld	h, (ix - 36)                    ; 1-byte Folded Reload
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
	ld	iy, (ix - 39)
	jr	z, .LBB18_96
; %bb.95:                               ;   in Loop: Header=BB18_91 Depth=1
	ld	e, -80
	ld	a, h
	add	a, e
	ld	h, a
	.local	.LBB18_96
.LBB18_96:                              ;   in Loop: Header=BB18_91 Depth=1
	ld	(ix - 36), h
	ld	a, l
	and	a, 1
	ld	de, 0
	ld	e, a
	ld	hl, (ix - 27)
	add	hl, de
	ld	(ix - 27), hl
	ld	de, 4
	add	iy, de
	ld	de, 320
	jp	.LBB18_91
	.local	.LBB18_97
.LBB18_97:
	call	_clock
	ld	bc, (ix - 42)
	ld	a, (ix - 45)                    ; 1-byte Folded Reload
	call	__lsub
	ld	a, e
	ld	(_render_profile+8), hl
	ld	(_render_profile+11), a
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_game_render, .Lfunc_end18-_game_render
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
	jp	m, .LBB19_3
; %bb.1:
	ld	bc, 160
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	c, .LBB19_5
; %bb.2:
	ld	l, 96
	ld	bc, 2
	jp	.LBB19_9
	.local	.LBB19_3
.LBB19_3:
	ld	bc, -160
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB19_7
; %bb.4:
	ld	l, -16
	ld	bc, -3
	jp	.LBB19_9
	.local	.LBB19_5
.LBB19_5:
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
	jr	nz, .LBB19_11
; %bb.6:
	push	de
	pop	hl
	ld	c, e
	jr	.LBB19_12
	.local	.LBB19_7
.LBB19_7:
	ld	bc, -80
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB19_16
; %bb.8:
	ld	l, -96
	ld	bc, -2
	.local	.LBB19_9
.LBB19_9:
	ld	(ix - 3), bc
	.local	.LBB19_10
.LBB19_10:
	ld	a, e
	add	a, l
	ld	c, a
	jr	.LBB19_13
	.local	.LBB19_11
.LBB19_11:
	ld	c, -80
	push	de
	pop	hl
	ld	a, e
	add	a, c
	ld	c, a
	.local	.LBB19_12
.LBB19_12:
	ld	iy, 0
	ld	iyl, b
	ld	(ix - 3), iy
	ld	iy, (ix + 9)
	ex	de, hl
	.local	.LBB19_13
.LBB19_13:
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
	jr	c, .LBB19_15
; %bb.14:
	ex	de, hl
	ld	l, -40
	inc	de
	ld	(iy + 3), de
	ld	a, c
	add	a, l
	ld	c, a
	.local	.LBB19_15
.LBB19_15:
	sla	c
	ld	(iy + 7), c
	pop	hl
	pop	ix
	ret
	.local	.LBB19_16
.LBB19_16:
	scf
	sbc	hl, hl
	ld	(ix - 3), hl
	ld	l, 80
	jr	.LBB19_10
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_ray_stepper_init, .Lfunc_end19-_ray_stepper_init
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
	jr	nz, .LBB20_2
; %bb.1:
	ld	hl, 4194303
	jr	.LBB20_7
	.local	.LBB20_2
.LBB20_2:
	ld	bc, 1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB20_4
; %bb.3:
	ld	hl, 65536
	jr	.LBB20_7
	.local	.LBB20_4
.LBB20_4:
	ld	iy, _render_reciprocal_delta
	ld	bc, 425
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ex	de, hl
	jr	c, .LBB20_6
; %bb.5:
	ld	hl, 425
	.local	.LBB20_6
.LBB20_6:
	add	hl, hl
	ex	de, hl
	add	iy, de
	ld	de, (iy)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	.local	.LBB20_7
.LBB20_7:
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_delta_for_component, .Lfunc_end20-_delta_for_component
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
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_fixed_scale_mul, .Lfunc_end21-_fixed_scale_mul
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
	.local	.LBB22_1
.LBB22_1:                               ; =>This Inner Loop Header: Depth=1
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
	jp	z, .LBB22_9
; %bb.2:                                ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 3
	jp	z, .LBB22_9
; %bb.3:                                ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nc, .LBB22_5
; %bb.4:                                ;   in Loop: Header=BB22_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB22_8
	.local	.LBB22_5
.LBB22_5:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_7
; %bb.6:                                ;   in Loop: Header=BB22_1 Depth=1
	push	de
	pop	iy
	.local	.LBB22_7
.LBB22_7:                               ;   in Loop: Header=BB22_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB22_8
.LBB22_8:                               ;   in Loop: Header=BB22_1 Depth=1
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
	.local	.LBB22_9
.LBB22_9:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, e
	or	a, a
	jr	nz, .LBB22_11
; %bb.10:                               ;   in Loop: Header=BB22_1 Depth=1
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
	jr	.LBB22_12
	.local	.LBB22_11
.LBB22_11:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_cast_wall_continue
	.local	.LBB22_12
.LBB22_12:                              ;   in Loop: Header=BB22_1 Depth=1
	pop	hl
	ld	a, (_render_benchmark_active)
	ld	b, a
	bit	0, b
	ld	hl, _render_profile+12
	jp	z, .LBB22_35
; %bb.13:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (_render_benchmark_category)
	ld	l, a
	or	a, a
	ld	(ix - 28), b                    ; 1-byte Folded Spill
	jp	z, .LBB22_20
; %bb.14:                               ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nc, .LBB22_16
; %bb.15:                               ;   in Loop: Header=BB22_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB22_19
	.local	.LBB22_16
.LBB22_16:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_18
; %bb.17:                               ;   in Loop: Header=BB22_1 Depth=1
	push	de
	pop	iy
	.local	.LBB22_18
.LBB22_18:                              ;   in Loop: Header=BB22_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB22_19
.LBB22_19:                              ;   in Loop: Header=BB22_1 Depth=1
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
	.local	.LBB22_20
.LBB22_20:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (_render_ray_state+1)
	ld	e, a
	ld	a, (_render_ray_state+4)
	ld	l, a
	ld	a, (_render_scratch+3)
	ld	c, a
	cp	a, e
	jr	c, .LBB22_22
; %bb.21:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, c
	sub	a, e
	jr	.LBB22_23
	.local	.LBB22_22
.LBB22_22:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, e
	sub	a, c
	.local	.LBB22_23
.LBB22_23:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	e, a
	ld	(ix - 43), e
	ld	a, (_render_scratch+4)
	ld	h, a
	cp	a, l
	jr	c, .LBB22_25
; %bb.24:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, h
	sub	a, l
	jr	.LBB22_26
	.local	.LBB22_25
.LBB22_25:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, l
	sub	a, h
	.local	.LBB22_26
.LBB22_26:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nz, .LBB22_29
; %bb.27:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, d
	cp	a, e
	jr	z, .LBB22_29
; %bb.28:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, d
	cp	a, c
	jr	nz, .LBB22_30
	.local	.LBB22_29
.LBB22_29:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	iy, _render_benchmark+48
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB22_30
.LBB22_30:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nc, .LBB22_32
; %bb.31:                               ;   in Loop: Header=BB22_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB22_34
	.local	.LBB22_32
.LBB22_32:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (-917472)
	ld	(ix - 43), hl
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	lea	hl, iy + 0
	jr	nc, .LBB22_34
; %bb.33:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (ix - 43)
	.local	.LBB22_34
.LBB22_34:                              ;   in Loop: Header=BB22_1 Depth=1
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
	.local	.LBB22_35
.LBB22_35:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	z, .LBB22_40
; %bb.36:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, e
	or	a, a
	ld	a, -1
	jr	nz, .LBB22_38
; %bb.37:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, 0
	.local	.LBB22_38
.LBB22_38:                              ;   in Loop: Header=BB22_1 Depth=1
	bit	0, a
	jr	z, .LBB22_40
; %bb.39:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	iy, _render_benchmark+50
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	iy, (ix - 43)
	.local	.LBB22_40
.LBB22_40:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	(ix - 28), e                    ; 1-byte Folded Spill
	ld	a, c
	ld	(_render_scratch+10), a
	lea	hl, iy + 0
	ld	de, 8191
	or	a, a
	sbc	hl, de
	lea	de, iy + 0
	jr	c, .LBB22_42
; %bb.41:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	de, 8191
	.local	.LBB22_42
.LBB22_42:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jp	z, .LBB22_116
; %bb.43:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, iyl
	cp	a, c
	jp	nc, .LBB22_90
; %bb.44:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	e, (ix - 1)
	ld	c, (ix - 2)
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB22_82
; %bb.45:                               ;   in Loop: Header=BB22_1 Depth=1
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
	jp	nc, .LBB22_54
; %bb.46:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (ix - 12)
	ld	a, l
	cp	a, e
	jr	c, .LBB22_48
; %bb.47:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	e, l
	.local	.LBB22_48
.LBB22_48:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (ix - 28)                    ; 1-byte Folded Reload
	cp	a, c
	ld	l, a
	jr	c, .LBB22_50
; %bb.49:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	l, c
	.local	.LBB22_50
.LBB22_50:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nz, .LBB22_52
; %bb.51:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	bc, 0
	.local	.LBB22_52
.LBB22_52:                              ;   in Loop: Header=BB22_1 Depth=1
	bit	0, a
	jp	nz, .LBB22_62
; %bb.53:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	d, h
	jp	.LBB22_63
	.local	.LBB22_54
.LBB22_54:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (ix - 12)
	ld	a, l
	cp	a, e
	jr	c, .LBB22_56
; %bb.55:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	e, l
	.local	.LBB22_56
.LBB22_56:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	iy, (ix - 25)
	ld	l, (iy + 3)
	ld	a, l
	cp	a, c
	jr	c, .LBB22_58
; %bb.57:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	l, c
	.local	.LBB22_58
.LBB22_58:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nz, .LBB22_60
; %bb.59:                               ;   in Loop: Header=BB22_1 Depth=1
	or	a, a
	sbc	hl, hl
	.local	.LBB22_60
.LBB22_60:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	iy, (ix - 12)
	bit	0, a
	jp	nz, .LBB22_71
; %bb.61:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	e, d
	jp	.LBB22_72
	.local	.LBB22_62
.LBB22_62:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	d, (ix - 9)                     ; 1-byte Folded Reload
	.local	.LBB22_63
.LBB22_63:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	c, .LBB22_65
; %bb.64:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	c, iyl
	.local	.LBB22_65
.LBB22_65:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, d
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB22_67
; %bb.66:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (ix - 16)
	ld	d, l
	.local	.LBB22_67
.LBB22_67:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nz, .LBB22_69
; %bb.68:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	bc, 0
	.local	.LBB22_69
.LBB22_69:                              ;   in Loop: Header=BB22_1 Depth=1
	bit	0, a
	ld	iy, (ix - 12)
	jr	nz, .LBB22_73
; %bb.70:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	a, h
	jr	.LBB22_74
	.local	.LBB22_71
.LBB22_71:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	e, (ix - 9)                     ; 1-byte Folded Reload
	.local	.LBB22_72
.LBB22_72:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	bc, (_render_benchmark+62)
	ld	a, (_render_benchmark+65)
	jr	.LBB22_75
	.local	.LBB22_73
.LBB22_73:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (ix - 9)                     ; 1-byte Folded Reload
	.local	.LBB22_74
.LBB22_74:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	hl, (ix - 55)
	.local	.LBB22_75
.LBB22_75:                              ;   in Loop: Header=BB22_1 Depth=1
	call	__ladd
	ld	a, e
	ld	(_render_benchmark+62), hl
	ld	(_render_benchmark+65), a
	ld	a, (_render_benchmark_category)
	cp	a, 6
	ld	e, (ix - 28)                    ; 1-byte Folded Reload
	ld	c, (ix - 46)                    ; 1-byte Folded Reload
	jp	z, .LBB22_82
; %bb.76:                               ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nc, .LBB22_78
; %bb.77:                               ;   in Loop: Header=BB22_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB22_81
	.local	.LBB22_78
.LBB22_78:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_80
; %bb.79:                               ;   in Loop: Header=BB22_1 Depth=1
	push	de
	pop	iy
	.local	.LBB22_80
.LBB22_80:                              ;   in Loop: Header=BB22_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB22_81
.LBB22_81:                              ;   in Loop: Header=BB22_1 Depth=1
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
	.local	.LBB22_82
.LBB22_82:                              ;   in Loop: Header=BB22_1 Depth=1
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
	jp	z, .LBB22_90
; %bb.83:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (_render_benchmark_category)
	cp	a, 4
	jp	z, .LBB22_90
; %bb.84:                               ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nc, .LBB22_86
; %bb.85:                               ;   in Loop: Header=BB22_1 Depth=1
	push	bc
	pop	hl
	jr	.LBB22_89
	.local	.LBB22_86
.LBB22_86:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_88
; %bb.87:                               ;   in Loop: Header=BB22_1 Depth=1
	push	de
	pop	iy
	.local	.LBB22_88
.LBB22_88:                              ;   in Loop: Header=BB22_1 Depth=1
	lea	hl, iy + 0
	.local	.LBB22_89
.LBB22_89:                              ;   in Loop: Header=BB22_1 Depth=1
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
	.local	.LBB22_90
.LBB22_90:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	c, (ix - 1)
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	cp	a, c
	ld	d, c
	jr	c, .LBB22_92
; %bb.91:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	d, a
	.local	.LBB22_92
.LBB22_92:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	l, (ix - 2)
	ld	a, l
	ld	e, (ix - 31)                    ; 1-byte Folded Reload
	cp	a, e
	ld	a, e
	ld	b, l
	jr	c, .LBB22_94
; %bb.93:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	b, a
	.local	.LBB22_94
.LBB22_94:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, d
	cp	a, b
	jp	nc, .LBB22_129
; %bb.95:                               ;   in Loop: Header=BB22_1 Depth=1
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
	jr	nc, .LBB22_103
; %bb.96:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	(ix - 9), b                     ; 1-byte Folded Spill
	ld	a, iyl
	cp	a, e
	ld	bc, (ix - 16)
	jr	c, .LBB22_98
; %bb.97:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	e, iyl
	.local	.LBB22_98
.LBB22_98:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, l
	sub	a, h
	ld	h, a
	cp	a, c
	ld	l, (ix - 13)                    ; 1-byte Folded Reload
	jr	c, .LBB22_100
; %bb.99:                               ;   in Loop: Header=BB22_1 Depth=1
	ld	h, c
	.local	.LBB22_100
.LBB22_100:                             ;   in Loop: Header=BB22_1 Depth=1
	ld	a, h
	cp	a, e
	ex	de, hl
	ld	iyl, d
	ex	de, hl
	jr	c, .LBB22_102
; %bb.101:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	iyl, e
	.local	.LBB22_102
.LBB22_102:                             ;   in Loop: Header=BB22_1 Depth=1
	ld	b, (ix - 9)                     ; 1-byte Folded Reload
	jp	.LBB22_104
	.local	.LBB22_103
.LBB22_103:                             ;   in Loop: Header=BB22_1 Depth=1
	ld	iy, (ix - 16)
	ex	de, hl
	ld	d, iyl
	ex	de, hl
                                        ; kill: def $iyl killed $iyl killed $uiy def $uiy
	ld	l, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB22_104
.LBB22_104:                             ;   in Loop: Header=BB22_1 Depth=1
	ld	a, l
	cp	a, 5
	jp	z, .LBB22_129
; %bb.105:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, b
	sub	a, d
	ld	l, a
	cp	a, 3
	jp	c, .LBB22_129
; %bb.106:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	(ix - 16), h                    ; 1-byte Folded Spill
	ld	(ix - 25), d                    ; 1-byte Folded Spill
	ld	a, (ix - 47)                    ; 1-byte Folded Reload
	cp	a, 8
	ld	c, (ix - 48)                    ; 1-byte Folded Reload
	jr	c, .LBB22_108
; %bb.107:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	c, (ix - 49)                    ; 1-byte Folded Reload
	.local	.LBB22_108
.LBB22_108:                             ;   in Loop: Header=BB22_1 Depth=1
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
	jp	nz, .LBB22_129
; %bb.109:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	a, (ix - 47)                    ; 1-byte Folded Reload
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	bit	0, a
	ld	l, (ix - 30)
	ld	h, (ix - 29)
	ld	l, h
	jr	nz, .LBB22_111
; %bb.110:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	l, e
	.local	.LBB22_111
.LBB22_111:                             ;   in Loop: Header=BB22_1 Depth=1
	bit	0, a
	jr	nz, .LBB22_113
; %bb.112:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	e, d
	.local	.LBB22_113
.LBB22_113:                             ;   in Loop: Header=BB22_1 Depth=1
	ld	(ix - 9), b                     ; 1-byte Folded Spill
	ld	(ix - 12), iy
	ld	a, (_render_benchmark_active)
	bit	0, a
	jr	z, .LBB22_115
; %bb.114:                              ;   in Loop: Header=BB22_1 Depth=1
	ld	iy, _render_benchmark+52
	ld	bc, (iy)
	inc.sis	bc
	ld	(iy), c
	ld	(iy + 1), b
	.local	.LBB22_115
.LBB22_115:                             ;   in Loop: Header=BB22_1 Depth=1
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
	jp	.LBB22_1
	.local	.LBB22_116
.LBB22_116:
	ld	a, (_render_benchmark_active)
	ld	l, a
	ld	a, iyl
	cp	a, c
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	jp	nc, .LBB22_130
; %bb.117:
	bit	0, l
	jp	z, .LBB22_131
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
	jp	c, .LBB22_120
; %bb.119:
                                        ; kill: def $l killed $l killed $uhl def $uhl
	ld	(ix - 9), hl
	.local	.LBB22_120
.LBB22_120:
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	a, l
	cp	a, c
	jr	c, .LBB22_122
; %bb.121:
	ld	l, c
	.local	.LBB22_122
.LBB22_122:
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
	jr	nz, .LBB22_124
; %bb.123:
	or	a, a
	sbc	hl, hl
	.local	.LBB22_124
.LBB22_124:
	bit	0, a
	ld	(ix - 31), e
	jr	nz, .LBB22_126
; %bb.125:
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	e, d
	.local	.LBB22_126
.LBB22_126:
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
	jp	z, .LBB22_140
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
	jr	nc, .LBB22_136
; %bb.128:
	push	bc
	pop	hl
	jr	.LBB22_139
	.local	.LBB22_129
.LBB22_129:                             ; %.loopexit.loopexit
	ld	a, (_render_benchmark_active)
	ld	c, a
	jp	.LBB22_142
	.local	.LBB22_130
.LBB22_130:
	ld	c, l
	jp	.LBB22_143
	.local	.LBB22_131
.LBB22_131:
	ld	iy, (ix - 25)
	ld	h, (iy + 2)
	ld	l, (iy + 3)
	ld	de, (ix - 12)
	ld	a, e
	cp	a, h
	jr	c, .LBB22_133
; %bb.132:
	ld	h, e
	.local	.LBB22_133
.LBB22_133:
	ld	a, l
	cp	a, c
	jr	c, .LBB22_135
; %bb.134:
	ld	l, c
	.local	.LBB22_135
.LBB22_135:
	ld	e, h
	ld	c, l
	ld	hl, (ix - 25)
	jp	.LBB22_141
	.local	.LBB22_136
.LBB22_136:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_138
; %bb.137:
	push	de
	pop	iy
	.local	.LBB22_138
.LBB22_138:
	lea	hl, iy + 0
	.local	.LBB22_139
.LBB22_139:
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
	.local	.LBB22_140
.LBB22_140:
	ld	hl, (ix - 25)
	ld	de, (ix - 9)
	ld	bc, (ix - 28)
	.local	.LBB22_141
.LBB22_141:
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
	jp	nz, .LBB22_156
	.local	.LBB22_142
.LBB22_142:                             ; %.loopexit
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB22_143
.LBB22_143:                             ; %.loopexit
	ld	a, (_render_benchmark_category)
	ld	l, a
	bit	0, c
	jp	z, .LBB22_153
; %bb.144:                              ; %.loopexit
	ld	a, l
	or	a, a
	jp	z, .LBB22_153
; %bb.145:
	ld	de, 0
	ld	e, l
	ld	(ix - 40), de
	.local	.LBB22_146
.LBB22_146:
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
	jr	nc, .LBB22_148
; %bb.147:
	push	bc
	jr	.LBB22_150
	.local	.LBB22_148
.LBB22_148:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_151
; %bb.149:
	push	de
	.local	.LBB22_150
.LBB22_150:
	pop	iy
	.local	.LBB22_151
.LBB22_151:
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
	.local	.LBB22_152
.LBB22_152:
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	.local	.LBB22_153
.LBB22_153:
	ld	a, (_render_profile+14)
	ld	l, a
	ld	a, e
	cp	a, l
	jr	c, .LBB22_155
; %bb.154:
	inc	e
	ld	a, e
	ld	(_render_profile+14), a
	.local	.LBB22_155
.LBB22_155:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB22_156
.LBB22_156:
	bit	0, c
	jp	z, .LBB22_164
; %bb.157:
	ld	a, (_render_benchmark_category)
	cp	a, 6
	jp	z, .LBB22_164
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
	jr	nc, .LBB22_160
; %bb.159:
	push	bc
	jr	.LBB22_162
	.local	.LBB22_160
.LBB22_160:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_163
; %bb.161:
	push	de
	.local	.LBB22_162
.LBB22_162:
	pop	iy
	.local	.LBB22_163
.LBB22_163:
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
	.local	.LBB22_164
.LBB22_164:
	ld	a, (_render_scratch+10)
	ld	l, a
	or	a, a
	ld	bc, (ix - 12)
	jp	z, .LBB22_194
; %bb.165:
	ld	a, l
	cp	a, 2
	jr	z, .LBB22_167
; %bb.166:
	ld	e, 0
	jr	.LBB22_168
	.local	.LBB22_167
.LBB22_167:
	ld	e, -1
	.local	.LBB22_168
.LBB22_168:
	ld	d, (ix - 1)
	ld	c, (ix - 2)
	ld	a, l
	cp	a, 1
	jr	z, .LBB22_170
; %bb.169:
	ld	l, 15
	ld	a, e
	add	a, l
	ld	l, a
	ld	(ix - 52), hl
	.local	.LBB22_170
.LBB22_170:
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
	jr	c, .LBB22_172
; %bb.171:
	ld	a, l
	.local	.LBB22_172
.LBB22_172:
	ld	(ix - 31), a
	ld	de, 0
	ld	c, (ix - 9)                     ; 1-byte Folded Reload
	ld	e, c
	or	a, a
	sbc	hl, de
	jr	nc, .LBB22_187
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
	jr	c, .LBB22_175
; %bb.174:
	ld	l, a
	ld	(ix - 25), hl
	.local	.LBB22_175
.LBB22_175:
	ld	de, (ix - 12)
	ld	a, e
	cp	a, c
	jr	c, .LBB22_177
; %bb.176:
	ld	c, e
	.local	.LBB22_177
.LBB22_177:
	ld	b, (ix - 31)                    ; 1-byte Folded Reload
	ld	a, b
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB22_179
; %bb.178:
	ld	hl, (ix - 16)
	ld	b, l
	.local	.LBB22_179
.LBB22_179:
	ld	a, c
	cp	a, b
	jr	nc, .LBB22_181
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
	.local	.LBB22_181
.LBB22_181:
	ld	a, e
	ld	bc, (ix - 25)
	cp	a, c
	jr	c, .LBB22_183
; %bb.182:
	ld	c, e
	.local	.LBB22_183
.LBB22_183:
	ld	a, iyl
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB22_185
; %bb.184:
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	.local	.LBB22_185
.LBB22_185:
	ld	a, c
	cp	a, iyl
	jr	nc, .LBB22_194
; %bb.186:
	ld	hl, (ix - 52)
	push	hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	push	hl
	push	bc
	jr	.LBB22_193
	.local	.LBB22_187
.LBB22_187:
	ld	hl, (ix - 12)
	ld	a, l
	ld	e, (ix - 28)                    ; 1-byte Folded Reload
	cp	a, e
	jr	c, .LBB22_189
; %bb.188:
	ld	e, l
	.local	.LBB22_189
.LBB22_189:
	ld	c, (ix - 31)                    ; 1-byte Folded Reload
	ld	a, c
	ld	hl, (ix - 16)
	cp	a, l
	jr	c, .LBB22_191
; %bb.190:
	ld	c, l
	.local	.LBB22_191
.LBB22_191:
	ld	a, e
	cp	a, c
	jr	nc, .LBB22_194
; %bb.192:
	ld	hl, (ix - 52)
	push	hl
	ld	l, c
	push	hl
	ld	l, e
	push	hl
	.local	.LBB22_193
.LBB22_193:
	ld	hl, (ix + 9)
	push	hl
	call	_render_asm_draw_solid_segment
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB22_194
.LBB22_194:
	ld	a, (_render_benchmark_active)
	bit	0, a
	jp	z, .LBB22_152
; %bb.195:
	ld	a, (_render_benchmark_category)
	cp	a, 4
	jp	z, .LBB22_146
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
	jr	nc, .LBB22_198
; %bb.197:
	push	bc
	jr	.LBB22_200
	.local	.LBB22_198
.LBB22_198:
	ld	de, (-917472)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB22_201
; %bb.199:
	push	de
	.local	.LBB22_200
.LBB22_200:
	pop	iy
	.local	.LBB22_201
.LBB22_201:
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
	jp	.LBB22_143
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_render_column, .Lfunc_end22-_render_column
                                        ; -- End function
	.section	.text._game_get_render_profile,"ax",@progbits
	.globl	_game_get_render_profile        ; -- Begin function game_get_render_profile
	.type	_game_get_render_profile,@function
_game_get_render_profile:               ; @game_get_render_profile
; %bb.0:
	ld	hl, _render_profile
	ret
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_game_get_render_profile, .Lfunc_end23-_game_get_render_profile
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	jp	_benchmark_run
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_main, .Lfunc_end24-_main
                                        ; -- End function
	.section	.bss._benchmark_report,"aw",@nobits
	.balign	1
	.local	_benchmark_report
_benchmark_report:
	.zero	6064

	.section	.rodata._benchmark_scenes,"a",@progbits
	.balign	2
	.local	_benchmark_scenes
_benchmark_scenes:
	db	1                               ; 0x1
	db	0                               ; 0x0
	.asciz	"NEAR_WALL\000\000\000"
	d24	384                             ; 0x180
	d24	384                             ; 0x180
	.zero	1
	dw	8192                            ; 0x2000
	.zero	4
	.zero	4
	db	2                               ; 0x2
	db	0                               ; 0x0
	.asciz	"MID_DIRECT\000\000"
	d24	2432                            ; 0x980
	d24	640                             ; 0x280
	.zero	1
	dw	12288                           ; 0x3000
	.zero	4
	.zero	4
	db	3                               ; 0x3
	db	0                               ; 0x0
	.asciz	"LONG_DDA\000\000\000\000"
	d24	896                             ; 0x380
	d24	384                             ; 0x180
	.zero	1
	dw	1536                            ; 0x600
	.zero	4
	.zero	4
	db	4                               ; 0x4
	db	0                               ; 0x0
	.asciz	"PORTAL_CHAIN"
	d24	384                             ; 0x180
	d24	640                             ; 0x280
	.zero	1
	dw	8192                            ; 0x2000
	.zero	4
	.zero	4
	db	5                               ; 0x5
	db	0                               ; 0x0
	.asciz	"PORTAL_WIDE\000"
	d24	1920                            ; 0x780
	d24	1920                            ; 0x780
	.zero	1
	dw	0                               ; 0x0
	.zero	4
	.zero	4
	db	6                               ; 0x6
	db	1                               ; 0x1
	.asciz	"CUSTOM_PAIR\000"
	d24	384                             ; 0x180
	d24	384                             ; 0x180
	.zero	1
	dw	8192                            ; 0x2000
	db	0                               ; 0x0
	db	1                               ; 0x1
	db	1                               ; 0x1
	db	1                               ; 0x1
	db	14                              ; 0xe
	db	10                              ; 0xa
	db	0                               ; 0x0
	db	1                               ; 0x1

	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"Warming up..."

	.section	.bss._benchmark_game,"aw",@nobits
	.balign	2
	.local	_benchmark_game
_benchmark_game:
	.zero	18

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"Clean timing..."

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"Cycle trace..."

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"PortalR benchmark"

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"Scene"

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"/"

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"80 rays / full detail"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"P3DBEN2"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"P3DTMP"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"w"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"P3DRES"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"r+"

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"Benchmark complete"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"Benchmark failed"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"Format: P3DBEN2"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"Build: 0x"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"Result: P3DRES"

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"Archived safely"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"Saved in RAM"

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"Send P3DRES.8xv"

	.section	.rodata._.str.20,"a",@progbits
	.balign	1
	.local	_.str.20
_.str.20:
	.asciz	"back to Codex."

	.section	.rodata._.str.21,"a",@progbits
	.balign	1
	.local	_.str.21
_.str.21:
	.asciz	"Could not save"

	.section	.rodata._.str.22,"a",@progbits
	.balign	1
	.local	_.str.22
_.str.22:
	.asciz	"the result AppVar."

	.section	.rodata._.str.23,"a",@progbits
	.balign	1
	.local	_.str.23
_.str.23:
	.asciz	"Press any key"

	.section	.rodata._benchmark_put_hex32.digits,"a",@progbits
	.balign	1
	.local	_benchmark_put_hex32.digits
_benchmark_put_hex32.digits:
	.asciz	"0123456789ABCDEF"

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

	.section	.bss._render_portal_transform_plans,"aw",@nobits
	.balign	1
	.globl	_render_portal_transform_plans
_render_portal_transform_plans:
	.zero	96

	.section	.bss._render_portal_faces,"aw",@nobits
	.balign	1
	.globl	_render_portal_faces
_render_portal_faces:
	.zero	1024

	.section	.data._render_primary_face,"aw",@progbits
	.balign	2
	.local	_render_primary_face
_render_primary_face:
	dw	65535                           ; 0xffff

	.section	.data._render_secondary_face,"aw",@progbits
	.balign	2
	.local	_render_secondary_face
_render_secondary_face:
	dw	65535                           ; 0xffff

	.section	.rodata._render_portal_transform_flags,"a",@progbits
	.balign	1
	.local	_render_portal_transform_flags
_render_portal_transform_flags:
	.ascii	"\202\000\003\201\000\202\201\003\001\203\202\000\203\001\000\202"

	.section	.rodata._portal_visit_bits,"a",@progbits
	.balign	1
	.local	_portal_visit_bits
_portal_visit_bits:
	.ascii	"\001\002\004\b\020 @\200"

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_os_HomeUp
	.extern	_render_asm_cast_wall_continue
	.extern	__ldivu
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_ti_Rename
	.extern	_gfx_PrintString
	.extern	_ti_GetSize
	.extern	_llvm.lifetime.end.p0
	.extern	_os_SetCursorPos
	.extern	_memcpy
	.extern	_llvm.umin.i32
	.extern	__ishru
	.extern	__sdivu
	.extern	_render_ray_state
	.extern	_render_asm_draw_horizontal_grid_pair
	.extern	__sor
	.extern	__Unwind_SjLj_Unregister
	.extern	_gfx_FillScreen
	.extern	_render_asm_repair_horizon
	.extern	_render_asm_cast_wall_begin
	.extern	__bshru
	.extern	_gfx_PrintStringXY
	.extern	__land
	.extern	_llvm.memset.p0.i64
	.extern	__ineg
	.extern	_gfx_Wait
	.extern	_llvm.umin.i8
	.extern	_llvm.umax.i8
	.extern	__ior
	.extern	_llvm.memset.p0.i24
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_os_GetCSC
	.extern	_gfx_End
	.extern	__lsub
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.abs.i16
	.extern	_llvm.frameaddress.p0
	.extern	_os_DrawStatusBar
	.extern	__lshl
	.extern	_llvm.abs.i24
	.extern	_os_PutStrFull
	.extern	__sand
	.extern	__sxor
	.extern	_llvm.stackrestore.p0
	.extern	_ti_Open
	.extern	_render_asm_draw_wall_segment_registers
	.extern	_render_asm_clear_background
	.extern	__lcmpu
	.extern	_atomic_load_decreasing_32
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_SetTextScale
	.extern	_render_asm_transform_ray_state
	.extern	_gfx_Begin
	.extern	__ladd
	.extern	__idivu
	.extern	_llvm.umin.i24
	.extern	_atomic_load_increasing_32
	.extern	__lxor
	.extern	_clock
	.extern	_render_asm_find_portal
	.extern	_render_asm_add_projected_grid_segment
	.extern	_llvm.smax.i24
	.extern	__irems
	.extern	_gfx_SetTextBGColor
	.extern	_gfx_SwapDraw
	.extern	_llvm.eh.sjlj.lsda
	.extern	_ti_SetArchiveStatus
	.extern	_strlen
	.extern	_render_asm_portal_opening
	.extern	_ti_Delete
	.extern	__frameset
	.extern	__iand
	.extern	__imulu
	.extern	__setflag
	.extern	__lnot
	.extern	_os_ClrLCD
	.extern	_ti_Write
	.extern	_ti_Close
	.extern	_llvm.stacksave.p0
	.extern	_llvm.eh.sjlj.callsite
	.extern	_llvm.lifetime.start.p0
	.extern	_render_asm_draw_portal_mask
	.extern	__lmulu
	.extern	__frameset0
	.extern	_gfx_PrintUInt
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.umin.i16
	.extern	_gfx_SetTextTransparentColor
	.extern	__lshru
	.extern	__sshl
	.extern	__bshl
	.extern	__ishrs
	.extern	__smulu
	.extern	_gfx_SetDraw
	.extern	__ixor
	.extern	__ishl
	.extern	_render_asm_draw_solid_segment
