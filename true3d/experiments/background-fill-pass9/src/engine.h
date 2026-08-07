#ifndef TRUE3D_ENGINE_H
#define TRUE3D_ENGINE_H

#include <stdint.h>

#include "level.h"

/* Stable YYMMDD/revision ID written into every benchmark result. */
#define TRUE3D_BUILD_VERSION 0x26080601UL

#ifndef TRUE3D_RENDER_BENCHMARK
#define TRUE3D_RENDER_BENCHMARK 0
#endif

typedef enum {
    TRUE3D_BENCH_ADMIN = 0,
    TRUE3D_BENCH_SETUP,
    TRUE3D_BENCH_ROOT_GEOMETRY,
    TRUE3D_BENCH_ROOT_FILL,
    TRUE3D_BENCH_PORTAL_SETUP,
    TRUE3D_BENCH_PORTAL_GEOMETRY,
    TRUE3D_BENCH_PORTAL_FILL,
    TRUE3D_BENCH_WAIT,
    TRUE3D_BENCH_PRESENT,
    TRUE3D_BENCH_OVERLAY,
    TRUE3D_BENCH_CATEGORY_COUNT
} True3DBenchmarkCategory;

#if TRUE3D_RENDER_BENCHMARK
typedef struct {
    uint32_t raw_ticks[TRUE3D_BENCH_CATEGORY_COUNT];
    uint16_t entries[TRUE3D_BENCH_CATEGORY_COUNT];
    uint32_t total_ticks;
    uint16_t transformed_vertices;
    uint16_t projected_points;
    uint16_t rasterized_polygons;
    uint16_t raster_rows;
    uint16_t filled_spans;
    uint16_t filled_pixels;
    uint16_t portal_composite_pixels;
    uint16_t portal_clip_pixels;
    uint16_t full_portal_views;
    uint16_t lod_portal_views;
    uint16_t edge_division_fallbacks;
} True3DRenderBenchmark;
#endif

#define ENGINE_BUTTON_JUMP (1u << 0)
#define ENGINE_BUTTON_ORANGE_PORTAL (1u << 1)
#define ENGINE_BUTTON_BLUE_PORTAL (1u << 2)
#define ENGINE_BUTTON_DEV_MODE (1u << 3)
#define ENGINE_BUTTON_FLY_DOWN (1u << 4)
#define ENGINE_BUTTON_RESOLUTION (1u << 5)

typedef int24_t fixed_t;

typedef struct {
    fixed_t x;
    fixed_t y;
    fixed_t z;
} Vec3;

typedef struct {
    Vec3 position;
    Vec3 velocity;
    Vec3 right;
    Vec3 up;
    Vec3 forward;
    uint8_t yaw;
    int8_t pitch;
    uint8_t room;
    uint8_t previous_buttons;
    uint8_t grounded;
    uint8_t dev_mode;
    uint8_t render_shift;
} EngineState;

_Static_assert(sizeof(EngineState) <= 64u, "True-3D player state exceeded 64 bytes");

uint8_t engine_init(EngineState *state, const True3DLevelView *level);
void engine_graphics_init(void);
uint8_t engine_update(
    EngineState *state,
    int8_t move_axis,
    int8_t turn_axis,
    int8_t look_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
);
void engine_render(const EngineState *state, uint16_t fps_tenths);

#if TRUE3D_CLEAR_VALIDATION
uint24_t engine_validate_root_clear(
    EngineState *state,
    uint16_t sample_count,
    uint16_t *first_failed_sample,
    uint16_t *first_failed_pixel
);
#endif

#if TRUE3D_RENDER_BENCHMARK
void engine_render_benchmark_reset(void);
void engine_render_benchmark_begin(void);
void engine_render_benchmark_end(void);
uint32_t engine_render_benchmark_calibrate(void);
const True3DRenderBenchmark *engine_render_benchmark_read(void);
uint8_t engine_render_benchmark_lod_state(void);
uint32_t engine_render_benchmark_logical_hash(void);
#endif

#endif
