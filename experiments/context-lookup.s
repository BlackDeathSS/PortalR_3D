	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"context-lookup.c"
	.globl	_lookup_original                ; -- Begin function lookup_original
	.type	_lookup_original,@function
_lookup_original:                       ; @lookup_original
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	c, 2
	call	__ishru
	push	hl
	pop	iy
	ld	de, 2047
	or	a, a
	sbc	hl, de
	jr	c, .LBB0_2
; %bb.1:
	ld	iy, 2047
	.local	.LBB0_2
.LBB0_2:
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _offsets
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _profiles
	add	hl, de
	pop	ix
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_lookup_original, .Lfunc_end0-_lookup_original
                                        ; -- End function
	.globl	_lookup_bytes                   ; -- Begin function lookup_bytes
	.type	_lookup_bytes,@function
_lookup_bytes:                          ; @lookup_bytes
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, (ix + 6)
	ld	iy, 2047
	ld	a, l
	ld	(ix - 1), a
	ld	a, h
	ld	(ix - 2), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(ix - 3), a
	ld	a, (ix - 3)
	or	a, a
	jr	nz, .LBB1_3
; %bb.1:
	ld	a, (ix - 2)
	cp	a, 32
	jr	nc, .LBB1_3
; %bb.2:
	ld	b, 2
	ld	a, (ix - 2)
	ld	de, 0
	ld	e, a
	push	de
	pop	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	pop	iy
	ld	a, (ix - 1)
	call	__bshru
	ld	e, a
	add	iy, de
	.local	.LBB1_3
.LBB1_3:
	add	iy, iy
	lea	de, iy + 0
	ld	hl, _offsets
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, _profiles
	add	hl, de
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_lookup_bytes, .Lfunc_end1-_lookup_bytes
                                        ; -- End function
	.globl	_lookup_pages                   ; -- Begin function lookup_pages
	.type	_lookup_pages,@function
_lookup_pages:                          ; @lookup_pages
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, (ix + 6)
	ld	iy, _profiles
	ld	de, _offsets+4094
	ld	a, l
	ld	(ix - 1), a
	ld	a, h
	ld	(ix - 2), a
	ld	c, 16
	call	__ishru
	ld	a, l
	ld	(ix - 3), a
	ld	a, (ix - 3)
	or	a, a
	jr	nz, .LBB2_3
; %bb.1:
	ld	a, (ix - 2)
	cp	a, 32
	ex	de, hl
	jr	nc, .LBB2_4
; %bb.2:
	ld	a, (ix - 2)
	ld	de, 0
	ld	e, a
	ld	bc, 3
	push	de
	pop	hl
	call	__imulu
	push	hl
	pop	bc
	ld	hl, _pages
	add	hl, bc
	ld	hl, (hl)
	ld	a, (ix - 1)
	ld	b, 2
	call	__bshru
	ld	e, a
	sla	e
	add	hl, de
	jr	.LBB2_4
	.local	.LBB2_3
.LBB2_3:
	ex	de, hl
	.local	.LBB2_4
.LBB2_4:
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	add	iy, de
	lea	hl, iy + 0
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_lookup_pages, .Lfunc_end2-_lookup_pages
                                        ; -- End function
	.globl	_lookup_direct_profile          ; -- Begin function lookup_direct_profile
	.type	_lookup_direct_profile,@function
_lookup_direct_profile:                 ; @lookup_direct_profile
; %bb.0:
	call	__frameset0
	ld	de, (ix + 6)
	ld	iy, _direct_profiles
	ld	bc, 8191
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	c, .LBB3_2
; %bb.1:
	ld	de, 8191
	.local	.LBB3_2
.LBB3_2:
	add	iy, de
	ld	a, (iy)
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, _profiles
	add	hl, de
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_lookup_direct_profile, .Lfunc_end3-_lookup_direct_profile
                                        ; -- End function
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym _profiles
	.extern	_profiles
	.extern	__Unwind_SjLj_Unregister
	.extern	_llvm.umin.i24
	.extern	_llvm.stackrestore.p0
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.eh.sjlj.callsite
	.extern	__frameset
	.extern	_direct_profiles
	.extern	_llvm.stacksave.p0
	.extern	__bshru
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	__imulu
	.extern	_offsets
	.extern	_pages
	.extern	__ishru
	.extern	_llvm.eh.sjlj.lsda
	.extern	__frameset0
	.extern	_llvm.frameaddress.p0
	.extern	__Unwind_SjLj_Register
