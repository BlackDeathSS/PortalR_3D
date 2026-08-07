#include "game.h"

#include <graphx.h>
#include <stddef.h>
#include <string.h>
#if RENDER_PROFILE
#include <time.h>
#endif
#if RENDER_BENCHMARK
#include <sys/timers.h>
#endif

#ifndef RENDER_ASM_RAYCAST
#define RENDER_ASM_RAYCAST 1
#endif

#ifndef RENDER_ASM_WALLS
#define RENDER_ASM_WALLS 1
#endif

#ifndef RENDER_ASM_PORTALS
#define RENDER_ASM_PORTALS 1
#endif

#ifndef RENDER_ASM_TRANSFORM
#define RENDER_ASM_TRANSFORM 1
#endif

#ifndef RENDER_ASM_PORTAL_GEOMETRY
#define RENDER_ASM_PORTAL_GEOMETRY 1
#endif

#ifndef RENDER_COLUMN_NOINLINE
#define RENDER_COLUMN_NOINLINE 1
#endif

#ifndef RENDER_ASM_BACKGROUND
#define RENDER_ASM_BACKGROUND 1
#endif

#ifndef RENDER_LAYER_MAJOR_PORTALS
#define RENDER_LAYER_MAJOR_PORTALS 0
#endif

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)
#define FIXED_INF ((fixed_t)0x3FFFFF)

#define MAP_WIDTH 15
#define MAP_HEIGHT 15
/* Four-pixel ray columns preserve the detailed 80-ray view. */
#define LOGICAL_COLUMNS GAME_RENDER_LOGICAL_COLUMNS
#define COLUMN_WIDTH GAME_RENDER_COLUMN_WIDTH
#define WALL_TEXTURE_WIDTH GAME_RENDER_TEXTURE_WIDTH
#define WALL_TEXTURE_HEIGHT GAME_RENDER_TEXTURE_HEIGHT
#define WALL_TEXTURE_MASK (WALL_TEXTURE_HEIGHT - 1)
#define WALL_TEXTURE_COUNT 4
#define WALL_TEXTURE_DESCRIPTOR_SIZE 2u
#define WALL_TEXTURE_DESCRIPTOR_COUNT \
    (WALL_TEXTURE_COUNT * WALL_TEXTURE_WIDTH * WALL_TEXTURE_HEIGHT)
#define WALL_TEXTURE_BOUNDARY_COUNT (WALL_TEXTURE_HEIGHT + 1)
#define MAX_WALL_TEXTURE_PROFILES 256
#define WALL_BASE_COLOR_COUNT 8
#define WALL_SHADE_LEVELS 4
#define WALL_PALETTE_STRIDE (WALL_BASE_COLOR_COUNT * WALL_SHADE_LEVELS)
#define FLOOR_NEAR_DISTANCE (FIXED_ONE + 4)
#define FLOOR_FAR_DISTANCE (FIXED_ONE * 16)
#define FLOOR_PROJECT_LIMIT 4096
#define WALL_HEIGHT_TABLE_SHIFT 2
#define WALL_HEIGHT_TABLE_SIZE 2048
#define WALL_HEIGHT_NUMERATOR \
    ((GFX_LCD_HEIGHT * FIXED_ONE) >> WALL_HEIGHT_TABLE_SHIFT)
#define FLOOR_NEAR_HEIGHT \
    (WALL_HEIGHT_NUMERATOR / \
        (FLOOR_NEAR_DISTANCE >> WALL_HEIGHT_TABLE_SHIFT))
#define FLOOR_FAR_HEIGHT \
    (WALL_HEIGHT_NUMERATOR / \
        (FLOOR_FAR_DISTANCE >> WALL_HEIGHT_TABLE_SHIFT))
#define FLOOR_NEAR_SCREEN_Y (GFX_LCD_HEIGHT / 2 + FLOOR_NEAR_HEIGHT / 2)
#define FLOOR_FAR_SCREEN_Y (GFX_LCD_HEIGHT / 2 + FLOOR_FAR_HEIGHT / 2)
#define WALL_HEIGHT_FAR 7
#define WALL_HEIGHT_MAX (GFX_LCD_HEIGHT * 4)
#define MAX_RENDER_PORTAL_DEPTH GAME_RENDER_MAX_PORTAL_DEPTH
#define MAX_PORTAL_TRACE_DEPTH 12
#define PORTAL_RECURSE_MIN_HEIGHT 3
#define GRID_SEGMENT_CAPACITY ((MAP_WIDTH + 1) + (MAP_HEIGHT + 1))
#define PLAYER_RADIUS 44
#define FIELD_OF_VIEW 169
#define MOVE_SPEED 600
#define TURN_SPEED 12
#define ANGLE_STEPS 64
#define ANGLE_FRACTION_BITS 8
#define ANGLE_WRAP (ANGLE_STEPS << ANGLE_FRACTION_BITS)
#define ANGLE_MASK (ANGLE_WRAP - 1)

enum Direction {
    DIR_NORTH = 0,
    DIR_SOUTH = 1,
    DIR_WEST = 2,
    DIR_EAST = 3
};

enum PortalKind {
    PORTAL_NONE = 0,
    PORTAL_PRIMARY = 1,
    PORTAL_SECONDARY = 2,
    PORTAL_BUILTIN = 3
};

enum ColorIndex {
    COLOR_BLACK = 0,
    COLOR_SKY = 1,
    COLOR_SKY_HORIZON = 2,
    COLOR_FLOOR = 3,
    COLOR_FLOOR_NEAR = 4,
    COLOR_NORTH = 5,
    COLOR_NORTH_DARK = 6,
    COLOR_SOUTH = 7,
    COLOR_SOUTH_DARK = 8,
    COLOR_EAST = 9,
    COLOR_EAST_DARK = 10,
    COLOR_WEST = 11,
    COLOR_WEST_DARK = 12,
    COLOR_PRIMARY = 13,
    COLOR_SECONDARY = 14,
    COLOR_BUILTIN = 15,
    COLOR_CEILING = 16,
    COLOR_CEILING_NEAR = 17,
    COLOR_TEXTURE_BASE = 18
};

typedef struct {
    uint8_t x;
    uint8_t y;
    uint8_t direction;
    uint8_t target_x;
    uint8_t target_y;
    uint8_t target_direction;
} PortalLink;

#if RENDER_ASM_PORTALS
extern uint8_t render_asm_find_portal(
    const GameState *game,
    uint8_t x,
    uint8_t y,
    uint8_t direction,
    Portal *exit,
    uint8_t *kind,
    uint8_t *portal_id
);
#endif

typedef struct {
    fixed_t distance;
    uint8_t map_x;
    uint8_t map_y;
    int8_t step_x;
    int8_t step_y;
    uint8_t side;
    uint8_t wall_u;
    uint8_t wall_direction;
    uint8_t portal_kind;
    fixed_t wall_position;
} RayHit;

/*
 * One exact-DDA state is reused by every segment of the current logical ray.
 * The renderer is deliberately single-threaded and already uses fixed global
 * assembly scratch, so this removes repeated C ABI traffic without adding a
 * per-column array.
 *
 * The zero padding around each 16-bit magnitude is intentional.  Assembly can
 * load abs_x/abs_y either unshifted at offsets 25/28 or shifted left by eight
 * at offsets 24/27.
 */
typedef struct __attribute__((packed)) {
    fixed_t origin_x;
    fixed_t origin_y;
    fixed_t ray_x;
    fixed_t ray_y;
    fixed_t delta_x;
    fixed_t delta_y;
    fixed_t qx;
    fixed_t qy;
    uint8_t abs_x_shift;
    uint16_t abs_x;
    uint8_t abs_y_shift;
    uint16_t abs_y;
    uint8_t abs_end;
    uint24_t threshold;
    int24_t map_step_x;
    int24_t map_step_y;
    RayHit *hit;
    const GameState *game;
    uint8_t primary_tile;
    uint8_t secondary_tile;
    Portal portal_exit;
    uint8_t portal_kind;
    uint8_t portal_id;
    uint8_t portal_has_exit;
} RayDDAState;

#if RENDER_LAYER_MAJOR_PORTALS
/* One affine plan is shared by a contiguous first-portal ray run. */
typedef struct __attribute__((packed)) {
    fixed_t tangent_base;
    fixed_t normal;
    uint8_t flags;
    uint8_t tangent_to_x;
} PortalTransformPlan;

/* Complete exact checkpoint immediately after a layer-zero DDA hit. */
typedef struct __attribute__((packed)) {
    RayDDAState dda;
    RayHit hit;
    fixed_t distance_bias;
    uint8_t clip_start;
    uint8_t clip_end;
    uint8_t draw_clip_start;
    uint8_t draw_clip_end;
    uint8_t visited_low;
    uint8_t visited_high;
    uint8_t count;
    uint8_t continues;
} LayerRay;

typedef struct __attribute__((packed)) {
    uint8_t first;
    uint8_t one_past_last;
    uint8_t portal_id;
    PortalTransformPlan plan;
} FirstPortalRun;
#endif

#if RENDER_ASM_RAYCAST
extern RayDDAState render_ray_state;
extern void render_asm_cast_wall_begin(
    fixed_t origin_x,
    fixed_t origin_y,
    fixed_t ray_x,
    fixed_t ray_y,
    RayHit *hit
);
extern void render_asm_cast_wall_continue(RayHit *hit);
#endif

#if RENDER_ASM_TRANSFORM
extern int8_t render_asm_transform_ray(
    const RayHit *entry,
    const Portal *exit
);
extern int8_t render_asm_transform_ray_state(void);
#if RENDER_LAYER_MAJOR_PORTALS
extern void render_asm_transform_ray_predecoded_state(void);
#endif
#endif


typedef struct {
    uint16_t full_height;
    uint8_t start;
    uint8_t end;
    const uint8_t *boundaries;
    uint8_t center;
} WallContext;

#if RENDER_ASM_PORTAL_GEOMETRY
extern void render_asm_portal_opening(
    const RayHit *ray,
    const WallContext *context,
    uint8_t *top,
    uint8_t *bottom
);
#endif

#if RENDER_ASM_WALLS
extern void render_asm_draw_wall_segment(
    const RayHit *ray,
    uint24_t x,
    uint8_t start,
    uint8_t end,
    const WallContext *full_context
);
extern void render_asm_draw_solid_segment(
    uint24_t x,
    uint8_t start,
    uint8_t end,
    uint8_t color
);
extern void render_asm_draw_portal_mask(
    const RayHit *ray,
    const WallContext *context,
    uint24_t x,
    uint8_t clip_start,
    uint8_t clip_end,
    uint8_t top,
    uint8_t bottom
);
#endif

typedef struct {
    RayHit hit;
    uint8_t primary_tile;
    uint8_t secondary_tile;
} RenderScratch;

typedef struct {
    fixed_t value;
    fixed_t step;
    uint8_t error;
    uint8_t error_step;
} RayStepper;

typedef struct {
    fixed_t whole;
    uint8_t fraction;
} FixedScale;

#if RENDER_ASM_BACKGROUND
/*
 * Only clipped slanted lines reach the deferred ceiling pass. Projection is
 * clamped to +/-4096, so signed 16-bit endpoints preserve every value while
 * halving this 32-entry scratch array.
 */
typedef struct {
    int16_t far_x;
    int16_t near_x;
} GridSegment;
#else
typedef struct {
    int24_t far_x;
    int24_t near_x;
    uint8_t far_y;
    uint8_t kind;
} GridSegment;

enum GridSegmentKind {
    GRID_SLANTED_NOCLIP = 0,
    GRID_HORIZONTAL = 1,
    GRID_SLANTED_CLIPPED = 2
};
#endif

typedef struct {
    fixed_t positive_limit;
    fixed_t negative_limit;
    uint16_t height;
    uint8_t screen_y;
} GridProjection;

typedef uint24_t packed24_t __attribute__((aligned(1), may_alias));

typedef struct {
    packed24_t packed;
    uint8_t palette;
} WallColor;

typedef struct {
    uint24_t offset;
    uint8_t padding;
} ScreenRow;

static RenderScratch render_scratch;
#if RENDER_LAYER_MAJOR_PORTALS
PortalTransformPlan render_layer_transform_plan;
static LayerRay render_layer_rays[LOGICAL_COLUMNS];
static FirstPortalRun render_first_portal_runs[LOGICAL_COLUMNS];
#define RENDER_LAYER_MAJOR_BYTES \
    (sizeof(render_layer_transform_plan) + sizeof(render_layer_rays) + \
        sizeof(render_first_portal_runs))
#else
#define RENDER_LAYER_MAJOR_BYTES 0u
#endif
#if RENDER_PROFILE
static GameRenderProfile render_profile;
#endif
#if RENDER_BENCHMARK
static GameRenderBenchmark render_benchmark;
static uint32_t render_benchmark_last;
static uint8_t render_benchmark_category;
static uint8_t render_benchmark_active;

static inline __attribute__((always_inline)) uint24_t
render_benchmark_timer_direct(void) {
    return *(volatile uint24_t *)0xF20020;
}

/*
 * Timer 3 runs at only 32.768 kHz during the benchmark.  A direct 24-bit
 * load avoids the atomic_load_32() function call, while the normally-equal
 * second read detects a rare byte-carry tear.  A third read resolves only
 * that exceptional case.  The 24-bit counter cannot fully wrap in a frame.
 */
static inline __attribute__((always_inline)) uint32_t
render_benchmark_timer(void) {
    uint24_t first = render_benchmark_timer_direct();
    uint24_t second = render_benchmark_timer_direct();

    if ((uint24_t)(second - first) <= 1u) {
        return second;
    }
    {
        uint24_t third = render_benchmark_timer_direct();

        if ((uint24_t)(third - second) <= 1u) {
            return third;
        }
    }
    return first;
}

static inline __attribute__((always_inline)) void render_benchmark_charge(
    uint32_t now
) {
    uint32_t elapsed = now - render_benchmark_last;

    render_benchmark.raw_ticks[render_benchmark_category] += elapsed;
    render_benchmark.total_ticks += elapsed;
    render_benchmark_last = now;
}

static inline __attribute__((always_inline)) void render_benchmark_switch(
    GameRenderBenchmarkCategory category
) {
    uint32_t now;

    if (!render_benchmark_active ||
        render_benchmark_category == (uint8_t)category) {
        return;
    }
    now = render_benchmark_timer();
    render_benchmark_charge(now);
    render_benchmark_category = (uint8_t)category;
    ++render_benchmark.entries[category];
}

void game_render_benchmark_reset(void) {
    render_benchmark_active = 0;
    render_benchmark_last = 0;
    render_benchmark_category = GAME_RENDER_BENCH_ADMIN;
    memset(&render_benchmark, 0, sizeof(render_benchmark));
}

void game_render_benchmark_begin(void) {
    if (render_benchmark_active) {
        return;
    }
    render_benchmark_category = GAME_RENDER_BENCH_ADMIN;
    ++render_benchmark.entries[GAME_RENDER_BENCH_ADMIN];
    render_benchmark_last = render_benchmark_timer();
    render_benchmark_active = 1;
}

void game_render_benchmark_end(void) {
    if (!render_benchmark_active) {
        return;
    }
    render_benchmark_charge(render_benchmark_timer());
    render_benchmark_active = 0;
}

uint32_t game_render_benchmark_calibrate(void) {
    GameRenderBenchmark saved_benchmark;
    uint32_t saved_last;
    uint32_t best = 0xFFFFFFFFUL;
    uint8_t saved_category;
    uint8_t saved_active;
    uint8_t batch;

    if (render_benchmark_active) {
        return 0;
    }
    saved_benchmark = render_benchmark;
    saved_last = render_benchmark_last;
    saved_category = render_benchmark_category;
    saved_active = render_benchmark_active;

    for (batch = 0; batch < 8; ++batch) {
        uint8_t transition;
        uint32_t elapsed;

        game_render_benchmark_reset();
        game_render_benchmark_begin();
        for (transition = 0; transition < 64; ++transition) {
            render_benchmark_switch((transition & 1u) != 0 ?
                GAME_RENDER_BENCH_ADMIN : GAME_RENDER_BENCH_WAIT);
        }
        game_render_benchmark_end();
        elapsed = render_benchmark.total_ticks;
        if (elapsed < best) {
            best = elapsed;
        }
    }

    render_benchmark = saved_benchmark;
    render_benchmark_last = saved_last;
    render_benchmark_category = saved_category;
    render_benchmark_active = saved_active;
    /* Q8 retains the sub-tick switch cost of the low-overhead 32K timer.
     * There are 64 transitions plus the initial ADMIN timing interval. */
    return (best << 8) / 65u;
}

const GameRenderBenchmark *game_render_benchmark_read(void) {
    return &render_benchmark;
}

#define RENDER_BENCHMARK_SWITCH(category) do { \
    if (render_benchmark_active) { \
        render_benchmark_switch(category); \
    } \
} while (0)
#else
#define RENDER_BENCHMARK_SWITCH(category) ((void)0)
#endif

#if RENDER_BENCHMARK
static inline __attribute__((always_inline)) uint16_t
render_benchmark_clipped_rows(
    uint8_t start,
    uint8_t end,
    uint8_t clip_start,
    uint8_t clip_end
) {
    if (start < clip_start) start = clip_start;
    if (end > clip_end) end = clip_end;
    return end > start ? (uint16_t)(end - start) : 0u;
}

static inline __attribute__((always_inline)) void render_benchmark_count_wall(
    const WallContext *context,
    uint8_t clip_start,
    uint8_t clip_end
) {
    if (!render_benchmark_active) {
        return;
    }
    ++render_benchmark.wall_calls;
    render_benchmark.textured_rows += render_benchmark_clipped_rows(
        context->start, context->end, clip_start, clip_end
    );
}

static inline __attribute__((always_inline)) void render_benchmark_count_mask(
    const WallContext *context,
    uint8_t clip_start,
    uint8_t clip_end,
    uint8_t top,
    uint8_t bottom
) {
    uint8_t thickness;
    uint8_t top_limit;

    if (!render_benchmark_active) {
        return;
    }
    ++render_benchmark.mask_calls;
    thickness = (uint8_t)(bottom - top) >= 8u ? 2u : 1u;
    top_limit = (uint8_t)(top + thickness);
    if (bottom <= top_limit) {
        render_benchmark.textured_rows += render_benchmark_clipped_rows(
            context->start, context->end, clip_start, clip_end
        );
        return;
    }
    render_benchmark.textured_rows += render_benchmark_clipped_rows(
        context->start, top, clip_start, clip_end
    );
    render_benchmark.textured_rows += render_benchmark_clipped_rows(
        bottom, context->end, clip_start, clip_end
    );
}
#endif

GridProjection render_grid_near_projection;
GridProjection grid_far_projection;
static GridSegment grid_segments[GRID_SEGMENT_CAPACITY];
static uint16_t render_wall_scale_offset[WALL_HEIGHT_TABLE_SIZE];
static WallContext render_wall_scale_profiles[MAX_WALL_TEXTURE_PROFILES];
ScreenRow render_screen_rows[GFX_LCD_HEIGHT];
#define SCREEN_ROW_STORAGE_BYTES sizeof(render_screen_rows)
/*
 * A single full-turn sine table also supplies cosine through a quarter-turn
 * index offset.  It is generated once at startup with the exact signed
 * truncation of direction_for_angle(), replacing four generic 24-bit
 * multiply/shift helper calls on every moving frame.
 */
static int16_t render_direction_y_by_angle[ANGLE_WRAP];
static int16_t render_fov_by_direction[FIXED_ONE * 2u + 1u];
uint8_t render_wall_texture_boundaries
    [MAX_WALL_TEXTURE_PROFILES][WALL_TEXTURE_BOUNDARY_COUNT];
/*
 * Interleaved {WallColor byte offset, next source row} descriptors let
 * assembly fetch both values from one table address and use the color offset
 * without scaling it in the draw loop. The final pad byte makes its three-byte
 * load safe for the last two-byte descriptor.
 */
uint8_t render_wall_texture_runs
    [WALL_TEXTURE_DESCRIPTOR_COUNT * WALL_TEXTURE_DESCRIPTOR_SIZE + 1u];
WallColor render_wall_colors
    [WALL_TEXTURE_COUNT][WALL_SHADE_LEVELS][WALL_BASE_COLOR_COUNT];
uint8_t render_portal_profile_by_u[256];

_Static_assert(LOGICAL_COLUMNS * COLUMN_WIDTH == GFX_LCD_WIDTH,
    "Ray columns must cover the complete LCD width");
_Static_assert(LOGICAL_COLUMNS == 80u && FIELD_OF_VIEW < 240u,
    "Division-free ray stepper quotient ranges changed");
_Static_assert(COLUMN_WIDTH == 4,
    "draw_wall_run must match the configured ray-column width");
_Static_assert(WALL_TEXTURE_WIDTH == 16u && WALL_TEXTURE_HEIGHT == 8u,
    "Assembly texture addressing requires the 16-by-8 layout");
_Static_assert(FLOOR_NEAR_HEIGHT == 236u && FLOOR_NEAR_SCREEN_Y == 238u,
    "Assembly near-grid projection constants changed");
_Static_assert(FLOOR_FAR_HEIGHT == 15u && FLOOR_FAR_SCREEN_Y == 127u,
    "Assembly far-grid projection constants changed");
_Static_assert(
    COLOR_SKY_HORIZON == 2u && COLOR_FLOOR == 3u && COLOR_CEILING == 16u,
    "Assembly split-background palette constants changed");
_Static_assert(GFX_LCD_WIDTH == 320u && GFX_LCD_HEIGHT == 240u,
    "Assembly split-background dimensions changed");
_Static_assert(WALL_TEXTURE_COUNT == 4,
    "wall_material_for_ray uses a two-bit material index");
_Static_assert(
    COLOR_TEXTURE_BASE + WALL_TEXTURE_COUNT * WALL_PALETTE_STRIDE <= 256,
    "Wall material palettes exceed indexed-color VRAM"
);
_Static_assert(sizeof(RenderScratch) <= 256u, "Render scratch exceeded its RAM budget");
#if RENDER_ASM_BACKGROUND
_Static_assert(sizeof(GridSegment) == 4u,
    "Assembly clipped-grid segment layout changed");
_Static_assert(offsetof(GridSegment, near_x) == 2u,
    "Assembly clipped-grid near-X offset changed");
#else
_Static_assert(sizeof(GridSegment) == 8u,
    "GridSegment must retain pointer-step indexing");
_Static_assert(offsetof(GridSegment, kind) == 7u,
    "GridSegment.kind offset changed");
#endif
_Static_assert(offsetof(GridProjection, height) == 6u,
    "Assembly GridProjection.height offset changed");
_Static_assert(offsetof(GridProjection, screen_y) == 8u,
    "Assembly GridProjection.screen_y offset changed");
_Static_assert(sizeof(WallColor) == 4u, "WallColor must stay tightly packed");
_Static_assert(sizeof(ScreenRow) == 4u, "ScreenRow must retain shift-only indexing");
_Static_assert(sizeof(WallContext) == 8u, "Assembly WallContext layout changed");
_Static_assert(offsetof(WallContext, start) == 2u,
    "Assembly WallContext.start offset changed");
_Static_assert(offsetof(WallContext, boundaries) == 4u,
    "Assembly WallContext.boundaries offset changed");
_Static_assert(offsetof(WallContext, center) == 7u,
    "Assembly WallContext.center offset changed");
_Static_assert(sizeof(RayHit) == 14u, "Assembly RayHit layout changed");
_Static_assert(sizeof(RayDDAState) == 55u,
    "Assembly RayDDAState layout changed");
#if RENDER_LAYER_MAJOR_PORTALS
_Static_assert(sizeof(PortalTransformPlan) == 8u,
    "Predecoded portal-plan ABI changed");
_Static_assert(sizeof(LayerRay) == 80u,
    "Layer-major exact-ray checkpoint changed");
_Static_assert(sizeof(FirstPortalRun) == 11u,
    "Layer-major run descriptor changed");
#endif
_Static_assert(offsetof(RayDDAState, origin_y) == 3u,
    "Assembly RayDDAState.origin_y offset changed");
_Static_assert(offsetof(RayDDAState, ray_x) == 6u,
    "Assembly RayDDAState.ray_x offset changed");
_Static_assert(offsetof(RayDDAState, ray_y) == 9u,
    "Assembly RayDDAState.ray_y offset changed");
_Static_assert(offsetof(RayDDAState, delta_x) == 12u,
    "Assembly RayDDAState.delta_x offset changed");
_Static_assert(offsetof(RayDDAState, delta_y) == 15u,
    "Assembly RayDDAState.delta_y offset changed");
_Static_assert(offsetof(RayDDAState, qx) == 18u,
    "Assembly RayDDAState.qx offset changed");
_Static_assert(offsetof(RayDDAState, qy) == 21u,
    "Assembly RayDDAState.qy offset changed");
_Static_assert(offsetof(RayDDAState, abs_x_shift) == 24u,
    "Assembly RayDDAState.abs_x_shift offset changed");
_Static_assert(offsetof(RayDDAState, abs_x) == 25u,
    "Assembly RayDDAState.abs_x offset changed");
_Static_assert(offsetof(RayDDAState, abs_y_shift) == 27u,
    "Assembly RayDDAState.abs_y_shift offset changed");
_Static_assert(offsetof(RayDDAState, abs_y) == 28u,
    "Assembly RayDDAState.abs_y offset changed");
_Static_assert(offsetof(RayDDAState, abs_end) == 30u,
    "Assembly RayDDAState.abs_end offset changed");
_Static_assert(offsetof(RayDDAState, threshold) == 31u,
    "Assembly RayDDAState.threshold offset changed");
_Static_assert(offsetof(RayDDAState, map_step_x) == 34u,
    "Assembly RayDDAState.map_step_x offset changed");
_Static_assert(offsetof(RayDDAState, map_step_y) == 37u,
    "Assembly RayDDAState.map_step_y offset changed");
_Static_assert(offsetof(RayDDAState, hit) == 40u,
    "Assembly RayDDAState.hit offset changed");
_Static_assert(offsetof(RayDDAState, game) == 43u,
    "Assembly RayDDAState.game offset changed");
_Static_assert(offsetof(RayDDAState, primary_tile) == 46u,
    "Assembly RayDDAState.primary_tile offset changed");
_Static_assert(offsetof(RayDDAState, secondary_tile) == 47u,
    "Assembly RayDDAState.secondary_tile offset changed");
_Static_assert(offsetof(RayDDAState, portal_exit) == 48u,
    "Assembly RayDDAState.portal_exit offset changed");
_Static_assert(offsetof(RayDDAState, portal_kind) == 52u,
    "Assembly RayDDAState.portal_kind offset changed");
_Static_assert(offsetof(RayDDAState, portal_id) == 53u,
    "Assembly RayDDAState.portal_id offset changed");
_Static_assert(offsetof(RayDDAState, portal_has_exit) == 54u,
    "Assembly RayDDAState.portal_has_exit offset changed");
_Static_assert(sizeof(Portal) == 4u, "Assembly Portal layout changed");
_Static_assert(offsetof(GameState, primary) == 8u,
    "Assembly GameState.primary offset changed");
_Static_assert(offsetof(GameState, secondary) == 12u,
    "Assembly GameState.secondary offset changed");
_Static_assert(sizeof(PortalLink) == 6u, "Assembly PortalLink layout changed");
_Static_assert(offsetof(RayHit, distance) == 0u, "Assembly RayHit.distance offset changed");
_Static_assert(offsetof(RayHit, map_x) == 3u, "Assembly RayHit.map_x offset changed");
_Static_assert(offsetof(RayHit, map_y) == 4u, "Assembly RayHit.map_y offset changed");
_Static_assert(offsetof(RayHit, step_x) == 5u, "Assembly RayHit.step_x offset changed");
_Static_assert(offsetof(RayHit, step_y) == 6u, "Assembly RayHit.step_y offset changed");
_Static_assert(offsetof(RayHit, side) == 7u, "Assembly RayHit.side offset changed");
_Static_assert(offsetof(RayHit, wall_u) == 8u, "Assembly RayHit.wall_u offset changed");
_Static_assert(offsetof(RayHit, wall_direction) == 9u,
    "Assembly RayHit.wall_direction offset changed");
_Static_assert(offsetof(RayHit, portal_kind) == 10u,
    "Assembly RayHit.portal_kind offset changed");
_Static_assert(offsetof(RayHit, wall_position) == 11u,
    "Assembly RayHit.wall_position offset changed");
_Static_assert(
    sizeof(GameState) + sizeof(RenderScratch) + sizeof(render_wall_scale_offset) +
        sizeof(render_wall_scale_profiles) +
        sizeof(grid_segments) + SCREEN_ROW_STORAGE_BYTES +
        sizeof(render_direction_y_by_angle) +
        sizeof(render_fov_by_direction) +
        sizeof(render_wall_texture_boundaries) +
        sizeof(render_wall_texture_runs) +
        sizeof(render_wall_colors) +
        sizeof(render_portal_profile_by_u) + sizeof(render_grid_near_projection) +
        sizeof(grid_far_projection) +
        RENDER_LAYER_MAJOR_BYTES +
        4096u < 96u * 1024u,
    "Static state plus the reserved CEdev stack exceeds 96 KiB"
);

/* A padded 16-by-16 map makes every DDA lookup a shift and an indexed load. */
const uint8_t render_wall_map[16 * 16] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
};

/* Link index + 1, keyed by the padded map tile. */
const uint8_t render_builtin_portal_by_tile[16 * 16] = {
    [3] = 10, [5] = 5, [7] = 6, [32] = 9, [64] = 3,
    [94] = 7, [110] = 8, [149] = 4, [208] = 1, [213] = 2
};

/* 65536/component for every possible 8.8 ray component. */
const uint16_t render_reciprocal_delta[426] = {
    0, 0, 32768, 21845, 16384, 13107, 10922, 9362, 8192, 7281, 6553, 5957,
    5461, 5041, 4681, 4369, 4096, 3855, 3640, 3449, 3276, 3120, 2978, 2849,
    2730, 2621, 2520, 2427, 2340, 2259, 2184, 2114, 2048, 1985, 1927, 1872,
    1820, 1771, 1724, 1680, 1638, 1598, 1560, 1524, 1489, 1456, 1424, 1394,
    1365, 1337, 1310, 1285, 1260, 1236, 1213, 1191, 1170, 1149, 1129, 1110,
    1092, 1074, 1057, 1040, 1024, 1008, 992, 978, 963, 949, 936, 923,
    910, 897, 885, 873, 862, 851, 840, 829, 819, 809, 799, 789,
    780, 771, 762, 753, 744, 736, 728, 720, 712, 704, 697, 689,
    682, 675, 668, 661, 655, 648, 642, 636, 630, 624, 618, 612,
    606, 601, 595, 590, 585, 579, 574, 569, 564, 560, 555, 550,
    546, 541, 537, 532, 528, 524, 520, 516, 512, 508, 504, 500,
    496, 492, 489, 485, 481, 478, 474, 471, 468, 464, 461, 458,
    455, 451, 448, 445, 442, 439, 436, 434, 431, 428, 425, 422,
    420, 417, 414, 412, 409, 407, 404, 402, 399, 397, 394, 392,
    390, 387, 385, 383, 381, 378, 376, 374, 372, 370, 368, 366,
    364, 362, 360, 358, 356, 354, 352, 350, 348, 346, 344, 343,
    341, 339, 337, 336, 334, 332, 330, 329, 327, 326, 324, 322,
    321, 319, 318, 316, 315, 313, 312, 310, 309, 307, 306, 304,
    303, 302, 300, 299, 297, 296, 295, 293, 292, 291, 289, 288,
    287, 286, 284, 283, 282, 281, 280, 278, 277, 276, 275, 274,
    273, 271, 270, 269, 268, 267, 266, 265, 264, 263, 262, 261,
    260, 259, 258, 257, 256, 255, 254, 253, 252, 251, 250, 249,
    248, 247, 246, 245, 244, 243, 242, 241, 240, 240, 239, 238,
    237, 236, 235, 234, 234, 233, 232, 231, 230, 229, 229, 228,
    227, 226, 225, 225, 224, 223, 222, 222, 221, 220, 219, 219,
    218, 217, 217, 216, 215, 214, 214, 213, 212, 212, 211, 210,
    210, 209, 208, 208, 207, 206, 206, 205, 204, 204, 203, 202,
    202, 201, 201, 200, 199, 199, 198, 197, 197, 196, 196, 195,
    195, 194, 193, 193, 192, 192, 191, 191, 190, 189, 189, 188,
    188, 187, 187, 186, 186, 185, 185, 184, 184, 183, 183, 182,
    182, 181, 181, 180, 180, 179, 179, 178, 178, 177, 177, 176,
    176, 175, 175, 174, 174, 173, 173, 172, 172, 172, 171, 171,
    170, 170, 169, 169, 168, 168, 168, 167, 167, 166, 166, 165,
    165, 165, 164, 164, 163, 163, 163, 162, 162, 161, 161, 161,
    160, 160, 159, 159, 159, 158, 158, 157, 157, 157, 156, 156,
    156, 155, 155, 154, 154, 154
};

const PortalLink render_builtin_portals[10] = {
    {0, 13, DIR_SOUTH, 5, 13, DIR_NORTH},
    {5, 13, DIR_NORTH, 0, 13, DIR_SOUTH},
    {0, 4, DIR_SOUTH, 5, 9, DIR_NORTH},
    {5, 9, DIR_NORTH, 0, 4, DIR_SOUTH},
    {5, 0, DIR_EAST, 7, 0, DIR_EAST},
    {7, 0, DIR_EAST, 5, 0, DIR_EAST},
    {14, 5, DIR_NORTH, 14, 6, DIR_NORTH},
    {14, 6, DIR_NORTH, 14, 5, DIR_NORTH},
    {0, 2, DIR_SOUTH, 3, 0, DIR_EAST},
    {3, 0, DIR_EAST, 0, 2, DIR_SOUTH}
};

static const int16_t direction_y[ANGLE_STEPS] = {
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25
};

static const uint8_t portal_visit_bits[8] = {
    1u, 2u, 4u, 8u, 16u, 32u, 64u, 128u
};

static const uint8_t map_row_offsets[16] = {
    0, 16, 32, 48, 64, 80, 96, 112,
    128, 144, 160, 176, 192, 208, 224, 240
};

static fixed_t fixed_abs(fixed_t value) {
    return value < 0 ? -value : value;
}

static inline __attribute__((always_inline)) uint8_t fixed_cell(
    const fixed_t *value
) {
    /* Positive little-endian 8.8 map coordinates keep their cell in byte one. */
    return ((const uint8_t *)value)[1];
}

#if !RENDER_ASM_RAYCAST
static inline __attribute__((always_inline)) uint8_t fixed_fraction(fixed_t value) {
    return *(const uint8_t *)&value;
}
#endif

/* Camera products stay below 2^23, so native eZ80-width math is sufficient. */
static fixed_t fixed_mul_camera(fixed_t left, fixed_t right) {
    return (fixed_t)((left * right) / FIXED_ONE);
}

static void fixed_scale_init(FixedScale *scale, fixed_t factor) {
    scale->whole = factor / FIXED_ONE;
    scale->fraction = (uint8_t)(factor - scale->whole * FIXED_ONE);
}

static __attribute__((noinline)) fixed_t fixed_scale_mul(
    fixed_t value,
    const FixedScale *scale
) {
    return value * scale->whole +
        fixed_mul_camera(value, scale->fraction);
}

/* Scale a positive DDA delta by a 0..256 cell fraction without 32-bit math. */
#if !RENDER_ASM_RAYCAST
static fixed_t scale_delta(uint16_t fraction, fixed_t delta) {
    if (delta == 65536) {
        return (fixed_t)((uint24_t)fraction << FIXED_SHIFT);
    }

    return (fixed_t)(
        ((uint24_t)fraction * (uint24_t)delta) >> FIXED_SHIFT
    );
}
#endif

static void ray_stepper_init(RayStepper *stepper, fixed_t direction, fixed_t plane) {
    int8_t quotient;
    uint8_t remainder;

    /*
     * For 80 columns:
     *   floor(((direction-plane)*80 + plane) / 80)
     *       = direction - plane + floor(plane / 80).
     *
     * Resolve plane = 80*quotient + remainder directly. The camera plane is
     * bounded to [-169,169], so three positive and three negative ranges cover
     * every reachable value without signed division or multiplication by 80.
     */
    if (plane >= 0) {
        if (plane >= 160) {
            quotient = 2;
            remainder = (uint8_t)(plane - 160);
        } else if (plane >= 80) {
            quotient = 1;
            remainder = (uint8_t)(plane - 80);
        } else {
            quotient = 0;
            remainder = (uint8_t)plane;
        }
    } else if (plane < -160) {
        quotient = -3;
        remainder = (uint8_t)(plane + 240);
    } else if (plane < -80) {
        quotient = -2;
        remainder = (uint8_t)(plane + 160);
    } else {
        quotient = -1;
        remainder = (uint8_t)(plane + 80);
    }

    stepper->value = direction - plane + quotient;
    stepper->error = remainder;

    /*
     * floor(2*plane/80) = 2*quotient + floor(2*remainder/80).
     * Keep error_step in the same canonical 0..79 range as the old path.
     */
    stepper->step = (fixed_t)(quotient + quotient);
    if (remainder >= 40) {
        ++stepper->step;
        remainder -= 40;
    }
    stepper->error_step = (uint8_t)(remainder + remainder);
}

static inline __attribute__((always_inline)) void ray_stepper_advance(RayStepper *stepper) {
    stepper->value += stepper->step;
    stepper->error += stepper->error_step;
    if (stepper->error >= LOGICAL_COLUMNS) {
        ++stepper->value;
        stepper->error -= LOGICAL_COLUMNS;
    }
}

static fixed_t delta_for_component(fixed_t component) {
    fixed_t magnitude = fixed_abs(component);

    if (magnitude == 0) {
        return FIXED_INF;
    }
    if (magnitude == 1) {
        return 65536;
    }
    if (magnitude > 425) magnitude = 425;
    return render_reciprocal_delta[magnitude];
}

static inline __attribute__((always_inline)) uint8_t map_is_wall(int24_t x, int24_t y) {
    if ((uint24_t)x >= MAP_WIDTH || (uint24_t)y >= MAP_HEIGHT) {
        return 1;
    }

    return render_wall_map[((uint16_t)y << 4) | (uint16_t)x];
}

#if RENDER_ASM_PORTALS
static inline __attribute__((always_inline)) uint8_t portal_find_exit(
    const GameState *game,
    uint8_t x,
    uint8_t y,
    uint8_t direction,
    Portal *exit,
    uint8_t *kind,
    uint8_t *portal_id
) {
    return render_asm_find_portal(
        game, x, y, direction, exit, kind, portal_id
    );
}
#else
static uint8_t builtin_portal_index(uint8_t x, uint8_t y, uint8_t direction) {
    uint8_t value = render_builtin_portal_by_tile[((uint16_t)y << 4) | x];

    if (value != 0 &&
        render_builtin_portals[value - 1].direction == direction) {
        return value;
    }
    return 0;
}

static uint8_t portal_matches(const Portal *portal, uint8_t x, uint8_t y, uint8_t direction) {
    return portal->valid && portal->x == x && portal->y == y && portal->direction == direction;
}

static uint8_t portal_find_exit(
    const GameState *game,
    uint8_t x,
    uint8_t y,
    uint8_t direction,
    Portal *exit,
    uint8_t *kind,
    uint8_t *portal_id
) {
    uint8_t index;

    *kind = PORTAL_NONE;
    if (portal_matches(&game->primary, x, y, direction)) {
        *kind = PORTAL_PRIMARY;
        if (game->secondary.valid) {
            *exit = game->secondary;
            *portal_id = 10;
            return 1;
        }
        return 0;
    }
    if (portal_matches(&game->secondary, x, y, direction)) {
        *kind = PORTAL_SECONDARY;
        if (game->primary.valid) {
            *exit = game->primary;
            *portal_id = 11;
            return 1;
        }
        return 0;
    }

    index = builtin_portal_index(x, y, direction);
    if (index != 0) {
        const PortalLink *link = &render_builtin_portals[index - 1];
        exit->x = link->target_x;
        exit->y = link->target_y;
        exit->direction = link->target_direction;
        exit->valid = 1;
        *kind = PORTAL_BUILTIN;
        *portal_id = (uint8_t)(index - 1);
        return 1;
    }
    return 0;
}
#endif

#if !RENDER_ASM_RAYCAST
static inline __attribute__((always_inline)) uint8_t render_portal_find_exit(
    const GameState *game,
    uint8_t x,
    uint8_t y,
    uint8_t direction,
    Portal *exit,
    uint8_t *kind,
    uint8_t *portal_id
) {
    uint8_t tile = (uint8_t)(map_row_offsets[y] + x);

    if (render_builtin_portal_by_tile[tile] == 0 &&
        tile != render_scratch.primary_tile &&
        tile != render_scratch.secondary_tile) {
        *kind = PORTAL_NONE;
        return 0;
    }
    return portal_find_exit(
        game, x, y, direction, exit, kind, portal_id
    );
}
#endif

#if RENDER_ASM_RAYCAST
/*
 * Portal identity is constant throughout one render (or placement trace).
 * Cache the two dynamic tile keys beside the persistent DDA state so the
 * assembly hit tail can reject ordinary walls and resolve linked exits
 * without returning through a second C ABI call.
 */
static inline __attribute__((always_inline)) void render_ray_set_game(
    const GameState *game
) {
    render_ray_state.game = game;
    render_ray_state.primary_tile = game->primary.valid ?
        (uint8_t)(map_row_offsets[game->primary.y] + game->primary.x) : 0xFFu;
    render_ray_state.secondary_tile = game->secondary.valid ?
        (uint8_t)(map_row_offsets[game->secondary.y] + game->secondary.x) : 0xFFu;
}
#endif

static int8_t portal_rotation(uint8_t entry_direction, uint8_t exit_direction) {
    if (entry_direction == exit_direction) {
        return 2;
    }

    switch (entry_direction) {
        case DIR_NORTH:
            if (exit_direction == DIR_SOUTH) return 0;
            return exit_direction == DIR_EAST ? 1 : -1;
        case DIR_EAST:
            if (exit_direction == DIR_WEST) return 0;
            return exit_direction == DIR_SOUTH ? 1 : -1;
        case DIR_SOUTH:
            if (exit_direction == DIR_NORTH) return 0;
            return exit_direction == DIR_WEST ? 1 : -1;
        case DIR_WEST:
            if (exit_direction == DIR_EAST) return 0;
            return exit_direction == DIR_NORTH ? 1 : -1;
        default:
            return 0;
    }
}

static void rotate_quarter(fixed_t *x, fixed_t *y, int8_t quarters) {
    fixed_t old_x = *x;
    fixed_t old_y = *y;

    if (quarters == 1) {
        *x = -old_y;
        *y = old_x;
    } else if (quarters == -1) {
        *x = old_y;
        *y = -old_x;
    } else if (quarters == 2 || quarters == -2) {
        *x = -old_x;
        *y = -old_y;
    }
}

#if RENDER_ASM_RAYCAST
static inline __attribute__((always_inline)) void cast_wall(
    fixed_t origin_x,
    fixed_t origin_y,
    fixed_t ray_x,
    fixed_t ray_y,
    int24_t map_x,
    int24_t map_y,
    RayHit *hit
) {
    (void)map_x;
    (void)map_y;
    render_asm_cast_wall_begin(origin_x, origin_y, ray_x, ray_y, hit);
}
#else
static void cast_wall(
    fixed_t origin_x,
    fixed_t origin_y,
    fixed_t ray_x,
    fixed_t ray_y,
    int24_t map_x,
    int24_t map_y,
    RayHit *hit
) {
    uint24_t delta_x;
    uint24_t delta_y;
    uint24_t side_x;
    uint24_t side_y;
    fixed_t wall_position;
    uint24_t map_index;
    int24_t map_step_y;

    hit->step_x = ray_x < 0 ? -1 : 1;
    hit->step_y = ray_y < 0 ? -1 : 1;

    if (ray_x == 0) {
        delta_x = FIXED_INF;
        side_x = FIXED_INF;
    } else {
        uint8_t fraction_x = fixed_fraction(origin_x);

        delta_x = delta_for_component(ray_x);
        if (ray_x < 0) {
            side_x = scale_delta(fraction_x, delta_x);
        } else {
            side_x = scale_delta((uint16_t)(FIXED_ONE - fraction_x), delta_x);
        }
    }

    if (ray_y == 0) {
        delta_y = FIXED_INF;
        side_y = FIXED_INF;
    } else {
        uint8_t fraction_y = fixed_fraction(origin_y);

        delta_y = delta_for_component(ray_y);
        if (ray_y < 0) {
            side_y = scale_delta(fraction_y, delta_y);
        } else {
            side_y = scale_delta((uint16_t)(FIXED_ONE - fraction_y), delta_y);
        }
    }

    /* The solid border guarantees this linear index cannot leave the map. */
    map_index = ((uint24_t)map_y << 4) + (uint24_t)map_x;
    map_step_y = (int24_t)hit->step_y * 16;

    do {
        uint8_t step_x_first = side_x < side_y;

        if (side_x == side_y) {
            uint8_t x_wall = render_wall_map[map_index + hit->step_x];
            uint8_t y_wall = render_wall_map[map_index + map_step_y];

            /* Ignore a point-only corner touch and enter the empty side. */
            step_x_first = (uint8_t)(y_wall != 0 && x_wall == 0);
        }

        if (step_x_first) {
            side_x += delta_x;
            map_x += hit->step_x;
            map_index += hit->step_x;
            hit->side = 0;
        } else {
            side_y += delta_y;
            map_y += hit->step_y;
            map_index += map_step_y;
            hit->side = 1;
        }
    } while (!render_wall_map[map_index]);

    if (hit->side == 0) {
        hit->distance = side_x - delta_x;
        hit->wall_direction = ray_x >= 0 ? DIR_NORTH : DIR_SOUTH;
    } else {
        hit->distance = side_y - delta_y;
        hit->wall_direction = ray_y >= 0 ? DIR_WEST : DIR_EAST;
    }

    if (hit->distance < 1) {
        hit->distance = 1;
    }
    wall_position = hit->side == 0 ?
        origin_y + fixed_mul_camera(hit->distance, ray_y) :
        origin_x + fixed_mul_camera(hit->distance, ray_x);
    hit->map_x = (uint8_t)map_x;
    hit->map_y = (uint8_t)map_y;
    hit->wall_position = wall_position;
    hit->wall_u = (uint8_t)wall_position;
    hit->portal_kind = PORTAL_NONE;
}

static inline __attribute__((always_inline)) void cast_wall_with_delta(
    fixed_t origin_x,
    fixed_t origin_y,
    fixed_t ray_x,
    fixed_t ray_y,
    int24_t map_x,
    int24_t map_y,
    RayHit *hit,
    fixed_t delta_x,
    fixed_t delta_y
) {
    (void)delta_x;
    (void)delta_y;
    cast_wall(origin_x, origin_y, ray_x, ray_y, map_x, map_y, hit);
}

#endif

#if RENDER_ASM_TRANSFORM
static inline __attribute__((always_inline)) int8_t transform_ray(
    const RayHit *entry,
    const Portal *exit
) {
#if RENDER_ASM_RAYCAST
    (void)entry;
    (void)exit;
    return render_asm_transform_ray_state();
#else
    return render_asm_transform_ray(entry, exit);
#endif
}
#else
static int8_t transform_ray(
    const RayHit *entry,
    const Portal *exit,
    fixed_t *origin_x,
    fixed_t *origin_y,
    fixed_t *ray_x,
    fixed_t *ray_y
) {
    *origin_x += fixed_mul_camera(entry->distance, *ray_x);
    *origin_y += fixed_mul_camera(entry->distance, *ray_y);

    fixed_t local_x = *origin_x - (fixed_t)entry->map_x * FIXED_ONE;
    fixed_t local_y = *origin_y - (fixed_t)entry->map_y * FIXED_ONE;
    int8_t rotation = portal_rotation(entry->wall_direction, exit->direction);

    if (entry->side == 0) {
        local_x += (fixed_t)entry->step_x * FIXED_ONE;
    } else {
        local_y += (fixed_t)entry->step_y * FIXED_ONE;
    }

    rotate_quarter(&local_x, &local_y, rotation);
    rotate_quarter(ray_x, ray_y, rotation);

    if (rotation == 2 || rotation == -2) {
        local_x += FIXED_ONE;
        local_y += FIXED_ONE;
    } else if (rotation == 1) {
        local_x += FIXED_ONE;
    } else if (rotation == -1) {
        local_y += FIXED_ONE;
    }

    *origin_x = (fixed_t)exit->x * FIXED_ONE + local_x;
    *origin_y = (fixed_t)exit->y * FIXED_ONE + local_y;

    switch (exit->direction) {
        case DIR_NORTH:
            *origin_x = (fixed_t)exit->x * FIXED_ONE - 1;
            break;
        case DIR_SOUTH:
            *origin_x = (fixed_t)(exit->x + 1u) * FIXED_ONE + 1;
            break;
        case DIR_WEST:
            *origin_y = (fixed_t)exit->y * FIXED_ONE - 1;
            break;
        case DIR_EAST:
            *origin_y = (fixed_t)(exit->y + 1u) * FIXED_ONE + 1;
            break;
    }
    return rotation;
}
#endif

static void transform_player(GameState *game, const Portal *exit, uint8_t entry_direction) {
    fixed_t local_x = game->player_x - (game->player_x / FIXED_ONE) * FIXED_ONE;
    fixed_t local_y = game->player_y - (game->player_y / FIXED_ONE) * FIXED_ONE;
    int8_t rotation = portal_rotation(entry_direction, exit->direction);

    rotate_quarter(&local_x, &local_y, rotation);
    if (rotation == 2 || rotation == -2) {
        local_x += FIXED_ONE;
        local_y += FIXED_ONE;
    } else if (rotation == 1) {
        local_x += FIXED_ONE;
    } else if (rotation == -1) {
        local_y += FIXED_ONE;
    }

    game->player_x = (fixed_t)exit->x * FIXED_ONE + local_x;
    game->player_y = (fixed_t)exit->y * FIXED_ONE + local_y;

    /* Put the player's collision circle fully outside the exit wall. */
    switch (exit->direction) {
        case DIR_NORTH:
            game->player_x =
                (fixed_t)exit->x * FIXED_ONE - PLAYER_RADIUS - 1;
            break;
        case DIR_SOUTH:
            game->player_x =
                (fixed_t)(exit->x + 1u) * FIXED_ONE + PLAYER_RADIUS + 1;
            break;
        case DIR_WEST:
            game->player_y =
                (fixed_t)exit->y * FIXED_ONE - PLAYER_RADIUS - 1;
            break;
        case DIR_EAST:
            game->player_y =
                (fixed_t)(exit->y + 1u) * FIXED_ONE + PLAYER_RADIUS + 1;
            break;
    }

    if (exit->direction == DIR_NORTH || exit->direction == DIR_SOUTH) {
        fixed_t minimum =
            (fixed_t)exit->y * FIXED_ONE + PLAYER_RADIUS + 1;
        fixed_t maximum =
            (fixed_t)(exit->y + 1u) * FIXED_ONE - PLAYER_RADIUS - 1;

        if (game->player_y < minimum) game->player_y = minimum;
        if (game->player_y > maximum) game->player_y = maximum;
    } else {
        fixed_t minimum =
            (fixed_t)exit->x * FIXED_ONE + PLAYER_RADIUS + 1;
        fixed_t maximum =
            (fixed_t)(exit->x + 1u) * FIXED_ONE - PLAYER_RADIUS - 1;

        if (game->player_x < minimum) game->player_x = minimum;
        if (game->player_x > maximum) game->player_x = maximum;
    }
    game->angle = (uint16_t)((game->angle + rotation * 16 * (1 << ANGLE_FRACTION_BITS)) & ANGLE_MASK);
}

static void direction_for_angle(uint16_t angle, fixed_t *x, fixed_t *y) {
    uint16_t normalized = (uint16_t)(angle & ANGLE_MASK);

    *y = render_direction_y_by_angle[normalized];
    *x = render_direction_y_by_angle[
        (uint16_t)((normalized + ANGLE_WRAP / 4u) & ANGLE_MASK)
    ];
}

static void move_without_portal(GameState *game, fixed_t amount) {
    fixed_t dir_x;
    fixed_t dir_y;
    fixed_t delta_x;
    fixed_t delta_y;
    fixed_t candidate;
    fixed_t probe;

    direction_for_angle(game->angle, &dir_x, &dir_y);
    delta_x = fixed_mul_camera(dir_x, amount);
    delta_y = fixed_mul_camera(dir_y, amount);

    if (delta_x != 0) {
        candidate = game->player_x + delta_x;
        probe = candidate + (delta_x > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);
        if (!map_is_wall(probe / FIXED_ONE, game->player_y / FIXED_ONE)) {
            game->player_x = candidate;
        }
    }

    if (delta_y != 0) {
        candidate = game->player_y + delta_y;
        probe = candidate + (delta_y > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);
        if (!map_is_wall(game->player_x / FIXED_ONE, probe / FIXED_ONE)) {
            game->player_y = candidate;
        }
    }
}

static uint8_t try_player_portal(
    GameState *game,
    fixed_t probe_x,
    fixed_t probe_y,
    fixed_t move_amount
) {
    int24_t current_x = game->player_x / FIXED_ONE;
    int24_t current_y = game->player_y / FIXED_ONE;
    int24_t target_x = probe_x / FIXED_ONE;
    int24_t target_y = probe_y / FIXED_ONE;
    uint8_t wall_direction;
    Portal exit;
    uint8_t kind;
    uint8_t portal_id;

    if (target_x != current_x) {
        wall_direction = target_x < current_x ? DIR_SOUTH : DIR_NORTH;
        target_y = current_y;
    } else if (target_y != current_y) {
        wall_direction = target_y < current_y ? DIR_EAST : DIR_WEST;
        target_x = current_x;
    } else {
        return 0;
    }

    if (target_x < 0 || target_y < 0 || target_x >= MAP_WIDTH || target_y >= MAP_HEIGHT) {
        return 0;
    }

    if (!portal_find_exit(
        game,
        (uint8_t)target_x,
        (uint8_t)target_y,
        wall_direction,
        &exit,
        &kind,
        &portal_id
    )) {
        return 0;
    }

    (void)kind;
    (void)portal_id;
    transform_player(game, &exit, wall_direction);
    move_without_portal(game, move_amount);
    return 1;
}

static void move_player(GameState *game, fixed_t amount) {
    fixed_t dir_x;
    fixed_t dir_y;
    fixed_t delta_x;
    fixed_t delta_y;
    fixed_t candidate_x;
    fixed_t candidate_y;
    fixed_t probe_x;
    fixed_t probe_y;

    if (amount == 0) {
        return;
    }

    direction_for_angle(game->angle, &dir_x, &dir_y);
    delta_x = fixed_mul_camera(dir_x, amount);
    delta_y = fixed_mul_camera(dir_y, amount);
    candidate_x = game->player_x + delta_x;
    candidate_y = game->player_y + delta_y;
    probe_x = candidate_x + (delta_x > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);
    probe_y = candidate_y + (delta_y > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);

    if (delta_x != 0 && try_player_portal(game, probe_x, game->player_y, amount)) {
        return;
    }
    if (delta_y != 0 && try_player_portal(game, game->player_x, probe_y, amount)) {
        return;
    }
    move_without_portal(game, amount);
}

static void place_portal(GameState *game, uint8_t primary) {
    fixed_t origin_x = game->player_x;
    fixed_t origin_y = game->player_y;
    fixed_t ray_x;
    fixed_t ray_y;
    int24_t map_x = fixed_cell(&origin_x);
    int24_t map_y = fixed_cell(&origin_y);
    uint8_t depth;

    direction_for_angle(game->angle, &ray_x, &ray_y);
#if RENDER_ASM_RAYCAST
    render_ray_set_game(game);
#endif

    for (depth = 0; depth < MAX_PORTAL_TRACE_DEPTH; ++depth) {
        RayHit hit;
#if RENDER_ASM_RAYCAST
        const Portal *exit;
#else
        Portal exit;
#endif
        uint8_t kind;
        uint8_t portal_id;
        uint8_t has_exit;

        cast_wall(origin_x, origin_y, ray_x, ray_y, map_x, map_y, &hit);

#if RENDER_ASM_RAYCAST
        exit = &render_ray_state.portal_exit;
        kind = render_ray_state.portal_kind;
        portal_id = render_ray_state.portal_id;
        has_exit = render_ray_state.portal_has_exit;
#else
        has_exit = portal_find_exit(
            game,
            hit.map_x,
            hit.map_y,
            hit.wall_direction,
            &exit,
            &kind,
            &portal_id
        );
#endif
        if (has_exit) {
            (void)kind;
            (void)portal_id;
#if RENDER_ASM_TRANSFORM
            (void)transform_ray(&hit, exit);
            origin_x = render_ray_state.origin_x;
            origin_y = render_ray_state.origin_y;
            ray_x = render_ray_state.ray_x;
            ray_y = render_ray_state.ray_y;
#else
#if RENDER_ASM_RAYCAST
            transform_ray(&hit, exit, &origin_x, &origin_y, &ray_x, &ray_y);
#else
            transform_ray(&hit, &exit, &origin_x, &origin_y, &ray_x, &ray_y);
#endif
#endif
            map_x = fixed_cell(&origin_x);
            map_y = fixed_cell(&origin_y);
            continue;
        }

        if (kind != PORTAL_NONE) {
            return;
        }

        if (primary) {
            game->primary.x = hit.map_x;
            game->primary.y = hit.map_y;
            game->primary.direction = hit.wall_direction;
            game->primary.valid = 1;
        } else {
            game->secondary.x = hit.map_x;
            game->secondary.y = hit.map_y;
            game->secondary.direction = hit.wall_direction;
            game->secondary.valid = 1;
        }
        return;
    }
}

static inline __attribute__((always_inline)) const WallContext *
wall_context_for_distance(fixed_t distance) {
    uint24_t table_index = (uint24_t)distance >> WALL_HEIGHT_TABLE_SHIFT;
    uint16_t profile_offset;

    if (table_index >= WALL_HEIGHT_TABLE_SIZE) {
        table_index = WALL_HEIGHT_TABLE_SIZE - 1u;
    }
    profile_offset = render_wall_scale_offset[table_index];
    return (const WallContext *)(
        (const uint8_t *)render_wall_scale_profiles + profile_offset
    );
}

static uint16_t wall_height_for_distance(fixed_t distance) {
    return wall_context_for_distance(distance)->full_height;
}

static void grid_projection_init(GridProjection *projection, fixed_t distance) {
    projection->height = wall_height_for_distance(distance);
    projection->screen_y = (uint8_t)(
        GFX_LCD_HEIGHT / 2 + projection->height / 2
    );
    projection->positive_limit =
        ((FLOOR_PROJECT_LIMIT - GFX_LCD_WIDTH / 2) * FIXED_ONE) /
        projection->height;
    projection->negative_limit =
        ((FLOOR_PROJECT_LIMIT + GFX_LCD_WIDTH / 2) * FIXED_ONE) /
        projection->height;
}

#if !RENDER_ASM_WALLS
static uint8_t wall_shade_level(const RayHit *ray) {
    uint8_t shade = ray->side != 0 ? 1 : 0;

    if (ray->distance > FIXED_ONE * 8) {
        shade += 2;
    } else if (ray->distance > FIXED_ONE * 4) {
        shade += 1;
    }
    if (shade >= WALL_SHADE_LEVELS) {
        shade = WALL_SHADE_LEVELS - 1;
    }
    return shade;
}

static uint8_t wall_texture_column_offset(const RayHit *ray) {
    uint8_t texture_offset = ray->wall_u & 0xF0;

    if ((ray->side == 0 && ray->step_x > 0) ||
        (ray->side != 0 && ray->step_y < 0)) {
        texture_offset = (uint8_t)(0xF0 - texture_offset);
    }
    return (uint8_t)(texture_offset >> 1);
}

static inline __attribute__((always_inline)) uint8_t wall_material_for_ray(
    const RayHit *ray
) {
    /* A wall cell keeps the same material from every viewing angle. */
    return (uint8_t)((ray->map_x ^ ray->map_y) & 3u);
}

static inline __attribute__((always_inline)) uint8_t *draw_wall_run(
    uint8_t *destination,
    uint8_t height,
    const WallColor *color
) {
    packed24_t packed = color->packed;
    uint8_t palette = color->palette;

    do {
        *(packed24_t *)destination = packed;
        destination[3] = palette;
        destination += GFX_LCD_WIDTH;
    } while (--height);

    return destination;
}

static void draw_textured_wall_segment(
    const RayHit *ray,
    uint24_t x,
    uint8_t start,
    uint8_t end,
    const WallContext *full_context,
    uint8_t reuse_setup
) {
    const uint8_t *texture_column;
    const uint8_t *boundaries;
    uint8_t *destination;
    uint8_t texture_column_offset;
    uint8_t material;
    uint8_t texture_index = 0;
    uint8_t shade;
    uint8_t y;

    (void)reuse_setup;
    if (end <= start) {
        return;
    }

    texture_column_offset = wall_texture_column_offset(ray);
    material = wall_material_for_ray(ray);
    texture_column = &render_wall_texture_runs[
        ((uint16_t)material * WALL_TEXTURE_WIDTH * WALL_TEXTURE_HEIGHT +
            texture_column_offset) * WALL_TEXTURE_DESCRIPTOR_SIZE
    ];
    boundaries = full_context->boundaries;
    shade = wall_shade_level(ray);
    y = start;
    destination = &gfx_vbuffer[0][0] + render_screen_rows[start].offset + x;

    while (texture_index < WALL_TEXTURE_MASK &&
        boundaries[texture_index + 1] <= start) {
        ++texture_index;
    }

    while (y < end) {
        const uint8_t *descriptor =
            &texture_column[(uint8_t)(texture_index * WALL_TEXTURE_DESCRIPTOR_SIZE)];
        uint8_t texel = (uint8_t)(descriptor[0] / sizeof(WallColor));
        uint8_t next_index = descriptor[1];
        uint8_t run_end = boundaries[next_index];
        uint8_t run;

        if (run_end > end) run_end = end;
        run = (uint8_t)(run_end - y);
        destination = draw_wall_run(
            destination,
            run,
            &render_wall_colors[material][shade][texel]
        );
        y = run_end;
        while (texture_index < WALL_TEXTURE_MASK &&
            boundaries[texture_index + 1] <= y) {
            ++texture_index;
        }
    }
}
#else
static inline __attribute__((always_inline)) void draw_textured_wall_segment(
    const RayHit *ray,
    uint24_t x,
    uint8_t start,
    uint8_t end,
    const WallContext *full_context,
    uint8_t reuse_setup
) {
    (void)reuse_setup;
    render_asm_draw_wall_segment(
        ray, x, start, end, full_context
    );
}
#endif

static uint8_t portal_color(uint8_t kind) {
    if (kind == PORTAL_PRIMARY) return COLOR_PRIMARY;
    if (kind == PORTAL_SECONDARY) return COLOR_SECONDARY;
    return COLOR_BUILTIN;
}

#if !RENDER_ASM_BACKGROUND
static inline __attribute__((always_inline)) void draw_visible_floor_segment(
    int24_t far_x,
    uint8_t far_y,
    int24_t near_x,
    uint8_t near_y
) {
    if ((uint24_t)far_x < GFX_LCD_WIDTH && (uint24_t)near_x < GFX_LCD_WIDTH) {
        gfx_Line_NoClip(far_x, far_y, near_x, near_y);
    } else {
        gfx_Line(far_x, far_y, near_x, near_y);
    }
}
#endif

#if RENDER_ASM_BACKGROUND
extern void render_asm_clear_background(void);
extern void render_asm_repair_horizon(void);
extern void render_asm_draw_horizontal_grid_pair(uint8_t screen_y);

static inline __attribute__((always_inline)) void add_horizontal_grid_segment(
    GridSegment **segment_end,
    uint8_t screen_y
) {
    (void)segment_end;
    render_asm_draw_horizontal_grid_pair(screen_y);
}

extern void render_asm_add_projected_grid_segment(
    GridSegment **segment_end,
    fixed_t lateral_near,
    fixed_t lateral_far
);
#define add_projected_grid_segment render_asm_add_projected_grid_segment

#else
static int24_t project_grid_x(
    fixed_t lateral,
    const GridProjection *projection
) {
    if (lateral >= projection->positive_limit) return FLOOR_PROJECT_LIMIT;
    if (lateral <= -projection->negative_limit) return -FLOOR_PROJECT_LIMIT;
    return GFX_LCD_WIDTH / 2 +
        fixed_mul_camera(lateral, projection->height);
}

static void add_grid_segment(
    GridSegment **segment_end,
    int24_t far_x,
    uint8_t far_y,
    int24_t near_x,
    uint8_t horizontal
) {
    GridSegment *segment;

    if (!horizontal) {
        if (far_x < 0) {
            if (near_x < 0) return;
        } else if (far_x >= GFX_LCD_WIDTH) {
            if (near_x >= GFX_LCD_WIDTH) return;
        }
    }

    segment = *segment_end;
    segment->far_x = far_x;
    segment->far_y = far_y;
    segment->near_x = near_x;
    segment->kind = horizontal ? GRID_HORIZONTAL :
        ((uint24_t)far_x < GFX_LCD_WIDTH &&
            (uint24_t)near_x < GFX_LCD_WIDTH ?
            GRID_SLANTED_NOCLIP : GRID_SLANTED_CLIPPED);
    *segment_end = segment + 1;

    if (horizontal) {
        gfx_HorizLine_NoClip(0, far_y, GFX_LCD_WIDTH);
    } else {
        draw_visible_floor_segment(
            far_x,
            far_y,
            near_x,
            render_grid_near_projection.screen_y
        );
    }
}

static void add_projected_grid_segment(
    GridSegment **segment_end,
    fixed_t lateral_near,
    fixed_t lateral_far
) {
    int24_t screen_x_near = project_grid_x(
        lateral_near,
        &render_grid_near_projection
    );
    int24_t screen_x_far = project_grid_x(
        lateral_far,
        &grid_far_projection
    );

    add_grid_segment(
        segment_end,
        screen_x_far,
        FLOOR_FAR_SCREEN_Y,
        screen_x_near,
        0
    );
}

static inline __attribute__((always_inline)) void add_horizontal_grid_segment(
    GridSegment **segment_end,
    uint8_t screen_y
) {
    add_grid_segment(
        segment_end,
        0,
        screen_y,
        GFX_LCD_WIDTH - 1,
        1
    );
}
#endif

static void draw_background_grid(
    const GameState *game,
    fixed_t direction_x_value,
    fixed_t direction_y_value
) {
    fixed_t inverse_x = direction_x_value == 0 ? 0 :
        delta_for_component(direction_x_value);
    fixed_t inverse_y = direction_y_value == 0 ? 0 :
        delta_for_component(direction_y_value);
    FixedScale inverse_x_scale;
    FixedScale inverse_y_scale;
    fixed_t x_near = fixed_mul_camera(direction_x_value, FLOOR_NEAR_DISTANCE);
    fixed_t x_far = fixed_mul_camera(direction_x_value, FLOOR_FAR_DISTANCE);
    fixed_t y_near = fixed_mul_camera(direction_y_value, FLOOR_NEAR_DISTANCE);
    fixed_t y_far = fixed_mul_camera(direction_y_value, FLOOR_FAR_DISTANCE);
    fixed_t x_line_near;
    fixed_t x_line_far;
    fixed_t x_line_step;
    fixed_t x_input_near;
    fixed_t x_input_far;
    fixed_t y_line_near;
    fixed_t y_line_far;
    fixed_t y_line_step;
    fixed_t y_input_near;
    fixed_t y_input_far;
    uint8_t near_screen_y = render_grid_near_projection.screen_y;
    GridSegment *segment_end = grid_segments;
    uint8_t line;

    fixed_scale_init(&inverse_x_scale, inverse_x);
    fixed_scale_init(&inverse_y_scale, inverse_y);

    /*
     * Projection is affine in the world-grid coordinate.  Compute line zero
     * once, then advance by one reciprocal per cell.  Signed truncation only
     * breaks the recurrence when a source value crosses zero, so recompute at
     * that one crossing.  This preserves the exact projected endpoints while
     * replacing almost all per-line signed 24-bit products with additions.
     */
    if (direction_y_value == 0) {
        x_input_near = -game->player_x;
        x_input_far = x_input_near;
        x_line_near = fixed_scale_mul(x_input_near, &inverse_x_scale);
        x_line_far = x_line_near;
        x_line_step = inverse_x;
        if (direction_x_value < 0) {
            x_line_near = -x_line_near;
            x_line_far = -x_line_far;
            x_line_step = -x_line_step;
        }
    } else {
        x_input_near = game->player_x + x_near;
        x_input_far = game->player_x + x_far;
        x_line_near = fixed_scale_mul(
            x_input_near,
            &inverse_y_scale
        );
        x_line_far = fixed_scale_mul(
            x_input_far,
            &inverse_y_scale
        );
        x_line_step = -inverse_y;
        if (direction_y_value < 0) {
            x_line_near = -x_line_near;
            x_line_far = -x_line_far;
            x_line_step = -x_line_step;
        }
    }

    if (direction_x_value == 0) {
        y_input_near = -game->player_y;
        y_input_far = y_input_near;
        y_line_near = fixed_scale_mul(y_input_near, &inverse_y_scale);
        y_line_far = y_line_near;
        y_line_step = inverse_y;
        if (direction_y_value < 0) {
            y_line_near = -y_line_near;
            y_line_far = -y_line_far;
            y_line_step = -y_line_step;
        }
    } else {
        y_input_near = -game->player_y - y_near;
        y_input_far = -game->player_y - y_far;
        y_line_near = fixed_scale_mul(
            y_input_near,
            &inverse_x_scale
        );
        y_line_far = fixed_scale_mul(
            y_input_far,
            &inverse_x_scale
        );
        y_line_step = inverse_x;
        if (direction_x_value < 0) {
            y_line_near = -y_line_near;
            y_line_far = -y_line_far;
            y_line_step = -y_line_step;
        }
    }

#if RENDER_ASM_BACKGROUND
    /*
     * game_render already waited for the draw buffer. Fill the ceiling,
     * horizon, and floor once each with the interrupt-safe stack-push path.
     */
    render_asm_clear_background();
#else
    gfx_FillScreen(COLOR_FLOOR);
    memset(
        &gfx_vbuffer[0][0],
        COLOR_CEILING,
        GFX_LCD_WIDTH * 112u
    );
#endif
    gfx_SetColor(COLOR_FLOOR_NEAR);

    /* Project each world-space line once; ceiling lines mirror the floor. */
    for (line = 0; line <= MAP_WIDTH; ++line) {
        if (direction_y_value == 0) {
            fixed_t distance = x_line_near;

            if (distance >= FLOOR_NEAR_DISTANCE && distance <= FLOOR_FAR_DISTANCE) {
                int24_t screen_y = GFX_LCD_HEIGHT / 2 +
                    wall_height_for_distance(distance) / 2;

                if (screen_y < GFX_LCD_HEIGHT) {
                    add_horizontal_grid_segment(
                        &segment_end, (uint8_t)screen_y
                    );
                }
            }
        } else {
            fixed_t lateral_near = x_line_near;
            fixed_t lateral_far = x_line_far;

            add_projected_grid_segment(
                &segment_end,
                lateral_near,
                lateral_far
            );
        }

        x_line_near += x_line_step;
        x_line_far += x_line_step;
        if (direction_y_value == 0) {
            x_input_near += FIXED_ONE;
            if (x_input_near >= 0 && x_input_near < FIXED_ONE) {
                x_line_near = fixed_scale_mul(
                    x_input_near,
                    &inverse_x_scale
                );
                if (direction_x_value < 0) x_line_near = -x_line_near;
                x_line_far = x_line_near;
            }
        } else {
            x_input_near -= FIXED_ONE;
            x_input_far -= FIXED_ONE;
            if (x_input_near <= 0 && x_input_near > -FIXED_ONE) {
                x_line_near = fixed_scale_mul(
                    x_input_near,
                    &inverse_y_scale
                );
                if (direction_y_value < 0) x_line_near = -x_line_near;
            }
            if (x_input_far <= 0 && x_input_far > -FIXED_ONE) {
                x_line_far = fixed_scale_mul(
                    x_input_far,
                    &inverse_y_scale
                );
                if (direction_y_value < 0) x_line_far = -x_line_far;
            }
        }
    }

    for (line = 0; line <= MAP_HEIGHT; ++line) {
        if (direction_x_value == 0) {
            fixed_t distance = y_line_near;

            if (distance >= FLOOR_NEAR_DISTANCE && distance <= FLOOR_FAR_DISTANCE) {
                int24_t screen_y = GFX_LCD_HEIGHT / 2 +
                    wall_height_for_distance(distance) / 2;

                if (screen_y < GFX_LCD_HEIGHT) {
                    add_horizontal_grid_segment(
                        &segment_end, (uint8_t)screen_y
                    );
                }
            }
        } else {
            fixed_t lateral_near = y_line_near;
            fixed_t lateral_far = y_line_far;

            add_projected_grid_segment(
                &segment_end,
                lateral_near,
                lateral_far
            );
        }


        y_line_near += y_line_step;
        y_line_far += y_line_step;
        if (direction_x_value == 0) {
            y_input_near += FIXED_ONE;
            if (y_input_near >= 0 && y_input_near < FIXED_ONE) {
                y_line_near = fixed_scale_mul(
                    y_input_near,
                    &inverse_y_scale
                );
                if (direction_y_value < 0) y_line_near = -y_line_near;
                y_line_far = y_line_near;
            }
        } else {
            y_input_near += FIXED_ONE;
            y_input_far += FIXED_ONE;
            if (y_input_near >= 0 && y_input_near < FIXED_ONE) {
                y_line_near = fixed_scale_mul(
                    y_input_near,
                    &inverse_x_scale
                );
                if (direction_x_value < 0) y_line_near = -y_line_near;
            }
            if (y_input_far >= 0 && y_input_far < FIXED_ONE) {
                y_line_far = fixed_scale_mul(
                    y_input_far,
                    &inverse_x_scale
                );
                if (direction_x_value < 0) y_line_far = -y_line_far;
            }
        }
    }

    gfx_SetColor(COLOR_CEILING_NEAR);
    {
        const GridSegment *segment;
        uint8_t ceiling_near_y = (uint8_t)(GFX_LCD_HEIGHT - near_screen_y);

        for (segment = grid_segments; segment != segment_end; ++segment) {
#if RENDER_ASM_BACKGROUND
            uint8_t far_y =
                (uint8_t)(GFX_LCD_HEIGHT - FLOOR_FAR_SCREEN_Y);
#else
            uint8_t far_y = (uint8_t)(GFX_LCD_HEIGHT - segment->far_y);
#endif

#if RENDER_ASM_BACKGROUND
            gfx_Line(
                segment->far_x,
                far_y,
                segment->near_x,
                ceiling_near_y
            );
#else
            if (segment->kind == GRID_HORIZONTAL) {
                gfx_HorizLine_NoClip(0, far_y, GFX_LCD_WIDTH);
            } else if (segment->kind == GRID_SLANTED_NOCLIP) {
                gfx_Line_NoClip(
                    segment->far_x,
                    far_y,
                    segment->near_x,
                    ceiling_near_y
                );
            } else {
                gfx_Line(
                    segment->far_x,
                    far_y,
                    segment->near_x,
                    ceiling_near_y
                );
            }
#endif
        }
    }
}

static inline __attribute__((always_inline)) void draw_span(
    uint24_t x,
    uint8_t start,
    uint8_t end,
    uint8_t color,
    uint8_t clip_start,
    uint8_t clip_end
) {
    if (start < clip_start) start = clip_start;
    if (end > clip_end) end = clip_end;
    if (end <= start) {
        return;
    }

#if RENDER_ASM_WALLS
    render_asm_draw_solid_segment(x, start, end, color);
#else
    gfx_SetColor(color);
    gfx_FillRectangle_NoClip(x, start, COLUMN_WIDTH, (uint8_t)(end - start));
#endif
}

#if RENDER_ASM_PORTAL_GEOMETRY
static inline __attribute__((always_inline)) void portal_opening(
    const RayHit *ray,
    const WallContext *context,
    uint8_t *top,
    uint8_t *bottom
) {
    render_asm_portal_opening(ray, context, top, bottom);
}
#else
static void portal_opening(const RayHit *ray, const WallContext *context, uint8_t *top, uint8_t *bottom) {
    uint24_t profile = render_portal_profile_by_u[ray->wall_u];
    uint24_t half_height = (profile * context->full_height) >> 8;
    uint8_t center = context->center;
    uint8_t visible_half = (uint8_t)(center - context->start);

    /* Keep a distant portal visibly open after its ellipse becomes sub-pixel. */
    if (profile != 0 && visible_half >= 2 && half_height < 2) {
        half_height = 2;
    }
    if (half_height > visible_half) {
        half_height = visible_half;
    }
    *top = (uint8_t)(center - half_height);
    *bottom = (uint8_t)(center + half_height);
}
#endif

static inline __attribute__((always_inline)) uint8_t portal_ring_thickness(
    uint8_t top,
    uint8_t bottom
) {
    uint8_t height = (uint8_t)(bottom - top);

    return height >= 8u ? 2u : 1u;
}

static void draw_wall_clipped(
    const RayHit *ray,
    const WallContext *context,
    uint24_t x,
    uint8_t clip_start,
    uint8_t clip_end
) {
    WallContext clipped = *context;

    if (clipped.start < clip_start) clipped.start = clip_start;
    if (clipped.end > clip_end) clipped.end = clip_end;
    draw_textured_wall_segment(
        ray, x, clipped.start, clipped.end, context, 0
    );
}

#if !RENDER_ASM_WALLS
static inline __attribute__((always_inline)) uint8_t draw_textured_range_clipped(
    const RayHit *ray,
    uint24_t x,
    uint8_t start,
    uint8_t end,
    const WallContext *context,
    uint8_t clip_start,
    uint8_t clip_end,
    uint8_t reuse_setup
) {
    if (start < clip_start) start = clip_start;
    if (end > clip_end) end = clip_end;
    if (end <= start) {
        return 0;
    }
    draw_textured_wall_segment(
        ray, x, start, end, context, reuse_setup
    );
    return 1;
}
#endif

static void draw_portal_ring(
    const RayHit *ray,
    const WallContext *context,
    uint24_t x,
    uint8_t clip_start,
    uint8_t clip_end,
    uint8_t top,
    uint8_t bottom
) {
    uint8_t top_end;
    uint8_t bottom_start;
    uint8_t thickness;
    uint8_t color;

    if (ray->portal_kind == PORTAL_NONE) {
        return;
    }

    color = portal_color(ray->portal_kind);
    thickness = portal_ring_thickness(top, bottom);
    top_end = (uint8_t)(top + thickness);
    if (top_end > context->end) top_end = context->end;

    if (bottom <= top + thickness) {
        draw_span(x, top, top_end, color, clip_start, clip_end);
        return;
    }
    bottom_start = (uint8_t)(bottom - thickness);
    if (bottom_start < context->start) bottom_start = context->start;
    draw_span(x, top, top_end, color, clip_start, clip_end);
    draw_span(x, bottom_start, bottom, color, clip_start, clip_end);
}

#if RENDER_ASM_WALLS
static inline __attribute__((always_inline)) void draw_portal_mask(
    const RayHit *ray,
    const WallContext *context,
    uint24_t x,
    uint8_t clip_start,
    uint8_t clip_end,
    uint8_t top,
    uint8_t bottom
) {
    render_asm_draw_portal_mask(
        ray, context, x, clip_start, clip_end, top, bottom
    );
}
#else
static void draw_portal_mask(
    const RayHit *ray,
    const WallContext *context,
    uint24_t x,
    uint8_t clip_start,
    uint8_t clip_end,
    uint8_t top,
    uint8_t bottom
) {
    uint8_t top_end;
    uint8_t bottom_start;
    uint8_t thickness;
    uint8_t ring = portal_color(ray->portal_kind);
    uint8_t reuse_setup;

    thickness = portal_ring_thickness(top, bottom);
    top_end = (uint8_t)(top + thickness);
    if (top_end > context->end) top_end = context->end;
    if (bottom <= top + thickness) {
        draw_textured_range_clipped(
            ray, x, context->start, context->end, context,
            clip_start, clip_end, 0
        );
        draw_span(x, top, top_end, ring, clip_start, clip_end);
        return;
    }

    bottom_start = (uint8_t)(bottom - thickness);
    if (bottom_start < context->start) bottom_start = context->start;
    reuse_setup = draw_textured_range_clipped(
        ray, x, context->start, top, context, clip_start, clip_end, 0
    );
    draw_span(x, top, top_end, ring, clip_start, clip_end);
    draw_span(x, bottom_start, bottom, ring, clip_start, clip_end);
    draw_textured_range_clipped(
        ray, x, bottom, context->end, context,
        clip_start, clip_end, reuse_setup
    );
}
#endif

#if RENDER_LAYER_MAJOR_PORTALS

enum LayerHitResult {
    LAYER_HIT_TERMINAL = 0,
    LAYER_HIT_CONTINUES = 1
};

/* Same packed flags as .Lportal_transform_flags in render_asm.s. */
static const uint8_t render_layer_transform_flags[16] = {
    0x82, 0x00, 0x03, 0x81,
    0x00, 0x82, 0x81, 0x03,
    0x01, 0x83, 0x82, 0x00,
    0x83, 0x01, 0x00, 0x82
};

static inline __attribute__((always_inline)) void render_layer_plan_init(
    PortalTransformPlan *plan,
    const RayHit *hit,
    const Portal *exit
) {
    uint8_t *tangent = (uint8_t *)&plan->tangent_base;
    uint8_t *normal = (uint8_t *)&plan->normal;

    plan->flags = render_layer_transform_flags[
        (uint8_t)(hit->wall_direction * 4u + exit->direction)
    ];
    tangent[0] = 0;
    tangent[2] = 0;

    if (exit->direction == DIR_NORTH || exit->direction == DIR_SOUTH) {
        tangent[1] = exit->y;
        if (exit->direction == DIR_NORTH) {
            normal[0] = 0xFFu;
            normal[1] = (uint8_t)(exit->x - 1u);
            normal[2] = exit->x == 0 ? 0xFFu : 0;
        } else {
            normal[0] = 1;
            normal[1] = (uint8_t)(exit->x + 1u);
            normal[2] = 0;
        }
        plan->tangent_to_x = 0;
    } else {
        tangent[1] = exit->x;
        if (exit->direction == DIR_WEST) {
            normal[0] = 0xFFu;
            normal[1] = (uint8_t)(exit->y - 1u);
            normal[2] = exit->y == 0 ? 0xFFu : 0;
        } else {
            normal[0] = 1;
            normal[1] = (uint8_t)(exit->y + 1u);
            normal[2] = 0;
        }
        plan->tangent_to_x = 1;
    }
}

/*
 * Finish one exact DDA hit without transforming it. This is the original
 * front-to-back compositor split at the portal boundary: a terminal wall is
 * drawn immediately, while a traversable portal leaves a checkpoint that a
 * later run can resume.
 */
static uint8_t render_layer_finish_hit(
    const GameState *game,
    uint24_t x,
    LayerRay *ray
) {
    RayHit *hit = &ray->hit;
    const Portal *exit = &render_ray_state.portal_exit;
    uint8_t kind;
    uint8_t portal_id;
    uint8_t has_exit;
    const WallContext *context;
    uint8_t opening_start = 0;
    uint8_t opening_end = 0;
    uint8_t next_clip_start;
    uint8_t next_clip_end;
    fixed_t segment_distance;
    fixed_t projected_distance;

    (void)game;
    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);
#if RENDER_BENCHMARK
    if (render_benchmark_active) {
        uint8_t input_x = fixed_cell(&render_ray_state.origin_x);
        uint8_t input_y = fixed_cell(&render_ray_state.origin_y);
        uint8_t x_steps = hit->map_x >= input_x ?
            (uint8_t)(hit->map_x - input_x) :
            (uint8_t)(input_x - hit->map_x);
        uint8_t y_steps = hit->map_y >= input_y ?
            (uint8_t)(hit->map_y - input_y) :
            (uint8_t)(input_y - hit->map_y);
        uint8_t tile = (uint8_t)(map_row_offsets[hit->map_y] + hit->map_x);

        ++render_benchmark.cast_count;
        render_benchmark.dda_steps += (uint16_t)x_steps + y_steps;
        if (render_builtin_portal_by_tile[tile] != 0 ||
            tile == render_scratch.primary_tile ||
            tile == render_scratch.secondary_tile) {
            ++render_benchmark.portal_candidates;
        }
    }
#endif
#if RENDER_PROFILE
    ++render_profile.cast_count;
#endif

    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_TRACE);
    segment_distance = hit->distance;
    projected_distance = ray->distance_bias + segment_distance;
#if RENDER_RAY_DIAGNOSTIC
    {
        fixed_t minor_component = hit->side == 0 ?
            render_ray_state.ray_y : render_ray_state.ray_x;
        uint16_t minor = (uint16_t)fixed_abs(minor_component);

        if (projected_distance < 96 &&
            (!render_profile.near_valid ||
                minor < render_profile.near_minor ||
                (minor == render_profile.near_minor &&
                    projected_distance < render_profile.near_projected_distance))) {
            render_profile.near_valid = 1;
            render_profile.near_column = (uint8_t)(x / COLUMN_WIDTH);
            render_profile.near_layer = ray->count;
            render_profile.near_side = hit->side;
            render_profile.near_origin_fraction = hit->side == 0 ?
                *(const uint8_t *)&render_ray_state.origin_y :
                *(const uint8_t *)&render_ray_state.origin_x;
            render_profile.near_hit_cell = (uint8_t)(
                (hit->map_y << 4) | hit->map_x
            );
            render_profile.near_minor = minor;
            render_profile.near_raw_distance = segment_distance;
            render_profile.near_projected_distance = projected_distance;
        }
    }
#endif

    hit->distance = projected_distance;
    kind = render_ray_state.portal_kind;
    portal_id = render_ray_state.portal_id;
    has_exit = render_ray_state.portal_has_exit;
#if RENDER_BENCHMARK
    if (render_benchmark_active && has_exit) {
        ++render_benchmark.linked_exits;
    }
#endif
    hit->portal_kind = kind;
    context = wall_context_for_distance(hit->distance);
    if (kind != PORTAL_NONE) {
        portal_opening(hit, context, &opening_start, &opening_end);
    }
    ++ray->count;

    if (!has_exit) {
        if (ray->draw_clip_end > ray->draw_clip_start) {
#if RENDER_BENCHMARK
            render_benchmark_count_wall(
                context,
                ray->draw_clip_start,
                ray->draw_clip_end
            );
#endif
            RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_WALL_DRAW);
            draw_wall_clipped(
                hit,
                context,
                x,
                ray->draw_clip_start,
                ray->draw_clip_end
            );
            if (kind != PORTAL_NONE) {
                RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_DRAW);
                draw_portal_ring(
                    hit,
                    context,
                    x,
                    ray->draw_clip_start,
                    ray->draw_clip_end,
                    opening_start,
                    opening_end
                );
            }
        }
        return LAYER_HIT_TERMINAL;
    }

    if (ray->draw_clip_end > ray->draw_clip_start) {
#if RENDER_BENCHMARK
        render_benchmark_count_mask(
            context,
            ray->draw_clip_start,
            ray->draw_clip_end,
            opening_start,
            opening_end
        );
#endif
        RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_DRAW);
        draw_portal_mask(
            hit,
            context,
            x,
            ray->draw_clip_start,
            ray->draw_clip_end,
            opening_start,
            opening_end
        );
        RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_TRACE);
    }

    next_clip_start = opening_start > ray->clip_start ?
        opening_start : ray->clip_start;
    next_clip_end = opening_end < ray->clip_end ?
        opening_end : ray->clip_end;
    if (next_clip_end <= next_clip_start) {
        return LAYER_HIT_TERMINAL;
    }

    {
        uint8_t thickness = portal_ring_thickness(opening_start, opening_end);
        uint8_t opening_center_start = (uint8_t)(opening_start + thickness);

        if (opening_end <= opening_center_start) {
            ray->draw_clip_start = ray->draw_clip_end;
        } else {
            uint8_t opening_center_end = (uint8_t)(opening_end - thickness);

            if (opening_center_start > ray->draw_clip_start) {
                ray->draw_clip_start = opening_center_start;
            }
            if (opening_center_end < ray->draw_clip_end) {
                ray->draw_clip_end = opening_center_end;
            }
            if (ray->draw_clip_end <= ray->draw_clip_start) {
                ray->draw_clip_start = ray->draw_clip_end;
            }
        }
    }

    ray->clip_start = next_clip_start;
    ray->clip_end = next_clip_end;
    {
        uint8_t visit_mask = portal_visit_bits[portal_id & 7u];
        uint8_t already_visited = portal_id < 8u ?
            ray->visited_low : ray->visited_high;
        uint8_t clip_height = (uint8_t)(ray->clip_end - ray->clip_start);

        if (clip_height < PORTAL_RECURSE_MIN_HEIGHT ||
            ray->count >= MAX_RENDER_PORTAL_DEPTH ||
            (already_visited & visit_mask) != 0) {
            return LAYER_HIT_TERMINAL;
        }
        if (portal_id < 8u) {
            ray->visited_low |= visit_mask;
        } else {
            ray->visited_high |= visit_mask;
        }
    }

    ray->distance_bias = projected_distance;
    ray->continues = 1;
    (void)exit;
    return LAYER_HIT_CONTINUES;
}

static uint8_t render_layer_trace_first(
    const GameState *game,
    uint24_t x,
    fixed_t ray_x,
    fixed_t ray_y,
    LayerRay *ray
) {
    ray->distance_bias = 0;
    ray->clip_start = 0;
    ray->clip_end = GFX_LCD_HEIGHT;
    ray->draw_clip_start = 0;
    ray->draw_clip_end = GFX_LCD_HEIGHT;
    ray->visited_low = 0;
    ray->visited_high = 0;
    ray->count = 0;
    ray->continues = 0;

    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_DDA);
    render_asm_cast_wall_begin(
        game->player_x,
        game->player_y,
        ray_x,
        ray_y,
        &ray->hit
    );
    (void)render_layer_finish_hit(game, x, ray);

    /* Store all 80 layer-zero states, including terminal columns. */
    ray->dda = render_ray_state;
    ray->dda.hit = &ray->hit;
    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);
    return ray->continues;
}

static void render_layer_continue_run_ray(
    const GameState *game,
    uint24_t x,
    LayerRay *ray
) {
    render_ray_state = ray->dda;
    render_ray_state.hit = &ray->hit;

    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_TRACE);
#if RENDER_BENCHMARK
    if (render_benchmark_active) {
        ++render_benchmark.portal_transforms;
    }
#endif
    render_asm_transform_ray_predecoded_state();
    ray->continues = 0;

    while (ray->count < MAX_RENDER_PORTAL_DEPTH) {
        RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_DDA);
        render_asm_cast_wall_continue(&ray->hit);
        if (render_layer_finish_hit(game, x, ray) != LAYER_HIT_CONTINUES) {
            break;
        }
#if RENDER_BENCHMARK
        if (render_benchmark_active) {
            ++render_benchmark.portal_transforms;
        }
#endif
        (void)transform_ray(&ray->hit, &render_ray_state.portal_exit);
        ray->continues = 0;
    }

    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);
#if RENDER_PROFILE
    if (ray->count > render_profile.max_depth) {
        render_profile.max_depth = ray->count;
    }
#endif
}

static uint8_t render_layer_trace_first_pass(
    const GameState *game,
    RayStepper *ray_x,
    RayStepper *ray_y
) {
    uint24_t column;
    uint8_t run_count = 0;

    for (column = 0; column < LOGICAL_COLUMNS; ++column) {
        LayerRay *ray = &render_layer_rays[column];

        if (render_layer_trace_first(
                game,
                column * COLUMN_WIDTH,
                ray_x->value,
                ray_y->value,
                ray)) {
            if (run_count != 0) {
                FirstPortalRun *previous =
                    &render_first_portal_runs[run_count - 1u];

                if (previous->one_past_last == column &&
                    previous->portal_id == ray->dda.portal_id) {
                    previous->one_past_last = (uint8_t)(column + 1u);
                } else {
                    FirstPortalRun *run = &render_first_portal_runs[run_count++];
                    run->first = (uint8_t)column;
                    run->one_past_last = (uint8_t)(column + 1u);
                    run->portal_id = ray->dda.portal_id;
                    render_layer_plan_init(
                        &run->plan,
                        &ray->hit,
                        &ray->dda.portal_exit
                    );
                }
            } else {
                FirstPortalRun *run = &render_first_portal_runs[run_count++];
                run->first = (uint8_t)column;
                run->one_past_last = (uint8_t)(column + 1u);
                run->portal_id = ray->dda.portal_id;
                render_layer_plan_init(
                    &run->plan,
                    &ray->hit,
                    &ray->dda.portal_exit
                );
            }
        }

#if RENDER_PROFILE
        if (!ray->continues && ray->count > render_profile.max_depth) {
            render_profile.max_depth = ray->count;
        }
#endif
        ray_stepper_advance(ray_x);
        ray_stepper_advance(ray_y);
    }
    return run_count;
}

static void render_layer_continue_first_runs(
    const GameState *game,
    uint8_t run_count
) {
    uint8_t run_index;

    for (run_index = 0; run_index < run_count; ++run_index) {
        const FirstPortalRun *run = &render_first_portal_runs[run_index];
        uint8_t column;

        render_layer_transform_plan = run->plan;
        for (column = run->first; column < run->one_past_last; ++column) {
            render_layer_continue_run_ray(
                game,
                (uint24_t)column * COLUMN_WIDTH,
                &render_layer_rays[column]
            );
        }
    }
}

#else

#if RENDER_COLUMN_NOINLINE
static __attribute__((noinline)) void render_column(
#else
static void render_column(
#endif
    const GameState *game,
    uint24_t x,
    fixed_t ray_x,
    fixed_t ray_y
) {
#if !RENDER_ASM_RAYCAST
    fixed_t origin_x = game->player_x;
    fixed_t origin_y = game->player_y;
    int24_t map_x = fixed_cell(&origin_x);
    int24_t map_y = fixed_cell(&origin_y);
    fixed_t delta_x = delta_for_component(ray_x);
    fixed_t delta_y = delta_for_component(ray_y);
#endif
    fixed_t distance_bias = 0;
    uint8_t visited_low = 0;
    uint8_t visited_high = 0;
    uint8_t count = 0;
    uint8_t clip_start = 0;
    uint8_t clip_end = GFX_LCD_HEIGHT;
    uint8_t draw_clip_start = 0;
    uint8_t draw_clip_end = GFX_LCD_HEIGHT;
    RayHit *hit = &render_scratch.hit;

    while (count < MAX_RENDER_PORTAL_DEPTH) {
#if RENDER_ASM_RAYCAST
        const Portal *exit;
#else
        Portal exit;
#endif
        uint8_t kind;
        uint8_t portal_id;
        uint8_t has_exit;
        const WallContext *context;
        uint8_t opening_start;
        uint8_t opening_end;
        uint8_t next_clip_start;
        uint8_t next_clip_end;
        fixed_t segment_distance;
        fixed_t projected_distance;
        RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_DDA);
#if RENDER_ASM_RAYCAST
        if (count == 0) {
            render_asm_cast_wall_begin(
                game->player_x, game->player_y, ray_x, ray_y, hit
            );
        } else {
            render_asm_cast_wall_continue(hit);
        }
#else
        cast_wall_with_delta(
            origin_x,
            origin_y,
            ray_x,
            ray_y,
            map_x,
            map_y,
            hit,
            delta_x,
            delta_y
        );
#endif
        RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);
#if RENDER_BENCHMARK
        if (render_benchmark_active) {
#if RENDER_ASM_RAYCAST
            uint8_t input_x = fixed_cell(&render_ray_state.origin_x);
            uint8_t input_y = fixed_cell(&render_ray_state.origin_y);
#else
            uint8_t input_x = (uint8_t)map_x;
            uint8_t input_y = (uint8_t)map_y;
#endif
            uint8_t x_steps = hit->map_x >= input_x ?
                (uint8_t)(hit->map_x - input_x) :
                (uint8_t)(input_x - hit->map_x);
            uint8_t y_steps = hit->map_y >= input_y ?
                (uint8_t)(hit->map_y - input_y) :
                (uint8_t)(input_y - hit->map_y);
            uint8_t tile = (uint8_t)(
                map_row_offsets[hit->map_y] + hit->map_x
            );

            ++render_benchmark.cast_count;
            render_benchmark.dda_steps += (uint16_t)x_steps + y_steps;
            if (render_builtin_portal_by_tile[tile] != 0 ||
                tile == render_scratch.primary_tile ||
                tile == render_scratch.secondary_tile) {
                ++render_benchmark.portal_candidates;
            }
        }
#endif
#if RENDER_PROFILE
        ++render_profile.cast_count;
#endif
        RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_TRACE);
        segment_distance = hit->distance;
        projected_distance = distance_bias + segment_distance;
#if RENDER_RAY_DIAGNOSTIC
        {
#if RENDER_ASM_RAYCAST
            fixed_t minor_component = hit->side == 0 ?
                render_ray_state.ray_y : render_ray_state.ray_x;
#else
            fixed_t minor_component = hit->side == 0 ? ray_y : ray_x;
#endif
            uint16_t minor = (uint16_t)fixed_abs(minor_component);

            /* A max-height one-ray streak has projected distance below 96.
             * Retain the most nearly collinear candidate so a calculator
             * screenshot identifies its exact ray and boundary ownership. */
            if (projected_distance < 96 &&
                (!render_profile.near_valid ||
                    minor < render_profile.near_minor ||
                    (minor == render_profile.near_minor &&
                        projected_distance <
                            render_profile.near_projected_distance))) {
                render_profile.near_valid = 1;
                render_profile.near_column = (uint8_t)(x / COLUMN_WIDTH);
                render_profile.near_layer = count;
                render_profile.near_side = hit->side;
#if RENDER_ASM_RAYCAST
                render_profile.near_origin_fraction = hit->side == 0 ?
                    *(const uint8_t *)&render_ray_state.origin_y :
                    *(const uint8_t *)&render_ray_state.origin_x;
#else
                render_profile.near_origin_fraction = hit->side == 0 ?
                    *(const uint8_t *)&origin_y : *(const uint8_t *)&origin_x;
#endif
                render_profile.near_hit_cell = (uint8_t)(
                    (hit->map_y << 4) | hit->map_x
                );
                render_profile.near_minor = minor;
                render_profile.near_raw_distance = segment_distance;
                render_profile.near_projected_distance = projected_distance;
            }
        }
#endif
        hit->distance = projected_distance;
#if RENDER_ASM_RAYCAST
        exit = &render_ray_state.portal_exit;
        kind = render_ray_state.portal_kind;
        portal_id = render_ray_state.portal_id;
        has_exit = render_ray_state.portal_has_exit;
#else
        has_exit = render_portal_find_exit(
            game,
            hit->map_x,
            hit->map_y,
            hit->wall_direction,
            &exit,
            &kind,
            &portal_id
        );
#endif
#if RENDER_BENCHMARK
        if (render_benchmark_active && has_exit) {
            ++render_benchmark.linked_exits;
        }
#endif
        hit->portal_kind = kind;
        context = wall_context_for_distance(hit->distance);
        if (kind != PORTAL_NONE) {
            portal_opening(hit, context, &opening_start, &opening_end);
        }
        ++count;

        if (!has_exit) {
            if (draw_clip_end > draw_clip_start) {
#if RENDER_BENCHMARK
                render_benchmark_count_wall(
                    context,
                    draw_clip_start,
                    draw_clip_end
                );
#endif
                RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_WALL_DRAW);
                draw_wall_clipped(
                    hit,
                    context,
                    x,
                    draw_clip_start,
                    draw_clip_end
                );
                if (kind != PORTAL_NONE) {
                    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_DRAW);
                    draw_portal_ring(
                        hit,
                        context,
                        x,
                        draw_clip_start,
                        draw_clip_end,
                        opening_start,
                        opening_end
                    );
                    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_TRACE);
                }
            }
            break;
        }

        /*
         * Composite the nearest portal first.  Every pixel written here is
         * opaque in the old back-to-front result, so deeper layers only need
         * the still-open center of the ring.  The independent visibility
         * clip below deliberately retains the full geometric aperture for
         * recursion, loop detection, and the minimum-height decision.
         */
        if (draw_clip_end > draw_clip_start) {
#if RENDER_BENCHMARK
            render_benchmark_count_mask(
                context,
                draw_clip_start,
                draw_clip_end,
                opening_start,
                opening_end
            );
#endif
            RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_DRAW);
            draw_portal_mask(
                hit,
                context,
                x,
                draw_clip_start,
                draw_clip_end,
                opening_start,
                opening_end
            );
            RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_PORTAL_TRACE);
        }

        next_clip_start = opening_start > clip_start ? opening_start : clip_start;
        next_clip_end = opening_end < clip_end ? opening_end : clip_end;

        /* This portal is behind the current aperture, so its wall is terminal. */
        if (next_clip_end <= next_clip_start) {
            break;
        }

        {
            uint8_t thickness = portal_ring_thickness(
                opening_start,
                opening_end
            );
            uint8_t opening_center_start = (uint8_t)(
                opening_start + thickness
            );

            if (opening_end <= opening_center_start) {
                draw_clip_start = draw_clip_end;
            } else {
                uint8_t opening_center_end = (uint8_t)(
                    opening_end - thickness
                );

                if (opening_center_start > draw_clip_start) {
                    draw_clip_start = opening_center_start;
                }
                if (opening_center_end < draw_clip_end) {
                    draw_clip_end = opening_center_end;
                }
                if (draw_clip_end <= draw_clip_start) {
                    draw_clip_start = draw_clip_end;
                }
            }
        }

        clip_start = next_clip_start;
        clip_end = next_clip_end;

        /* Preserve an open aperture at the recursion/visibility limit. */
        {
            uint8_t visit_mask = portal_visit_bits[portal_id & 7u];
            uint8_t already_visited = portal_id < 8u ?
                visited_low : visited_high;
            uint8_t clip_height = (uint8_t)(clip_end - clip_start);

            if (clip_height < PORTAL_RECURSE_MIN_HEIGHT ||
                count >= MAX_RENDER_PORTAL_DEPTH ||
                (already_visited & visit_mask) != 0) {
                break;
            }

            if (portal_id < 8u) {
                visited_low |= visit_mask;
            } else {
                visited_high |= visit_mask;
            }
        }
#if !RENDER_ASM_TRANSFORM
        hit->distance = segment_distance;
#endif
        {
#if RENDER_BENCHMARK
            if (render_benchmark_active) {
                ++render_benchmark.portal_transforms;
            }
#endif
#if RENDER_ASM_TRANSFORM
            (void)transform_ray(hit, exit);
#else
#if RENDER_ASM_RAYCAST
            int8_t rotation = transform_ray(
                hit, exit, &origin_x, &origin_y, &ray_x, &ray_y
            );
#else
            int8_t rotation = transform_ray(
                hit, &exit, &origin_x, &origin_y, &ray_x, &ray_y
            );
#endif
            if ((rotation & 1) != 0) {
                fixed_t swap = delta_x;

                delta_x = delta_y;
                delta_y = swap;
            }
#endif
        }
#if !RENDER_ASM_TRANSFORM
        hit->distance = projected_distance;
#endif
        distance_bias = projected_distance;
#if !RENDER_ASM_RAYCAST
        map_x = fixed_cell(&origin_x);
        map_y = fixed_cell(&origin_y);
#endif
    }

    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);

#if RENDER_PROFILE
    if (count > render_profile.max_depth) {
        render_profile.max_depth = count;
    }
#endif
}

#endif /* RENDER_LAYER_MAJOR_PORTALS */

void game_init(GameState *game) {
    game->player_x = FIXED_ONE + FIXED_ONE / 2;
    game->player_y = FIXED_ONE * 2 + FIXED_ONE / 2;
    game->angle = 32u << ANGLE_FRACTION_BITS;
    game->primary.valid = 0;
    game->secondary.valid = 0;
    game->previous_buttons = 0;
}

void game_graphics_init(void) {
    uint24_t index;
    uint16_t fraction;
    uint16_t height = WALL_HEIGHT_MAX;
    uint16_t previous_height = 0;
    uint16_t profile_count = 0;
    uint8_t x;
    uint8_t y;
    uint8_t material;
    uint8_t boundary;
    uint8_t shade;
    uint8_t texture_column[WALL_TEXTURE_HEIGHT];
    static const uint8_t shade_offsets[WALL_SHADE_LEVELS] = {0, 8, 16, 24};
    static const uint8_t wall_palette_rgb
        [WALL_TEXTURE_COUNT][WALL_BASE_COLOR_COUNT][3] = {
        {
            {64, 54, 48}, {86, 65, 54}, {128, 68, 45}, {150, 78, 52},
            {170, 92, 60}, {190, 108, 70}, {210, 125, 84}, {236, 150, 100}
        },
        {
            {42, 49, 54}, {55, 65, 70}, {72, 83, 88}, {88, 100, 105},
            {105, 119, 124}, {122, 138, 142}, {151, 169, 171}, {206, 221, 218}
        },
        {
            {55, 52, 48}, {72, 69, 64}, {96, 93, 86}, {116, 112, 103},
            {136, 132, 122}, {158, 153, 142}, {184, 179, 167}, {218, 213, 201}
        },
        {
            {25, 29, 35}, {40, 46, 54}, {54, 65, 78}, {68, 80, 92},
            {82, 96, 108}, {104, 119, 128}, {190, 145, 35}, {240, 200, 65}
        }
    };

    /*
     * Preserve C's truncation toward zero exactly.  Within each 1/64-turn
     * segment, an error accumulator generates
     *   start + trunc((next - start) * fraction / 256)
     * without doing a multiply or divide during initialization either.
     */
    for (index = 0; index < ANGLE_STEPS; ++index) {
        int16_t value = direction_y[index];
        int16_t difference = (int16_t)(
            direction_y[(index + 1u) & (ANGLE_STEPS - 1u)] - value
        );
        int8_t step = difference < 0 ? -1 : 1;
        uint8_t amount = (uint8_t)(
            difference < 0 ? -difference : difference
        );
        uint16_t error = 0;
        uint24_t offset = index << ANGLE_FRACTION_BITS;

        for (fraction = 0; fraction < (1u << ANGLE_FRACTION_BITS);
            ++fraction) {
            render_direction_y_by_angle[offset + fraction] = value;
            error = (uint16_t)(error + amount);
            if (error >= (1u << ANGLE_FRACTION_BITS)) {
                error = (uint16_t)(error - (1u << ANGLE_FRACTION_BITS));
                value = (int16_t)(value + step);
            }
        }
    }

    for (index = 0; index <= FIXED_ONE * 2u; ++index) {
        int16_t component = (int16_t)index - FIXED_ONE;
        uint16_t magnitude = (uint16_t)(
            component < 0 ? -component : component
        );
        int16_t scaled = (int16_t)(
            ((uint24_t)magnitude * FIELD_OF_VIEW) >> FIXED_SHIFT
        );

        render_fov_by_direction[index] =
            component < 0 ? (int16_t)-scaled : scaled;
    }

    render_screen_rows[0].offset = 0;
    for (index = 1; index < GFX_LCD_HEIGHT; ++index) {
        render_screen_rows[index].offset =
            render_screen_rows[index - 1].offset + GFX_LCD_WIDTH;
    }

    for (index = 0; index < WALL_HEIGHT_TABLE_SIZE; ++index) {
        if (index != 0) {
            while (height > 1 && (uint24_t)height * index >
                ((uint24_t)GFX_LCD_HEIGHT * FIXED_ONE >> WALL_HEIGHT_TABLE_SHIFT)) {
                --height;
            }
        }

        if (height != previous_height) {
            WallContext *context = &render_wall_scale_profiles[profile_count];
            uint16_t step =
                (uint16_t)(((uint24_t)WALL_TEXTURE_HEIGHT << 8) / height);
            uint16_t visible_height = height < GFX_LCD_HEIGHT ?
                height : GFX_LCD_HEIGHT;

            context->full_height = height;
            if (height >= GFX_LCD_HEIGHT) {
                context->start = 0;
                context->end = GFX_LCD_HEIGHT;
            } else {
                uint8_t visible = (uint8_t)height;
                uint8_t start = (uint8_t)(GFX_LCD_HEIGHT - visible) >> 1;

                context->start = start;
                context->end = (uint8_t)(start + visible);
            }
            context->boundaries = render_wall_texture_boundaries[profile_count];
            context->center = (uint8_t)(
                ((uint16_t)context->start + context->end) >> 1
            );
            for (boundary = 0;
                boundary < WALL_TEXTURE_BOUNDARY_COUNT;
                ++boundary) {
                uint24_t numerator = (uint24_t)boundary << 8;
                uint24_t screen_offset =
                    (numerator + step - 1) / step;

                if (screen_offset > visible_height) {
                    screen_offset = visible_height;
                }
                render_wall_texture_boundaries[profile_count][boundary] =
                    (uint8_t)(context->start + screen_offset);
            }
            previous_height = height;
            ++profile_count;
        }
        render_wall_scale_offset[index] = (uint16_t)(
            (profile_count - 1u) * sizeof(WallContext)
        );
    }

    grid_projection_init(&render_grid_near_projection, FLOOR_NEAR_DISTANCE);
    grid_projection_init(&grid_far_projection, FLOOR_FAR_DISTANCE);

    for (index = 0; index < 256; ++index) {
        render_portal_profile_by_u[index] =
            (uint8_t)((index * (256u - index)) >> 7);
    }

    for (material = 0; material < WALL_TEXTURE_COUNT; ++material) {
        for (x = 0; x < WALL_TEXTURE_WIDTH; ++x) {
            for (y = 0; y < WALL_TEXTURE_HEIGHT; ++y) {
                uint8_t source_y = (uint8_t)(y << 1);
                uint8_t texel;

                if (material == 0) {
                    uint8_t mortar = (x == 0 || source_y == 0 ||
                        source_y == 8 || ((source_y >= 8) ? x == 8 : 0));
                    uint8_t noise = (uint8_t)(
                        (x * 5u + source_y * 3u +
                            ((x ^ source_y) * 7u)) & 3u
                    );

                    texel = mortar ? 0 : (uint8_t)(2u + noise);
                } else if (material == 1) {
                    uint8_t seam = (uint8_t)(
                        x == 0 || x == 8 || source_y == 0 || source_y == 8
                    );
                    uint8_t rivet = (uint8_t)(
                        ((x & 7u) == 2u || (x & 7u) == 6u) &&
                        ((source_y & 7u) == 2u ||
                            (source_y & 7u) == 6u)
                    );
                    uint8_t brushed = (uint8_t)(
                        2u + ((x * 3u + source_y * 5u +
                            (x ^ source_y)) & 3u)
                    );

                    texel = seam ? 0 : (rivet ? 7 : brushed);
                } else if (material == 2) {
                    uint8_t joint = (uint8_t)(
                        source_y == 0 || source_y == 8 ||
                        ((source_y < 8) ? x == 0 : x == 8)
                    );
                    uint8_t aggregate = (uint8_t)(
                        2u + ((x * 7u + source_y * 11u +
                            (x ^ (source_y * 3u))) & 3u)
                    );
                    uint8_t pock = (uint8_t)(
                        ((x * 13u + source_y * 5u) & 31u) == 0u
                    );

                    texel = joint ? 0 : (pock ? 1 : aggregate);
                } else {
                    uint8_t seam = (uint8_t)(
                        x == 0 || x == 8 || source_y == 0 || source_y == 8
                    );
                    uint8_t hazard = (uint8_t)((x + source_y) & 7u);
                    uint8_t plate = (uint8_t)(
                        2u + ((x * 5u + source_y * 3u +
                            (x ^ source_y)) & 3u)
                    );

                    texel = seam ? 0 :
                        (hazard < 2u ? (uint8_t)(6u + (hazard & 1u)) : plate);
                }
                texture_column[y] = texel;
            }

            for (y = 0; y < WALL_TEXTURE_HEIGHT; ++y) {
                uint8_t next = (uint8_t)(y + 1);
                uint16_t descriptor_index = (uint16_t)(
                    ((uint16_t)material * WALL_TEXTURE_WIDTH *
                        WALL_TEXTURE_HEIGHT +
                        (uint16_t)x * WALL_TEXTURE_HEIGHT + y) *
                    WALL_TEXTURE_DESCRIPTOR_SIZE
                );

                while (next < WALL_TEXTURE_HEIGHT &&
                    texture_column[next] == texture_column[y]) {
                    ++next;
                }
                render_wall_texture_runs[descriptor_index] =
                    (uint8_t)(texture_column[y] * sizeof(WallColor));
                render_wall_texture_runs[descriptor_index + 1u] = next;
            }
        }
    }

    for (material = 0; material < WALL_TEXTURE_COUNT; ++material) {
        for (shade = 0; shade < WALL_SHADE_LEVELS; ++shade) {
            uint8_t color;

            for (color = 0; color < WALL_BASE_COLOR_COUNT; ++color) {
                WallColor *wall_color =
                    &render_wall_colors[material][shade][color];
                uint8_t palette = (uint8_t)(
                    COLOR_TEXTURE_BASE + material * WALL_PALETTE_STRIDE +
                    shade * WALL_BASE_COLOR_COUNT + color
                );

                wall_color->palette = palette;
                wall_color->packed =
                    (uint24_t)palette |
                    ((uint24_t)palette << 8) |
                    ((uint24_t)palette << 16);
            }
        }
    }

    gfx_palette[COLOR_BLACK] = gfx_RGBTo1555(0, 0, 0);
    gfx_palette[COLOR_SKY] = gfx_RGBTo1555(24, 28, 48);
    gfx_palette[COLOR_SKY_HORIZON] = gfx_RGBTo1555(48, 54, 78);
    gfx_palette[COLOR_FLOOR] = gfx_RGBTo1555(54, 54, 54);
    gfx_palette[COLOR_FLOOR_NEAR] = gfx_RGBTo1555(32, 32, 32);
    gfx_palette[COLOR_NORTH] = gfx_RGBTo1555(40, 90, 255);
    gfx_palette[COLOR_NORTH_DARK] = gfx_RGBTo1555(20, 45, 145);
    gfx_palette[COLOR_SOUTH] = gfx_RGBTo1555(40, 220, 80);
    gfx_palette[COLOR_SOUTH_DARK] = gfx_RGBTo1555(20, 120, 45);
    gfx_palette[COLOR_EAST] = gfx_RGBTo1555(240, 55, 55);
    gfx_palette[COLOR_EAST_DARK] = gfx_RGBTo1555(135, 25, 25);
    gfx_palette[COLOR_WEST] = gfx_RGBTo1555(30, 215, 215);
    gfx_palette[COLOR_WEST_DARK] = gfx_RGBTo1555(18, 115, 115);
    gfx_palette[COLOR_PRIMARY] = gfx_RGBTo1555(255, 140, 0);
    gfx_palette[COLOR_SECONDARY] = gfx_RGBTo1555(0, 130, 255);
    gfx_palette[COLOR_BUILTIN] = gfx_RGBTo1555(180, 180, 180);
    gfx_palette[COLOR_CEILING] = gfx_RGBTo1555(22, 24, 38);
    gfx_palette[COLOR_CEILING_NEAR] = gfx_RGBTo1555(46, 49, 68);

    for (material = 0; material < WALL_TEXTURE_COUNT; ++material) {
        for (shade = 0; shade < WALL_SHADE_LEVELS; ++shade) {
            uint8_t color;
            uint8_t offset = shade_offsets[shade];
            uint8_t base = (uint8_t)(
                COLOR_TEXTURE_BASE + material * WALL_PALETTE_STRIDE +
                shade * WALL_BASE_COLOR_COUNT
            );

            for (color = 0; color < WALL_BASE_COLOR_COUNT; ++color) {
                const uint8_t *rgb = wall_palette_rgb[material][color];

                gfx_palette[base + color] = gfx_RGBTo1555(
                    rgb[0] - offset,
                    rgb[1] - offset,
                    rgb[2] - offset
                );
            }
        }
    }
}

uint8_t game_update(
    GameState *game,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    fixed_t previous_x = game->player_x;
    fixed_t previous_y = game->player_y;
    uint16_t previous_angle = game->angle;
    Portal previous_primary = game->primary;
    Portal previous_secondary = game->secondary;
    uint8_t pressed = (uint8_t)(buttons & (uint8_t)~game->previous_buttons);
    uint24_t maximum_ticks;
    fixed_t move_amount;
    int24_t turn_amount;

    game->previous_buttons = buttons;
    if (ticks_per_second == 0) {
        return 0;
    }

    maximum_ticks = ticks_per_second / 8u;
    if (elapsed_ticks > maximum_ticks) {
        elapsed_ticks = maximum_ticks;
    }

    if ((pressed & PORTAL_BUTTON_PRIMARY) != 0) {
        place_portal(game, 1);
    }
    if ((pressed & PORTAL_BUTTON_SECONDARY) != 0) {
        place_portal(game, 0);
    }
    if ((pressed & PORTAL_BUTTON_CLEAR) != 0) {
        game->primary.valid = 0;
        game->secondary.valid = 0;
    }

    turn_amount = (int24_t)(((int32_t)TURN_SPEED * (1 << ANGLE_FRACTION_BITS) * elapsed_ticks) / ticks_per_second);
    game->angle = (uint16_t)((game->angle + turn_axis * turn_amount) & ANGLE_MASK);

    move_amount = (fixed_t)(((int32_t)MOVE_SPEED * elapsed_ticks) / ticks_per_second);
    move_player(game, (fixed_t)(move_axis * move_amount));

    return (uint8_t)(
        game->player_x != previous_x ||
        game->player_y != previous_y ||
        game->angle != previous_angle ||
        game->primary.x != previous_primary.x ||
        game->primary.y != previous_primary.y ||
        game->primary.direction != previous_primary.direction ||
        game->primary.valid != previous_primary.valid ||
        game->secondary.x != previous_secondary.x ||
        game->secondary.y != previous_secondary.y ||
        game->secondary.direction != previous_secondary.direction ||
        game->secondary.valid != previous_secondary.valid
    );
}

void game_render(const GameState *game) {
    fixed_t dir_x;
    fixed_t dir_y;
    fixed_t plane_x;
    fixed_t plane_y;
    RayStepper ray_x;
    RayStepper ray_y;
#if !RENDER_LAYER_MAJOR_PORTALS
    uint24_t column;
#endif
#if RENDER_PROFILE
    clock_t mark;
    clock_t now;

    render_profile.cast_count = 0;
    render_profile.max_depth = 0;
#if RENDER_RAY_DIAGNOSTIC
    render_profile.near_valid = 0;
    render_profile.near_column = 0;
    render_profile.near_layer = 0;
    render_profile.near_side = 0;
    render_profile.near_origin_fraction = 0;
    render_profile.near_hit_cell = 0;
    render_profile.near_minor = 0;
    render_profile.near_raw_distance = 0;
    render_profile.near_projected_distance = 0;
#endif
    mark = clock();
#endif

    /* Direct wall writes must not touch a buffer still being scanned out. */
    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_WAIT);
    gfx_Wait();
    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);
#if RENDER_PROFILE
    now = clock();
    render_profile.wait_ticks = now - mark;
    mark = now;
#endif
    direction_for_angle(game->angle, &dir_x, &dir_y);
    plane_x = -render_fov_by_direction[
        (uint16_t)(dir_y + FIXED_ONE)
    ];
    plane_y = render_fov_by_direction[
        (uint16_t)(dir_x + FIXED_ONE)
    ];
    ray_stepper_init(&ray_x, dir_x, plane_x);
    ray_stepper_init(&ray_y, dir_y, plane_y);
    render_scratch.primary_tile = game->primary.valid ?
        (uint8_t)(map_row_offsets[game->primary.y] + game->primary.x) : 0xFFu;
    render_scratch.secondary_tile = game->secondary.valid ?
        (uint8_t)(map_row_offsets[game->secondary.y] + game->secondary.x) : 0xFFu;
#if RENDER_ASM_RAYCAST
    render_ray_state.game = game;
    render_ray_state.primary_tile = render_scratch.primary_tile;
    render_ray_state.secondary_tile = render_scratch.secondary_tile;
#endif

#if RENDER_PROFILE
    mark = clock();
#endif

    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_BACKGROUND);
    draw_background_grid(game, dir_x, dir_y);
#if RENDER_ASM_BACKGROUND
    /*
     * Grid lines can enter the horizon only on ceiling rows 112-113 and
     * floor row 127. Repair those rows instead of rewriting all 16 rows.
     */
    render_asm_repair_horizon();
#else
    memset(
        &gfx_vbuffer[0][0] + GFX_LCD_WIDTH * 112u,
        COLOR_SKY_HORIZON,
        GFX_LCD_WIDTH * 16u
    );
#endif
    RENDER_BENCHMARK_SWITCH(GAME_RENDER_BENCH_ADMIN);

#if RENDER_PROFILE
    now = clock();
    render_profile.background_ticks = now - mark;
    mark = now;
#endif

#if RENDER_LAYER_MAJOR_PORTALS
    {
        uint8_t first_run_count = render_layer_trace_first_pass(
            game,
            &ray_x,
            &ray_y
        );

        render_layer_continue_first_runs(game, first_run_count);
    }
#else
    for (column = 0; column < LOGICAL_COLUMNS; ++column) {
        render_column(
            game,
            column * COLUMN_WIDTH,
            ray_x.value,
            ray_y.value
        );
        ray_stepper_advance(&ray_x);
        ray_stepper_advance(&ray_y);
    }
#endif

#if RENDER_PROFILE
    render_profile.columns_ticks = clock() - mark;
#endif
}

#if RENDER_PROFILE
const GameRenderProfile *game_get_render_profile(void) {
    return &render_profile;
}
#endif
