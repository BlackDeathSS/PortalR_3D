	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
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
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_game_init, .Lfunc_end0-_game_init
                                        ; -- End function
	.section	.text._game_graphics_init,"ax",@progbits
	.globl	_game_graphics_init             ; -- Begin function game_graphics_init
	.type	_game_graphics_init,@function
_game_graphics_init:                    ; @game_graphics_init
; %bb.0:
	ld	hl, -67
	call	__frameset
	ld	iy, 0
	ld	e, 3
	ld	(ix - 19), e
	ld	(ix - 18), d
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
	.local	.LBB1_1
.LBB1_1:                                ; %.loopexit24
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_5 Depth 2
	ld	de, 64
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_12
; %bb.2:                                ;   in Loop: Header=BB1_1 Depth=1
	lea	hl, iy + 0
	add	hl, hl
	ex	de, hl
	lea	bc, iy + 0
	ld	iy, _direction_y
	lea	hl, iy + 0
	add	hl, de
	ld	iy, (hl)
	inc	bc
	ld	(ix - 42), bc
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
	ld	(ix - 48), de
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
	ld	(ix - 17), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	de, 0
	sbc.sis	hl, de
	call	pe, __setflag
	ld.sis	hl, -1
	jp	m, .LBB1_4
; %bb.3:                                ;   in Loop: Header=BB1_1 Depth=1
	ld.sis	hl, 0
	.local	.LBB1_4
.LBB1_4:                                ;   in Loop: Header=BB1_1 Depth=1
	ld	de, (ix - 17)
	ld	e, c
	ld	d, b
	ld	(ix - 17), de
	ld.sis	bc, 1
	call	__sor
	ld	(ix - 54), l
	ld	(ix - 53), h
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 11), hl
	.local	.LBB1_5
.LBB1_5:                                ;   Parent Loop BB1_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	iy, (ix - 42)
	push	bc
	pop	hl
	ld	de, 512
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_11
; %bb.6:                                ;   in Loop: Header=BB1_5 Depth=2
	ld	hl, (ix - 14)
	ld	(ix - 57), bc
	add	hl, bc
	ld	de, (ix - 48)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	bc, (ix - 17)
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
	ld	(ix - 51), iy
	bit	0, a
	jr	nz, .LBB1_8
; %bb.7:                                ;   in Loop: Header=BB1_5 Depth=2
	ld	hl, (ix - 11)
	ld	(ix - 51), hl
	.local	.LBB1_8
.LBB1_8:                                ;   in Loop: Header=BB1_5 Depth=2
	bit	0, a
	ld	l, (ix - 54)
	ld	h, (ix - 53)
	jr	nz, .LBB1_10
; %bb.9:                                ;   in Loop: Header=BB1_5 Depth=2
	ld.sis	hl, 0
	.local	.LBB1_10
.LBB1_10:                               ;   in Loop: Header=BB1_5 Depth=2
	add.sis	hl, de
	ld	iy, (ix - 57)
	ld	de, 2
	add	iy, de
	lea	bc, iy + 0
	ld	de, (ix - 51)
	ld	(ix - 11), de
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 48), hl
	jp	.LBB1_5
	.local	.LBB1_11
.LBB1_11:                               ; %.loopexit24.loopexit
                                        ;   in Loop: Header=BB1_1 Depth=1
	ld	hl, (ix - 14)
	add	hl, de
	ld	(ix - 14), hl
	jp	.LBB1_1
	.local	.LBB1_12
.LBB1_12:
	ld	bc, 257
	ld	a, 8
	ld	de, -256
	or	a, a
	sbc	hl, hl
	ld	(ix - 11), hl
	.local	.LBB1_13
.LBB1_13:                               ; %.preheader23
                                        ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB1_17
; %bb.14:                               ;   in Loop: Header=BB1_13 Depth=1
	ld	hl, (ix - 11)
	ld	c, a
	call	__ishl
	ld	bc, -65536
	add	hl, bc
	ld	c, a
	call	__ishrs
	ld	(ix - 17), hl
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
	pop	de
	ld	bc, 8388352
	call	__iand
	call	__ineg
	push	hl
	pop	iy
	ld	hl, (ix - 17)
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB1_16
; %bb.15:                               ;   in Loop: Header=BB1_13 Depth=1
	push	de
	pop	iy
	.local	.LBB1_16
.LBB1_16:                               ;   in Loop: Header=BB1_13 Depth=1
	lea	hl, iy + 0
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
	jp	.LBB1_13
	.local	.LBB1_17
.LBB1_17:
	or	a, a
	sbc	hl, hl
	ld	(_render_screen_rows), hl
	ld	bc, 76800
	ld	iy, 320
	ld	de, 320
	.local	.LBB1_18
.LBB1_18:                               ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	z, .LBB1_20
; %bb.19:                               ;   in Loop: Header=BB1_18 Depth=1
	lea	hl, iy + 0
	ld	iy, (ix - 22)
	ld	(iy), hl
	add	hl, de
	lea	iy, iy + 4
	ld	(ix - 22), iy
	push	hl
	pop	iy
	jr	.LBB1_18
	.local	.LBB1_20
.LBB1_20:
	ld.sis	hl, 960
	ld	(ix - 11), l
	ld	(ix - 10), h
	ld.sis	hl, 0
	ld	e, l
	ld	d, h
	ld	(ix - 14), de
	ld	(ix - 25), l
	ld	(ix - 24), h
	ld	de, 0
	.local	.LBB1_21
.LBB1_21:                               ; %.preheader22
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_24 Depth 2
                                        ;     Child Loop BB1_36 Depth 2
	sbc	hl, hl
	adc	hl, de
	ld	(ix - 17), de
	jr	nz, .LBB1_23
; %bb.22:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	c, (ix - 11)
	ld	b, (ix - 10)
	jr	.LBB1_27
	.local	.LBB1_23
.LBB1_23:                               ; %.preheader22
                                        ;   in Loop: Header=BB1_21 Depth=1
	ex	de, hl
	ld	de, 2048
	or	a, a
	sbc	hl, de
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	jp	z, .LBB1_42
	.local	.LBB1_24
.LBB1_24:                               ; %.preheader20
                                        ;   Parent Loop BB1_21 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	iyl, e
	ld	iyh, d
	ld	bc, 0
	ld	c, iyl
	ld	b, iyh
	ld	hl, (ix - 17)
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
	jr	c, .LBB1_26
; %bb.25:                               ; %.preheader20
                                        ;   in Loop: Header=BB1_24 Depth=2
	ld	e, iyl
	ld	d, iyh
	dec.sis	de
	push	bc
	pop	hl
	ld	bc, 15361
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB1_24
	.local	.LBB1_26
.LBB1_26:                               ; %.loopexit21.loopexit
                                        ;   in Loop: Header=BB1_21 Depth=1
	ld	c, iyl
	ld	b, iyh
	.local	.LBB1_27
.LBB1_27:                               ; %.loopexit21
                                        ;   in Loop: Header=BB1_21 Depth=1
	ld	l, c
	ld	h, b
	ld	e, (ix - 25)
	ld	d, (ix - 24)
	or	a, a
	sbc.sis	hl, de
	ld	(ix - 11), c
	ld	(ix - 10), b
	jr	nz, .LBB1_29
; %bb.28:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	hl, (ix - 14)
	jp	.LBB1_41
	.local	.LBB1_29
.LBB1_29:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	de, 0
	ld	hl, (ix - 14)
	ld	e, l
	ld	d, h
	ld	(ix - 25), de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	iy, _render_wall_scale_profiles
	add	iy, de
	ld.sis	hl, 2048
	ld	c, (ix - 11)
	ld	b, (ix - 10)
	call	__sdivu
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	ld	(ix - 42), l
	ld	(ix - 41), h
	ld	l, e
	ld	h, d
	ld.sis	bc, 240
	or	a, a
	sbc.sis	hl, bc
	ld	l, e
	ld	h, d
	jr	c, .LBB1_31
; %bb.30:                               ;   in Loop: Header=BB1_21 Depth=1
	ld.sis	hl, 240
	.local	.LBB1_31
.LBB1_31:                               ;   in Loop: Header=BB1_21 Depth=1
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
	jr	nz, .LBB1_33
; %bb.32:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	c, h
	.local	.LBB1_33
.LBB1_33:                               ;   in Loop: Header=BB1_21 Depth=1
	bit	0, l
	ld	e, -16
	ld	a, e
	jr	nz, .LBB1_35
; %bb.34:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	a, h
	add	a, d
	ld	l, a
	.local	.LBB1_35
.LBB1_35:                               ;   in Loop: Header=BB1_21 Depth=1
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
	.local	.LBB1_36
.LBB1_36:                               ;   Parent Loop BB1_21 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB1_40
; %bb.37:                               ;   in Loop: Header=BB1_36 Depth=2
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
	jr	c, .LBB1_39
; %bb.38:                               ;   in Loop: Header=BB1_36 Depth=2
	ld	iy, (ix - 42)
	.local	.LBB1_39
.LBB1_39:                               ;   in Loop: Header=BB1_36 Depth=2
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
	jr	.LBB1_36
	.local	.LBB1_40
.LBB1_40:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	hl, (ix - 14)
	inc.sis	hl
	ld	e, (ix - 11)
	ld	d, (ix - 10)
	ld	(ix - 25), e
	ld	(ix - 24), d
	.local	.LBB1_41
.LBB1_41:                               ;   in Loop: Header=BB1_21 Depth=1
	ld	(ix - 14), hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld.sis	de, -8
	add.sis	hl, de
	ld	(ix - 22), l
	ld	(ix - 21), h
	ld	de, (ix - 17)
	push	de
	pop	hl
	add	hl, hl
	push	hl
	pop	bc
	ld	iy, _render_wall_scale_offset
	add	iy, bc
	ld	l, (ix - 22)
	ld	h, (ix - 21)
	ld	(iy), l
	ld	(iy + 1), h
	inc	de
	jp	.LBB1_21
	.local	.LBB1_42
.LBB1_42:
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
	.local	.LBB1_43
.LBB1_43:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB1_45
; %bb.44:                               ;   in Loop: Header=BB1_43 Depth=1
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
	jr	.LBB1_43
	.local	.LBB1_45
.LBB1_45:
	ld	bc, 0
	.local	.LBB1_46
.LBB1_46:                               ; %.preheader19
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_48 Depth 2
                                        ;       Child Loop BB1_50 Depth 3
                                        ;       Child Loop BB1_89 Depth 3
                                        ;         Child Loop BB1_91 Depth 4
	ld	de, 4
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_97
; %bb.47:                               ;   in Loop: Header=BB1_46 Depth=1
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
	ld	(ix - 17), a                    ; 1-byte Folded Spill
	.local	.LBB1_48
.LBB1_48:                               ;   Parent Loop BB1_46 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB1_50 Depth 3
                                        ;       Child Loop BB1_89 Depth 3
                                        ;         Child Loop BB1_91 Depth 4
	push	de
	pop	hl
	ld	bc, 16
	or	a, a
	sbc	hl, bc
	jp	z, .LBB1_96
; %bb.49:                               ;   in Loop: Header=BB1_48 Depth=2
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
	ld	a, (ix - 17)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	or	a, a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	(ix - 22), bc
	.local	.LBB1_50
.LBB1_50:                               ;   Parent Loop BB1_46 Depth=1
                                        ;     Parent Loop BB1_48 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_88
; %bb.51:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	hl, (ix - 51)
	ld	a, l
	or	a, a
	ld	de, (ix - 11)
	jp	nz, .LBB1_60
; %bb.52:                               ;   in Loop: Header=BB1_50 Depth=3
	sbc	hl, hl
	adc	hl, de
	ld	l, 1
	jp	z, .LBB1_57
; %bb.53:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	ld	l, 1
	jp	z, .LBB1_57
; %bb.54:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	hl, (ix - 11)
	ld	de, 8
	or	a, a
	sbc	hl, de
	ld	a, -1
	jr	z, .LBB1_56
; %bb.55:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, 0
	.local	.LBB1_56
.LBB1_56:                               ;   in Loop: Header=BB1_50 Depth=3
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
	.local	.LBB1_57
.LBB1_57:                               ;   in Loop: Header=BB1_50 Depth=3
	bit	0, l
	ld	d, 0
	jp	nz, .LBB1_87
; %bb.58:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	e, (ix - 19)
	ld	d, (ix - 18)
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
	ld	(ix - 19), e
	ld	(ix - 18), d
	.local	.LBB1_59
.LBB1_59:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, l
	and	a, e
	ld	l, a
	ld	e, 2
	ld	a, l
	add	a, e
	ld	d, a
	jp	.LBB1_87
	.local	.LBB1_60
.LBB1_60:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, l
	cp	a, 1
	jp	nz, .LBB1_72
; %bb.61:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, (ix - 60)                    ; 1-byte Folded Reload
	or	a, a
	ld	a, -1
	jr	z, .LBB1_63
; %bb.62:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, 0
	.local	.LBB1_63
.LBB1_63:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	(ix - 67), a
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, iyh
	and	a, l
	ld	l, a
	or	a, a
	ld	l, -1
	jr	z, .LBB1_65
; %bb.64:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	l, 0
	.local	.LBB1_65
.LBB1_65:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	de, (ix - 63)
	ld	a, e
	cp	a, 2
	jr	z, .LBB1_67
; %bb.66:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	de, (ix - 63)
	ld	a, e
	cp	a, 6
	ld	h, 0
	jr	nz, .LBB1_68
	.local	.LBB1_67
.LBB1_67:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	e, 1
	ld	a, iyh
	and	a, e
	ld	h, a
	.local	.LBB1_68
.LBB1_68:                               ;   in Loop: Header=BB1_50 Depth=3
	bit	0, h
	ld	h, 7
	jr	nz, .LBB1_70
; %bb.69:                               ;   in Loop: Header=BB1_50 Depth=3
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
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	a, h
	and	a, e
	ld	h, a
	ld	e, 2
	ld	a, h
	add	a, e
	ld	h, a
	.local	.LBB1_70
.LBB1_70:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, (ix - 67)
	or	a, l
	ld	l, a
	bit	0, l
	ld	d, 0
	jp	nz, .LBB1_87
; %bb.71:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	d, h
	jp	.LBB1_87
	.local	.LBB1_72
.LBB1_72:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, l
	cp	a, 2
	jp	nz, .LBB1_83
; %bb.73:                               ;   in Loop: Header=BB1_50 Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	ld	hl, 0
	ex	de, hl
	jr	c, .LBB1_75
; %bb.74:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	hl, 8
	ex	de, hl
	.local	.LBB1_75
.LBB1_75:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	ld	a, -1
	ld	hl, (ix - 11)
	jr	z, .LBB1_77
; %bb.76:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, 0
	.local	.LBB1_77
.LBB1_77:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	(ix - 67), a
	or	a, a
	sbc	hl, de
	ld	h, -1
	jr	z, .LBB1_79
; %bb.78:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	h, 0
	.local	.LBB1_79
.LBB1_79:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	l, 31
	ld	de, (ix - 25)
	ld	a, e
	and	a, l
	ld	l, a
	or	a, a
	ld	l, 1
	jr	z, .LBB1_81
; %bb.80:                               ;   in Loop: Header=BB1_50 Depth=3
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
	ld	e, (ix - 19)
	ld	d, (ix - 18)
	ld	a, l
	and	a, e
	ld	l, a
	ld	e, 2
	ld	a, l
	add	a, e
	ld	l, a
	.local	.LBB1_81
.LBB1_81:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, (ix - 67)
	or	a, h
	ld	h, a
	bit	0, h
	ld	d, 0
	jr	nz, .LBB1_87
; %bb.82:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	d, l
	jr	.LBB1_87
	.local	.LBB1_83
.LBB1_83:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	a, (ix - 60)                    ; 1-byte Folded Reload
	or	a, a
	ld	d, 0
	jr	z, .LBB1_87
; %bb.84:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, c
	and	a, l
	ld	l, a
	or	a, a
	jr	z, .LBB1_87
; %bb.85:                               ;   in Loop: Header=BB1_50 Depth=3
	ld	l, 6
	ld	a, iyl
	and	a, l
	ld	l, a
	or	a, a
	ld	d, (ix - 64)                    ; 1-byte Folded Reload
	jr	z, .LBB1_87
; %bb.86:                               ;   in Loop: Header=BB1_50 Depth=3
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
	jp	.LBB1_59
	.local	.LBB1_87
.LBB1_87:                               ;   in Loop: Header=BB1_50 Depth=3
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
	jp	.LBB1_50
	.local	.LBB1_88
.LBB1_88:                               ;   in Loop: Header=BB1_48 Depth=2
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
	.local	.LBB1_89
.LBB1_89:                               ;   Parent Loop BB1_46 Depth=1
                                        ;     Parent Loop BB1_48 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB1_91 Depth 4
	push	de
	pop	hl
	ld	bc, 8
	or	a, a
	sbc	hl, bc
	ld	iy, (ix - 54)
	jr	z, .LBB1_95
; %bb.90:                               ;   in Loop: Header=BB1_89 Depth=3
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
	.local	.LBB1_91
.LBB1_91:                               ;   Parent Loop BB1_46 Depth=1
                                        ;     Parent Loop BB1_48 Depth=2
                                        ;       Parent Loop BB1_89 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ex	de, hl
	ld	iyl, d
	ex	de, hl
	push	bc
	pop	hl
	ld	de, 8
	or	a, a
	sbc	hl, de
	jr	z, .LBB1_93
; %bb.92:                               ;   in Loop: Header=BB1_91 Depth=4
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
	jr	z, .LBB1_91
	jr	.LBB1_94
	.local	.LBB1_93
.LBB1_93:                               ;   in Loop: Header=BB1_89 Depth=3
	ld	e, 8
	ld	a, e
	ex	de, hl
	ld	d, iyl
	ex	de, hl
	.local	.LBB1_94
.LBB1_94:                               ; %.loopexit
                                        ;   in Loop: Header=BB1_89 Depth=3
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
	jr	.LBB1_89
	.local	.LBB1_95
.LBB1_95:                               ;   in Loop: Header=BB1_48 Depth=2
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
	push	bc
	pop	de
	jp	.LBB1_48
	.local	.LBB1_96
.LBB1_96:                               ;   in Loop: Header=BB1_46 Depth=1
	ld	bc, (ix - 51)
	inc	bc
	jp	.LBB1_46
	.local	.LBB1_97
.LBB1_97:
	ld	iy, 0
	.local	.LBB1_98
.LBB1_98:                               ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_100 Depth 2
                                        ;       Child Loop BB1_102 Depth 3
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_106
; %bb.99:                               ;   in Loop: Header=BB1_98 Depth=1
	ld	a, (ix - 33)                    ; 1-byte Folded Reload
	ld	(ix - 11), a
	ld	hl, (ix - 36)
	ld	(ix - 14), hl
	ld	hl, (ix - 39)
	ld	(ix - 17), hl
	ld	bc, 0
	.local	.LBB1_100
.LBB1_100:                              ;   Parent Loop BB1_98 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB1_102 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB1_105
; %bb.101:                              ;   in Loop: Header=BB1_100 Depth=2
	ld	(ix - 25), bc
	ld	(ix - 22), iy
	ld	a, (ix - 11)                    ; 1-byte Folded Reload
	ld	iy, (ix - 14)
	ld	de, 0
	.local	.LBB1_102
.LBB1_102:                              ;   Parent Loop BB1_98 Depth=1
                                        ;     Parent Loop BB1_100 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	jr	z, .LBB1_104
; %bb.103:                              ;   in Loop: Header=BB1_102 Depth=3
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
	jr	.LBB1_102
	.local	.LBB1_104
.LBB1_104:                              ;   in Loop: Header=BB1_100 Depth=2
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
	jr	.LBB1_100
	.local	.LBB1_105
.LBB1_105:                              ;   in Loop: Header=BB1_98 Depth=1
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
	jp	.LBB1_98
	.local	.LBB1_106
.LBB1_106:
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
	.local	.LBB1_107
.LBB1_107:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_109 Depth 2
                                        ;       Child Loop BB1_111 Depth 3
	ld	(ix - 17), hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_115
; %bb.108:                              ;   in Loop: Header=BB1_107 Depth=1
	ld	hl, (ix - 31)
	ld	(ix - 11), hl
	ld	bc, 0
	.local	.LBB1_109
.LBB1_109:                              ;   Parent Loop BB1_107 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB1_111 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_114
; %bb.110:                              ;   in Loop: Header=BB1_109 Depth=2
	ld	hl, _game_graphics_init.shade_offsets
	ld	(ix - 25), bc
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 39), a
	ld	iy, (ix - 28)
	or	a, a
	sbc	hl, hl
	.local	.LBB1_111
.LBB1_111:                              ;   Parent Loop BB1_107 Depth=1
                                        ;     Parent Loop BB1_109 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	(ix - 22), hl
	ld	de, 16
	or	a, a
	sbc	hl, de
	jp	z, .LBB1_113
; %bb.112:                              ;   in Loop: Header=BB1_111 Depth=3
	ld	a, (iy - 2)
	ld	c, (ix - 39)                    ; 1-byte Folded Reload
	sub	a, c
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
	ld	l, (ix - 19)
	ld	h, (ix - 18)
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
	ld	e, (ix - 19)
	ld	d, (ix - 18)
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
	jp	.LBB1_111
	.local	.LBB1_113
.LBB1_113:                              ;   in Loop: Header=BB1_109 Depth=2
	ld	bc, (ix - 25)
	inc	bc
	ld	iy, (ix - 11)
	lea	iy, iy + 16
	ld	(ix - 11), iy
	ld	de, 4
	jp	.LBB1_109
	.local	.LBB1_114
.LBB1_114:                              ;   in Loop: Header=BB1_107 Depth=1
	ld	hl, (ix - 17)
	inc	hl
	ld	iy, (ix - 31)
	lea	iy, iy + 64
	ld	(ix - 31), iy
	ld	iy, (ix - 28)
	lea	iy, iy + 24
	ld	(ix - 28), iy
	jp	.LBB1_107
	.local	.LBB1_115
.LBB1_115:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_game_graphics_init, .Lfunc_end1-_game_graphics_init
                                        ; -- End function
	.section	.text._grid_projection_init,"ax",@progbits
	.type	_grid_projection_init,@function ; -- Begin function grid_projection_init
_grid_projection_init:                  ; @grid_projection_init
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, (ix + 9)
	ld	de, _render_wall_scale_profiles
	ld	c, 2
	call	__ishru
	push	hl
	pop	iy
	ld	bc, 2047
	or	a, a
	sbc	hl, bc
	jr	c, .LBB2_2
; %bb.1:
	ld	iy, 2047
	.local	.LBB2_2
.LBB2_2:
	add	iy, iy
	lea	bc, iy + 0
	ld	hl, _render_wall_scale_offset
	add	hl, bc
	ld	hl, (hl)
	ld	bc, 0
	ld	c, l
	ld	b, h
	ex	de, hl
	add	hl, bc
	ld	hl, (hl)
	ld	(ix - 3), hl
	ld	iy, (ix + 6)
	ld	(iy + 6), l
	ld	(iy + 7), h
	ld	a, h
	srl	a
	ld	d, l
	rr	d
	ld	e, d
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
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_grid_projection_init, .Lfunc_end2-_grid_projection_init
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
	jr	nz, .LBB3_2
	.local	.LBB3_1
.LBB3_1:
	ld	c, 0
	jp	.LBB3_29
	.local	.LBB3_2
.LBB3_2:
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
	jr	c, .LBB3_4
; %bb.3:
	push	de
	pop	bc
	.local	.LBB3_4
.LBB3_4:
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
	jr	z, .LBB3_6
; %bb.5:
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_place_portal
	pop	hl
	pop	hl
	.local	.LBB3_6
.LBB3_6:
	ld	bc, 3072
	bit	2, (ix - 3)                     ; 1-byte Folded Reload
	jr	z, .LBB3_8
; %bb.7:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	(iy + 11), 0
	ld	(iy + 15), 0
	.local	.LBB3_8
.LBB3_8:
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
	jp	z, .LBB3_18
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
	jp	p, .LBB3_11
; %bb.10:
	ld	bc, -44
	.local	.LBB3_11
.LBB3_11:
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
	jr	c, .LBB3_15
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
	jp	p, .LBB3_14
; %bb.13:
	ld	iy, -44
	.local	.LBB3_14
.LBB3_14:
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
	jr	nz, .LBB3_18
	.local	.LBB3_15
.LBB3_15:
	ld	de, 255
	ld	hl, (ix - 27)
	add	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .LBB3_17
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
	jr	nz, .LBB3_18
	.local	.LBB3_17
.LBB3_17:
	ld	hl, (ix - 3)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	call	_move_without_portal
	pop	hl
	pop	hl
	.local	.LBB3_18
.LBB3_18:
	ld	c, 1
	ld	iy, (ix + 6)
	ld	hl, (iy)
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB3_29
; %bb.19:
	ld	hl, (iy + 3)
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	jp	nz, .LBB3_29
; %bb.20:
	ld	hl, (iy + 6)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	de, (ix - 15)
	or	a, a
	sbc.sis	hl, de
	jr	nz, .LBB3_29
; %bb.21:
	ld	a, (iy + 8)
	ld	l, (ix - 16)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.22:
	ld	a, (iy + 9)
	ld	l, (ix - 17)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.23:
	ld	a, (iy + 10)
	ld	l, (ix - 18)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.24:
	ld	a, (iy + 11)
	ld	l, (ix - 19)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.25:
	ld	a, (iy + 12)
	ld	l, (ix - 20)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.26:
	ld	a, (iy + 13)
	ld	l, (ix - 21)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.27:
	ld	a, (iy + 14)
	ld	l, (ix - 28)
	cp	a, l
	jr	nz, .LBB3_29
; %bb.28:
	ld	a, (iy + 15)
	ld	l, (ix - 29)
	cp	a, l
	jp	z, .LBB3_1
	.local	.LBB3_29
.LBB3_29:
	ld	a, c
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_game_update, .Lfunc_end3-_game_update
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
	jr	z, .LBB4_2
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
	.local	.LBB4_2
.LBB4_2:
	ld	a, c
	ld	(_render_ray_state+46), a
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB4_4
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
	.local	.LBB4_4
.LBB4_4:
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
	.local	.LBB4_5
.LBB4_5:                                ; =>This Inner Loop Header: Depth=1
	ld	a, c
	or	a, a
	jp	z, .LBB4_21
; %bb.6:                                ;   in Loop: Header=BB4_5 Depth=1
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
	jr	z, .LBB4_8
; %bb.7:                                ;   in Loop: Header=BB4_5 Depth=1
	call	_render_asm_transform_ray_state
	ld	hl, (_render_ray_state)
	ld	(ix - 17), hl
	ld	hl, (_render_ray_state+3)
	ld	(ix - 20), hl
	ld	hl, (_render_ray_state+6)
	ld	iy, (_render_ray_state+9)
	ld	c, (ix - 23)                    ; 1-byte Folded Reload
	dec	c
	jr	.LBB4_5
	.local	.LBB4_8
.LBB4_8:
	ld	a, (_render_ray_state+52)
	or	a, a
	jr	nz, .LBB4_21
; %bb.9:
	ld	a, (ix + 9)
	or	a, a
	jr	z, .LBB4_11
; %bb.10:
	ld	a, 0
	jr	.LBB4_12
	.local	.LBB4_11
.LBB4_11:
	ld	a, -1
	.local	.LBB4_12
.LBB4_12:
	ld	hl, (ix + 6)
	ld	bc, 15
	bit	0, a
	jr	nz, .LBB4_14
; %bb.13:
	ld	de, 8
	ld	(ix - 38), de
	.local	.LBB4_14
.LBB4_14:
	bit	0, a
	jr	nz, .LBB4_16
; %bb.15:
	ld	de, 9
	ld	(ix - 35), de
	.local	.LBB4_16
.LBB4_16:
	bit	0, a
	jr	nz, .LBB4_18
; %bb.17:
	ld	de, 10
	ld	(ix - 32), de
	.local	.LBB4_18
.LBB4_18:
	ld	e, (ix - 11)
	bit	0, a
	jr	nz, .LBB4_20
; %bb.19:
	ld	bc, 11
	.local	.LBB4_20
.LBB4_20:
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
	.local	.LBB4_21
.LBB4_21:                               ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_place_portal, .Lfunc_end4-_place_portal
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
	jr	nz, .LBB5_4
; %bb.1:
	lea	hl, iy + 0
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	jr	z, .LBB5_13
; %bb.2:
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB5_8
; %bb.3:
	ld	a, 0
	jr	.LBB5_9
	.local	.LBB5_4
.LBB5_4:
	ld	hl, (ix - 15)
	push	de
	pop	bc
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB5_6
; %bb.5:
	ld	l, 0
	jr	.LBB5_7
	.local	.LBB5_6
.LBB5_6:
	ld	l, 1
	.local	.LBB5_7
.LBB5_7:
	ld	(ix - 9), hl
	ld	de, (ix - 15)
	jr	.LBB5_10
	.local	.LBB5_8
.LBB5_8:
	ld	a, 1
	.local	.LBB5_9
.LBB5_9:
	ld	de, (ix - 9)
	ld	l, 2
	add	a, l
	ld	l, a
	ld	(ix - 9), hl
	ld	(ix - 12), iy
	.local	.LBB5_10
.LBB5_10:
	ld	bc, 15
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB5_13
; %bb.11:
	ld	iy, (ix - 12)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB5_13
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
	jr	nz, .LBB5_15
	.local	.LBB5_13
.LBB5_13:
	ld	l, 0
	ld	a, l
	.local	.LBB5_14
.LBB5_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB5_15
.LBB5_15:
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
	jr	nz, .LBB5_17
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
	jp	.LBB5_33
	.local	.LBB5_17
.LBB5_17:
	ld	(ix - 12), bc
	ld	(ix - 20), de
	ld	de, 0
	ld	e, l
	ld	hl, JTI5_0
	add	hl, de
	add	hl, de
	add	hl, de
	ld	hl, (hl)
	jp	(hl)
	.local	.LBB5_18
.LBB5_18:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	cp	a, 1
	jp	nz, .LBB5_28
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
	jp	.LBB5_36
	.local	.LBB5_20
.LBB5_20:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	or	a, a
	ld	de, (ix - 12)
	jp	z, .LBB5_31
; %bb.21:
	ld	a, l
	cp	a, 3
	jp	nz, .LBB5_32
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
	jp	.LBB5_45
	.local	.LBB5_23
.LBB5_23:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	cp	a, 1
	ld	de, (ix - 12)
	jp	z, .LBB5_31
; %bb.24:
	ld	a, l
	cp	a, 2
	jp	nz, .LBB5_32
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
	jp	.LBB5_44
	.local	.LBB5_26
.LBB5_26:
	ld	l, (ix - 15)                    ; 1-byte Folded Reload
	ld	a, l
	or	a, a
	jr	nz, .LBB5_29
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
	jp	.LBB5_35
	.local	.LBB5_28
.LBB5_28:
	ld	a, l
	cp	a, 3
	jr	.LBB5_30
	.local	.LBB5_29
.LBB5_29:
	ld	a, l
	cp	a, 2
	.local	.LBB5_30
.LBB5_30:
	ld	de, (ix - 12)
	jr	nz, .LBB5_32
	.local	.LBB5_31
.LBB5_31:
	ld	hl, 256
	or	a, a
	sbc	hl, de
	ld	(ix - 12), hl
	ld	a, 1
	ld	l, a
	ld	(ix - 17), l
	ld	(ix - 16), h
	jr	.LBB5_33
	.local	.LBB5_32
.LBB5_32:
	ld	l, -1
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	hl, 256
	ld	de, (ix - 20)
	or	a, a
	sbc	hl, de
	ld	(ix - 20), hl
	.local	.LBB5_33
.LBB5_33:
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
	jp	nc, .LBB5_47
; %bb.34:
	ld	e, a
	ld	iy, JTI5_1
	add	iy, de
	add	iy, de
	add	iy, de
	ld	iy, (iy)
	jp	(iy)
	.local	.LBB5_35
.LBB5_35:
	ld	de, -45
	jr	.LBB5_37
	.local	.LBB5_36
.LBB5_36:
	ld	de, 301
	.local	.LBB5_37
.LBB5_37:
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
	jp	m, .LBB5_39
; %bb.38:
	push	bc
	pop	de
	.local	.LBB5_39
.LBB5_39:
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	jp	m, .LBB5_41
; %bb.40:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB5_54
	.local	.LBB5_41
.LBB5_41:
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix + 6)
	jr	c, .LBB5_43
; %bb.42:
	push	bc
	pop	de
	.local	.LBB5_43
.LBB5_43:
	ld	(iy + 3), de
	jr	.LBB5_55
	.local	.LBB5_44
.LBB5_44:
	ld	de, -45
	jr	.LBB5_46
	.local	.LBB5_45
.LBB5_45:
	ld	de, 301
	.local	.LBB5_46
.LBB5_46:
	ld	hl, (ix - 23)
	add	hl, de
	ld	iy, (ix + 6)
	ld	(iy + 3), hl
	.local	.LBB5_47
.LBB5_47:
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
	jp	m, .LBB5_49
; %bb.48:
	push	bc
	pop	de
	.local	.LBB5_49
.LBB5_49:
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	jp	m, .LBB5_51
; %bb.50:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB5_54
	.local	.LBB5_51
.LBB5_51:
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix + 6)
	jr	c, .LBB5_53
; %bb.52:
	push	bc
	pop	de
	.local	.LBB5_53
.LBB5_53:
	ld	(iy), de
	jr	.LBB5_55
	.local	.LBB5_54
.LBB5_54:
	ld	iy, (ix + 6)
	.local	.LBB5_55
.LBB5_55:
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
	jp	.LBB5_14
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_try_player_portal, .Lfunc_end5-_try_player_portal
	.section	.rodata._try_player_portal,"a",@progbits
JTI5_0:
	d24	.LBB5_18
	d24	.LBB5_26
	d24	.LBB5_20
	d24	.LBB5_23
JTI5_1:
	d24	.LBB5_35
	d24	.LBB5_36
	d24	.LBB5_44
	d24	.LBB5_45
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
	jp	c, .LBB6_7
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
	jp	p, .LBB6_3
; %bb.2:
	ld	de, -44
	.local	.LBB6_3
.LBB6_3:
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
	jr	nc, .LBB6_7
; %bb.4:
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jr	nc, .LBB6_7
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
	jr	nz, .LBB6_7
; %bb.6:
	ld	hl, (ix + 6)
	ld	de, (ix - 15)
	ld	(hl), de
	.local	.LBB6_7
.LBB6_7:
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	ld	de, 255
	add	hl, de
	ld	de, 511
	or	a, a
	sbc	hl, de
	jp	c, .LBB6_14
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
	jp	p, .LBB6_10
; %bb.9:
	ld	hl, -44
	ld	(ix - 9), hl
	.local	.LBB6_10
.LBB6_10:
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
	jr	nc, .LBB6_14
; %bb.11:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB6_14
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
	jr	nz, .LBB6_14
; %bb.13:
	ld	iy, (ix + 6)
	ld	hl, (ix - 6)
	ld	(iy + 3), hl
	.local	.LBB6_14
.LBB6_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_move_without_portal, .Lfunc_end6-_move_without_portal
                                        ; -- End function
	.section	.text._game_render,"ax",@progbits
	.globl	_game_render                    ; -- Begin function game_render
	.type	_game_render,@function
_game_render:                           ; @game_render
; %bb.0:
	ld	hl, -80
	call	__frameset
	call	_gfx_Wait
	ld	iy, (ix + 6)
	ld	iy, (iy + 6)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld.sis	bc, 16383
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
	ld	(ix - 30), de
	ld	l, e
	ld	h, d
	ld	(ix - 36), hl
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
	ld	(ix - 39), de
	ld	iyl, e
	ld	iyh, d
	ld	hl, (ix - 36)
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
	ex	de, hl
	lea	hl, iy + 0
	ld	bc, 256
	add	hl, bc
	ld	bc, 65535
	call	__iand
	add	hl, hl
	push	hl
	pop	bc
	ld	hl, _render_fov_by_direction
	add	hl, bc
	ld	bc, (hl)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 33), hl
	push	de
	ld	(ix - 42), iy
	push	iy
	pea	ix - 19
	call	_ray_stepper_init
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 33)
	push	hl
	ld	hl, (ix - 36)
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
	jr	z, .LBB7_2
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
	.local	.LBB7_2
.LBB7_2:
	ld	a, l
	ld	(_render_scratch+14), a
	ld	a, (iy + 15)
	or	a, a
	jr	z, .LBB7_4
; %bb.3:
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
	.local	.LBB7_4
.LBB7_4:
	ld	de, 0
	ld	a, c
	ld	(_render_scratch+15), a
	ld	(_render_ray_state+43), iy
	ld	a, l
	ld	(_render_ray_state+46), a
	ld	a, c
	ld	(_render_ray_state+47), a
	ld	hl, (ix - 39)
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
	ld	de, (ix - 36)
	push	de
	ld	hl, 0
	call	nz, _delta_for_component
	ld	(ix - 48), hl
	pop	hl
	lea	hl, ix - 4
	ld	(ix - 33), hl
	lea	hl, ix - 8
	ld	(ix - 57), hl
	ld	hl, (ix - 36)
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
	ld	(ix - 60), hl
	ld	hl, (ix - 36)
	ld	bc, -16
	call	__imulu
	ld	(ix - 36), hl
	ld	a, (_render_grid_near_projection+8)
	ld	(ix - 73), a                    ; 1-byte Folded Spill
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
	ld	de, (ix - 48)
	push	de
	pop	hl
	call	__ishru
	ld	bc, (ix - 33)
	ld	(ix - 8), hl
	ld	a, e
	ld	(ix - 5), a
	ld	hl, (ix - 30)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	de, (ix - 57)
	jp	nz, .LBB7_7
; %bb.5:
	ld	hl, (ix + 6)
	ld	hl, (hl)
	call	__ineg
	push	bc
	ld	(ix - 51), hl
	push	hl
	call	_fixed_scale_mul
	ex	de, hl
	pop	hl
	pop	hl
	ld	hl, (ix - 39)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB7_9
; %bb.6:
	ex	de, hl
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 63)
	call	__ineg
	ld	(ix - 72), hl
	ld	(ix - 45), de
	ld	(ix - 54), de
	ld	hl, (ix - 51)
	ld	(ix - 69), hl
	ld	iy, (ix + 6)
	jp	.LBB7_14
	.local	.LBB7_7
.LBB7_7:
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
	ld	hl, (ix - 57)
	push	hl
	ld	hl, (ix - 69)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	ld	de, (ix - 48)
	push	de
	pop	hl
	call	__ineg
	ld	(ix - 72), hl
	ld	hl, (ix - 30)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB7_10
; %bb.8:
	ld	hl, (ix - 45)
	call	__ineg
	ld	(ix - 45), hl
	lea	hl, iy + 0
	call	__ineg
	ld	(ix - 54), hl
	ld	(ix - 72), de
	jr	.LBB7_11
	.local	.LBB7_9
.LBB7_9:
	ld	hl, (ix - 51)
	ld	(ix - 69), hl
	ld	hl, (ix - 63)
	ld	(ix - 72), hl
	ld	(ix - 54), de
	ld	(ix - 45), de
	jr	.LBB7_11
	.local	.LBB7_10
.LBB7_10:
	ld	(ix - 54), iy
	.local	.LBB7_11
.LBB7_11:
	ld	iy, (ix + 6)
	ld	de, (ix - 57)
	ld	hl, (ix - 39)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jp	nz, .LBB7_14
; %bb.12:
	ld	hl, (iy + 3)
	call	__ineg
	push	de
	ld	(ix - 36), hl
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
	jp	p, .LBB7_18
; %bb.13:
	push	bc
	pop	hl
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 48)
	call	__ineg
	ld	(ix - 48), hl
	ld	hl, (ix - 36)
	ld	(ix - 66), hl
	ld	(ix - 60), de
	ld	(ix - 42), de
	jp	.LBB7_19
	.local	.LBB7_14
.LBB7_14:
	ld	de, (iy + 3)
	ld	hl, (ix - 60)
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld	hl, (ix - 36)
	or	a, a
	sbc	hl, de
	ld	(ix - 36), hl
	ld	hl, (ix - 33)
	push	hl
	ld	(ix - 66), bc
	push	bc
	call	_fixed_scale_mul
	ld	(ix - 42), hl
	pop	hl
	pop	hl
	ld	hl, (ix - 33)
	push	hl
	ld	hl, (ix - 36)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	bc
	pop	hl
	pop	hl
	ld	hl, (ix - 39)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB7_16
; %bb.15:
	ld	hl, (ix - 42)
	call	__ineg
	ld	(ix - 42), hl
	push	bc
	pop	hl
	call	__ineg
	ld	(ix - 60), hl
	ld	hl, (ix - 63)
	call	__ineg
	jr	.LBB7_17
	.local	.LBB7_16
.LBB7_16:
	ld	(ix - 60), bc
	ld	hl, (ix - 63)
	.local	.LBB7_17
.LBB7_17:
	ld	(ix - 48), hl
	jr	.LBB7_19
	.local	.LBB7_18
.LBB7_18:
	ld	hl, (ix - 36)
	ld	(ix - 66), hl
	ld	(ix - 60), bc
	ld	(ix - 42), bc
	.local	.LBB7_19
.LBB7_19:
	lea	hl, ix - 11
	ld	(ix - 63), hl
	call	_render_asm_clear_background
	ld	hl, 4
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	e, 16
	ld	bc, (ix - 30)
	ld	iy, (ix - 33)
	ld	hl, (ix - 51)
	.local	.LBB7_20
.LBB7_20:                               ; =>This Inner Loop Header: Depth=1
	ld	a, e
	or	a, a
	jp	z, .LBB7_42
; %bb.21:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	(ix - 74), e                    ; 1-byte Folded Spill
	ld	(ix - 51), hl
	sbc.sis	hl, hl
	adc.sis	hl, bc
	jp	nz, .LBB7_29
; %bb.22:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 45)
	ld	de, -260
	add	hl, de
	ld	de, 3837
	or	a, a
	sbc	hl, de
	jp	nc, .LBB7_25
; %bb.23:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 45)
	ld	c, 2
	call	__ishru
	add	hl, hl
	ex	de, hl
	ld	hl, _render_wall_scale_offset
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _render_wall_scale_profiles
	add	hl, de
	ld	de, (hl)
	ld	l, e
	ld	h, d
	ld.sis	bc, 240
	or	a, a
	sbc.sis	hl, bc
	jp	nc, .LBB7_25
; %bb.24:                               ;   in Loop: Header=BB7_20 Depth=1
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
	ld	iy, (ix - 33)
	pop	hl
	.local	.LBB7_25
.LBB7_25:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	de, (ix - 72)
	ld	hl, (ix - 45)
	add	hl, de
	ld	(ix - 45), hl
	ld	hl, (ix - 54)
	add	hl, de
	ld	(ix - 54), hl
	ld	hl, (ix - 51)
	push	hl
	pop	iy
	ld	de, 256
	add	iy, de
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB7_37
; %bb.26:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 33)
	push	hl
	ld	(ix - 45), iy
	push	iy
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	lea	hl, iy + 0
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 39)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB7_28
; %bb.27:                               ;   in Loop: Header=BB7_20 Depth=1
	lea	de, iy + 0
	.local	.LBB7_28
.LBB7_28:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 45)
	ld	(ix - 54), de
	ld	(ix - 45), de
	jp	.LBB7_39
	.local	.LBB7_29
.LBB7_29:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 54)
	push	hl
	ld	hl, (ix - 45)
	push	hl
	ld	hl, (ix - 63)
	push	hl
	call	_render_asm_add_projected_grid_segment
	pop	hl
	pop	hl
	pop	hl
	ld	de, (ix - 72)
	ld	hl, (ix - 45)
	add	hl, de
	ld	(ix - 45), hl
	ld	hl, (ix - 54)
	add	hl, de
	ld	(ix - 54), hl
	ld	bc, (ix - 51)
	push	bc
	pop	iy
	ld	hl, -256
	ex	de, hl
	add	iy, de
	ld	(ix - 77), iy
	ld	iy, (ix - 69)
	add	iy, de
	dec	bc
	push	bc
	pop	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	ld	(ix - 80), iy
	jp	nc, .LBB7_33
; %bb.30:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 57)
	push	hl
	ld	hl, (ix - 77)
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
	jp	m, .LBB7_32
; %bb.31:                               ;   in Loop: Header=BB7_20 Depth=1
	lea	de, iy + 0
	.local	.LBB7_32
.LBB7_32:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	(ix - 45), de
	ld	iy, (ix - 80)
	.local	.LBB7_33
.LBB7_33:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 69)
	dec	hl
	ld	de, 256
	or	a, a
	sbc	hl, de
	jr	nc, .LBB7_38
; %bb.34:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 57)
	push	hl
	push	iy
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	lea	hl, iy + 0
	call	__ineg
	ld	(ix - 54), hl
	ld	bc, (ix - 30)
	ld	l, c
	ld	h, b
	ld.sis	de, 0
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB7_36
; %bb.35:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	(ix - 54), iy
	.local	.LBB7_36
.LBB7_36:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	hl, (ix - 80)
	ld	(ix - 69), hl
	ld	hl, (ix - 77)
	jr	.LBB7_40
	.local	.LBB7_37
.LBB7_37:                               ;   in Loop: Header=BB7_20 Depth=1
	lea	hl, iy + 0
	ld	bc, (ix - 30)
	ld	e, (ix - 74)                    ; 1-byte Folded Reload
	ld	iy, (ix - 33)
	jr	.LBB7_41
	.local	.LBB7_38
.LBB7_38:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	(ix - 69), iy
	ld	hl, (ix - 77)
	.local	.LBB7_39
.LBB7_39:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	bc, (ix - 30)
	.local	.LBB7_40
.LBB7_40:                               ;   in Loop: Header=BB7_20 Depth=1
	ld	iy, (ix - 33)
	ld	e, (ix - 74)                    ; 1-byte Folded Reload
	.local	.LBB7_41
.LBB7_41:                               ;   in Loop: Header=BB7_20 Depth=1
	dec	e
	jp	.LBB7_20
	.local	.LBB7_42
.LBB7_42:
	ld	de, (ix - 36)
	ld	b, 16
	.local	.LBB7_43
.LBB7_43:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	ld	a, b
	or	a, a
	jp	z, .LBB7_65
; %bb.44:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 39)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	ld	(ix - 36), de
	jp	nz, .LBB7_52
; %bb.45:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 42)
	ld	de, -260
	add	hl, de
	ld	de, 3837
	or	a, a
	sbc	hl, de
	jp	nc, .LBB7_48
; %bb.46:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 42)
	ld	c, 2
	call	__ishru
	add	hl, hl
	ex	de, hl
	ld	hl, _render_wall_scale_offset
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
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
	jp	nc, .LBB7_48
; %bb.47:                               ;   in Loop: Header=BB7_43 Depth=1
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
	ld	(ix - 45), b                    ; 1-byte Folded Spill
	call	_render_asm_draw_horizontal_grid_pair
	ld	b, (ix - 45)                    ; 1-byte Folded Reload
	pop	hl
	.local	.LBB7_48
.LBB7_48:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	de, (ix - 48)
	ld	hl, (ix - 42)
	add	hl, de
	ld	(ix - 42), hl
	ld	hl, (ix - 60)
	add	hl, de
	ld	(ix - 60), hl
	ld	hl, (ix - 66)
	push	hl
	pop	iy
	ld	de, 256
	add	iy, de
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB7_60
; %bb.49:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	(ix - 45), b                    ; 1-byte Folded Spill
	ld	hl, (ix - 57)
	push	hl
	ld	(ix - 42), iy
	push	iy
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
	jp	m, .LBB7_51
; %bb.50:                               ;   in Loop: Header=BB7_43 Depth=1
	lea	de, iy + 0
	.local	.LBB7_51
.LBB7_51:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 42)
	ld	(ix - 66), hl
	ld	(ix - 60), de
	ld	(ix - 42), de
	ld	de, (ix - 36)
	jp	.LBB7_63
	.local	.LBB7_52
.LBB7_52:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	(ix - 45), b                    ; 1-byte Folded Spill
	ld	hl, (ix - 60)
	push	hl
	ld	hl, (ix - 42)
	push	hl
	ld	hl, (ix - 63)
	push	hl
	call	_render_asm_add_projected_grid_segment
	pop	hl
	pop	hl
	pop	hl
	ld	de, (ix - 48)
	ld	hl, (ix - 42)
	add	hl, de
	ld	(ix - 42), hl
	ld	hl, (ix - 60)
	add	hl, de
	ld	(ix - 60), hl
	ld	de, (ix - 66)
	push	de
	pop	iy
	ld	hl, 256
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 51), iy
	ld	iy, (ix - 36)
	add	iy, bc
	ex	de, hl
	ld	de, -256
	or	a, a
	sbc	hl, de
	ld	hl, (ix - 36)
	ld	(ix - 54), iy
	jp	c, .LBB7_56
; %bb.53:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 33)
	push	hl
	ld	hl, (ix - 51)
	push	hl
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	lea	hl, iy + 0
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 39)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB7_55
; %bb.54:                               ;   in Loop: Header=BB7_43 Depth=1
	lea	de, iy + 0
	.local	.LBB7_55
.LBB7_55:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	(ix - 42), de
	ld	hl, (ix - 36)
	ld	iy, (ix - 54)
	.local	.LBB7_56
.LBB7_56:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	de, -256
	or	a, a
	sbc	hl, de
	jp	c, .LBB7_61
; %bb.57:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 33)
	push	hl
	push	iy
	call	_fixed_scale_mul
	push	hl
	pop	iy
	pop	hl
	pop	hl
	lea	hl, iy + 0
	call	__ineg
	ex	de, hl
	ld	hl, (ix - 39)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB7_59
; %bb.58:                               ;   in Loop: Header=BB7_43 Depth=1
	lea	de, iy + 0
	.local	.LBB7_59
.LBB7_59:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	(ix - 60), de
	ld	de, (ix - 54)
	jr	.LBB7_62
	.local	.LBB7_60
.LBB7_60:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	(ix - 66), iy
	ld	de, (ix - 36)
	jr	.LBB7_64
	.local	.LBB7_61
.LBB7_61:                               ;   in Loop: Header=BB7_43 Depth=1
	lea	de, iy + 0
	.local	.LBB7_62
.LBB7_62:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	hl, (ix - 51)
	ld	(ix - 66), hl
	.local	.LBB7_63
.LBB7_63:                               ;   in Loop: Header=BB7_43 Depth=1
	ld	b, (ix - 45)                    ; 1-byte Folded Reload
	.local	.LBB7_64
.LBB7_64:                               ;   in Loop: Header=BB7_43 Depth=1
	dec	b
	jp	.LBB7_43
	.local	.LBB7_65
.LBB7_65:
	ld	hl, 17
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	l, (ix - 73)
	ld	a, -16
	sub	a, l
	ld	l, a
	ld	de, 0
	ld	e, l
	ld	(ix - 30), de
	ld	hl, _grid_segments
	push	hl
	pop	iy
	.local	.LBB7_66
.LBB7_66:                               ; =>This Inner Loop Header: Depth=1
	ld	de, (ix - 11)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jr	z, .LBB7_68
; %bb.67:                               ;   in Loop: Header=BB7_66 Depth=1
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
	jr	.LBB7_66
	.local	.LBB7_68
.LBB7_68:
	call	_render_asm_repair_horizon
	ld	hl, (ix - 19)
	ld	(ix - 33), hl
	ld	hl, (ix - 27)
	ld	(ix - 30), hl
	ld	hl, (ix - 16)
	ld	(ix - 45), hl
	ld	a, (ix - 12)
	ld	(ix - 48), a
	ld	hl, (ix - 24)
	ld	(ix - 51), hl
	ld	a, (ix - 20)
	ld	(ix - 54), a
	ld	a, (ix - 13)
	ld	(ix - 36), a
	ld	a, (ix - 21)
	ld	(ix - 39), a
	ld	de, 320
	ld	bc, (ix + 6)
	ld	iy, 0
	.local	.LBB7_69
.LBB7_69:                               ; =>This Inner Loop Header: Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	jp	z, .LBB7_75
; %bb.70:                               ;   in Loop: Header=BB7_69 Depth=1
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
	ld	de, (ix - 45)
	add	iy, de
	ld	l, (ix - 48)
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
	jr	z, .LBB7_72
; %bb.71:                               ;   in Loop: Header=BB7_69 Depth=1
	ld	e, -80
	ld	a, c
	add	a, e
	ld	c, a
	.local	.LBB7_72
.LBB7_72:                               ;   in Loop: Header=BB7_69 Depth=1
	ld	(ix - 36), c
	ld	a, l
	and	a, 1
	ld	de, 0
	ld	e, a
	add	iy, de
	ld	(ix - 33), iy
	ld	hl, (ix - 30)
	ld	de, (ix - 51)
	add	hl, de
	ld	(ix - 30), hl
	ld	l, (ix - 54)
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
	jr	z, .LBB7_74
; %bb.73:                               ;   in Loop: Header=BB7_69 Depth=1
	ld	e, -80
	ld	a, h
	add	a, e
	ld	h, a
	.local	.LBB7_74
.LBB7_74:                               ;   in Loop: Header=BB7_69 Depth=1
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
	jp	.LBB7_69
	.local	.LBB7_75
.LBB7_75:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_game_render, .Lfunc_end7-_game_render
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
	jp	m, .LBB8_3
; %bb.1:
	ld	bc, 160
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	c, .LBB8_5
; %bb.2:
	ld	l, 96
	ld	bc, 2
	jp	.LBB8_9
	.local	.LBB8_3
.LBB8_3:
	ld	bc, -160
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB8_7
; %bb.4:
	ld	l, -16
	ld	bc, -3
	jp	.LBB8_9
	.local	.LBB8_5
.LBB8_5:
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
	jr	nz, .LBB8_11
; %bb.6:
	push	de
	pop	hl
	ld	c, e
	jr	.LBB8_12
	.local	.LBB8_7
.LBB8_7:
	ld	bc, -80
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB8_16
; %bb.8:
	ld	l, -96
	ld	bc, -2
	.local	.LBB8_9
.LBB8_9:
	ld	(ix - 3), bc
	.local	.LBB8_10
.LBB8_10:
	ld	a, e
	add	a, l
	ld	c, a
	jr	.LBB8_13
	.local	.LBB8_11
.LBB8_11:
	ld	c, -80
	push	de
	pop	hl
	ld	a, e
	add	a, c
	ld	c, a
	.local	.LBB8_12
.LBB8_12:
	ld	iy, 0
	ld	iyl, b
	ld	(ix - 3), iy
	ld	iy, (ix + 9)
	ex	de, hl
	.local	.LBB8_13
.LBB8_13:
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
	jr	c, .LBB8_15
; %bb.14:
	ex	de, hl
	ld	l, -40
	inc	de
	ld	(iy + 3), de
	ld	a, c
	add	a, l
	ld	c, a
	.local	.LBB8_15
.LBB8_15:
	sla	c
	ld	(iy + 7), c
	pop	hl
	pop	ix
	ret
	.local	.LBB8_16
.LBB8_16:
	scf
	sbc	hl, hl
	ld	(ix - 3), hl
	ld	l, 80
	jr	.LBB8_10
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_ray_stepper_init, .Lfunc_end8-_ray_stepper_init
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
	jr	nz, .LBB9_2
; %bb.1:
	ld	hl, 4194303
	jr	.LBB9_7
	.local	.LBB9_2
.LBB9_2:
	ld	bc, 1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB9_4
; %bb.3:
	ld	hl, 65536
	jr	.LBB9_7
	.local	.LBB9_4
.LBB9_4:
	ld	iy, _render_reciprocal_delta
	ld	bc, 425
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	ex	de, hl
	jr	c, .LBB9_6
; %bb.5:
	ld	hl, 425
	.local	.LBB9_6
.LBB9_6:
	add	hl, hl
	ex	de, hl
	add	iy, de
	ld	de, (iy)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	.local	.LBB9_7
.LBB9_7:
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_delta_for_component, .Lfunc_end9-_delta_for_component
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
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_fixed_scale_mul, .Lfunc_end10-_fixed_scale_mul
                                        ; -- End function
	.section	.text._render_column,"ax",@progbits
	.type	_render_column,@function        ; -- Begin function render_column
_render_column:                         ; @render_column
; %bb.0:
	ld	hl, -25
	call	__frameset
	ld	iy, (ix + 6)
	ld	a, 5
	ld	c, 0
	ld	l, 13
	ld	(ix - 22), hl
	ld	e, -16
	or	a, a
	sbc	hl, hl
	ld	(ix - 11), hl
	ld	l, c
	ld	(ix - 13), e                    ; 1-byte Folded Spill
	ld	(ix - 14), c                    ; 1-byte Folded Spill
	ld	(ix - 19), c                    ; 1-byte Folded Spill
	ld	(ix - 18), c                    ; 1-byte Folded Spill
	.local	.LBB11_1
.LBB11_1:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 8), de
	ld	(ix - 5), hl
	ld	(ix - 15), a                    ; 1-byte Folded Spill
	cp	a, 5
	jr	nz, .LBB11_3
; %bb.2:                                ;   in Loop: Header=BB11_1 Depth=1
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
	jr	.LBB11_4
	.local	.LBB11_3
.LBB11_3:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_cast_wall_continue
	.local	.LBB11_4
.LBB11_4:                               ;   in Loop: Header=BB11_1 Depth=1
	pop	hl
	ld	hl, (_render_scratch)
	ld	de, (ix - 11)
	add	hl, de
	ld	(_render_scratch), hl
	ld	a, (_render_ray_state+52)
	ld	b, a
	ld	a, (_render_ray_state+53)
	ld	(ix - 17), a                    ; 1-byte Folded Spill
	ld	a, (_render_ray_state+54)
	ld	(ix - 12), a                    ; 1-byte Folded Spill
	ld	a, b
	ld	(_render_scratch+10), a
	ld	(ix - 25), hl
	ld	c, 2
	call	__ishru
	push	hl
	pop	iy
	ld	de, 2047
	or	a, a
	sbc	hl, de
	jr	c, .LBB11_6
; %bb.5:                                ;   in Loop: Header=BB11_1 Depth=1
	ld	iy, 2047
	.local	.LBB11_6
.LBB11_6:                               ;   in Loop: Header=BB11_1 Depth=1
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _render_wall_scale_offset
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _render_wall_scale_profiles
	add	hl, de
	ld	(ix - 16), b                    ; 1-byte Folded Spill
	ld	a, b
	or	a, a
	pea	ix - 2
	pea	ix - 1
	ld	(ix - 11), hl
	push	hl
	ld	hl, _render_scratch
	push	hl
	call	nz, _render_asm_portal_opening
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (ix - 12)                    ; 1-byte Folded Reload
	or	a, a
	ld	bc, (ix - 5)
	ld	de, (ix - 8)
	ld	a, c
	jp	z, .LBB11_33
; %bb.7:                                ;   in Loop: Header=BB11_1 Depth=1
	cp	a, e
	ld	iy, (ix - 11)
	jp	nc, .LBB11_9
; %bb.8:                                ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (ix - 1)
	ld	l, (ix - 2)
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	l, a
	push	hl
	push	de
	push	bc
	ld	hl, (ix + 9)
	push	hl
	push	iy
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_draw_portal_mask
	ld	bc, (ix - 5)
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	.local	.LBB11_9
.LBB11_9:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	d, (ix - 1)
	ld	a, (ix - 14)                    ; 1-byte Folded Reload
	cp	a, d
	ld	h, d
	jr	c, .LBB11_11
; %bb.10:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	h, a
	.local	.LBB11_11
.LBB11_11:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	l, (ix - 2)
	ld	a, l
	ld	e, (ix - 13)                    ; 1-byte Folded Reload
	cp	a, e
	ld	a, e
	ld	e, l
	jr	c, .LBB11_13
; %bb.12:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	e, a
	.local	.LBB11_13
.LBB11_13:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, h
	ld	(ix - 11), e                    ; 1-byte Folded Spill
	cp	a, e
	jp	nc, .LBB11_69
; %bb.14:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	(ix - 12), h                    ; 1-byte Folded Spill
	ld	a, l
	sub	a, d
	ld	e, a
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	h, a
	inc	h
	inc	h
	ld	a, h
	add	a, d
	ld	e, a
	cp	a, l
	jr	nc, .LBB11_22
; %bb.15:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	a, c
	cp	a, e
	ld	iy, (ix - 8)
	jr	c, .LBB11_17
; %bb.16:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	e, c
	.local	.LBB11_17
.LBB11_17:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, l
	sub	a, h
	ld	b, a
	cp	a, iyl
	jr	c, .LBB11_19
; %bb.18:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	b, iyl
	.local	.LBB11_19
.LBB11_19:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, b
	cp	a, e
	ld	iyl, b
	ld	l, (ix - 12)                    ; 1-byte Folded Reload
	jr	c, .LBB11_21
; %bb.20:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	iyl, e
	.local	.LBB11_21
.LBB11_21:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (ix - 15)                    ; 1-byte Folded Reload
	jp	.LBB11_23
	.local	.LBB11_22
.LBB11_22:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	iy, (ix - 8)
	ld	b, iyl
                                        ; kill: def $iyl killed $iyl killed $uiy def $uiy
	ld	a, (ix - 15)                    ; 1-byte Folded Reload
	ld	l, (ix - 12)                    ; 1-byte Folded Reload
	.local	.LBB11_23
.LBB11_23:                              ;   in Loop: Header=BB11_1 Depth=1
	or	a, a
	jp	z, .LBB11_69
; %bb.24:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (ix - 11)
	sub	a, l
	ld	l, a
	cp	a, 3
	jp	c, .LBB11_69
; %bb.25:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (ix - 17)                    ; 1-byte Folded Reload
	cp	a, 8
	ld	c, (ix - 18)                    ; 1-byte Folded Reload
	jr	c, .LBB11_27
; %bb.26:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	c, (ix - 19)                    ; 1-byte Folded Reload
	.local	.LBB11_27
.LBB11_27:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	l, 7
	ld	de, 0
	ld	a, (ix - 17)
	and	a, l
	ld	e, a
	ld	hl, _portal_visit_bits
	add	hl, de
	ld	e, (hl)
	ld	a, e
	and	a, c
	ld	l, a
	or	a, a
	jp	nz, .LBB11_69
; %bb.28:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (ix - 17)                    ; 1-byte Folded Reload
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	bit	0, a
	ld	l, 0
	jr	nz, .LBB11_30
; %bb.29:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	l, e
	.local	.LBB11_30
.LBB11_30:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	(ix - 8), b                     ; 1-byte Folded Spill
	ld	(ix - 5), iy
	bit	0, a
	jr	nz, .LBB11_32
; %bb.31:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	e, 0
	.local	.LBB11_32
.LBB11_32:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	c, (ix - 19)
	ld	a, l
	or	a, c
	ld	c, a
	ld	(ix - 19), c
	ld	l, (ix - 18)
	ld	a, e
	or	a, l
	ld	l, a
	ld	(ix - 18), l
	call	_render_asm_transform_ray_state
	ld	a, (ix - 15)                    ; 1-byte Folded Reload
	dec	a
	ld	e, (ix - 8)                     ; 1-byte Folded Reload
	ld	l, (ix - 11)
	ld	(ix - 13), l                    ; 1-byte Folded Spill
	ld	l, (ix - 12)                    ; 1-byte Folded Reload
	ld	(ix - 14), l
	ld	hl, (ix - 25)
	ld	(ix - 11), hl
	ld	hl, (ix - 5)
	ld	iy, (ix + 6)
	jp	.LBB11_1
	.local	.LBB11_33
.LBB11_33:
	cp	a, e
	ld	iy, (ix - 11)
	jp	nc, .LBB11_69
; %bb.34:
	ld	e, (iy + 2)
	ld	l, (iy + 3)
	ld	a, c
	cp	a, e
                                        ; kill: def $e killed $e def $ude
	jr	c, .LBB11_36
; %bb.35:
	ld	e, c
	.local	.LBB11_36
.LBB11_36:
	ld	a, l
	ld	bc, (ix - 8)
	cp	a, c
	jr	c, .LBB11_38
; %bb.37:
	ld	l, c
	.local	.LBB11_38
.LBB11_38:
	push	iy
                                        ; kill: def $l killed $l def $uhl
	push	hl
	push	de
	ld	hl, (ix + 9)
	push	hl
	ld	hl, _render_scratch
	push	hl
	call	_render_asm_draw_wall_segment
	ld	iy, (ix - 11)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (ix - 16)                    ; 1-byte Folded Reload
	or	a, a
	ld	de, (ix - 5)
	jp	z, .LBB11_69
; %bb.39:
	ld	a, (_render_scratch+10)
	ld	l, a
	or	a, a
	jp	z, .LBB11_69
; %bb.40:
	ld	a, l
	cp	a, 2
	jr	z, .LBB11_42
; %bb.41:
	ld	e, 0
	jr	.LBB11_43
	.local	.LBB11_42
.LBB11_42:
	ld	e, -1
	.local	.LBB11_43
.LBB11_43:
	ld	a, (ix - 1)
	ld	(ix - 12), a
	ld	c, (ix - 2)
	ld	a, l
	cp	a, 1
	jr	z, .LBB11_45
; %bb.44:
	ld	l, 15
	ld	a, e
	add	a, l
	ld	l, a
	ld	(ix - 22), hl
	.local	.LBB11_45
.LBB11_45:
	ld	(ix - 13), c                    ; 1-byte Folded Spill
	ld	e, (ix - 12)                    ; 1-byte Folded Reload
	ld	a, c
	sub	a, e
	ld	l, a
	ld	c, e
	cp	a, 8
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	b, a
	inc	b
	inc	b
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	e, c
	ld	l, b
	add	hl, de
	ld	a, (iy + 3)
	cp	a, l
	jr	c, .LBB11_47
; %bb.46:
	ld	a, l
	.local	.LBB11_47
.LBB11_47:
	ld	(ix - 14), a
	ld	de, 0
	ld	c, (ix - 13)                    ; 1-byte Folded Reload
	ld	e, c
	or	a, a
	sbc	hl, de
	jr	nc, .LBB11_62
; %bb.48:
	ld	a, c
	sub	a, b
	ld	l, a
	ld	iy, (ix - 11)
	ld	a, (iy + 2)
	ld	(ix - 11), hl
	cp	a, l
	ld	de, (ix - 5)
	ld	iyl, c
	jr	c, .LBB11_50
; %bb.49:
	ld	l, a
	ld	(ix - 11), hl
	.local	.LBB11_50
.LBB11_50:
	ld	a, e
	ld	c, (ix - 12)                    ; 1-byte Folded Reload
	cp	a, c
	jr	c, .LBB11_52
; %bb.51:
	ld	c, e
	.local	.LBB11_52
.LBB11_52:
	ld	b, (ix - 14)                    ; 1-byte Folded Reload
	ld	a, b
	ld	hl, (ix - 8)
	cp	a, l
	jr	c, .LBB11_54
; %bb.53:
	ld	hl, (ix - 8)
	ld	b, l
	.local	.LBB11_54
.LBB11_54:
	ld	a, c
	cp	a, b
	jr	nc, .LBB11_56
; %bb.55:
	ld	hl, (ix - 22)
	push	hl
	ld	l, b
	push	hl
	ld	l, c
	push	hl
	ld	hl, (ix + 9)
	push	hl
	call	_render_asm_draw_solid_segment
	push	af
	ld	a, (ix - 13)                    ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	ld	de, (ix - 5)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB11_56
.LBB11_56:
	ld	a, e
	ld	bc, (ix - 11)
	cp	a, c
	jr	c, .LBB11_58
; %bb.57:
	ld	c, e
	.local	.LBB11_58
.LBB11_58:
	ld	a, iyl
	ld	hl, (ix - 8)
	cp	a, l
	jr	c, .LBB11_60
; %bb.59:
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	.local	.LBB11_60
.LBB11_60:
	ld	a, c
	cp	a, iyl
	jr	nc, .LBB11_69
; %bb.61:
	ld	hl, (ix - 22)
	push	hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	push	hl
	push	bc
	jr	.LBB11_68
	.local	.LBB11_62
.LBB11_62:
	ld	hl, (ix - 5)
	ld	a, l
	ld	e, (ix - 12)                    ; 1-byte Folded Reload
	cp	a, e
	jr	c, .LBB11_64
; %bb.63:
	ld	e, l
	.local	.LBB11_64
.LBB11_64:
	ld	c, (ix - 14)                    ; 1-byte Folded Reload
	ld	a, c
	ld	hl, (ix - 8)
	cp	a, l
	jr	c, .LBB11_66
; %bb.65:
	ld	c, l
	.local	.LBB11_66
.LBB11_66:
	ld	a, e
	cp	a, c
	jr	nc, .LBB11_69
; %bb.67:
	ld	hl, (ix - 22)
	push	hl
	ld	l, c
	push	hl
	ld	l, e
	push	hl
	.local	.LBB11_68
.LBB11_68:                              ; %.loopexit
	ld	hl, (ix + 9)
	push	hl
	call	_render_asm_draw_solid_segment
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB11_69
.LBB11_69:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_render_column, .Lfunc_end11-_render_column
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -21
	call	__frameset
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	call	_game_graphics_init
	ld	hl, 384
	ld	(_game), hl
	ld	hl, 640
	ld	(_game+3), hl
	ld.sis	hl, 8192
	ld	iy, _game+6
	ld	(iy), l
	ld	(iy + 1), h
	xor	a, a
	ld	(_game+11), a
	ld	(_game+15), a
	ld	(_game+16), a
	call	_render_frame
	ld	a, (-720896)
	ld	l, 3
	or	a, l
	ld	l, a
	ld	(-720896), a
	call	_clock
	ld	(ix - 6), hl
	ld	e, 0
	ld	bc, 0
	.local	.LBB12_1
.LBB12_1:                               ; =>This Inner Loop Header: Depth=1
	ld	hl, -720868
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	bit	6, a
	jp	nz, .LBB12_10
; %bb.2:                                ;   in Loop: Header=BB12_1 Depth=1
	ld	(ix - 3), bc
	ld	(ix - 13), e                    ; 1-byte Folded Spill
	call	_clock
	ld	(ix - 9), hl
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	ld	iy, -720866
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	ld	b, 3
	call	__bshru
	ld	(ix - 14), a                    ; 1-byte Folded Spill
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	(ix - 16), l
	ld	(ix - 15), h
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	dec	b
	call	__bshru
	ld	(ix - 17), a                    ; 1-byte Folded Spill
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	ld	e, 6
	ld	b, e
	call	__bshl
	rlc	a
	sbc	a, a
	ld	(ix - 18), a                    ; 1-byte Folded Spill
	ld	iy, -720878
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	ld	d, 5
	ld	b, d
	call	__bshru
	ld	(ix - 19), a                    ; 1-byte Folded Spill
	ld	hl, -720876
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	ld	b, e
	call	__bshru
	ld	(ix - 20), a                    ; 1-byte Folded Spill
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	ld	b, d
	call	__bshru
	ld	(ix - 21), a                    ; 1-byte Folded Spill
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	b, 1
	ld	a, l
	and	a, b
	ld	e, a
	bit	0, (ix - 13)                    ; 1-byte Folded Reload
	ld	a, iyh
	ld	b, a
	jr	nz, .LBB12_5
; %bb.3:                                ;   in Loop: Header=BB12_1 Depth=1
	bit	0, e
	ld	b, a
	jr	z, .LBB12_5
; %bb.4:                                ;   in Loop: Header=BB12_1 Depth=1
	ld	a, (_fps_overlay_enabled)
	ld	l, 1
	ld	b, l
	xor	a, b
	ld	l, a
	ld	(_fps_overlay_enabled), a
	or	a, a
	sbc	hl, hl
	ld	(_fps_smoothed_ticks), hl
	xor	a, a
	ld	(_fps_smoothed_ticks+3), a
	ld	iy, _fps_tenths
	ld	(iy), l
	ld	(iy + 1), h
	.local	.LBB12_5
.LBB12_5:                               ;   in Loop: Header=BB12_1 Depth=1
	ld	(ix - 6), b
	ld	(ix - 10), e                    ; 1-byte Folded Spill
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	ld	de, 546
	or	a, a
	sbc	hl, de
	jr	c, .LBB12_7
; %bb.6:                                ;   in Loop: Header=BB12_1 Depth=1
	ld	a, 1
	ld	h, a
	ld	a, (ix - 14)
	and	a, h
	ld	l, a
	ld	e, (ix - 16)
	ld	d, (ix - 15)
	ld	a, e
	and	a, h
	ld	e, a
	push	bc
	pop	iy
	ld	a, l
	sub	a, e
	ld	e, a
	ld	(ix - 13), de
	ld	a, (ix - 17)
	and	a, h
	ld	e, a
	ld	a, (ix - 18)
	add	a, e
	ld	e, a
	ld	a, (ix - 19)
	and	a, h
	ld	c, a
	ld	b, 2
	ld	a, (ix - 20)
	and	a, b
	ld	b, a
	ld	a, b
	add	a, c
	ld	c, a
	ld	b, 4
	ld	a, (ix - 21)
	and	a, b
	ld	b, a
	ld	a, c
	add	a, b
	ld	c, a
	ld	hl, 32768
	push	hl
	push	iy
	push	bc
	push	de
	ld	hl, (ix - 13)
	push	hl
	ld	hl, _game
	push	hl
	call	_game_update
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	e, (ix - 6)                     ; 1-byte Folded Reload
	or	a, e
	ld	e, a
	ld	bc, 0
	ld	hl, (ix - 9)
	jr	.LBB12_8
	.local	.LBB12_7
.LBB12_7:                               ;   in Loop: Header=BB12_1 Depth=1
	ld	hl, (ix - 9)
	ld	e, (ix - 6)                     ; 1-byte Folded Reload
	.local	.LBB12_8
.LBB12_8:                               ;   in Loop: Header=BB12_1 Depth=1
	ld	a, e
	or	a, a
	ld	a, (ix - 10)                    ; 1-byte Folded Reload
	ld	e, a
	ld	(ix - 6), hl
	jp	z, .LBB12_1
; %bb.9:                                ;   in Loop: Header=BB12_1 Depth=1
	ld	(ix - 3), bc
	call	_render_frame
	ld	bc, (ix - 3)
	ld	e, (ix - 10)                    ; 1-byte Folded Reload
	ld	hl, (ix - 9)
	ld	(ix - 6), hl
	jp	.LBB12_1
	.local	.LBB12_10
.LBB12_10:
	call	_kb_Reset
	call	_gfx_End
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_main, .Lfunc_end12-_main
                                        ; -- End function
	.section	.text._render_frame,"ax",@progbits
	.type	_render_frame,@function         ; -- Begin function render_frame
_render_frame:                          ; @render_frame
; %bb.0:
	ld	hl, -10
	call	__frameset
	ld	hl, _game
	ld	a, (_fps_overlay_enabled)
	or	a, a
	jr	nz, .LBB13_2
; %bb.1:
	push	hl
	call	_game_render
	pop	hl
	call	_gfx_SwapDraw
	jp	.LBB13_19
	.local	.LBB13_2
.LBB13_2:
	call	_clock
	ld	(ix - 6), hl
	ld	(ix - 7), e                     ; 1-byte Folded Spill
	ld	hl, _game
	push	hl
	call	_game_render
	pop	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_gfx_SetColor
	pop	hl
	ld	hl, 12
	push	hl
	ld	hl, 76
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 244
	push	hl
	call	_gfx_FillRectangle_NoClip
	pop	hl
	pop	hl
	pop	hl
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
	ld	(ix - 3), hl
	push	hl
	call	_gfx_SetTextTransparentColor
	pop	hl
	ld	hl, 1
	push	hl
	push	hl
	call	_gfx_SetTextScale
	pop	hl
	pop	hl
	ld	hl, _fps_tenths
	ld	de, (hl)
	sbc.sis	hl, hl
	adc.sis	hl, de
	jr	nz, .LBB13_4
; %bb.3:
	ld	hl, _.str
	ld	de, 2
	push	de
	ld	de, 248
	push	de
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	jp	.LBB13_8
	.local	.LBB13_4
.LBB13_4:
	ld	iy, 248
	ld.sis	bc, 10
	ld	l, e
	ld	h, d
	call	__sdivu
	ld	bc, (ix - 3)
	ld	c, l
	ld	b, h
	ld	(ix - 3), bc
	ld.sis	bc, 100
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	inc	l
	ld	(ix - 10), hl
	ld.sis	bc, 1000
	ld	l, e
	ld	h, d
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB13_6
; %bb.5:
	ld	hl, (ix - 10)
	inc	l
	jr	.LBB13_7
	.local	.LBB13_6
.LBB13_6:
	ld	l, 3
	.local	.LBB13_7
.LBB13_7:
	ld	(ix - 10), hl
	ld	hl, 2
	push	hl
	push	iy
	ld	hl, _.str.1
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 10)
	push	hl
	ld	hl, (ix - 3)
	push	hl
	call	_gfx_PrintUInt
	pop	hl
	pop	hl
	ld	hl, 46
	push	hl
	call	_gfx_PrintChar
	pop	hl
	ld	hl, _fps_tenths
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	ld.sis	bc, 10
	call	__sremu
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, 1
	push	hl
	push	de
	call	_gfx_PrintUInt
	.local	.LBB13_8
.LBB13_8:
	pop	hl
	pop	hl
	call	_gfx_SwapDraw
	call	_clock
	ld	bc, (ix - 6)
	ld	a, (ix - 7)                     ; 1-byte Folded Reload
	call	__lcmpu
	jp	z, .LBB13_19
; %bb.9:
	ld	iy, _fps_smoothed_ticks
	call	__lsub
	ld	(ix - 3), hl
	ld	d, e
	ld	hl, (_fps_smoothed_ticks)
	lea	iy, iy + 3
	ld	e, (iy)
	call	__lcmpzero
	jr	z, .LBB13_11
; %bb.10:
	ld	iyh, 0
	jr	.LBB13_12
	.local	.LBB13_11
.LBB13_11:
	ld	iyh, 1
	.local	.LBB13_12
.LBB13_12:
	ld	bc, 3
	ld	iyl, b
	ld	a, iyl
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 3)
	ld	e, d
	call	__ladd
	ld	bc, 2
	ld	a, iyl
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	l, 2
	call	__lshru
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	bit	0, l
	jr	nz, .LBB13_14
; %bb.13:
	ld	(ix - 3), bc
	.local	.LBB13_14
.LBB13_14:
	bit	0, l
	jr	nz, .LBB13_16
; %bb.15:
	ld	d, a
	.local	.LBB13_16
.LBB13_16:
	ld	iy, (ix - 3)
	ld	(_fps_smoothed_ticks), iy
	ld	a, d
	ld	(_fps_smoothed_ticks+3), a
	ld	l, 1
	lea	bc, iy + 0
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, 327680
	xor	a, a
	call	__ladd
	lea	bc, iy + 0
	ld	a, d
	call	__ldivu
	push	hl
	pop	de
	ld	bc, 9999
	or	a, a
	sbc	hl, bc
	jr	c, .LBB13_18
; %bb.17:
	ld	de, 9999
	.local	.LBB13_18
.LBB13_18:
	ld	hl, _fps_tenths
	ld	(hl), e
	inc	hl
	ld	(hl), d
	.local	.LBB13_19
.LBB13_19:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_render_frame, .Lfunc_end13-_render_frame
                                        ; -- End function
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

	.section	.bss._render_wall_scale_offset,"aw",@nobits
	.balign	2
	.local	_render_wall_scale_offset
_render_wall_scale_offset:
	.zero	4096

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

	.section	.bss._game,"aw",@nobits
	.balign	2
	.local	_game
_game:
	.zero	18

	.section	.bss._fps_overlay_enabled,"aw",@nobits
	.balign	1
	.local	_fps_overlay_enabled
_fps_overlay_enabled:
	.zero	1

	.section	.bss._fps_tenths,"aw",@nobits
	.balign	2
	.local	_fps_tenths
_fps_tenths:
	.zero	2

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

	.section	.bss._fps_smoothed_ticks,"aw",@nobits
	.balign	1
	.local	_fps_smoothed_ticks
_fps_smoothed_ticks:
	.zero	4

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_render_asm_cast_wall_continue
	.extern	__ldivu
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.lifetime.end.p0
	.extern	__ishru
	.extern	__sdivu
	.extern	_render_ray_state
	.extern	_render_asm_draw_horizontal_grid_pair
	.extern	__sor
	.extern	__Unwind_SjLj_Unregister
	.extern	_render_asm_repair_horizon
	.extern	_render_asm_draw_wall_segment
	.extern	_gfx_FillRectangle_NoClip
	.extern	_render_asm_cast_wall_begin
	.extern	__bshru
	.extern	__sremu
	.extern	_llvm.umax.i8
	.extern	__ineg
	.extern	_gfx_PrintStringXY
	.extern	_gfx_Wait
	.extern	_llvm.umin.i8
	.extern	__ior
	.extern	_gfx_SetColor
	.extern	_kb_Reset
	.extern	_gfx_End
	.extern	__lsub
	.extern	_gfx_Line
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	__lcmpzero
	.extern	_llvm.abs.i16
	.extern	_llvm.frameaddress.p0
	.extern	_llvm.abs.i24
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	__sxor
	.extern	_render_asm_clear_background
	.extern	__lcmpu
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_SetTextScale
	.extern	_render_asm_transform_ray_state
	.extern	_gfx_Begin
	.extern	__ladd
	.extern	_gfx_PrintChar
	.extern	_llvm.umin.i24
	.extern	__idivu
	.extern	_clock
	.extern	_render_asm_find_portal
	.extern	_render_asm_add_projected_grid_segment
	.extern	__irems
	.extern	_llvm.smax.i24
	.extern	_gfx_SetTextBGColor
	.extern	_gfx_SwapDraw
	.extern	_llvm.eh.sjlj.lsda
	.extern	_render_asm_portal_opening
	.extern	__frameset
	.extern	__iand
	.extern	__imulu
	.extern	__setflag
	.extern	_llvm.eh.sjlj.callsite
	.extern	_llvm.stacksave.p0
	.extern	_render_asm_draw_portal_mask
	.extern	__lmulu
	.extern	_llvm.lifetime.start.p0
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	_gfx_PrintUInt
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
