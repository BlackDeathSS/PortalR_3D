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
	.equ STATE_ORIGIN_X, 0
	.equ STATE_ORIGIN_Y, 3
	.equ STATE_RAY_X, 6
	.equ STATE_RAY_Y, 9
	.equ STATE_DELTA_X, 12
	.equ STATE_DELTA_Y, 15
	.equ STATE_QX, 18
	.equ STATE_QY, 21
	.equ STATE_ABS_X_SHIFT, 24
	.equ STATE_ABS_X, 25
	.equ STATE_ABS_Y_SHIFT, 27
	.equ STATE_ABS_Y, 28
	.equ STATE_ABS_END, 30
	.equ STATE_THRESHOLD, 31
	.equ STATE_MAP_STEP_X, 34
	.equ STATE_MAP_STEP_Y, 37
	.equ STATE_HIT, 40
	.equ STATE_GAME, 43
	.equ STATE_PRIMARY_TILE, 46
	.equ STATE_SECONDARY_TILE, 47
	.equ STATE_PORTAL_EXIT, 48
	.equ STATE_PORTAL_KIND, 52
	.equ STATE_PORTAL_ID, 53
	.equ STATE_PORTAL_HAS_EXIT, 54
	.equ STATE_SIZE, 55
	.equ PLAN_TANGENT_BASE, 0
	.equ PLAN_NORMAL, 3
	.equ PLAN_FLAGS, 6
	.equ PLAN_TANGENT_TO_X, 7
	.equ GRID_FAR_X, 0
	.equ GRID_NEAR_X, 2
	.equ GRID_PROJECTION_POSITIVE_LIMIT, 0
	.equ GRID_PROJECTION_NEGATIVE_LIMIT, 3
	.equ GRID_PROJECTION_HEIGHT, 6
	.equ GRID_PROJECTION_SCREEN_Y, 8
	.equ GRID_NEAR_SCREEN_Y, 238
	.equ GRID_FAR_SCREEN_Y, 127
	.equ GRID_CEILING_NEAR_SCREEN_Y, 2
	.equ GRID_CEILING_FAR_SCREEN_Y, 113
	.equ GRID_FLOOR_COLOR, 4
	.equ GRID_CEILING_COLOR, 17
	.equ GRID_HORIZONTAL_BYTES, 320
	.equ GRID_HORIZONTAL_PUSHES, 106
	.equ GRID_HORIZONTAL_HEAD_BYTES, 2
	.equ BACKGROUND_HORIZON_COLOR, 2
	.equ BACKGROUND_FLOOR_COLOR, 3
	.equ BACKGROUND_CEILING_COLOR, 16
	.equ BACKGROUND_BUFFER_BYTES, 76800
	.equ BACKGROUND_CEILING_BYTES, 35840
	.equ BACKGROUND_HORIZON_BYTES, 5120
	.equ BACKGROUND_FLOOR_BYTES, 35840
	.equ BACKGROUND_PUSHES_PER_ITER, 115
	.equ BACKGROUND_FLOOR_ITERS, 103
	.equ BACKGROUND_FLOOR_TAIL, 101
	.equ BACKGROUND_HORIZON_ITERS, 14
	.equ BACKGROUND_HORIZON_TAIL, 96
	.equ BACKGROUND_CEILING_ITERS, 103
	.equ BACKGROUND_CEILING_TAIL, 101
	.equ BACKGROUND_REPAIR_TOP_OFFSET, 35840
	.equ BACKGROUND_REPAIR_TOP_BYTES, 640
	.equ BACKGROUND_REPAIR_BOTTOM_OFFSET, 40640
	.equ BACKGROUND_REPAIR_BOTTOM_BYTES, 320

	.section .text._render_asm_cast_wall_begin,"ax",@progbits
	.global _render_asm_cast_wall_begin
	.global _render_asm_cast_wall_continue
	.type _render_asm_cast_wall_begin, @function
	.type _render_asm_cast_wall_continue, @function

/*
 * Persistent exact 8.8 grid DDA for the C renderer.
 *
 * Begin ABI stack slots after __frameset0:
 *   ix+6  origin_x       ix+9  origin_y
 *   ix+12 ray_x          ix+15 ray_y
 *   ix+18 RayHit *
 *
 * Continue has only ix+6 RayHit *.  Ray direction, reciprocal deltas,
 * magnitudes, threshold, origin, and signed map strides persist in the fixed
 * state block.  Portal transforms rotate that block between continuations.
 *
 * The generic loop keeps its exact modular recurrence in HL/BC/DE, the
 * RayHit pointer in IY, and the current padded-map pointer in shadow HL.
 * The specialized exact-axis paths step the map directly because projection
 * distance is reconstructed after the hit.
 */
_render_asm_cast_wall_begin:
	call __frameset0

	/* Seed the persistent values once for this logical screen ray. */
	ld hl, (ix + 6)
	ld (_render_ray_state + STATE_ORIGIN_X), hl
	ld hl, (ix + 9)
	ld (_render_ray_state + STATE_ORIGIN_Y), hl
	ld hl, (ix + 12)
	ld (_render_ray_state + STATE_RAY_X), hl
	ld a, (ix + 14)
	ld iy, _render_ray_state + STATE_ABS_X
	call .Lstate_component_init
	ld (_render_ray_state + STATE_DELTA_X), hl
	ld hl, (ix + 15)
	ld (_render_ray_state + STATE_RAY_Y), hl
	ld a, (ix + 17)
	ld iy, _render_ray_state + STATE_ABS_Y
	call .Lstate_component_init
	ld (_render_ray_state + STATE_DELTA_Y), hl

	/* T=(abs_x+abs_y)<<8 is invariant under every portal rotation. */
	ld hl, (_render_ray_state + STATE_ABS_X_SHIFT)
	ld de, (_render_ray_state + STATE_ABS_Y_SHIFT)
	add hl, de
	ld (_render_ray_state + STATE_THRESHOLD), hl

	/* Zero components retain the legacy positive map stride. */
	ld hl, 1
	ld a, (_render_ray_state + STATE_RAY_X + 2)
	bit 7, a
	jr z, .Lbegin_step_x_ready
	ld hl, -1
.Lbegin_step_x_ready:
	ld (_render_ray_state + STATE_MAP_STEP_X), hl
	ld hl, 16
	ld a, (_render_ray_state + STATE_RAY_Y + 2)
	bit 7, a
	jr z, .Lbegin_step_y_ready
	ld hl, -16
.Lbegin_step_y_ready:
	ld (_render_ray_state + STATE_MAP_STEP_Y), hl

	ld iy, (ix + 18)
	ld (_render_ray_state + STATE_HIT), iy
	jr .Lcast_seed_segment

_render_asm_cast_wall_continue:
	call __frameset0
	ld iy, (ix + 6)
	ld (_render_ray_state + STATE_HIT), iy

.Lcast_seed_segment:
	xor a, a
	ld (_render_asm_axis_boundary), a

	/*
	 * Cache the exact sub-cell distance to each next boundary (qx/qy).  The
	 * persistent positive magnitudes let the generic DDA compare
	 * qx/abs(ray_x) with qy/abs(ray_y) by cross multiplication, so reciprocal
	 * rounding can no longer change which grid face owns a ray.
	 */
	ld hl, 0
	ld a, (_render_ray_state + STATE_ORIGIN_X)
	ld l, a
	ld a, (_render_ray_state + STATE_RAY_X + 2)
	bit 7, a
	jr nz, .Lsetup_qx_store
	ld a, l
	neg
	ld l, a
	jr nz, .Lsetup_qx_store
	inc h
.Lsetup_qx_store:
	ld (_render_ray_state + STATE_QX), hl

	ld hl, 0
	ld a, (_render_ray_state + STATE_ORIGIN_Y)
	ld l, a
	ld a, (_render_ray_state + STATE_RAY_Y + 2)
	bit 7, a
	jr nz, .Lsetup_qy_store
	ld a, l
	neg
	ld l, a
	jr nz, .Lsetup_qy_store
	inc h
.Lsetup_qy_store:
	ld (_render_ray_state + STATE_QY), hl

	ld hl, (_render_ray_state + STATE_RAY_X)
	ld de, 0
	or a, a
	sbc hl, de
	jr nz, .Lsetup_y
	/* A vertical ray on an exact X boundary touches either column only at
	 * zero area.  The axis-only loop below therefore requires both adjacent
	 * columns to be solid before accepting a hit. */
	ld a, (_render_ray_state + STATE_ORIGIN_X)
	or a, a
	jr nz, .Lsetup_y
	ld a, 2
	ld (_render_asm_axis_boundary), a

	/* Y reciprocal delta and exact-axis-boundary detection. */
.Lsetup_y:
	ld hl, (_render_ray_state + STATE_RAY_Y)
	ld de, 0
	or a, a
	sbc hl, de
	jr nz, .Lsetup_error
	/* Symmetric horizontal-boundary ownership. */
	ld a, (_render_ray_state + STATE_ORIGIN_Y)
	or a, a
	jr nz, .Lsetup_error
	ld a, 1
	ld (_render_asm_axis_boundary), a

	/* E = qx*abs(ray_y) - qy*abs(ray_x). */
.Lsetup_error:
	ld a, (_render_asm_axis_boundary)
	or a, a
	jr nz, .Lsetup_map
	ld hl, (_render_ray_state + STATE_QX)
	ld bc, (_render_ray_state + STATE_ABS_Y)
	call .Lmul_q_component
	push hl
	ld hl, (_render_ray_state + STATE_QY)
	ld bc, (_render_ray_state + STATE_ABS_X)
	call .Lmul_q_component
	ex de, hl
	pop hl
	or a, a
	sbc hl, de
	/* U = E + Ax is non-negative:
	 * qx*Ay + (256-qy)*Ax. Preserve U and T=Ax+Ay across map setup. */
	ld de, (_render_ray_state + STATE_ABS_X_SHIFT)
	add hl, de
	push hl
	ld hl, (_render_ray_state + STATE_THRESHOLD)
	push hl

	/* Build the map pointer once; shadow BC/DE retain signed Y/X steps. */
.Lsetup_map:
	ld hl, 0
	ld a, (_render_ray_state + STATE_ORIGIN_Y + 1)
	rlca
	rlca
	rlca
	rlca
	and a, 0xF0
	ld l, a
	ld a, (_render_ray_state + STATE_ORIGIN_X + 1)
	add a, l
	ld l, a
	ld de, _render_wall_map
	add hl, de
	push hl
	exx
	pop hl
	ld bc, (_render_ray_state + STATE_MAP_STEP_Y)
	ld de, (_render_ray_state + STATE_MAP_STEP_X)
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
	ld de, (_render_ray_state + STATE_ABS_Y_SHIFT)
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
	ld a, (_render_ray_state + STATE_RAY_X + 2)
	rlca
	and a, 1
	ld (iy + RAY_WALL_DIRECTION), a
	ld a, (_render_ray_state + STATE_MAP_STEP_X)
	ld (iy + RAY_STEP_X), a
	jr .Lstore_hit

	/* Y wall ownership. */
.Lhit_y:
	ld a, 1
	ld (iy + RAY_SIDE), a
	ld a, (_render_ray_state + STATE_RAY_Y + 2)
	rlca
	and a, 1
	add a, DIR_WEST
	ld (iy + RAY_WALL_DIRECTION), a
	ld a, (_render_ray_state + STATE_MAP_STEP_Y)
	/* The low byte of +/-16 has the sign needed by the RayHit field. */
	bit 7, a
	jr z, .Lhit_y_positive_step
	ld a, -1
	jr .Lhit_y_step_ready
.Lhit_y_positive_step:
	ld a, 1
.Lhit_y_step_ready:
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

	ld hl, (_render_ray_state + STATE_DELTA_X)
	ld bc, (_render_ray_state + STATE_QX)
	ld a, b
	or a, a
	jr nz, .Ldistance_initial_x_ready
	ld a, c
	call .Lscale_delta_8
.Ldistance_initial_x_ready:
	ld de, (_render_ray_state + STATE_DELTA_X)
	ld a, (iy + RAY_MAP_X)
	ld c, a
	ld a, (_render_ray_state + STATE_ORIGIN_X + 1)
	ld b, a
	ld a, (_render_ray_state + STATE_RAY_X + 2)
	bit 7, a
	ld a, c
	jr z, .Ldistance_x_positive
	ld a, b
	sub a, c
	jr .Ldistance_count_ready
.Ldistance_x_positive:
	sub a, b
	jr .Ldistance_count_ready

.Ldistance_rebuild_y:
	ld hl, (_render_ray_state + STATE_DELTA_Y)
	ld bc, (_render_ray_state + STATE_QY)
	ld a, b
	or a, a
	jr nz, .Ldistance_initial_y_ready
	ld a, c
	call .Lscale_delta_8
.Ldistance_initial_y_ready:
	ld de, (_render_ray_state + STATE_DELTA_Y)
	ld a, (iy + RAY_MAP_Y)
	ld c, a
	ld a, (_render_ray_state + STATE_ORIGIN_Y + 1)
	ld b, a
	ld a, (_render_ray_state + STATE_RAY_Y + 2)
	bit 7, a
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
	ld bc, (_render_ray_state + STATE_RAY_Y)
	call .Lmul_distance_ray
	ld de, (_render_ray_state + STATE_ORIGIN_Y)
	add hl, de
	jr .Lwall_position_store

	/* Y wall position uses origin_x + distance * ray_x / 256. */
.Lwall_position_y:
	ld bc, (_render_ray_state + STATE_RAY_X)
	call .Lmul_distance_ray
	ld de, (_render_ray_state + STATE_ORIGIN_X)
	add hl, de

.Lwall_position_store:
	ld iy, (_render_ray_state + STATE_HIT)
	ld (iy + RAY_WALL_POSITION), hl
	ld a, l
	ld (iy + RAY_WALL_U), a
	call .Lstate_resolve_portal
	pop ix
	ret

	/*
	 * Resolve the wall face while the hit is still resident in IY.  The old
	 * path returned to C, repeated the tile key, pushed seven ABI slots, and
	 * entered _render_asm_find_portal.  C caches the two dynamic portal tile
	 * keys once per render/placement trace; ordinary walls therefore retain
	 * the same three-lookup fast rejection, while candidate faces leave the
	 * linked exit directly beside the persistent DDA state.
	 */
.Lstate_resolve_portal:
	xor a, a
	ld (_render_ray_state + STATE_PORTAL_KIND), a
	ld (_render_ray_state + STATE_PORTAL_HAS_EXIT), a

	ld a, (iy + RAY_WALL_DIRECTION)
	ld b, a
	ld a, (iy + RAY_MAP_Y)
	add a, a
	add a, a
	add a, a
	add a, a
	add a, (iy + RAY_MAP_X)
	ld c, a

	ld a, (_render_ray_state + STATE_PRIMARY_TILE)
	cp a, c
	jr z, .Lstate_portal_try_primary
	ld a, (_render_ray_state + STATE_SECONDARY_TILE)
	cp a, c
	jr z, .Lstate_portal_try_secondary_load
	jr .Lstate_portal_try_builtin

.Lstate_portal_try_primary:
	push iy
	ld iy, (_render_ray_state + STATE_GAME)
	ld a, (iy + 10)
	cp a, b
	jr nz, .Lstate_portal_try_secondary_loaded
	ld a, 1
	ld (_render_ray_state + STATE_PORTAL_KIND), a
	ld a, (iy + 15)
	or a, a
	jr z, .Lstate_portal_dynamic_return
	ld hl, (iy + 12)
	ld (_render_ray_state + STATE_PORTAL_EXIT), hl
	ld a, (iy + 15)
	ld (_render_ray_state + STATE_PORTAL_EXIT + 3), a
	ld a, 10
	ld (_render_ray_state + STATE_PORTAL_ID), a
	jr .Lstate_portal_dynamic_found

.Lstate_portal_try_secondary_loaded:
	ld a, (_render_ray_state + STATE_SECONDARY_TILE)
	cp a, c
	jr nz, .Lstate_portal_builtin_after_dynamic
	ld a, (iy + 14)
	cp a, b
	jr nz, .Lstate_portal_builtin_after_dynamic
	jr .Lstate_portal_secondary_match

.Lstate_portal_try_secondary_load:
	push iy
	ld iy, (_render_ray_state + STATE_GAME)
	ld a, (iy + 14)
	cp a, b
	jr nz, .Lstate_portal_builtin_after_dynamic

.Lstate_portal_secondary_match:
	ld a, 2
	ld (_render_ray_state + STATE_PORTAL_KIND), a
	ld a, (iy + 11)
	or a, a
	jr z, .Lstate_portal_dynamic_return
	ld hl, (iy + 8)
	ld (_render_ray_state + STATE_PORTAL_EXIT), hl
	ld a, (iy + 11)
	ld (_render_ray_state + STATE_PORTAL_EXIT + 3), a
	ld a, 11
	ld (_render_ray_state + STATE_PORTAL_ID), a

.Lstate_portal_dynamic_found:
	ld a, 1
	ld (_render_ray_state + STATE_PORTAL_HAS_EXIT), a
.Lstate_portal_dynamic_return:
	pop iy
	ret

.Lstate_portal_builtin_after_dynamic:
	pop iy

.Lstate_portal_try_builtin:
	ld hl, _render_builtin_portal_by_tile
	ld de, 0
	ld e, c
	add hl, de
	ld a, (hl)
	or a, a
	ret z
	dec a
	ld c, a
	ld de, 0
	ld d, 6
	ld e, a
	mlt de
	ld hl, _render_builtin_portals
	add hl, de
	inc hl
	inc hl
	ld a, (hl)
	cp a, b
	ret nz
	inc hl
	ld a, (hl)
	ld (_render_ray_state + STATE_PORTAL_EXIT), a
	inc hl
	ld a, (hl)
	ld (_render_ray_state + STATE_PORTAL_EXIT + 1), a
	inc hl
	ld a, (hl)
	ld (_render_ray_state + STATE_PORTAL_EXIT + 2), a
	ld a, 1
	ld (_render_ray_state + STATE_PORTAL_EXIT + 3), a
	ld a, 3
	ld (_render_ray_state + STATE_PORTAL_KIND), a
	ld a, c
	ld (_render_ray_state + STATE_PORTAL_ID), a
	ld a, 1
	ld (_render_ray_state + STATE_PORTAL_HAS_EXIT), a
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

/*
 * Initialize one persistent component. A is the sign byte, HL is signed,
 * and IY points at the state's packed uint16_t magnitude. Return the positive
 * reciprocal delta in HL.
 */
.Lstate_component_init:
	bit 7, a
	jr z, .Lstate_component_magnitude
	ex de, hl
	or a, a
	sbc hl, hl
	sbc hl, de

.Lstate_component_magnitude:
	ld (iy), l
	ld (iy + 1), h
	ld de, 0
	or a, a
	sbc hl, de
	jr z, .Lstate_component_zero

	dec hl
	jr z, .Lstate_component_one
	inc hl

	ld de, 425
	or a, a
	sbc hl, de
	jr c, .Lstate_component_under_limit
	ld hl, 425
	jr .Lstate_component_lookup

.Lstate_component_under_limit:
	add hl, de

.Lstate_component_lookup:
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

.Lstate_component_zero:
	ld hl, FIXED_INF
	ret

.Lstate_component_one:
	ld hl, 65536
	ret

	.size _render_asm_cast_wall_begin, .-_render_asm_cast_wall_begin
	.size _render_asm_cast_wall_continue, .-_render_asm_cast_wall_continue

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
	/*
	 * Pair fully visible floor/ceiling lines in one Bresenham traversal.
	 * A specialized path below reproduces GraphX's sequential clipping for
	 * lines that cross either X edge.
	 */
	ld de, 320
	ld hl, (_render_grid_far_x)
	or a, a
	sbc hl, de
	jr nc, .Lfused_grid_draw_clipped
	ld hl, (_render_grid_near_x)
	or a, a
	sbc hl, de
	jr nc, .Lfused_grid_draw_clipped
	call .Lgrid_draw_pair_noclip
	jp .Lfused_grid_return

.Lfused_grid_draw_clipped:
	/*
	 * Both original Y ranges are already inside the clip rectangle, and a
	 * clipped endpoint is a convex interpolation of them. Therefore GraphX's
	 * Cohen-Sutherland loop can only visit RIGHT or LEFT here. It always clips
	 * endpoint 1 first, then endpoint 0 using the already-rounded endpoint 1.
	 */
	ld a, GRID_FAR_SCREEN_Y
	ld (_render_grid_floor_y0), a
	ld a, GRID_NEAR_SCREEN_Y
	ld (_render_grid_floor_y1), a
	ld a, GRID_CEILING_FAR_SCREEN_Y
	ld (_render_grid_ceiling_y0), a
	ld a, GRID_CEILING_NEAR_SCREEN_Y
	ld (_render_grid_ceiling_y1), a

	/* Match GraphX's endpoint-1-first outcode selection. */
	ld a, (_render_grid_near_x + 2)
	bit 7, a
	jr nz, .Lgrid_clip_near_left
	ld hl, (_render_grid_near_x)
	ld de, 320
	or a, a
	sbc hl, de
	jr c, .Lgrid_clip_far_check
	ld hl, 319
	jr .Lgrid_clip_near
.Lgrid_clip_near_left:
	ld hl, 0
.Lgrid_clip_near:
	ld (_render_grid_clip_bound), hl
	call .Lgrid_clip_pair_endpoint
	ld hl, (_render_grid_clip_bound)
	ld (_render_grid_near_x), hl
	ld a, (_render_grid_clip_floor_result)
	ld (_render_grid_floor_y1), a
	ld a, (_render_grid_clip_ceiling_result)
	ld (_render_grid_ceiling_y1), a

.Lgrid_clip_far_check:
	ld a, (_render_grid_far_x + 2)
	bit 7, a
	jr nz, .Lgrid_clip_far_left
	ld hl, (_render_grid_far_x)
	ld de, 320
	or a, a
	sbc hl, de
	jr c, .Lgrid_clipped_draw
	ld hl, 319
	jr .Lgrid_clip_far
.Lgrid_clip_far_left:
	ld hl, 0
.Lgrid_clip_far:
	ld (_render_grid_clip_bound), hl
	call .Lgrid_clip_pair_endpoint
	ld hl, (_render_grid_clip_bound)
	ld (_render_grid_far_x), hl
	ld a, (_render_grid_clip_floor_result)
	ld (_render_grid_floor_y0), a
	ld a, (_render_grid_clip_ceiling_result)
	ld (_render_grid_ceiling_y0), a

.Lgrid_clipped_draw:
	/*
	 * Draw both already-clipped lines locally. The helper is a direct
	 * translation of GraphX gfx_Line_NoClip, without its ABI transition,
	 * draw-buffer wait, or mutable global color lookup.
	 */
	ld a, GRID_FLOOR_COLOR
	ld (.Lgrid_dynamic_horizontal_color + 1), a
	ld (.Lgrid_dynamic_vertical_color + 1), a
	ld hl, (_render_grid_far_x)
	ld de, (_render_grid_near_x)
	ld a, (_render_grid_floor_y0)
	ld b, a
	ld a, (_render_grid_floor_y1)
	call .Lgrid_draw_dynamic_noclip

	ld a, GRID_CEILING_COLOR
	ld (.Lgrid_dynamic_horizontal_color + 1), a
	ld (.Lgrid_dynamic_vertical_color + 1), a
	ld hl, (_render_grid_far_x)
	ld de, (_render_grid_near_x)
	ld a, (_render_grid_ceiling_y0)
	ld b, a
	ld a, (_render_grid_ceiling_y1)
	call .Lgrid_draw_dynamic_noclip

.Lfused_grid_return:
	pop ix
	ret

/*
 * Clip one shared-X floor/ceiling endpoint to _render_grid_clip_bound.
 *
 * Floor Y is monotone increasing and ceiling Y is monotone decreasing:
 *   floor   = f0 + floor(a*n/d)
 *   ceiling = c0 - ceil(b*n/d)
 * where n=abs(bound-x0), d=abs(x1-x0), a=f1-f0, b=c0-c1.
 *
 * Initially a==b. After endpoint 1 has been rounded, b is either a or a+1.
 * The quotient and remainder of a*n/d therefore derive the ceiling result
 * exactly too, including GraphX's signed floor rounding, with one division.
 */
.Lgrid_clip_pair_endpoint:
	/* n = abs(bound - x0). */
	ld hl, (_render_grid_clip_bound)
	ld de, (_render_grid_far_x)
	or a, a
	sbc hl, de
	bit 7, h
	jr z, .Lgrid_clip_n_ready
	ex de, hl
	or a, a
	sbc hl, hl
	sbc hl, de
.Lgrid_clip_n_ready:
	ld (_render_grid_clip_n), hl

	/* d = abs(x1 - x0). Retained clipped lines always have d>0. */
	ld hl, (_render_grid_near_x)
	ld de, (_render_grid_far_x)
	or a, a
	sbc hl, de
	bit 7, h
	jr z, .Lgrid_clip_d_ready
	ex de, hl
	or a, a
	sbc hl, hl
	sbc hl, de
.Lgrid_clip_d_ready:
	ld (_render_grid_clip_d), hl

	ld a, (_render_grid_floor_y0)
	ld b, a
	ld a, (_render_grid_floor_y1)
	sub a, b
	ld (_render_grid_clip_floor_delta), a

	ld a, (_render_grid_ceiling_y1)
	ld b, a
	ld a, (_render_grid_ceiling_y0)
	sub a, b
	ld (_render_grid_clip_ceiling_delta), a

	/* HL = a*n, then A=floor(a*n/d), HL=(a*n)%d. */
	ld a, (_render_grid_clip_floor_delta)
	ld hl, (_render_grid_clip_n)
	call .Lgrid_mul_u8_u16
	ld bc, (_render_grid_clip_d)
	call .Lgrid_div_u7
	ld (_render_grid_clip_quotient), a
	ld (_render_grid_clip_remainder), hl

	ld b, a
	ld a, (_render_grid_floor_y0)
	add a, b
	ld (_render_grid_clip_floor_result), a

	/* Derive ceil(b*n/d) from q/remainder; b-a is exactly zero or one. */
	ld a, (_render_grid_clip_quotient)
	ld (_render_grid_clip_ceiling_magnitude), a
	ld a, (_render_grid_clip_floor_delta)
	ld b, a
	ld a, (_render_grid_clip_ceiling_delta)
	cp a, b
	jr z, .Lgrid_clip_ceiling_remainder_ready

	ld hl, (_render_grid_clip_remainder)
	ld de, (_render_grid_clip_n)
	add hl, de
	ld bc, (_render_grid_clip_d)
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_clip_ceiling_wrap
	add hl, bc
	jr .Lgrid_clip_ceiling_store_remainder
.Lgrid_clip_ceiling_wrap:
	ld a, (_render_grid_clip_ceiling_magnitude)
	inc a
	ld (_render_grid_clip_ceiling_magnitude), a
.Lgrid_clip_ceiling_store_remainder:
	ld (_render_grid_clip_remainder), hl

.Lgrid_clip_ceiling_remainder_ready:
	ld hl, (_render_grid_clip_remainder)
	ld de, 0
	or a, a
	sbc hl, de
	jr z, .Lgrid_clip_ceiling_magnitude_ready
	ld a, (_render_grid_clip_ceiling_magnitude)
	inc a
	ld (_render_grid_clip_ceiling_magnitude), a
.Lgrid_clip_ceiling_magnitude_ready:
	ld a, (_render_grid_clip_ceiling_magnitude)
	ld b, a
	ld a, (_render_grid_ceiling_y0)
	sub a, b
	ld (_render_grid_clip_ceiling_result), a
	ret

/*
 * A=unsigned 8-bit multiplicand, HL=unsigned 16-bit multiplicand.
 * Return their exact <=20-bit product in HL using two native 8x8 MLTs.
 */
.Lgrid_mul_u8_u16:
	ld bc, 0
	ld b, a
	ld c, l
	mlt bc
	ld de, 0
	ld d, a
	ld e, h
	mlt de
	ex de, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	push bc
	pop de
	add hl, de
	ret

/*
 * Divide HL by positive BC when the quotient is known to be 0..127.
 * Return quotient in A and remainder in HL. Seven trial subtractions replace
 * GraphX's general 24-step signed divider.
 */
.Lgrid_div_u7:
	push hl
	pop de
	push bc
	push bc
	pop hl
	add hl, hl
	push hl
	pop bc
	push bc
	push bc
	pop hl
	add hl, hl
	push hl
	pop bc
	push bc
	push bc
	pop hl
	add hl, hl
	push hl
	pop bc
	push bc
	push bc
	pop hl
	add hl, hl
	push hl
	pop bc
	push bc
	push bc
	pop hl
	add hl, hl
	push hl
	pop bc
	push bc
	push bc
	pop hl
	add hl, hl
	push hl
	pop bc
	push bc
	push de
	pop hl
	xor a, a

	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit6
	add hl, bc
	jr .Lgrid_div_next5
.Lgrid_div_bit6:
	or a, 64
.Lgrid_div_next5:
	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit5
	add hl, bc
	jr .Lgrid_div_next4
.Lgrid_div_bit5:
	or a, 32
.Lgrid_div_next4:
	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit4
	add hl, bc
	jr .Lgrid_div_next3
.Lgrid_div_bit4:
	or a, 16
.Lgrid_div_next3:
	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit3
	add hl, bc
	jr .Lgrid_div_next2
.Lgrid_div_bit3:
	or a, 8
.Lgrid_div_next2:
	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit2
	add hl, bc
	jr .Lgrid_div_next1
.Lgrid_div_bit2:
	or a, 4
.Lgrid_div_next1:
	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit1
	add hl, bc
	jr .Lgrid_div_next0
.Lgrid_div_bit1:
	or a, 2
.Lgrid_div_next0:
	pop bc
	or a, a
	sbc hl, bc
	jr nc, .Lgrid_div_bit0
	add hl, bc
	ret
.Lgrid_div_bit0:
	or a, 1
	ret

/*
 * Draw one in-bounds line exactly like GraphX gfx_Line_NoClip.
 * Inputs: HL=x0, B=y0, DE=x1, A=y1. The two pixel-color immediates are
 * patched by the caller for the floor and ceiling passes.
 */
.Lgrid_draw_dynamic_noclip:
	or a, a
	sbc hl, de
	add hl, de
	jr c, .Lgrid_dynamic_left_to_right
	ex de, hl
	ld c, a
	ld a, b
	ld b, c
.Lgrid_dynamic_left_to_right:
	sub a, b
	ld iy, 320
	jr nc, .Lgrid_dynamic_positive_dy
	ld iy, -320
	neg
.Lgrid_dynamic_positive_dy:
	push hl
	ld hl, (0xE30014)
	ld c, 160
	mlt bc
	add hl, bc
	add hl, bc
	pop bc
	add hl, bc
	push hl
	ex de, hl
	or a, a
	sbc hl, bc
	push hl
	pop bc

	or a, a
	sbc hl, hl
	ld l, a
	sbc hl, bc
	add hl, bc
	jp nc, .Lgrid_dynamic_vertical

.Lgrid_dynamic_standard_horizontal:
	ld a, l
	or a, h
	ld a, 0x38
	jr nz, .Lgrid_dynamic_dy_nonzero
	xor a, 0x20
.Lgrid_dynamic_dy_nonzero:
	ld (.Lgrid_dynamic_error_jump), a
	ld (.Lgrid_dynamic_width + 1), iy
	ex de, hl
	sbc hl, hl
	sbc hl, de
	ld (.Lgrid_dynamic_dx + 1), bc
	ld (.Lgrid_dynamic_dy + 1), hl
	ex de, hl
	pop hl
	push bc
	srl b
	rr c
	push bc
	pop iy
	pop bc
	inc bc
.Lgrid_dynamic_horizontal_color:
	ld a, 0
.Lgrid_dynamic_horizontal_loop:
	ld (hl), a
	cpi
	ret po
	add iy, de
.Lgrid_dynamic_error_jump:
	jr c, .Lgrid_dynamic_horizontal_loop
.Lgrid_dynamic_width:
	ld de, 0
	add hl, de
.Lgrid_dynamic_dx:
	ld de, 0
	add iy, de
.Lgrid_dynamic_dy:
	ld de, 0
	jr .Lgrid_dynamic_horizontal_loop

.Lgrid_dynamic_vertical:
	lea de, iy + 0
	ld b, c
	ld a, l
	ld iyl, a
	ld c, a
	rra
	inc c
	pop hl
.Lgrid_dynamic_vertical_loop:
.Lgrid_dynamic_vertical_color:
	ld (hl), 0
	dec c
	ret z
	add hl, de
	sub a, b
	jr nc, .Lgrid_dynamic_vertical_loop
	inc hl
	add a, iyl
	jr .Lgrid_dynamic_vertical_loop

/*
 * Draw an unclipped floor line and its exact Y-mirrored ceiling line.
 * X normalization and the dx==dy vertical-major tie match GraphX exactly.
 * The grid endpoints always have abs(dy)==111.
 */
.Lgrid_draw_pair_noclip:
	ld hl, (_render_grid_far_x)
	ld de, (_render_grid_near_x)
	or a, a
	sbc hl, de
	jr c, .Lgrid_pair_far_left

	/* near_x is leftmost (GraphX also swaps equal-X endpoints). */
	ld hl, (_render_grid_far_x)
	ld de, (_render_grid_near_x)
	or a, a
	sbc hl, de
	push hl
	push hl
	pop bc
	push bc
	srl b
	rr c
	push bc
	pop iy
	pop bc

	ld hl, (0xE30014)
	ld de, GRID_CEILING_NEAR_SCREEN_Y * 320
	add hl, de
	ld de, (_render_grid_near_x)
	add hl, de
	ld de, 320
	exx

	pop bc
	inc bc
	ld hl, (0xE30014)
	ld de, GRID_NEAR_SCREEN_Y * 320
	add hl, de
	ld de, (_render_grid_near_x)
	add hl, de

	ld a, b
	or a, a
	jp nz, .Lgrid_pair_horizontal_negative
	ld a, c
	cp a, 113
	jp nc, .Lgrid_pair_horizontal_negative
	ld de, -320
	jr .Lgrid_pair_vertical

.Lgrid_pair_far_left:
	ld hl, (_render_grid_near_x)
	ld de, (_render_grid_far_x)
	or a, a
	sbc hl, de
	push hl
	push hl
	pop bc
	push bc
	srl b
	rr c
	push bc
	pop iy
	pop bc

	ld hl, (0xE30014)
	ld de, GRID_CEILING_FAR_SCREEN_Y * 320
	add hl, de
	ld de, (_render_grid_far_x)
	add hl, de
	ld de, -320
	exx

	pop bc
	inc bc
	ld hl, (0xE30014)
	ld de, GRID_FAR_SCREEN_Y * 320
	add hl, de
	ld de, (_render_grid_far_x)
	add hl, de

	ld a, b
	or a, a
	jr nz, .Lgrid_pair_horizontal_positive
	ld a, c
	cp a, 113
	jr nc, .Lgrid_pair_horizontal_positive
	ld de, 320

.Lgrid_pair_vertical:
	ld b, c
	dec b
	ld c, 112
	ld a, 55
.Lgrid_pair_vertical_loop:
	ld (hl), GRID_FLOOR_COLOR
	exx
	ld (hl), GRID_CEILING_COLOR
	exx
	dec c
	ret z
	add hl, de
	exx
	add hl, de
	exx
	sub a, b
	jr nc, .Lgrid_pair_vertical_loop
	inc hl
	exx
	inc hl
	exx
	add a, 111
	jr .Lgrid_pair_vertical_loop

.Lgrid_pair_horizontal_positive:
	ld (hl), GRID_FLOOR_COLOR
	inc hl
	exx
	ld (hl), GRID_CEILING_COLOR
	inc hl
	exx
	dec bc
	ld a, b
	or a, c
	ret z
	ld de, -111
	add iy, de
	jr c, .Lgrid_pair_horizontal_positive
	ld de, 320
	add hl, de
	exx
	add hl, de
	add iy, bc
	exx
	jr .Lgrid_pair_horizontal_positive

.Lgrid_pair_horizontal_negative:
	ld (hl), GRID_FLOOR_COLOR
	inc hl
	exx
	ld (hl), GRID_CEILING_COLOR
	inc hl
	exx
	dec bc
	ld a, b
	or a, c
	ret z
	ld de, -111
	add iy, de
	jr c, .Lgrid_pair_horizontal_negative
	ld de, -320
	add hl, de
	exx
	add hl, de
	add iy, bc
	exx
	jr .Lgrid_pair_horizontal_negative

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

	.section .text._render_asm_clear_background,"ax",@progbits
	.global _render_asm_clear_background
	.type _render_asm_clear_background, @function

/*
 * Fill the 320x240 draw buffer with a 112-row ceiling, 16-row horizon, and
 * 112-row floor.
 *
 * This specialized version switches color at both horizon edges and writes
 * exactly 76,800 bytes instead of filling the whole screen and overwriting two
 * regions.  It owns the complete background phase: save IFF2 once, mask
 * interrupts while any routine temporarily points SP into VRAM, then let
 * repair_horizon restore the caller's interrupt state.  With interrupts masked
 * the ceiling can use packed PUSHes all the way to byte zero; no 4,001-byte
 * interrupt-stack reserve or byte-at-a-time LDDR prefix is needed.
 */
_render_asm_clear_background:
	ld a, i
	di
	jp po, .Lbackground_interrupts_disabled
	ld a, 1
	jr .Lbackground_interrupt_state_ready
.Lbackground_interrupts_disabled:
	xor a, a
.Lbackground_interrupt_state_ready:
	ld (_render_background_restore_interrupts), a

	ld iy, 0
	add iy, sp

	/* Fill the bottom 112-row floor, leaving its two-byte PUSH remainder. */
	ld hl, (0xE30014)
	ld bc, BACKGROUND_BUFFER_BYTES
	add hl, bc
	ld de, BACKGROUND_FLOOR_COLOR * 0x010101
	ld b, BACKGROUND_FLOOR_ITERS
	ld c, BACKGROUND_FLOOR_TAIL
	ld sp, hl
	call .Lbackground_push_runs

	/* Complete the floor's two-byte head at its exact row boundary. */
	dec sp
	dec sp
	ld hl, 0
	add hl, sp
	ld (hl), BACKGROUND_FLOOR_COLOR
	inc hl
	ld (hl), BACKGROUND_FLOOR_COLOR

	/* Fill the 16-row horizon, likewise leaving its two-byte remainder. */
	ld de, BACKGROUND_HORIZON_COLOR * 0x010101
	ld b, BACKGROUND_HORIZON_ITERS
	ld c, BACKGROUND_HORIZON_TAIL
	call .Lbackground_push_runs
	dec sp
	dec sp
	ld hl, 0
	add hl, sp
	ld (hl), BACKGROUND_HORIZON_COLOR
	inc hl
	ld (hl), BACKGROUND_HORIZON_COLOR

	/* Fill the upper ceiling, leaving its two-byte PUSH remainder. */
	ld de, BACKGROUND_CEILING_COLOR * 0x010101
	ld b, BACKGROUND_CEILING_ITERS
	ld c, BACKGROUND_CEILING_TAIL
	call .Lbackground_push_runs
	dec sp
	dec sp
	ld hl, 0
	add hl, sp
	ld (hl), BACKGROUND_CEILING_COLOR
	inc hl
	ld (hl), BACKGROUND_CEILING_COLOR
	ld sp, iy
	ret

/*
 * Entered with SP on VRAM, DE holding a packed color, B full iterations,
 * and C tail pushes. POP removes CALL's return address before any pixels are
 * written; JP returns without touching the displaced stack.
 */
.Lbackground_push_runs:
	pop hl
.Lbackground_push_loop:
	.rept BACKGROUND_PUSHES_PER_ITER
	push de
	.endr
	djnz .Lbackground_push_loop
.Lbackground_push_tail:
	push de
	dec c
	jr nz, .Lbackground_push_tail
	jp (hl)

	.size _render_asm_clear_background, .-_render_asm_clear_background

	.section .text._render_asm_repair_horizon,"ax",@progbits
	.global _render_asm_repair_horizon
	.type _render_asm_repair_horizon, @function

/*
 * Restore only the horizon rows touched by the paired grid rasterizers:
 * ceiling rows 112-113 and floor row 127.
 */
_render_asm_repair_horizon:
	ld hl, (0xE30014)
	ld de, BACKGROUND_REPAIR_TOP_OFFSET
	add hl, de
	ld (hl), BACKGROUND_HORIZON_COLOR
	push hl
	pop de
	inc de
	ld bc, BACKGROUND_REPAIR_TOP_BYTES - 1
	ldir

	ld hl, (0xE30014)
	ld de, BACKGROUND_REPAIR_BOTTOM_OFFSET
	add hl, de
	ld (hl), BACKGROUND_HORIZON_COLOR
	push hl
	pop de
	inc de
	ld bc, BACKGROUND_REPAIR_BOTTOM_BYTES - 1
	ldir
	ld a, (_render_background_restore_interrupts)
	or a, a
	ret z
	ei
	ret

	.size _render_asm_repair_horizon, .-_render_asm_repair_horizon

	.section .text._render_asm_draw_horizontal_grid_pair,"ax",@progbits
	.global _render_asm_draw_horizontal_grid_pair
	.type _render_asm_draw_horizontal_grid_pair, @function

/*
 * Draw a full-width horizontal floor/ceiling pair directly. The unused
 * C wrapper discards its segment pointer before entering this one-argument
 * assembly ABI. Stack slot: ix+6 screen_y.
 *
 * A 24-bit PUSH writes three equal-color pixels at once, so each row needs
 * only 106 packed writes plus its two-byte head instead of a 319-iteration
 * overlapping LDIR. clear_background has already masked interrupts for the
 * whole background phase, so this hot per-line routine only saves/restores SP.
 */
_render_asm_draw_horizontal_grid_pair:
	call __frameset0
	ld a, (ix + 6)

	/* Resolve both row pointers before temporarily moving SP into VRAM. */
	ld hl, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld de, _render_screen_rows
	add hl, de
	ld de, (hl)
	ld hl, (0xE30014)
	add hl, de
	ld (_render_grid_floor_row), hl

	ld b, a
	ld a, 240
	sub a, b
	ld hl, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld de, _render_screen_rows
	add hl, de
	ld de, (hl)
	ld hl, (0xE30014)
	add hl, de
	ld (_render_grid_ceiling_row), hl

	ld iy, 0
	add iy, sp

	ld hl, (_render_grid_floor_row)
	ld (hl), GRID_FLOOR_COLOR
	inc hl
	ld (hl), GRID_FLOOR_COLOR
	ld hl, (_render_grid_floor_row)
	ld bc, GRID_HORIZONTAL_BYTES
	add hl, bc
	ld sp, hl
	ld de, GRID_FLOOR_COLOR * 0x010101
	.rept GRID_HORIZONTAL_PUSHES
	push de
	.endr

	ld hl, (_render_grid_ceiling_row)
	ld (hl), GRID_CEILING_COLOR
	inc hl
	ld (hl), GRID_CEILING_COLOR
	ld hl, (_render_grid_ceiling_row)
	ld bc, GRID_HORIZONTAL_BYTES
	add hl, bc
	ld sp, hl
	ld de, GRID_CEILING_COLOR * 0x010101
	.rept GRID_HORIZONTAL_PUSHES
	push de
	.endr

	ld sp, iy
	pop ix
	ret

	.size _render_asm_draw_horizontal_grid_pair, .-_render_asm_draw_horizontal_grid_pair

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
	.global _render_asm_transform_ray_state
	.type _render_asm_transform_ray, @function
	.type _render_asm_transform_ray_state, @function

/* Transform a ray and its sub-cell origin through a linked portal. */
_render_asm_transform_ray:
	call __frameset0
	ld iy, (ix + 6)
	ld hl, (ix + 9)
	ld (_render_transform_exit), hl
	jr .Ltransform_ray_common

/*
 * Renderer-specialized entry. The fused DDA hit resolver already owns both
 * pointers, so no argument slots or frame setup are needed. Push IX only to
 * share the common epilogue with the public compatibility entry above.
 */
_render_asm_transform_ray_state:
	push ix
	ld iy, (_render_ray_state + STATE_HIT)
	ld hl, _render_ray_state + STATE_PORTAL_EXIT
	ld (_render_transform_exit), hl

.Ltransform_ray_common:
	/*
	 * The exit-face overwrite discards the entry normal coordinate. Retain
	 * only the exact wall tangent computed by the DDA; every direction pair
	 * maps it to either tangent or 256-tangent at the exit.
	 */
	ld hl, (iy + RAY_WALL_POSITION)
	ld de, 0
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Ltransform_tangent_x_wall
	ld d, (iy + RAY_MAP_Y)
.Ltransform_tangent_ready:
	or a, a
	sbc hl, de
	jr .Ltransform_direction_pair
.Ltransform_tangent_x_wall:
	ld d, (iy + RAY_MAP_X)
	jr .Ltransform_tangent_ready

	/*
	 * Each table byte packs the ray rotation in bits 0-1
	 * (0, +1, 2, -1 respectively) and tangent mirroring in bit 7.
	 */
.Ltransform_direction_pair:
	ld a, (iy + RAY_WALL_DIRECTION)
	add a, a
	add a, a
	ld b, a
	ld iy, (_render_transform_exit)
	ld a, (iy + 2)
	add a, b
	ld de, 0
	ld e, a
	ld bc, .Lportal_transform_flags
	ex de, hl
	add hl, bc
	ld a, (hl)
	ld (_render_transform_flags), a
	ex de, hl

	/* Apply the pair's exact tangent orientation without rotating a point. */
	bit 7, a
	jr z, .Ltransform_tangent_oriented
	ex de, hl
	ld hl, 256
	or a, a
	sbc hl, de
.Ltransform_tangent_oriented:

	/*
	 * Construct the final affine origin directly. One coordinate is the
	 * oriented tangent plus its exit tile; the other is the fixed restart
	 * point one unit beyond the exit face.
	 */
	ld iy, (_render_transform_exit)
	ld a, (iy + 2)
	or a, a
	jr z, .Ltransform_exit_north
	cp a, 1
	jr z, .Ltransform_exit_south
	cp a, 2
	jr z, .Ltransform_exit_west

	/* East: x = tile_x*256+t, y = (tile_y+1)*256+1. */
	ld de, 0
	ld d, (iy)
	add hl, de
	ld de, 0
	ld d, (iy + 1)
	inc d
	inc de
	jr .Ltransform_exit_ready
.Ltransform_exit_north:
	/* North: x = tile_x*256-1, y = tile_y*256+t. */
	ld de, 0
	ld d, (iy + 1)
	add hl, de
	ld de, 0
	ld d, (iy)
	dec de
	ex de, hl
	jr .Ltransform_exit_ready
.Ltransform_exit_south:
	/* South: x = (tile_x+1)*256+1, y = tile_y*256+t. */
	ld de, 0
	ld d, (iy + 1)
	add hl, de
	ld de, 0
	ld d, (iy)
	inc d
	inc de
	ex de, hl
	jr .Ltransform_exit_ready
.Ltransform_exit_west:
	/* West: x = tile_x*256+t, y = tile_y*256-1. */
	ld de, 0
	ld d, (iy)
	add hl, de
	ld de, 0
	ld d, (iy + 1)
	dec de
.Ltransform_exit_ready:
	ld (_render_ray_state + STATE_ORIGIN_X), hl
	ld (_render_ray_state + STATE_ORIGIN_Y), de

	/*
	 * Rotate the direction with a specialized kernel. Rotation zero touches
	 * neither component; quarter-turn kernels load the destination's old
	 * component before overwriting it.
	 */
	ld a, (_render_transform_flags)
	and a, 3
	jr z, .Ltransform_state_axes
	dec a
	jr z, .Ltransform_ray_positive
	dec a
	jr z, .Ltransform_ray_half

	/* -90 degrees: (x, y) -> (y, -x). */
	ld de, (_render_ray_state + STATE_RAY_X)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld de, (_render_ray_state + STATE_RAY_Y)
	ld (_render_ray_state + STATE_RAY_Y), hl
	ld (_render_ray_state + STATE_RAY_X), de
	jr .Ltransform_state_axes

.Ltransform_ray_positive:
	/* +90 degrees: (x, y) -> (-y, x). */
	ld de, (_render_ray_state + STATE_RAY_Y)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld de, (_render_ray_state + STATE_RAY_X)
	ld (_render_ray_state + STATE_RAY_X), hl
	ld (_render_ray_state + STATE_RAY_Y), de
	jr .Ltransform_state_axes

.Ltransform_ray_half:
	/* 180 degrees: negate both components independently. */
	ld de, (_render_ray_state + STATE_RAY_X)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld (_render_ray_state + STATE_RAY_X), hl
	ld de, (_render_ray_state + STATE_RAY_Y)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld (_render_ray_state + STATE_RAY_Y), hl

.Ltransform_state_axes:
	/* Quarter turns swap every positive axis-specific persistent value. */
	ld a, (_render_transform_flags)
	and a, 1
	jr z, .Ltransform_state_steps
	ld hl, (_render_ray_state + STATE_DELTA_X)
	ld de, (_render_ray_state + STATE_DELTA_Y)
	ld (_render_ray_state + STATE_DELTA_X), de
	ld (_render_ray_state + STATE_DELTA_Y), hl
	ld a, (_render_ray_state + STATE_ABS_X)
	ld b, a
	ld a, (_render_ray_state + STATE_ABS_Y)
	ld (_render_ray_state + STATE_ABS_X), a
	ld a, b
	ld (_render_ray_state + STATE_ABS_Y), a
	ld a, (_render_ray_state + STATE_ABS_X + 1)
	ld b, a
	ld a, (_render_ray_state + STATE_ABS_Y + 1)
	ld (_render_ray_state + STATE_ABS_X + 1), a
	ld a, b
	ld (_render_ray_state + STATE_ABS_Y + 1), a

.Ltransform_state_steps:
	/* Rebuild signed strides from the rotated rays; negative zero is zero. */
	ld hl, 1
	ld a, (_render_ray_state + STATE_RAY_X + 2)
	bit 7, a
	jr z, .Ltransform_step_x_ready
	ld hl, -1
.Ltransform_step_x_ready:
	ld (_render_ray_state + STATE_MAP_STEP_X), hl
	ld hl, 16
	ld a, (_render_ray_state + STATE_RAY_Y + 2)
	bit 7, a
	jr z, .Ltransform_step_y_ready
	ld hl, -16
.Ltransform_step_y_ready:
	ld (_render_ray_state + STATE_MAP_STEP_Y), hl

	/* Translate packed code 3 back to the caller's signed -1 rotation. */
	ld a, (_render_transform_flags)
	and a, 3
	cp a, 3
	jr nz, .Ltransform_return
	ld a, -1
.Ltransform_return:
	pop ix
	ret

	.size _render_asm_transform_ray, .-_render_asm_transform_ray
	.size _render_asm_transform_ray_state, .-_render_asm_transform_ray_state

	.section .text._render_asm_transform_ray_predecoded_state,"ax",@progbits
	.global _render_asm_transform_ray_predecoded_state
	.type _render_asm_transform_ray_predecoded_state, @function

/*
 * Layer-major first-portal transform. C decodes one eight-byte affine plan
 * for a contiguous run. Each ray still contributes its exact DDA tangent,
 * vector, reciprocals, and signed state, but avoids exit lookup, the 16-way
 * direction-pair lookup, and the exit-direction origin switch.
 */
_render_asm_transform_ray_predecoded_state:
	push ix
	ld iy, (_render_ray_state + STATE_HIT)

	/* tangent = wall_position - entry tile's tangent coordinate. */
	ld hl, (iy + RAY_WALL_POSITION)
	ld de, 0
	ld a, (iy + RAY_SIDE)
	or a, a
	jr nz, .Lplan_tangent_x_wall
	ld d, (iy + RAY_MAP_Y)
	jr .Lplan_tangent_ready
.Lplan_tangent_x_wall:
	ld d, (iy + RAY_MAP_X)
.Lplan_tangent_ready:
	or a, a
	sbc hl, de

	/* Apply the run's exact tangent mirror, then add its exit-axis base. */
	ld a, (_render_layer_transform_plan + PLAN_FLAGS)
	bit 7, a
	jr z, .Lplan_tangent_oriented
	ex de, hl
	ld hl, 256
	or a, a
	sbc hl, de
.Lplan_tangent_oriented:
	ld de, (_render_layer_transform_plan + PLAN_TANGENT_BASE)
	add hl, de
	ld de, (_render_layer_transform_plan + PLAN_NORMAL)
	ld a, (_render_layer_transform_plan + PLAN_TANGENT_TO_X)
	or a, a
	jr nz, .Lplan_exit_ready
	ex de, hl
.Lplan_exit_ready:
	ld (_render_ray_state + STATE_ORIGIN_X), hl
	ld (_render_ray_state + STATE_ORIGIN_Y), de

	/* Rotate the exact ray components according to the predecoded flags. */
	ld a, (_render_layer_transform_plan + PLAN_FLAGS)
	and a, 3
	jr z, .Lplan_state_axes
	dec a
	jr z, .Lplan_ray_positive
	dec a
	jr z, .Lplan_ray_half

	/* -90 degrees: (x, y) -> (y, -x). */
	ld de, (_render_ray_state + STATE_RAY_X)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld de, (_render_ray_state + STATE_RAY_Y)
	ld (_render_ray_state + STATE_RAY_Y), hl
	ld (_render_ray_state + STATE_RAY_X), de
	jr .Lplan_state_axes

.Lplan_ray_positive:
	/* +90 degrees: (x, y) -> (-y, x). */
	ld de, (_render_ray_state + STATE_RAY_Y)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld de, (_render_ray_state + STATE_RAY_X)
	ld (_render_ray_state + STATE_RAY_X), hl
	ld (_render_ray_state + STATE_RAY_Y), de
	jr .Lplan_state_axes

.Lplan_ray_half:
	ld de, (_render_ray_state + STATE_RAY_X)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld (_render_ray_state + STATE_RAY_X), hl
	ld de, (_render_ray_state + STATE_RAY_Y)
	or a, a
	sbc hl, hl
	sbc hl, de
	ld (_render_ray_state + STATE_RAY_Y), hl

.Lplan_state_axes:
	/* Quarter turns swap every positive axis-specific persistent value. */
	ld a, (_render_layer_transform_plan + PLAN_FLAGS)
	and a, 1
	jr z, .Lplan_state_steps
	ld hl, (_render_ray_state + STATE_DELTA_X)
	ld de, (_render_ray_state + STATE_DELTA_Y)
	ld (_render_ray_state + STATE_DELTA_X), de
	ld (_render_ray_state + STATE_DELTA_Y), hl
	ld a, (_render_ray_state + STATE_ABS_X)
	ld b, a
	ld a, (_render_ray_state + STATE_ABS_Y)
	ld (_render_ray_state + STATE_ABS_X), a
	ld a, b
	ld (_render_ray_state + STATE_ABS_Y), a
	ld a, (_render_ray_state + STATE_ABS_X + 1)
	ld b, a
	ld a, (_render_ray_state + STATE_ABS_Y + 1)
	ld (_render_ray_state + STATE_ABS_X + 1), a
	ld a, b
	ld (_render_ray_state + STATE_ABS_Y + 1), a

.Lplan_state_steps:
	ld hl, 1
	ld a, (_render_ray_state + STATE_RAY_X + 2)
	bit 7, a
	jr z, .Lplan_step_x_ready
	ld hl, -1
.Lplan_step_x_ready:
	ld (_render_ray_state + STATE_MAP_STEP_X), hl
	ld hl, 16
	ld a, (_render_ray_state + STATE_RAY_Y + 2)
	bit 7, a
	jr z, .Lplan_step_y_ready
	ld hl, -16
.Lplan_step_y_ready:
	ld (_render_ray_state + STATE_MAP_STEP_Y), hl
	pop ix
	ret

	.size _render_asm_transform_ray_predecoded_state, .-_render_asm_transform_ray_predecoded_state

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
.Lportal_transform_flags:
	.byte 0x82, 0x00, 0x03, 0x81
	.byte 0x00, 0x82, 0x81, 0x03
	.byte 0x01, 0x83, 0x82, 0x00
	.byte 0x83, 0x01, 0x00, 0x82

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
	ld de, _render_wall_texture_runs
	add hl, de
	ld (_render_span_texture), hl

	/* The shared scale profile carries its absolute-Y boundary pointer. */
	ld iy, (ix + 18)
	ld hl, (iy + 4)
	ld (_render_span_boundaries), hl
	/* Heights >=8 have strictly increasing boundaries until the visible
	 * end, so descriptor.next_index is already the next visible source row. */
	ld a, (iy + 1)
	or a, a
	jr nz, .Lspan_mark_strict_boundaries
	ld a, (iy)
	cp a, 8
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
	cp a, 7
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
	/*
	 * Duff-style eight-row writer.  Every row still performs the exact same
	 * packed24 + fourth-byte writes, but long texture runs now take one loop
	 * branch per eight rows instead of one per two.  Runs shorter than eight
	 * retain the lower-setup pair writer.  L is the palette byte in all three
	 * packed lanes, so it can supply the fourth pixel directly.
	 */
	ld a, (_render_span_run_length)
	cp a, 8
	jr c, .Lspan_write_short
	ld c, a
	add a, 7
	srl a
	srl a
	srl a
	ld b, a
	ld a, c
	and a, 7
	jr z, .Lspan_write_8
	cp a, 4
	jr c, .Lspan_write_low
	jr z, .Lspan_write_4
	cp a, 6
	jr c, .Lspan_write_5
	jr z, .Lspan_write_6
	jr .Lspan_write_7
.Lspan_write_low:
	cp a, 2
	jr c, .Lspan_write_1
	jr z, .Lspan_write_2
	jr .Lspan_write_3

.Lspan_write_8:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_7:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_6:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_5:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_4:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_3:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_2:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_1:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
	djnz .Lspan_write_8
	jr .Lspan_write_done

.Lspan_write_short:
	srl a
	ld b, a
	jr z, .Lspan_write_short_single
	jr nc, .Lspan_write_short_pairs
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lspan_write_short_pairs:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
	djnz .Lspan_write_short_pairs
	jr .Lspan_write_done
.Lspan_write_short_single:
	ld (iy), hl
	ld (iy + 3), l
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
	cp a, 7
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
	cp a, 8
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
	cp a, 7
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
	cp a, 8
	jr c, .Lportal_mask_write_short
	ld c, a
	add a, 7
	srl a
	srl a
	srl a
	ld b, a
	ld a, c
	and a, 7
	jr z, .Lportal_mask_write_8
	cp a, 4
	jr c, .Lportal_mask_write_low
	jr z, .Lportal_mask_write_4
	cp a, 6
	jr c, .Lportal_mask_write_5
	jr z, .Lportal_mask_write_6
	jr .Lportal_mask_write_7
.Lportal_mask_write_low:
	cp a, 2
	jr c, .Lportal_mask_write_1
	jr z, .Lportal_mask_write_2
	jr .Lportal_mask_write_3

.Lportal_mask_write_8:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_7:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_6:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_5:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_4:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_3:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_2:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_1:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
	djnz .Lportal_mask_write_8
	jr .Lportal_mask_write_done

.Lportal_mask_write_short:
	srl a
	ld b, a
	jr z, .Lportal_mask_write_short_single
	jr nc, .Lportal_mask_write_short_pairs
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
.Lportal_mask_write_short_pairs:
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
	ld (iy), hl
	ld (iy + 3), l
	add iy, de
	djnz .Lportal_mask_write_short_pairs
	jr .Lportal_mask_write_done
.Lportal_mask_write_short_single:
	ld (iy), hl
	ld (iy + 3), l
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
	cp a, 7
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
	.global _render_ray_state
	.type _render_ray_state, @object
_render_ray_state:
	.zero STATE_SIZE
	.size _render_ray_state, STATE_SIZE
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
	.local _render_grid_floor_row
_render_grid_floor_row:
	.zero 3
	.local _render_grid_ceiling_row
_render_grid_ceiling_row:
	.zero 3
	.local _render_grid_floor_y0
_render_grid_floor_y0:
	.zero 1
	.local _render_grid_floor_y1
_render_grid_floor_y1:
	.zero 1
	.local _render_grid_ceiling_y0
_render_grid_ceiling_y0:
	.zero 1
	.local _render_grid_ceiling_y1
_render_grid_ceiling_y1:
	.zero 1
	.local _render_grid_clip_bound
_render_grid_clip_bound:
	.zero 3
	.local _render_grid_clip_n
_render_grid_clip_n:
	.zero 3
	.local _render_grid_clip_d
_render_grid_clip_d:
	.zero 3
	.local _render_grid_clip_floor_delta
_render_grid_clip_floor_delta:
	.zero 1
	.local _render_grid_clip_ceiling_delta
_render_grid_clip_ceiling_delta:
	.zero 1
	.local _render_grid_clip_quotient
_render_grid_clip_quotient:
	.zero 1
	.local _render_grid_clip_remainder
_render_grid_clip_remainder:
	.zero 3
	.local _render_grid_clip_ceiling_magnitude
_render_grid_clip_ceiling_magnitude:
	.zero 1
	.local _render_grid_clip_floor_result
_render_grid_clip_floor_result:
	.zero 1
	.local _render_grid_clip_ceiling_result
_render_grid_clip_ceiling_result:
	.zero 1
	.local _render_background_restore_interrupts
_render_background_restore_interrupts:
	.zero 1
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
	.local _render_transform_flags
_render_transform_flags:
	.zero 1
	.local _render_transform_exit
_render_transform_exit:
	.zero 3
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
	.extern _render_layer_transform_plan
	.extern _render_reciprocal_delta
	.extern _render_grid_near_projection
	.extern _grid_far_projection
	.extern _gfx_HorizLine_NoClip
	.extern _gfx_Line_NoClip
	.extern _gfx_Line
	.extern __frameset0

	.section ".note.GNU-stack","",@progbits
