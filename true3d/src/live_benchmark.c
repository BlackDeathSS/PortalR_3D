#include "live_benchmark.h"
#include "engine.h"
#include "level.h"

#include <fileioc.h>
#include <graphx.h>
#include <stdint.h>
#include <string.h>
#include <sys/timers.h>
#include <ti/getcsc.h>
#include <ti/screen.h>
#include <time.h>

#ifndef TRUE3D_LIVE_BENCHMARK
#define TRUE3D_LIVE_BENCHMARK 0
#endif
#ifndef TRUE3D_LIVE_AUTOTEST_HOLD
#define TRUE3D_LIVE_AUTOTEST_HOLD 0
#endif

#if TRUE3D_LIVE_BENCHMARK

#define LIVE_MAGIC "T3DLIV1"
#define LIVE_FORMAT_VERSION 1u
#define LIVE_RESULT_NAME "T3DLIVE"
#define LIVE_TEMP_NAME "T3DTMP"

#define LIVE_HEADER_SIZE 112u
#define LIVE_SECTION_RECORD_SIZE 116u
#define LIVE_FRAME_RECORD_SIZE 24u
#define LIVE_SECTION_COUNT 10u
#define LIVE_FRAME_COUNT 854u
#define LIVE_WARMUP_FRAMES 16u
#define LIVE_EXPECTED_CROSSINGS 4u
#define LIVE_HUD_FPS_TENTHS 300u
#define LIVE_REPORT_SIZE \
    (LIVE_HEADER_SIZE + \
        LIVE_SECTION_COUNT * LIVE_SECTION_RECORD_SIZE + \
        LIVE_FRAME_COUNT * LIVE_FRAME_RECORD_SIZE)

#define LIVE_TICKS_PER_SECOND 30u
#define LIVE_ELAPSED_TICKS 1u

#define LIVE_FLAG_FRAME_TIMINGS       (1UL << 0)
#define LIVE_FLAG_FIXED_TIMESTEP      (1UL << 1)
#define LIVE_FLAG_FULL_UPDATE         (1UL << 2)
#define LIVE_FLAG_FULL_RENDER_PRESENT (1UL << 3)
#define LIVE_FLAG_SECTION_TRACE       (1UL << 4)
#define LIVE_FLAG_SECTION_HASHES      (1UL << 5)
#define LIVE_FLAG_BUILTIN_LEVEL       (1UL << 6)
#define LIVE_FLAG_CONSTANT_HUD        (1UL << 7)
#define LIVE_FLAG_FULL_DETAIL         (1UL << 8)
#define LIVE_FLAG_DIAGNOSTIC_REPLAY   (1UL << 9)
#define LIVE_FLAG_ARCHIVED            (1UL << 10)
#define LIVE_FLAG_FIXED_TRACE_FRAMES  (1UL << 11)

#define LIVE_SECTION_PORTAL_VIEW  (1u << 0)
#define LIVE_SECTION_PORTAL_CROSS (1u << 1)
#define LIVE_SECTION_TURN         (1u << 2)
#define LIVE_SECTION_PITCH        (1u << 3)
#define LIVE_SECTION_FREECAM      (1u << 4)
#define LIVE_SECTION_LOD          (1u << 5)
#define LIVE_SECTION_VERTICAL     (1u << 6)
#define LIVE_SECTION_STRESS       (1u << 7)

#define LIVE_FRAME_CROSSED_PORTAL (1u << 0)
#define LIVE_FRAME_DETAILED       (1u << 1)
#define LIVE_FRAME_CHANGED        (1u << 2)
#define LIVE_FRAME_SECTION_END    (1u << 3)
#define LIVE_FRAME_FREECAM        (1u << 4)

typedef struct {
    const char *name;
    uint8_t flags;
    uint16_t detail_offset;
} LiveSection;

typedef struct __attribute__((packed)) {
    uint16_t frames;
    int8_t move_axis;
    int8_t turn_axis;
    int8_t look_axis;
    uint8_t buttons;
    uint8_t section;
} LiveRouteStep;

typedef struct {
    uint8_t step;
    uint16_t step_frame;
    uint16_t route_frame;
} LiveController;

static const LiveSection live_sections[LIVE_SECTION_COUNT] = {
    {"OPEN_YAW", LIVE_SECTION_TURN, 1},
    {"PITCH_SWEEP", LIVE_SECTION_PITCH, 5},
    {"PORTAL_FAR", LIVE_SECTION_PORTAL_VIEW | LIVE_SECTION_LOD, 30},
    {"PORTAL_NEAR", LIVE_SECTION_PORTAL_VIEW | LIVE_SECTION_LOD, 32},
    {"CROSS_DOWN", LIVE_SECTION_PORTAL_VIEW | LIVE_SECTION_PORTAL_CROSS |
        LIVE_SECTION_STRESS, 0},
    {"RETURN_UP", LIVE_SECTION_PORTAL_VIEW | LIVE_SECTION_PORTAL_CROSS |
        LIVE_SECTION_FREECAM | LIVE_SECTION_STRESS, 9},
    {"LOD_RETREAT", LIVE_SECTION_PORTAL_VIEW | LIVE_SECTION_LOD |
        LIVE_SECTION_FREECAM, 8},
    {"LOD_APPROACH", LIVE_SECTION_PORTAL_VIEW | LIVE_SECTION_PORTAL_CROSS |
        LIVE_SECTION_LOD | LIVE_SECTION_FREECAM | LIVE_SECTION_STRESS, 38},
    {"FREECAM_YAW", LIVE_SECTION_TURN | LIVE_SECTION_FREECAM, 21},
    {"FREECAM_3D", LIVE_SECTION_PITCH | LIVE_SECTION_FREECAM |
        LIVE_SECTION_VERTICAL | LIVE_SECTION_STRESS, 46}
};

/*
 * A real input recording at the 30 FPS target cadence.  Every frame executes
 * engine_update(), the full 64x48 renderer/presenter, HUD, and gfx_SwapDraw().
 */
static const LiveRouteStep live_route[] = {
    {64, 0, 1, 0, 0, 0},
    {64, 0, -1, 0, 0, 0},
    {24, 0, 0, 1, 0, 1},
    {48, 0, 0, -1, 0, 1},
    {24, 0, 0, 1, 0, 1},
    {56, 1, 0, 0, 0, 2},
    {36, 1, 0, 0, 0, 3},
    {4, 1, 0, 0, 0, 4},
    {1, 0, 0, 0, ENGINE_BUTTON_DEV_MODE, 5},
    {1, 0, 0, 0, 0, 5},
    {8, -1, 0, 0, 0, 5},
    {48, -1, 0, 0, 0, 6},
    {60, 1, 0, 0, 0, 7},
    {64, 0, 1, 0, 0, 8},
    {64, 0, -1, 0, 0, 8},
    {48, 0, 0, 1, 0, 9},
    {96, 0, 0, -1, 0, 9},
    {48, 0, 0, 1, 0, 9},
    {24, 0, 0, 0, ENGINE_BUTTON_JUMP, 9},
    {48, 0, 0, 0, ENGINE_BUTTON_FLY_DOWN, 9},
    {24, 1, 1, 0, 0, 9}
};

#define LIVE_ROUTE_STEP_COUNT \
    ((uint8_t)(sizeof(live_route) / sizeof(live_route[0])))

static uint8_t *live_report;
static uint8_t live_report_handle;
static EngineState live_state;
static True3DLevelView live_level;

_Static_assert(LIVE_REPORT_SIZE < 65536u,
    "True3D live report must fit in one AppVar");
_Static_assert(TRUE3D_BENCH_CATEGORY_COUNT == 10u,
    "True3D live format requires ten phase categories");

static void write_u16(uint8_t *destination, uint16_t value) {
    destination[0] = (uint8_t)value;
    destination[1] = (uint8_t)(value >> 8);
}

static void write_u24(uint8_t *destination, uint32_t value) {
    destination[0] = (uint8_t)value;
    destination[1] = (uint8_t)(value >> 8);
    destination[2] = (uint8_t)(value >> 16);
}

static void write_s24(uint8_t *destination, fixed_t value) {
    write_u24(destination, (uint32_t)value & 0xFFFFFFUL);
}

static void write_u32(uint8_t *destination, uint32_t value) {
    destination[0] = (uint8_t)value;
    destination[1] = (uint8_t)(value >> 8);
    destination[2] = (uint8_t)(value >> 16);
    destination[3] = (uint8_t)(value >> 24);
}

static uint16_t read_u16(const uint8_t *source) {
    return (uint16_t)source[0] | ((uint16_t)source[1] << 8);
}

static uint32_t read_u32(const uint8_t *source) {
    return (uint32_t)source[0] |
        ((uint32_t)source[1] << 8) |
        ((uint32_t)source[2] << 16) |
        ((uint32_t)source[3] << 24);
}

static uint16_t clamp_u16(uint32_t value) {
    return value > 65535UL ? 65535u : (uint16_t)value;
}

static uint32_t live_crc32(const uint8_t *data, uint16_t size) {
    uint32_t crc = 0xFFFFFFFFUL;
    uint16_t index;

    for (index = 0; index < size; ++index) {
        uint8_t bit;

        crc ^= data[index];
        for (bit = 0; bit < 8; ++bit) {
            uint32_t mask = (uint32_t)-(int32_t)(crc & 1u);

            crc = (crc >> 1) ^ (0xEDB88320UL & mask);
        }
    }
    return ~crc;
}

static uint32_t live_hash_bytes(
    uint32_t hash,
    const uint8_t *data,
    uint24_t size
) {
    uint24_t index;

    for (index = 0; index < size; ++index) {
        hash ^= data[index];
        hash *= 16777619UL;
    }
    return hash;
}

static uint32_t live_presented_hash(void) {
    return live_hash_bytes(
        2166136261UL,
        &gfx_vbuffer[0][0],
        GFX_LCD_WIDTH * GFX_LCD_HEIGHT
    );
}

static uint32_t live_state_hash(const EngineState *state) {
    uint8_t data[52];
    uint8_t *cursor = data;
    const Vec3 *vectors[5] = {
        &state->position,
        &state->velocity,
        &state->right,
        &state->up,
        &state->forward
    };
    uint8_t vector;

    for (vector = 0; vector < 5u; ++vector) {
        write_s24(cursor + 0, vectors[vector]->x);
        write_s24(cursor + 3, vectors[vector]->y);
        write_s24(cursor + 6, vectors[vector]->z);
        cursor += 9;
    }
    *cursor++ = state->yaw;
    *cursor++ = (uint8_t)state->pitch;
    *cursor++ = state->room;
    *cursor++ = state->previous_buttons;
    *cursor++ = state->grounded;
    *cursor++ = state->dev_mode;
    *cursor++ = state->render_shift;
    return live_hash_bytes(2166136261UL, data, sizeof(data));
}

static uint32_t live_route_fingerprint(void) {
    uint32_t hash = live_hash_bytes(
        2166136261UL,
        (const uint8_t *)live_route,
        sizeof(live_route)
    );
    uint8_t section;

    for (section = 0; section < LIVE_SECTION_COUNT; ++section) {
        hash = live_hash_bytes(
            hash,
            (const uint8_t *)live_sections[section].name,
            (uint24_t)strlen(live_sections[section].name)
        );
        hash ^= live_sections[section].flags;
        hash *= 16777619UL;
    }
    return hash;
}

static uint8_t *live_section_record(uint8_t section) {
    return live_report + LIVE_HEADER_SIZE +
        (uint16_t)section * LIVE_SECTION_RECORD_SIZE;
}

static uint8_t *live_frame_record(uint16_t frame) {
    return live_report + LIVE_HEADER_SIZE +
        LIVE_SECTION_COUNT * LIVE_SECTION_RECORD_SIZE +
        (uint24_t)frame * LIVE_FRAME_RECORD_SIZE;
}

static uint8_t live_prepare_report(void) {
#if TRUE3D_LIVE_AUTOTEST_HOLD
    uint8_t previous_handle = ti_Open(LIVE_RESULT_NAME, "r+");

    if (previous_handle != 0) {
        uint8_t *previous = ti_GetDataPtr(previous_handle);

        if (previous != NULL && ti_GetSize(previous_handle) != 0) {
            previous[0] = 0;
        }
        ti_Close(previous_handle);
    }
#endif
    (void)ti_Delete(LIVE_TEMP_NAME);
    live_report_handle = ti_Open(LIVE_TEMP_NAME, "w");
    if (live_report_handle == 0) return 0;
    if (ti_Resize(LIVE_REPORT_SIZE, live_report_handle) != LIVE_REPORT_SIZE) {
        ti_Close(live_report_handle);
        live_report_handle = 0;
        (void)ti_Delete(LIVE_TEMP_NAME);
        return 0;
    }
    live_report = ti_GetDataPtr(live_report_handle);
    if (live_report == NULL) {
        ti_Close(live_report_handle);
        live_report_handle = 0;
        (void)ti_Delete(LIVE_TEMP_NAME);
        return 0;
    }
    memset(live_report, 0, LIVE_REPORT_SIZE);
    return 1;
}

static uint8_t live_commit_report(void) {
    ti_Close(live_report_handle);
    live_report_handle = 0;
    live_report = NULL;
    (void)ti_Delete(LIVE_RESULT_NAME);
    return ti_Rename(LIVE_TEMP_NAME, LIVE_RESULT_NAME) == 0;
}

#if !TRUE3D_LIVE_AUTOTEST_HOLD
static uint8_t live_archive_report(void) {
    uint8_t handle = ti_Open(LIVE_RESULT_NAME, "r+");
    uint8_t archived;

    if (handle == 0) return 0;
    archived = ti_SetArchiveStatus(true, handle) != 0;
    ti_Close(handle);
    return archived;
}
#endif

static uint8_t live_reset_state(void) {
    return engine_init(&live_state, &live_level);
}

static void live_controller_reset(LiveController *controller) {
    controller->step = 0;
    controller->step_frame = 0;
    controller->route_frame = 0;
}

static uint8_t live_controller_next(
    LiveController *controller,
    int8_t *move_axis,
    int8_t *turn_axis,
    int8_t *look_axis,
    uint8_t *buttons,
    uint8_t *section
) {
    const LiveRouteStep *step;

    if (controller->step >= LIVE_ROUTE_STEP_COUNT) return 0;
    step = &live_route[controller->step];
    *move_axis = step->move_axis;
    *turn_axis = step->turn_axis;
    *look_axis = step->look_axis;
    *buttons = step->buttons;
    *section = step->section;
    ++controller->route_frame;
    ++controller->step_frame;
    if (controller->step_frame == step->frames) {
        ++controller->step;
        controller->step_frame = 0;
    }
    return 1;
}

static uint8_t live_route_is_valid(void) {
    uint16_t total_frames = 0;
    uint8_t previous_section = 0;
    uint8_t step;

    for (step = 0; step < LIVE_ROUTE_STEP_COUNT; ++step) {
        const LiveRouteStep *route = &live_route[step];

        if (route->frames == 0 || route->section >= LIVE_SECTION_COUNT ||
            (step != 0 && route->section < previous_section)) {
            return 0;
        }
        previous_section = route->section;
        total_frames += route->frames;
    }
    return total_frames == LIVE_FRAME_COUNT &&
        previous_section == LIVE_SECTION_COUNT - 1u;
}

static void live_write_sections(void) {
    uint16_t first_frame = 0;
    uint8_t step = 0;
    uint8_t section;

    for (section = 0; section < LIVE_SECTION_COUNT; ++section) {
        uint8_t *record = live_section_record(section);
        uint16_t frames = 0;
        uint8_t length = (uint8_t)strlen(live_sections[section].name);

        while (step < LIVE_ROUTE_STEP_COUNT &&
            live_route[step].section == section) {
            frames += live_route[step].frames;
            ++step;
        }
        if (length > 15u) length = 15u;
        record[0] = (uint8_t)(section + 1u);
        record[1] = live_sections[section].flags;
        write_u16(record + 2, first_frame);
        write_u16(record + 4, frames);
        write_u16(record + 6, first_frame + live_sections[section].detail_offset);
        memcpy(record + 8, live_sections[section].name, length);
        first_frame += frames;
    }
}

static uint8_t live_section_ends(uint16_t frame, uint8_t section) {
    const uint8_t *record = live_section_record(section);

    return frame + 1u == read_u16(record + 2) + read_u16(record + 4);
}

static uint8_t live_should_trace(uint16_t frame, uint8_t section) {
    return frame == read_u16(live_section_record(section) + 6);
}

static void live_write_detail(
    uint8_t section,
    const True3DRenderBenchmark *detail
) {
    uint8_t *record = live_section_record(section);
    const uint16_t counters[11] = {
        detail->transformed_vertices,
        detail->projected_points,
        detail->rasterized_polygons,
        detail->raster_rows,
        detail->filled_spans,
        detail->filled_pixels,
        detail->portal_composite_pixels,
        detail->portal_clip_pixels,
        detail->full_portal_views,
        detail->lod_portal_views,
        detail->edge_division_fallbacks
    };
    uint8_t category;
    uint8_t counter;

    for (category = 0; category < TRUE3D_BENCH_CATEGORY_COUNT; ++category) {
        write_u24(record + 40 + category * 3, detail->raw_ticks[category]);
        write_u16(record + 70 + category * 2, detail->entries[category]);
    }
    for (counter = 0; counter < 11u; ++counter) {
        write_u16(record + 90 + counter * 2, counters[counter]);
    }
    write_u32(record + 112, detail->total_ticks);
}

static void live_write_frame(
    uint16_t frame,
    int8_t move_axis,
    int8_t turn_axis,
    int8_t look_axis,
    uint8_t buttons,
    uint8_t flags,
    uint32_t update_ticks,
    uint32_t render_ticks,
    uint32_t swap_ticks,
    uint32_t state_hash
) {
    uint8_t *record = live_frame_record(frame);

    write_u16(record + 0, clamp_u16(update_ticks + render_ticks + swap_ticks));
    write_u16(record + 2, clamp_u16(update_ticks));
    write_u16(record + 4, clamp_u16(render_ticks));
    write_u16(record + 6, clamp_u16(swap_ticks));
    write_u32(record + 8, state_hash);
    write_s24(record + 12, live_state.position.x);
    write_s24(record + 15, live_state.position.y);
    write_s24(record + 18, live_state.position.z);
    record[21] = live_state.room;
    record[22] = flags;
    record[23] = (uint8_t)(
        ((uint8_t)(move_axis + 1) & 3u) |
        (((uint8_t)(turn_axis + 1) & 3u) << 2) |
        (((uint8_t)(look_axis + 1) & 3u) << 4) |
        ((buttons != 0) << 6)
    );
}

static uint32_t live_first_frame(void) {
    clock_t started;

    if (!live_reset_state()) return 0;
    started = clock();
    engine_render(&live_state, LIVE_HUD_FPS_TENTHS);
    gfx_SwapDraw();
    return clock() - started;
}

static uint8_t live_warmup(void) {
    LiveController controller;
    uint8_t frame;

    if (!live_reset_state()) return 0;
    live_controller_reset(&controller);
    for (frame = 0; frame < LIVE_WARMUP_FRAMES; ++frame) {
        int8_t move_axis;
        int8_t turn_axis;
        int8_t look_axis;
        uint8_t buttons;
        uint8_t section;

        if (!live_controller_next(
                &controller, &move_axis, &turn_axis, &look_axis,
                &buttons, &section)) {
            return 0;
        }
        (void)section;
        (void)engine_update(
            &live_state, move_axis, turn_axis, look_axis, buttons,
            LIVE_ELAPSED_TICKS, LIVE_TICKS_PER_SECOND
        );
        engine_render(&live_state, LIVE_HUD_FPS_TENTHS);
        gfx_SwapDraw();
    }
    return 1;
}

static uint8_t live_run_route(
    uint32_t *recorded_total_ticks,
    uint32_t *route_state_hash,
    uint16_t *crossings,
    uint32_t *wall_ticks
) {
    LiveController controller;
    uint32_t route_hash = 2166136261UL;
    uint16_t frame = 0;
    clock_t wall_started;

    *recorded_total_ticks = 0;
    *crossings = 0;
    if (!live_reset_state()) return 0;
    live_controller_reset(&controller);
    wall_started = clock();
    while (frame < LIVE_FRAME_COUNT) {
        int8_t move_axis;
        int8_t turn_axis;
        int8_t look_axis;
        uint8_t buttons;
        uint8_t section;
        uint8_t before_room = live_state.room;
        uint8_t changed;
        uint8_t flags = 0;
        uint32_t update_ticks;
        uint32_t render_ticks;
        uint32_t swap_ticks;
        uint32_t state_hash;
        clock_t started;

        if (!live_controller_next(
                &controller, &move_axis, &turn_axis, &look_axis,
                &buttons, &section)) {
            return 0;
        }
        started = clock();
        changed = engine_update(
            &live_state, move_axis, turn_axis, look_axis, buttons,
            LIVE_ELAPSED_TICKS, LIVE_TICKS_PER_SECOND
        );
        update_ticks = clock() - started;
        if (changed) flags |= LIVE_FRAME_CHANGED;
        if (live_state.room != before_room) {
            flags |= LIVE_FRAME_CROSSED_PORTAL;
            ++*crossings;
            write_u16(
                live_section_record(section) + 36,
                (uint16_t)(read_u16(live_section_record(section) + 36) + 1u)
            );
        }
        if (live_section_ends(frame, section)) flags |= LIVE_FRAME_SECTION_END;
        if (live_state.dev_mode) flags |= LIVE_FRAME_FREECAM;

        engine_render_benchmark_reset();
        started = clock();
        engine_render(&live_state, LIVE_HUD_FPS_TENTHS);
        render_ticks = clock() - started;
        started = clock();
        gfx_SwapDraw();
        swap_ticks = clock() - started;

        state_hash = live_state_hash(&live_state);
        if (live_section_ends(frame, section)) {
            uint8_t *record = live_section_record(section);

            write_u32(record + 32, state_hash);
            record[38] = engine_render_benchmark_lod_state();
            record[39] = live_state.room;
        }
        live_write_frame(
            frame, move_axis, turn_axis, look_axis, buttons, flags,
            update_ticks, render_ticks, swap_ticks, state_hash
        );
        *recorded_total_ticks += update_ticks + render_ticks + swap_ticks;
        route_hash = live_hash_bytes(
            route_hash,
            live_frame_record(frame) + 8,
            4
        );
        ++frame;
    }
    *wall_ticks = clock() - wall_started;
    *route_state_hash = route_hash;
    {
        uint8_t section;

        for (section = 0; section < LIVE_SECTION_COUNT; ++section) {
            uint16_t detail = read_u16(live_section_record(section) + 6);

            if (detail >= LIVE_FRAME_COUNT) return 0;
            live_frame_record(detail)[22] |= LIVE_FRAME_DETAILED;
        }
    }
    return controller.step == LIVE_ROUTE_STEP_COUNT &&
        controller.route_frame == LIVE_FRAME_COUNT;
}

static uint8_t live_run_diagnostics(
    uint32_t *final_logical_hash,
    uint32_t *final_presented_hash,
    uint16_t *detailed_frames
) {
    LiveController controller;
    uint16_t replay_crossings = 0;
    uint16_t frame = 0;

    *detailed_frames = 0;
    *final_logical_hash = 0;
    *final_presented_hash = 0;
    if (!live_reset_state()) return 0;
    live_controller_reset(&controller);
    while (frame < LIVE_FRAME_COUNT) {
        int8_t move_axis;
        int8_t turn_axis;
        int8_t look_axis;
        uint8_t buttons;
        uint8_t section;
        uint8_t before_room = live_state.room;
        uint8_t detailed;
        uint8_t section_end;
        uint32_t state_hash;

        if (!live_controller_next(
                &controller, &move_axis, &turn_axis, &look_axis,
                &buttons, &section)) {
            return 0;
        }
        (void)engine_update(
            &live_state, move_axis, turn_axis, look_axis, buttons,
            LIVE_ELAPSED_TICKS, LIVE_TICKS_PER_SECOND
        );
        if (live_state.room != before_room) ++replay_crossings;
        detailed = live_should_trace(frame, section);
        section_end = live_section_ends(frame, section);
        engine_render_benchmark_reset();
        if (detailed) engine_render_benchmark_begin();
        engine_render(&live_state, LIVE_HUD_FPS_TENTHS);
        if (detailed) {
            engine_render_benchmark_end();
            live_write_detail(section, engine_render_benchmark_read());
            ++*detailed_frames;
        }
        state_hash = live_state_hash(&live_state);
        if (state_hash != read_u32(live_frame_record(frame) + 8)) return 0;
        if (section_end) {
            uint8_t *record = live_section_record(section);
            uint32_t logical_hash = engine_render_benchmark_logical_hash();
            uint32_t presented_hash = live_presented_hash();

            if (state_hash != read_u32(record + 32) ||
                engine_render_benchmark_lod_state() != record[38] ||
                live_state.room != record[39]) {
                return 0;
            }
            write_u32(record + 24, logical_hash);
            write_u32(record + 28, presented_hash);
            *final_logical_hash = logical_hash;
            *final_presented_hash = presented_hash;
        }
        gfx_SwapDraw();
        ++frame;
    }
    return controller.step == LIVE_ROUTE_STEP_COUNT &&
        controller.route_frame == LIVE_FRAME_COUNT &&
        replay_crossings == LIVE_EXPECTED_CROSSINGS;
}

static void live_write_header(
    uint32_t switch_cost_q8,
    uint32_t graphics_init_ticks,
    uint32_t first_frame_ticks,
    uint32_t recorded_total_ticks,
    uint32_t route_state_hash,
    uint32_t final_logical_hash,
    uint32_t final_presented_hash,
    uint16_t crossings,
    uint16_t detailed_frames,
    uint32_t wall_ticks
) {
    uint8_t *header = live_report;
    uint32_t flags =
        LIVE_FLAG_FRAME_TIMINGS |
        LIVE_FLAG_FIXED_TIMESTEP |
        LIVE_FLAG_FULL_UPDATE |
        LIVE_FLAG_FULL_RENDER_PRESENT |
        LIVE_FLAG_SECTION_TRACE |
        LIVE_FLAG_SECTION_HASHES |
        LIVE_FLAG_BUILTIN_LEVEL |
        LIVE_FLAG_CONSTANT_HUD |
        LIVE_FLAG_FULL_DETAIL |
        LIVE_FLAG_DIAGNOSTIC_REPLAY |
        LIVE_FLAG_FIXED_TRACE_FRAMES
#if !TRUE3D_LIVE_AUTOTEST_HOLD
        | LIVE_FLAG_ARCHIVED
#endif
        ;

    memcpy(header, LIVE_MAGIC, 7);
    write_u16(header + 8, LIVE_FORMAT_VERSION);
    write_u16(header + 10, LIVE_HEADER_SIZE);
    write_u32(header + 12, flags);
    write_u32(header + 16, CLOCKS_PER_SEC);
    write_u32(header + 20, CLOCKS_PER_SEC);
    write_u32(header + 24, TRUE3D_BUILD_VERSION);
    write_u32(header + 28, live_route_fingerprint());
    write_u16(header + 32, LIVE_REPORT_SIZE);
    write_u16(header + 34, LIVE_SECTION_COUNT);
    write_u16(header + 36, LIVE_WARMUP_FRAMES);
    write_u16(header + 38, LIVE_FRAME_COUNT);
    write_u16(header + 40, LIVE_SECTION_RECORD_SIZE);
    write_u16(header + 42, LIVE_FRAME_RECORD_SIZE);
    header[44] = 64;
    header[45] = 48;
    header[46] = 5;
    header[47] = 1;
    header[48] = TRUE3D_BENCH_CATEGORY_COUNT;
    header[49] = 11;
    write_u16(header + 50, LIVE_TICKS_PER_SECOND);
    write_u16(header + 52, LIVE_ELAPSED_TICKS);
    write_u16(header + 54, LIVE_EXPECTED_CROSSINGS);
    write_u32(header + 56, switch_cost_q8);
    write_u32(header + 64, graphics_init_ticks);
    write_u32(header + 68, first_frame_ticks);
    write_u32(header + 72, recorded_total_ticks);
    write_u32(header + 76, route_state_hash);
    write_u32(header + 80, final_logical_hash);
    write_u32(header + 84, final_presented_hash);
    write_u16(header + 88, crossings);
    write_u16(header + 90, detailed_frames);
    write_u16(header + 92, LIVE_REPORT_SIZE);
    header[94] = LIVE_ROUTE_STEP_COUNT;
    header[95] = 0;
    write_u32(header + 96, wall_ticks);
    write_u16(header + 100, LIVE_HUD_FPS_TENTHS);
    header[102] = 0;
    header[103] = TRUE3D_LEVEL_VERSION;
    write_u32(header + 60, live_crc32(
        live_report + LIVE_HEADER_SIZE,
        LIVE_REPORT_SIZE - LIVE_HEADER_SIZE
    ));
}

static void live_put_hex32(uint32_t value) {
    static const char digits[] = "0123456789ABCDEF";
    char text[9];
    uint8_t index;

    text[8] = '\0';
    for (index = 8; index != 0; ) {
        text[--index] = digits[value & 0x0Fu];
        value >>= 4;
    }
    os_PutStrFull(text);
}

static void live_show_failure(const char *message) {
    os_ClrHome();
    os_SetCursorPos(0, 0);
    os_PutStrFull("True3D benchmark failed");
    os_SetCursorPos(2, 0);
    os_PutStrFull(message);
    os_SetCursorPos(8, 0);
    os_PutStrFull("Press any key");
    while (os_GetCSC() != 0) {
    }
    while (os_GetCSC() == 0) {
    }
}

static void live_show_result(
    uint8_t saved,
    uint8_t archived,
    uint16_t crossings
) {
    os_ClrHome();
    os_SetCursorPos(0, 0);
    os_PutStrFull(saved ? "True3D live benchmark done" :
        "True3D benchmark save failed");
    os_SetCursorPos(2, 0);
    os_PutStrFull("Frames: 854");
    os_SetCursorPos(3, 0);
    os_PutStrFull("Portal crossings: ");
    os_PutStrFull(crossings == 4 ? "4" : "unexpected");
    os_SetCursorPos(5, 0);
    os_PutStrFull("Result: T3DLIVE");
    os_SetCursorPos(6, 0);
    os_PutStrFull(archived ? "Archived safely" : "Stored in RAM");
    os_SetCursorPos(8, 0);
    os_PutStrFull("Build: ");
    live_put_hex32(TRUE3D_BUILD_VERSION);
    os_SetCursorPos(10, 0);
    os_PutStrFull("Press any key");
    while (os_GetCSC() != 0) {
    }
    while (os_GetCSC() == 0) {
    }
}

int true3d_live_benchmark_run(void) {
    uint16_t saved_timer_control;
    uint32_t saved_timer_count;
    uint32_t switch_cost_q8;
    uint32_t graphics_init_ticks;
    uint32_t first_frame_ticks;
    uint32_t recorded_total_ticks = 0;
    uint32_t route_state_hash = 0;
    uint32_t final_logical_hash = 0;
    uint32_t final_presented_hash = 0;
    uint32_t wall_ticks = 0;
    uint16_t crossings = 0;
    uint16_t detailed_frames = 0;
    clock_t started;
    uint8_t route_ok;
    uint8_t diagnostics_ok;
    uint8_t saved;
    uint8_t archived = 0;

    if (!live_route_is_valid() || !true3d_level_builtin_view(&live_level)) {
        live_show_failure("Route or built-in level invalid.");
        return 1;
    }
    if (!live_prepare_report()) {
        live_show_failure("No room for T3DLIVE.");
        return 1;
    }
    live_write_sections();

    saved_timer_control = timer_Control;
    saved_timer_count = timer_GetSafe(
        3,
        (saved_timer_control & TIMER3_UP) != 0 ? TIMER_UP : TIMER_DOWN
    );
    timer_Disable(3);
    timer_Set(3, 0);
    timer_Enable(3, TIMER_32K, TIMER_NOINT, TIMER_UP);

    gfx_Begin();
    gfx_SetDrawBuffer();
    started = clock();
    engine_graphics_init();
    graphics_init_ticks = clock() - started;
    switch_cost_q8 = engine_render_benchmark_calibrate();
    first_frame_ticks = live_first_frame();
    route_ok = first_frame_ticks != 0 && live_warmup() && live_run_route(
        &recorded_total_ticks,
        &route_state_hash,
        &crossings,
        &wall_ticks
    );
    diagnostics_ok = route_ok && live_run_diagnostics(
        &final_logical_hash,
        &final_presented_hash,
        &detailed_frames
    );
    live_write_header(
        switch_cost_q8,
        graphics_init_ticks,
        first_frame_ticks,
        recorded_total_ticks,
        route_state_hash,
        final_logical_hash,
        final_presented_hash,
        crossings,
        detailed_frames,
        wall_ticks
    );
    gfx_End();

    saved = diagnostics_ok && crossings == LIVE_EXPECTED_CROSSINGS &&
        detailed_frames == LIVE_SECTION_COUNT && live_commit_report();
    if (!saved && live_report_handle != 0) {
        ti_Close(live_report_handle);
        live_report_handle = 0;
        (void)ti_Delete(LIVE_TEMP_NAME);
    }
    if (saved) {
#if TRUE3D_LIVE_AUTOTEST_HOLD
        archived = 0;
#else
        archived = live_archive_report();
#endif
    }

    timer_Disable(3);
    timer_Set(3, saved_timer_count);
    timer_Control = saved_timer_control;

#if TRUE3D_LIVE_AUTOTEST_HOLD
    for (;;) {
    }
#endif

    live_show_result(saved, archived, crossings);
    return saved ? 0 : 1;
}

#endif
