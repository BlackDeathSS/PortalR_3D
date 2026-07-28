	.assume adl=1

	.equ RAY_DISTANCE, 0
	.equ RAY_MAP_X, 3
	.equ RAY_MAP_Y, 4
	.equ RAY_STEP_X, 5
	.equ RAY_STEP_Y, 6
	.equ RAY_SIDE, 7
	.equ RAY_WALL_U, 8
	.equ RAY_WALL_DIRECTION, 9
	.equ RAY_PORTAL_KIND, 10
	.equ RAY_WALL_POSITION, 11

	.equ FIXED_INF, 0x3FFFFF
	.equ DIR_NORTH, 0
	.equ DIR_SOUTH, 1
	.equ DIR_WEST, 2
	.equ DIR_EAST, 3
	.equ GRID_FAR_X, 0
	.equ GRID_NEAR_X, 3
	.equ GRID_FAR_Y, 6
	.equ GRID_KIND, 7
	.equ GRID_SLANTED_NOCLIP, 0
	.equ GRID_HORIZONTAL, 1
	.equ GRID_SLANTED_CLIPPED, 2
	.equ GRID_PROJECTION_POSITIVE_LIMIT, 0
	.equ GRID_PROJECTION_NEGATIVE_LIMIT, 3
	.equ GRID_PROJECTION_HEIGHT, 6
	.equ GRID_PROJECTION_SCREEN_Y, 8
	.equ GRID_NEAR_SCREEN_Y, 238
	.equ GRID_FAR_SCREEN_Y, 127

	.section .text._render_asm_cast_wall,"ax",@progbits
	.global _render_asm_cast_wall
	.type _render_asm_cast_wall, @function

/*
 * Exact 8.8 grid DDA for the C renderer.
 *
 * C ABI stack slots after __frameset0:
 *   ix+6  origin_x       ix+9  origin_y
 *   ix+12 ray_x          ix+15 ray_y
 *   ix+18 map_x          ix+21 map_y
 *   ix+24 RayHit *       ix+27 delta_x
 *   ix+30 delta_y
 *
	 * The generic loop keeps its exact modular recurrence in HL/BC/DE, the
	 * RayHit pointer in IY, and the current padded-map pointer in shadow HL.
	 * The specialized exact-axis paths step the map directly because
	 * projection distance is reconstructed after the hit.
 */
_render_asm_cast_wall:
	call __frameset0

	ld iy, (ix + 24)

	xor a, a
	ld (_render_asm_axis_boundary), a

	/*
	 * Cache the exact sub-cell distance to each next boundary (qx/qy) and
	 * the positive ray-component magnitudes.  The generic DDA compares
	 * qx/abs(ray_x) with qy/abs(ray_y) by cross multiplication, so reciprocal
	 * rounding can no longer change which grid face owns a ray.
	 */
	ld hl, 0
	ld l, (ix + 6)
	bit 7, (ix + 14)
	jr nz, .Lsetup_qx_store
	ld a, l
	neg
	ld l, a
	jr nz, .Lsetup_qx_store
	inc h
.Lsetup_qx_store:
	ld (_render_asm_qx), hl

	ld hl, (ix + 12)
	bit 7, (ix + 14)
	jr z, .Lsetup_abs_x_store
	ex de, hl
	ld hl, 0
	or a, a
	sbc hl, de
.Lsetup_abs_x_store:
	ld (_render_asm_abs_x), hl

	ld hl, 0
	ld l, (ix + 9)
	bit 7, (ix + 17)
	jr nz, .Lsetup_qy_store
	ld a, l
	neg
	ld l, a
	jr nz, .Lsetup_qy_store
	inc h
.Lsetup_qy_store:
	ld (_render_asm_qy), hl

	ld hl, (ix + 15)
	bit 7, (ix + 17)
	jr z, .Lsetup_abs_y_store
	ex de, hl
	ld hl, 0
	or a, a
	sbc hl, de
.Lsetup_abs_y_store:
	ld (_render_asm_abs_y), hl

	/* The supplied reciprocal deltas remain in the restored ABI frame for
	 * post-hit projection; avoid copying them through global scratch. */
	ld a, (ix + 12)
	or a, (ix + 13)
	or a, (ix + 14)
	jr nz, .Lsetup_y
	/* A vertical ray on an exact X boundary touches either column only at
	 * zero area.  The axis-only loop below therefore requires both adjacent
	 * columns to be solid before accepting a hit. */
	ld a, (ix + 6)
	or a, a
	jr nz, .Lsetup_y
	ld a, 2
	ld (_render_asm_axis_boundary), a

	/* Y reciprocal delta and exact-axis-boundary detection. */
.Lsetup_y:
	ld a, (ix + 15)
	or a, (ix + 16)
	or a, (ix + 17)
	jr nz, .Lsetup_error
	/* Symmetric horizontal-boundary ownership. */
	ld a, (ix + 9)
	or a, a
	jr nz, .Lsetup_error
	ld a, 1
	ld (_render_asm_axis_boundary), a

	/* E = qx*abs(ray_y) - qy*abs(ray_x). */
.Lsetup_error:
	ld a, (_render_asm_axis_boundary)
	or a, a
	jr nz, .Lsetup_map
	ld hl, (_render_asm_qx)
	ld bc, (_render_asm_abs_y)
	call .Lmul_q_component
	push hl
	ld hl, (_render_asm_qy)
	ld bc, (_render_asm_abs_x)
	call .Lmul_q_component
	ex de, hl
	pop hl
	or a, a
	sbc hl, de
	/* U = E + Ax is non-negative:
	 * qx*Ay + (256-qy)*Ax. Preserve U and T=Ax+Ay across map setup. */
	ld de, (_render_asm_abs_x_shift)
	add hl, de
	push hl
	ld hl, (_render_asm_abs_x_shift)
	ld de, (_render_asm_abs_y_shift)
	add hl, de
	push hl

	/* Build the map pointer once; shadow BC/DE retain signed Y/X steps. */
.Lsetup_map:
	ld hl, 0
	ld l, (ix + 21)
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, 0
	ld e, (ix + 18)
	add hl, de
	ld de, _render_wall_map
	add hl, de
	push hl
	exx
	pop hl
	ld bc, 16
	ld de, 1
	bit 7, (ix + 17)
	jr z, .Lsetup_map_y_step_ready
	ld bc, -16
.Lsetup_map_y_step_ready:
	bit 7, (ix + 14)
	jr z, .Lsetup_map_x_step_ready
	ld de, -1
.Lsetup_map_x_step_ready:
	exx

	/* Exact-axis boundary rays are rare, but a normal half-open DDA would
	 * turn a one-sided, zero-area wall edge into a full four-pixel streak.
	 * These straight-line paths accept a cell only when the cell on the
	 * other side of the boundary is solid as well.  They also avoid the
	 * general side comparison entirely. */
	ld a, (_render_asm_axis_boundary)
	or a, a
	jr z, .Ldda_exact_setup
	dec a
	jr z, .Ldda_axis_x
	jr .Ldda_axis_y

.Ldda_exact_setup:
	pop bc
	pop hl
	/* DE=Ay, BC=T=Ax+Ay, and HL=U. */
	ld de, (_render_asm_abs_y_shift)
	jr .Ldda_begin

	/* Horizontal ray: advance X and test both rows.  For a zero Y ray the
	 * shadow BC step is +16, so the other row is map_pointer - BC. */
.Ldda_axis_x:
	exx
	add hl, de
	ld a, (hl)
	or a, a
	jr z, .Ldda_axis_x_empty
	or a, a
	sbc hl, bc
	ld a, (hl)
	add hl, bc
	exx
	or a, a
	jr z, .Ldda_axis_x
	jr .Lhit_x
.Ldda_axis_x_empty:
	exx
	jr .Ldda_axis_x

	/* Vertical ray: advance Y and test both columns.  For a zero X ray the
	 * shadow DE step is +1, so the other column is map_pointer - DE. */
.Ldda_axis_y:
	exx
	add hl, bc
	ld a, (hl)
	or a, a
	jr z, .Ldda_axis_y_empty
	or a, a
	sbc hl, de
	ld a, (hl)
	add hl, de
	exx
	or a, a
	jr z, .Ldda_axis_y
	jr .Lhit_y
.Ldda_axis_y_empty:
	exx
	jr .Ldda_axis_y

	/*
	 * Exact generic DDA. HL is the non-negative modular recurrence U=E+Ax,
	 * DE is Ay, and BC is T=Ax+Ay. Each comparison computes:
	 *
	 *   U + Ay - T = E
	 *
	 * Carry therefore selects X, zero retains the existing corner rule, and
	 * a positive result is already the next U after a Y step. The shadow
	 * registers still own the map pointer and signed cell strides.
	 */
.Ldda_begin:
.Ldda_loop:
	add hl, de
	sbc hl, bc
	jr c, .Ldda_x
	jr z, .Ldda_tie

	/* The recurrence result is already the next U; advance the map row. */
.Ldda_y:
	exx
	add hl, bc
	ld a, (hl)
	exx
	or a, a
	jr z, .Ldda_loop
	jr .Lhit_y

	/* A negative result wrapped; adding T produces the next non-negative U. */
.Ldda_x:
	add hl, bc
.Ldda_x_advance:
	exx
	add hl, de
	ld a, (hl)
	exx
	or a, a
	jr z, .Ldda_loop
	jr .Lhit_x

	/*
	 * A corner touch has no area.  If only the default Y neighbor is solid,
	 * enter the empty X neighbor first; the next iteration then tests the
	 * diagonal cell at the same distance.  This makes corner ownership
	 * symmetric without perturbing any non-tied ray.
	 */
.Ldda_tie:
	exx
	push hl
	add hl, bc
	ld a, (hl)
	pop hl
	or a, a
	jr z, .Ldda_tie_take_y
	push hl
	add hl, de
	ld a, (hl)
	pop hl
	or a, a
	jr z, .Ldda_tie_take_x
.Ldda_tie_take_y:
	exx
	jr .Ldda_y
.Ldda_tie_take_x:
	exx
	jr .Ldda_x

	/* X wall ownership.  Projection distance is reconstructed below. */
.Lhit_x:
	xor a, a
	ld (iy + RAY_SIDE), a
	ld a, (ix + 14)
	rlca
	and a, 1
	ld (iy + RAY_WALL_DIRECTION), a
	add a, a
	neg
	inc a
	ld (iy + RAY_STEP_X), a
	jr .Lstore_hit

	/* Y wall ownership. */
.Lhit_y:
	ld a, 1
	ld (iy + RAY_SIDE), a
	ld a, (ix + 17)
	rlca
	and a, 1
	ld b, a
	add a, DIR_WEST
	ld (iy + RAY_WALL_DIRECTION), a
	ld a, b
	add a, a
	neg
	inc a
	ld (iy + RAY_STEP_Y), a

.Lstore_hit:
	/* Recover the padded-map index once, after the DDA has hit a wall. */
	exx
	ld de, _render_wall_map
	or a, a
	sbc hl, de
	ld a, l
	and a, 15
	ld (iy + RAY_MAP_X), a
	ld a, l
	and a, 0xF0
	rrca
	rrca
	rrca
	rrca
	ld (iy + RAY_MAP_Y), a
	exx

	/*
	 * The exact traversal deliberately does not carry reciprocal side
	 * distances in its hot loop. Recreate the legacy projection distance
	 * for the chosen face as:
	 *
	 *   initial_side + (abs(hit_cell - start_cell) - 1) * supplied_delta
	 *
	 * This is byte-for-byte the value the old accumulator produced for that
	 * same boundary, preserving wall height and wall_u rounding.
	 */
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Ldistance_rebuild_y

	ld hl, (ix + 27)
	ld bc, (_render_asm_qx)
	ld a, b
	or a, a
	jr nz, .Ldistance_initial_x_ready
	ld a, c
	call .Lscale_delta_8
.Ldistance_initial_x_ready:
	ld de, (ix + 27)
	ld a, (iy + RAY_MAP_X)
	ld b, (ix + 18)
	ld c, a
	bit 7, (ix + 14)
	ld a, c
	jr z, .Ldistance_x_positive
	ld a, b
	sub a, c
	jr .Ldistance_count_ready
.Ldistance_x_positive:
	sub a, b
	jr .Ldistance_count_ready

.Ldistance_rebuild_y:
	ld hl, (ix + 30)
	ld bc, (_render_asm_qy)
	ld a, b
	or a, a
	jr nz, .Ldistance_initial_y_ready
	ld a, c
	call .Lscale_delta_8
.Ldistance_initial_y_ready:
	ld de, (ix + 30)
	ld a, (iy + RAY_MAP_Y)
	ld b, (ix + 21)
	ld c, a
	bit 7, (ix + 17)
	ld a, c
	jr z, .Ldistance_y_positive
	ld a, b
	sub a, c
	jr .Ldistance_count_ready
.Ldistance_y_positive:
	sub a, b

.Ldistance_count_ready:
	dec a
	jr z, .Ldistance_rebuilt
.Ldistance_add_delta:
	add hl, de
	dec a
	jr nz, .Ldistance_add_delta
.Ldistance_rebuilt:
	/* A solid neighbor can yield zero distance; retain the C clamp. */
	ld bc, 0
	or a, a
	sbc hl, bc
	jr nz, .Ldistance_nonzero
	inc hl
.Ldistance_nonzero:
	ld (iy + RAY_DISTANCE), hl

	ld hl, (iy + RAY_DISTANCE)
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Lwall_position_y

	/* X wall position uses origin_y + distance * ray_y / 256. */
	ld bc, (ix + 15)
	call .Lmul_distance_ray
	ld de, (ix + 9)
	add hl, de
	jr .Lwall_position_store

	/* Y wall position uses origin_x + distance * ray_x / 256. */
.Lwall_position_y:
	ld bc, (ix + 12)
	call .Lmul_distance_ray
	ld de, (ix + 6)
	add hl, de

.Lwall_position_store:
	ld iy, (ix + 24)
	ld (iy + RAY_WALL_POSITION), hl
	ld a, l
	ld (iy + RAY_WALL_U), a
	pop ix
	ret

	/*
	 * HL = q (0..256), BC = component magnitude (0..425).
	 * Return q*component exactly.  For q<256 one MLT resolves the low byte;
	 * the component high byte is at most one.  q==256 is the component<<8
	 * boundary case.
	 */
.Lmul_q_component:
	ld a, h
	or a, a
	jr nz, .Lmul_q_component_256
	ld a, l
	ld de, 0
	ld d, a
	ld e, c
	mlt de
	push de
	pop hl
	bit 0, b
	ret z
	ld de, 0
	ld d, a
	add hl, de
	ret
.Lmul_q_component_256:
	push bc
	pop hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ret

	/*
	 * HL = delta, A = 0..255 cell fraction.
	 * Compute floor(A * delta / 256) using two native 8x8 MLTs.
	 */
.Lscale_delta_8:
	ld de, 65536
	or a, a
	sbc hl, de
	jr z, .Lscale_delta_large
	add hl, de
	ld bc, 0
	ld de, 0
	ld e, h
	ld c, l
	ld b, a
	ld d, a
	mlt bc
	mlt de
	ld hl, 0
	ld l, b
	add hl, de
	ret
.Lscale_delta_large:
	ld hl, 0
	ld h, a
	ret

	/*
	 * HL = positive 16-bit distance, BC = signed 16-bit ray component.
	 * Return trunc(HL * BC / 256) exactly using two 8x8 MLTs.
	 * Ray magnitude is at most 425, so its high byte is only zero or one.
	 */
.Lmul_distance_ray:
	push hl
	pop iy
	ld a, b
	and a, 0x80
	ex af, af'
	bit 7, b
	jr z, .Lmul_magnitude_ready
	push bc
	pop de
	or a, a
	sbc hl, hl
	sbc hl, de
	push hl
	pop bc
.Lmul_magnitude_ready:
	ld de, 0
	ld d, c
	ld e, iyl
	mlt de
	ld hl, 0
	ld h, c
	ld c, d
	ld a, iyh
	ld l, a
	mlt hl
	ld de, 0
	ld e, c
	add hl, de
	bit 0, b
	jr z, .Lmul_apply_sign
	push iy
	pop de
	add hl, de
.Lmul_apply_sign:
	ex af, af'
	or a, a
	ret z
	ex de, hl
	or a, a
	sbc hl, hl
	sbc hl, de
	ret

	.size _render_asm_cast_wall, .-_render_asm_cast_wall

	.section .text._render_asm_delta_pair,"ax",@progbits
	.global _render_asm_delta_pair
	.type _render_asm_delta_pair, @function

/*
 * Resolve both positive reciprocal DDA deltas with one C ABI transition.
 * Stack slots after __frameset0: ix+6 ray_x, ix+9 ray_y, ix+12 output.
 */
_render_asm_delta_pair:
	call __frameset0
	ld iy, (ix + 12)

	ld hl, (ix + 6)
	ld a, (ix + 8)
	call .Ldelta_pair_component
	ld (iy), hl

	ld hl, (ix + 9)
	ld a, (ix + 11)
	call .Ldelta_pair_component
	ld (iy + 3), hl

	pop ix
	ret

/* A is the sign byte and HL is a signed 24-bit component. */
.Ldelta_pair_component:
	bit 7, a
	jr z, .Ldelta_pair_magnitude
	ex de, hl
	or a, a
	sbc hl, hl
	sbc hl, de

.Ldelta_pair_magnitude:
	ld de, 0
	or a, a
	sbc hl, de
	jr z, .Ldelta_pair_zero

	dec hl
	jr z, .Ldelta_pair_one
	inc hl

	ld de, 425
	or a, a
	sbc hl, de
	jr c, .Ldelta_pair_under_limit
	ld hl, 425
	jr .Ldelta_pair_lookup

.Ldelta_pair_under_limit:
	add hl, de

.Ldelta_pair_lookup:
	add hl, hl
	ld de, _render_reciprocal_delta
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, 0
	ld l, e
	ld h, d
	ret

.Ldelta_pair_zero:
	ld hl, FIXED_INF
	ret

.Ldelta_pair_one:
	ld hl, 65536
	ret

	.size _render_asm_delta_pair, .-_render_asm_delta_pair

	.section .text._render_asm_add_projected_grid_segment,"ax",@progbits
	.global _render_asm_add_projected_grid_segment
	.type _render_asm_add_projected_grid_segment, @function

/*
 * Project both endpoints, cull/store the retained segment, and draw its floor
 * line in one C ABI transition.
 *
 * Stack slots after __frameset0:
 *   ix+6  GridSegment **end
 *   ix+9  lateral_near
 *   ix+12 lateral_far
 *
 * The local projection core accepts HL=lateral and IY=GridProjection*. For
 * heights 1..255, derived clamp limits keep the high-byte partial product
 * below 256, so three 8x8 products exactly implement C truncation toward zero.
 */
_render_asm_add_projected_grid_segment:
	call __frameset0

	/*
	 * Projection is monotonic. Reject lines whose endpoints are both beyond
	 * the same X edge before paying for either three-product projection:
	 *   near x<0  iff lateral<=-175; near x>=320 iff lateral>=174
	 *   far  x<0  iff lateral<=-2748; far  x>=320 iff lateral>=2731
	 */
	ld hl, (ix + 9)
	bit 7, (ix + 11)
	jr z, .Lfused_grid_precheck_right
	ld de, 174
	add hl, de
	ld (_render_grid_lateral_magnitude), hl
	ld a, (_render_grid_lateral_magnitude + 2)
	bit 7, a
	jr z, .Lfused_grid_project
	ld hl, (ix + 12)
	ld de, 2747
	add hl, de
	ld (_render_grid_lateral_magnitude), hl
	ld a, (_render_grid_lateral_magnitude + 2)
	bit 7, a
	jp nz, .Lfused_grid_return
	jr .Lfused_grid_project

.Lfused_grid_precheck_right:
	ld de, -174
	add hl, de
	ld (_render_grid_lateral_magnitude), hl
	ld a, (_render_grid_lateral_magnitude + 2)
	bit 7, a
	jr nz, .Lfused_grid_project
	ld hl, (ix + 12)
	ld de, -2731
	add hl, de
	ld (_render_grid_lateral_magnitude), hl
	ld a, (_render_grid_lateral_magnitude + 2)
	bit 7, a
	jp z, .Lfused_grid_return

.Lfused_grid_project:
	ld hl, (ix + 9)
	ld iy, _render_grid_near_projection
	call .Lgrid_project_core
	ld (_render_grid_near_x), hl

	ld hl, (ix + 12)
	ld iy, _grid_far_projection
	call .Lgrid_project_core
	ld (_render_grid_far_x), hl

.Lfused_grid_store:
	ld hl, (ix + 6)
	ld iy, (hl)
	ld de, (_render_grid_far_x)
	ld (iy + GRID_FAR_X), de
	ld de, (_render_grid_near_x)
	ld (iy + GRID_NEAR_X), de
	ld (iy + GRID_FAR_Y), GRID_FAR_SCREEN_Y
	ld (iy + GRID_KIND), GRID_SLANTED_NOCLIP
	lea de, iy + 8
	ld (hl), de

	/* Push GraphX line arguments in the same order as the C implementation. */
	ld hl, 0
	ld l, GRID_NEAR_SCREEN_Y
	push hl
	ld hl, (_render_grid_near_x)
	push hl
	ld hl, GRID_FAR_SCREEN_Y
	push hl
	ld hl, (_render_grid_far_x)
	push hl

	/* The no-clip entry point requires both unsigned X values below 320. */
	ld de, 320
	ld hl, (_render_grid_far_x)
	or a, a
	sbc hl, de
	jr nc, .Lfused_grid_draw_clipped
	ld hl, (_render_grid_near_x)
	or a, a
	sbc hl, de
	jr nc, .Lfused_grid_draw_clipped
	call _gfx_Line_NoClip
	jr .Lfused_grid_line_done

.Lfused_grid_draw_clipped:
	ld (iy + GRID_KIND), GRID_SLANTED_CLIPPED
	call _gfx_Line

.Lfused_grid_line_done:
	pop hl
	pop hl
	pop hl
	pop hl

.Lfused_grid_return:
	pop ix
	ret

.Lgrid_project_core:
	ld (_render_grid_lateral_magnitude), hl
	ld a, (_render_grid_lateral_magnitude + 2)
	bit 7, a
	jr nz, .Lgrid_project_core_negative

	xor a, a
	ld (_render_grid_project_negative), a
	ld de, (iy + GRID_PROJECTION_POSITIVE_LIMIT)
	or a, a
	sbc hl, de
	jr nc, .Lgrid_project_core_clip_positive
	ld hl, (_render_grid_lateral_magnitude)
	jr .Lgrid_project_core_magnitude_ready

.Lgrid_project_core_negative:
	ld a, 1
	ld (_render_grid_project_negative), a
	ld de, (_render_grid_lateral_magnitude)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld (_render_grid_lateral_magnitude), hl
	ld de, (iy + GRID_PROJECTION_NEGATIVE_LIMIT)
	or a, a
	sbc hl, de
	jr nc, .Lgrid_project_core_clip_negative
	ld hl, (_render_grid_lateral_magnitude)

.Lgrid_project_core_magnitude_ready:
	/*
	 * magnitude = x0 + 256*x1 + 65536*x2:
	 *   magnitude*height/256 =
	 *     high(x0*height) + x1*height + (x2*height)<<8.
	 */
	ld bc, 0
	ld a, (iy + GRID_PROJECTION_HEIGHT)
	ld b, a
	ld a, (_render_grid_lateral_magnitude)
	ld c, a
	mlt bc
	ld hl, 0
	ld l, b

	ld de, 0
	ld a, (iy + GRID_PROJECTION_HEIGHT)
	ld d, a
	ld a, (_render_grid_lateral_magnitude + 1)
	ld e, a
	mlt de
	add hl, de

	ld a, (_render_grid_lateral_magnitude + 2)
	or a, a
	jr z, .Lgrid_project_core_apply_sign
	ld de, 0
	ld d, a
	ld a, (iy + GRID_PROJECTION_HEIGHT)
	ld e, a
	mlt de
	ld d, e
	ld e, 0
	add hl, de

.Lgrid_project_core_apply_sign:
	ld a, (_render_grid_project_negative)
	or a, a
	jr nz, .Lgrid_project_core_result_negative
	ld de, 160
	add hl, de
	ret

.Lgrid_project_core_result_negative:
	ex de, hl
	ld hl, 160
	or a, a
	sbc hl, de
	ret

.Lgrid_project_core_clip_positive:
	ld hl, 4096
	ret

.Lgrid_project_core_clip_negative:
	ld hl, -4096
	ret

	.size _render_asm_add_projected_grid_segment, .-_render_asm_add_projected_grid_segment

	.section .text._render_asm_add_horizontal_grid_segment,"ax",@progbits
	.global _render_asm_add_horizontal_grid_segment
	.type _render_asm_add_horizontal_grid_segment, @function

/*
 * Retain and draw one full-width horizontal floor-grid segment.
 * Stack slots: ix+6 end**, ix+9 screen_y.
 */
_render_asm_add_horizontal_grid_segment:
	call __frameset0
	ld hl, (ix + 6)
	ld iy, (hl)
	ld a, (ix + 9)
	ld (iy + GRID_FAR_Y), a
	ld (iy + GRID_KIND), GRID_HORIZONTAL
	lea de, iy + 8
	ld (hl), de

	ld hl, 320
	push hl
	ld hl, 0
	ld l, (ix + 9)
	push hl
	ld hl, 0
	push hl
	call _gfx_HorizLine_NoClip
	pop hl
	pop hl
	pop hl
	pop ix
	ret

	.size _render_asm_add_horizontal_grid_segment, .-_render_asm_add_horizontal_grid_segment

	.section .text._render_asm_find_portal,"ax",@progbits
	.global _render_asm_find_portal
	.type _render_asm_find_portal, @function

/*
 * Resolve user and built-in portals directly from a wall hit.
 * All arguments occupy three-byte CEdev ABI slots.
 */
_render_asm_find_portal:
	call __frameset0
	ld hl, (ix + 21)
	ld (hl), 0
	ld iy, (ix + 6)

	/* Primary entry: it exits through the active secondary portal. */
	ld a, (iy + 11)
	or a, a
	jr z, .Lportal_try_secondary
	ld a, (iy + 8)
	ld b, (ix + 9)
	cp a, b
	jr nz, .Lportal_try_secondary
	ld a, (iy + 9)
	ld b, (ix + 12)
	cp a, b
	jr nz, .Lportal_try_secondary
	ld a, (iy + 10)
	ld b, (ix + 15)
	cp a, b
	jr nz, .Lportal_try_secondary
	ld hl, (ix + 21)
	ld (hl), 1
	ld a, (iy + 15)
	or a, a
	jp z, .Lportal_not_linked
	ld bc, (iy + 12)
	ld hl, (ix + 18)
	ld (hl), bc
	inc hl
	inc hl
	inc hl
	ld a, (iy + 15)
	ld (hl), a
	ld hl, (ix + 24)
	ld (hl), 10
	jp .Lportal_found

	/* Secondary entry: it exits through the active primary portal. */
.Lportal_try_secondary:
	ld a, (iy + 15)
	or a, a
	jr z, .Lportal_try_builtin
	ld a, (iy + 12)
	ld b, (ix + 9)
	cp a, b
	jr nz, .Lportal_try_builtin
	ld a, (iy + 13)
	ld b, (ix + 12)
	cp a, b
	jr nz, .Lportal_try_builtin
	ld a, (iy + 14)
	ld b, (ix + 15)
	cp a, b
	jr nz, .Lportal_try_builtin
	ld hl, (ix + 21)
	ld (hl), 2
	ld a, (iy + 11)
	or a, a
	jr z, .Lportal_not_linked
	ld bc, (iy + 8)
	ld hl, (ix + 18)
	ld (hl), bc
	inc hl
	inc hl
	inc hl
	ld a, (iy + 11)
	ld (hl), a
	ld hl, (ix + 24)
	ld (hl), 11
	jr .Lportal_found

	/* Built-ins are a one-byte tile lookup followed by one six-byte record. */
.Lportal_try_builtin:
	ld hl, 0
	ld l, (ix + 12)
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, 0
	ld e, (ix + 9)
	add hl, de
	ld de, _render_builtin_portal_by_tile
	add hl, de
	ld a, (hl)
	or a, a
	jr z, .Lportal_not_linked
	dec a
	ld b, a
	ld de, 0
	ld d, 6
	ld e, a
	mlt de
	ld hl, _render_builtin_portals
	add hl, de
	inc hl
	inc hl
	ld a, (hl)
	ld c, (ix + 15)
	cp a, c
	jr nz, .Lportal_not_linked
	inc hl
	ld iy, (ix + 18)
	ld a, (hl)
	ld (iy), a
	inc hl
	ld a, (hl)
	ld (iy + 1), a
	inc hl
	ld a, (hl)
	ld (iy + 2), a
	ld (iy + 3), 1
	ld hl, (ix + 21)
	ld (hl), 3
	ld hl, (ix + 24)
	ld (hl), b

.Lportal_found:
	ld a, 1
	ld hl, 1
	pop ix
	ret
.Lportal_not_linked:
	xor a, a
	ld hl, 0
	pop ix
	ret

	.size _render_asm_find_portal, .-_render_asm_find_portal

	.section .text._render_asm_transform_ray,"ax",@progbits
	.global _render_asm_transform_ray
	.type _render_asm_transform_ray, @function

/* Transform a ray and its sub-cell origin through a linked portal. */
_render_asm_transform_ray:
	call __frameset0
	ld iy, (ix + 6)

	/*
	 * The DDA already computed the exact full wall position for wall_u.
	 * Keep that tangential coordinate and synthesize the crossed normal
	 * coordinate directly: positive entry steps land at 256, negative at 0.
	 * This is identical to advance/subtract/cross, without two multiplies.
	 */
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Ltransform_local_y_wall

	ld hl, 0
	bit 7, (iy + RAY_STEP_X)
	jr nz, .Ltransform_local_x_ready
	ld hl, 256
.Ltransform_local_x_ready:
	ld (_render_transform_local_x), hl
	ld hl, (iy + RAY_WALL_POSITION)
	ld de, 0
	ld d, (iy + RAY_MAP_Y)
	or a, a
	sbc hl, de
	ld (_render_transform_local_y), hl
	jr .Ltransform_rotation

.Ltransform_local_y_wall:
	ld hl, (iy + RAY_WALL_POSITION)
	ld de, 0
	ld d, (iy + RAY_MAP_X)
	or a, a
	sbc hl, de
	ld (_render_transform_local_x), hl
	ld hl, 0
	bit 7, (iy + RAY_STEP_Y)
	jr nz, .Ltransform_local_y_ready
	ld hl, 256
.Ltransform_local_y_ready:
	ld (_render_transform_local_y), hl

	/* rotation[entry_direction][exit_direction]. */
.Ltransform_rotation:
	ld a, (iy + RAY_WALL_DIRECTION)
	add a, a
	add a, a
	ld b, a
	ld iy, (ix + 9)
	ld a, (iy + 2)
	add a, b
	ld de, 0
	ld e, a
	ld hl, .Lportal_rotation_table
	add hl, de
	ld a, (hl)
	ld (_render_transform_rotation), a

	/* Rotate local coordinates. */
	ld hl, (_render_transform_local_x)
	ld de, (_render_transform_local_y)
	call .Lrotate_pair
	ld (_render_transform_local_x), hl
	ld (_render_transform_local_y), de

	/* Rotate the ray direction with the same quarter-turn. */
	ld iy, (ix + 18)
	ld hl, (iy)
	ld iy, (ix + 21)
	ld de, (iy)
	ld a, (_render_transform_rotation)
	call .Lrotate_pair
	ld iy, (ix + 18)
	ld (iy), hl
	ld iy, (ix + 21)
	ld (iy), de

	/* Normalize the rotated sub-cell point back into [0, 256]. */
	ld hl, (_render_transform_local_x)
	ld de, (_render_transform_local_y)
	ld a, (_render_transform_rotation)
	cp a, 2
	jr z, .Ltransform_normalize_both
	cp a, 1
	jr z, .Ltransform_normalize_x
	cp a, -1
	jr nz, .Ltransform_normalized
	push hl
	ld hl, 256
	add hl, de
	ex de, hl
	pop hl
	jr .Ltransform_normalized
.Ltransform_normalize_both:
	ld bc, 256
	add hl, bc
	ex de, hl
	add hl, bc
	ex de, hl
	jr .Ltransform_normalized
.Ltransform_normalize_x:
	ld bc, 256
	add hl, bc
.Ltransform_normalized:

	/* Add the exit tile. */
	ld iy, (ix + 9)
	ld bc, 0
	ld b, (iy)
	add hl, bc
	ld bc, 0
	ld b, (iy + 1)
	ex de, hl
	add hl, bc
	ex de, hl

	/* Restart one fixed-point unit outside the exit face. */
	ld a, (iy + 2)
	or a, a
	jr z, .Ltransform_exit_north
	cp a, 1
	jr z, .Ltransform_exit_south
	cp a, 2
	jr z, .Ltransform_exit_west
	/* East face: y = (tile_y + 1) * 256 + 1. */
	ld de, 0
	ld d, (iy + 1)
	inc d
	inc de
	jr .Ltransform_exit_ready
.Ltransform_exit_north:
	/* North face: x = tile_x * 256 - 1. */
	ld hl, 0
	ld h, (iy)
	dec hl
	jr .Ltransform_exit_ready
.Ltransform_exit_south:
	/* South face: x = (tile_x + 1) * 256 + 1. */
	ld hl, 0
	ld h, (iy)
	inc h
	inc hl
	jr .Ltransform_exit_ready
.Ltransform_exit_west:
	/* West face: y = tile_y * 256 - 1. */
	ld de, 0
	ld d, (iy + 1)
	dec de
.Ltransform_exit_ready:
	ld iy, (ix + 12)
	ld (iy), hl
	ld iy, (ix + 15)
	ld (iy), de

	ld a, (_render_transform_rotation)
	pop ix
	ret

/* HL=x, DE=y, A=-1/0/1/2; returns the rotated pair. */
.Lrotate_pair:
	or a, a
	ret z
	cp a, 1
	jr z, .Lrotate_positive
	cp a, 2
	jr z, .Lrotate_half
	/* -90 degrees: (x, y) -> (y, -x). */
	ex de, hl
	push hl
	ex de, hl
	call .Lnegate_hl
	push hl
	pop de
	pop hl
	ret
.Lrotate_positive:
	/* +90 degrees: (x, y) -> (-y, x). */
	ex de, hl
	call .Lnegate_hl
	ret
.Lrotate_half:
	/* 180 degrees: (x, y) -> (-x, -y). */
	call .Lnegate_hl
	push hl
	ex de, hl
	call .Lnegate_hl
	push hl
	pop de
	pop hl
	ret
.Lnegate_hl:
	push de
	push hl
	pop de
	or a, a
	sbc hl, hl
	sbc hl, de
	pop de
	ret

	.size _render_asm_transform_ray, .-_render_asm_transform_ray

	.section .text._render_asm_portal_opening,"ax",@progbits
	.global _render_asm_portal_opening
	.type _render_asm_portal_opening, @function

/* Exact portal ellipse height using two native 8x8 MLT operations. */
_render_asm_portal_opening:
	call __frameset0
	ld iy, (ix + 6)
	ld a, (iy + RAY_WALL_U)
	ld de, 0
	ld e, a
	ld hl, _render_portal_profile_by_u
	add hl, de
	ld a, (hl)
	ld (_render_opening_profile), a

	/* half_height = profile * full_height >> 8. */
	ld iy, (ix + 9)
	ld bc, 0
	ld b, a
	ld c, (iy)
	ld de, 0
	ld d, a
	ld e, (iy + 1)
	mlt bc
	mlt de
	ld hl, 0
	ld l, b
	add hl, de

	ld a, (iy + 7)
	sub a, (iy + 2)
	ld (_render_opening_visible), a

	/* Preserve the C renderer's two-pixel minimum for a visible portal. */
	ld a, (_render_opening_profile)
	or a, a
	jr z, .Lopening_limit_max
	ld a, (_render_opening_visible)
	cp a, 2
	jr c, .Lopening_limit_max
	ld a, h
	or a, a
	jr nz, .Lopening_limit_max
	ld a, l
	cp a, 2
	jr nc, .Lopening_limit_max
	ld hl, 2

.Lopening_limit_max:
	ld a, h
	or a, a
	jr nz, .Lopening_clamp
	ld a, (_render_opening_visible)
	ld b, a
	ld a, l
	cp a, b
	jr c, .Lopening_limited
	jr z, .Lopening_limited
.Lopening_clamp:
	ld hl, 0
	ld a, (_render_opening_visible)
	ld l, a
.Lopening_limited:
	push hl
	pop bc

	/* The shared scale profile already carries its exact centered row. */
	ld iy, (ix + 9)
	ld hl, 0
	ld l, (iy + 7)
	push hl
	pop de
	or a, a
	sbc hl, bc
	ld iy, (ix + 12)
	ld (iy), l
	push de
	pop hl
	add hl, bc
	ld iy, (ix + 15)
	ld (iy), l

	pop ix
	ret

	.size _render_asm_portal_opening, .-_render_asm_portal_opening

	.section .rodata.render_portal_rotation,"a",@progbits
.Lportal_rotation_table:
	.byte 2, 0, -1, 1
	.byte 0, 2, 1, -1
	.byte 1, -1, 2, 0
	.byte -1, 1, 0, 2

	.section .text._render_asm_draw_wall_segment,"ax",@progbits
	.global _render_asm_draw_wall_segment
	.type _render_asm_draw_wall_segment, @function

/*
 * Draw one four-pixel textured wall column.
 *
 * This consumes the same pre-scaled boundary and identical-texel run tables
 * as the C renderer, but the hot loop has no stack locals, helper calls,
 * division, or per-pixel texture-coordinate math.
 *
 * C ABI stack slots after __frameset0:
 *   ix+6  RayHit *       ix+9  x
 *   ix+12 start          ix+15 end
 *   ix+18 WallContext *
 */
_render_asm_draw_wall_segment:
	call __frameset0
	ld a, (ix + 12)
	ld b, a
	ld a, (ix + 15)
	cp a, b
	jp c, .Lspan_return
	jp z, .Lspan_return
	ld (_render_span_end), a
	ld a, b
	ld (_render_span_y), a

	ld iy, (ix + 6)

	/* Select and mirror the 16-byte column exactly like the C sampler. */
	ld a, (iy + RAY_WALL_U)
	and a, 0xF0
	ld c, a
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Lspan_mirror_y
	ld a, (iy + RAY_STEP_X)
	cp a, 1
	jr nz, .Lspan_mirror_done
	jr .Lspan_mirror
.Lspan_mirror_y:
	bit 7, (iy + RAY_STEP_Y)
	jr z, .Lspan_mirror_done
.Lspan_mirror:
	ld a, 0xF0
	sub a, c
	ld c, a
.Lspan_mirror_done:

	/* A stable two-bit cell hash selects one of four fully shaded materials. */
	ld a, (iy + RAY_MAP_X)
	xor a, (iy + RAY_MAP_Y)
	and a, 3
	ld (_render_span_material), a

	ld hl, 0
	ld l, c
	ld h, a
	add hl, hl
	ld de, _render_wall_texture_runs
	add hl, de
	ld (_render_span_texture), hl

	/* The shared scale profile carries its absolute-Y boundary pointer. */
	ld iy, (ix + 18)
	ld hl, (iy + 4)
	ld (_render_span_boundaries), hl
	/* Heights >=16 have strictly increasing boundaries until the visible
	 * end, so descriptor.next_index is already the next visible source row. */
	ld a, (iy + 1)
	or a, a
	jr nz, .Lspan_mark_strict_boundaries
	ld a, (iy)
	cp a, 16
	jr c, .Lspan_boundaries_ready
.Lspan_mark_strict_boundaries:
	ld a, (_render_span_material)
	or a, 0x80
	ld (_render_span_material), a
.Lspan_boundaries_ready:
	ld iy, (ix + 6)

	/* Material base + distance/side shade selects one 32-byte color bank. */
	ld b, (iy + RAY_SIDE)
	ld a, (iy + RAY_DISTANCE + 2)
	or a, a
	jr nz, .Lspan_shade_far
	ld hl, (iy + RAY_DISTANCE)
	dec hl
	ld a, h
	cp a, 8
	jr nc, .Lspan_shade_far
	cp a, 4
	jr c, .Lspan_shade_ready
	inc b
	jr .Lspan_shade_ready
.Lspan_shade_far:
	inc b
	inc b
.Lspan_shade_ready:
	/* ((material << 2) | shade) * 32 selects the exact color bank. */
	ld a, (_render_span_material)
	add a, a
	add a, a
	or a, b
	ld de, 0
	ld d, a
	ld e, 32
	mlt de
	ld hl, _render_wall_colors
	add hl, de
	ld (_render_span_colors), hl

	/* draw-buffer pointer + x + the shared padded row-offset lookup. */
	ld iy, (0xE30014)
	ld de, (ix + 9)
	add iy, de
	ld hl, 0
	ld l, (ix + 12)
	add hl, hl
	add hl, hl
	ld de, _render_screen_rows
	add hl, de
	ld de, (hl)
	add iy, de

	/* Find the first visible source row in the pre-scaled boundary profile. */
	ld a, (_render_span_y)
	ld c, a
	ld b, 0
	ld hl, (_render_span_boundaries)
	/* An unclipped wall begins at boundary[0], so source row zero is exact. */
	cp a, (hl)
	jr z, .Lspan_initial_ready
.Lspan_initial_seek:
	ld a, b
	cp a, 15
	jr nc, .Lspan_initial_ready
	inc hl
	ld a, c
	cp a, (hl)
	jr c, .Lspan_initial_ready
	inc b
	jr .Lspan_initial_seek
.Lspan_initial_ready:
	ld a, b
	ld (_render_span_texture_index), a

.Lspan_outer:
	ld a, (_render_span_y)
	ld b, a
	ld a, (_render_span_end)
	cp a, b
	jp c, .Lspan_return
	jp z, .Lspan_return

	/* Color byte offset, identical-source run end, and scaled screen run end. */
	ld de, 0
	ld a, (_render_span_texture_index)
	add a, a
	ld e, a
	ld hl, (_render_span_texture)
	add hl, de
	ld bc, (hl)
	ld a, c
	ld (_render_span_texel), a
	ld a, b
	ld (_render_span_next_index), a
	ld e, a
	ld hl, (_render_span_boundaries)
	add hl, de
	ld a, (hl)
	ld b, a
	ld a, (_render_span_end)
	cp a, b
	jr nc, .Lspan_run_clamped
	ld b, a
.Lspan_run_clamped:
	ld a, b
	ld (_render_span_next_y), a
	ld a, (_render_span_y)
	ld c, a
	ld a, b
	sub a, c
	ld (_render_span_run_length), a

	/* Four adjacent palette pixels are packed into one 24-bit + one byte write. */
	ld de, 0
	ld a, (_render_span_texel)
	ld e, a
	ld hl, (_render_span_colors)
	add hl, de
	ld hl, (hl)
	ld de, 320
	/* Write an odd leading row, then retire two rows per loop branch. */
	ld a, (_render_span_run_length)
	srl a
	ld b, a
	jr z, .Lspan_write_single
	jr nc, .Lspan_write_pairs_ready
	ld a, l
	ld (iy), hl
	ld (iy + 3), a
	add iy, de

.Lspan_write_pairs_ready:
	ld a, l
.Lspan_write_pair:
	ld (iy), hl
	ld (iy + 3), a
	add iy, de
	ld (iy), hl
	ld (iy + 3), a
	add iy, de
	djnz .Lspan_write_pair
	jr .Lspan_write_done
.Lspan_write_single:
	ld a, l
	ld (iy), hl
	ld (iy + 3), a
	add iy, de
.Lspan_write_done:
	/* Advance past any collapsed source rows before drawing the next run. */
	ld a, (_render_span_next_y)
	ld (_render_span_y), a
	ld c, a
	ld b, a
	ld a, (_render_span_end)
	cp a, b
	jp z, .Lspan_return
	ld a, (_render_span_next_index)
	ld b, a
	ld a, (_render_span_material)
	bit 7, a
	jr nz, .Lspan_advance_done
	ld de, 0
	ld e, b
	ld hl, (_render_span_boundaries)
	add hl, de
.Lspan_advance_texture:
	ld a, b
	cp a, 15
	jr nc, .Lspan_advance_done
	inc hl
	ld a, c
	cp a, (hl)
	jr c, .Lspan_advance_done
	inc b
	jr .Lspan_advance_texture
.Lspan_advance_done:
	ld a, b
	ld (_render_span_texture_index), a
	jp .Lspan_outer

.Lspan_return:
	pop ix
	ret

	.size _render_asm_draw_wall_segment, .-_render_asm_draw_wall_segment

	.section .text._render_asm_draw_solid_segment,"ax",@progbits
	.global _render_asm_draw_solid_segment
	.type _render_asm_draw_solid_segment, @function

/* Draw a clipped four-pixel solid vertical span without GraphX state calls. */
_render_asm_draw_solid_segment:
	call __frameset0
	ld a, (ix + 9)
	ld b, a
	ld a, (ix + 12)
	cp a, b
	jr c, .Lsolid_return
	jr z, .Lsolid_return
	sub a, b
	ld c, a

	/* draw-buffer pointer + x + the shared padded row-offset lookup. */
	ld iy, (0xE30014)
	ld de, (ix + 6)
	add iy, de
	ld hl, 0
	ld l, (ix + 9)
	add hl, hl
	add hl, hl
	ld de, _render_screen_rows
	add hl, de
	ld de, (hl)
	add iy, de

	ld a, (ix + 15)
	ld de, 320
	ld b, c
	/* Write an odd leading row, then retire two rows per loop branch. */
	srl b
	jr z, .Lsolid_single
	jr nc, .Lsolid_pairs_ready
	ld (iy), a
	ld (iy + 1), a
	ld (iy + 2), a
	ld (iy + 3), a
	add iy, de

.Lsolid_pairs_ready:
.Lsolid_pair_loop:
	ld (iy), a
	ld (iy + 1), a
	ld (iy + 2), a
	ld (iy + 3), a
	add iy, de
	ld (iy), a
	ld (iy + 1), a
	ld (iy + 2), a
	ld (iy + 3), a
	add iy, de
	djnz .Lsolid_pair_loop
	jr .Lsolid_return
.Lsolid_single:
	ld (iy), a
	ld (iy + 1), a
	ld (iy + 2), a
	ld (iy + 3), a
	add iy, de
.Lsolid_return:
	pop ix
	ret

	.size _render_asm_draw_solid_segment, .-_render_asm_draw_solid_segment

	.section .text._render_asm_draw_portal_mask,"ax",@progbits
	.global _render_asm_draw_portal_mask
	.type _render_asm_draw_portal_mask, @function

/*
 * Draw one complete clipped portal mask in a single C/assembly transition.
 * Texture/material/shade setup is shared by its upper and lower wall ranges;
 * the two tiny ring ranges use the same direct four-pixel writer as the
 * standalone solid-span routine.
 *
 * C ABI stack slots after __frameset0:
 *   ix+6  RayHit *       ix+9  WallContext *
 *   ix+12 x              ix+15 clip start
 *   ix+18 clip end       ix+21 opening top
 *   ix+24 opening bottom
 */
_render_asm_draw_portal_mask:
	call __frameset0
	ld iy, (ix + 6)

	/* Select and mirror the 16-byte texture column. */
	ld a, (iy + RAY_WALL_U)
	and a, 0xF0
	ld c, a
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Lportal_mask_mirror_y
	ld a, (iy + RAY_STEP_X)
	cp a, 1
	jr nz, .Lportal_mask_mirror_done
	jr .Lportal_mask_mirror
.Lportal_mask_mirror_y:
	bit 7, (iy + RAY_STEP_Y)
	jr z, .Lportal_mask_mirror_done
.Lportal_mask_mirror:
	ld a, 0xF0
	sub a, c
	ld c, a
.Lportal_mask_mirror_done:

	ld a, (iy + RAY_MAP_X)
	xor a, (iy + RAY_MAP_Y)
	and a, 3
	ld (_render_span_material), a
	ld hl, 0
	ld l, c
	ld h, a
	add hl, hl
	ld de, _render_wall_texture_runs
	add hl, de
	ld (_render_span_texture), hl

	ld iy, (ix + 9)
	ld hl, (iy + 4)
	ld (_render_span_boundaries), hl
	ld a, (iy + 1)
	or a, a
	jr nz, .Lportal_mask_mark_strict_boundaries
	ld a, (iy)
	cp a, 16
	jr c, .Lportal_mask_boundaries_ready
.Lportal_mask_mark_strict_boundaries:
	ld a, (_render_span_material)
	or a, 0x80
	ld (_render_span_material), a
.Lportal_mask_boundaries_ready:
	ld iy, (ix + 6)

	/* Select the same material/shade color bank as the wall-span entry. */
	ld b, (iy + RAY_SIDE)
	ld a, (iy + RAY_DISTANCE + 2)
	or a, a
	jr nz, .Lportal_mask_shade_far
	ld hl, (iy + RAY_DISTANCE)
	dec hl
	ld a, h
	cp a, 8
	jr nc, .Lportal_mask_shade_far
	cp a, 4
	jr c, .Lportal_mask_shade_ready
	inc b
	jr .Lportal_mask_shade_ready
.Lportal_mask_shade_far:
	inc b
	inc b
.Lportal_mask_shade_ready:
	ld a, (_render_span_material)
	add a, a
	add a, a
	or a, b
	ld de, 0
	ld d, a
	ld e, 32
	mlt de
	ld hl, _render_wall_colors
	add hl, de
	ld (_render_span_colors), hl

	/* Translate the portal kind to the palette index used by portal_color(). */
	ld a, (iy + RAY_PORTAL_KIND)
	cp a, 1
	jr z, .Lportal_mask_primary
	cp a, 2
	jr z, .Lportal_mask_secondary
	ld a, 15
	jr .Lportal_mask_color_ready
.Lportal_mask_primary:
	ld a, 13
	jr .Lportal_mask_color_ready
.Lportal_mask_secondary:
	ld a, 14
.Lportal_mask_color_ready:
	ld (_render_portal_ring_color), a

	/* thickness = opening height >= 8 ? 2 : 1. */
	ld a, (ix + 24)
	ld b, a
	ld a, (ix + 21)
	ld c, a
	ld a, b
	sub a, c
	ld d, 1
	cp a, 8
	jr c, .Lportal_mask_thickness_ready
	inc d
.Lportal_mask_thickness_ready:

	/* top_end is clipped to the projected wall, but the collapse test uses
	 * the unclipped top + thickness exactly like the C compositor. */
	ld a, (ix + 21)
	add a, d
	ld (_render_portal_top_limit), a
	ld b, a
	ld iy, (ix + 9)
	ld a, (iy + 3)
	cp a, b
	jr nc, .Lportal_mask_top_end_ready
	ld b, a
.Lportal_mask_top_end_ready:
	ld a, b
	ld (_render_portal_top_end), a

	ld a, (_render_portal_top_limit)
	ld b, (ix + 24)
	cp a, b
	jr nc, .Lportal_mask_collapsed

	/* bottom_start = max(bottom - thickness, context->start). */
	ld a, (ix + 24)
	sub a, d
	ld b, a
	ld a, (iy + 2)
	cp a, b
	jr c, .Lportal_mask_bottom_start_ready
	jr z, .Lportal_mask_bottom_start_ready
	ld b, a
.Lportal_mask_bottom_start_ready:
	ld a, b
	ld (_render_portal_bottom_start), a

	/* Upper texture, upper ring, lower ring, lower texture.  Each helper
	 * performs the identical half-open aperture clipping as its C caller. */
	ld b, (iy + 2)
	ld c, (ix + 21)
	call .Lportal_mask_draw_texture_range
	ld b, (ix + 21)
	ld a, (_render_portal_top_end)
	ld c, a
	call .Lportal_mask_draw_solid_range
	ld a, (_render_portal_bottom_start)
	ld b, a
	ld c, (ix + 24)
	call .Lportal_mask_draw_solid_range
	ld b, (ix + 24)
	ld iy, (ix + 9)
	ld a, (iy + 3)
	ld c, a
	call .Lportal_mask_draw_texture_range
	jr .Lportal_mask_return

.Lportal_mask_collapsed:
	/* Degenerate opening: redraw the complete wall, then overlay one ring. */
	ld iy, (ix + 9)
	ld b, (iy + 2)
	ld c, (iy + 3)
	call .Lportal_mask_draw_texture_range
	ld b, (ix + 21)
	ld a, (_render_portal_top_end)
	ld c, a
	call .Lportal_mask_draw_solid_range

.Lportal_mask_return:
	pop ix
	ret

/* Draw a texture range passed in B=start, C=end after aperture clipping.
 * The parent entry has already prepared every texture/shade pointer. */
.Lportal_mask_draw_texture_range:
	ld a, b
	ld d, (ix + 15)
	cp a, d
	jr nc, .Lportal_mask_texture_start_ready
	ld b, d
.Lportal_mask_texture_start_ready:
	ld a, c
	ld d, (ix + 18)
	cp a, d
	jr c, .Lportal_mask_texture_end_ready
	jr z, .Lportal_mask_texture_end_ready
	ld c, d
.Lportal_mask_texture_end_ready:
	ld a, c
	cp a, b
	ret c
	ret z
	ld (_render_span_end), a
	ld a, b
	ld (_render_span_y), a

	ld iy, (0xE30014)
	ld de, (ix + 12)
	add iy, de
	ld hl, 0
	ld l, b
	add hl, hl
	add hl, hl
	ld de, _render_screen_rows
	add hl, de
	ld de, (hl)
	add iy, de

	ld a, (_render_span_y)
	ld c, a
	ld b, 0
	ld hl, (_render_span_boundaries)
	/* The upper mask range commonly begins at the full wall boundary. */
	cp a, (hl)
	jr z, .Lportal_mask_initial_ready
.Lportal_mask_initial_seek:
	ld a, b
	cp a, 15
	jr nc, .Lportal_mask_initial_ready
	inc hl
	ld a, c
	cp a, (hl)
	jr c, .Lportal_mask_initial_ready
	inc b
	jr .Lportal_mask_initial_seek
.Lportal_mask_initial_ready:
	ld a, b
	ld (_render_span_texture_index), a

.Lportal_mask_texture_outer:
	ld a, (_render_span_y)
	ld b, a
	ld a, (_render_span_end)
	cp a, b
	ret c
	ret z

	ld de, 0
	ld a, (_render_span_texture_index)
	add a, a
	ld e, a
	ld hl, (_render_span_texture)
	add hl, de
	ld bc, (hl)
	ld a, c
	ld (_render_span_texel), a
	ld a, b
	ld (_render_span_next_index), a
	ld e, a
	ld hl, (_render_span_boundaries)
	add hl, de
	ld a, (hl)
	ld b, a
	ld a, (_render_span_end)
	cp a, b
	jr nc, .Lportal_mask_run_clamped
	ld b, a
.Lportal_mask_run_clamped:
	ld a, b
	ld (_render_span_next_y), a
	ld a, (_render_span_y)
	ld c, a
	ld a, b
	sub a, c
	ld (_render_span_run_length), a

	ld de, 0
	ld a, (_render_span_texel)
	ld e, a
	ld hl, (_render_span_colors)
	add hl, de
	ld hl, (hl)
	ld de, 320
	ld a, (_render_span_run_length)
	srl a
	ld b, a
	jr z, .Lportal_mask_write_single
	jr nc, .Lportal_mask_write_pairs_ready
	ld a, l
	ld (iy), hl
	ld (iy + 3), a
	add iy, de

.Lportal_mask_write_pairs_ready:
	ld a, l
.Lportal_mask_write_pair:
	ld (iy), hl
	ld (iy + 3), a
	add iy, de
	ld (iy), hl
	ld (iy + 3), a
	add iy, de
	djnz .Lportal_mask_write_pair
	jr .Lportal_mask_write_done
.Lportal_mask_write_single:
	ld a, l
	ld (iy), hl
	ld (iy + 3), a
	add iy, de
.Lportal_mask_write_done:
	ld a, (_render_span_next_y)
	ld (_render_span_y), a
	ld c, a
	ld b, a
	ld a, (_render_span_end)
	cp a, b
	ret z
	ld a, (_render_span_next_index)
	ld b, a
	ld a, (_render_span_material)
	bit 7, a
	jr nz, .Lportal_mask_advance_done
	ld de, 0
	ld e, b
	ld hl, (_render_span_boundaries)
	add hl, de
.Lportal_mask_advance_texture:
	ld a, b
	cp a, 15
	jr nc, .Lportal_mask_advance_done
	inc hl
	ld a, c
	cp a, (hl)
	jr c, .Lportal_mask_advance_done
	inc b
	jr .Lportal_mask_advance_texture
.Lportal_mask_advance_done:
	ld a, b
	ld (_render_span_texture_index), a
	jp .Lportal_mask_texture_outer

/* Draw a solid range passed in B=start, C=end after aperture clipping. */
.Lportal_mask_draw_solid_range:
	ld a, b
	ld d, (ix + 15)
	cp a, d
	jr nc, .Lportal_mask_solid_start_ready
	ld b, d
.Lportal_mask_solid_start_ready:
	ld a, c
	ld d, (ix + 18)
	cp a, d
	jr c, .Lportal_mask_solid_end_ready
	jr z, .Lportal_mask_solid_end_ready
	ld c, d
.Lportal_mask_solid_end_ready:
	ld a, c
	cp a, b
	ret c
	ret z
	sub a, b
	ld c, a

	ld iy, (0xE30014)
	ld de, (ix + 12)
	add iy, de
	ld hl, 0
	ld l, b
	add hl, hl
	add hl, hl
	ld de, _render_screen_rows
	add hl, de
	ld de, (hl)
	add iy, de

	/* A portal ring is one or two rows; clipping cannot increase that span. */
	ld a, (_render_portal_ring_color)
	ld (iy), a
	ld (iy + 1), a
	ld (iy + 2), a
	ld (iy + 3), a
	dec c
	ret z
	ld de, 320
	add iy, de
	ld (iy), a
	ld (iy + 1), a
	ld (iy + 2), a
	ld (iy + 3), a
	ret

	.size _render_asm_draw_portal_mask, .-_render_asm_draw_portal_mask

	.section .bss.render_asm_scratch,"aw",@nobits
	.local _render_asm_qx
_render_asm_qx:
	.zero 3
	.local _render_asm_qy
_render_asm_qy:
	.zero 3
	.local _render_asm_abs_x_shift
_render_asm_abs_x_shift:
	.zero 1
	.local _render_asm_abs_x
_render_asm_abs_x:
	.zero 3
	.local _render_asm_abs_y_shift
_render_asm_abs_y_shift:
	.zero 1
	.local _render_asm_abs_y
_render_asm_abs_y:
	.zero 3
	.local _render_asm_axis_boundary
_render_asm_axis_boundary:
	.zero 1
	.local _render_grid_lateral_magnitude
_render_grid_lateral_magnitude:
	.zero 3
	.local _render_grid_project_negative
_render_grid_project_negative:
	.zero 1
	.local _render_grid_near_x
_render_grid_near_x:
	.zero 3
	.local _render_grid_far_x
_render_grid_far_x:
	.zero 3
	.local _render_span_texture
_render_span_texture:
	.zero 3
	.local _render_span_boundaries
_render_span_boundaries:
	.zero 3
	.local _render_span_colors
_render_span_colors:
	.zero 3
	.local _render_span_end
_render_span_end:
	.zero 1
	.local _render_span_y
_render_span_y:
	.zero 1
	.local _render_span_texture_index
_render_span_texture_index:
	.zero 1
	.local _render_span_next_index
_render_span_next_index:
	.zero 1
	.local _render_span_next_y
_render_span_next_y:
	.zero 1
	.local _render_span_run_length
_render_span_run_length:
	.zero 1
	.local _render_span_material
_render_span_material:
	.zero 1
	.local _render_span_texel
_render_span_texel:
	.zero 1
	.local _render_transform_local_x
_render_transform_local_x:
	.zero 3
	.local _render_transform_local_y
_render_transform_local_y:
	.zero 3
	.local _render_transform_rotation
_render_transform_rotation:
	.zero 1
	.local _render_opening_profile
_render_opening_profile:
	.zero 1
	.local _render_opening_visible
_render_opening_visible:
	.zero 1
	.local _render_portal_ring_color
_render_portal_ring_color:
	.zero 1
	.local _render_portal_top_limit
_render_portal_top_limit:
	.zero 1
	.local _render_portal_top_end
_render_portal_top_end:
	.zero 1
	.local _render_portal_bottom_start
_render_portal_bottom_start:
	.zero 1

	.extern _render_wall_map
	.extern _render_wall_texture_runs
	.extern _render_wall_colors
	.extern _render_screen_rows
	.extern _render_builtin_portal_by_tile
	.extern _render_builtin_portals
	.extern _render_portal_profile_by_u
	.extern _render_reciprocal_delta
	.extern _render_grid_near_projection
	.extern _grid_far_projection
	.extern _gfx_HorizLine_NoClip
	.extern _gfx_Line_NoClip
	.extern _gfx_Line
	.extern __frameset0

	.section ".note.GNU-stack","",@progbits
