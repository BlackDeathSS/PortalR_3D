	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
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
	jr	z, .LBB0_5
; %bb.1:
	ld	iy, (ix + 9)
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_5
; %bb.2:
	ld	hl, (iy)
	ld	(ix - 12), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_5
; %bb.3:
	ld	de, (iy + 3)
	ld	(ix - 21), de
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB0_5
; %bb.4:
	ld	e, -9
	ld	iy, (ix - 12)
	ld	l, (iy + 5)
	ld	a, l
	add	a, e
	ld	e, a
	cp	a, -8
	jr	nc, .LBB0_7
	.local	.LBB0_5
.LBB0_5:
	ld	a, c
	.local	.LBB0_6
.LBB0_6:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB0_7
.LBB0_7:
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
	.local	.LBB0_8
.LBB0_8:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_10 Depth 2
                                        ;       Child Loop BB0_12 Depth 3
	push	hl
	pop	iy
	ld	de, (ix - 50)
	or	a, a
	sbc	hl, de
	jp	z, .LBB0_16
; %bb.9:                                ;   in Loop: Header=BB0_8 Depth=1
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
	.local	.LBB0_10
.LBB0_10:                               ;   Parent Loop BB0_8 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB0_12 Depth 3
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB0_15
; %bb.11:                               ;   in Loop: Header=BB0_10 Depth=2
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
	.local	.LBB0_12
.LBB0_12:                               ;   Parent Loop BB0_8 Depth=1
                                        ;     Parent Loop BB0_10 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	bc
	pop	hl
	ld	de, 4
	or	a, a
	sbc	hl, de
	jr	z, .LBB0_14
; %bb.13:                               ;   in Loop: Header=BB0_12 Depth=3
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
	jr	.LBB0_12
	.local	.LBB0_14
.LBB0_14:                               ;   in Loop: Header=BB0_10 Depth=2
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
	jr	.LBB0_10
	.local	.LBB0_15
.LBB0_15:                               ;   in Loop: Header=BB0_8 Depth=1
	ld	hl, (ix - 56)
	inc	hl
	ld	iy, (ix - 36)
	lea	iy, iy + 36
	ld	(ix - 36), iy
	ld	e, 1
	ld	a, e
	ld	bc, 18
	jp	.LBB0_8
	.local	.LBB0_16
.LBB0_16:
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
	.local	.LBB0_17
.LBB0_17:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB0_22
; %bb.18:                               ;   in Loop: Header=BB0_17 Depth=1
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
	jp	z, .LBB0_21
; %bb.19:                               ;   in Loop: Header=BB0_17 Depth=1
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
	jr	z, .LBB0_21
; %bb.20:                               ;   in Loop: Header=BB0_17 Depth=1
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
	.local	.LBB0_21
.LBB0_21:                               ;   in Loop: Header=BB0_17 Depth=1
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
	jp	.LBB0_17
	.local	.LBB0_22
.LBB0_22:
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
	jp	.LBB0_6
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_engine_init, .Lfunc_end0-_engine_init
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
	jr	nc, .LBB1_2
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
	jr	.LBB1_6
	.local	.LBB1_2
.LBB1_2:
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
	jr	nc, .LBB1_4
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
	jr	.LBB1_5
	.local	.LBB1_4
.LBB1_4:
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	iy, (iy + 5)
	.local	.LBB1_5
.LBB1_5:
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
	.local	.LBB1_6
.LBB1_6:
	ld	de, 896
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, -1
	ld	d, 0
	ld	e, a
	jp	p, .LBB1_8
; %bb.7:
	ld	e, d
	.local	.LBB1_8
.LBB1_8:
	ld	bc, 768
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB1_10
; %bb.9:
	ld	a, d
	.local	.LBB1_10
.LBB1_10:
	and	a, e
	ld	l, a
	ld	e, 1
	ld	a, l
	and	a, e
	ld	l, a
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_room_face_holds_portal, .Lfunc_end1-_room_face_holds_portal
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
	jp	nc, .LBB2_41
; %bb.1:
	ld	a, (ix + 9)
	cp	a, l
	jp	nc, .LBB2_41
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
	jp	nc, .LBB2_14
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
	jp	m, .LBB2_5
; %bb.4:
	push	de
	pop	iy
	.local	.LBB2_5
.LBB2_5:
	push	bc
	pop	hl
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB2_7
; %bb.6:
	lea	de, iy + 0
	.local	.LBB2_7
.LBB2_7:
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
	jp	m, .LBB2_9
; %bb.8:
	push	bc
	pop	de
	.local	.LBB2_9
.LBB2_9:
	ld	(ix - 18), de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	bc, 9
	jp	m, .LBB2_11
; %bb.10:
	ld	de, (ix - 18)
	.local	.LBB2_11
.LBB2_11:
	ld	(ix + 18), de
	ld	a, (ix + 12)
	or	a, a
	push	bc
	pop	de
	ld	bc, (ix - 6)
	jr	z, .LBB2_13
; %bb.12:
	ld	de, 11
	.local	.LBB2_13
.LBB2_13:
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
	jp	.LBB2_37
	.local	.LBB2_14
.LBB2_14:
	cp	a, 4
	jp	nc, .LBB2_25
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
	jp	m, .LBB2_17
; %bb.16:
	push	de
	pop	iy
	.local	.LBB2_17
.LBB2_17:
	push	bc
	pop	hl
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB2_19
; %bb.18:
	lea	de, iy + 0
	.local	.LBB2_19
.LBB2_19:
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
	jp	m, .LBB2_21
; %bb.20:
	push	bc
	pop	de
	.local	.LBB2_21
.LBB2_21:
	ld	(ix - 18), de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB2_23
; %bb.22:
	ld	de, (ix - 18)
	.local	.LBB2_23
.LBB2_23:
	ld	(ix + 21), de
	ld	a, (ix + 12)
	cp	a, 2
	ld	iy, (ix - 6)
	jp	z, .LBB2_35
; %bb.24:
	ld	bc, 7
	jp	.LBB2_36
	.local	.LBB2_25
.LBB2_25:
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
	jp	m, .LBB2_27
; %bb.26:
	push	bc
	pop	de
	.local	.LBB2_27
.LBB2_27:
	ld	bc, (ix - 9)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB2_29
; %bb.28:
	push	de
	pop	bc
	.local	.LBB2_29
.LBB2_29:
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
	jp	m, .LBB2_31
; %bb.30:
	push	bc
	pop	de
	.local	.LBB2_31
.LBB2_31:
	ld	(ix - 18), de
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	bc, 9
	jp	m, .LBB2_33
; %bb.32:
	ld	de, (ix - 18)
	.local	.LBB2_33
.LBB2_33:
	ld	(ix + 21), de
	ld	a, (ix + 12)
	cp	a, 4
	ld	iy, (ix - 6)
	jr	z, .LBB2_38
; %bb.34:
	ld	de, 3
	jr	.LBB2_39
	.local	.LBB2_35
.LBB2_35:
	ld	bc, 5
	.local	.LBB2_36
.LBB2_36:
	ld	hl, (ix - 3)
	add	hl, bc
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix + 18), hl
	.local	.LBB2_37
.LBB2_37:
	ld	bc, 9
	jr	.LBB2_40
	.local	.LBB2_38
.LBB2_38:
	ld	de, 1
	.local	.LBB2_39
.LBB2_39:
	ld	hl, (ix - 3)
	add	hl, de
	ld	de, (hl)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(ix + 15), hl
	.local	.LBB2_40
.LBB2_40:
	lea	de, iy + 0
	ld	hl, (ix - 12)
	ldir
	.local	.LBB2_41
.LBB2_41:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_configure_portal_on_face, .Lfunc_end2-_configure_portal_on_face
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
	jp	m, .LBB3_2
; %bb.1:
	ex	de, hl
	.local	.LBB3_2
.LBB3_2:
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
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_rebuild_camera_basis, .Lfunc_end3-_rebuild_camera_basis
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
	jr	z, .LBB4_2
; %bb.1:
	ld	hl, 64
	jr	.LBB4_3
	.local	.LBB4_2
.LBB4_2:
	ld	hl, 384
	.local	.LBB4_3
.LBB4_3:
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
	jp	m, .LBB4_5
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
	jp	p, .LBB4_6
	.local	.LBB4_5
.LBB4_5:
	ld	hl, (ix + 9)
	ld	(hl), de
	or	a, a
	sbc	hl, hl
	ld	(iy + 9), hl
	.local	.LBB4_6
.LBB4_6:
	ld	iy, (ix + 9)
	ld	bc, (iy + 3)
	push	bc
	pop	hl
	ld	de, (ix - 15)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB4_8
; %bb.7:
	ld	de, (ix - 19)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB4_9
	.local	.LBB4_8
.LBB4_8:
	ld	(iy + 3), de
	or	a, a
	sbc	hl, hl
	ld	iy, (ix + 6)
	ld	(iy + 12), hl
	.local	.LBB4_9
.LBB4_9:
	ld	iy, (ix + 9)
	ld	de, (iy + 6)
	ld	bc, (ix - 9)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB4_11
; %bb.10:
	xor	a, a
	ld	hl, (ix - 6)
	ld	iy, (ix + 6)
	jr	.LBB4_17
	.local	.LBB4_11
.LBB4_11:
	ld	(iy + 6), bc
	ld	iy, (ix + 6)
	ld	hl, (iy + 15)
	ld	de, 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB4_13
; %bb.12:
	or	a, a
	sbc	hl, hl
	ld	(iy + 15), hl
	lea	hl, iy + 0
	ld	iy, (ix + 9)
	ld	bc, (iy + 6)
	push	hl
	pop	iy
	.local	.LBB4_13
.LBB4_13:
	ld	a, (ix - 16)                    ; 1-byte Folded Reload
	or	a, a
	jr	z, .LBB4_15
; %bb.14:
	ld	a, 0
	jr	.LBB4_16
	.local	.LBB4_15
.LBB4_15:
	ld	a, 1
	.local	.LBB4_16
.LBB4_16:
	ld	hl, (ix - 6)
	push	bc
	pop	de
	.local	.LBB4_17
.LBB4_17:
	ld	(iy + 49), a
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB4_20
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
	jp	m, .LBB4_20
; %bb.19:
	or	a, a
	sbc	hl, hl
	ld	(iy + 15), hl
	.local	.LBB4_20
.LBB4_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_collide_with_room, .Lfunc_end4-_collide_with_room
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
	jr	c, .LBB5_3
; %bb.1:
	ld	d, 64
	ld	b, 6
	ld	a, e
	call	__bshru
	cp	a, 1
	jr	nz, .LBB5_4
; %bb.2:
	ld	a, d
	sub	a, c
	ld	c, a
	.local	.LBB5_3
.LBB5_3:
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
	jr	.LBB5_7
	.local	.LBB5_4
.LBB5_4:
	cp	a, 2
	jr	z, .LBB5_6
; %bb.5:
	ld	a, d
	sub	a, c
	ld	c, a
	.local	.LBB5_6
.LBB5_6:
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
	.local	.LBB5_7
.LBB5_7:
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_angle_sine, .Lfunc_end5-_angle_sine
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
	.local	.LBB6_1
.LBB6_1:                                ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_3
; %bb.2:                                ;   in Loop: Header=BB6_1 Depth=1
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
	jr	.LBB6_1
	.local	.LBB6_3
.LBB6_3:
	ld	de, 8192
	ld	iy, 32
	lea	bc, iy + 0
	.local	.LBB6_4
.LBB6_4:                                ; %.preheader7
                                        ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_6
; %bb.5:                                ;   in Loop: Header=BB6_4 Depth=1
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
	jr	.LBB6_4
	.local	.LBB6_6
.LBB6_6:
	ld	de, 65536
	ld	iy, 8192
	lea	bc, iy + 0
	.local	.LBB6_7
.LBB6_7:                                ; %.preheader6
                                        ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_9
; %bb.8:                                ;   in Loop: Header=BB6_7 Depth=1
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
	jr	.LBB6_7
	.local	.LBB6_9
.LBB6_9:
	ld.sis	hl, 0
	ld	iy, _edge_reciprocal_table
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, 32768
	ld	iy, 16
	lea	bc, iy + 0
	.local	.LBB6_10
.LBB6_10:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB6_14
; %bb.11:                               ;   in Loop: Header=BB6_10 Depth=1
	ld	hl, (ix - 6)
	ld	(ix - 12), bc
	call	__idivu
	push	hl
	pop	de
	ld	bc, 65535
	or	a, a
	sbc	hl, bc
	jr	c, .LBB6_13
; %bb.12:                               ;   in Loop: Header=BB6_10 Depth=1
	ld	de, 65535
	.local	.LBB6_13
.LBB6_13:                               ;   in Loop: Header=BB6_10 Depth=1
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
	jr	.LBB6_10
	.local	.LBB6_14
.LBB6_14:
	ld	de, 13
	ld	bc, 0
	.local	.LBB6_15
.LBB6_15:                               ; %.preheader
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_17 Depth 2
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB6_20
; %bb.16:                               ;   in Loop: Header=BB6_15 Depth=1
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
	.local	.LBB6_17
.LBB6_17:                               ;   Parent Loop BB6_15 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	hl
	pop	de
	ld	bc, 4
	or	a, a
	sbc	hl, bc
	jp	z, .LBB6_19
; %bb.18:                               ;   in Loop: Header=BB6_17 Depth=2
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
	jp	.LBB6_17
	.local	.LBB6_19
.LBB6_19:                               ;   in Loop: Header=BB6_15 Depth=1
	ld	bc, (ix - 9)
	inc	bc
	ld	iy, (ix - 3)
	lea	iy, iy + 8
	ld	(ix - 3), iy
	ld	de, 13
	jp	.LBB6_15
	.local	.LBB6_20
.LBB6_20:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_engine_graphics_init, .Lfunc_end6-_engine_graphics_init
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
	jr	nz, .LBB7_2
; %bb.1:
	ld	l, 0
	jr	.LBB7_3
	.local	.LBB7_2
.LBB7_2:
	ld	l, 1
	.local	.LBB7_3
.LBB7_3:
	ld	a, (_active_render_width)
	ld	h, a
	ld	a, (_active_render_shift)
	ld	c, a
	ld	a, h
	or	a, a
	jr	z, .LBB7_6
; %bb.4:
	ld	a, c
	cp	a, l
	jr	nz, .LBB7_6
	.local	.LBB7_5
.LBB7_5:                                ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB7_6
.LBB7_6:
	ld	a, e
	or	a, a
	jr	nz, .LBB7_8
; %bb.7:
	ld	c, 0
	jr	.LBB7_9
	.local	.LBB7_8
.LBB7_8:
	ld	c, -1
	.local	.LBB7_9
.LBB7_9:
	ld	a, l
	ld	(_active_render_shift), a
	bit	0, c
	jr	nz, .LBB7_11
; %bb.10:
	ld	e, 64
	jr	.LBB7_12
	.local	.LBB7_11
.LBB7_11:
	ld	e, 32
	.local	.LBB7_12
.LBB7_12:
	ld	a, e
	ld	(_active_render_width), a
	bit	0, c
	jr	nz, .LBB7_14
; %bb.13:
	ld	l, 48
	jr	.LBB7_15
	.local	.LBB7_14
.LBB7_14:
	ld	l, 24
	.local	.LBB7_15
.LBB7_15:
	ld	a, l
	ld	(_active_render_height), a
	bit	0, c
	jr	nz, .LBB7_17
; %bb.16:
	ld	a, 4
	jr	.LBB7_18
	.local	.LBB7_17
.LBB7_17:
	ld	a, 2
	.local	.LBB7_18
.LBB7_18:
	ld	(_active_horizon_near_limit), a
	bit	0, c
	jr	nz, .LBB7_20
; %bb.19:
	ld	a, 12
	jr	.LBB7_21
	.local	.LBB7_20
.LBB7_20:
	ld	a, 6
	.local	.LBB7_21
.LBB7_21:
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
	.local	.LBB7_22
.LBB7_22:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB7_5
; %bb.23:                               ;   in Loop: Header=BB7_22 Depth=1
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
	jr	.LBB7_22
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_configure_render_mode, .Lfunc_end7-_configure_render_mode
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
	jr	nz, .LBB8_2
; %bb.1:
	ld	l, 0
	ld	a, l
	jp	.LBB8_118
	.local	.LBB8_2
.LBB8_2:
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
	jr	c, .LBB8_4
; %bb.3:
	push	de
	pop	bc
	.local	.LBB8_4
.LBB8_4:
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
	jr	z, .LBB8_8
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
	jr	z, .LBB8_7
; %bb.6:
	ld	h, e
	.local	.LBB8_7
.LBB8_7:
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
	.local	.LBB8_8
.LBB8_8:
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
	jp	z, .LBB8_16
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
	jr	nz, .LBB8_11
; %bb.10:
	ld.sis	bc, 1
	.local	.LBB8_11
.LBB8_11:
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
	jp	p, .LBB8_13
; %bb.12:
	ld.sis	iy, -64
	.local	.LBB8_13
.LBB8_13:
	ld.sis	bc, 64
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	m, .LBB8_15
; %bb.14:
	ld.sis	iy, 64
	.local	.LBB8_15
.LBB8_15:
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
	jr	nz, .LBB8_17
	.local	.LBB8_16
.LBB8_16:
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	l, (iy + 0)
	ld	h, (iy + 1)
	ld	a, l
	or	a, a
	ld	iy, (ix + 6)
	jr	nz, .LBB8_18
	jr	.LBB8_19
	.local	.LBB8_17
.LBB8_17:
	ld	a, iyl
	ld	iy, (ix + 6)
	ld	(iy + 46), a
	.local	.LBB8_18
.LBB8_18:
	push	iy
	call	_rebuild_camera_basis
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	ld	c, 1
	ld	iy, (ix + 6)
	pop	hl
	.local	.LBB8_19
.LBB8_19:
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 66), hl
	pop	ix
	bit	3, d
	jr	z, .LBB8_24
; %bb.20:
	ld	a, (iy + 50)
	or	a, a
	jr	z, .LBB8_22
; %bb.21:
	ld	a, 0
	jr	.LBB8_23
	.local	.LBB8_22
.LBB8_22:
	ld	a, 1
	.local	.LBB8_23
.LBB8_23:
	ld	(iy + 50), a
	or	a, a
	sbc	hl, hl
	ld	(iy + 9), hl
	ld	(iy + 12), hl
	ld	(iy + 15), hl
	ld	(iy + 49), h
	.local	.LBB8_24
.LBB8_24:
	bit	5, d
	jr	z, .LBB8_26
; %bb.25:
	ld	a, (iy + 51)
	xor	a, c
	ld	l, a
	ld	(iy + 51), l
	.local	.LBB8_26
.LBB8_26:
	bit	1, d
	ld	hl, 0
	jr	z, .LBB8_28
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
	.local	.LBB8_28
.LBB8_28:
	bit	2, d
	jr	z, .LBB8_30
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
	.local	.LBB8_30
.LBB8_30:
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
	jr	z, .LBB8_32
; %bb.31:
	ld	a, l
	or	a, a
	jp	z, .LBB8_35
	.local	.LBB8_32
.LBB8_32:
	ld	a, l
	or	a, a
	jp	z, .LBB8_37
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
	jp	z, .LBB8_38
; %bb.34:
	ld	de, 640
	push	bc
	pop	hl
	add	hl, de
	jp	.LBB8_39
	.local	.LBB8_35
.LBB8_35:
	ld	a, (iy + 49)
	or	a, a
	jr	z, .LBB8_37
; %bb.36:
	ld	hl, 1792
	ld	(iy + 15), hl
	ld	(iy + 49), l
	.local	.LBB8_37
.LBB8_37:
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
	jr	.LBB8_43
	.local	.LBB8_38
.LBB8_38:
	push	bc
	pop	hl
	.local	.LBB8_39
.LBB8_39:
	ld	iy, (ix + 6)
	ld	(iy + 15), hl
	bit	4, (ix + 18)
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 14)
	pop	ix
	jr	nz, .LBB8_41
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
	jr	.LBB8_42
	.local	.LBB8_41
.LBB8_41:
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
	.local	.LBB8_42
.LBB8_42:
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 20)                    ; 1-byte Folded Reload
	pop	ix
	.local	.LBB8_43
.LBB8_43:
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
	.local	.LBB8_44
.LBB8_44:                               ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB8_114
; %bb.45:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	z, .LBB8_79
; %bb.46:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	z, .LBB8_79
; %bb.47:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	iy, (ix + 6)
	ld	l, (iy + 47)
	push	de
	pop	iy
	ld	a, (iy + 42)
	cp	a, l
	jp	nz, .LBB8_79
; %bb.48:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	nz, .LBB8_51
; %bb.49:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	de, (iy + 30)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB8_52
; %bb.50:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	.LBB8_54
	.local	.LBB8_51
.LBB8_51:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	.LBB8_53
	.local	.LBB8_52
.LBB8_52:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 44)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 95)
	.local	.LBB8_53
.LBB8_53:                               ;   in Loop: Header=BB8_44 Depth=1
	pop	ix
	or	a, a
	sbc	hl, bc
	.local	.LBB8_54
.LBB8_54:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	p, .LBB8_56
; %bb.55:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	a, 0
	.local	.LBB8_56
.LBB8_56:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 83)
	pop	ix
	call	__ineg
	bit	0, a
	jr	nz, .LBB8_58
; %bb.57:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	(ix - 83), hl
	pop	ix
	.local	.LBB8_58
.LBB8_58:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	call	__ineg
	bit	0, a
	jr	nz, .LBB8_60
; %bb.59:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	(ix - 80), hl
	pop	ix
	.local	.LBB8_60
.LBB8_60:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	z, .LBB8_66
; %bb.61:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	hl, (iy + 33)
	ld	bc, 129
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	hl, 384
	jp	p, .LBB8_63
; %bb.62:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	hl, 64
	.local	.LBB8_63
.LBB8_63:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	p, .LBB8_65
; %bb.64:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	hl, 64
	.local	.LBB8_65
.LBB8_65:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	de, -226
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 89)
	pop	ix
	.local	.LBB8_66
.LBB8_66:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	m, .LBB8_79
; %bb.67:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 77)
	pop	ix
	ld	de, 1
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB8_79
; %bb.68:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 83)
	pop	ix
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB8_70
; %bb.69:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	or	a, a
	sbc	hl, bc
	jp	z, .LBB8_79
	.local	.LBB8_70
.LBB8_70:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	nz, .LBB8_73
; %bb.71:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	z, .LBB8_73
; %bb.72:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	bc, -208
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	.local	.LBB8_73
.LBB8_73:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jr	nz, .LBB8_77
; %bb.74:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	hl, (iy + 21)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB8_76
; %bb.75:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 80)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 86), hl
	pop	ix
	.local	.LBB8_76
.LBB8_76:                               ;   in Loop: Header=BB8_44 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 86)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 77), hl
	pop	ix
	.local	.LBB8_77
.LBB8_77:                               ;   in Loop: Header=BB8_44 Depth=1
	ld	hl, (iy + 36)
	ld	de, -64
	add	hl, de
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB8_79
; %bb.78:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	p, .LBB8_80
	.local	.LBB8_79
.LBB8_79:                               ;   in Loop: Header=BB8_44 Depth=1
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
	jp	.LBB8_44
	.local	.LBB8_80
.LBB8_80:
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
	.local	.LBB8_81
.LBB8_81:                               ; =>This Inner Loop Header: Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	or	a, a
	sbc	hl, bc
	jp	z, .LBB8_87
; %bb.82:                               ;   in Loop: Header=BB8_81 Depth=1
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
	jp	m, .LBB8_84
; %bb.83:                               ;   in Loop: Header=BB8_81 Depth=1
	push	de
	pop	iy
	.local	.LBB8_84
.LBB8_84:                               ;   in Loop: Header=BB8_81 Depth=1
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
	jp	m, .LBB8_86
; %bb.85:                               ;   in Loop: Header=BB8_81 Depth=1
	ld	c, a
	.local	.LBB8_86
.LBB8_86:                               ;   in Loop: Header=BB8_81 Depth=1
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
	jp	.LBB8_81
	.local	.LBB8_87
.LBB8_87:
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	ld	bc, 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	l, a
	jp	p, .LBB8_89
; %bb.88:
	ld	a, e
	sub	a, l
	ld	l, a
	.local	.LBB8_89
.LBB8_89:
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
	jp	nc, .LBB8_91
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
	.local	.LBB8_91
.LBB8_91:
	ld.sis	hl, 256
	.local	.LBB8_92
.LBB8_92:                               ; =>This Inner Loop Header: Depth=1
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
	jp	z, .LBB8_113
; %bb.93:                               ;   in Loop: Header=BB8_92 Depth=1
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
	jp	c, .LBB8_95
; %bb.94:                               ;   in Loop: Header=BB8_92 Depth=1
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
	jp	.LBB8_97
	.local	.LBB8_95
.LBB8_95:                               ;   in Loop: Header=BB8_92 Depth=1
	ld	de, -202
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	bit	0, (iy + 0)                     ; 1-byte Folded Reload
	jp	z, .LBB8_107
; %bb.96:                               ;   in Loop: Header=BB8_92 Depth=1
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
	.local	.LBB8_97
.LBB8_97:                               ;   in Loop: Header=BB8_92 Depth=1
	push	hl
	pop	bc
	ld	a, e
	.local	.LBB8_98
.LBB8_98:                               ;   in Loop: Header=BB8_92 Depth=1
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
	jp	m, .LBB8_100
; %bb.99:                               ;   in Loop: Header=BB8_92 Depth=1
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	d, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB8_100
.LBB8_100:                              ;   in Loop: Header=BB8_92 Depth=1
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
	jp	m, .LBB8_102
; %bb.101:                              ;   in Loop: Header=BB8_92 Depth=1
	ld	l, 0
	.local	.LBB8_102
.LBB8_102:                              ;   in Loop: Header=BB8_92 Depth=1
	bit	0, l
	jr	nz, .LBB8_104
; %bb.103:                              ;   in Loop: Header=BB8_92 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 66)
	pop	ix
	.local	.LBB8_104
.LBB8_104:                              ;   in Loop: Header=BB8_92 Depth=1
	bit	0, l
	jr	nz, .LBB8_106
; %bb.105:                              ;   in Loop: Header=BB8_92 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 67)                    ; 1-byte Folded Reload
	pop	ix
	.local	.LBB8_106
.LBB8_106:                              ;   in Loop: Header=BB8_92 Depth=1
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
	jp	.LBB8_92
	.local	.LBB8_107
.LBB8_107:                              ;   in Loop: Header=BB8_92 Depth=1
	ld	de, -172
	lea	iy, ix + 0
	add	iy, de
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	cp	a, 1
	call	pe, __setflag
	ld	a, d
	jp	p, .LBB8_109
; %bb.108:                              ;   in Loop: Header=BB8_92 Depth=1
	ld	a, 0
	.local	.LBB8_109
.LBB8_109:                              ;   in Loop: Header=BB8_92 Depth=1
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
	jr	nz, .LBB8_111
; %bb.110:                              ;   in Loop: Header=BB8_92 Depth=1
	lea	bc, iy + 0
	.local	.LBB8_111
.LBB8_111:                              ;   in Loop: Header=BB8_92 Depth=1
	bit	0, l
	jp	nz, .LBB8_98
; %bb.112:                              ;   in Loop: Header=BB8_92 Depth=1
	ld	a, d
	jp	.LBB8_98
	.local	.LBB8_113
.LBB8_113:
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
	.local	.LBB8_114
.LBB8_114:                              ; %.loopexit
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
	jr	nz, .LBB8_118
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
	jr	nz, .LBB8_117
; %bb.116:
	ld	a, 0
	jr	.LBB8_118
	.local	.LBB8_117
.LBB8_117:
	ld	a, 1
	.local	.LBB8_118
.LBB8_118:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_engine_update, .Lfunc_end8-_engine_update
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
	.local	.LBB9_1
.LBB9_1:                                ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_35
; %bb.2:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	(ix - 39), iy
	ld	(ix - 49), a                    ; 1-byte Folded Spill
	ld	iy, (ix - 27)
	ld	hl, (iy - 3)
	ld	(ix - 52), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, -1
	jr	z, .LBB9_4
; %bb.3:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	a, 0
	.local	.LBB9_4
.LBB9_4:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	(ix - 36), de
	ld	hl, (ix - 27)
	ld	de, (hl)
	ld	(ix - 55), de
	sbc	hl, hl
	adc	hl, de
	ld	c, -1
	jr	z, .LBB9_6
; %bb.5:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	c, 0
	.local	.LBB9_6
.LBB9_6:                                ;   in Loop: Header=BB9_1 Depth=1
	bit	0, c
	ld	de, 42
	jr	nz, .LBB9_8
; %bb.7:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	de, 39
	.local	.LBB9_8
.LBB9_8:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	hl, (ix + 6)
	add	hl, de
	bit	0, c
	jr	nz, .LBB9_10
; %bb.9:                                ;   in Loop: Header=BB9_1 Depth=1
	ld	bc, (ix - 55)
	jr	.LBB9_11
	.local	.LBB9_10
.LBB9_10:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	iy, (ix - 27)
	ld	bc, (iy + 3)
	.local	.LBB9_11
.LBB9_11:                               ;   in Loop: Header=BB9_1 Depth=1
	bit	0, a
	jr	nz, .LBB9_13
; %bb.12:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	hl, (ix - 58)
	.local	.LBB9_13
.LBB9_13:                               ;   in Loop: Header=BB9_1 Depth=1
	bit	0, a
	jr	nz, .LBB9_15
; %bb.14:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	bc, (ix - 52)
	.local	.LBB9_15
.LBB9_15:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	p, .LBB9_17
; %bb.16:                               ;   in Loop: Header=BB9_1 Depth=1
	push	de
	pop	iy
	.local	.LBB9_17
.LBB9_17:                               ;   in Loop: Header=BB9_1 Depth=1
	lea	hl, iy + 0
	ld	de, -4
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB9_31
; %bb.18:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jr	z, .LBB9_20
; %bb.19:                               ;   in Loop: Header=BB9_1 Depth=1
	push	de
	pop	bc
	.local	.LBB9_20
.LBB9_20:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	hl, (ix - 52)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB9_22
; %bb.21:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	bc, (ix - 80)
	.local	.LBB9_22
.LBB9_22:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	p, .LBB9_24
; %bb.23:                               ;   in Loop: Header=BB9_1 Depth=1
	lea	bc, iy + 0
	.local	.LBB9_24
.LBB9_24:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	m, .LBB9_31
; %bb.25:                               ;   in Loop: Header=BB9_1 Depth=1
	lea	hl, iy + 0
	ld	bc, (ix - 64)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB9_31
; %bb.26:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	m, .LBB9_31
; %bb.27:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	m, .LBB9_31
; %bb.28:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	m, .LBB9_31
; %bb.29:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	m, .LBB9_31
; %bb.30:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	p, .LBB9_33
	.local	.LBB9_31
.LBB9_31:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	hl, (ix - 36)
	.local	.LBB9_32
.LBB9_32:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	.LBB9_1
	.local	.LBB9_33
.LBB9_33:                               ;   in Loop: Header=BB9_1 Depth=1
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
	jp	m, .LBB9_32
; %bb.34:                               ;   in Loop: Header=BB9_1 Depth=1
	ld	(ix - 45), de
	ld	de, (ix - 55)
	ld	(ix - 48), de
	ld	de, (ix - 52)
	ld	(ix - 42), de
	ld	e, (ix - 49)                    ; 1-byte Folded Reload
	ld	(ix - 33), de
	ld	de, (ix - 80)
	ld	(ix - 64), de
	jr	.LBB9_32
	.local	.LBB9_35
.LBB9_35:
	ld	hl, (ix - 48)
	ld	(ix - 6), hl
	ld	hl, (ix - 45)
	ld	(ix - 3), hl
	ld	hl, (ix - 42)
	ld	(ix - 9), hl
	ld	hl, (ix - 33)
	ld	a, l
	cp	a, -1
	jr	z, .LBB9_38
; %bb.36:
	push	hl
	push	iy
	call	_room_face_holds_portal
	pop	hl
	pop	hl
	ld	hl, (ix - 33)
	or	a, a
	jr	z, .LBB9_38
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
	.local	.LBB9_38
.LBB9_38:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_place_portal, .Lfunc_end9-_place_portal
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
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_transform_portal_point, .Lfunc_end10-_transform_portal_point
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
	jr	nz, .LBB11_4
; %bb.1:
	push	bc
	pop	iy
	ld	de, (iy + 12)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB11_3
; %bb.2:
	push	bc
	pop	iy
	ld	hl, (iy + 15)
	ld	(ix - 12), hl
	ld	iy, (ix - 3)
	lea	hl, iy + 6
	jr	.LBB11_4
	.local	.LBB11_3
.LBB11_3:
	ld	(ix - 12), de
	ld	iy, (ix - 3)
	lea	hl, iy + 3
	.local	.LBB11_4
.LBB11_4:
	ld	(ix - 9), hl
	push	bc
	pop	iy
	ld	de, (iy + 18)
	sbc	hl, hl
	adc	hl, de
	ld	hl, (ix - 3)
	jr	nz, .LBB11_9
; %bb.5:
	push	bc
	pop	iy
	ld	de, (iy + 21)
	sbc	hl, hl
	adc	hl, de
	ld	(ix - 18), bc
	jr	nz, .LBB11_7
; %bb.6:
	push	bc
	pop	iy
	ld	de, (iy + 24)
	ld	iy, (ix - 3)
	lea	hl, iy + 6
	jr	.LBB11_8
	.local	.LBB11_7
.LBB11_7:
	ld	iy, (ix - 3)
	lea	hl, iy + 3
	.local	.LBB11_8
.LBB11_8:
	ld	bc, (ix - 18)
	.local	.LBB11_9
.LBB11_9:
	ld	(ix - 15), de
	ld	de, (hl)
	push	bc
	pop	iy
	ld	hl, (iy + 27)
	ld	(ix - 6), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB11_13
; %bb.10:
	push	bc
	pop	iy
	ld	hl, (iy + 30)
	ld	(ix - 6), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB11_12
; %bb.11:
	ld	iy, (ix - 3)
	lea	iy, iy + 6
	ld	(ix - 3), iy
	push	bc
	pop	iy
	ld	hl, (iy + 33)
	ld	(ix - 6), hl
	jr	.LBB11_13
	.local	.LBB11_12
.LBB11_12:
	ld	iy, (ix - 3)
	lea	iy, iy + 3
	ld	(ix - 3), iy
	.local	.LBB11_13
.LBB11_13:
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
	jp	p, .LBB11_15
; %bb.14:
	ld	(ix - 9), iy
	.local	.LBB11_15
.LBB11_15:
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
	jp	p, .LBB11_17
; %bb.16:
	ld	iy, (ix - 12)
	.local	.LBB11_17
.LBB11_17:
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
	jp	p, .LBB11_19
; %bb.18:
	ld	(ix - 12), bc
	.local	.LBB11_19
.LBB11_19:
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
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_transform_portal_vector, .Lfunc_end11-_transform_portal_vector
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
	jr	nz, .LBB12_5
; %bb.1:
	ld	de, (ix + 12)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB12_8
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
	jp	p, .LBB12_4
; %bb.3:
	lea	hl, iy + 0
	.local	.LBB12_4
.LBB12_4:
	ld	iy, (ix + 6)
	ld	de, (iy + 6)
	add	hl, de
	ld	(iy + 6), hl
	jr	.LBB12_11
	.local	.LBB12_5
.LBB12_5:
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
	jp	p, .LBB12_7
; %bb.6:
	lea	bc, iy + 0
	.local	.LBB12_7
.LBB12_7:
	ld	iy, (ix + 6)
	ld	hl, (iy)
	add	hl, bc
	ld	(iy), hl
	jr	.LBB12_11
	.local	.LBB12_8
.LBB12_8:
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
	jp	p, .LBB12_10
; %bb.9:
	lea	bc, iy + 0
	.local	.LBB12_10
.LBB12_10:
	ld	iy, (ix + 6)
	ld	hl, (iy + 3)
	add	hl, bc
	ld	(iy + 3), hl
	.local	.LBB12_11
.LBB12_11:
	pop	ix
	ret
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_add_signed_axis, .Lfunc_end12-_add_signed_axis
                                        ; -- End function
	.section	.text._engine_render,"ax",@progbits
	.globl	_engine_render                  ; -- Begin function engine_render
	.type	_engine_render,@function
_engine_render:                         ; @engine_render
; %bb.0:
	ld	hl, -47
	call	__frameset
	ld	iy, (ix + 6)
	ld	l, 3
	ld	(ix - 47), hl
	ld	hl, _render_layers+1208
	ld	(ix - 43), hl
	lea	hl, ix - 37
	ld	(ix - 40), hl
	ld	a, (iy + 51)
	ld	l, a
	push	hl
	call	_configure_render_mode
	pop	hl
	ld	iy, (ix - 40)
	lea	de, iy + 0
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
	ld	(ix - 44), a                    ; 1-byte Folded Spill
	ld	(_render_layers+1309), a
	ld	a, h
	ld	(_render_layers+1310), a
	ld	b, h
	call	__smulu
	ld	iy, _render_layers+1312
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, 0
	ld	e, c
	ld	a, (ix - 44)
	.local	.LBB13_1
.LBB13_1:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB13_3
; %bb.2:                                ;   in Loop: Header=BB13_1 Depth=1
	ld	iy, (ix - 43)
	ld	(iy), 0
	ld	(iy + 48), a
	inc	iy
	ld	(ix - 43), iy
	dec	de
	jr	.LBB13_1
	.local	.LBB13_3
.LBB13_3:
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
	call	_gfx_Wait
	ld	a, (_active_render_shift)
	or	a, a
	jr	nz, .LBB13_5
; %bb.4:
	call	_present_low_frame_fast
	jr	.LBB13_6
	.local	.LBB13_5
.LBB13_5:
	call	_present_low_frame_32_fast
	.local	.LBB13_6
.LBB13_6:
	ld	iy, (ix + 6)
	ld	a, (iy + 50)
	ld	(ix - 44), a
	ld	hl, (-1900524)
	ld	(ix - 40), hl
	or	a, a
	sbc	hl, hl
	push	hl
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
	ld	(ix - 43), hl
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
	jr	nz, .LBB13_8
; %bb.7:
	ld	hl, 2
	push	hl
	push	hl
	ld	hl, _.str
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	jp	.LBB13_11
	.local	.LBB13_8
.LBB13_8:
	ld	l, e
	ld	h, d
	ld.sis	bc, 10
	call	__sdivu
	ld	bc, (ix - 43)
	ld	c, l
	ld	b, h
	ld	(ix - 43), bc
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
	jr	nc, .LBB13_10
; %bb.9:
	inc	a
	ld	l, a
	ld	(ix - 47), hl
	.local	.LBB13_10
.LBB13_10:
	ld	hl, 2
	push	hl
	push	hl
	ld	hl, _.str.1
	push	hl
	call	_gfx_PrintStringXY
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 47)
	push	hl
	ld	hl, (ix - 43)
	push	hl
	call	_gfx_PrintUInt
	pop	hl
	pop	hl
	ld	hl, 46
	push	hl
	call	_gfx_PrintChar
	pop	hl
	ld	hl, (ix - 43)
                                        ; kill: def $hl killed $hl killed $uhl
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
	.local	.LBB13_11
.LBB13_11:
	pop	hl
	pop	hl
	ld	a, (ix - 44)                    ; 1-byte Folded Reload
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
	.local	.LBB13_12
.LBB13_12:                              ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB13_14
; %bb.13:                               ;   in Loop: Header=BB13_12 Depth=1
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
	jr	.LBB13_12
	.local	.LBB13_14
.LBB13_14:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_engine_render, .Lfunc_end13-_engine_render
                                        ; -- End function
	.section	.text._render_camera,"ax",@progbits
	.type	_render_camera,@function        ; -- Begin function render_camera
_render_camera:                         ; @render_camera
; %bb.0:
	ld	hl, -162
	call	__frameset
	ld	a, (ix + 9)
	ld	iy, _render_layers
	ld	de, 1
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 1318
	ld	(ix - 91), hl
	call	__imulu
	push	hl
	pop	bc
	ld	(ix - 97), iy
	add	iy, bc
	or	a, a
	ex	de, hl
	jr	z, .LBB14_2
; %bb.1:
	ld	hl, 0
	.local	.LBB14_2
.LBB14_2:
	push	hl
	ld	l, (ix + 12)
	push	hl
	ld	hl, (ix + 6)
	push	hl
	push	iy
	ld	(ix - 85), iy
	call	_collect_room_polygons
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, (ix - 85)
	ld	a, (ix + 9)
	or	a, a
	ld	de, 1306
	jp	nz, .LBB14_169
; %bb.3:
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
	ld	hl, _low_frame+2
	push	hl
	call	_memset
	ld	iy, (ix - 85)
	ld	bc, 0
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB14_4
.LBB14_4:                               ; %.loopexit73
	lea	hl, ix - 45
	ld	(ix - 115), hl
	lea	hl, ix - 82
	ld	(ix - 127), hl
	lea	hl, ix - 8
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	lea	hl, ix - 82
	ld	(ix - 112), hl
	lea	hl, iy + 0
	ld	de, 1208
	add	hl, de
	ld	(ix - 121), hl
	lea	hl, iy + 0
	ld	de, 1256
	add	hl, de
	ld	(ix - 124), hl
	ld	hl, (ix - 91)
	push	bc
	pop	iy
	ld	bc, 1318
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 97)
	add	hl, de
	ld	(ix - 97), hl
	ld	bc, 1305
	or	a, a
	sbc	hl, hl
	ld	(ix - 88), hl
	ld	hl, (ix - 85)
	.local	.LBB14_5
.LBB14_5:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB14_7 Depth 2
                                        ;     Child Loop BB14_36 Depth 2
                                        ;       Child Loop BB14_52 Depth 3
                                        ;       Child Loop BB14_69 Depth 3
                                        ;     Child Loop BB14_18 Depth 2
	push	hl
	pop	de
	add	hl, bc
	ld	a, (hl)
	lea	bc, iy + 0
	ld	c, a
	ld	hl, (ix - 88)
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB14_78
; %bb.6:                                ;   in Loop: Header=BB14_5 Depth=1
	ld	(ix - 109), a                   ; 1-byte Folded Spill
	ld	hl, (ix - 88)
	ld	(ix - 91), bc
	ld	bc, 151
	call	__imulu
	push	hl
	pop	bc
	push	de
	pop	hl
	add	hl, bc
	ld	(ix - 94), hl
	ex	de, hl
	ld	bc, 1304
	add	hl, bc
	ld	a, (hl)
	lea	hl, iy + 0
	ld	l, a
	ld	(ix - 103), hl
	ld	hl, (ix - 91)
	ld	bc, 151
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 97)
	add	hl, bc
	ld	bc, 146
	add	hl, bc
	ld	(ix - 106), hl
	ld	hl, (ix - 91)
	ld	e, b
	ld	a, e
	.local	.LBB14_7
.LBB14_7:                               ;   Parent Loop BB14_5 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	bc, iy + 0
	ld	c, a
	push	hl
	pop	iy
	ld	de, (ix - 103)
	or	a, a
	sbc	hl, de
	jp	nc, .LBB14_16
; %bb.8:                                ;   in Loop: Header=BB14_7 Depth=2
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	cp	a, 2
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	jr	nc, .LBB14_16
; %bb.9:                                ;   in Loop: Header=BB14_7 Depth=2
	ld	hl, (ix - 106)
	ld	a, (hl)
	cp	a, -1
	jr	nz, .LBB14_11
; %bb.10:                               ;   in Loop: Header=BB14_7 Depth=2
	ld	a, (ix - 109)                   ; 1-byte Folded Reload
	lea	de, iy + 0
	jr	.LBB14_15
	.local	.LBB14_11
.LBB14_11:                              ;   in Loop: Header=BB14_7 Depth=2
	ld	(ix - 118), bc
	ld	(ix - 91), iy
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 46
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _portals
	add	hl, bc
	ex	de, hl
	ld	iy, (ix - 94)
	ld	bc, 147
	add	iy, bc
	ld	l, (iy)
	push	de
	pop	iy
	ld	a, (iy + 43)
	cp	a, l
	jr	nz, .LBB14_13
; %bb.12:                               ;   in Loop: Header=BB14_7 Depth=2
	inc	(ix - 100)
	ld	hl, (ix - 115)
	ld	bc, (ix - 118)
	add	hl, bc
	ld	a, (ix - 109)                   ; 1-byte Folded Reload
	ld	(hl), a
	ld	de, (ix - 91)
	jr	.LBB14_14
	.local	.LBB14_13
.LBB14_13:                              ;   in Loop: Header=BB14_7 Depth=2
	ld	de, (ix - 91)
	ld	a, (ix - 109)                   ; 1-byte Folded Reload
	.local	.LBB14_14
.LBB14_14:                              ;   in Loop: Header=BB14_7 Depth=2
	ld	hl, (ix - 106)
	.local	.LBB14_15
.LBB14_15:                              ;   in Loop: Header=BB14_7 Depth=2
	inc	de
	ld	bc, 151
	add	hl, bc
	ld	(ix - 106), hl
	inc	a
	ld	(ix - 109), a
	ld	iy, 0
	ld	a, (ix - 100)                   ; 1-byte Folded Reload
	ex	de, hl
	jp	.LBB14_7
	.local	.LBB14_16
.LBB14_16:                              ;   in Loop: Header=BB14_5 Depth=1
	ld	(ix - 118), bc
	ld	de, (ix - 94)
	push	de
	pop	iy
	ld	bc, 149
	add	iy, bc
	ld	l, (iy)
	push	de
	pop	iy
	lea	bc, iy + 48
	ld	(ix - 91), bc
	lea	bc, iy + 96
	ld	(ix - 100), bc
	or	a, a
	jp	nz, .LBB14_35
; %bb.17:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB14_5 Depth=1
                                        ; kill: def $l killed $l def $uhl
	.local	.LBB14_18
.LBB14_18:                              ; %.preheader
                                        ;   Parent Loop BB14_5 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	iy, (ix - 94)
	ld	de, 150
	add	iy, de
	ld	a, (iy)
	cp	a, l
	jp	c, .LBB14_77
; %bb.19:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	bc, 0
	ld	c, l
	push	hl
	pop	iy
	ld	hl, (ix - 91)
	add	hl, bc
	ld	e, (hl)
	ld	hl, (ix - 100)
	ld	(ix - 109), bc
	add	hl, bc
	ld	a, (hl)
	ld	(ix - 106), a                   ; 1-byte Folded Spill
	ld	(ix - 103), e                   ; 1-byte Folded Spill
	cp	a, e
	jp	c, .LBB14_34
; %bb.20:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1306
	add	hl, de
	ld	l, (hl)
	ld	a, iyl
	cp	a, l
	jp	c, .LBB14_34
; %bb.21:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1307
	add	hl, de
	ld	a, (hl)
	cp	a, iyl
	jp	c, .LBB14_34
; %bb.22:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	(ix - 118), iy
	ld	hl, (ix - 121)
	ld	de, (ix - 109)
	add	hl, de
	ld	a, (hl)
	ld	l, (ix - 103)
	cp	a, l
	jr	c, .LBB14_24
; %bb.23:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	(ix - 103), a                   ; 1-byte Folded Spill
	.local	.LBB14_24
.LBB14_24:                              ;   in Loop: Header=BB14_18 Depth=2
	ld	hl, (ix - 124)
	add	hl, de
	ld	l, (hl)
	ld	a, (ix - 106)                   ; 1-byte Folded Reload
	cp	a, l
	jr	c, .LBB14_26
; %bb.25:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	(ix - 106), l                   ; 1-byte Folded Spill
	.local	.LBB14_26
.LBB14_26:                              ;   in Loop: Header=BB14_18 Depth=2
	ld	iy, (ix - 94)
	ld	de, 148
	add	iy, de
	ld	a, (iy)
	ld	bc, 0
	ld	c, a
	ld	hl, _face_light_level
	add	hl, bc
	ld	l, (hl)
	cp	a, 2
	jp	nc, .LBB14_33
; %bb.27:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	(ix - 109), l                   ; 1-byte Folded Spill
	ld	bc, (ix - 85)
	push	bc
	pop	hl
	ld	de, 1316
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	nz, .LBB14_29
; %bb.28:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	l, (ix - 109)                   ; 1-byte Folded Reload
	jp	.LBB14_33
	.local	.LBB14_29
.LBB14_29:                              ;   in Loop: Header=BB14_18 Depth=2
	ld	iyh, 0
	ld	hl, (ix - 118)
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
	jr	nc, .LBB14_31
; %bb.30:                               ;   in Loop: Header=BB14_18 Depth=2
	ld	l, -2
	jp	.LBB14_32
	.local	.LBB14_31
.LBB14_31:                              ;   in Loop: Header=BB14_18 Depth=2
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
	.local	.LBB14_32
.LBB14_32:                              ;   in Loop: Header=BB14_18 Depth=2
	ld	e, (ix - 109)                   ; 1-byte Folded Reload
	ld	a, e
	add	a, l
	ld	e, a
	ld	l, e
	.local	.LBB14_33
.LBB14_33:                              ;   in Loop: Header=BB14_18 Depth=2
	ld	iy, (ix - 94)
	ld	de, 145
	add	iy, de
	ld	a, (iy)
	add	a, l
	ld	l, a
	push	hl
	ld	bc, 0
	push	bc
	pop	hl
	ld	l, (ix - 106)                   ; 1-byte Folded Reload
	push	hl
	push	bc
	pop	hl
	ld	l, (ix - 103)                   ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 118)
	push	hl
	call	_write_frame_span
	ld	iy, (ix - 118)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB14_34
.LBB14_34:                              ;   in Loop: Header=BB14_18 Depth=2
	inc	iyl
	lea	hl, iy + 0
	jp	.LBB14_18
	.local	.LBB14_35
.LBB14_35:                              ;   in Loop: Header=BB14_5 Depth=1
	ld	c, l
	.local	.LBB14_36
.LBB14_36:                              ; %.preheader71
                                        ;   Parent Loop BB14_5 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB14_52 Depth 3
                                        ;       Child Loop BB14_69 Depth 3
	ld	iy, (ix - 94)
	ld	de, 150
	add	iy, de
	ld	a, (iy)
	cp	a, c
	jp	c, .LBB14_77
; %bb.37:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	de, 0
	ld	e, c
	ld	hl, (ix - 91)
	add	hl, de
	ld	(ix - 103), bc
	ld	c, (hl)
	ld	hl, (ix - 100)
	ld	(ix - 106), de
	add	hl, de
	ld	b, (hl)
	ld	a, b
	cp	a, c
	jp	c, .LBB14_76
; %bb.38:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1306
	add	hl, de
	ld	l, (hl)
	ld	de, (ix - 103)
	ld	a, e
	cp	a, l
	jp	c, .LBB14_76
; %bb.39:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	hl, (ix - 85)
	ld	de, 1307
	add	hl, de
	ld	a, (hl)
	ld	hl, (ix - 103)
	cp	a, l
	jp	c, .LBB14_76
; %bb.40:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	hl, (ix - 121)
	ld	de, (ix - 106)
	add	hl, de
	ld	a, (hl)
	cp	a, c
	ld	iyl, c
	jr	c, .LBB14_42
; %bb.41:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	iyl, a
	.local	.LBB14_42
.LBB14_42:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	iyh, 0
	ld	hl, (ix - 124)
	ld	de, (ix - 106)
	add	hl, de
	ld	l, (hl)
	ld	a, b
	cp	a, l
	jr	c, .LBB14_44
; %bb.43:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	b, l
	.local	.LBB14_44
.LBB14_44:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	a, b
	cp	a, iyl
	jp	c, .LBB14_76
; %bb.45:                               ;   in Loop: Header=BB14_36 Depth=2
	push	iy
	ex	(sp), hl
	ld	(ix - 109), l
	ld	(ix - 108), h
	pop	hl
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), b                     ; 1-byte Folded Spill
	ld	iy, (ix - 94)
	ld	de, 148
	add	iy, de
	ld	a, (iy)
	ld	bc, 0
	ld	c, a
	ld	hl, _face_light_level
	add	hl, bc
	ld	l, (hl)
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	cp	a, 2
	jp	nc, .LBB14_51
; %bb.46:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	bc, (ix - 85)
	push	bc
	pop	hl
	ld	de, 1316
	add	hl, de
	ld	a, (hl)
	or	a, a
	jp	z, .LBB14_51
; %bb.47:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	l, (ix - 109)
	ld	h, (ix - 108)
                                        ; kill: def $h killed $h killed $hl def $hl
	ld	de, (ix - 103)
	ld	l, e
	push	bc
	pop	iy
	ld	de, 1314
	add	iy, de
	ld	e, (ix - 109)
	ld	d, (ix - 108)
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
	jr	nc, .LBB14_49
; %bb.48:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	l, -2
	jp	.LBB14_50
	.local	.LBB14_49
.LBB14_49:                              ;   in Loop: Header=BB14_36 Depth=2
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
	.local	.LBB14_50
.LBB14_50:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)
	ld	a, e
	add	a, l
	ld	e, a
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e
	.local	.LBB14_51
.LBB14_51:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	iy, (ix - 94)
	ld	de, 145
	add	iy, de
	ld	a, (iy)
	ld	de, -139
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a
	or	a, a
	sbc	hl, hl
	xor	a, a
	ld	de, -142
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	bc, 0
	ld	iy, (ix - 85)
	.local	.LBB14_52
.LBB14_52:                              ;   Parent Loop BB14_5 Depth=1
                                        ;     Parent Loop BB14_36 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), hl
	pop	ix
	ld	de, (ix - 118)
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 14)                    ; 1-byte Folded Reload
	pop	ix
	jp	nc, .LBB14_65
; %bb.53:                               ;   in Loop: Header=BB14_52 Depth=3
	ld	a, e
	cp	a, 2
	jp	nc, .LBB14_65
; %bb.54:                               ;   in Loop: Header=BB14_52 Depth=3
	ld	hl, (ix - 115)
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 17)
	pop	ix
	add	hl, de
	ld	a, (hl)
	push	bc
	pop	hl
	ld	l, a
	ld	bc, 151
	call	__imulu
	push	hl
	pop	bc
	add	iy, bc
	lea	hl, iy + 0
	ld	de, 149
	add	hl, de
	ld	l, (hl)
	ld	bc, (ix - 103)
	ld	a, c
	cp	a, l
	jr	c, .LBB14_57
; %bb.55:                               ;   in Loop: Header=BB14_52 Depth=3
	lea	hl, iy + 0
	ld	de, 150
	add	hl, de
	ld	a, (hl)
	cp	a, c
	jr	c, .LBB14_57
; %bb.56:                               ;   in Loop: Header=BB14_52 Depth=3
	ld	de, (ix - 106)
	add	iy, de
	ld	l, (iy + 48)
	ld	d, (iy + 96)
	ld	a, d
	cp	a, l
	jr	nc, .LBB14_59
	.local	.LBB14_57
.LBB14_57:                              ;   in Loop: Header=BB14_52 Depth=3
	ld	bc, 0
	ld	iy, (ix - 85)
	.local	.LBB14_58
.LBB14_58:                              ;   in Loop: Header=BB14_52 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 17)
	pop	ix
	inc	hl
	jp	.LBB14_52
	.local	.LBB14_59
.LBB14_59:                              ;   in Loop: Header=BB14_52 Depth=3
	ld	e, l
	ld	l, (ix - 109)
	ld	h, (ix - 108)
	ld	a, l
	ld	h, e
	cp	a, h
	ld	bc, 0
	ld	iy, (ix - 85)
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 14)                    ; 1-byte Folded Reload
	pop	ix
	jr	c, .LBB14_61
; %bb.60:                               ;   in Loop: Header=BB14_52 Depth=3
	ld	l, (ix - 109)
	ld	h, (ix - 108)
	ld	h, l
	.local	.LBB14_61
.LBB14_61:                              ;   in Loop: Header=BB14_52 Depth=3
	ld	a, d
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)
	pop	ix
	cp	a, l
	jr	c, .LBB14_63
; %bb.62:                               ;   in Loop: Header=BB14_52 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	d, (ix - 8)                     ; 1-byte Folded Reload
	pop	ix
	.local	.LBB14_63
.LBB14_63:                              ;   in Loop: Header=BB14_52 Depth=3
	ld	a, d
	cp	a, h
	jr	c, .LBB14_58
; %bb.64:                               ;   in Loop: Header=BB14_52 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), bc
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 23), d                    ; 1-byte Folded Spill
	pop	ix
	ld	a, e
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 20)
	pop	ix
	ld	e, a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), de
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 25), h                    ; 1-byte Folded Spill
	pop	ix
	ld	hl, (ix - 127)
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 20)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 25)
	pop	ix
	ld	(hl), e
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 20)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	e, (ix - 23)
	pop	ix
	ld	(hl), e
	inc	a
	ld	de, -142
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a
	jp	.LBB14_58
	.local	.LBB14_65
.LBB14_65:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	a, e
	cp	a, 2
	jr	nz, .LBB14_68
; %bb.66:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	a, (ix - 81)
	ld	l, (ix - 82)
	cp	a, l
	jr	nc, .LBB14_68
; %bb.67:                               ;   in Loop: Header=BB14_36 Depth=2
	ld	(ix - 82), a
	ld	(ix - 81), l
	ld	a, (ix - 8)
	ld	l, (ix - 7)
	ld	(ix - 8), l
	ld	(ix - 7), a
	.local	.LBB14_68
.LBB14_68:                              ; %.preheader125
                                        ;   in Loop: Header=BB14_36 Depth=2
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	l, (iy + 0)
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	a, (iy + 0)
	add	a, l
	ld	l, a
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	de, (ix - 127)
	ld	bc, -133
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	ld	bc, -130
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	(ix - 106), de
	ld	c, (ix - 109)
	ld	b, (ix - 108)
	ld	e, c
	ld	d, b
	ld	iy, (ix - 103)
	.local	.LBB14_69
.LBB14_69:                              ;   Parent Loop BB14_5 Depth=1
                                        ;     Parent Loop BB14_36 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), hl
	pop	ix
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB14_75
; %bb.70:                               ;   in Loop: Header=BB14_69 Depth=3
	ld	hl, (ix - 106)
	ld	a, (hl)
	ld	c, a
	ld	l, c
	ld	h, b
	or	a, a
	sbc.sis	hl, de
	jr	c, .LBB14_73
; %bb.71:                               ;   in Loop: Header=BB14_69 Depth=3
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 17
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	a, (hl)
	ld	h, 0
	ld	l, a
	dec.sis	hl
	push	ix
	lea	ix, ix - 128
	ld	iy, (ix - 11)
	pop	ix
	push	iy
	push	hl
	push	de
	ld	hl, (ix - 103)
	push	hl
	ld	(ix - 109), c
	ld	(ix - 108), b
	call	_write_frame_span
	ld	c, (ix - 109)
	ld	b, (ix - 108)
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	e, c
	ld	d, b
	inc.sis	de
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 17
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	l, (iy + 0)
	cp	a, l
	jr	nc, .LBB14_74
; %bb.72:                               ;   in Loop: Header=BB14_69 Depth=3
	ld	iy, (ix - 103)
	.local	.LBB14_73
.LBB14_73:                              ;   in Loop: Header=BB14_69 Depth=3
	ld	hl, (ix - 106)
	inc	hl
	ld	(ix - 106), hl
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	inc	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	dec	hl
	jp	.LBB14_69
	.local	.LBB14_74
.LBB14_74:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	iy, (ix - 103)
	.local	.LBB14_75
.LBB14_75:                              ;   in Loop: Header=BB14_36 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	push	hl
	or	a, a
	sbc	hl, hl
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 8)                     ; 1-byte Folded Reload
	pop	ix
	push	hl
	push	de
	push	iy
	call	_write_frame_span
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB14_76
.LBB14_76:                              ;   in Loop: Header=BB14_36 Depth=2
	ld	bc, (ix - 103)
	inc	c
	jp	.LBB14_36
	.local	.LBB14_77
.LBB14_77:                              ; %.loopexit70
                                        ;   in Loop: Header=BB14_5 Depth=1
	ld	hl, (ix - 88)
	inc	hl
	ld	(ix - 88), hl
	ld	iy, 0
	ld	hl, (ix - 85)
	ld	de, 1305
	push	de
	pop	bc
	jp	.LBB14_5
	.local	.LBB14_78
.LBB14_78:
	ld	a, (ix + 9)
	or	a, a
	jp	nz, .LBB14_168
; %bb.79:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	lea	hl, iy + 9
	ld	(ix - 103), hl
	lea	hl, iy + 18
	ld	(ix - 106), hl
	lea	hl, iy + 27
	ld	(ix - 109), hl
	ld	iy, 0
	.local	.LBB14_80
.LBB14_80:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB14_87 Depth 2
                                        ;     Child Loop BB14_130 Depth 2
                                        ;     Child Loop BB14_133 Depth 2
                                        ;       Child Loop BB14_135 Depth 3
                                        ;     Child Loop BB14_153 Depth 2
                                        ;       Child Loop BB14_157 Depth 3
                                        ;     Child Loop BB14_161 Depth 2
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
	jp	nc, .LBB14_168
; %bb.81:                               ;   in Loop: Header=BB14_80 Depth=1
	ld	(ix - 91), bc
	push	bc
	pop	hl
	ld	bc, 151
	call	__imulu
	ex	de, hl
	ld	hl, (ix - 85)
	add	hl, de
	ld	(ix - 88), hl
	ld	a, -1
	ld	(_render_layers+2526), a
	ld	bc, _render_layers+2526
	push	bc
	pop	hl
	inc	hl
	ex	de, hl
	push	bc
	pop	hl
	ld	iy, 47
	lea	bc, iy + 0
	ldir
	inc	a
	ld	(_render_layers+2574), a
	ld	bc, _render_layers+2574
	push	bc
	pop	hl
	inc	hl
	ex	de, hl
	push	bc
	pop	hl
	lea	bc, iy + 0
	ldir
	ld	a, (_active_render_height)
	ld	(ix - 100), a                   ; 1-byte Folded Spill
	ld	(_render_layers+2624), a
	ld	l, 0
	ld	a, l
	ld	(_render_layers+2625), a
	ld	a, (_active_render_width)
	ld	(ix - 94), a                    ; 1-byte Folded Spill
	ld	(_render_layers+2626), a
	ld	a, l
	ld	(_render_layers+2627), a
	ld.sis	hl, 0
	ld	iy, _render_layers+2630
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 88)
	ld	de, 149
	add	hl, de
	ld	e, (hl)
	ld	hl, (ix - 85)
	ld	bc, 1306
	add	hl, bc
	ld	a, (hl)
	cp	a, e
	jr	c, .LBB14_83
; %bb.82:                               ;   in Loop: Header=BB14_80 Depth=1
	ld	e, a
	.local	.LBB14_83
.LBB14_83:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	hl, (ix - 88)
	ld	bc, 150
	add	hl, bc
	ld	a, (hl)
	ld	hl, (ix - 85)
	ld	bc, 1307
	add	hl, bc
	ld	l, (hl)
	cp	a, l
	jr	c, .LBB14_85
; %bb.84:                               ;   in Loop: Header=BB14_80 Depth=1
	ld	a, l
	.local	.LBB14_85
.LBB14_85:                              ;   in Loop: Header=BB14_80 Depth=1
	cp	a, e
	ld	bc, (ix - 91)
	ld	iy, 0
	jp	c, .LBB14_167
; %bb.86:                               ;   in Loop: Header=BB14_80 Depth=1
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	ld	h, 0
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), h                     ; 1-byte Folded Spill
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), h                     ; 1-byte Folded Spill
	pop	ix
	ld	l, (ix - 94)                    ; 1-byte Folded Reload
	.local	.LBB14_87
.LBB14_87:                              ;   Parent Loop BB14_80 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	cp	a, e
	jp	c, .LBB14_112
; %bb.88:                               ;   in Loop: Header=BB14_87 Depth=2
	ld	(ix - 127), h                   ; 1-byte Folded Spill
	ld	d, l
	lea	bc, iy + 0
	ld	c, e
	ld	iy, (ix - 88)
	add	iy, bc
	ld	l, (iy + 48)
	ld	a, (iy + 96)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	(ix - 118), l
	ld	(ix - 117), h
	cp	a, l
	jr	nc, .LBB14_90
; %bb.89:                               ;   in Loop: Header=BB14_87 Depth=2
	ld	iy, 0
	ld	bc, (ix - 91)
	ld	l, d
	jr	.LBB14_97
	.local	.LBB14_90
.LBB14_90:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	(ix - 94), d                    ; 1-byte Folded Spill
	ld	hl, (ix - 121)
	add	hl, bc
	ld	d, (hl)
	ld	hl, (ix - 124)
	add	hl, bc
	ld	a, (hl)
	ld	iyl, d
	cp	a, d
	jr	c, .LBB14_96
; %bb.91:                               ;   in Loop: Header=BB14_87 Depth=2
	ld	d, a
	ld	a, iyl
	ld	l, (ix - 118)
	ld	h, (ix - 117)
	cp	a, l
	jr	c, .LBB14_93
; %bb.92:                               ;   in Loop: Header=BB14_87 Depth=2
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	(ix - 118), l
	ld	(ix - 117), h
	.local	.LBB14_93
.LBB14_93:                              ;   in Loop: Header=BB14_87 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	cp	a, d
	jr	c, .LBB14_95
; %bb.94:                               ;   in Loop: Header=BB14_87 Depth=2
	ld	a, d
	.local	.LBB14_95
.LBB14_95:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	l, (ix - 118)
	ld	h, (ix - 117)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	cp	a, l
	jr	nc, .LBB14_99
	.local	.LBB14_96
.LBB14_96:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	iy, 0
	ld	bc, (ix - 91)
	ld	l, (ix - 94)                    ; 1-byte Folded Reload
	.local	.LBB14_97
.LBB14_97:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	h, (ix - 127)                   ; 1-byte Folded Reload
	.local	.LBB14_98
.LBB14_98:                              ;   in Loop: Header=BB14_87 Depth=2
	inc	e
	jp	.LBB14_87
	.local	.LBB14_99
.LBB14_99:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	h, 0
	ld	l, a
	push	iy
	ex	(sp), hl
	ld	(ix - 118), l
	ld	(ix - 117), h
	pop	hl
	ld	(ix - 94), e                    ; 1-byte Folded Spill
	ld	e, (ix - 118)
	ld	d, (ix - 117)
	ld	d, h
	ld	(ix - 118), e
	ld	(ix - 117), d
	ld	iy, _render_layers+2526
	add	iy, bc
	ld	e, (ix - 118)
	ld	d, (ix - 117)
	ld	(iy), e
	ld	iy, _render_layers+2574
	add	iy, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), a                    ; 1-byte Folded Spill
	pop	ix
	ld	(iy), a
	ld	iy, _render_layers+2630
	ld	bc, (iy)
	ld	e, (ix - 118)
	ld	d, (ix - 117)
	or	a, a
	sbc.sis	hl, de
	ld	e, (ix - 94)                    ; 1-byte Folded Reload
                                        ; kill: def $hl killed $hl def $uhl
	add.sis	hl, bc
	inc.sis	hl
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	ld	(iy), l
	ld	(iy + 1), h
	ld	a, (_render_layers+2624)
	ld	l, a
	ld	d, (ix - 127)                   ; 1-byte Folded Reload
	ld	a, d
	or	a, a
	jr	z, .LBB14_101
; %bb.100:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	a, e
	cp	a, l
	jr	nc, .LBB14_102
	.local	.LBB14_101
.LBB14_101:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	a, e
	ld	(_render_layers+2624), a
	ld	l, e
	.local	.LBB14_102
.LBB14_102:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	(ix - 100), l
	ld	a, (_render_layers+2625)
	ld	l, a
	ld	a, d
	or	a, a
	jr	z, .LBB14_104
; %bb.103:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	a, l
	cp	a, e
	jr	nc, .LBB14_105
	.local	.LBB14_104
.LBB14_104:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	a, e
	ld	(_render_layers+2625), a
	ld	l, e
	.local	.LBB14_105
.LBB14_105:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	bc, -136
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	a, (_render_layers+2626)
	ld	l, a
	ld	a, d
	or	a, a
	ld	iy, 0
	ld	bc, (ix - 91)
	jr	z, .LBB14_107
; %bb.106:                              ;   in Loop: Header=BB14_87 Depth=2
	ld	d, l
	ld	l, (ix - 118)
	ld	h, (ix - 117)
	ld	a, l
	ld	l, d
	ld	d, (ix - 127)                   ; 1-byte Folded Reload
	cp	a, l
	jp	nc, .LBB14_108
	.local	.LBB14_107
.LBB14_107:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	l, (ix - 118)
	ld	h, (ix - 117)
	ld	a, l
	ld	(_render_layers+2626), a
                                        ; kill: def $l killed $l killed $hl
	.local	.LBB14_108
.LBB14_108:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	a, (_render_layers+2627)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), a                     ; 1-byte Folded Spill
	pop	ix
	ld	a, d
	or	a, a
	push	ix
	lea	ix, ix - 128
	ld	h, (ix - 11)                    ; 1-byte Folded Reload
	pop	ix
	jr	z, .LBB14_110
; %bb.109:                              ;   in Loop: Header=BB14_87 Depth=2
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 2)                     ; 1-byte Folded Reload
	pop	ix
	cp	a, h
	jr	nc, .LBB14_111
	.local	.LBB14_110
.LBB14_110:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	a, h
	ld	(_render_layers+2627), a
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), h                     ; 1-byte Folded Spill
	pop	ix
	.local	.LBB14_111
.LBB14_111:                             ;   in Loop: Header=BB14_87 Depth=2
	ld	h, 1
	jp	.LBB14_98
	.local	.LBB14_112
.LBB14_112:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	(ix - 94), l                    ; 1-byte Folded Spill
	ld	a, h
	or	a, a
	jp	z, .LBB14_167
; %bb.113:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	hl, (ix - 88)
	ld	de, 146
	add	hl, de
	ld	(ix - 127), hl
	ld	a, (hl)
	lea	de, iy + 0
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	e, a
	ld	iy, _portal_lod_state
	ld	bc, -139
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	add	iy, de
	ld	a, (_active_render_shift)
	or	a, a
	jr	nz, .LBB14_115
; %bb.114:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	b, 0
	.local	.LBB14_115
.LBB14_115:                             ;   in Loop: Header=BB14_80 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 5)
	pop	ix
	push	de
	pop	hl
	add	hl, hl
	add	hl, hl
	ld	(ix - 118), l
	ld	(ix - 117), h
	bit	0, b
	ld	c, (ix - 100)                   ; 1-byte Folded Reload
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 2)                     ; 1-byte Folded Reload
	pop	ix
	jr	nz, .LBB14_117
; %bb.116:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	l, e
	ld	h, d
	ld	(ix - 118), l
	ld	(ix - 117), h
	.local	.LBB14_117
.LBB14_117:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	l, (ix - 94)
	sub	a, l
	ld	l, a
	inc	l
	push	ix
	lea	ix, ix - 128
	ld	a, (ix - 8)
	pop	ix
	sub	a, c
	ld	h, a
	inc	h
	ld	c, (iy)
	ld	a, b
	and	a, 1
	ld	b, a
	ld	a, l
	call	__bshl
	ld	iyl, a
	ld	a, h
	call	__bshl
	ld	iyh, a
	ld	a, c
	or	a, a
	jp	nz, .LBB14_120
; %bb.118:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	e, (ix - 118)
	ld	d, (ix - 117)
	ld	l, e
	ld	h, d
	ld.sis	bc, 160
	or	a, a
	sbc.sis	hl, bc
	ld	c, 2
	jp	c, .LBB14_127
; %bb.119:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	a, iyl
	cp	a, 40
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	iyl, a
	ex.sis	de, hl
	ld.sis	bc, 960
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	or	a, l
	ld	l, a
	ld	a, iyh
	cp	a, 30
	jp	.LBB14_126
	.local	.LBB14_120
.LBB14_120:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	a, c
	cp	a, 1
	ld	e, (ix - 118)
	ld	d, (ix - 117)
	jp	nz, .LBB14_123
; %bb.121:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	l, e
	ld	h, d
	ld.sis	bc, 160
	or	a, a
	sbc.sis	hl, bc
	ld	c, 2
	jp	c, .LBB14_127
; %bb.122:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	a, iyl
	cp	a, 49
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	iyl, a
	ex.sis	de, hl
	ld.sis	bc, 1281
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	or	a, l
	jp	.LBB14_125
	.local	.LBB14_123
.LBB14_123:                             ;   in Loop: Header=BB14_80 Depth=1
	ex.sis	de, hl
	ld.sis	de, 257
	or	a, a
	sbc.sis	hl, de
	ld	l, (ix - 118)
	ld	h, (ix - 117)
	jp	c, .LBB14_127
; %bb.124:                              ;   in Loop: Header=BB14_80 Depth=1
	ld	a, iyl
	cp	a, 49
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	e, a
	ld.sis	bc, 1281
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	or	a, e
	.local	.LBB14_125
.LBB14_125:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	l, a
	ld	a, iyh
	cp	a, 37
	.local	.LBB14_126
.LBB14_126:                             ;   in Loop: Header=BB14_80 Depth=1
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	c, a
	ld	a, l
	or	a, c
	ld	l, a
	ld	c, 1
	ld	a, l
	and	a, c
	ld	c, a
	.local	.LBB14_127
.LBB14_127:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	hl, _portal_lod_state
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 11
	ld	de, (iy + 0)
	add	hl, de
	ld	(hl), c
	ld	a, c
	ld	(_render_layers+2628), a
	ex	de, hl
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
	ld	(ix - 94), hl
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
	ld	hl, (ix - 112)
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
	ld	hl, (ix - 103)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	iy, (ix - 112)
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
	ld	hl, (ix - 106)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	iy, (ix - 112)
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
	ld	hl, (ix - 109)
	ld	bc, 9
	ldir
	ld	l, (ix - 97)                    ; 1-byte Folded Reload
	push	hl
	ld	iy, (ix - 112)
	pea	iy + 27
	call	_transform_portal_vector
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 94)
	ld	bc, 46
	call	__imulu
	ex	de, hl
	ld	iy, _portals
	add	iy, de
	ld	a, (iy + 42)
	ld	(ix - 46), a
	ld	de, (ix - 115)
	ld	hl, (ix - 112)
	ld	bc, 37
	ldir
	ld	hl, (ix - 127)
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
	jp	nz, .LBB14_129
; %bb.128:                              ;   in Loop: Header=BB14_80 Depth=1
                                        ; kill: def $l killed $l def $uhl
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, (ix - 115)
	push	hl
	call	_render_camera
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_layers+2624)
	ld	c, a
	ld	a, (_render_layers+2625)
	jp	.LBB14_160
	.local	.LBB14_129
.LBB14_129:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	(ix - 94), l                    ; 1-byte Folded Spill
	ld	a, (_active_render_width)
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	call	__ishru
	ld	(ix - 97), hl
	ld	a, (_active_render_height)
	ex	de, hl
	ld	l, a
	call	__ishru
	ex	de, hl
	ld	hl, _portal_lod_frame
	push	hl
	pop	iy
	.local	.LBB14_130
.LBB14_130:                             ;   Parent Loop BB14_80 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB14_132
; %bb.131:                              ;   in Loop: Header=BB14_130 Depth=2
	ld	hl, (ix - 97)
	push	hl
	ld	hl, 1
	push	hl
	push	iy
	ld	(ix - 100), de
	ld	(ix - 118), iy
	call	_memset
	ld	iy, (ix - 118)
	ld	de, (ix - 100)
	pop	hl
	pop	hl
	pop	hl
	lea	iy, iy + 32
	dec	de
	jr	.LBB14_130
	.local	.LBB14_132
.LBB14_132:                             ;   in Loop: Header=BB14_80 Depth=1
	or	a, a
	sbc	hl, hl
	push	hl
	ld	l, (ix - 94)                    ; 1-byte Folded Reload
	push	hl
	ld	hl, (ix - 115)
	push	hl
	ld	hl, _render_layers+1318
	push	hl
	call	_collect_room_polygons
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	a, (_render_layers+2623)
	ld	(ix - 97), a                    ; 1-byte Folded Spill
	ld	a, (_render_layers+2628)
	ld	e, a
	ld	hl, 1
	ld	c, e
	call	__ishl
	ld	(ix - 118), hl
	ld	bc, 255
	call	__iand
	push	hl
	pop	iy
	call	__ishru_1
	ld	(ix - 94), hl
	ld	a, (_active_render_width)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 100), e                   ; 1-byte Folded Spill
	ld	c, e
	call	__ishru
	dec	l
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	hl, (ix - 94)
	call	__inot
	push	hl
	pop	bc
	add	iy, bc
	ld	de, -136
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	a, (_render_layers+2634)
	ld	de, -145
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	ld	hl, _render_layers+2632
	ld	hl, (hl)
	ld	de, -151
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	a, (_active_horizon_near_limit)
	ld	l, a
	inc	d
	ld	h, d
	ld	bc, -153
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	a, (_active_horizon_far_limit)
	ld	l, a
	ld	bc, -148
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), e
	ld	(iy + 1), d
	ld	h, d
	ld	de, -155
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), l
	ld	(iy + 1), h
	ld	hl, (ix - 118)
	ld	(ix - 118), l                   ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, (ix - 97)                    ; 1-byte Folded Reload
	ld	bc, 0
	.local	.LBB14_133
.LBB14_133:                             ;   Parent Loop BB14_80 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB14_135 Depth 3
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jp	z, .LBB14_152
; %bb.134:                              ;   in Loop: Header=BB14_133 Depth=2
	ld	(ix - 127), de
	ld	de, -130
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
	ld	(ix - 97), iy
	inc	de
	add	iy, de
	.local	.LBB14_135
.LBB14_135:                             ;   Parent Loop BB14_80 Depth=1
                                        ;     Parent Loop BB14_133 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld	a, (iy)
	cp	a, c
	jp	c, .LBB14_151
; %bb.136:                              ;   in Loop: Header=BB14_135 Depth=3
	ld	de, -133
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	iy, (ix - 97)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), de
	pop	ix
	add	iy, de
	ld	d, (iy + 48)
	ld	e, (iy + 96)
	ld	a, e
	cp	a, d
	jp	c, .LBB14_150
; %bb.137:                              ;   in Loop: Header=BB14_135 Depth=3
	ld	a, e
	ld	hl, (ix - 94)
	cp	a, l
	jp	c, .LBB14_150
; %bb.138:                              ;   in Loop: Header=BB14_135 Depth=3
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 31
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	ld	bc, 0
	ld	c, d
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 8
	ld	hl, (iy + 0)
	add	hl, bc
	ld	c, (ix - 100)                   ; 1-byte Folded Reload
	call	__ishru
	ld	bc, 255
	call	__iand
	ld	bc, -158
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	hl, (ix - 94)
	ld	a, l
	cp	a, d
	jr	c, .LBB14_140
; %bb.139:                              ;   in Loop: Header=BB14_135 Depth=3
	or	a, a
	sbc	hl, hl
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	.local	.LBB14_140
.LBB14_140:                             ;   in Loop: Header=BB14_135 Depth=3
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	de, (ix - 94)
	sbc	hl, de
	ld	c, (ix - 100)                   ; 1-byte Folded Reload
	call	__ishrs
	ld	bc, -139
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	ld	a, e
	cp	a, l
	jr	c, .LBB14_142
; %bb.141:                              ;   in Loop: Header=BB14_135 Depth=3
	ld	a, l
	.local	.LBB14_142
.LBB14_142:                             ;   in Loop: Header=BB14_135 Depth=3
	ld	bc, -158
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	cp	a, e
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 31
	ld	c, (iy + 0)                     ; 1-byte Folded Reload
	jp	c, .LBB14_150
; %bb.143:                              ;   in Loop: Header=BB14_135 Depth=3
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, -162
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, -142
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	ld	c, (ix - 100)                   ; 1-byte Folded Reload
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
	ld	hl, (ix - 97)
	ld	bc, 148
	add	hl, bc
	ld	a, (hl)
	ld	bc, 0
	ld	c, a
	ld	hl, _face_light_level
	add	hl, bc
	ld	e, (hl)
	cp	a, 2
	jp	nc, .LBB14_149
; %bb.144:                              ;   in Loop: Header=BB14_135 Depth=3
	ld	bc, -145
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)                         ; 1-byte Folded Reload
	or	a, a
	jp	z, .LBB14_149
; %bb.145:                              ;   in Loop: Header=BB14_135 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 20)
	ld	h, (ix - 19)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 31)                    ; 1-byte Folded Reload
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), l
	ld	(ix - 19), h
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 23)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), l
	ld	(ix - 13), h
	pop	ix
	add.sis	hl, hl
	sbc.sis	hl, hl
	ld	c, l
	ld	b, h
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 14)
	ld	h, (ix - 13)
	pop	ix
	add.sis	hl, bc
	call	__sxor
	push	ix
	lea	ix, ix - 128
	ld	(ix - 14), l
	ld	(ix - 13), h
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 25)
	ld	b, (ix - 24)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
	jr	nc, .LBB14_147
; %bb.146:                              ;   in Loop: Header=BB14_135 Depth=3
	ld	l, -2
	jp	.LBB14_148
	.local	.LBB14_147
.LBB14_147:                             ;   in Loop: Header=BB14_135 Depth=3
	push	ix
	lea	ix, ix - 128
	ld	l, (ix - 14)
	ld	h, (ix - 13)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	c, (ix - 27)
	ld	b, (ix - 26)
	pop	ix
	or	a, a
	sbc.sis	hl, bc
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	.local	.LBB14_148
.LBB14_148:                             ;   in Loop: Header=BB14_135 Depth=3
	ld	a, e
	add	a, l
	ld	e, a
	.local	.LBB14_149
.LBB14_149:                             ;   in Loop: Header=BB14_135 Depth=3
	ld	hl, (ix - 97)
	ld	bc, 145
	add	hl, bc
	ld	a, (hl)
	add	a, e
	ld	c, a
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 34)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 30)
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
	ld	de, -159
	lea	iy, ix + 0
	add	iy, de
	ld	c, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB14_150
.LBB14_150:                             ;   in Loop: Header=BB14_135 Depth=3
	ld	l, (ix - 118)
	ld	a, c
	add	a, l
	ld	c, a
	ld	de, -133
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	jp	.LBB14_135
	.local	.LBB14_151
.LBB14_151:                             ;   in Loop: Header=BB14_133 Depth=2
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	inc	bc
	ld	de, (ix - 127)
	jp	.LBB14_133
	.local	.LBB14_152
.LBB14_152:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	a, (_render_layers+2624)
	ld	c, a
	ld	a, (_render_layers+2625)
	ld	l, c
	ld	(ix - 97), a
	.local	.LBB14_153
.LBB14_153:                             ;   Parent Loop BB14_80 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB14_157 Depth 3
	cp	a, l
	jp	c, .LBB14_159
; %bb.154:                              ;   in Loop: Header=BB14_153 Depth=2
	ld	(ix - 94), bc
	ld	iy, 0
	ld	(ix - 118), l                   ; 1-byte Folded Spill
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	lea	hl, iy + 0
	ld	c, (ix - 100)                   ; 1-byte Folded Reload
	call	__ishru
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	(ix - 127), hl
	lea	de, iy + 0
	ld	hl, _render_layers+2526
	add	hl, de
	ld	b, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	a, (hl)
	cp	a, b
	jr	nc, .LBB14_156
	.local	.LBB14_155
.LBB14_155:                             ; %.loopexit
                                        ;   in Loop: Header=BB14_153 Depth=2
	ld	l, (ix - 118)                   ; 1-byte Folded Reload
	inc	l
	ld	bc, (ix - 94)
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	jr	.LBB14_153
	.local	.LBB14_156
.LBB14_156:                             ;   in Loop: Header=BB14_153 Depth=2
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _low_row_offsets
	add	hl, de
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	.local	.LBB14_157
.LBB14_157:                             ;   Parent Loop BB14_80 Depth=1
                                        ;     Parent Loop BB14_153 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	cp	a, b
	jr	c, .LBB14_155
; %bb.158:                              ;   in Loop: Header=BB14_157 Depth=3
	or	a, a
	sbc	hl, hl
	ld	l, b
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	c, (ix - 100)                   ; 1-byte Folded Reload
	call	__ishru
	ld	de, (ix - 127)
	add	hl, de
	ex	de, hl
	ld	hl, _portal_lod_frame
	add	hl, de
	ld	c, (hl)
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	iy, (hl)
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
	ld	de, (iy + 0)
	add	hl, de
	ex	de, hl
	ld	hl, _low_frame+2
	add	hl, de
	ld	(hl), c
	inc	b
	jr	.LBB14_157
	.local	.LBB14_159
.LBB14_159:                             ;   in Loop: Header=BB14_80 Depth=1
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	.local	.LBB14_160
.LBB14_160:                             ; %.loopexit68
                                        ;   in Loop: Header=BB14_80 Depth=1
	ld	de, 145
	ld	hl, (ix - 88)
	add	hl, de
	ld	l, (hl)
	ld	(ix - 94), bc
	ld	e, c
	ld	iy, 0
	ld	(ix - 97), a
	.local	.LBB14_161
.LBB14_161:                             ;   Parent Loop BB14_80 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	c, l
	cp	a, e
	jr	c, .LBB14_165
; %bb.162:                              ;   in Loop: Header=BB14_161 Depth=2
	ld	(ix - 88), e                    ; 1-byte Folded Spill
	ld	iyl, e
	lea	de, iy + 0
	ld	hl, _render_layers+2526
	add	hl, de
	ld	b, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	a, (hl)
	ld	(ix - 100), b                   ; 1-byte Folded Spill
	cp	a, b
	jr	c, .LBB14_164
; %bb.163:                              ;   in Loop: Header=BB14_161 Depth=2
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	(ix - 118), hl
	ld	de, 0
	ld	e, (ix - 100)                   ; 1-byte Folded Reload
	ld	(ix - 100), de
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
	ld	de, (ix - 100)
	add	hl, de
	ex	de, hl
	ld	hl, _low_frame+2
	add	hl, de
	ld	a, c
	ld	(hl), a
	ld	de, (ix - 118)
	add	iy, de
	lea	de, iy + 0
	ld	hl, _low_frame+2
	add	hl, de
	ld	(hl), a
	.local	.LBB14_164
.LBB14_164:                             ;   in Loop: Header=BB14_161 Depth=2
	ld	e, (ix - 88)                    ; 1-byte Folded Reload
	inc	e
	ld	iy, 0
	ld	a, (ix - 97)                    ; 1-byte Folded Reload
	ld	l, c
	jr	.LBB14_161
	.local	.LBB14_165
.LBB14_165:                             ;   in Loop: Header=BB14_80 Depth=1
	lea	de, iy + 0
	ld	hl, (ix - 94)
	ld	e, l
	ld	hl, _render_layers+2526
	add	hl, de
	ld	a, (hl)
	ld	hl, _render_layers+2574
	add	hl, de
	ld	l, (hl)
	ld	(ix - 88), c                    ; 1-byte Folded Spill
	ld	e, c
	push	de
	lea	de, iy + 0
	ld	e, l
	push	de
	ld	iyl, a
	push	iy
	ld	hl, (ix - 94)
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
	ld	bc, (ix - 91)
	jr	z, .LBB14_167
; %bb.166:                              ;   in Loop: Header=BB14_80 Depth=1
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
	ld	c, (ix - 88)                    ; 1-byte Folded Reload
	push	bc
	ld	e, l
	push	de
	ld	e, a
	push	de
	push	iy
	call	_write_frame_span
	ld	bc, (ix - 91)
	ld	iy, 0
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB14_167
.LBB14_167:                             ;   in Loop: Header=BB14_80 Depth=1
	inc	bc
	jp	.LBB14_80
	.local	.LBB14_168
.LBB14_168:                             ; %.loopexit69
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB14_169
.LBB14_169:
	push	bc
	pop	hl
	add	hl, de
	ld	a, (hl)
	push	bc
	pop	hl
	ld	e, a
	ld	(ix - 88), de
	ld	iy, 0
	lea	bc, iy + 0
	.local	.LBB14_170
.LBB14_170:                             ; =>This Inner Loop Header: Depth=1
	push	hl
	pop	iy
	ld	de, 1307
	add	hl, de
	ld	a, (hl)
	ld	hl, (ix - 88)
	cp	a, l
	jp	c, .LBB14_4
; %bb.171:                              ;   in Loop: Header=BB14_170 Depth=1
	push	bc
	pop	de
	ld	hl, (ix - 88)
	ld	e, l
	add	iy, de
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
	lea	bc, iy + 0
	ld	hl, (ix - 85)
	jr	.LBB14_170
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_render_camera, .Lfunc_end14-_render_camera
                                        ; -- End function
	.section	.text._collect_room_polygons,"ax",@progbits
	.type	_collect_room_polygons,@function ; -- Begin function collect_room_polygons
_collect_room_polygons:                 ; @collect_room_polygons
; %bb.0:
	ld	hl, -170
	call	__frameset
	ld	hl, _rooms
	ld	(ix - 109), hl
	lea	hl, ix - 42
	ld	de, -136
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	lea	hl, ix - 51
	ld	(ix - 124), hl
	lea	hl, ix - 63
	ld	de, -169
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
	ld	hl, (ix - 109)
	add	hl, de
	ld	(ix - 109), hl
	ld	(ix - 63), b
	ld	de, -169
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
	ld	(ix - 38), hl
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
	jp	nc, .LBB15_7
; %bb.1:
	ld	iy, (iy + 24)
	ld	(ix - 103), iy
	ld	a, (ix - 101)
	rlc	a
	sbc	a, a
	ld	de, -133
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
	ld	bc, -130
	lea	hl, ix + 0
	push	af
	add	hl, bc
	pop	af
	ld	(hl), iy
	jp	c, .LBB15_8
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
	jp	m, .LBB15_4
; %bb.3:
	push	de
	pop	iy
	.local	.LBB15_4
.LBB15_4:
	ld	(ix - 112), iy
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
	ld	bc, (ix - 112)
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
	jr	z, .LBB15_6
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
	.local	.LBB15_6
.LBB15_6:
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
	jr	.LBB15_8
	.local	.LBB15_7
.LBB15_7:
	ld	hl, (ix + 6)
	add	hl, de
	ld	(hl), 0
	ld	hl, (iy + 24)
	ld	de, -130
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	(ix - 106), hl
	ld	a, (ix - 104)
	rlc	a
	sbc	a, a
	ld	de, -133
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), a                     ; 1-byte Folded Spill
	.local	.LBB15_8
.LBB15_8:
	ld	iy, (ix - 109)
	ld	bc, (iy + 1)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	(ix - 42), de
	ld	bc, (iy + 5)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 112), hl
	ld	(ix - 39), hl
	ld	bc, (iy + 9)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	(ix - 36), hl
	push	hl
	pop	bc
	ld	iy, (ix - 109)
	ld	iy, (iy + 3)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc	hl, de
	ld	(ix - 115), hl
	ld	iy, (ix - 109)
	ld	de, (iy + 7)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 112)
	or	a, a
	sbc	hl, de
	ld	(ix - 112), hl
	ld	de, (iy + 11)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	or	a, a
	sbc	hl, bc
	ld	(ix - 121), hl
	push	hl
	push	hl
	push	hl
	ex	de, hl
	ld	hl, 0
	add	hl, sp
	ex	de, hl
	ld	bc, -136
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
	lea	iy, iy - 26
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
	ld	de, -160
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 12)
	ld	bc, (ix - 112)
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
	lea	iy, iy - 8
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 21)
	ld	(ix - 78), hl
	ld	a, (ix - 76)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 112)
	ld	a, d
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 8
	call	__lshru
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 20
	ld	(iy + 0), bc
	ld	iy, (ix + 9)
	ld	hl, (iy + 30)
	ld	(ix - 75), hl
	ld	a, (ix - 73)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 112)
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
	ld	de, -151
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
	lea	iy, iy - 2
	ld	bc, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 5
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
	ld	bc, 0
	ld	e, a
	ld	c, e
	ld	a, e
	add	a, l
	ld	l, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 42
	ld	(iy + 0), l
	ld	a, e
	push	bc
	pop	hl
	push	bc
	pop	iy
	push	ix
	lea	ix, ix - 128
	ld	(ix - 17), iy
	pop	ix
	ld	bc, 9
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
	ld	(ix - 112), iy
	ld	iy, (ix - 51)
	ld	de, -163
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	hl, (ix - 48)
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
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
	push	ix
	lea	ix, ix - 128
	ld	(ix - 29), iy
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 26)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	(ix - 127), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 32)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 5), hl
	pop	ix
	ld	hl, (ix - 112)
	ld	(hl), iy
	push	hl
	pop	iy
	ld	(iy + 3), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	ld	(iy + 6), hl
	ld	de, -145
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	(ix - 112), hl
	ld	de, 3
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 35)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 8)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 32), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 20)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	de, -139
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 23)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 26), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 32)
	pop	ix
	ld	(iy), hl
	ld	(iy + 3), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 26)
	pop	ix
	ld	(iy + 6), hl
	ld	hl, (ix - 112)
	ld	de, 2
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
	ld	de, (ix - 8)
	pop	ix
	add	hl, de
	ld	(ix - 124), hl
	ld	hl, (ix - 127)
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 20)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	de, -136
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 23)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 20), hl
	pop	ix
	ld	hl, (ix - 124)
	ld	(iy), hl
	ld	(iy + 3), bc
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 20)
	pop	ix
	ld	(iy + 6), hl
	ld	hl, (ix - 112)
	ld	de, 4
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 35)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	de, (ix - 118)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 2)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 2), hl
	pop	ix
	ld	de, (ix - 121)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 14)
	pop	ix
	add	hl, de
	ld	(iy), bc
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 2)
	pop	ix
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	hl, (ix - 112)
	ld	de, 5
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 29)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	de, (ix - 118)
	ld	hl, (ix - 127)
	add	hl, de
	ld	(ix - 127), hl
	ld	de, (ix - 121)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 5)
	pop	ix
	add	hl, de
	ld	(iy), bc
	ld	de, (ix - 127)
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	hl, (ix - 112)
	ld	de, 7
	add	hl, de
	ld	bc, 9
	call	__imulu
	ex	de, hl
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 32)
	pop	ix
	add	hl, de
	push	hl
	pop	bc
	ld	de, (ix - 118)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 11)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 11), hl
	pop	ix
	ld	de, (ix - 121)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 26)
	pop	ix
	add	hl, de
	ld	(iy), bc
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 11)
	pop	ix
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	de, 6
	ld	hl, (ix - 112)
	add	hl, de
	ld	bc, 9
	call	__imulu
	ld	c, a
	ex	de, hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 42
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	ld	iy, _camera_vertices
	add	iy, de
	ld	de, (ix - 115)
	ld	hl, (ix - 124)
	add	hl, de
	ld	(ix - 124), hl
	ld	de, (ix - 118)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 8)
	pop	ix
	add	hl, de
	push	ix
	lea	ix, ix - 128
	ld	(ix - 8), hl
	pop	ix
	ld	de, (ix - 121)
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 20)
	pop	ix
	add	hl, de
	ld	de, (ix - 124)
	ld	(iy), de
	push	ix
	lea	ix, ix - 128
	ld	de, (ix - 8)
	pop	ix
	ld	(iy + 3), de
	ld	(iy + 6), hl
	ld	b, c
	cp	a, c
	jr	c, .LBB15_10
; %bb.9:
	ld	b, a
	.local	.LBB15_10
.LBB15_10:
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
	ld	iyl, b
	ld	bc, -145
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
	.local	.LBB15_11
.LBB15_11:                              ; =>This Inner Loop Header: Depth=1
	ld	(ix - 112), hl
	ld	hl, (ix - 112)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB15_17
; %bb.12:                               ;   in Loop: Header=BB15_11 Depth=1
	ld	iy, (ix - 115)
	ld	de, (iy + 6)
	push	de
	pop	hl
	ld	bc, 32
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	a, 1
	jp	p, .LBB15_14
; %bb.13:                               ;   in Loop: Header=BB15_11 Depth=1
	ld	a, 0
	.local	.LBB15_14
.LBB15_14:                              ;   in Loop: Header=BB15_11 Depth=1
	ld	hl, (ix - 118)
	ld	(hl), a
	ex	de, hl
	ld	de, 32
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB15_16
; %bb.15:                               ;   in Loop: Header=BB15_11 Depth=1
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
	.local	.LBB15_16
.LBB15_16:                              ;   in Loop: Header=BB15_11 Depth=1
	ld	iy, (ix - 115)
	lea	iy, iy + 9
	ld	(ix - 115), iy
	ld	hl, (ix - 118)
	inc	hl
	ld	(ix - 118), hl
	ld	iy, (ix - 121)
	lea	iy, iy + 6
	ld	(ix - 121), iy
	ld	hl, (ix - 112)
	dec	hl
	jr	.LBB15_11
	.local	.LBB15_17
.LBB15_17:
	xor	a, a
	ld	(ix - 112), a                   ; 1-byte Folded Spill
	ld	de, 0
	ld	bc, 6
	.local	.LBB15_18
.LBB15_18:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB15_22 Depth 2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB15_37
; %bb.19:                               ;   in Loop: Header=BB15_18 Depth=1
	ld	hl, (ix - 109)
	ld	a, (hl)
	ld	(ix - 115), a                   ; 1-byte Folded Spill
	add	a, e
	ld	h, a
	ld	l, (ix + 12)
	cp	a, l
	jp	z, .LBB15_36
; %bb.20:                               ;   in Loop: Header=BB15_18 Depth=1
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
	ld	de, -166
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	a, (hl)
	cp	a, 8
	ld	l, 0
	ld	c, l
	jp	nc, .LBB15_35
; %bb.21:                               ;   in Loop: Header=BB15_18 Depth=1
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
	ld	l, (ix - 112)
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
	.local	.LBB15_22
.LBB15_22:                              ;   Parent Loop BB15_18 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	hl
	pop	bc
	ld	de, 36
	or	a, a
	sbc	hl, de
	jp	z, .LBB15_27
; %bb.23:                               ;   in Loop: Header=BB15_22 Depth=2
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
	jr	nz, .LBB15_25
; %bb.24:                               ;   in Loop: Header=BB15_22 Depth=2
	ld	de, 6
	jr	.LBB15_26
	.local	.LBB15_25
.LBB15_25:                              ;   in Loop: Header=BB15_22 Depth=2
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
	lea	de, iy + 0
	inc	(ix - 127)
	.local	.LBB15_26
.LBB15_26:                              ;   in Loop: Header=BB15_22 Depth=2
	ld	hl, (ix - 115)
	inc	hl
	ld	(ix - 115), hl
	ld	bc, -142
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	bc, 9
	add	iy, bc
	ld	hl, (ix - 121)
	add	hl, de
	ld	(ix - 121), hl
	lea	hl, iy + 0
	push	af
	ld	a, (ix - 127)                   ; 1-byte Folded Reload
	ld	iyl, a
	pop	af
	jp	.LBB15_22
	.local	.LBB15_27
.LBB15_27:                              ;   in Loop: Header=BB15_18 Depth=1
	ld	a, iyl
	or	a, a
	ld	de, -133
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	ld	bc, (hl)
	jr	nz, .LBB15_29
; %bb.28:                               ;   in Loop: Header=BB15_18 Depth=1
	ld	c, iyl
	jp	.LBB15_35
	.local	.LBB15_29
.LBB15_29:                              ;   in Loop: Header=BB15_18 Depth=1
	ld	a, iyl
	cp	a, 4
	jr	nz, .LBB15_31
; %bb.30:                               ;   in Loop: Header=BB15_18 Depth=1
	push	bc
	pop	hl
	ld	de, 144
	add	hl, de
	ld	(hl), 4
	jr	.LBB15_32
	.local	.LBB15_31
.LBB15_31:                              ;   in Loop: Header=BB15_18 Depth=1
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
	jp	z, .LBB15_35
	.local	.LBB15_32
.LBB15_32:                              ;   in Loop: Header=BB15_18 Depth=1
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
	jr	z, .LBB15_35
; %bb.33:                               ;   in Loop: Header=BB15_18 Depth=1
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
	jr	z, .LBB15_35
; %bb.34:                               ;   in Loop: Header=BB15_18 Depth=1
	ld	de, -166
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	(hl)
	ld	a, 1
	ld	c, a
	.local	.LBB15_35
.LBB15_35:                              ;   in Loop: Header=BB15_18 Depth=1
	ld	de, -169
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	de, (ix - 118)
	add	hl, de
	ld	(hl), c
	ld	bc, 6
	.local	.LBB15_36
.LBB15_36:                              ;   in Loop: Header=BB15_18 Depth=1
	inc	de
	inc	(ix - 112)
	jp	.LBB15_18
	.local	.LBB15_37
.LBB15_37:
	ld	de, -166
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
	jr	nz, .LBB15_39
	.local	.LBB15_38
.LBB15_38:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB15_39
.LBB15_39:                              ; =>This Inner Loop Header: Depth=1
	ld	de, 92
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, .LBB15_38
; %bb.40:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	hl, _portals
	push	hl
	pop	iy
	add	iy, bc
	ld	(ix - 112), iy
	ld	a, (iy + 45)
	or	a, a
	jp	z, .LBB15_54
; %bb.41:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	iy, (ix - 112)
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
	jp	z, .LBB15_54
; %bb.42:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	l, (iy + 36)
	lea	de, iy + 0
	ld	iy, (ix - 112)
	ld	a, (iy + 42)
	cp	a, l
	jp	nz, .LBB15_54
; %bb.43:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	iy, (ix - 112)
	ld	a, (iy + 43)
	push	de
	pop	iy
	ld	hl, (ix - 109)
	ld	l, (hl)
	cp	a, l
	jp	c, .LBB15_54
; %bb.44:                               ;   in Loop: Header=BB15_39 Depth=1
	sub	a, l
	ld	l, a
	cp	a, 6
	jp	nc, .LBB15_54
; %bb.45:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	de, 0
	ld	e, l
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 41)
	pop	ix
	add	hl, de
	ld	a, (hl)
	or	a, a
	jp	z, .LBB15_54
; %bb.46:                               ;   in Loop: Header=BB15_39 Depth=1
	push	ix
	lea	ix, ix - 128
	ld	hl, (ix - 38)
	pop	ix
	ld	a, (hl)
	cp	a, 8
	jp	nc, .LBB15_53
; %bb.47:                               ;   in Loop: Header=BB15_39 Depth=1
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
	ld	hl, (ix - 112)
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
	ld	(ix - 32), hl
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
	ld	de, -163
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
	ld	bc, (ix - 32)
	pop	ix
	ld	(ix - 42), bc
	push	ix
	lea	ix, ix - 128
	ld	bc, (ix - 35)
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
	jr	z, .LBB15_53
; %bb.48:                               ;   in Loop: Header=BB15_39 Depth=1
	push	de
	ld	hl, (ix - 118)
	push	hl
	call	_polygon_intersects_layer
	pop	hl
	pop	hl
	or	a, a
	jr	z, .LBB15_53
; %bb.49:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	bc, (ix - 118)
	ld	hl, (ix - 115)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 1
	jr	z, .LBB15_51
; %bb.50:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	a, 0
	.local	.LBB15_51
.LBB15_51:                              ;   in Loop: Header=BB15_39 Depth=1
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
	ld	iy, (ix - 112)
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
	jr	z, .LBB15_53
; %bb.52:                               ;   in Loop: Header=BB15_39 Depth=1
	ld	de, -166
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	(hl)
	.local	.LBB15_53
.LBB15_53:                              ;   in Loop: Header=BB15_39 Depth=1
	ld	bc, (ix - 115)
	.local	.LBB15_54
.LBB15_54:                              ;   in Loop: Header=BB15_39 Depth=1
	push	bc
	pop	hl
	ld	de, 46
	add	hl, de
	inc	(ix - 124)
	push	hl
	pop	bc
	jp	.LBB15_39
	.local	.Lfunc_end15
.Lfunc_end15:
	.size	_collect_room_polygons, .Lfunc_end15-_collect_room_polygons
                                        ; -- End function
	.section	.text._write_frame_span,"ax",@progbits
	.type	_write_frame_span,@function     ; -- Begin function write_frame_span
_write_frame_span:                      ; @write_frame_span
; %bb.0:
	call	__frameset0
	ld	de, (ix + 9)
	ld	iy, (ix + 12)
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB16_2
; %bb.1:
	ld	a, (ix + 6)
	ld	bc, 0
	ld	c, e
	ld	b, d
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, de
	inc.sis	hl
	ld	iy, 0
	ld	iyl, a
	add	iy, iy
	lea	de, iy + 0
	ld	iy, _low_row_offsets
	add	iy, de
	ld	de, (iy)
	ld	iy, 0
	ld	iyl, e
	ld	iyh, d
	add	iy, bc
	lea	de, iy + 0
	ld	iy, _low_frame+2
	add	iy, de
	ld	de, 0
	ld	e, l
	ld	d, h
	push	de
	ld	l, (ix + 15)
	push	hl
	push	iy
	call	_memset
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB16_2
.LBB16_2:
	pop	ix
	ret
	.local	.Lfunc_end16
.Lfunc_end16:
	.size	_write_frame_span, .Lfunc_end16-_write_frame_span
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
	jp	m, .LBB17_4
; %bb.1:
	ld	c, 5
	ex	de, hl
	call	__ishru
	push	hl
	pop	iy
	ld	de, 2047
	or	a, a
	sbc	hl, de
	jr	c, .LBB17_3
; %bb.2:
	ld	iy, 2047
	.local	.LBB17_3
.LBB17_3:
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _far_projection_scale_table
	jr	.LBB17_9
	.local	.LBB17_4
.LBB17_4:
	ld	c, 2
	push	de
	pop	hl
	call	__ishru
	push	hl
	pop	iy
	ld	bc, 2047
	or	a, a
	sbc	hl, bc
	jr	c, .LBB17_6
; %bb.5:
	ld	iy, 2047
	.local	.LBB17_6
.LBB17_6:
	ld	bc, 4
	ex	de, hl
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB17_8
; %bb.7:
	ld	iy, 1
	.local	.LBB17_8
.LBB17_8:
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _projection_scale_table
	.local	.LBB17_9
.LBB17_9:
	add	hl, de
	ld	hl, (hl)
                                        ; kill: def $hl killed $hl killed $uhl
	pop	ix
	ret
	.local	.Lfunc_end17
.Lfunc_end17:
	.size	_projection_scale_for_depth, .Lfunc_end17-_projection_scale_for_depth
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
	.local	.Lfunc_end18
.Lfunc_end18:
	.size	_half_projected, .Lfunc_end18-_half_projected
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
	.local	.Lfunc_end19
.Lfunc_end19:
	.size	_transform_point, .Lfunc_end19-_transform_point
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
	jp	m, .LBB20_2
; %bb.1:
	ld	a, 0
	jr	.LBB20_3
	.local	.LBB20_2
.LBB20_2:
	ld	a, 1
	.local	.LBB20_3
.LBB20_3:
	bit	0, a
	jr	nz, .LBB20_5
; %bb.4:
	ld	iy, 1040384
	.local	.LBB20_5
.LBB20_5:
	ld	hl, -1056768
	ld	e, -1
	bit	0, a
	jr	nz, .LBB20_7
; %bb.6:
	ld	d, 0
	.local	.LBB20_7
.LBB20_7:
	lea	bc, iy + 0
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB20_9
; %bb.8:
	push	hl
	pop	iy
	.local	.LBB20_9
.LBB20_9:
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
	jp	m, .LBB20_11
; %bb.10:
	ld	a, 0
	jr	.LBB20_12
	.local	.LBB20_11
.LBB20_11:
	ld	a, 1
	.local	.LBB20_12
.LBB20_12:
	ld	e, -1
	bit	0, a
	jr	nz, .LBB20_14
; %bb.13:
	ld	iy, 1048576
	.local	.LBB20_14
.LBB20_14:
	ld	hl, -1048576
	bit	0, a
	jr	nz, .LBB20_16
; %bb.15:
	ld	d, 0
	.local	.LBB20_16
.LBB20_16:
	ld	(ix - 13), iy
	lea	bc, iy + 0
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB20_18
; %bb.17:
	ld	(ix - 13), hl
	.local	.LBB20_18
.LBB20_18:
	ld	a, (_active_render_shift)
	or	a, a
	jr	nz, .LBB20_20
; %bb.19:
	ld	bc, (ix - 10)
	ld	hl, (ix - 13)
	jr	.LBB20_21
	.local	.LBB20_20
.LBB20_20:
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
	.local	.LBB20_21
.LBB20_21:
	ld	iy, (ix + 6)
	ld	(iy), bc
	ld	(iy + 3), hl
	lea	hl, iy + 0
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end20
.Lfunc_end20:
	.size	_project_camera_point, .Lfunc_end20-_project_camera_point
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
	.local	.LBB21_1
.LBB21_1:                               ; =>This Inner Loop Header: Depth=1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB21_21
; %bb.2:                                ;   in Loop: Header=BB21_1 Depth=1
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
	jr	z, .LBB21_4
; %bb.3:                                ;   in Loop: Header=BB21_1 Depth=1
	ex	de, hl
	dec	hl
	.local	.LBB21_4
.LBB21_4:                               ;   in Loop: Header=BB21_1 Depth=1
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
	jp	p, .LBB21_6
; %bb.5:                                ;   in Loop: Header=BB21_1 Depth=1
	ld	a, 0
	.local	.LBB21_6
.LBB21_6:                               ;   in Loop: Header=BB21_1 Depth=1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	l, -1
	jp	m, .LBB21_8
; %bb.7:                                ;   in Loop: Header=BB21_1 Depth=1
	ld	l, 0
	.local	.LBB21_8
.LBB21_8:                               ;   in Loop: Header=BB21_1 Depth=1
	xor	a, l
	ld	l, a
	bit	0, l
	jp	nz, .LBB21_14
; %bb.9:                                ;   in Loop: Header=BB21_1 Depth=1
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
	jp	p, .LBB21_11
; %bb.10:                               ;   in Loop: Header=BB21_1 Depth=1
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
	jr	.LBB21_12
	.local	.LBB21_11
.LBB21_11:                              ;   in Loop: Header=BB21_1 Depth=1
	ld	(ix - 49), de
	ld	de, (ix - 68)
	ld	(ix - 58), de
	ld	(ix - 74), iy
	ld	de, (ix - 65)
	ld	(ix - 77), de
	ld	bc, (ix - 52)
	ld	e, (ix - 71)                    ; 1-byte Folded Reload
	.local	.LBB21_12
.LBB21_12:                              ;   in Loop: Header=BB21_1 Depth=1
	push	af
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, iyh
	cp	a, 8
	jp	nc, .LBB21_18
; %bb.13:                               ;   in Loop: Header=BB21_1 Depth=1
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
	.local	.LBB21_14
.LBB21_14:                              ;   in Loop: Header=BB21_1 Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	iyl, 0
	ld	hl, (ix - 33)
	jp	m, .LBB21_17
; %bb.15:                               ;   in Loop: Header=BB21_1 Depth=1
	push	af
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	ld	a, iyh
	cp	a, 8
	jr	nc, .LBB21_20
; %bb.16:                               ;   in Loop: Header=BB21_1 Depth=1
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
	jr	.LBB21_19
	.local	.LBB21_17
.LBB21_17:                              ;   in Loop: Header=BB21_1 Depth=1
	push	af
	ld	a, (ix - 34)                    ; 1-byte Folded Reload
	ld	iyh, a
	pop	af
	jr	.LBB21_20
	.local	.LBB21_18
.LBB21_18:                              ;   in Loop: Header=BB21_1 Depth=1
	ld	iyl, 0
	.local	.LBB21_19
.LBB21_19:                              ;   in Loop: Header=BB21_1 Depth=1
	ld	hl, (ix - 33)
	.local	.LBB21_20
.LBB21_20:                              ;   in Loop: Header=BB21_1 Depth=1
	inc	hl
	ld	(ix - 33), hl
	ld	hl, (ix - 46)
	ld	bc, 9
	add	hl, bc
	ex	de, hl
	ld	bc, 36
	jp	.LBB21_1
	.local	.LBB21_21
.LBB21_21:
	ld	a, iyh
	cp	a, 3
	jr	c, .LBB21_26
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
	.local	.LBB21_23
.LBB21_23:                              ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB21_25
; %bb.24:                               ;   in Loop: Header=BB21_23 Depth=1
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
	jr	.LBB21_23
	.local	.LBB21_25
.LBB21_25:
	ld	de, 144
	ld	hl, (ix + 9)
	add	hl, de
	ld	a, (ix - 34)
	ld	(hl), a
	ld	iyl, 1
	.local	.LBB21_26
.LBB21_26:
	ld	a, iyl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end21
.Lfunc_end21:
	.size	_clip_and_project, .Lfunc_end21-_clip_and_project
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
	jr	nc, .LBB22_2
; %bb.1:
	ld	a, 1
	.local	.LBB22_2
.LBB22_2:
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
	.local	.LBB22_3
.LBB22_3:                               ; =>This Inner Loop Header: Depth=1
	sbc	hl, hl
	adc	hl, bc
	ld	(ix - 18), de
	jp	z, .LBB22_13
; %bb.4:                                ;   in Loop: Header=BB22_3 Depth=1
	ld	iy, (ix - 3)
	ld	iy, (iy - 3)
	lea	hl, iy + 0
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	(ix - 15), iy
	jp	m, .LBB22_6
; %bb.5:                                ;   in Loop: Header=BB22_3 Depth=1
	ld	iy, (ix - 9)
	.local	.LBB22_6
.LBB22_6:                               ;   in Loop: Header=BB22_3 Depth=1
	ld	(ix - 25), bc
	ld	(ix - 9), iy
	ld	iy, (ix - 12)
	lea	hl, iy + 0
	ld	de, (ix - 15)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB22_8
; %bb.7:                                ;   in Loop: Header=BB22_3 Depth=1
	ld	(ix - 15), iy
	.local	.LBB22_8
.LBB22_8:                               ;   in Loop: Header=BB22_3 Depth=1
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
	jp	m, .LBB22_10
; %bb.9:                                ;   in Loop: Header=BB22_3 Depth=1
	lea	hl, iy + 0
	.local	.LBB22_10
.LBB22_10:                              ;   in Loop: Header=BB22_3 Depth=1
	ld	(ix - 6), hl
	ld	iy, (ix - 18)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	bc, (ix - 25)
	jp	m, .LBB22_12
; %bb.11:                               ;   in Loop: Header=BB22_3 Depth=1
	lea	de, iy + 0
	.local	.LBB22_12
.LBB22_12:                              ;   in Loop: Header=BB22_3 Depth=1
	ld	iy, (ix - 3)
	lea	iy, iy + 6
	ld	(ix - 3), iy
	dec	bc
	ld	hl, (ix - 15)
	ld	(ix - 12), hl
	jp	.LBB22_3
	.local	.LBB22_13
.LBB22_13:
	ld	de, 1310
	ld	hl, (ix + 9)
	add	hl, de
	ld	c, (hl)
	ld	a, c
	or	a, a
	jr	nz, .LBB22_15
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
	jr	.LBB22_20
	.local	.LBB22_15
.LBB22_15:
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
	jr	c, .LBB22_17
; %bb.16:
	dec	l
	ex	de, hl
	ld	iyl, e
	ex	de, hl
	.local	.LBB22_17
.LBB22_17:
	ld	hl, (ix - 3)
	ld	c, l
	ld	a, (_active_render_height)
	ld	l, a
	ld	a, e
	cp	a, l
	jr	c, .LBB22_19
; %bb.18:
	dec	l
	ld	e, l
	.local	.LBB22_19
.LBB22_19:
	ld	a, b
	and	a, c
	ld	b, a
	ld	l, (ix - 21)                    ; 1-byte Folded Reload
	ld	a, l
	and	a, c
	ld	c, a
	ld	a, (ix - 19)                    ; 1-byte Folded Reload
	.local	.LBB22_20
.LBB22_20:
	cp	a, l
	jr	nc, .LBB22_22
; %bb.21:
	xor	a, a
	jr	.LBB22_27
	.local	.LBB22_22
.LBB22_22:
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
	jp	m, .LBB22_27
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
	jp	p, .LBB22_27
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
	jp	m, .LBB22_27
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
	jp	p, .LBB22_27
; %bb.26:
	ld	a, 1
	.local	.LBB22_27
.LBB22_27:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end22
.Lfunc_end22:
	.size	_polygon_intersects_layer, .Lfunc_end22-_polygon_intersects_layer
                                        ; -- End function
	.section	.text._rasterize_polygon,"ax",@progbits
	.type	_rasterize_polygon,@function    ; -- Begin function rasterize_polygon
_rasterize_polygon:                     ; @rasterize_polygon
; %bb.0:
	ld	hl, -83
	call	__frameset
	ld	de, (ix + 6)
	ld	bc, (ix + 9)
	ld	hl, 1310
	push	bc
	pop	iy
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 52), iy
	ld	c, (iy)
	ld	hl, 1
	ld	(ix - 37), c                    ; 1-byte Folded Spill
	call	__ishl
	ld	(ix - 34), hl
	ld	bc, 144
	push	de
	pop	iy
	add	iy, bc
	ld	a, (iy)
	cp	a, 2
	ld	(ix - 49), a                    ; 1-byte Folded Spill
	jr	nc, .LBB23_2
; %bb.1:
	ld	a, 1
	.local	.LBB23_2
.LBB23_2:
	ld	iy, (ix + 6)
	ld	bc, (iy + 3)
	ld	de, 0
	ld	e, a
	lea	hl, iy + 9
	ld	(ix - 28), hl
	dec	de
	ld	(ix - 25), bc
	.local	.LBB23_3
.LBB23_3:                               ; =>This Inner Loop Header: Depth=1
	ld	(ix - 31), bc
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB23_9
; %bb.4:                                ;   in Loop: Header=BB23_3 Depth=1
	ld	hl, (ix - 28)
	ld	iy, (hl)
	lea	hl, iy + 0
	ld	bc, (ix - 25)
	or	a, a
	sbc	hl, bc
	lea	bc, iy + 0
	call	pe, __setflag
	push	bc
	pop	hl
	jp	m, .LBB23_6
; %bb.5:                                ;   in Loop: Header=BB23_3 Depth=1
	ld	hl, (ix - 25)
	.local	.LBB23_6
.LBB23_6:                               ;   in Loop: Header=BB23_3 Depth=1
	ld	(ix - 25), hl
	ld	iy, (ix - 31)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_8
; %bb.7:                                ;   in Loop: Header=BB23_3 Depth=1
	lea	bc, iy + 0
	.local	.LBB23_8
.LBB23_8:                               ;   in Loop: Header=BB23_3 Depth=1
	ld	iy, (ix - 28)
	lea	iy, iy + 6
	ld	(ix - 28), iy
	dec	de
	jr	.LBB23_3
	.local	.LBB23_9
.LBB23_9:
	ld	hl, (ix - 34)
	ld	bc, 255
	call	__iand
	ld	(ix - 40), hl
	call	__ishru_1
	ld	(ix - 34), hl
	ld	bc, (ix - 25)
	push	bc
	pop	hl
	ld	de, 128
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB23_11
; %bb.10:
	push	bc
	pop	hl
	ld	de, 127
	add	hl, de
	ld	c, 8
	call	__ishru
	jp	.LBB23_12
	.local	.LBB23_11
.LBB23_11:
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	c, 8
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB23_12
.LBB23_12:
	ld	(ix - 43), hl
	ld	iy, (ix - 31)
	lea	hl, iy + 0
	ld	de, -129
	add	hl, de
	call	__ishru
	ld	(ix - 25), hl
	ld	hl, 384
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ld	(ix - 46), l
	ld	(ix - 45), h
	ld	bc, 129
	ex	de, hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_14
; %bb.13:
	ld	hl, (ix - 25)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 46), l
	ld	(ix - 45), h
	.local	.LBB23_14
.LBB23_14:
	ld	c, (ix - 37)                    ; 1-byte Folded Reload
	ld	a, c
	or	a, a
	ld	de, 1306
	jp	nz, .LBB23_19
; %bb.15:
	ld	bc, (ix - 43)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	(ix - 43), bc
	ld	l, c
	ld	h, b
	ld	iy, (ix + 9)
	add	iy, de
	ld	a, (iy)
	ld	iy, 0
	lea	de, iy + 0
	ld	e, a
	ld	b, iyh
	ld	c, a
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	(ix - 25), bc
                                        ; kill: def $bc killed $bc killed $ubc def $ubc
	ld	(ix - 28), bc
	jp	m, .LBB23_17
; %bb.16:
	ld	hl, (ix - 43)
                                        ; kill: def $hl killed $hl killed $uhl def $uhl
	ld	(ix - 28), hl
	.local	.LBB23_17
.LBB23_17:
	push	hl
	ld	l, (ix - 46)
	ld	h, (ix - 45)
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
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	de, (ix - 25)
	ld	e, a
	ld	(ix - 25), de
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_24
; %bb.18:
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	jp	.LBB23_23
	.local	.LBB23_19
.LBB23_19:
	ld	iy, (ix + 9)
	lea	hl, iy + 0
	add	hl, de
	ld	a, (hl)
	ld	iy, 0
	lea	hl, iy + 0
	ld	l, a
	call	__ishru
	ld	iy, (ix - 40)
	lea	bc, iy + 0
	call	__imulu
	ld	de, (ix - 34)
	add	hl, de
	ld	(ix - 28), hl
	ld	hl, (ix + 9)
	ld	bc, 1307
	add	hl, bc
	ld	a, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	c, (ix - 37)                    ; 1-byte Folded Reload
	call	__ishru
	lea	bc, iy + 0
	call	__imulu
	add	hl, de
	ld	(ix - 25), hl
	ld	de, (ix - 43)
	ld	a, d
	rlc	a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, (ix - 28)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_21
; %bb.20:
                                        ; kill: def $de killed $de killed $ude def $ude
	ld	(ix - 28), de
	.local	.LBB23_21
.LBB23_21:
	ld	e, (ix - 46)
	ld	d, (ix - 45)
	ld	a, d
	rlc	a
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	ld	hl, (ix - 25)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_24
; %bb.22:
	ld	l, e
	ld	h, d
	.local	.LBB23_23
.LBB23_23:
	ld	(ix - 25), hl
	.local	.LBB23_24
.LBB23_24:
	ld	iy, 0
	ld.sis	de, 1
	ld	hl, (ix - 28)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	p, .LBB23_26
; %bb.25:
	ld.sis	hl, 0
                                        ; kill: def $hl killed $hl def $uhl
	ld	(ix - 28), hl
	.local	.LBB23_26
.LBB23_26:
	ld	a, (_active_render_height)
	ld	e, a
	ld	d, 0
	ld	hl, (ix - 25)
                                        ; kill: def $hl killed $hl killed $uhl
	ld	(ix - 43), e
	ld	(ix - 42), d
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	de, (ix - 34)
	jp	m, .LBB23_28
; %bb.27:
	ld	c, (ix - 43)
	ld	b, (ix - 42)
	dec.sis	bc
	ld	l, c
	ld	h, b
	ld	(ix - 25), hl
	.local	.LBB23_28
.LBB23_28:
	lea	bc, iy + 0
	ld	hl, (ix - 28)
	ld	c, l
	ld	b, h
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	push	de
	pop	hl
	jr	nc, .LBB23_30
; %bb.29:
	ld	hl, (ix - 40)
	push	de
	pop	iy
	ld	de, 65535
	add	hl, de
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	push	hl
	pop	iy
	add	iy, bc
	scf
	sbc	hl, hl
	ld	c, (ix - 37)                    ; 1-byte Folded Reload
	call	__ishl
	push	hl
	pop	bc
	lea	hl, iy + 0
	call	__iand
	add	hl, de
	.local	.LBB23_30
.LBB23_30:
	ld	(ix - 28), hl
	ld	iy, (ix - 25)
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	push	de
	pop	bc
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	push	de
	pop	hl
	push	bc
	pop	iy
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_32
; %bb.31:
	ex	de, hl
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	ex	de, hl
	scf
	sbc	hl, hl
	ld	c, (ix - 37)                    ; 1-byte Folded Reload
	call	__ishl
	push	hl
	pop	bc
	ex	de, hl
	ld	(ix - 55), bc
	call	__iand
	push	hl
	pop	iy
	ld	de, (ix - 34)
	add	iy, de
	ld	c, 8
	ld	hl, (ix - 28)
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	(ix - 37), iy
	lea	hl, iy + 0
	call	__ishl
	call	__ishrs
	ld	(ix - 25), hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB23_34
	.local	.LBB23_32
.LBB23_32:
	xor	a, a
	.local	.LBB23_33
.LBB23_33:                              ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB23_34
.LBB23_34:                              ; %.preheader.preheader
	ld	(ix - 58), de
	ld	a, 8
	ld	hl, (ix - 28)
	ld	iy, 0
	.local	.LBB23_35
.LBB23_35:                              ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	ld	c, a
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	hl, (ix - 25)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB23_37
; %bb.36:                               ;   in Loop: Header=BB23_35 Depth=1
	push	de
	pop	hl
	ld	bc, 3
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _span_left
	add	hl, bc
	ld	iy, 1048577
	ld	(hl), iy
	ld	iy, 0
	ld	hl, _span_right
	add	hl, bc
	ld	bc, -1048577
	ld	(hl), bc
	ex	de, hl
	ld	de, (ix - 40)
	add	hl, de
	jr	.LBB23_35
	.local	.LBB23_37
.LBB23_37:
	lea	hl, iy + 0
	ld	l, (ix - 49)                    ; 1-byte Folded Reload
	ld	(ix - 46), hl
	ld	hl, (ix - 40)
	ld	de, 65535
	add	hl, de
	ld	de, (ix - 34)
	or	a, a
	sbc	hl, de
	ld	(ix - 61), hl
	ld	a, 8
	or	a, a
	sbc	hl, hl
	ld	(ix - 31), hl
	.local	.LBB23_38
.LBB23_38:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB23_62 Depth 2
	ld	bc, (ix - 31)
	push	bc
	pop	hl
	ld	de, (ix - 46)
	or	a, a
	sbc	hl, de
	jp	z, .LBB23_90
; %bb.39:                               ;   in Loop: Header=BB23_38 Depth=1
	push	bc
	pop	hl
	ld	(ix - 31), bc
	ld	bc, 6
	call	__imulu
	push	de
	pop	bc
	ex	de, hl
	ld	iy, (ix + 6)
	add	iy, de
	ld	de, (iy + 3)
	ld	hl, (ix - 31)
	inc	hl
	ld	(ix - 31), hl
	or	a, a
	sbc	hl, bc
	ld	hl, 0
	jr	z, .LBB23_41
; %bb.40:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	hl, (ix - 31)
	.local	.LBB23_41
.LBB23_41:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	bc, (iy)
	ld	(ix - 49), bc
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
	jr	z, .LBB23_38
; %bb.42:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	hl, (iy)
	ld	(ix - 64), hl
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB23_44
; %bb.43:                               ;   in Loop: Header=BB23_38 Depth=1
	push	de
	pop	iy
	push	bc
	pop	de
	ld	bc, (ix - 64)
	ld	hl, (ix - 49)
	jr	.LBB23_45
	.local	.LBB23_44
.LBB23_44:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	hl, (ix - 49)
	push	bc
	pop	iy
	push	hl
	pop	bc
	ld	hl, (ix - 64)
	.local	.LBB23_45
.LBB23_45:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	(ix - 49), bc
	or	a, a
	sbc	hl, bc
	ld	(ix - 64), hl
	ld	(ix - 70), iy
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	ld	(ix - 67), hl
	push	de
	pop	hl
	ld	bc, 128
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	(ix - 76), de
	jp	m, .LBB23_47
; %bb.46:                               ;   in Loop: Header=BB23_38 Depth=1
	ex	de, hl
	ld	bc, 127
	add	hl, bc
	ld	c, a
	call	__ishru
	push	hl
	pop	iy
	jp	.LBB23_48
	.local	.LBB23_47
.LBB23_47:                              ;   in Loop: Header=BB23_38 Depth=1
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	ld	c, a
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	.local	.LBB23_48
.LBB23_48:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	de, (ix - 70)
	push	de
	pop	hl
	ld	bc, -129
	add	hl, bc
	ld	c, a
	call	__ishru
	ld	(ix - 73), hl
	ld	hl, 384
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
	jp	m, .LBB23_50
; %bb.49:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	hl, (ix - 73)
	ld	c, l
	ld	b, h
	.local	.LBB23_50
.LBB23_50:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	(ix - 70), c
	ld	(ix - 69), b
	lea	bc, iy + 0
	ld	a, b
	rlc	a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	de, (ix - 58)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, (ix - 28)
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	jp	m, .LBB23_52
; %bb.51:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	iyl, c
	ld	iyh, b
	.local	.LBB23_52
.LBB23_52:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	c, (ix - 70)
	ld	b, (ix - 69)
	ld	a, b
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, c
	ld	d, b
	ld	hl, (ix - 25)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	hl, (ix - 37)
                                        ; kill: def $hl killed $hl killed $uhl
	jp	m, .LBB23_54
; %bb.53:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	l, c
	ld	h, b
	.local	.LBB23_54
.LBB23_54:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	(ix - 70), l
	ld	(ix - 69), h
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ld	hl, (ix - 61)
	add	hl, de
	ld	bc, (ix - 55)
	call	__iand
	push	hl
	pop	iy
	ld	hl, (ix - 34)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB23_56
; %bb.55:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	iy, 0
	.local	.LBB23_56
.LBB23_56:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	de, (ix - 34)
	add	iy, de
	lea	hl, iy + 0
	ld	c, 8
	call	__ishl
	ld	(ix - 79), hl
	lea	hl, iy + 0
	call	__ishl
	call	__ishrs
	ld	(ix - 73), hl
	ld	e, (ix - 70)
	ld	d, (ix - 69)
	ld	a, d
	rlc	a
	ld	a, c
	sbc	hl, hl
	push	hl
	pop	bc
	ld	c, e
	ld	b, d
	push	bc
	pop	hl
	ld	de, (ix - 73)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB23_38
; %bb.57:                               ;   in Loop: Header=BB23_38 Depth=1
	ld	(ix - 82), iy
	ld	(ix - 70), bc
	ld	hl, (ix - 67)
	ld	de, -32760
	add	hl, de
	ld	iy, (ix - 64)
	ld	de, -32768
	add	iy, de
	ld	de, -32504
	or	a, a
	sbc	hl, de
	ld	hl, 0
	ld	a, l
	ld	(ix - 73), a
	jr	c, .LBB23_59
; %bb.58:                               ;   in Loop: Header=BB23_38 Depth=1
	lea	hl, iy + 0
	ld	de, -65535
	or	a, a
	sbc	hl, de
	jr	nc, .LBB23_60
	.local	.LBB23_59
.LBB23_59:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	bc, (ix - 64)
	ld	(ix - 18), bc
	ld	a, (ix - 16)
	rlc	a
	sbc	a, a
	ld	d, 8
	ld	l, d
	call	__lshl
	ld	e, a
	ld	iy, (ix - 67)
	ld	(ix - 15), iy
	ld	a, (ix - 13)
	rlc	a
	sbc	a, a
	push	bc
	pop	hl
	lea	bc, iy + 0
	call	__ldivs
	ld	(ix - 67), hl
	jr	.LBB23_61
	.local	.LBB23_60
.LBB23_60:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	de, 8
	ld	hl, (ix - 67)
	add	hl, de
	ld	c, 4
	call	__ishru
	ld	bc, (ix - 64)
	ld	(ix - 22), bc
	ld	a, (ix - 20)
	rlc	a
	sbc	a, a
	add	hl, hl
	ex	de, hl
	ld	hl, _edge_reciprocal_table
	add	hl, de
	ld	de, (hl)
	ld	l, (ix - 43)
	ld	h, (ix - 42)
	ld	(ix - 19), h
	ld	hl, (ix - 21)
	ld	h, d
	ld	l, e
	ld	e, (ix - 73)                    ; 1-byte Folded Reload
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, 12
	call	__lshrs
	ld	(ix - 67), bc
	ld	e, a
	ld	d, 8
	.local	.LBB23_61
.LBB23_61:                              ;   in Loop: Header=BB23_38 Depth=1
	ld	hl, (ix - 49)
	ld	(ix - 12), hl
	ld	a, (ix - 10)
	rlc	a
	sbc	a, a
	ld	(ix - 64), a                    ; 1-byte Folded Spill
	ld	hl, (ix - 79)
	ld	bc, (ix - 76)
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
	ld	hl, (ix - 67)
	ld	(ix - 83), e
	lea	bc, iy + 0
	call	__lmulu
	push	hl
	pop	bc
	ld	a, e
	ld	l, d
	call	__lshrs
	push	bc
	pop	hl
	ld	e, a
	ld	bc, (ix - 49)
	ld	a, (ix - 64)                    ; 1-byte Folded Reload
	call	__ladd
	ld	(ix - 49), hl
	ld	(ix - 64), e                    ; 1-byte Folded Spill
	ld	hl, (ix - 67)
	ld	e, (ix - 83)                    ; 1-byte Folded Reload
	ld	bc, (ix - 40)
	ld	a, (ix - 73)                    ; 1-byte Folded Reload
	call	__lmulu
	ld	(ix - 73), hl
	ld	(ix - 76), e                    ; 1-byte Folded Spill
	ld	hl, (ix - 82)
	ld	iy, (ix - 70)
	.local	.LBB23_62
.LBB23_62:                              ;   Parent Loop BB23_38 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	c, d
	call	__ishl
	call	__ishrs
	push	hl
	pop	bc
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	ld	a, d
	jp	m, .LBB23_38
; %bb.63:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	(ix - 67), bc
	push	bc
	pop	hl
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, _span_left
	add	iy, de
	ld	bc, (iy)
	ld	(ix - 6), bc
	ld	a, (ix - 4)
	rlc	a
	sbc	a, a
	ld	hl, (ix - 49)
	ld	e, (ix - 64)                    ; 1-byte Folded Reload
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB23_73
; %bb.64:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, (ix - 49)
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	ld	a, 1
	jp	m, .LBB23_66
; %bb.65:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	a, 0
	.local	.LBB23_66
.LBB23_66:                              ;   in Loop: Header=BB23_62 Depth=2
	bit	0, a
	ld	bc, (ix - 49)
	jr	nz, .LBB23_68
; %bb.67:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	bc, 1048576
	.local	.LBB23_68
.LBB23_68:                              ;   in Loop: Header=BB23_62 Depth=2
	bit	0, a
	ld	a, e
	jr	nz, .LBB23_70
; %bb.69:                               ;   in Loop: Header=BB23_62 Depth=2
	xor	a, a
	.local	.LBB23_70
.LBB23_70:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, -1048576
	ld	e, -1
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB23_72
; %bb.71:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	bc, -1048576
	.local	.LBB23_72
.LBB23_72:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	(iy), bc
	.local	.LBB23_73
.LBB23_73:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, (ix - 67)
	ld	bc, 3
	call	__imulu
	ex	de, hl
	ld	iy, _span_right
	add	iy, de
	ld	d, (ix - 64)                    ; 1-byte Folded Reload
	ld	hl, (iy)
	ld	(ix - 3), hl
	ld	a, (ix - 1)
	rlc	a
	sbc	a, a
	ld	e, a
	ld	bc, (ix - 49)
	ld	a, d
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB23_83
; %bb.74:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, (ix - 49)
	ld	e, d
	ld	bc, 1048576
	xor	a, a
	call	__lcmps
	call	pe, __setflag
	ld	a, 1
	jp	m, .LBB23_76
; %bb.75:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	a, 0
	.local	.LBB23_76
.LBB23_76:                              ;   in Loop: Header=BB23_62 Depth=2
	bit	0, a
	ld	bc, (ix - 49)
	jr	nz, .LBB23_78
; %bb.77:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	bc, 1048576
	.local	.LBB23_78
.LBB23_78:                              ;   in Loop: Header=BB23_62 Depth=2
	bit	0, a
	ld	a, d
	jr	nz, .LBB23_80
; %bb.79:                               ;   in Loop: Header=BB23_62 Depth=2
	xor	a, a
	.local	.LBB23_80
.LBB23_80:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, -1048576
	ld	e, -1
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB23_82
; %bb.81:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	bc, -1048576
	.local	.LBB23_82
.LBB23_82:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	(iy), bc
	.local	.LBB23_83
.LBB23_83:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, (ix - 67)
	ld	de, (ix - 40)
	add	hl, de
	ex	de, hl
	ld	iy, (ix - 70)
	lea	hl, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	ld	a, -1
	jp	m, .LBB23_85
; %bb.84:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	a, 0
	.local	.LBB23_85
.LBB23_85:                              ;   in Loop: Header=BB23_62 Depth=2
	bit	0, a
	ld	hl, 0
	jr	nz, .LBB23_87
; %bb.86:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	hl, (ix - 73)
	.local	.LBB23_87
.LBB23_87:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	(ix - 67), de
	bit	0, a
	ld	e, 0
	ld	a, (ix - 64)                    ; 1-byte Folded Reload
	jr	nz, .LBB23_89
; %bb.88:                               ;   in Loop: Header=BB23_62 Depth=2
	ld	e, (ix - 76)                    ; 1-byte Folded Reload
	.local	.LBB23_89
.LBB23_89:                              ;   in Loop: Header=BB23_62 Depth=2
	ld	bc, (ix - 49)
	call	__ladd
	ld	(ix - 49), hl
	ld	(ix - 64), e                    ; 1-byte Folded Spill
	ld	d, 8
	ld	hl, (ix - 67)
	jp	.LBB23_62
	.local	.LBB23_90
.LBB23_90:
	ld	bc, (ix - 28)
	ld	a, c
	ld	de, 149
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	add	iy, de
	ld	(iy), a
	ld	hl, (ix - 37)
	ld	a, l
	inc	de
	ld	iy, (ix + 6)
	add	iy, de
	ld	(iy), a
	push	bc
	pop	hl
	ld	a, (_active_render_width)
	ld	e, a
	ld	b, d
	ld	(ix - 49), c
	ld	(ix - 48), b
	ld	d, b
	ld	(ix - 37), e
	ld	(ix - 36), d
	dec.sis	de
	ld	(ix - 46), e
	ld	(ix - 45), d
	ld	iy, (ix + 6)
	lea	de, iy + 48
	ld	(ix - 31), de
	lea	de, iy + 96
	ld	(ix - 34), de
	ld	c, 8
	xor	a, a
	.local	.LBB23_91
.LBB23_91:                              ; =>This Inner Loop Header: Depth=1
	call	__ishl
	call	__ishrs
	ex	de, hl
	ld	hl, (ix - 25)
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB23_33
; %bb.92:                               ;   in Loop: Header=BB23_91 Depth=1
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
	jr	nz, .LBB23_94
; %bb.93:                               ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix - 31)
	add	hl, bc
	ld	(hl), -1
	ld	hl, (ix - 34)
	add	hl, bc
	ld	(hl), 0
	push	bc
	pop	de
	jp	.LBB23_113
	.local	.LBB23_94
.LBB23_94:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	(ix - 58), a                    ; 1-byte Folded Spill
	ld	(ix - 28), bc
	lea	bc, iy + 0
	push	bc
	pop	hl
	ld	iy, 128
	lea	de, iy + 0
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	m, .LBB23_96
; %bb.95:                               ;   in Loop: Header=BB23_91 Depth=1
	push	bc
	pop	hl
	ld	bc, 127
	add	hl, bc
	ld	a, 8
	ld	c, a
	call	__ishru
	jp	.LBB23_97
	.local	.LBB23_96
.LBB23_96:                              ;   in Loop: Header=BB23_91 Depth=1
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	a, 8
	ld	c, a
	call	__ishru
                                        ; kill: def $hl killed $hl killed $uhl
	call	__sneg
                                        ; kill: def $hl killed $hl def $uhl
	.local	.LBB23_97
.LBB23_97:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	(ix - 55), hl
	ld	hl, (ix - 28)
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
	ld	(ix - 43), hl
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
	jp	m, .LBB23_99
; %bb.98:                               ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix - 43)
	ld	c, l
	ld	b, h
	.local	.LBB23_99
.LBB23_99:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	(ix - 43), c
	ld	(ix - 42), b
	ld	iy, (ix - 55)
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
	jp	p, .LBB23_101
; %bb.100:                              ;   in Loop: Header=BB23_91 Depth=1
	ld.sis	bc, 0
	.local	.LBB23_101
.LBB23_101:                             ;   in Loop: Header=BB23_91 Depth=1
	push	hl
	ld	l, (ix - 43)
	ld	h, (ix - 42)
	ex	(sp), hl
	pop	iy
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	ld	e, (ix - 37)
	ld	d, (ix - 36)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	jp	m, .LBB23_103
; %bb.102:                              ;   in Loop: Header=BB23_91 Depth=1
	push	hl
	ld	l, (ix - 46)
	ld	h, (ix - 45)
	ex	(sp), hl
	pop	iy
	.local	.LBB23_103
.LBB23_103:                             ;   in Loop: Header=BB23_91 Depth=1
	ld	a, iyh
	rlc	a
	sbc	hl, hl
	ld	(ix - 61), hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	ld	de, (ix - 28)
	jp	p, .LBB23_106
; %bb.104:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix - 31)
	add	hl, de
	ld	(hl), -1
	ld	hl, (ix - 34)
	add	hl, de
	ld	(hl), 0
	.local	.LBB23_105
.LBB23_105:                             ;   in Loop: Header=BB23_91 Depth=1
	ld	a, (ix - 58)                    ; 1-byte Folded Reload
	jp	.LBB23_113
	.local	.LBB23_106
.LBB23_106:                             ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix - 31)
	add	hl, de
	ld	(hl), c
	push	iy
	ex	(sp), hl
	ld	(ix - 43), l
	ld	(ix - 42), h
	pop	hl
	ld	a, iyl
	ld	hl, (ix - 34)
	add	hl, de
	ld	(hl), a
	ld	hl, (ix - 52)
	ld	a, (hl)
	or	a, a
	ld	a, 1
	jp	nz, .LBB23_113
; %bb.107:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix + 9)
	ld	de, 1306
	add	hl, de
	ld	de, (ix - 28)
	ld	a, (hl)
	ld	iy, 0
	lea	bc, iy + 0
	ld	c, a
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	m, .LBB23_105
; %bb.108:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix + 9)
	ld	de, 1307
	add	hl, de
	ld	de, (ix - 28)
	ld	a, (hl)
	lea	hl, iy + 0
	ld	l, a
	or	a, a
	sbc	hl, de
	jr	c, .LBB23_105
; %bb.109:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	hl, (ix - 61)
	ld	c, (ix - 43)
	ld	b, (ix - 42)
	ld	l, c
	ld	h, b
	ld	(ix - 61), hl
	ld	hl, (ix + 9)
	add	hl, de
	ld	(ix - 43), hl
	ld	de, 1208
	add	hl, de
	ld	a, (hl)
	lea	bc, iy + 0
	ld	c, a
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB23_111
; %bb.110:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	a, (ix - 58)                    ; 1-byte Folded Reload
	ld	de, (ix - 28)
	jr	.LBB23_113
	.local	.LBB23_111
.LBB23_111:                             ;   in Loop: Header=BB23_91 Depth=1
	ld	de, 1256
	ld	hl, (ix - 43)
	add	hl, de
	ld	a, (hl)
	ld	l, (ix - 49)
	ld	h, (ix - 48)
	ld	l, a
	ld	(ix - 49), l
	ld	(ix - 48), h
	ld	de, (ix - 55)
	or	a, a
	sbc.sis	hl, de
	call	pe, __setflag
	ld	a, (ix - 58)                    ; 1-byte Folded Reload
	ld	de, (ix - 28)
	jp	m, .LBB23_113
; %bb.112:                              ;   in Loop: Header=BB23_91 Depth=1
	ld	a, 1
	.local	.LBB23_113
.LBB23_113:                             ;   in Loop: Header=BB23_91 Depth=1
	ex	de, hl
	ld	de, (ix - 40)
	add	hl, de
	ld	c, 8
	jp	.LBB23_91
	.local	.Lfunc_end23
.Lfunc_end23:
	.size	_rasterize_polygon, .Lfunc_end23-_rasterize_polygon
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
	jr	nz, .LBB24_3
; %bb.1:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB24_4
; %bb.2:
	ld	de, (ix + 18)
	lea	hl, iy + 15
	jr	.LBB24_5
	.local	.LBB24_3
.LBB24_3:
	lea	hl, iy + 9
	jr	.LBB24_5
	.local	.LBB24_4
.LBB24_4:
	lea	hl, iy + 12
	.local	.LBB24_5
.LBB24_5:
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
	jp	p, .LBB24_7
; %bb.6:
	ld	de, (ix - 24)
	.local	.LBB24_7
.LBB24_7:
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
	jr	nz, .LBB24_10
; %bb.8:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	ld	iy, (ix + 9)
	jr	nz, .LBB24_11
; %bb.9:
	ld	de, (ix + 18)
	lea	hl, iy + 24
	jr	.LBB24_12
	.local	.LBB24_10
.LBB24_10:
	ld	iy, (ix + 9)
	lea	hl, iy + 18
	jr	.LBB24_12
	.local	.LBB24_11
.LBB24_11:
	lea	hl, iy + 21
	.local	.LBB24_12
.LBB24_12:
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
	jp	p, .LBB24_14
; %bb.13:
	lea	bc, iy + 0
	.local	.LBB24_14
.LBB24_14:
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
	jr	nz, .LBB24_17
; %bb.15:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	ld	iy, (ix + 9)
	jr	nz, .LBB24_18
; %bb.16:
	ld	hl, (ix + 18)
	ld	(ix - 21), hl
	lea	hl, iy + 33
	jr	.LBB24_19
	.local	.LBB24_17
.LBB24_17:
	ld	iy, (ix + 9)
	lea	hl, iy + 27
	jr	.LBB24_19
	.local	.LBB24_18
.LBB24_18:
	ld	(ix - 21), de
	lea	hl, iy + 30
	.local	.LBB24_19
.LBB24_19:
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
	jp	p, .LBB24_21
; %bb.20:
	lea	bc, iy + 0
	.local	.LBB24_21
.LBB24_21:
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
	.local	.Lfunc_end24
.Lfunc_end24:
	.size	_camera_axis_scaled, .Lfunc_end24-_camera_axis_scaled
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
	jp	z, .LBB25_7
; %bb.1:
	ld	iy, (ix + 9)
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB25_7
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
	jr	z, .LBB25_5
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
	jr	nz, .LBB25_6
; %bb.4:
	ld	l, (ix - 1)                     ; 1-byte Folded Reload
	push	hl
	call	_ti_Close
	pop	hl
	.local	.LBB25_5
.LBB25_5:
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
	jr	.LBB25_7
	.local	.LBB25_6
.LBB25_6:
	ld	a, 1
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	ld	l, (ix - 1)
	ld	(iy), l
	ld	(iy + 1), a
	.local	.LBB25_7
.LBB25_7:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end25
.Lfunc_end25:
	.size	_true3d_level_open, .Lfunc_end25-_true3d_level_open
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
	jp	z, .LBB26_20
; %bb.1:
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB26_20
; %bb.2:
	ld	hl, (ix + 12)
	ld	de, 30
	or	a, a
	sbc	hl, de
	jp	c, .LBB26_20
; %bb.3:
	ld	iy, (ix + 9)
	ld	a, (iy)
	cp	a, 84
	jp	nz, .LBB26_20
; %bb.4:
	ld	a, (iy + 1)
	cp	a, 51
	jp	nz, .LBB26_20
; %bb.5:
	ld	a, (iy + 2)
	cp	a, 68
	jp	nz, .LBB26_20
; %bb.6:
	ld	a, (iy + 3)
	cp	a, 49
	jp	nz, .LBB26_20
; %bb.7:
	ld	a, (iy + 4)
	cp	a, 1
	jp	nz, .LBB26_20
; %bb.8:
	ld	l, -9
	ld	h, (iy + 5)
	ld	a, h
	add	a, l
	ld	l, a
	cp	a, -8
	jp	c, .LBB26_20
; %bb.9:
	ld	a, (iy + 6)
	cp	a, h
	jp	nc, .LBB26_20
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
	jp	c, .LBB26_34
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
	.local	.LBB26_12
.LBB26_12:                              ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB26_17 Depth 2
	ld	a, d
	ld	l, (ix - 1)
	cp	a, l
	jp	z, .LBB26_22
; %bb.13:                               ;   in Loop: Header=BB26_12 Depth=1
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
	jp	m, .LBB26_34
; %bb.14:                               ;   in Loop: Header=BB26_12 Depth=1
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
	jp	m, .LBB26_34
; %bb.15:                               ;   in Loop: Header=BB26_12 Depth=1
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
	jp	m, .LBB26_34
; %bb.16:                               ;   in Loop: Header=BB26_12 Depth=1
	ld	iy, 0
	.local	.LBB26_17
.LBB26_17:                              ;   Parent Loop BB26_12 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	lea	hl, iy + 0
	ld	bc, 6
	or	a, a
	sbc	hl, bc
	jr	z, .LBB26_19
; %bb.18:                               ;   in Loop: Header=BB26_17 Depth=2
	ld	hl, (ix - 19)
	lea	bc, iy + 0
	add	hl, bc
	inc	bc
	push	bc
	pop	iy
	ld	a, (hl)
	cp	a, 13
	jp	nc, .LBB26_34
	jr	.LBB26_17
	.local	.LBB26_19
.LBB26_19:                              ;   in Loop: Header=BB26_12 Depth=1
	inc	d
	ld	iy, (ix - 19)
	lea	iy, iy + 18
	ld	bc, 18
	jp	.LBB26_12
	.local	.LBB26_20
.LBB26_20:
	ld	e, c
	.local	.LBB26_21
.LBB26_21:                              ; %.loopexit
	ld	a, e
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB26_22
.LBB26_22:
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
	jp	p, .LBB26_34
; %bb.23:
	ld	iy, (ix - 4)
	ld	iy, (iy + 2)
	ld	l, c
	ld	h, b
	lea	bc, iy + 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB26_34
; %bb.24:
	ld	iy, (ix + 9)
	ld	bc, (iy + 10)
	ld	iy, (ix - 4)
	ld	hl, (iy + 4)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB26_34
; %bb.25:
	ld	iy, (ix - 4)
	ld	iy, (iy + 6)
	ld	l, c
	ld	h, b
	lea	bc, iy + 0
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB26_34
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
	jp	m, .LBB26_34
; %bb.27:
	ld	iy, (ix - 4)
	ld	bc, (iy + 10)
	ld	hl, (ix - 13)
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, bc
	call	pe, __setflag
	jp	p, .LBB26_34
; %bb.28:
	ld	hl, (ix + 9)
	push	hl
	pop	iy
	ld	d, (iy + 7)
	lea	iy, iy + 15
	.local	.LBB26_29
.LBB26_29:                              ; =>This Inner Loop Header: Depth=1
	ld	hl, (ix - 16)
	ld	bc, 2
	or	a, a
	sbc	hl, bc
	jp	z, .LBB26_35
; %bb.30:                               ;   in Loop: Header=BB26_29 Depth=1
	ld	hl, 1
	ld	bc, (ix - 16)
                                        ; kill: def $c killed $c killed $ubc
	call	__ishl
	ld	a, l
	and	a, d
	ld	l, a
	or	a, a
	jr	nz, .LBB26_32
	.local	.LBB26_31
.LBB26_31:                              ;   in Loop: Header=BB26_29 Depth=1
	ld	hl, (ix - 16)
	inc	hl
	ld	(ix - 16), hl
	lea	iy, iy + 8
	jp	.LBB26_29
	.local	.LBB26_32
.LBB26_32:                              ;   in Loop: Header=BB26_29 Depth=1
	ld	a, (iy - 1)
	ld	l, (ix - 1)
	cp	a, l
	jr	nc, .LBB26_34
; %bb.33:                               ;   in Loop: Header=BB26_29 Depth=1
	ld	a, (iy)
	cp	a, 6
	jr	c, .LBB26_31
	.local	.LBB26_34
.LBB26_34:
	ld	e, 0
	jp	.LBB26_21
	.local	.LBB26_35
.LBB26_35:
	ld	hl, (ix + 6)
	push	hl
	pop	iy
	ld	hl, (ix + 9)
	ld	(iy), hl
	ld	hl, (ix - 7)
	ld	(iy + 3), hl
	jp	.LBB26_21
	.local	.Lfunc_end26
.Lfunc_end26:
	.size	_bind_level, .Lfunc_end26-_bind_level
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
	.local	.Lfunc_end27
.Lfunc_end27:
	.size	_true3d_level_builtin_view, .Lfunc_end27-_true3d_level_builtin_view
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
	jp	z, .LBB28_3
; %bb.1:
	ld	l, (iy)
	ld	a, l
	or	a, a
	jp	z, .LBB28_3
; %bb.2:
                                        ; kill: def $l killed $l def $uhl
	push	hl
	call	_ti_Close
	pop	hl
	ld	iy, (ix + 6)
	ld	(iy), 0
	ld	(iy + 1), 0
	.local	.LBB28_3
.LBB28_3:
	pop	ix
	ret
	.local	.Lfunc_end28
.Lfunc_end28:
	.size	_true3d_level_close, .Lfunc_end28-_true3d_level_close
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -40
	call	__frameset
	ld	bc, _level
	ld	hl, _level_source
	ld	de, 1
	ld	(ix - 3), de
	push	hl
	push	bc
	call	_true3d_level_open
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB29_17
; %bb.1:
	ld	hl, _engine
	ld	de, _level
	push	de
	push	hl
	call	_engine_init
	pop	hl
	pop	hl
	or	a, a
	jp	z, .LBB29_17
; %bb.2:
	call	_gfx_Begin
	ld	hl, 1
	push	hl
	call	_gfx_SetDraw
	pop	hl
	call	_engine_graphics_init
	call	_clock
	ld	(ix - 3), hl
	ld	(ix - 6), e                     ; 1-byte Folded Spill
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, _engine
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	call	_gfx_SwapDraw
	call	_clock
	ld	bc, (ix - 3)
	ld	a, (ix - 6)                     ; 1-byte Folded Reload
	call	__lsub
	push	hl
	pop	iy
	ld	d, e
	call	__lcmpzero
	ld	(ix - 36), iy
	ld	(ix - 40), d
	jr	nz, .LBB29_4
; %bb.3:
	or	a, a
	sbc	hl, hl
	ld	(ix - 39), hl
	jr	.LBB29_7
	.local	.LBB29_4
.LBB29_4:
	ld	l, 1
	lea	bc, iy + 0
	ld	a, d
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
	pop	bc
	ld	de, 9999
	or	a, a
	sbc	hl, de
	jr	c, .LBB29_6
; %bb.5:
	ld	bc, 9999
	.local	.LBB29_6
.LBB29_6:
	ld	(ix - 39), bc
	.local	.LBB29_7
.LBB29_7:
	ld	a, (-720896)
	ld	l, 3
	or	a, l
	ld	l, a
	ld	(-720896), a
	call	_clock
	push	hl
	pop	bc
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	.local	.LBB29_8
.LBB29_8:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB29_9 Depth 2
	ld	(ix - 6), hl
	.local	.LBB29_9
.LBB29_9:                               ;   Parent Loop BB29_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
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
	jp	nz, .LBB29_16
; %bb.10:                               ;   in Loop: Header=BB29_9 Depth=2
	ld	(ix - 9), bc
	call	_clock
	push	hl
	pop	bc
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	iy, (ix - 6)
	add	iy, de
	ld	hl, -720866
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	ld	(ix - 11), e
	ld	(ix - 10), d
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	ld	(ix - 9), e
	ld	(ix - 8), d
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	ld	(ix - 13), e
	ld	(ix - 12), d
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 15), l
	ld	(ix - 14), h
	ld	hl, -720878
	push	hl
	pop	de
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 17), l
	ld	(ix - 16), h
	push	de
	pop	hl
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 19), l
	ld	(ix - 18), h
	push	de
	pop	hl
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 33), l
	ld	(ix - 32), h
	ld	hl, -720876
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 30), l
	ld	(ix - 29), h
	push	de
	pop	hl
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 28), l
	ld	(ix - 27), h
	push	de
	pop	hl
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 26), l
	ld	(ix - 25), h
	push	de
	pop	hl
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 24), l
	ld	(ix - 23), h
	ex	de, hl
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	(ix - 22), l
	ld	(ix - 21), h
	ld	(ix - 6), iy
	lea	hl, iy + 0
	ld	de, 546
	or	a, a
	sbc	hl, de
	push	bc
	pop	hl
	jp	c, .LBB29_9
; %bb.11:                               ;   in Loop: Header=BB29_9 Depth=2
	ld	e, (ix - 33)
	ld	d, (ix - 32)
	ld	a, e
	ld	b, 5
	call	__bshru
	ld	(ix - 33), hl
	ld	l, 1
	and	a, l
	ld	l, a
	ld	e, (ix - 30)
	ld	d, (ix - 29)
	ld	a, e
	ld	h, 6
	ld	b, h
	call	__bshru
	ld	e, 2
	and	a, e
	ld	c, a
	ld	a, c
	add	a, l
	ld	l, a
	ld	e, (ix - 28)
	ld	d, (ix - 27)
	ld	a, e
	ld	c, 4
	ld	b, c
	call	__bshru
	and	a, c
	ld	e, a
	ld	a, l
	add	a, e
	ld	l, a
	ld	e, (ix - 26)
	ld	d, (ix - 25)
	ld	a, e
	ld	iyl, 3
	ld	b, iyl
	call	__bshl
	ld	e, 8
	and	a, e
	ld	e, a
	ld	a, l
	add	a, e
	ld	l, a
	ld	e, (ix - 24)
	ld	d, (ix - 23)
	ld	a, e
	call	__bshru
	ld	e, 16
	and	a, e
	ld	e, a
	ld	a, l
	add	a, e
	ld	l, a
	ld	e, (ix - 22)
	ld	d, (ix - 21)
	ld	a, e
	ld	d, b
	call	__bshl
	ld	e, 32
	and	a, e
	ld	e, a
	ld	a, l
	add	a, e
	ld	l, a
	ld	(ix - 22), hl
	ld	l, (ix - 19)
	ld	h, (ix - 18)
	ld	a, l
	ld	b, c
	call	__bshl
	rlc	a
	sbc	a, a
	ld	l, a
	push	hl
	ld	l, (ix - 17)
	ld	h, (ix - 16)
	ex	(sp), hl
	pop	iy
	ld	a, iyl
	call	__bshru
	ld	h, 1
	and	a, h
	ld	e, a
	ld	a, l
	add	a, e
	ld	iyl, a
	ld	c, (ix - 15)
	ld	b, (ix - 14)
	ld	a, c
	ld	b, 6
	call	__bshl
	rlc	a
	sbc	a, a
	ld	l, a
	ld	c, (ix - 13)
	ld	b, (ix - 12)
	ld	a, c
	ld	b, 2
	call	__bshru
	ld	e, h
	and	a, e
	ld	c, a
	ld	a, l
	add	a, c
	ld	l, a
	ld	c, (ix - 11)
	ld	b, (ix - 10)
	ld	a, c
	ld	b, d
	call	__bshru
	and	a, e
	ld	c, a
	ld	b, e
	ld	e, (ix - 9)
	ld	d, (ix - 8)
	ld	a, e
	and	a, b
	ld	b, a
	ld	a, c
	sub	a, b
	ld	c, a
	ld	de, 32768
	push	de
	ld	de, (ix - 6)
	push	de
	ld	de, (ix - 22)
	push	de
	push	iy
	push	hl
	push	bc
	ld	hl, _engine
	push	hl
	call	_engine_update
	ld	hl, 21
	add	hl, sp
	ld	sp, hl
	or	a, a
	ld	hl, 0
	ld	(ix - 6), hl
	ld	bc, (ix - 33)
	jp	z, .LBB29_9
; %bb.12:                               ;   in Loop: Header=BB29_9 Depth=2
	call	_clock
	ld	(ix - 9), hl
	ld	(ix - 11), e                    ; 1-byte Folded Spill
	ld	hl, (ix - 39)
	push	hl
	ld	hl, _engine
	push	hl
	call	_engine_render
	pop	hl
	pop	hl
	call	_gfx_SwapDraw
	call	_clock
	push	hl
	pop	iy
	ld	d, e
	ld	bc, (ix - 9)
	ld	a, (ix - 11)                    ; 1-byte Folded Reload
	call	__lcmpu
	ld	hl, 0
	ld	(ix - 6), hl
	ld	bc, (ix - 33)
	jp	z, .LBB29_9
; %bb.13:                               ;   in Loop: Header=BB29_8 Depth=1
	ld	hl, (ix - 36)
	ld	e, (ix - 40)                    ; 1-byte Folded Reload
	ld	bc, 3
	xor	a, a
	call	__lmulu
	dec	bc
	call	__ladd
	ld	bc, (ix - 9)
	ld	a, (ix - 11)                    ; 1-byte Folded Reload
	call	__lsub
	lea	bc, iy + 0
	ld	a, d
	call	__ladd
	push	hl
	pop	iy
	lea	bc, iy + 0
	ld	a, e
	ld	l, 2
	call	__lshru
	ld	(ix - 36), bc
	ld	d, a
	lea	bc, iy + 0
	ld	a, e
	inc	l
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, 327680
	xor	a, a
	call	__ladd
	ld	bc, (ix - 36)
	ld	(ix - 40), d                    ; 1-byte Folded Spill
	ld	a, d
	call	__ldivu
	push	hl
	pop	bc
	ld	de, 9999
	or	a, a
	sbc	hl, de
	jr	c, .LBB29_15
; %bb.14:                               ;   in Loop: Header=BB29_8 Depth=1
	ld	bc, 9999
	.local	.LBB29_15
.LBB29_15:                              ;   in Loop: Header=BB29_8 Depth=1
	ld	(ix - 39), bc
	ld	bc, (ix - 33)
	or	a, a
	sbc	hl, hl
	jp	.LBB29_8
	.local	.LBB29_16
.LBB29_16:
	call	_kb_Reset
	call	_gfx_End
	.local	.LBB29_17
.LBB29_17:
	ld	hl, _level_source
	push	hl
	call	_true3d_level_close
	pop	hl
	ld	hl, (ix - 3)
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end29
.Lfunc_end29:
	.size	_main, .Lfunc_end29-_main
                                        ; -- End function
	.section	.bss._portal_lod_state,"aw",@nobits
	.balign	1
	.local	_portal_lod_state
_portal_lod_state:
	.zero	2

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

	.section	.bss._active_render_height,"aw",@nobits
	.balign	1
	.local	_active_render_height
_active_render_height:
	.zero	1

	.section	.bss._active_render_width,"aw",@nobits
	.balign	1
	.local	_active_render_width
_active_render_width:
	.zero	1

	.section	.bss._active_render_shift,"aw",@nobits
	.balign	1
	.local	_active_render_shift
_active_render_shift:
	.zero	1

	.section	.bss._low_frame,"aw",@nobits
	.balign	1
	.globl	_low_frame
_low_frame:
	.zero	3074

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

	.section	.bss._level,"aw",@nobits
	.balign	1
	.local	_level
_level:
	.zero	6

	.section	.bss._level_source,"aw",@nobits
	.balign	1
	.local	_level_source
_level_source:
	.zero	2

	.section	.bss._engine,"aw",@nobits
	.balign	1
	.local	_engine
_engine:
	.zero	52

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	__ldivu
	.extern	_llvm.smin.i24
	.extern	_llvm.lifetime.end.p0
	.extern	__ishru
	.extern	__Unwind_SjLj_Unregister
	.extern	__lshrs
	.extern	_memset
	.extern	__land
	.extern	_llvm.smax.i16
	.extern	__ineg
	.extern	_llvm.umax.i8
	.extern	__sneg
	.extern	_gfx_Wait
	.extern	__lsub
	.extern	__lcmpzero
	.extern	_llvm.smin.i32
	.extern	__inot
	.extern	_llvm.abs.i24
	.extern	_ti_Open
	.extern	__ladd
	.extern	_llvm.umin.i24
	.extern	__idivu
	.extern	__ldivs
	.extern	_llvm.eh.sjlj.lsda
	.extern	__iand
	.extern	__setflag
	.extern	__lneg
	.extern	_llvm.smax.i32
	.extern	_llvm.stacksave.p0
	.extern	_ti_Close
	.extern	_llvm.lifetime.start.p0
	.extern	_memcmp
	.extern	_present_low_frame_32_fast
	.extern	_llvm.smin.i16
	.extern	_gfx_SetTextTransparentColor
	.extern	__lshru
	.extern	__ixor
	.extern	_llvm.abs.i8
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_ti_GetSize
	.extern	__sdivu
	.extern	_gfx_FillRectangle_NoClip
	.extern	__bshru
	.extern	_gfx_PrintStringXY
	.extern	_llvm.umin.i8
	.extern	_llvm.memset.p0.i24
	.extern	_gfx_SetColor
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_kb_Reset
	.extern	_gfx_End
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.abs.i16
	.extern	_llvm.frameaddress.p0
	.extern	__lshl
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	__sxor
	.extern	__lcmpu
	.extern	_gfx_SetTextFGColor
	.extern	_gfx_SetTextScale
	.extern	_gfx_PrintChar
	.extern	_gfx_Begin
	.extern	_clock
	.extern	_llvm.smax.i24
	.extern	__ishru_1
	.extern	__lcmps
	.extern	_gfx_SetTextBGColor
	.extern	_gfx_SwapDraw
	.extern	__sshru
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
