#include "internal.h"

#include <keypadc.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void t3d2_input_poll(T3D2Engine *engine) {
    if (engine == NULL) return;
    if (kb_IsDown(kb_KeyClear)) engine->exit_requested = 1u;
    if ((kb_Data[7] & kb_Up) != 0u) engine->input_latch |= T3D2_INPUT_UP;
    if ((kb_Data[7] & kb_Down) != 0u) engine->input_latch |= T3D2_INPUT_DOWN;
    if ((kb_Data[7] & kb_Left) != 0u) engine->input_latch |= T3D2_INPUT_LEFT;
    if ((kb_Data[7] & kb_Right) != 0u) engine->input_latch |= T3D2_INPUT_RIGHT;
    if ((kb_Data[1] & kb_2nd) != 0u) engine->input_latch |= T3D2_BUTTON_JUMP;
    if ((kb_Data[2] & kb_Alpha) != 0u) engine->input_latch |= T3D2_BUTTON_PORTAL_A;
    if ((kb_Data[1] & kb_Mode) != 0u) engine->input_latch |= T3D2_BUTTON_PORTAL_B;
    /* Read Del from the continuously scanned keypad matrix.  The old
       kb_IsDown() path performs an extra scan and could miss short presses
       while a slow render frame was in progress. */
    if ((kb_Data[1] & kb_Del) != 0u) {
        engine->input_latch |= T3D2_BUTTON_CANCEL_PORTALS;
    }
}

uint8_t t3d2_boot(T3D2Engine *engine) {
    uint8_t memory_status;

    if (engine == NULL) return T3D2_ERROR_ARGUMENT;
    memset(engine, 0, sizeof(*engine));
    t3d2_physics_init(engine);
    memory_status = t3d2_memory_prepare();
    engine->takeover_ready = (uint8_t)(memory_status == T3D2_OK);
    /* The standard CEdev runtime is the expected development configuration. */
    if (memory_status == T3D2_ERROR_MEMORY_DISABLED) return T3D2_OK;
    return memory_status;
}

void t3d2_shutdown(T3D2Engine *engine) {
    if (engine != NULL) {
        uint8_t page;

        for (page = 0u; page < T3D2_MAX_GEOMETRY_PAGES; ++page) {
            free(engine->geometry_cache[page]);
            engine->geometry_cache[page] = NULL;
        }
        free(engine->texture_cache[0]);
        free(engine->texture_cache[1]);
        free(engine->scene_cache);
        engine->texture_cache[0] = NULL;
        engine->texture_cache[1] = NULL;
        engine->scene_cache = NULL;
        engine->texture_half[0] = NULL;
        engine->texture_half[1] = NULL;
        if (engine->takeover_ready != 0u) {
            (void)t3d2_memory_restore();
            engine->takeover_ready = 0u;
        }
    }
}

uint8_t t3d2_load_scene(T3D2Engine *engine, const void *data, uint24_t size) {
    uint8_t status;
    uint8_t index;

    if (engine == NULL) return T3D2_ERROR_ARGUMENT;
    status = t3d2_scene_bind(&engine->scene, data, size);
    if (status != T3D2_OK) return status;
    free(engine->scene_cache);
    engine->scene_cache = (uint8_t *)malloc(size);
    if (engine->scene_cache == NULL) {
        memset(&engine->scene, 0, sizeof(engine->scene));
        return T3D2_ERROR_MEMORY_SPACE;
    }
    memcpy(engine->scene_cache, data, size);
    status = t3d2_scene_bind(&engine->scene, engine->scene_cache, size);
    if (status != T3D2_OK) {
        free(engine->scene_cache);
        engine->scene_cache = NULL;
        return status;
    }
    status = t3d2_resources_load(engine);
    if (status != T3D2_OK) {
        memset(&engine->scene, 0, sizeof(engine->scene));
        return status;
    }
    engine->scene_loaded = 1u;
    engine->player.position.x = (t3d2_fixed_t)engine->scene.header->spawn_x;
    engine->player.position.y = (t3d2_fixed_t)engine->scene.header->spawn_y;
    engine->player.position.z = (t3d2_fixed_t)engine->scene.header->spawn_z;
    engine->player.cell = engine->scene.header->spawn_cell;
    memset(engine->body, 0, sizeof(engine->body));
    engine->body_count = 0u;
    for (index = 0; index < engine->scene.header->body_count; ++index) {
        const T3D2BodySpawnRecord *spawn = &engine->scene.body_spawns[index];
        T3D2Body body;

        memset(&body, 0, sizeof(body));
        body.shape = spawn->shape;
        body.flags = spawn->flags;
        body.cell = spawn->cell;
        body.position.x = (t3d2_fixed_t)spawn->position_x;
        body.position.y = (t3d2_fixed_t)spawn->position_y;
        body.position.z = (t3d2_fixed_t)spawn->position_z;
        body.velocity.x = (t3d2_fixed_t)spawn->velocity_x;
        body.velocity.y = (t3d2_fixed_t)spawn->velocity_y;
        body.velocity.z = (t3d2_fixed_t)spawn->velocity_z;
        body.half_extent.x = spawn->half_x;
        body.half_extent.y = spawn->half_y;
        body.half_extent.z = spawn->half_z;
        (void)t3d2_spawn_body(engine, &body);
    }
    return T3D2_OK;
}

uint8_t t3d2_tick(
    T3D2Engine *engine,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    clock_t started;
    uint8_t changed;

    if (engine == NULL) return 0u;
    started = clock();
    changed = t3d2_physics_tick(engine, move_axis, turn_axis, buttons,
                                elapsed_ticks, ticks_per_second);
    engine->benchmark.update_ticks += (uint32_t)(clock() - started);
    if ((buttons & T3D2_BUTTON_PORTAL_A) != 0u &&
        (engine->previous_buttons & T3D2_BUTTON_PORTAL_A) == 0u) {
        changed |= (uint8_t)(t3d2_place_portal(engine, 0u) == T3D2_OK);
    }
    if ((buttons & T3D2_BUTTON_PORTAL_B) != 0u &&
        (engine->previous_buttons & T3D2_BUTTON_PORTAL_B) == 0u) {
        changed |= (uint8_t)(t3d2_place_portal(engine, 1u) == T3D2_OK);
    }
    if ((buttons & T3D2_BUTTON_CANCEL_PORTALS) != 0u &&
        (engine->previous_buttons & T3D2_BUTTON_CANCEL_PORTALS) == 0u) {
        memset(engine->portal, 0, sizeof(engine->portal));
        changed = 1u;
    }
    engine->previous_buttons = buttons;
    return changed;
}

void t3d2_render(T3D2Engine *engine) {
    clock_t frame_started;
    clock_t phase_started;
    uint24_t frame_ticks;

    if (engine == NULL) return;
    frame_started = clock();
    phase_started = frame_started;
    t3d2_reference_render(engine);
    engine->benchmark.raster_ticks += (uint32_t)(clock() - phase_started);
    phase_started = clock();
    t3d2_present_80x60();
    engine->benchmark.present_ticks += (uint32_t)(clock() - phase_started);
    frame_ticks = (uint24_t)(clock() - frame_started);
    engine->benchmark.total_ticks += frame_ticks;
    engine->benchmark.frame_ticks[engine->benchmark.frame_sample_cursor] = frame_ticks;
    engine->benchmark.frame_sample_cursor = (uint16_t)(
        (engine->benchmark.frame_sample_cursor + 1u) % T3D2_FRAME_SAMPLE_CAPACITY);
    if (engine->benchmark.frame_sample_count < T3D2_FRAME_SAMPLE_CAPACITY) {
        ++engine->benchmark.frame_sample_count;
    }
    ++engine->benchmark.frame_count;
}

uint8_t t3d2_place_portal(T3D2Engine *engine, uint8_t portal_index) {
    T3D2Portal *portal;
    const T3D2PortalSurfaceRecord *surface = NULL;
    T3D2Vec3 hit = {0, 0, 0};
    t3d2_fixed_t nearest_distance = 0x7FFFFF;
    uint16_t surface_index;

    if (engine == NULL || portal_index > 1u) return T3D2_ERROR_ARGUMENT;
    portal = &engine->portal[portal_index];
    if (engine->scene_loaded != 0u) {
        for (surface_index = 0u;
             surface_index < engine->scene.header->portal_surface_count;
             ++surface_index) {
            const T3D2PortalSurfaceRecord *candidate =
                &engine->scene.portal_surfaces[surface_index];
            T3D2Vec3 normal;
            T3D2Vec3 relative;
            int24_t denominator;
            int24_t numerator;
            int24_t distance;
            T3D2Vec3 candidate_hit;
            T3D2Vec3 hit_relative;
            T3D2Vec3 right;
            T3D2Vec3 up;
            int24_t local_right;
            int24_t local_up;

            if (candidate->cell != engine->player.cell ||
                (candidate->flags & T3D2_PORTAL_SURFACE_PLACEABLE) == 0u ||
                candidate->half_width < 384u || candidate->half_height < 448u) {
                continue;
            }
            normal.x = candidate->normal_x >> 6;
            normal.y = candidate->normal_y >> 6;
            normal.z = candidate->normal_z >> 6;
            denominator = (engine->player.forward.x * normal.x +
                           engine->player.forward.y * normal.y +
                           engine->player.forward.z * normal.z) >> 8;
            if (denominator >= -4) continue;
            relative.x = (t3d2_fixed_t)candidate->center_x - engine->player.position.x;
            relative.y = (t3d2_fixed_t)candidate->center_y - engine->player.position.y;
            relative.z = (t3d2_fixed_t)candidate->center_z - engine->player.position.z;
            numerator = (relative.x * normal.x + relative.y * normal.y +
                         relative.z * normal.z) >> 8;
            distance = numerator * 256 / denominator;
            if (distance <= T3D2_NEAR_PLANE || distance >= nearest_distance) continue;
            candidate_hit.x = engine->player.position.x +
                (engine->player.forward.x * distance >> 8);
            candidate_hit.y = engine->player.position.y +
                (engine->player.forward.y * distance >> 8);
            candidate_hit.z = engine->player.position.z +
                (engine->player.forward.z * distance >> 8);
            hit_relative.x = candidate_hit.x - (t3d2_fixed_t)candidate->center_x;
            hit_relative.y = candidate_hit.y - (t3d2_fixed_t)candidate->center_y;
            hit_relative.z = candidate_hit.z - (t3d2_fixed_t)candidate->center_z;
            right.x = candidate->right_x >> 6;
            right.y = candidate->right_y >> 6;
            right.z = candidate->right_z >> 6;
            up.x = candidate->up_x >> 6;
            up.y = candidate->up_y >> 6;
            up.z = candidate->up_z >> 6;
            local_right = (hit_relative.x * right.x + hit_relative.y * right.y +
                           hit_relative.z * right.z) >> 8;
            local_up = (hit_relative.x * up.x + hit_relative.y * up.y +
                        hit_relative.z * up.z) >> 8;
            if (local_right < -(int24_t)candidate->half_width ||
                local_right > (int24_t)candidate->half_width ||
                local_up < -(int24_t)candidate->half_height ||
                local_up > (int24_t)candidate->half_height) continue;
            surface = candidate;
            hit = candidate_hit;
            nearest_distance = distance;
        }
    }
    if (surface == NULL) return T3D2_ERROR_SCENE_BOUNDS;
    memset(portal, 0, sizeof(*portal));
    {
        T3D2Vec3 surface_center;
        T3D2Vec3 relative;
        int24_t local_right;
        int24_t local_up;
        int24_t maximum_right = (int24_t)surface->half_width - 384;
        int24_t maximum_up = (int24_t)surface->half_height - 448;

        portal->right.x = surface->right_x >> 6;
        portal->right.y = surface->right_y >> 6;
        portal->right.z = surface->right_z >> 6;
        portal->up.x = surface->up_x >> 6;
        portal->up.y = surface->up_y >> 6;
        portal->up.z = surface->up_z >> 6;
        portal->normal.x = surface->normal_x >> 6;
        portal->normal.y = surface->normal_y >> 6;
        portal->normal.z = surface->normal_z >> 6;
        surface_center.x = (t3d2_fixed_t)surface->center_x;
        surface_center.y = (t3d2_fixed_t)surface->center_y;
        surface_center.z = (t3d2_fixed_t)surface->center_z;
        relative.x = hit.x - surface_center.x;
        relative.y = hit.y - surface_center.y;
        relative.z = hit.z - surface_center.z;
        local_right = (relative.x * portal->right.x + relative.y * portal->right.y +
                       relative.z * portal->right.z) >> 8;
        local_up = (relative.x * portal->up.x + relative.y * portal->up.y +
                    relative.z * portal->up.z) >> 8;
        if (local_right < -maximum_right) local_right = -maximum_right;
        if (local_right > maximum_right) local_right = maximum_right;
        if (local_up < -maximum_up) local_up = -maximum_up;
        if (local_up > maximum_up) local_up = maximum_up;
        portal->center.x = surface_center.x +
            ((portal->right.x * local_right + portal->up.x * local_up) >> 8);
        portal->center.y = surface_center.y +
            ((portal->right.y * local_right + portal->up.y * local_up) >> 8);
        portal->center.z = surface_center.z +
            ((portal->right.z * local_right + portal->up.z * local_up) >> 8);
        portal->half_width = 384;
        portal->half_height = 448;
        portal->cell = surface->cell;
    }
    portal->active = 1u;
    portal->charging = (uint8_t)(engine->resources_loaded == 0u);
    if (engine->portal[portal_index ^ 1u].active != 0u) {
        portal->linked = 1u;
        engine->portal[portal_index ^ 1u].linked = 1u;
    }
    return T3D2_OK;
}

const T3D2Benchmark *t3d2_benchmark_read(const T3D2Engine *engine) {
    return engine == NULL ? NULL : &engine->benchmark;
}
