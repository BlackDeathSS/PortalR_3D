#ifndef PORTAL3D_GAME_H
#define PORTAL3D_GAME_H

#include <stdint.h>

#ifndef RENDER_PROFILE
#define RENDER_PROFILE 0
#endif
#ifndef RENDER_RAY_DIAGNOSTIC
#define RENDER_RAY_DIAGNOSTIC 0
#endif
#ifndef RENDER_BENCHMARK
#define RENDER_BENCHMARK 0
#endif

#define PORTAL_BUTTON_PRIMARY  (1u << 0)
#define PORTAL_BUTTON_SECONDARY (1u << 1)
#define PORTAL_BUTTON_CLEAR    (1u << 2)

#define GAME_RENDER_LOGICAL_COLUMNS 80
#define GAME_RENDER_COLUMN_WIDTH 4
#define GAME_RENDER_TEXTURE_SIZE 16
#define GAME_RENDER_MAX_PORTAL_DEPTH 6

typedef int24_t fixed_t;

typedef struct {
    uint8_t x;
    uint8_t y;
    uint8_t direction;
    uint8_t valid;
} Portal;

typedef struct {
    fixed_t player_x;
    fixed_t player_y;
    uint16_t angle;
    Portal primary;
    Portal secondary;
    uint8_t previous_buttons;
} GameState;

#if RENDER_PROFILE
typedef struct {
    uint32_t wait_ticks;
    uint32_t background_ticks;
    uint32_t columns_ticks;
    uint16_t cast_count;
    uint8_t max_depth;
#if RENDER_RAY_DIAGNOSTIC
    uint8_t near_valid;
    uint8_t near_column;
    uint8_t near_layer;
    uint8_t near_side;
    uint8_t near_origin_fraction;
    uint8_t near_hit_cell;
    uint16_t near_minor;
    fixed_t near_raw_distance;
    fixed_t near_projected_distance;
#endif
} GameRenderProfile;
#endif

#if RENDER_BENCHMARK
typedef enum {
    GAME_RENDER_BENCH_ADMIN = 0,
    GAME_RENDER_BENCH_WAIT,
    GAME_RENDER_BENCH_BACKGROUND,
    GAME_RENDER_BENCH_DDA,
    GAME_RENDER_BENCH_PORTAL_TRACE,
    GAME_RENDER_BENCH_WALL_DRAW,
    GAME_RENDER_BENCH_PORTAL_DRAW,
    GAME_RENDER_BENCH_CATEGORY_COUNT
} GameRenderBenchmarkCategory;

_Static_assert(GAME_RENDER_BENCH_CATEGORY_COUNT == 7,
    "Render benchmark report requires exactly seven categories");

typedef struct {
    uint32_t raw_ticks[GAME_RENDER_BENCH_CATEGORY_COUNT];
    uint16_t entries[GAME_RENDER_BENCH_CATEGORY_COUNT];
    uint32_t total_ticks;
    uint16_t cast_count;
    uint16_t portal_candidates;
    uint16_t linked_exits;
    uint16_t portal_transforms;
    uint16_t wall_calls;
    uint16_t mask_calls;
    uint32_t dda_steps;
    uint32_t textured_rows;
} GameRenderBenchmark;
#endif

_Static_assert(sizeof(GameState) <= 32u, "GameState exceeded its RAM budget");

void game_init(GameState *game);
void game_graphics_init(void);
uint8_t game_update(
    GameState *game,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
);
void game_render(const GameState *game);
#if RENDER_PROFILE
const GameRenderProfile *game_get_render_profile(void);
#endif
#if RENDER_BENCHMARK
void game_render_benchmark_reset(void);
void game_render_benchmark_begin(void);
void game_render_benchmark_end(void);
uint32_t game_render_benchmark_calibrate(void);
const GameRenderBenchmark *game_render_benchmark_read(void);
#endif

#endif
