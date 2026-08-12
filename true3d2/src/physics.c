#include "internal.h"

#include <string.h>

static t3d2_fixed_t scale_rate(int32_t rate, uint24_t elapsed, uint24_t frequency) {
    if (frequency == 0u) return 0;
    return (t3d2_fixed_t)((rate * (int32_t)elapsed) / (int32_t)frequency);
}

static void identity_orientation(int16_t orientation[9]) {
    uint8_t index;

    for (index = 0; index < 9u; ++index) orientation[index] = 0;
    orientation[0] = 16384;
    orientation[4] = 16384;
    orientation[8] = 16384;
}

static int32_t fixed_dot(T3D2Vec3 first, T3D2Vec3 second) {
    return (int32_t)(((int64_t)first.x * second.x +
                      (int64_t)first.y * second.y +
                      (int64_t)first.z * second.z) >> 8);
}

static T3D2Vec3 rotate_portal_vector(
    T3D2Vec3 vector,
    const T3D2Portal *source,
    const T3D2Portal *destination
) {
    int32_t local_right = fixed_dot(vector, source->right);
    int32_t local_up = fixed_dot(vector, source->up);
    int32_t local_normal = fixed_dot(vector, source->normal);
    T3D2Vec3 result;

    result.x = (t3d2_fixed_t)(
        (-(int64_t)destination->right.x * local_right +
          (int64_t)destination->up.x * local_up -
          (int64_t)destination->normal.x * local_normal) >> 8);
    result.y = (t3d2_fixed_t)(
        (-(int64_t)destination->right.y * local_right +
          (int64_t)destination->up.y * local_up -
          (int64_t)destination->normal.y * local_normal) >> 8);
    result.z = (t3d2_fixed_t)(
        (-(int64_t)destination->right.z * local_right +
          (int64_t)destination->up.z * local_up -
          (int64_t)destination->normal.z * local_normal) >> 8);
    return result;
}

static T3D2Vec3 transform_portal_point(
    T3D2Vec3 point,
    const T3D2Portal *source,
    const T3D2Portal *destination
) {
    T3D2Vec3 relative;
    T3D2Vec3 transformed;

    relative.x = point.x - source->center.x;
    relative.y = point.y - source->center.y;
    relative.z = point.z - source->center.z;
    transformed = rotate_portal_vector(relative, source, destination);
    transformed.x += destination->center.x;
    transformed.y += destination->center.y;
    transformed.z += destination->center.z;
    return transformed;
}

static int32_t portal_distance(T3D2Vec3 point, const T3D2Portal *portal) {
    T3D2Vec3 relative;

    relative.x = point.x - portal->center.x;
    relative.y = point.y - portal->center.y;
    relative.z = point.z - portal->center.z;
    return fixed_dot(relative, portal->normal);
}

static uint8_t portal_contains(
    T3D2Vec3 point,
    const T3D2Portal *portal,
    t3d2_fixed_t margin
) {
    T3D2Vec3 relative;
    int32_t local_right;
    int32_t local_up;

    relative.x = point.x - portal->center.x;
    relative.y = point.y - portal->center.y;
    relative.z = point.z - portal->center.z;
    local_right = fixed_dot(relative, portal->right);
    local_up = fixed_dot(relative, portal->up);
    if (local_right < 0) local_right = -local_right;
    if (local_up < 0) local_up = -local_up;
    return (uint8_t)(portal->half_width > margin && portal->half_height > margin &&
        local_right <= portal->half_width - margin &&
        local_up <= portal->half_height - margin);
}

static uint8_t crossed_portal(
    T3D2Vec3 previous,
    T3D2Vec3 current,
    const T3D2Portal *portal,
    t3d2_fixed_t margin
) {
    return (uint8_t)(portal_distance(previous, portal) > 0 &&
                     portal_distance(current, portal) <= 0 &&
                     portal_contains(current, portal, margin));
}

static void rotate_player_yaw(T3D2Player *player, int16_t delta) {
    int16_t sine = t3d2_sin_q8((uint8_t)delta);
    int16_t cosine = t3d2_cos_q8((uint8_t)delta);
    T3D2Vec3 old_right = player->right;
    T3D2Vec3 old_forward = player->forward;

    player->right.x = (t3d2_fixed_t)(((int32_t)old_right.x * cosine -
                                      (int32_t)old_forward.x * sine) >> 8);
    player->right.y = (t3d2_fixed_t)(((int32_t)old_right.y * cosine -
                                      (int32_t)old_forward.y * sine) >> 8);
    player->right.z = (t3d2_fixed_t)(((int32_t)old_right.z * cosine -
                                      (int32_t)old_forward.z * sine) >> 8);
    player->forward.x = (t3d2_fixed_t)(((int32_t)old_right.x * sine +
                                        (int32_t)old_forward.x * cosine) >> 8);
    player->forward.y = (t3d2_fixed_t)(((int32_t)old_right.y * sine +
                                        (int32_t)old_forward.y * cosine) >> 8);
    player->forward.z = (t3d2_fixed_t)(((int32_t)old_right.z * sine +
                                        (int32_t)old_forward.z * cosine) >> 8);
}

static void transfer_body_orientation(
    T3D2Body *body,
    const T3D2Portal *source,
    const T3D2Portal *destination
) {
    uint8_t column;

    for (column = 0u; column < 3u; ++column) {
        T3D2Vec3 axis;
        T3D2Vec3 rotated;

        axis.x = body->orientation[column] >> 6;
        axis.y = body->orientation[3u + column] >> 6;
        axis.z = body->orientation[6u + column] >> 6;
        rotated = rotate_portal_vector(axis, source, destination);
        body->orientation[column] = (int16_t)(rotated.x * 64);
        body->orientation[3u + column] = (int16_t)(rotated.y * 64);
        body->orientation[6u + column] = (int16_t)(rotated.z * 64);
    }
}

static t3d2_fixed_t cell_floor(
    const T3D2Engine *engine,
    uint16_t cell,
    t3d2_fixed_t height
) {
    if (engine->scene_loaded != 0u && cell < engine->scene.header->cell_count) {
        return (t3d2_fixed_t)(engine->scene.cells[cell].minimum_z + height);
    }
    return height;
}

static uint8_t point_inside_cell(
    T3D2Vec3 point,
    const T3D2CellRecord *cell
) {
    return (uint8_t)(point.x >= cell->minimum_x && point.x <= cell->maximum_x &&
                     point.y >= cell->minimum_y && point.y <= cell->maximum_y &&
                     point.z >= cell->minimum_z && point.z <= cell->maximum_z);
}

static uint8_t point_inside_gateway(
    const T3D2Engine *engine,
    const T3D2GatewayRecord *gateway,
    T3D2Vec3 point
) {
    const int32_t *first =
        (const int32_t *)((const uint8_t *)engine->scene.header +
                          gateway->vertex_offset);
    int32_t minimum[3] = {first[0], first[1], first[2]};
    int32_t maximum[3] = {first[0], first[1], first[2]};
    int32_t coordinate[3] = {point.x, point.y, point.z};
    uint8_t vertex_index;
    uint8_t axis;

    for (vertex_index = 1u; vertex_index < gateway->vertex_count; ++vertex_index) {
        const int32_t *vertex = first + (uint16_t)vertex_index * 3u;

        for (axis = 0u; axis < 3u; ++axis) {
            if (vertex[axis] < minimum[axis]) minimum[axis] = vertex[axis];
            if (vertex[axis] > maximum[axis]) maximum[axis] = vertex[axis];
        }
    }
    for (axis = 0u; axis < 3u; ++axis) {
        /* The zero-width axis is the gateway plane.  Inset the other two
           axes so the player capsule cannot clip the aperture edge. */
        if (maximum[axis] != minimum[axis] &&
            (coordinate[axis] < minimum[axis] + T3D2_PLAYER_RADIUS ||
             coordinate[axis] > maximum[axis] - T3D2_PLAYER_RADIUS)) {
            return 0u;
        }
    }
    return 1u;
}

static void resolve_player_cell_bounds(T3D2Engine *engine) {
    const T3D2CellRecord *cell;
    uint16_t gateway_offset;
    t3d2_fixed_t minimum_x;
    t3d2_fixed_t maximum_x;
    t3d2_fixed_t minimum_y;
    t3d2_fixed_t maximum_y;

    if (engine->scene_loaded == 0u ||
        engine->player.cell >= engine->scene.header->cell_count) return;
    cell = &engine->scene.cells[engine->player.cell];
    if (point_inside_cell(engine->player.position, cell) == 0u) {
        for (gateway_offset = 0u; gateway_offset < cell->gateway_count;
             ++gateway_offset) {
            const T3D2GatewayRecord *gateway = &engine->scene.gateways[
                cell->first_gateway + gateway_offset];
            const T3D2CellRecord *destination;

            if (gateway->destination_cell >= engine->scene.header->cell_count) continue;
            destination = &engine->scene.cells[gateway->destination_cell];
            if (point_inside_cell(engine->player.position, destination) != 0u &&
                point_inside_gateway(engine, gateway, engine->player.position) != 0u) {
                engine->player.cell = gateway->destination_cell;
                cell = destination;
                break;
            }
        }
    }
    minimum_x = (t3d2_fixed_t)(cell->minimum_x + T3D2_PLAYER_RADIUS);
    maximum_x = (t3d2_fixed_t)(cell->maximum_x - T3D2_PLAYER_RADIUS);
    minimum_y = (t3d2_fixed_t)(cell->minimum_y + T3D2_PLAYER_RADIUS);
    maximum_y = (t3d2_fixed_t)(cell->maximum_y - T3D2_PLAYER_RADIUS);
    if (engine->player.position.x < minimum_x) engine->player.position.x = minimum_x;
    if (engine->player.position.x > maximum_x) engine->player.position.x = maximum_x;
    if (engine->player.position.y < minimum_y) engine->player.position.y = minimum_y;
    if (engine->player.position.y > maximum_y) engine->player.position.y = maximum_y;
}

void t3d2_physics_init(T3D2Engine *engine) {
    memset(&engine->player, 0, sizeof(engine->player));
    engine->player.right.x = T3D2_FIXED_ONE;
    engine->player.up.z = T3D2_FIXED_ONE;
    engine->player.forward.y = T3D2_FIXED_ONE;
    engine->player.grounded = 1u;
}

uint8_t t3d2_physics_tick(
    T3D2Engine *engine,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    uint8_t changed = 0u;
    uint8_t index;
    t3d2_fixed_t movement;
    T3D2Vec3 previous_player;
    T3D2Vec3 previous_body[T3D2_MAX_BODIES];

    if (engine == NULL || ticks_per_second == 0u) return 0u;
    if (elapsed_ticks > ticks_per_second / 4u) elapsed_ticks = ticks_per_second / 4u;
    previous_player = engine->player.position;
    for (index = 0u; index < T3D2_MAX_BODIES; ++index) {
        previous_body[index] = engine->body[index].position;
    }
    if (engine->player.portal_exclusion_ticks != 0u) {
        --engine->player.portal_exclusion_ticks;
    }

    movement = scale_rate(T3D2_MOVE_SPEED * move_axis, elapsed_ticks, ticks_per_second);
    if (movement != 0) {
        engine->player.position.x +=
            (t3d2_fixed_t)(((int32_t)engine->player.forward.x * movement) >> 8);
        engine->player.position.y +=
            (t3d2_fixed_t)(((int32_t)engine->player.forward.y * movement) >> 8);
        engine->player.position.z +=
            (t3d2_fixed_t)(((int32_t)engine->player.forward.z * movement) >> 8);
        changed = 1u;
    }
    if (turn_axis != 0) {
        int16_t delta = (int16_t)scale_rate(
            (int32_t)T3D2_TURN_SPEED * (int32_t)turn_axis,
            elapsed_ticks, ticks_per_second);

        engine->player.yaw = (uint8_t)(engine->player.yaw + delta);
        rotate_player_yaw(&engine->player, delta);
        changed = 1u;
    }
    if ((buttons & T3D2_BUTTON_JUMP) != 0u &&
        (engine->previous_buttons & T3D2_BUTTON_JUMP) == 0u &&
        engine->player.grounded != 0u) {
        engine->player.velocity.z = T3D2_JUMP_SPEED;
        engine->player.grounded = 0u;
    }
    if (engine->player.grounded == 0u) {
        engine->player.velocity.z -= scale_rate(
            T3D2_GRAVITY, elapsed_ticks, ticks_per_second);
        engine->player.position.z += scale_rate(
            engine->player.velocity.z, elapsed_ticks, ticks_per_second);
        t3d2_fixed_t floor_height = cell_floor(
            engine, engine->player.cell, T3D2_PLAYER_EYE_HEIGHT);

        if (engine->player.position.z <= floor_height) {
            engine->player.position.z = floor_height;
            engine->player.velocity.z = 0;
            engine->player.grounded = 1u;
        }
        changed = 1u;
    }

    if (engine->portal[0].linked != 0u && engine->portal[1].linked != 0u &&
        engine->portal[0].charging == 0u && engine->portal[1].charging == 0u &&
        engine->player.portal_exclusion_ticks == 0u) {
        for (index = 0u; index < 2u; ++index) {
            T3D2Portal *source = &engine->portal[index];
            T3D2Portal *destination = &engine->portal[index ^ 1u];

            if (source->cell == engine->player.cell &&
                crossed_portal(previous_player, engine->player.position,
                               source, T3D2_PLAYER_RADIUS)) {
                engine->player.position = transform_portal_point(
                    engine->player.position, source, destination);
                engine->player.velocity = rotate_portal_vector(
                    engine->player.velocity, source, destination);
                engine->player.right = rotate_portal_vector(
                    engine->player.right, source, destination);
                engine->player.up = rotate_portal_vector(
                    engine->player.up, source, destination);
                engine->player.forward = rotate_portal_vector(
                    engine->player.forward, source, destination);
                engine->player.cell = destination->cell;
                engine->player.portal_exclusion_ticks = 3u;
                changed = 1u;
                break;
            }
        }
    }
    resolve_player_cell_bounds(engine);

    for (index = 0; index < T3D2_MAX_BODIES; ++index) {
        T3D2Body *body = &engine->body[index];
        t3d2_fixed_t floor_height;

        if (body->active == 0u) continue;
        if (body->portal_exclusion_ticks != 0u) --body->portal_exclusion_ticks;
        if (body->sleep_ticks >= T3D2_BODY_SLEEP_TICKS) continue;
        body->velocity.z -= scale_rate(T3D2_GRAVITY, elapsed_ticks, ticks_per_second);
        body->position.x += scale_rate(body->velocity.x, elapsed_ticks, ticks_per_second);
        body->position.y += scale_rate(body->velocity.y, elapsed_ticks, ticks_per_second);
        body->position.z += scale_rate(body->velocity.z, elapsed_ticks, ticks_per_second);
        floor_height = cell_floor(engine, body->cell, body->half_extent.z);
        if (body->position.z <= floor_height) {
            body->position.z = floor_height;
            if (body->velocity.z < 0) body->velocity.z = 0;
            if (body->velocity.x == 0 && body->velocity.y == 0) {
                if (body->sleep_ticks < T3D2_BODY_SLEEP_TICKS) ++body->sleep_ticks;
            }
        } else {
            body->sleep_ticks = 0u;
        }
        if (body->portal_exclusion_ticks == 0u &&
            engine->portal[0].linked != 0u && engine->portal[1].linked != 0u &&
            engine->portal[0].charging == 0u && engine->portal[1].charging == 0u) {
            uint8_t portal_index;

            for (portal_index = 0u; portal_index < 2u; ++portal_index) {
                T3D2Portal *source = &engine->portal[portal_index];
                T3D2Portal *destination = &engine->portal[portal_index ^ 1u];

                if (crossed_portal(previous_body[index], body->position, source,
                                   body->half_extent.x)) {
                    body->position = transform_portal_point(body->position, source, destination);
                    body->velocity = rotate_portal_vector(body->velocity, source, destination);
                    transfer_body_orientation(body, source, destination);
                    body->cell = destination->cell;
                    body->portal_exclusion_ticks = 3u;
                    body->sleep_ticks = 0u;
                    break;
                }
            }
        }
        changed = 1u;
    }
    return changed;
}

int8_t t3d2_spawn_body(T3D2Engine *engine, const T3D2Body *source) {
    uint8_t index;

    if (engine == NULL || source == NULL) return -1;
    for (index = 0; index < T3D2_MAX_BODIES; ++index) {
        if (engine->body[index].active == 0u) {
            engine->body[index] = *source;
            engine->body[index].active = 1u;
            identity_orientation(engine->body[index].orientation);
            if (engine->body_count < T3D2_MAX_BODIES) ++engine->body_count;
            return (int8_t)index;
        }
    }
    return -1;
}
