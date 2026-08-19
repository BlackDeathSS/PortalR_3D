#include "engine.h"

#include <graphx.h>
#include <limits.h>
#include <stddef.h>
#include <string.h>
#if TRUE3D_RENDER_BENCHMARK
#include <sys/timers.h>
#endif

#ifndef TRUE3D_BENCHMARK_COUNTERS
#define TRUE3D_BENCHMARK_COUNTERS 0
#endif
#ifndef T3D3_PORTAL_PUSH_TEST
#define T3D3_PORTAL_PUSH_TEST 0
#endif
#ifndef T3D3_PLAYER_FLING_TEST
#define T3D3_PLAYER_FLING_TEST 0
#endif

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)

#define RENDER_WIDTH T3D3_RENDER_WIDTH
#define RENDER_HEIGHT T3D3_RENDER_HEIGHT
#define RENDER_SCALE T3D3_RENDER_SCALE
#define LOW_RENDER_WIDTH (RENDER_WIDTH / 2)
#define LOW_RENDER_HEIGHT (RENDER_HEIGHT / 2)
#define LOW_RENDER_SCALE (RENDER_SCALE * 2)
#define VIEW_CENTER_X (RENDER_WIDTH / 2)
#define VIEW_CENTER_Y (RENDER_HEIGHT / 2)
#define PROJECTION_FOCAL 42
#define NEAR_PLANE 32
#define ROOM_CULL_HALF_WIDTH 40
#define ROOM_CULL_HALF_HEIGHT 32
#define PROJECTED_LIMIT 1048576L
#define PROJECTION_TABLE_SHIFT 2
#ifndef T3D3_NEAR_PROJECTION_DEPTH_COUNT
#define T3D3_NEAR_PROJECTION_DEPTH_COUNT 8192u
#endif
#ifndef T3D3_FAR_PROJECTION_TABLE_SIZE
#define T3D3_FAR_PROJECTION_TABLE_SIZE 2048u
#endif
#ifndef T3D3_EDGE_RECIPROCAL_TABLE_SIZE
#define T3D3_EDGE_RECIPROCAL_TABLE_SIZE 2048u
#endif
#define NEAR_PROJECTION_DEPTH_COUNT T3D3_NEAR_PROJECTION_DEPTH_COUNT
#define NEAR_PROJECTION_TABLE_SIZE \
    (NEAR_PROJECTION_DEPTH_COUNT >> PROJECTION_TABLE_SHIFT)
#define FAR_PROJECTION_TABLE_SHIFT 5
#define PROJECTION_SCALE_SHIFT 6
#define EDGE_RECIPROCAL_SHIFT 4
#define EDGE_RECIPROCAL_SIZE T3D3_EDGE_RECIPROCAL_TABLE_SIZE
#define EDGE_STEP_PRECISION_SHIFT 12
#define NEAR_INTERSECTION_SHIFT 14

#define MAX_WORLD_VERTICES (TRUE3D_MAX_ROOMS * 8u)
#define MAX_WORLD_FACES (TRUE3D_MAX_ROOMS * ROOM_FACE_COUNT)
#define PORTAL_COUNT 2
#define ROOM_FACE_COUNT 6
#define MAX_POLYGON_VERTICES 8
#define MAX_DRAW_POLYGONS 8
#define PORTAL_RECURSION_LIMIT 1
#define RENDER_LAYER_COUNT (PORTAL_RECURSION_LIMIT + 1)
#define NO_PORTAL 255u
#define SCALE_PORTAL_AREA(value) \
    ((uint16_t)(((uint32_t)(value) * RENDER_WIDTH * RENDER_HEIGHT) / \
        (64u * 48u)))
#define SCALE_PORTAL_WIDTH(value) \
    ((uint8_t)(((uint16_t)(value) * RENDER_WIDTH) / 64u))
#define SCALE_PORTAL_HEIGHT(value) \
    ((uint8_t)(((uint16_t)(value) * RENDER_HEIGHT) / 48u))
#define PORTAL_LOD_QUARTER_ENTER_AREA SCALE_PORTAL_AREA(160u)
#define PORTAL_LOD_QUARTER_LEAVE_AREA SCALE_PORTAL_AREA(256u)
#define PORTAL_LOD_HALF_ENTER_AREA SCALE_PORTAL_AREA(960u)
#define PORTAL_LOD_FULL_ENTER_AREA SCALE_PORTAL_AREA(1280u)
#define PORTAL_LOD_HALF_ENTER_WIDTH SCALE_PORTAL_WIDTH(40u)
#define PORTAL_LOD_HALF_ENTER_HEIGHT SCALE_PORTAL_HEIGHT(30u)
#define PORTAL_LOD_FULL_ENTER_WIDTH SCALE_PORTAL_WIDTH(48u)
#define PORTAL_LOD_FULL_ENTER_HEIGHT SCALE_PORTAL_HEIGHT(36u)
#define PORTAL_LOD_STRIDE (RENDER_WIDTH / 2)
#define PORTAL_LOD_HEIGHT (RENDER_HEIGHT / 2)
#define SHADED_PALETTE_FIRST 16u
#define SHADE_LEVEL_COUNT 4u
#define WALL_SHADE_NEAR_DEPTH (8 * FIXED_ONE)
#define WALL_SHADE_MIDDLE_DEPTH (16 * FIXED_ONE)
#define WALL_SHADE_FAR_DEPTH (24 * FIXED_ONE)
#define PANEL_SEAM_INTERVAL (4 * FIXED_ONE)
#define PANEL_DEPTH_SEAM_COUNT 2u
#define PANEL_DEPTH_SEAM_CANDIDATES 4u
#define PANEL_DEPTH_SEAM_MIN_DELTA (2 * FIXED_ONE)

#define MOVE_SPEED 640
#define TURN_UNITS_PER_SECOND 80u
#define PITCH_UNITS_PER_SECOND 72u
#define PITCH_LIMIT 64
#define GRAVITY 2560
#define JUMP_SPEED 1792
#define PLAYER_RADIUS 64
#define PLAYER_EYE_HEIGHT 384
#define CEILING_MARGIN 64
#define PORTAL_APERTURE_MARGIN PLAYER_RADIUS
#define PORTAL_HALF_WIDTH 384
#define PORTAL_HALF_HEIGHT 448

#define BODY_MIN_HALF_EXTENT 64
#define BODY_MAX_HALF_EXTENT 256
#define BODY_DEFAULT_HALF_EXTENT 128
#define BODY_HOLD_DISTANCE 512
#define BODY_PICKUP_DISTANCE 896
#define BODY_THROW_SPEED 2560
#define BODY_FLOOR_FRICTION 224
#define BODY_RESTITUTION 96
#define BODY_SLEEP_SPEED 12
#define BODY_SETTLE_SPEED 192
#define BODY_SLEEP_TICKS 30u
#define BODY_PORTAL_COOLDOWN 3u
#define BODY_PORTAL_FIT_TOLERANCE 8
#define PLAYER_BODY_PUSH_SCALE 192
#define PLAYER_BODY_VERTICAL_SLOP 16
#define BODY_FLAT_LOD_DEPTH (8 * FIXED_ONE)
#define BODY_DENSE_PORTAL_FLAT_LOD_DEPTH (3 * FIXED_ONE)
#define NO_BODY 255u
#define BODY_STORAGE_SLOTS 8u

enum PaletteIndex {
    COLOR_BLACK = 0,
    COLOR_VOID = 1,
    COLOR_FLOOR_A = 2,
    COLOR_CEILING_A = 3,
    COLOR_WALL_GREEN = 4,
    COLOR_WALL_GREEN_DARK = 5,
    COLOR_FLOOR_B = 6,
    COLOR_CEILING_B = 7,
    COLOR_WALL_RED = 8,
    COLOR_WALL_RED_DARK = 9,
    COLOR_PORTAL_BLUE = 10,
    COLOR_PORTAL_ORANGE = 11,
    COLOR_HUD = 12
};

static const uint8_t base_palette_rgb[COLOR_HUD + 1u][3] = {
    {0, 0, 0},
    {12, 14, 25},
    {54, 57, 62},
    {32, 35, 48},
    {38, 205, 75},
    {24, 118, 52},
    {65, 57, 54},
    {48, 32, 35},
    {215, 52, 52},
    {125, 30, 34},
    {45, 105, 245},
    {240, 145, 28},
    {240, 240, 240}
};

static const uint8_t shade_numerator[SHADE_LEVEL_COUNT] = {9, 11, 14, 16};
static const uint8_t face_light_level[ROOM_FACE_COUNT] = {3, 2, 3, 2, 2, 1};

typedef struct __attribute__((packed)) {
    int16_t x;
    int16_t y;
    int16_t z;
} WorldVertex;

typedef struct __attribute__((packed)) {
    uint8_t vertex[4];
    uint8_t color;
    uint8_t portal;
} WorldFace;

typedef struct __attribute__((packed)) {
    uint8_t first_face;
    int16_t minimum_x;
    int16_t maximum_x;
    int16_t minimum_y;
    int16_t maximum_y;
    int16_t minimum_z;
    int16_t maximum_z;
} Room;

typedef struct {
    Vec3 center;
    Vec3 right;
    Vec3 up;
    Vec3 normal;
    fixed_t half_width;
    fixed_t half_height;
    uint8_t room;
    uint8_t host_face;
    uint8_t linked;
    uint8_t active;
} Portal;

typedef struct {
    Vec3 position;
    Vec3 right;
    Vec3 up;
    Vec3 forward;
    uint8_t room;
} Camera;

typedef struct {
    fixed_t x;
    fixed_t y;
    fixed_t depth;
} CameraPoint;

void transform_point_exact(
    const Camera *camera,
    const Vec3 *point,
    CameraPoint *result
);
void scale_camera_room_edges_exact(
    const Camera *camera,
    fixed_t extent_x,
    fixed_t extent_y,
    fixed_t extent_z,
    CameraPoint *result
);

typedef struct {
    int24_t x;
    int24_t y;
} ScreenPoint;

void project_camera_xy_exact(
    const CameraPoint *point,
    uint24_t scale,
    ScreenPoint *result,
    uint8_t render_shift
);
void project_camera_xy_pair_exact(
    const CameraPoint *first,
    uint24_t scale,
    ScreenPoint *first_result,
    uint8_t render_shift,
    const CameraPoint *second,
    ScreenPoint *second_result
);
void project_box_vertices_80(
    uint8_t mask,
    const CameraPoint *camera_points,
    ScreenPoint *screen_points,
    uint8_t *projectable,
    const uint16_t *near_scale,
    const uint16_t *far_scale
);
typedef struct {
    ScreenPoint point[MAX_POLYGON_VERTICES];
    uint8_t span_left[RENDER_HEIGHT];
    uint8_t span_right[RENDER_HEIGHT];
    uint8_t count;
    uint8_t color;
    uint8_t portal;
    uint8_t face;
    uint8_t face_offset;
    uint8_t first_row;
    uint8_t last_row;
    int16_t sample_first_row;
    int16_t sample_last_row;
    uint8_t top_vertex;
} DrawPolygon;

typedef struct {
    DrawPolygon polygon[MAX_DRAW_POLYGONS];
    uint8_t row_left[RENDER_HEIGHT];
    uint8_t row_right[RENDER_HEIGHT];
    uint8_t count;
    uint8_t solid_count;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t bound_left;
    uint8_t bound_right;
    uint8_t lod_shift;
    uint16_t pixel_area;
    int16_t horizon_row;
    uint8_t horizon_valid;
} RenderLayer;

/* A reduced portal destination can be shared by both gameplay apertures when
 * their transformed cameras are exactly identical.  Keep the two original
 * aperture clips outside RenderLayer so the shared scratch render can use a
 * wider union clip without losing the exact masks used for composition. */
typedef struct {
    uint8_t row_left[RENDER_HEIGHT];
    uint8_t row_right[RENDER_HEIGHT];
    uint8_t first_row;
    uint8_t last_row;
    uint8_t bound_left;
    uint8_t bound_right;
    uint8_t lod_shift;
    uint16_t pixel_area;
} PortalClipSnapshot;

typedef struct {
    uint8_t width;
    uint8_t height;
    uint8_t data[RENDER_WIDTH * RENDER_HEIGHT];
} LowFrame;

_Static_assert(RENDER_WIDTH * RENDER_SCALE == 320, "Presenter width mismatch");
_Static_assert(RENDER_HEIGHT * RENDER_SCALE == 240, "Presenter height mismatch");
_Static_assert(
    LOW_RENDER_WIDTH * LOW_RENDER_SCALE == 320,
    "Low presenter width mismatch"
);
_Static_assert(
    LOW_RENDER_HEIGHT * LOW_RENDER_SCALE == 240,
    "Low presenter height mismatch"
);
_Static_assert(PORTAL_LOD_STRIDE * 2 == RENDER_WIDTH, "Portal LOD width mismatch");
_Static_assert(PORTAL_LOD_HEIGHT * 2 == RENDER_HEIGHT, "Portal LOD height mismatch");
_Static_assert(
    SHADED_PALETTE_FIRST + (COLOR_HUD + 1u) * SHADE_LEVEL_COUNT <= 256u,
    "Shaded palette exceeds eight-bit indices"
);

static WorldVertex world_vertices[MAX_WORLD_VERTICES];
static WorldFace world_faces[MAX_WORLD_FACES];
static Room rooms[TRUE3D_MAX_ROOMS];
static uint8_t room_count;
/* Preserve the recovery/debug memory layout while the public API and every
 * runtime loop enforce the four-body gameplay limit. */
static T3D3Body bodies[BODY_STORAGE_SLOTS];
static uint8_t body_sleep_ticks[BODY_STORAGE_SLOTS];
static uint8_t active_body_count;
static uint8_t held_body = NO_BODY;
static uint8_t static_scene_only;

#if T3D3_STATIC_BOX_LIMIT > 0
typedef struct {
    T3D3Body render_body;
    Vec3 half_extents;
} StaticBox;

static StaticBox static_boxes[T3D3_STATIC_BOX_LIMIT];
static uint8_t static_box_count;
/* Static scenery is rendered only from the root camera, so this sorting and
 * projection workspace need not live on the tiny calculator call stack. */
static uint8_t static_box_order[T3D3_STATIC_BOX_LIMIT];
static fixed_t static_box_depth[T3D3_STATIC_BOX_LIMIT];
static CameraPoint static_box_center[T3D3_STATIC_BOX_LIMIT];
static CameraPoint static_box_world_axis[T3D3_STATIC_BOX_LIMIT][3];
static CameraPoint static_box_projected_extent[T3D3_STATIC_BOX_LIMIT];
#endif

static const Vec3 face_normals[ROOM_FACE_COUNT] = {
    {0, 0, 256},
    {0, 0, -256},
    {0, 256, 0},
    {0, -256, 0},
    {256, 0, 0},
    {-256, 0, 0}
};

static const Vec3 face_right_vectors[ROOM_FACE_COUNT] = {
    {256, 0, 0},
    {256, 0, 0},
    {-256, 0, 0},
    {256, 0, 0},
    {0, 256, 0},
    {0, -256, 0}
};

static const Vec3 face_up_vectors[ROOM_FACE_COUNT] = {
    {0, 256, 0},
    {0, -256, 0},
    {0, 0, 256},
    {0, 0, 256},
    {0, 0, 256},
    {0, 0, 256}
};

static const uint8_t box_face_vertices[ROOM_FACE_COUNT][4] = {
    {0, 3, 2, 1},
    {4, 5, 6, 7},
    {0, 1, 5, 4},
    {3, 7, 6, 2},
    {0, 4, 7, 3},
    {1, 2, 6, 5}
};
static const uint8_t vertex_mask_bit[8] = {
    1u, 2u, 4u, 8u, 16u, 32u, 64u, 128u
};
static const uint8_t box_face_vertex_mask[ROOM_FACE_COUNT] = {
    0x0Fu, 0xF0u, 0x33u, 0xCCu, 0x99u, 0x66u
};
/* Quarter-wave Q8 sine table. Angles use 256 units per turn. */
static const int16_t quarter_sine[65] = {
    0, 6, 13, 19, 25, 31, 38, 44, 50, 56, 62, 68, 74, 80, 86, 92,
    98, 104, 109, 115, 121, 126, 132, 137, 142, 147, 152, 157, 162,
    167, 172, 177, 181, 185, 190, 194, 198, 202, 206, 209, 213, 216,
    220, 223, 226, 229, 231, 234, 237, 239, 241, 243, 245, 247, 248,
    250, 251, 252, 253, 254, 255, 255, 256, 256, 256
};

/* Portal 0 is vertical. Portal 1 lies on a ceiling. right x up = inward normal. */
static Portal portals[PORTAL_COUNT] = {
    {
        {0 * 256, 10 * 256, 640},
        {256, 0, 0},
        {0, 0, 256},
        {0, -256, 0},
        384,
        448,
        0,
        3,
        1,
        1
    },
    {
        {12 * 256, 4 * 256, 5 * 256},
        {256, 0, 0},
        {0, -256, 0},
        {0, 0, -256},
        384,
        448,
        1,
        7,
        0,
        1
    }
};

static CameraPoint camera_vertices[8];
static ScreenPoint screen_vertices[8];
static uint8_t vertex_projectable[8];
static CameraPoint clip_output[MAX_POLYGON_VERTICES];
static RenderLayer render_layers[RENDER_LAYER_COUNT];
static PortalClipSnapshot shared_portal_clip[PORTAL_COUNT];
uint16_t low_row_offsets[RENDER_HEIGHT];
static uint16_t projection_scale_table[NEAR_PROJECTION_DEPTH_COUNT];
static uint16_t far_projection_scale_table[T3D3_FAR_PROJECTION_TABLE_SIZE];
static uint16_t edge_reciprocal_table[EDGE_RECIPROCAL_SIZE];
uint8_t portal_lod_frame[PORTAL_LOD_STRIDE * PORTAL_LOD_HEIGHT];
static uint8_t portal_lod_state[PORTAL_COUNT];
#if RENDER_WIDTH < 160
static uint8_t present_frame_cache[2][RENDER_WIDTH * RENDER_HEIGHT];
static uint8_t present_frame_cache_valid[2];
#define PRESENT_CACHE_STORAGE_SIZE \
    (sizeof(present_frame_cache) + sizeof(present_frame_cache_valid))
#else
#define PRESENT_CACHE_STORAGE_SIZE 0u
#endif
uint8_t horizon_light_subtract[RENDER_HEIGHT];
uint8_t active_render_width;
static uint8_t active_render_height;
static uint8_t active_render_shift;
static uint8_t active_horizon_near_limit;
static uint8_t active_horizon_far_limit;
LowFrame low_frame;

#if TRUE3D_RENDER_BENCHMARK
static True3DRenderBenchmark render_benchmark;
static uint32_t render_benchmark_last;
static uint8_t render_benchmark_category;
static uint8_t render_benchmark_active;

static inline __attribute__((always_inline)) uint24_t
render_benchmark_timer_direct(void) {
    return *(volatile uint24_t *)0xF20020;
}

static inline __attribute__((always_inline)) uint32_t
render_benchmark_timer(void) {
    uint24_t first = render_benchmark_timer_direct();
    uint24_t second = render_benchmark_timer_direct();

    if ((uint24_t)(second - first) <= 1u) return second;
    {
        uint24_t third = render_benchmark_timer_direct();

        if ((uint24_t)(third - second) <= 1u) return third;
    }
    return first;
}

static inline __attribute__((always_inline)) void
render_benchmark_charge(uint32_t now) {
    uint32_t elapsed = now - render_benchmark_last;

    render_benchmark.raw_ticks[render_benchmark_category] += elapsed;
    render_benchmark.total_ticks += elapsed;
    render_benchmark_last = now;
}

static inline __attribute__((always_inline)) void
render_benchmark_switch(True3DBenchmarkCategory category) {
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

void engine_render_benchmark_reset(void) {
    render_benchmark_active = 0;
    render_benchmark_last = 0;
    render_benchmark_category = TRUE3D_BENCH_ADMIN;
    memset(&render_benchmark, 0, sizeof(render_benchmark));
}

void engine_render_benchmark_begin(void) {
    if (render_benchmark_active) return;
    render_benchmark_category = TRUE3D_BENCH_ADMIN;
    render_benchmark_last = render_benchmark_timer();
    render_benchmark_active = 1;
}

void engine_render_benchmark_end(void) {
    if (!render_benchmark_active) return;
    render_benchmark_charge(render_benchmark_timer());
    render_benchmark_active = 0;
}

uint32_t engine_render_benchmark_calibrate(void) {
    True3DRenderBenchmark saved_benchmark;
    uint32_t saved_last;
    uint32_t best = 0xFFFFFFFFUL;
    uint8_t saved_category;
    uint8_t saved_active;
    uint8_t batch;

    if (render_benchmark_active) return 0;
    saved_benchmark = render_benchmark;
    saved_last = render_benchmark_last;
    saved_category = render_benchmark_category;
    saved_active = render_benchmark_active;
    for (batch = 0; batch < 8; ++batch) {
        uint8_t transition;
        uint32_t elapsed;

        engine_render_benchmark_reset();
        engine_render_benchmark_begin();
        for (transition = 0; transition < 64; ++transition) {
            render_benchmark_switch((transition & 1u) != 0 ?
                TRUE3D_BENCH_SETUP : TRUE3D_BENCH_ADMIN);
        }
        engine_render_benchmark_end();
        elapsed = render_benchmark.total_ticks;
        if (elapsed < best) best = elapsed;
    }
    render_benchmark = saved_benchmark;
    render_benchmark_last = saved_last;
    render_benchmark_category = saved_category;
    render_benchmark_active = saved_active;
    return (best << 8) / 65u;
}

const True3DRenderBenchmark *engine_render_benchmark_read(void) {
    return &render_benchmark;
}

uint8_t engine_render_benchmark_lod_state(void) {
    return (uint8_t)(
        (portal_lod_state[0] & 3u) |
        ((portal_lod_state[1] & 3u) << 2)
    );
}

uint32_t engine_render_benchmark_logical_hash(void) {
    uint32_t hash = 2166136261UL;
    uint16_t size = (uint16_t)active_render_width * active_render_height;
    uint16_t index;

    hash ^= active_render_width;
    hash *= 16777619UL;
    hash ^= active_render_height;
    hash *= 16777619UL;
    for (index = 0; index < size; ++index) {
        hash ^= low_frame.data[index];
        hash *= 16777619UL;
    }
    return hash;
}

#define RENDER_BENCHMARK_SWITCH(category) do { \
    if (render_benchmark_active) render_benchmark_switch(category); \
} while (0)
#if TRUE3D_BENCHMARK_COUNTERS
#define RENDER_BENCHMARK_COUNT(field, amount) do { \
    if (render_benchmark_active) { \
        render_benchmark.field = (uint16_t)( \
            render_benchmark.field + (uint16_t)(amount) \
        ); \
    } \
} while (0)
#else
#define RENDER_BENCHMARK_COUNT(field, amount) ((void)0)
#endif
#else
#define RENDER_BENCHMARK_SWITCH(category) ((void)0)
#define RENDER_BENCHMARK_COUNT(field, amount) ((void)0)
#endif

void present_low_frame_fast(void);
void present_low_frame_32_fast(void);
void present_low_frame_dirty_fast(uint8_t *cache);
void present_low_frame_dirty_80_fast(uint8_t *cache);
void present_low_frame_40_fast(void);
void present_low_frame_80_fast(void);
void present_low_frame_160_fast(void);

_Static_assert(
        sizeof(camera_vertices) + sizeof(screen_vertices) +
        sizeof(vertex_projectable) + sizeof(clip_output) +
        sizeof(render_layers) + sizeof(shared_portal_clip) +
        sizeof(low_frame) + sizeof(portal_lod_frame) + sizeof(low_row_offsets) +
        sizeof(portal_lod_state) + PRESENT_CACHE_STORAGE_SIZE +
        sizeof(horizon_light_subtract) +
        sizeof(active_render_width) + sizeof(active_render_height) +
        sizeof(active_render_shift) + sizeof(active_horizon_near_limit) +
        sizeof(active_horizon_far_limit) +
        sizeof(projection_scale_table) + sizeof(far_projection_scale_table) +
        sizeof(edge_reciprocal_table) +
        sizeof(world_vertices) + sizeof(world_faces) + sizeof(rooms) +
        sizeof(bodies) + sizeof(body_sleep_ticks) <
            (RENDER_WIDTH == 64 ? 40u * 1024u : 96u * 1024u),
    "True-3D render scratch exceeded the selected resolution budget"
);

static fixed_t fixed_mul(fixed_t left, fixed_t right) {
    return (fixed_t)(((int32_t)left * right) >> FIXED_SHIFT);
}

static fixed_t fixed_absolute(fixed_t value) {
    return value < 0 ? -value : value;
}

static fixed_t angle_sine(uint8_t angle) {
    uint8_t quadrant = angle >> 6;
    uint8_t offset = angle & 63u;

    if (quadrant == 0) return quarter_sine[offset];
    if (quadrant == 1) return quarter_sine[64u - offset];
    if (quadrant == 2) return -quarter_sine[offset];
    return -quarter_sine[64u - offset];
}

static void rebuild_camera_basis(EngineState *state) {
    uint8_t pitch_magnitude = (uint8_t)(state->pitch < 0 ? -state->pitch : state->pitch);
    fixed_t sine_yaw = angle_sine(state->yaw);
    fixed_t cosine_yaw = angle_sine((uint8_t)(state->yaw + 64u));
    fixed_t sine_pitch = quarter_sine[pitch_magnitude];
    fixed_t cosine_pitch = quarter_sine[64u - pitch_magnitude];

    if (state->pitch < 0) sine_pitch = -sine_pitch;
    state->right.x = -sine_yaw;
    state->right.y = cosine_yaw;
    state->right.z = 0;
    state->forward.x = fixed_mul(cosine_pitch, cosine_yaw);
    state->forward.y = fixed_mul(cosine_pitch, sine_yaw);
    state->forward.z = sine_pitch;
    state->up.x = -fixed_mul(sine_pitch, cosine_yaw);
    state->up.y = -fixed_mul(sine_pitch, sine_yaw);
    state->up.z = cosine_pitch;
}

static Vec3 vec_add(Vec3 left, Vec3 right) {
    Vec3 result = {left.x + right.x, left.y + right.y, left.z + right.z};
    return result;
}

static Vec3 vec_subtract(Vec3 left, Vec3 right) {
    Vec3 result = {left.x - right.x, left.y - right.y, left.z - right.z};
    return result;
}

static Vec3 vec_scale(Vec3 vector, fixed_t scale) {
    Vec3 result = {
        fixed_mul(vector.x, scale),
        fixed_mul(vector.y, scale),
        fixed_mul(vector.z, scale)
    };
    return result;
}

static fixed_t vec_dot(Vec3 left, Vec3 right) {
    return fixed_mul(left.x, right.x) +
        fixed_mul(left.y, right.y) +
        fixed_mul(left.z, right.z);
}

/* Portal face bases are signed world axes, so these avoid fixed-point matrix multiplies. */
static fixed_t signed_axis_component(Vec3 vector, Vec3 axis) {
    if (axis.x != 0) return axis.x > 0 ? vector.x : -vector.x;
    if (axis.y != 0) return axis.y > 0 ? vector.y : -vector.y;
    return axis.z > 0 ? vector.z : -vector.z;
}

static void add_signed_axis(Vec3 *vector, Vec3 axis, fixed_t amount) {
    if (axis.x != 0) {
        vector->x += axis.x > 0 ? amount : -amount;
    } else if (axis.y != 0) {
        vector->y += axis.y > 0 ? amount : -amount;
    } else {
        vector->z += axis.z > 0 ? amount : -amount;
    }
}

static Vec3 world_vertex(uint8_t index) {
    Vec3 result = {
        world_vertices[index].x,
        world_vertices[index].y,
        world_vertices[index].z
    };
    return result;
}

static CameraPoint transform_point(const Camera *camera, Vec3 point) {
    CameraPoint result;

    transform_point_exact(camera, &point, &result);
    return result;
}

static __attribute__((unused)) int24_t clamp_projected(int32_t value) {
    if (value < -PROJECTED_LIMIT) return -PROJECTED_LIMIT;
    if (value > PROJECTED_LIMIT) return PROJECTED_LIMIT;
    return (int24_t)value;
}

static __attribute__((noinline)) int24_t half_projected(int24_t value) {
    return value >> 1;
}

static uint16_t projection_scale_for_depth(fixed_t depth) {
    uint24_t index;

    if (depth >= (fixed_t)NEAR_PROJECTION_DEPTH_COUNT) {
        index = (uint24_t)depth >> FAR_PROJECTION_TABLE_SHIFT;
        if (index >= T3D3_FAR_PROJECTION_TABLE_SIZE) {
            index = T3D3_FAR_PROJECTION_TABLE_SIZE - 1u;
        }
        return far_projection_scale_table[index];
    }
    return projection_scale_table[(uint24_t)depth];
}

static __attribute__((always_inline)) inline void scale_projected_resolution(
    ScreenPoint *point
) {
#if RENDER_WIDTH == 80
    point->x = (int24_t)(((int32_t)point->x * 5) >> 2);
    point->y = (int24_t)(((int32_t)point->y * 5) >> 2);
#elif RENDER_WIDTH == 160
    point->x = (int24_t)(((int32_t)point->x * 5) >> 1);
    point->y = (int24_t)(((int32_t)point->y * 5) >> 1);
#else
    (void)point;
#endif
}

static ScreenPoint project_camera_point(const CameraPoint *point) {
    uint16_t scale = projection_scale_for_depth(point->depth);
    ScreenPoint result;

    RENDER_BENCHMARK_COUNT(projected_points, 1u);
    project_camera_xy_exact(point, scale, &result, active_render_shift);
    scale_projected_resolution(&result);
    return result;
}

/* A level camera (including one transformed through an axis-aligned portal)
 * leaves one box axis at exactly equal depth. Project those four vertex pairs
 * with one scale lookup and one assembly ABI frame per pair. The mask lets the
 * body path omit vertices that are not referenced by any camera-facing face. */
static void project_cached_box_vertices(uint8_t mask) {
#if RENDER_WIDTH == 80 && !TRUE3D_BENCHMARK_COUNTERS
    if (active_render_shift == 0u) {
        project_box_vertices_80(
            mask,
            camera_vertices,
            screen_vertices,
            vertex_projectable,
            projection_scale_table,
            far_projection_scale_table
        );
        return;
    }
#endif
    static const uint8_t axis_pairs[3][8] = {
        {0, 1, 3, 2, 4, 5, 7, 6},
        {0, 3, 1, 2, 4, 7, 5, 6},
        {0, 4, 1, 5, 3, 7, 2, 6}
    };
    uint8_t pair_axis = NO_PORTAL;
    uint8_t index;

    if (mask == 0xFFu) {
        for (index = 0; index < 8u; ++index) {
            vertex_projectable[index] = (uint8_t)(
                camera_vertices[index].depth >= NEAR_PLANE
            );
        }
    } else {
        for (index = 0; index < 8u; ++index) {
            vertex_projectable[index] = (uint8_t)(
                (mask & vertex_mask_bit[index]) != 0 &&
                camera_vertices[index].depth >= NEAR_PLANE
            );
        }
    }
    if (camera_vertices[0].depth == camera_vertices[1].depth) {
        pair_axis = 0u;
    } else if (camera_vertices[0].depth == camera_vertices[3].depth) {
        pair_axis = 1u;
    } else if (camera_vertices[0].depth == camera_vertices[4].depth) {
        pair_axis = 2u;
    }
    if (pair_axis == NO_PORTAL) {
        for (index = 0; index < 8u; ++index) {
            if (vertex_projectable[index]) {
                screen_vertices[index] = project_camera_point(
                    &camera_vertices[index]
                );
            }
        }
        return;
    }
    for (index = 0; index < 8u; index += 2u) {
        uint8_t first = axis_pairs[pair_axis][index];
        uint8_t second = axis_pairs[pair_axis][index + 1u];

        if (vertex_projectable[first] && vertex_projectable[second]) {
            uint16_t scale = projection_scale_for_depth(
                camera_vertices[first].depth
            );

            RENDER_BENCHMARK_COUNT(projected_points, 2u);
            project_camera_xy_pair_exact(
                &camera_vertices[first],
                scale,
                &screen_vertices[first],
                active_render_shift,
                &camera_vertices[second],
                &screen_vertices[second]
            );
            scale_projected_resolution(&screen_vertices[first]);
            scale_projected_resolution(&screen_vertices[second]);
        } else if (vertex_projectable[first]) {
            screen_vertices[first] = project_camera_point(
                &camera_vertices[first]
            );
        } else if (vertex_projectable[second]) {
            screen_vertices[second] = project_camera_point(
                &camera_vertices[second]
            );
        }
    }
}

static CameraPoint intersect_near_plane(CameraPoint first, CameraPoint second) {
    CameraPoint lower = first;
    CameraPoint upper = second;
    fixed_t depth_delta;
    int32_t fraction;
    CameraPoint result;

    if (lower.depth > upper.depth) {
        CameraPoint swap = lower;
        lower = upper;
        upper = swap;
    }
    depth_delta = (fixed_t)((int32_t)upper.depth - lower.depth);
    fraction = (
        ((int32_t)(NEAR_PLANE - lower.depth) << NEAR_INTERSECTION_SHIFT) +
        depth_delta / 2
    ) / depth_delta;
    result.x = lower.x + (fixed_t)(
        (((int32_t)upper.x - lower.x) * fraction) >> NEAR_INTERSECTION_SHIFT
    );
    result.y = lower.y + (fixed_t)(
        (((int32_t)upper.y - lower.y) * fraction) >> NEAR_INTERSECTION_SHIFT
    );
    result.depth = NEAR_PLANE;
    return result;
}

static uint8_t clip_and_project(
    const CameraPoint *source,
    uint8_t source_count,
    DrawPolygon *polygon
) {
    uint8_t input_count = source_count;
    uint8_t output_count = 0;
    uint8_t index;

    if (source_count < 3 || source_count > MAX_POLYGON_VERTICES) return 0;
    for (index = 0; index < input_count; ++index) {
        const CameraPoint *current = &source[index];
        const CameraPoint *previous = &source[
            index == 0 ? input_count - 1 : index - 1
        ];
        uint8_t current_inside = current->depth >= NEAR_PLANE;
        uint8_t previous_inside = previous->depth >= NEAR_PLANE;

        if (current_inside != previous_inside) {
            CameraPoint intersection = intersect_near_plane(*previous, *current);
            if (output_count < MAX_POLYGON_VERTICES) {
                clip_output[output_count++] = intersection;
            }
        }
        if (current_inside && output_count < MAX_POLYGON_VERTICES) {
            clip_output[output_count++] = *current;
        }
    }
    if (output_count < 3) return 0;

    for (index = 0; index < output_count; ++index) {
        const CameraPoint *point = &clip_output[index];
        polygon->point[index] = project_camera_point(point);
    }
    polygon->count = output_count;
    return 1;
}

/* Room vertices have already been projected once. During near clipping only
 * the newly-created intersections need projection; reuse the cached screen
 * coordinates for every surviving original box vertex. */
static uint8_t clip_cached_face_and_project(
    uint8_t face_offset,
    DrawPolygon *polygon
) {
    uint8_t output_count = 0;
    uint8_t index;

    for (index = 0; index < 4; ++index) {
        uint8_t current_vertex = box_face_vertices[face_offset][index];
        uint8_t previous_vertex = box_face_vertices[face_offset][
            index == 0 ? 3 : index - 1
        ];
        const CameraPoint *current = &camera_vertices[current_vertex];
        const CameraPoint *previous = &camera_vertices[previous_vertex];
        uint8_t current_inside = current->depth >= NEAR_PLANE;
        uint8_t previous_inside = previous->depth >= NEAR_PLANE;

        if (current_inside != previous_inside) {
            CameraPoint intersection = intersect_near_plane(*previous, *current);

            polygon->point[output_count++] = project_camera_point(&intersection);
        }
        if (current_inside) {
            polygon->point[output_count++] = screen_vertices[current_vertex];
        }
    }
    if (output_count < 3) return 0;
    polygon->count = output_count;
    return 1;
}

static uint8_t polygon_intersects_layer(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    int24_t minimum_x = polygon->point[0].x;
    int24_t maximum_x = minimum_x;
    int24_t minimum_y = polygon->point[0].y;
    int24_t maximum_y = minimum_y;
    uint8_t bound_left = layer->bound_left;
    uint8_t bound_right = layer->bound_right;
    uint8_t first_row = layer->first_row;
    uint8_t last_row = layer->last_row;
    uint8_t index;

    /* DrawPolygon records are reused across immediate-mode room, portal, and
     * body faces.  Always seed the scan-conversion start from point zero
     * before looking for a higher vertex; otherwise a face whose point zero
     * is already highest inherits top_vertex from the previously drawn face
     * and the rasterizer walks the wrong two edge chains. */
    polygon->top_vertex = 0;

    for (index = 1; index < polygon->count; ++index) {
        if (polygon->point[index].x < minimum_x) minimum_x = polygon->point[index].x;
        if (polygon->point[index].x > maximum_x) maximum_x = polygon->point[index].x;
        if (polygon->point[index].y < minimum_y) {
            minimum_y = polygon->point[index].y;
            polygon->top_vertex = index;
        }
        if (polygon->point[index].y > maximum_y) maximum_y = polygon->point[index].y;
    }
    polygon->sample_first_row = (int16_t)(
        (minimum_y - FIXED_ONE / 2 + FIXED_ONE - 1) >> FIXED_SHIFT
    );
    polygon->sample_last_row = (int16_t)(
        (maximum_y - 1 - FIXED_ONE / 2) >> FIXED_SHIFT
    );
    if (layer->lod_shift != 0) {
        bound_left = (bound_left >> layer->lod_shift) << layer->lod_shift;
        bound_right = (uint8_t)(
            (((bound_right >> layer->lod_shift) + 1u) << layer->lod_shift) - 1u
        );
        first_row = (first_row >> layer->lod_shift) << layer->lod_shift;
        last_row = (uint8_t)(
            (((last_row >> layer->lod_shift) + 1u) << layer->lod_shift) - 1u
        );
        if (bound_right >= active_render_width) bound_right = active_render_width - 1u;
        if (last_row >= active_render_height) last_row = active_render_height - 1u;
    }
    return (uint8_t)(
        layer->first_row <= layer->last_row &&
        maximum_x >= (int24_t)bound_left * FIXED_ONE &&
        minimum_x < (int24_t)(bound_right + 1u) * FIXED_ONE &&
        maximum_y >= (int24_t)first_row * FIXED_ONE &&
        minimum_y < (int24_t)(last_row + 1u) * FIXED_ONE
    );
}

static CameraPoint camera_point_add(CameraPoint left, CameraPoint right) {
    CameraPoint result = {
        left.x + right.x,
        left.y + right.y,
        left.depth + right.depth
    };
    return result;
}

/* Reject a room only when its complete camera-space AABB is outside one
 * conservative frustum plane.  The normal 80x60 projection has half extents
 * 40x30; the extra vertical guard protects table quantization and raster
 * rounding at the top and bottom edges. */
static uint8_t room_camera_bounds_visible(void) {
    fixed_t maximum_depth = camera_vertices[0].depth;
    fixed_t minimum_x;
    fixed_t maximum_x;
    fixed_t minimum_y;
    fixed_t maximum_y;
    uint8_t index;

    for (index = 1; index < 8u; ++index) {
        if (camera_vertices[index].depth > maximum_depth) {
            maximum_depth = camera_vertices[index].depth;
        }
    }
    /* Looking entirely away from the room is the common fast case. */
    if (maximum_depth < NEAR_PLANE) return 0;

    minimum_x = maximum_x = camera_vertices[0].x;
    minimum_y = maximum_y = camera_vertices[0].y;
    for (index = 1; index < 8u; ++index) {
        if (camera_vertices[index].x < minimum_x) {
            minimum_x = camera_vertices[index].x;
        }
        if (camera_vertices[index].x > maximum_x) {
            maximum_x = camera_vertices[index].x;
        }
        if (camera_vertices[index].y < minimum_y) {
            minimum_y = camera_vertices[index].y;
        }
        if (camera_vertices[index].y > maximum_y) {
            maximum_y = camera_vertices[index].y;
        }
    }
    if ((int32_t)PROJECTION_FOCAL * maximum_x +
            (int32_t)ROOM_CULL_HALF_WIDTH * maximum_depth < 0) {
        return 0;
    }
    if ((int32_t)PROJECTION_FOCAL * minimum_x -
            (int32_t)ROOM_CULL_HALF_WIDTH * maximum_depth >= 0) {
        return 0;
    }
    if ((int32_t)PROJECTION_FOCAL * minimum_y -
            (int32_t)ROOM_CULL_HALF_HEIGHT * maximum_depth > 0) {
        return 0;
    }
    if (-(int32_t)PROJECTION_FOCAL * maximum_y -
            (int32_t)ROOM_CULL_HALF_HEIGHT * maximum_depth >= 0) {
        return 0;
    }
    return 1;
}

/* A convex room viewed from outside exposes only the boundary planes on the
 * camera side.  Avoid projecting and scan-converting the opposite/interior
 * faces during noclip inspection.  Normal gameplay remains the six-face
 * interior renderer. */
static uint8_t room_exterior_face_mask(
    const Camera *camera,
    const Room *room,
    uint8_t allow_room_cull
) {
    uint8_t mask = 0;

    if (!allow_room_cull) return 0x3Fu;
    if (camera->position.z < room->minimum_z) mask |= 1u << 0;
    if (camera->position.z > room->maximum_z) mask |= 1u << 1;
    if (camera->position.y < room->minimum_y) mask |= 1u << 2;
    if (camera->position.y > room->maximum_y) mask |= 1u << 3;
    if (camera->position.x < room->minimum_x) mask |= 1u << 4;
    if (camera->position.x > room->maximum_x) mask |= 1u << 5;
    return mask == 0 ? 0x3Fu : mask;
}

static uint8_t camera_is_outside_room(
    const Camera *camera,
    const Room *room
) {
    return (uint8_t)(
        camera->position.x < room->minimum_x ||
        camera->position.x > room->maximum_x ||
        camera->position.y < room->minimum_y ||
        camera->position.y > room->maximum_y ||
        camera->position.z < room->minimum_z ||
        camera->position.z > room->maximum_z
    );
}

static uint8_t transform_world_vertices(
    const Camera *camera,
    uint8_t allow_room_cull
) {
    const Room *room = &rooms[camera->room];
    Vec3 minimum = {room->minimum_x, room->minimum_y, room->minimum_z};
    fixed_t extent_x = room->maximum_x - room->minimum_x;
    fixed_t extent_y = room->maximum_y - room->minimum_y;
    fixed_t extent_z = room->maximum_z - room->minimum_z;
    CameraPoint base = transform_point(camera, minimum);
    CameraPoint edge[3];
    uint8_t first = 0;

    RENDER_BENCHMARK_COUNT(transformed_vertices, 8u);

    scale_camera_room_edges_exact(
        camera,
        extent_x,
        extent_y,
        extent_z,
        edge
    );

    camera_vertices[first] = base;
    camera_vertices[first + 1] = camera_point_add(base, edge[0]);
    camera_vertices[first + 3] = camera_point_add(base, edge[1]);
    camera_vertices[first + 2] = camera_point_add(camera_vertices[first + 1], edge[1]);
    camera_vertices[first + 4] = camera_point_add(base, edge[2]);
    camera_vertices[first + 5] = camera_point_add(camera_vertices[first + 1], edge[2]);
    camera_vertices[first + 7] = camera_point_add(camera_vertices[first + 3], edge[2]);
    camera_vertices[first + 6] = camera_point_add(camera_vertices[first + 2], edge[2]);
    if (allow_room_cull &&
        (camera->position.x < room->minimum_x ||
         camera->position.x > room->maximum_x ||
         camera->position.y < room->minimum_y ||
         camera->position.y > room->maximum_y ||
         camera->position.z < room->minimum_z ||
         camera->position.z > room->maximum_z) &&
        !room_camera_bounds_visible()) {
        return 0;
    }
    project_cached_box_vertices(0xFFu);
    return 1;
}

static uint8_t rasterize_polygon(
    DrawPolygon *polygon,
    const RenderLayer *layer
);

static uint8_t prepare_face_polygon(
    const RenderLayer *layer,
    uint8_t face_index,
    uint8_t face_offset,
    DrawPolygon *polygon
) {
    const WorldFace *face = &world_faces[face_index];
    uint8_t index;
    uint8_t inside_count = 0;

    for (index = 0; index < 4; ++index) {
        uint8_t vertex = box_face_vertices[face_offset][index];
        if (vertex_projectable[vertex]) {
            polygon->point[index] = screen_vertices[vertex];
            ++inside_count;
        }
    }
    if (inside_count == 0) return 0;
    if (inside_count == 4) {
        polygon->count = 4;
    } else if (!clip_cached_face_and_project(face_offset, polygon)) {
        return 0;
    }
    polygon->top_vertex = 0;
    if (!polygon_intersects_layer(polygon, layer)) return 0;
    polygon->color = face->color;
    if (face_offset > 1u) {
        int32_t depth_sum = 0;
        uint8_t distance_light;
        uint8_t orientation_light = face_light_level[face_offset];

        for (index = 0; index < 4u; ++index) {
            depth_sum += camera_vertices[
                box_face_vertices[face_offset][index]
            ].depth;
        }
        depth_sum >>= 2;
        distance_light = depth_sum <= WALL_SHADE_NEAR_DEPTH ? 3u :
            (depth_sum <= WALL_SHADE_MIDDLE_DEPTH ? 2u :
                (depth_sum <= WALL_SHADE_FAR_DEPTH ? 1u : 0u));
        if (distance_light < orientation_light) {
            polygon->color -= orientation_light - distance_light;
        }
    }
    polygon->portal = NO_PORTAL;
    polygon->face = face_index;
    polygon->face_offset = face_offset;
    return 1;
}

static __attribute__((unused)) uint8_t append_face_polygon(
    RenderLayer *layer,
    uint8_t face_index,
    uint8_t face_offset
) {
    DrawPolygon *polygon;

    if (layer->count >= MAX_DRAW_POLYGONS) return 0;
    polygon = &layer->polygon[layer->count];
    if (!prepare_face_polygon(layer, face_index, face_offset, polygon)) return 0;
    if (!rasterize_polygon(polygon, layer)) return 0;
    ++layer->count;
    return 1;
}

static CameraPoint camera_axis_scaled(
    const Camera *camera,
    Vec3 axis,
    fixed_t scale
) {
    CameraPoint result = {
        fixed_mul(signed_axis_component(camera->right, axis), scale),
        fixed_mul(signed_axis_component(camera->up, axis), scale),
        fixed_mul(signed_axis_component(camera->forward, axis), scale)
    };
    return result;
}

static void append_portal_polygon(
    RenderLayer *layer,
    const Camera *camera,
    uint8_t portal_index
) {
    const Portal *portal = &portals[portal_index];
    CameraPoint point[4];
    CameraPoint center;
    CameraPoint horizontal;
    CameraPoint vertical;
    DrawPolygon *polygon;

    if (layer->count >= MAX_DRAW_POLYGONS) return;
    center = transform_point(camera, portal->center);
    horizontal = camera_axis_scaled(camera, portal->right, portal->half_width);
    vertical = camera_axis_scaled(camera, portal->up, portal->half_height);
    point[0] = (CameraPoint){
        center.x - horizontal.x - vertical.x,
        center.y - horizontal.y - vertical.y,
        center.depth - horizontal.depth - vertical.depth
    };
    point[1] = (CameraPoint){
        center.x + horizontal.x - vertical.x,
        center.y + horizontal.y - vertical.y,
        center.depth + horizontal.depth - vertical.depth
    };
    point[2] = (CameraPoint){
        center.x + horizontal.x + vertical.x,
        center.y + horizontal.y + vertical.y,
        center.depth + horizontal.depth + vertical.depth
    };
    point[3] = (CameraPoint){
        center.x - horizontal.x + vertical.x,
        center.y - horizontal.y + vertical.y,
        center.depth - horizontal.depth + vertical.depth
    };
    polygon = &layer->polygon[layer->count];
    if (!clip_and_project(point, 4, polygon)) return;
    polygon->top_vertex = 0;
    if (!polygon_intersects_layer(polygon, layer)) return;
    polygon->color = portal_index == 0 ? COLOR_PORTAL_ORANGE : COLOR_PORTAL_BLUE;
    polygon->portal = portal_index;
    polygon->face = portal->host_face;
    polygon->face_offset = NO_PORTAL;
    if (!rasterize_polygon(polygon, layer)) return;
    ++layer->count;
}

static uint8_t prepare_room_geometry(
    RenderLayer *layer,
    const Camera *camera,
    uint8_t allow_room_cull
) {
    uint8_t first_horizon_row;
    uint8_t last_horizon_row;
    uint8_t row;

    if (!transform_world_vertices(camera, allow_room_cull)) return 0;
    layer->horizon_valid = (uint8_t)(
        fixed_absolute(camera->right.z) <= 8 &&
        fixed_absolute(camera->up.z) >= 64
    );
    if (layer->horizon_valid) {
        fixed_t vertical_depth = fixed_absolute(camera->up.z);
        fixed_t signed_forward = camera->up.z < 0 ?
            -camera->forward.z : camera->forward.z;
        int24_t horizon_offset = (int24_t)(
            ((int32_t)signed_forward * projection_scale_for_depth(vertical_depth)) >>
            (PROJECTION_SCALE_SHIFT + FIXED_SHIFT)
        );
        int16_t horizon = (int16_t)(VIEW_CENTER_Y + horizon_offset);
        if (active_render_shift != 0) horizon = (int16_t)half_projected(horizon);
        layer->horizon_row = horizon;
        first_horizon_row = layer->first_row;
        last_horizon_row = layer->last_row;
        if (layer->lod_shift != 0) {
            first_horizon_row = (uint8_t)(
                (first_horizon_row >> layer->lod_shift) << layer->lod_shift
            );
            last_horizon_row = (uint8_t)(
                (((last_horizon_row >> layer->lod_shift) + 1u) <<
                 layer->lod_shift) - 1u
            );
            if (last_horizon_row >= active_render_height) {
                last_horizon_row = active_render_height - 1u;
            }
        }
        /* Portal children never sample shading outside their aperture rows.
         * Root rendering still initializes the complete logical height. */
        for (row = first_horizon_row; row <= last_horizon_row; ++row) {
            int16_t distance = (int16_t)row - horizon;

            if (distance < 0) distance = -distance;
            horizon_light_subtract[row] = distance < active_horizon_near_limit ?
                2u : (distance < active_horizon_far_limit ? 1u : 0u);
        }
    }
    return 1;
}

static __attribute__((unused)) void collect_room_polygons(
    RenderLayer *layer,
    const Camera *camera,
    uint8_t skipped_face,
    uint8_t allow_portals
) {
    const Room *room = &rooms[camera->room];
    uint8_t face_added[ROOM_FACE_COUNT] = {0, 0, 0, 0, 0, 0};
    uint8_t offset;
    uint8_t portal_index;

    layer->count = 0;
    if (!prepare_room_geometry(layer, camera, 0)) {
        layer->solid_count = 0;
        return;
    }
    for (offset = 0; offset < ROOM_FACE_COUNT; ++offset) {
        uint8_t face_index = room->first_face + offset;

        if (face_index == skipped_face) continue;
        face_added[offset] = append_face_polygon(layer, face_index, offset);
    }
    layer->solid_count = layer->count;
    if (!allow_portals) return;
    /* Append apertures after every solid face so recursion cannot be overdrawn. */
    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const Portal *portal = &portals[portal_index];
        uint8_t host_offset;
        if (!portal->active || !portals[portal->linked].active ||
            portal->room != camera->room || portal->host_face < room->first_face) {
            continue;
        }
        host_offset = portal->host_face - room->first_face;
        if (host_offset < ROOM_FACE_COUNT && face_added[host_offset]) {
            append_portal_polygon(layer, camera, portal_index);
        }
    }
}

static __attribute__((always_inline)) inline int16_t floor_q8(int24_t value) {
    return (int16_t)(value >> FIXED_SHIFT);
}

static __attribute__((always_inline)) inline int16_t ceil_q8(int24_t value) {
    return (int16_t)((value + FIXED_ONE - 1) >> FIXED_SHIFT);
}

static fixed_t panel_grid_floor(fixed_t coordinate) {
    return (fixed_t)(coordinate & -PANEL_SEAM_INTERVAL);
}

static void write_frame_span(
    uint8_t row,
    int16_t first_column,
    int16_t last_column,
    uint8_t color
);

/* A world-grid plane perpendicular to the camera's dominant horizontal axis
 * projects to an almost horizontal floor/ceiling seam.  Sampling its center
 * gives the exact screen row without projecting and clipping two full line
 * endpoints.  Later wall fills trim the span to the visible room surface. */
static void draw_surface_depth_seams(
    const Camera *camera,
    const RenderLayer *layer,
    const DrawPolygon *polygon,
    uint8_t face_offset
) {
    const Room *room = &rooms[camera->room];
    fixed_t forward_x = fixed_absolute(camera->forward.x);
    fixed_t forward_y = fixed_absolute(camera->forward.y);
    fixed_t camera_coordinate;
    fixed_t minimum;
    fixed_t maximum;
    fixed_t coordinate;
    fixed_t advance;
    fixed_t plane_z;
    uint8_t color;
    uint8_t drawn = 0;
    uint8_t candidate;
    int16_t previous_row = -1;
    uint8_t axis;

    if (!layer->horizon_valid || face_offset > 1u) return;
    axis = forward_x >= forward_y ? 0u : 1u;
    camera_coordinate = axis == 0 ? camera->position.x : camera->position.y;
    minimum = axis == 0 ? room->minimum_x : room->minimum_y;
    maximum = axis == 0 ? room->maximum_x : room->maximum_y;
    advance = (axis == 0 ? camera->forward.x : camera->forward.y) >= 0 ?
        PANEL_SEAM_INTERVAL : -PANEL_SEAM_INTERVAL;
    coordinate = panel_grid_floor(camera_coordinate);
    if (advance > 0) {
        coordinate += PANEL_SEAM_INTERVAL;
    } else if (coordinate == camera_coordinate) {
        coordinate -= PANEL_SEAM_INTERVAL;
    }
    plane_z = face_offset == 0 ? room->minimum_z : room->maximum_z;
    {
        const WorldFace *face = &world_faces[room->first_face + face_offset];
        uint8_t light = face_light_level[face_offset];

        color = (uint8_t)(face->color + (light == 0 ? 0 : light - 1u));
    }

    for (candidate = 0;
         candidate < PANEL_DEPTH_SEAM_CANDIDATES &&
            drawn < PANEL_DEPTH_SEAM_COUNT;
         ++candidate, coordinate += advance) {
        Vec3 point = camera->position;
        CameraPoint transformed;
        ScreenPoint projected;
        int16_t row;

        if (coordinate <= minimum || coordinate >= maximum) {
            if ((advance > 0 && coordinate >= maximum) ||
                (advance < 0 && coordinate <= minimum)) {
                break;
            }
            continue;
        }
        if (fixed_absolute(coordinate - camera_coordinate) <
            PANEL_DEPTH_SEAM_MIN_DELTA) {
            continue;
        }
        if (axis == 0) point.x = coordinate;
        else point.y = coordinate;
        point.z = plane_z;
        transformed = transform_point(camera, point);
        if (transformed.depth < NEAR_PLANE) continue;
        projected = project_camera_point(&transformed);
        row = floor_q8(projected.y + FIXED_ONE / 2);
        if (row < polygon->sample_first_row || row > polygon->sample_last_row ||
            row < layer->first_row || row > layer->last_row ||
            row < 0 || row >= active_render_height || row == previous_row) {
            continue;
        }
        write_frame_span(
            (uint8_t)row,
            layer->row_left[row],
            layer->row_right[row],
            color
        );
        previous_row = row;
        ++drawn;
    }
}

/* Scan conversion only needs a clipped byte column. Range-checking before an
 * unsigned shift avoids the compiler's signed 24-bit shift helper in every
 * raster row while preserving the original top-left rounding exactly. */
static __attribute__((always_inline)) inline uint8_t raster_first_column(
    int24_t value
) {
    int24_t adjusted;

    if (value < -(FIXED_ONE / 2 - 1)) return 0;
    adjusted = value + FIXED_ONE / 2 - 1;
    if (adjusted >= (int24_t)active_render_width * FIXED_ONE) {
        return active_render_width;
    }
    return (uint8_t)((uint24_t)adjusted >> FIXED_SHIFT);
}

static __attribute__((always_inline)) inline uint8_t raster_last_column(
    int24_t value
) {
    int24_t adjusted;

    if (value < FIXED_ONE / 2) return 255u;
    adjusted = value - FIXED_ONE / 2;
    if (adjusted >= (int24_t)active_render_width * FIXED_ONE) {
        return active_render_width - 1u;
    }
    return (uint8_t)((uint24_t)adjusted >> FIXED_SHIFT);
}

static int32_t edge_x_step(int24_t delta_x, int24_t delta_y) {
    uint24_t index = ((uint24_t)delta_y +
        (1u << (EDGE_RECIPROCAL_SHIFT - 1))) >> EDGE_RECIPROCAL_SHIFT;

    if (delta_y < FIXED_ONE ||
        index >= EDGE_RECIPROCAL_SIZE ||
        delta_x > 32767 || delta_x < -32767) {
        RENDER_BENCHMARK_COUNT(edge_division_fallbacks, 1u);
        return ((int32_t)delta_x * FIXED_ONE) / delta_y;
    }
    return ((int32_t)delta_x * edge_reciprocal_table[index]) >>
        EDGE_STEP_PRECISION_SHIFT;
}

#if 0
static uint8_t rasterize_polygon_lod(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    uint8_t step = (uint8_t)(1u << layer->lod_shift);
    uint8_t sample_origin = step >> 1;
    uint8_t index;
    int24_t minimum_y = polygon->point[0].y;
    int24_t maximum_y = minimum_y;
    int16_t first_row;
    int16_t last_row;
    int16_t row;
    uint8_t any = 0;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);

    for (index = 1; index < polygon->count; ++index) {
        if (polygon->point[index].y < minimum_y) minimum_y = polygon->point[index].y;
        if (polygon->point[index].y > maximum_y) maximum_y = polygon->point[index].y;
    }
    first_row = ceil_q8(minimum_y - FIXED_ONE / 2);
    last_row = floor_q8(maximum_y - 1 - FIXED_ONE / 2);
    if (layer->lod_shift == 0) {
        if (first_row < layer->first_row) first_row = layer->first_row;
        if (last_row > layer->last_row) last_row = layer->last_row;
    } else {
        int16_t clip_first =
            ((int16_t)layer->first_row >> layer->lod_shift) * step + sample_origin;
        int16_t clip_last =
            ((int16_t)layer->last_row >> layer->lod_shift) * step + sample_origin;
        if (first_row < clip_first) first_row = clip_first;
        if (last_row > clip_last) last_row = clip_last;
    }
    if (first_row < 0) first_row = 0;
    if (last_row >= active_render_height) last_row = active_render_height - 1;
    if (first_row <= sample_origin) {
        first_row = sample_origin;
    } else {
        first_row = sample_origin +
            (((first_row - sample_origin + step - 1u) >> layer->lod_shift) <<
             layer->lod_shift);
    }
    if (last_row < sample_origin) return 0;
    last_row = sample_origin +
        (((last_row - sample_origin) >> layer->lod_shift) << layer->lod_shift);
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; row += step) {
        span_left[row] = PROJECTED_LIMIT + 1;
        span_right[row] = -PROJECTED_LIMIT - 1;
    }
    for (index = 0; index < polygon->count; ++index) {
        ScreenPoint a = polygon->point[index];
        ScreenPoint b = polygon->point[
            index + 1 == polygon->count ? 0 : index + 1
        ];
        int24_t delta_x;
        int24_t delta_y;
        int32_t x_step;
        int32_t x_value;
        int16_t edge_first;
        int16_t edge_last;
        int16_t current_row;

        if (a.y == b.y) continue;
        if (a.y > b.y) {
            ScreenPoint swap = a;
            a = b;
            b = swap;
        }
        delta_x = (int24_t)b.x - a.x;
        delta_y = (int24_t)b.y - a.y;
        edge_first = ceil_q8((int24_t)a.y - FIXED_ONE / 2);
        edge_last = floor_q8((int24_t)b.y - 1 - FIXED_ONE / 2);
        if (edge_first < first_row) edge_first = first_row;
        if (edge_last > last_row) edge_last = last_row;
        if (edge_first <= sample_origin) {
            edge_first = sample_origin;
        } else {
            edge_first = sample_origin +
                (((edge_first - sample_origin + step - 1u) >> layer->lod_shift) <<
                 layer->lod_shift);
        }
        if (edge_first > edge_last) continue;

        x_step = edge_x_step(delta_x, delta_y);
        x_value = a.x + (int32_t)(
            (x_step *
                ((int24_t)edge_first * FIXED_ONE + FIXED_ONE / 2 - a.y)) >>
            FIXED_SHIFT
        );
        for (current_row = edge_first; current_row <= edge_last; current_row += step) {
            if (x_value < span_left[current_row]) {
                span_left[current_row] = clamp_projected(x_value);
            }
            if (x_value > span_right[current_row]) {
                span_right[current_row] = clamp_projected(x_value);
            }
            if (current_row + step <= edge_last) x_value += x_step * step;
        }
    }

    polygon->first_row = (uint8_t)first_row;
    polygon->last_row = (uint8_t)last_row;
    RENDER_BENCHMARK_COUNT(
        raster_rows,
        (uint16_t)(((last_row - first_row) >> layer->lod_shift) + 1)
    );
    for (row = first_row; row <= last_row; row += step) {
        uint8_t first_column;
        uint8_t last_column;

        if (span_left[row] == PROJECTED_LIMIT + 1) {
            polygon->span_left[row] = 255;
            polygon->span_right[row] = 0;
            continue;
        }
        first_column = ceil_q8((int24_t)span_left[row] - FIXED_ONE / 2);
        last_column = floor_q8((int24_t)span_right[row] - FIXED_ONE / 2);
        if (first_column < 0) first_column = 0;
        if (last_column >= active_render_width) last_column = active_render_width - 1;
        if (first_column <= last_column) {
            polygon->span_left[row] = (uint8_t)first_column;
            polygon->span_right[row] = (uint8_t)last_column;
            if (layer->lod_shift != 0 ||
                (row >= layer->first_row && row <= layer->last_row &&
                 last_column >= layer->row_left[row] &&
                 first_column <= layer->row_right[row])) {
                any = 1;
            }
        } else {
            polygon->span_left[row] = 255;
            polygon->span_right[row] = 0;
        }
    }
    return any;
}

/*
 * Full-resolution layers use one sample per row. Keeping this path separate
 * lets the compiler fold step=1 and sample_origin=0 instead of carrying the
 * portal LOD shift through every edge and scanline.
 */
static uint8_t rasterize_polygon_full(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    uint8_t index;
    int24_t minimum_y = polygon->point[0].y;
    int24_t maximum_y = minimum_y;
    int16_t first_row;
    int16_t last_row;
    int16_t row;
    uint8_t any = 0;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);

    for (index = 1; index < polygon->count; ++index) {
        if (polygon->point[index].y < minimum_y) minimum_y = polygon->point[index].y;
        if (polygon->point[index].y > maximum_y) maximum_y = polygon->point[index].y;
    }
    first_row = ceil_q8(minimum_y - FIXED_ONE / 2);
    last_row = floor_q8(maximum_y - 1 - FIXED_ONE / 2);
    if (first_row < layer->first_row) first_row = layer->first_row;
    if (last_row > layer->last_row) last_row = layer->last_row;
    if (first_row < 0) first_row = 0;
    if (last_row >= active_render_height) last_row = active_render_height - 1;
    if (first_row <= 0) first_row = 0;
    if (last_row < 0) return 0;
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; ++row) {
        span_left[row] = PROJECTED_LIMIT + 1;
        span_right[row] = -PROJECTED_LIMIT - 1;
    }
    for (index = 0; index < polygon->count; ++index) {
        ScreenPoint a = polygon->point[index];
        ScreenPoint b = polygon->point[
            index + 1 == polygon->count ? 0 : index + 1
        ];
        int24_t delta_x;
        int24_t delta_y;
        int32_t x_step;
        int32_t x_value;
        int16_t edge_first;
        int16_t edge_last;
        int16_t current_row;

        if (a.y == b.y) continue;
        if (a.y > b.y) {
            ScreenPoint swap = a;
            a = b;
            b = swap;
        }
        delta_x = (int24_t)b.x - a.x;
        delta_y = (int24_t)b.y - a.y;
        edge_first = ceil_q8((int24_t)a.y - FIXED_ONE / 2);
        edge_last = floor_q8((int24_t)b.y - 1 - FIXED_ONE / 2);
        if (edge_first < first_row) edge_first = first_row;
        if (edge_last > last_row) edge_last = last_row;
        if (edge_first <= 0) edge_first = 0;
        if (edge_first > edge_last) continue;

        x_step = edge_x_step(delta_x, delta_y);
        x_value = a.x + (int32_t)(
            (x_step *
                ((int24_t)edge_first * FIXED_ONE + FIXED_ONE / 2 - a.y)) >>
            FIXED_SHIFT
        );
        for (current_row = edge_first; current_row <= edge_last; ++current_row) {
            if (x_value < span_left[current_row]) {
                span_left[current_row] = clamp_projected(x_value);
            }
            if (x_value > span_right[current_row]) {
                span_right[current_row] = clamp_projected(x_value);
            }
            if (current_row < edge_last) x_value += x_step;
        }
    }

    polygon->first_row = (uint8_t)first_row;
    polygon->last_row = (uint8_t)last_row;
    RENDER_BENCHMARK_COUNT(
        raster_rows,
        (uint16_t)(last_row - first_row + 1)
    );
    for (row = first_row; row <= last_row; ++row) {
        uint8_t first_column;
        uint8_t last_column;

        if (span_left[row] == PROJECTED_LIMIT + 1) {
            polygon->span_left[row] = 255;
            polygon->span_right[row] = 0;
            continue;
        }
        first_column = ceil_q8((int24_t)span_left[row] - FIXED_ONE / 2);
        last_column = floor_q8((int24_t)span_right[row] - FIXED_ONE / 2);
        if (first_column < 0) first_column = 0;
        if (last_column >= active_render_width) last_column = active_render_width - 1;
        if (first_column <= last_column) {
            polygon->span_left[row] = (uint8_t)first_column;
            polygon->span_right[row] = (uint8_t)last_column;
            if (row >= layer->first_row && row <= layer->last_row &&
                last_column >= layer->row_left[row] &&
                first_column <= layer->row_right[row]) {
                any = 1;
            }
        } else {
            polygon->span_left[row] = 255;
            polygon->span_right[row] = 0;
        }
    }
    return any;
}

static uint8_t rasterize_polygon(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    if (layer->lod_shift == 0) {
        return rasterize_polygon_full(polygon, layer);
    }
    return rasterize_polygon_lod(polygon, layer);
}
#endif

#include "raster_two_chain_split.inc"

#if RENDER_WIDTH == 80 && !TRUE3D_BENCHMARK_COUNTERS
_Static_assert(sizeof(RasterChain) == 19u, "Assembly RasterChain size mismatch");
_Static_assert(
    offsetof(RasterChain, last_row) == 3u &&
    offsetof(RasterChain, x_value) == 4u &&
    offsetof(RasterChain, x_advance) == 7u,
    "Assembly RasterChain offsets mismatch"
);
_Static_assert(
    offsetof(RenderLayer, row_left) == 1456u &&
    offsetof(RenderLayer, row_right) == 1516u &&
    offsetof(RenderLayer, bound_left) == 1580u &&
    offsetof(RenderLayer, bound_right) == 1581u,
    "Assembly RenderLayer offsets mismatch"
);
void raster_fill_segment_80(
    RasterChain *first_chain,
    RasterChain *second_chain,
    const RenderLayer *layer,
    uint8_t first_row,
    uint8_t last_row,
    uint8_t base_color,
    uint8_t horizon_shaded
);
void raster_fill_root_segment_80(
    RasterChain *first_chain,
    RasterChain *second_chain,
    uint8_t first_row,
    uint8_t last_row,
    uint8_t base_color,
    uint8_t horizon_shaded
);
void raster_flat_body_80(
    const RenderLayer *layer,
    uint8_t first_column,
    uint8_t last_column,
    uint8_t first_row,
    uint8_t last_row,
    uint8_t light_last_row,
    uint8_t has_light_rows,
    uint8_t base_color
);
void raster_fill_lod_segment_80(
    RasterChain *first_chain,
    RasterChain *second_chain,
    const RenderLayer *layer,
    uint8_t first_row,
    uint8_t last_row,
    uint8_t base_color,
    uint8_t horizon_shaded,
    uint8_t shift
);
void composite_portal_lod_half_80(const RenderLayer *layer);
void composite_portal_lod_80(const RenderLayer *layer, uint8_t shift);
#endif

static void write_frame_span(
    uint8_t row,
    int16_t first_column,
    int16_t last_column,
    uint8_t color
) {
    if (first_column <= last_column) {
        uint16_t width = (uint16_t)(last_column - first_column + 1);

        RENDER_BENCHMARK_COUNT(filled_spans, 1u);
        RENDER_BENCHMARK_COUNT(filled_pixels, width);
        memset(
            &low_frame.data[low_row_offsets[row] + first_column],
            color,
            width
        );
    }
}

static __attribute__((unused, always_inline)) inline void write_small_frame_span(
    uint8_t row,
    int16_t first_column,
    int16_t last_column,
    uint8_t color
) {
    if (first_column <= last_column) {
        uint8_t *destination =
            &low_frame.data[low_row_offsets[row] + first_column];
        uint8_t width = (uint8_t)(last_column - first_column + 1);

        RENDER_BENCHMARK_COUNT(filled_spans, 1u);
        RENDER_BENCHMARK_COUNT(filled_pixels, width);
        do {
            *destination++ = color;
        } while (--width != 0);
    }
}

static __attribute__((unused, always_inline)) inline uint8_t face_color_for_row(
    const DrawPolygon *polygon,
    const RenderLayer *layer,
    uint8_t row
) {
    uint8_t light = face_light_level[polygon->face_offset];

    if (polygon->face_offset <= 1u && layer->horizon_valid) {
        uint8_t subtract = horizon_light_subtract[row];

        light = light > subtract ? light - subtract : 0u;
    }
    return polygon->color + light;
}

#if 0
static void fill_polygon(const DrawPolygon *polygon, const RenderLayer *layer) {
    const DrawPolygon *aperture_polygon[PORTAL_COUNT];
    uint8_t aperture_count = 0;
    uint8_t index;
    uint8_t row;

    for (index = layer->solid_count;
         index < layer->count && aperture_count < PORTAL_COUNT;
         ++index) {
        const DrawPolygon *aperture = &layer->polygon[index];
        if (aperture->portal != NO_PORTAL &&
            portals[aperture->portal].host_face == polygon->face) {
            aperture_polygon[aperture_count++] = aperture;
        }
    }
    if (aperture_count == 0) {
        for (row = polygon->first_row; row <= polygon->last_row; ++row) {
            int16_t first_column;
            int16_t last_column;
            if (polygon->span_left[row] > polygon->span_right[row] ||
                row < layer->first_row || row > layer->last_row) {
                continue;
            }
            first_column = polygon->span_left[row];
            last_column = polygon->span_right[row];
            if (first_column < layer->row_left[row]) first_column = layer->row_left[row];
            if (last_column > layer->row_right[row]) last_column = layer->row_right[row];
            write_frame_span(
                row,
                first_column,
                last_column,
                face_color_for_row(polygon, layer, row)
            );
        }
        return;
    }
    for (row = polygon->first_row; row <= polygon->last_row; ++row) {
        uint8_t first_column;
        uint8_t last_column;
        uint8_t hole_left[PORTAL_COUNT];
        uint8_t hole_right[PORTAL_COUNT];
        uint8_t hole_count = 0;
        uint8_t aperture_number;
        uint8_t row_color;
        int16_t cursor;

        if (polygon->span_left[row] > polygon->span_right[row] ||
            row < layer->first_row || row > layer->last_row) {
            continue;
        }
        first_column = polygon->span_left[row];
        last_column = polygon->span_right[row];
        if (first_column < layer->row_left[row]) first_column = layer->row_left[row];
        if (last_column > layer->row_right[row]) last_column = layer->row_right[row];
        if (first_column > last_column) continue;
        row_color = face_color_for_row(polygon, layer, row);

        /* The only systematic overdraw in a convex room is its portal host wall. */
        for (aperture_number = 0;
             aperture_number < aperture_count && hole_count < PORTAL_COUNT;
             ++aperture_number) {
            const DrawPolygon *aperture = aperture_polygon[aperture_number];
            int16_t left;
            int16_t right;
            if (row < aperture->first_row || row > aperture->last_row ||
                aperture->span_left[row] > aperture->span_right[row]) {
                continue;
            }
            left = aperture->span_left[row];
            right = aperture->span_right[row];
            if (left < first_column) left = first_column;
            if (right > last_column) right = last_column;
            if (left <= right) {
                hole_left[hole_count] = (uint8_t)left;
                hole_right[hole_count] = (uint8_t)right;
                ++hole_count;
            }
        }
        if (hole_count == 2 && hole_left[1] < hole_left[0]) {
            uint8_t swap = hole_left[0];
            hole_left[0] = hole_left[1];
            hole_left[1] = swap;
            swap = hole_right[0];
            hole_right[0] = hole_right[1];
            hole_right[1] = swap;
        }
        cursor = first_column;
        for (aperture_number = 0; aperture_number < hole_count; ++aperture_number) {
            if (hole_right[aperture_number] < cursor) continue;
            write_frame_span(
                row,
                cursor,
                (int16_t)hole_left[aperture_number] - 1,
                row_color
            );
            cursor = (int16_t)hole_right[aperture_number] + 1;
            if (cursor > last_column) break;
        }
        write_frame_span(row, cursor, last_column, row_color);
    }
}
#endif

static __attribute__((unused)) void fill_polygon_color_rows(
    const DrawPolygon *polygon,
    const RenderLayer *layer,
    const DrawPolygon *const *aperture_polygon,
    uint8_t aperture_count,
    int16_t first_row,
    int16_t last_row,
    uint8_t row_color
) {
    uint8_t row;

    if (first_row < polygon->first_row) first_row = polygon->first_row;
    if (last_row > polygon->last_row) last_row = polygon->last_row;
    if (first_row > last_row) return;

    if (aperture_count == 0 && layer == &render_layers[0]) {
        for (row = (uint8_t)first_row; row <= (uint8_t)last_row; ++row) {
            write_frame_span(
                row,
                polygon->span_left[row],
                polygon->span_right[row],
                row_color
            );
        }
        return;
    }
    if (aperture_count == 0) {
        for (row = (uint8_t)first_row; row <= (uint8_t)last_row; ++row) {
            int16_t first_column = polygon->span_left[row];
            int16_t last_column = polygon->span_right[row];

            if (first_column < layer->row_left[row]) first_column = layer->row_left[row];
            if (last_column > layer->row_right[row]) last_column = layer->row_right[row];
            write_frame_span(row, first_column, last_column, row_color);
        }
        return;
    }
    for (row = (uint8_t)first_row; row <= (uint8_t)last_row; ++row) {
        int16_t first_column;
        int16_t last_column;
        uint8_t hole_left[PORTAL_COUNT];
        uint8_t hole_right[PORTAL_COUNT];
        uint8_t hole_count = 0;
        uint8_t aperture_number;
        int16_t cursor;

        first_column = polygon->span_left[row];
        last_column = polygon->span_right[row];
        if (first_column < layer->row_left[row]) first_column = layer->row_left[row];
        if (last_column > layer->row_right[row]) last_column = layer->row_right[row];
        if (first_column > last_column) continue;

        for (aperture_number = 0;
             aperture_number < aperture_count && hole_count < PORTAL_COUNT;
             ++aperture_number) {
            const DrawPolygon *aperture = aperture_polygon[aperture_number];
            int16_t left;
            int16_t right;
            if (row < aperture->first_row || row > aperture->last_row ||
                aperture->span_left[row] > aperture->span_right[row]) {
                continue;
            }
            left = aperture->span_left[row];
            right = aperture->span_right[row];
            if (left < first_column) left = first_column;
            if (right > last_column) right = last_column;
            if (left <= right) {
                hole_left[hole_count] = (uint8_t)left;
                hole_right[hole_count] = (uint8_t)right;
                ++hole_count;
            }
        }
        if (hole_count == 2 && hole_left[1] < hole_left[0]) {
            uint8_t swap = hole_left[0];
            hole_left[0] = hole_left[1];
            hole_left[1] = swap;
            swap = hole_right[0];
            hole_right[0] = hole_right[1];
            hole_right[1] = swap;
        }
        cursor = first_column;
        for (aperture_number = 0; aperture_number < hole_count; ++aperture_number) {
            if (hole_right[aperture_number] < cursor) continue;
            write_frame_span(
                row,
                cursor,
                (int16_t)hole_left[aperture_number] - 1,
                row_color
            );
            cursor = (int16_t)hole_right[aperture_number] + 1;
            if (cursor > last_column) break;
        }
        write_frame_span(row, cursor, last_column, row_color);
    }
}

static __attribute__((unused)) void fill_polygon(
    const DrawPolygon *polygon,
    const RenderLayer *layer
) {
    const DrawPolygon *aperture_polygon[PORTAL_COUNT];
    uint8_t aperture_count = 0;
    uint8_t index;
    uint8_t base_light = face_light_level[polygon->face_offset];
    uint8_t base_color = polygon->color + base_light;

    for (index = layer->solid_count;
         index < layer->count && aperture_count < PORTAL_COUNT;
         ++index) {
        const DrawPolygon *aperture = &layer->polygon[index];
        if (aperture->portal != NO_PORTAL &&
            portals[aperture->portal].host_face == polygon->face) {
            aperture_polygon[aperture_count++] = aperture;
        }
    }
    if (polygon->face_offset > 1u || !layer->horizon_valid) {
        fill_polygon_color_rows(
            polygon,
            layer,
            aperture_polygon,
            aperture_count,
            polygon->first_row,
            polygon->last_row,
            base_color
        );
        return;
    }
    {
        int16_t horizon = layer->horizon_row;
        int16_t near_limit = active_horizon_near_limit;
        int16_t far_limit = active_horizon_far_limit;

        fill_polygon_color_rows(
            polygon, layer, aperture_polygon, aperture_count,
            polygon->first_row, horizon - far_limit, base_color
        );
        fill_polygon_color_rows(
            polygon, layer, aperture_polygon, aperture_count,
            horizon - far_limit + 1, horizon - near_limit,
            (uint8_t)(base_color - 1u)
        );
        fill_polygon_color_rows(
            polygon, layer, aperture_polygon, aperture_count,
            horizon - near_limit + 1, horizon + near_limit - 1,
            (uint8_t)(polygon->color + (base_light > 1u ? base_light - 2u : 0u))
        );
        fill_polygon_color_rows(
            polygon, layer, aperture_polygon, aperture_count,
            horizon + near_limit, horizon + far_limit - 1,
            (uint8_t)(base_color - 1u)
        );
        fill_polygon_color_rows(
            polygon, layer, aperture_polygon, aperture_count,
            horizon + far_limit, polygon->last_row, base_color
        );
    }
}

static uint8_t build_portal_clip(
    const DrawPolygon *portal_polygon,
    const RenderLayer *parent,
    RenderLayer *child
) {
    uint8_t row;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t any = 0;

    child->first_row = active_render_height;
    child->last_row = 0;
    child->bound_left = active_render_width;
    child->bound_right = 0;
    child->pixel_area = 0;
    first_row = portal_polygon->first_row > parent->first_row ?
        portal_polygon->first_row : parent->first_row;
    last_row = portal_polygon->last_row < parent->last_row ?
        portal_polygon->last_row : parent->last_row;
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; ++row) {
        uint8_t first_column;
        uint8_t last_column;

        /* Only rows touched by this aperture can be consumed by child
         * rendering or composition.  Initializing this exact interval avoids
         * clearing both complete 60-row clip arrays for every portal. */
        child->row_left[row] = 255u;
        child->row_right[row] = 0u;
        if (portal_polygon->span_left[row] > portal_polygon->span_right[row] ||
            parent->row_left[row] > parent->row_right[row]) {
            continue;
        }
        first_column = portal_polygon->span_left[row];
        last_column = portal_polygon->span_right[row];
        if (first_column < parent->row_left[row]) first_column = parent->row_left[row];
        if (last_column > parent->row_right[row]) last_column = parent->row_right[row];
        if (first_column > last_column) continue;

        child->row_left[row] = first_column;
        child->row_right[row] = last_column;
        child->pixel_area += (uint16_t)(last_column - first_column + 1u);
        if (!any || row < child->first_row) child->first_row = row;
        if (!any || row > child->last_row) child->last_row = row;
        if (!any || first_column < child->bound_left) child->bound_left = first_column;
        if (!any || last_column > child->bound_right) child->bound_right = last_column;
        any = 1;
    }
    if (any) {
        uint8_t width = child->bound_right - child->bound_left + 1u;
        uint8_t height = child->last_row - child->first_row + 1u;
        uint16_t normalized_area = child->pixel_area;
        uint8_t normalized_width = width;
        uint8_t normalized_height = height;
        uint8_t lod = portal_lod_state[portal_polygon->portal];
        uint8_t full_detail;
        uint8_t reduced_detail;
        uint8_t heavy_portal_pair = (uint8_t)(
            active_body_count >= T3D3_MAX_BODIES &&
            parent->count == PORTAL_COUNT
        );

        if (active_render_shift != 0) {
            normalized_area <<= 2;
            normalized_width <<= 1;
            normalized_height <<= 1;
        }
        full_detail = (uint8_t)(
            normalized_area > PORTAL_LOD_FULL_ENTER_AREA &&
            normalized_width > PORTAL_LOD_FULL_ENTER_WIDTH &&
            normalized_height > PORTAL_LOD_FULL_ENTER_HEIGHT
        );
        reduced_detail = (uint8_t)(
            normalized_area < PORTAL_LOD_HALF_ENTER_AREA ||
            normalized_width < PORTAL_LOD_HALF_ENTER_WIDTH ||
            normalized_height < PORTAL_LOD_HALF_ENTER_HEIGHT
        );

        if (lod == 0) {
            if (normalized_area < PORTAL_LOD_QUARTER_ENTER_AREA ||
                (heavy_portal_pair && reduced_detail)) {
                lod = 2;
            } else if (reduced_detail) {
                lod = 1;
            }
        } else if (lod == 1) {
            /* Four visible bodies already dominate root geometry.  When both
             * portals are also visible, use the quarter-size portal scratch
             * path for apertures that would otherwise be half-size.  Portal
             * outlines remain full-resolution, and a large portal still
             * promotes directly back to full detail. */
            if (normalized_area < PORTAL_LOD_QUARTER_ENTER_AREA ||
                (heavy_portal_pair && !full_detail)) {
                lod = 2;
            } else if (full_detail) {
                lod = 0;
            }
        } else if (normalized_area > PORTAL_LOD_QUARTER_LEAVE_AREA) {
            if (full_detail) {
                lod = 0;
            } else if (!heavy_portal_pair) {
                lod = 1;
            }
        }
        portal_lod_state[portal_polygon->portal] = lod;
        child->lod_shift = lod;
        RENDER_BENCHMARK_COUNT(portal_clip_pixels, child->pixel_area);
        if (lod == 0) {
            RENDER_BENCHMARK_COUNT(full_portal_views, 1u);
        } else {
            RENDER_BENCHMARK_COUNT(lod_portal_views, 1u);
        }
    }
    return any;
}

static Vec3 transform_portal_vector(uint8_t portal_index, Vec3 vector) {
    const Portal *source = &portals[portal_index];
    const Portal *destination = &portals[source->linked];
    fixed_t local_right = signed_axis_component(vector, source->right);
    fixed_t local_up = signed_axis_component(vector, source->up);
    fixed_t local_normal = signed_axis_component(vector, source->normal);
    Vec3 result = {0, 0, 0};

    add_signed_axis(&result, destination->right, -local_right);
    add_signed_axis(&result, destination->up, local_up);
    add_signed_axis(&result, destination->normal, -local_normal);
    return result;
}

static Vec3 transform_portal_point(uint8_t portal_index, Vec3 point) {
    const Portal *source = &portals[portal_index];
    const Portal *destination = &portals[source->linked];
    Vec3 relative = vec_subtract(point, source->center);
    return vec_add(destination->center, transform_portal_vector(portal_index, relative));
}

static Camera transform_portal_camera(uint8_t portal_index, const Camera *source) {
    const Portal *destination_portal = &portals[portals[portal_index].linked];
    Camera destination;

    destination.position = transform_portal_point(portal_index, source->position);
    destination.right = transform_portal_vector(portal_index, source->right);
    destination.up = transform_portal_vector(portal_index, source->up);
    destination.forward = transform_portal_vector(portal_index, source->forward);
    destination.room = destination_portal->room;
    return destination;
}

static void clear_render_layer(const RenderLayer *layer, uint8_t depth) {
    if (depth == 0) {
        memset(
            low_frame.data,
            COLOR_VOID,
            (uint16_t)active_render_width * active_render_height
        );
    } else {
        uint8_t row;
        for (row = layer->first_row; row <= layer->last_row; ++row) {
            if (layer->row_left[row] <= layer->row_right[row]) {
                write_frame_span(
                    row,
                    layer->row_left[row],
                    layer->row_right[row],
                    COLOR_VOID
                );
            }
        }
    }
}

static void draw_portal_outline(const RenderLayer *clip, uint8_t color) {
    uint8_t row;

    for (row = clip->first_row; row <= clip->last_row; ++row) {
        uint8_t left = clip->row_left[row];
        uint8_t right = clip->row_right[row];
        if (left <= right) {
            low_frame.data[low_row_offsets[row] + left] = color;
            low_frame.data[low_row_offsets[row] + right] = color;
        }
    }
    write_frame_span(
        clip->first_row,
        clip->row_left[clip->first_row],
        clip->row_right[clip->first_row],
        color
    );
    if (clip->last_row != clip->first_row) {
        write_frame_span(
            clip->last_row,
            clip->row_left[clip->last_row],
            clip->row_right[clip->last_row],
            color
        );
    }
}

static void clear_portal_lod(const RenderLayer *layer) {
    uint8_t shift = layer->lod_shift;
    uint8_t first_row;
    uint8_t last_row;

    if (shift == 0) return;
    first_row = layer->first_row >> shift;
    last_row = layer->last_row >> shift;
    /* Pixels outside the aperture are never composited. Clearing complete
     * scratch rows trades a few harmless stores for one memset instead of up
     * to thirty tiny libc calls on every reduced-resolution portal view. */
    memset(
        &portal_lod_frame[(uint16_t)first_row * PORTAL_LOD_STRIDE],
        COLOR_VOID,
        (uint16_t)(last_row - first_row + 1u) * PORTAL_LOD_STRIDE
    );
}

/* Depth-one cameras cannot recurse, so emit their spans as they are scanned
 * instead of storing every span in DrawPolygon and reading it back to fill. */
static void rasterize_fill_polygon_full(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    int16_t first_row_value = polygon->sample_first_row;
    int16_t last_row_value = polygon->sample_last_row;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t row;
    uint8_t base_color __attribute__((unused)) =
        (uint8_t)(polygon->color + face_light_level[polygon->face_offset]);
    uint8_t horizon_shaded __attribute__((unused)) = (uint8_t)(
        polygon->face_offset <= 1u && layer->horizon_valid
    );
    RasterChain first_chain;
    RasterChain second_chain;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);
    if (first_row_value < layer->first_row) first_row_value = layer->first_row;
    if (last_row_value > layer->last_row) last_row_value = layer->last_row;
    if (first_row_value < 0) first_row_value = 0;
    if (last_row_value >= active_render_height) {
        last_row_value = active_render_height - 1;
    }
    if (last_row_value < 0 || first_row_value > last_row_value) return;
    first_row = (uint8_t)first_row_value;
    last_row = (uint8_t)last_row_value;

    RENDER_BENCHMARK_COUNT(raster_rows, (uint16_t)(last_row - first_row + 1));
    first_chain.vertex = polygon->top_vertex;
    first_chain.point = &polygon->point[polygon->top_vertex];
    first_chain.begin = polygon->point;
    first_chain.end = polygon->point + polygon->count;
    first_chain.direction = 1;
    first_chain.edges_left = polygon->count;
    second_chain.vertex = polygon->top_vertex;
    second_chain.point = &polygon->point[polygon->top_vertex];
    second_chain.begin = polygon->point;
    second_chain.end = polygon->point + polygon->count;
    second_chain.direction = -1;
    second_chain.edges_left = polygon->count;
    if (!raster_chain_begin_edge(&first_chain, first_row, 1u) ||
        !raster_chain_begin_edge(&second_chain, first_row, 1u)) {
        return;
    }

#if RENDER_WIDTH == 80 && !TRUE3D_BENCHMARK_COUNTERS
    row = first_row;
    while (row <= last_row) {
        uint8_t segment_last;

        if (row > first_chain.last_row &&
            !raster_chain_begin_edge(&first_chain, row, 1u)) {
            return;
        }
        if (row > second_chain.last_row &&
            !raster_chain_begin_edge(&second_chain, row, 1u)) {
            return;
        }
        segment_last = first_chain.last_row < second_chain.last_row ?
            first_chain.last_row : second_chain.last_row;
        if (segment_last > last_row) segment_last = last_row;
        if (layer == &render_layers[0] && active_render_width == 80u) {
            raster_fill_root_segment_80(
                &first_chain,
                &second_chain,
                row,
                segment_last,
                base_color,
                horizon_shaded
            );
        } else {
            raster_fill_segment_80(
                &first_chain,
                &second_chain,
                layer,
                row,
                segment_last,
                base_color,
                horizon_shaded
            );
        }
        row = segment_last + 1u;
    }
#else
    for (row = first_row; row <= last_row; ++row) {
        int24_t left_value;
        int24_t right_value;
        uint8_t first_column;
        uint8_t last_column;

        if (row > first_chain.last_row &&
            !raster_chain_begin_edge(&first_chain, row, 1u)) {
            return;
        }
        if (row > second_chain.last_row &&
            !raster_chain_begin_edge(&second_chain, row, 1u)) {
            return;
        }
        left_value = first_chain.x_value;
        right_value = second_chain.x_value;
        if (left_value > right_value) {
            int24_t swap = left_value;
            left_value = right_value;
            right_value = swap;
        }
        first_column = raster_first_column(left_value);
        last_column = raster_last_column(right_value);
        if (last_column != 255u && first_column < active_render_width) {
            uint8_t row_color = base_color;

            if (first_column < layer->row_left[row]) {
                first_column = layer->row_left[row];
            }
            if (last_column > layer->row_right[row]) {
                last_column = layer->row_right[row];
            }
            if (horizon_shaded) {
                row_color = face_color_for_row(polygon, layer, row);
            }
            write_frame_span(
                row,
                first_column,
                last_column,
                row_color
            );
        }
        if (row < first_chain.last_row) {
            first_chain.x_value += first_chain.x_advance;
        }
        if (row < second_chain.last_row) {
            second_chain.x_value += second_chain.x_advance;
        }
    }
#endif
}

static void rasterize_fill_polygon_lod(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    uint8_t shift = layer->lod_shift;
    uint8_t step = (uint8_t)(1u << shift);
    uint8_t sample_origin = step >> 1;
    uint8_t maximum_column __attribute__((unused)) =
        (active_render_width >> shift) - 1u;
    uint8_t base_color __attribute__((unused)) =
        (uint8_t)(polygon->color + face_light_level[polygon->face_offset]);
    uint8_t horizon_shaded __attribute__((unused)) = (uint8_t)(
        polygon->face_offset <= 1u && layer->horizon_valid
    );
    int16_t first_row = polygon->sample_first_row;
    int16_t last_row = polygon->sample_last_row;
    int16_t row;
    RasterChain first_chain;
    RasterChain second_chain;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);
    {
        int16_t clip_first =
            ((int16_t)layer->first_row >> shift) * step + sample_origin;
        int16_t clip_last =
            ((int16_t)layer->last_row >> shift) * step + sample_origin;
        if (first_row < clip_first) first_row = clip_first;
        if (last_row > clip_last) last_row = clip_last;
    }
    if (first_row < 0) first_row = 0;
    if (last_row >= active_render_height) last_row = active_render_height - 1;
    if (first_row <= sample_origin) {
        first_row = sample_origin;
    } else {
        first_row = sample_origin +
            (((first_row - sample_origin + step - 1u) >> shift) << shift);
    }
    if (last_row < sample_origin) return;
    last_row = sample_origin +
        (((last_row - sample_origin) >> shift) << shift);
    if (first_row > last_row) return;

    RENDER_BENCHMARK_COUNT(
        raster_rows,
        (uint16_t)(((last_row - first_row) >> shift) + 1)
    );
    first_chain.vertex = polygon->top_vertex;
    first_chain.point = &polygon->point[polygon->top_vertex];
    first_chain.begin = polygon->point;
    first_chain.end = polygon->point + polygon->count;
    first_chain.direction = 1;
    first_chain.edges_left = polygon->count;
    second_chain.vertex = polygon->top_vertex;
    second_chain.point = &polygon->point[polygon->top_vertex];
    second_chain.begin = polygon->point;
    second_chain.end = polygon->point + polygon->count;
    second_chain.direction = -1;
    second_chain.edges_left = polygon->count;
    if (!raster_chain_begin_edge(&first_chain, first_row, step) ||
        !raster_chain_begin_edge(&second_chain, first_row, step)) {
        return;
    }

#if RENDER_WIDTH == 80 && !TRUE3D_BENCHMARK_COUNTERS
    row = first_row;
    while (row <= last_row) {
        uint8_t edge_last;
        uint8_t segment_last;

        if (row > first_chain.last_row &&
            !raster_chain_begin_edge(&first_chain, row, step)) {
            return;
        }
        if (row > second_chain.last_row &&
            !raster_chain_begin_edge(&second_chain, row, step)) {
            return;
        }
        edge_last = first_chain.last_row < second_chain.last_row ?
            first_chain.last_row : second_chain.last_row;
        if (edge_last > last_row) edge_last = (uint8_t)last_row;
        segment_last = (uint8_t)(
            row + (((edge_last - row) >> shift) << shift)
        );
        raster_fill_lod_segment_80(
            &first_chain,
            &second_chain,
            layer,
            (uint8_t)row,
            segment_last,
            base_color,
            horizon_shaded,
            shift
        );
        row = segment_last + step;
    }
#else
    for (row = first_row; row <= last_row; row += step) {
        int24_t left_value;
        int24_t right_value;
        uint8_t first_column;
        uint8_t last_column;

        if (row > first_chain.last_row &&
            !raster_chain_begin_edge(&first_chain, row, step)) {
            return;
        }
        if (row > second_chain.last_row &&
            !raster_chain_begin_edge(&second_chain, row, step)) {
            return;
        }
        left_value = first_chain.x_value;
        right_value = second_chain.x_value;
        if (left_value > right_value) {
            int24_t swap = left_value;
            left_value = right_value;
            right_value = swap;
        }
        first_column = raster_first_column(left_value);
        last_column = raster_last_column(right_value);
        if (last_column != 255u && first_column < active_render_width &&
            last_column >= sample_origin) {
            /* Reduced portal views are composited only inside the aperture's
             * bounding rectangle. Clamp before downsampling so unreachable
             * destination-room pixels are never written. */
            if (first_column < layer->bound_left) {
                first_column = layer->bound_left;
            }
            if (last_column > layer->bound_right) {
                last_column = layer->bound_right;
            }
            uint8_t target_first = first_column <= sample_origin ? 0 :
                (uint8_t)((first_column - sample_origin + step - 1u) >>
                    shift);
            uint8_t target_last =
                (uint8_t)((last_column - sample_origin) >> shift);

            if (target_last > maximum_column) target_last = maximum_column;
            if (target_first <= target_last) {
                uint8_t target_row = (uint8_t)row >> shift;
                memset(
                    &portal_lod_frame[
                        (uint16_t)target_row * PORTAL_LOD_STRIDE + target_first
                    ],
                    face_color_for_row(polygon, layer, (uint8_t)row),
                    (size_t)(target_last - target_first + 1u)
                );
            }
        }
        if (row + step <= first_chain.last_row) {
            first_chain.x_value += first_chain.x_advance;
        }
        if (row + step <= second_chain.last_row) {
            second_chain.x_value += second_chain.x_advance;
        }
    }
#endif
}

static __attribute__((unused)) void composite_portal_lod_half(
    const RenderLayer *layer
) {
    uint8_t row;

    for (row = layer->first_row; row <= layer->last_row; ++row) {
        uint8_t column;
        uint8_t *destination;
        const uint8_t *source;

        if (layer->row_left[row] > layer->row_right[row]) continue;
        RENDER_BENCHMARK_COUNT(
            portal_composite_pixels,
            (uint16_t)(layer->row_right[row] - layer->row_left[row] + 1u)
        );

        column = layer->row_left[row];
        destination = &low_frame.data[low_row_offsets[row] + column];
        source = &portal_lod_frame[
            ((uint16_t)(row >> 1) * PORTAL_LOD_STRIDE) + (column >> 1)
        ];

        if ((column & 1u) != 0) {
            *destination++ = *source++;
            ++column;
        }
        while (column < layer->row_right[row]) {
            uint8_t color = *source++;

            *destination++ = color;
            *destination++ = color;
            column += 2u;
        }
        if (column <= layer->row_right[row]) {
            *destination = *source;
        }
    }
}

static __attribute__((unused)) void composite_portal_lod_quarter(
    const RenderLayer *layer
) {
    uint8_t row;

    for (row = layer->first_row; row <= layer->last_row; ++row) {
        uint8_t column;
        uint8_t phase;
        uint8_t *destination;
        const uint8_t *source;

        if (layer->row_left[row] > layer->row_right[row]) continue;
        RENDER_BENCHMARK_COUNT(
            portal_composite_pixels,
            (uint16_t)(layer->row_right[row] - layer->row_left[row] + 1u)
        );

        column = layer->row_left[row];
        destination = &low_frame.data[low_row_offsets[row] + column];
        source = &portal_lod_frame[
            ((uint16_t)(row >> 2) * PORTAL_LOD_STRIDE) + (column >> 2)
        ];
        phase = column & 3u;

        if (phase != 0) {
            uint8_t color = *source++;

            do {
                *destination++ = color;
                ++column;
                ++phase;
            } while (column <= layer->row_right[row] && phase < 4u);
        }
        while ((uint16_t)column + 3u <= layer->row_right[row]) {
            uint8_t color = *source++;

            *destination++ = color;
            *destination++ = color;
            *destination++ = color;
            *destination++ = color;
            column += 4u;
        }
        if (column <= layer->row_right[row]) {
            uint8_t color = *source;

            do {
                *destination++ = color;
                ++column;
            } while (column <= layer->row_right[row]);
        }
    }
}

static void composite_portal_lod(const RenderLayer *layer) {
    /* render_portal_lod is entered only for the two reduced-detail states. */
#if RENDER_WIDTH == 80 && !TRUE3D_BENCHMARK_COUNTERS
    if (layer->lod_shift == 1u) {
        composite_portal_lod_half_80(layer);
    } else {
        composite_portal_lod_80(layer, layer->lod_shift);
    }
#else
    if (layer->lod_shift == 1u) {
        composite_portal_lod_half(layer);
    } else {
        composite_portal_lod_quarter(layer);
    }
#endif
}

static __attribute__((always_inline)) inline CameraPoint body_camera_axis(
    const CameraPoint *world_axis,
    Vec3 axis
) {
    uint8_t selected = axis.x != 0 ? 0u : (axis.y != 0 ? 1u : 2u);
    fixed_t sign = axis.x != 0 ? axis.x : (axis.y != 0 ? axis.y : axis.z);
    CameraPoint result = world_axis[selected];

    if (sign < 0) {
        result.x = -result.x;
        result.y = -result.y;
        result.depth = -result.depth;
    }
    return result;
}

static void transform_body_vertices(
    const T3D3Body *body,
    CameraPoint center,
    const CameraPoint *world_axis
) {
    CameraPoint axis_x;
    CameraPoint axis_y;
    CameraPoint axis_z;
    CameraPoint twice_x;
    CameraPoint twice_y;
    CameraPoint twice_z;

    axis_x = body_camera_axis(world_axis, body->basis_x);
    axis_y = body_camera_axis(world_axis, body->basis_y);
    axis_z = body_camera_axis(world_axis, body->basis_z);
    twice_x = camera_point_add(axis_x, axis_x);
    twice_y = camera_point_add(axis_y, axis_y);
    twice_z = camera_point_add(axis_z, axis_z);

    camera_vertices[0] = (CameraPoint){
        center.x - axis_x.x - axis_y.x - axis_z.x,
        center.y - axis_x.y - axis_y.y - axis_z.y,
        center.depth - axis_x.depth - axis_y.depth - axis_z.depth
    };
    camera_vertices[1] = camera_point_add(camera_vertices[0], twice_x);
    camera_vertices[3] = camera_point_add(camera_vertices[0], twice_y);
    camera_vertices[2] = camera_point_add(camera_vertices[1], twice_y);
    camera_vertices[4] = camera_point_add(camera_vertices[0], twice_z);
    camera_vertices[5] = camera_point_add(camera_vertices[1], twice_z);
    camera_vertices[7] = camera_point_add(camera_vertices[3], twice_z);
    camera_vertices[6] = camera_point_add(camera_vertices[2], twice_z);
}

static uint8_t body_fast_projected_bounds(
    CameraPoint center,
    const CameraPoint *projected_extent,
    int16_t *first_column,
    int16_t *last_column,
    int16_t *first_row,
    int16_t *last_row
) {
    fixed_t minimum_depth = center.depth - projected_extent->depth;
    CameraPoint first;
    CameraPoint second;
    ScreenPoint projected_first;
    ScreenPoint projected_second;

    if (minimum_depth < NEAR_PLANE) return 0;
    first = (CameraPoint){
        center.x - projected_extent->x,
        center.y + projected_extent->y,
        minimum_depth
    };
    second = (CameraPoint){
        center.x + projected_extent->x,
        center.y - projected_extent->y,
        minimum_depth
    };
    {
        uint16_t scale = projection_scale_for_depth(minimum_depth);

        RENDER_BENCHMARK_COUNT(projected_points, 2u);
        project_camera_xy_pair_exact(
            &first,
            scale,
            &projected_first,
            active_render_shift,
            &second,
            &projected_second
        );
        scale_projected_resolution(&projected_first);
        scale_projected_resolution(&projected_second);
    }
    *first_column = ceil_q8(projected_first.x - FIXED_ONE / 2) - 1;
    *last_column = floor_q8(projected_second.x - 1 - FIXED_ONE / 2) + 1;
    *first_row = ceil_q8(projected_first.y - FIXED_ONE / 2) - 1;
    *last_row = floor_q8(projected_second.y - 1 - FIXED_ONE / 2) + 1;
    return (uint8_t)(
        *first_column <= *last_column && *first_row <= *last_row
    );
}

static Vec3 body_face_inward(
    const T3D3Body *body,
    uint8_t face_offset
) {
    Vec3 result;

    if (face_offset <= 1u) {
        result = body->basis_z;
    } else if (face_offset <= 3u) {
        result = body->basis_y;
    } else {
        result = body->basis_x;
    }
    if ((face_offset & 1u) != 0) {
        result.x = -result.x;
        result.y = -result.y;
        result.z = -result.z;
    }
    return result;
}

/* Room lighting is indexed by the inward normal of a wall. A body's visible
 * surface has the opposite (outward) normal, and its basis can be reoriented
 * by portal traversal. Convert that transformed normal back to a world-light
 * class instead of applying the room-face index directly. This keeps the top
 * bright, the underside dark, and both lateral viewing directions consistent. */
static uint8_t body_shading_face_offset(
    const T3D3Body *body,
    uint8_t face_offset
) {
    Vec3 inward = body_face_inward(body, face_offset);

    if (inward.z > 0) return 5u;  /* outward -Z: darkest */
    if (inward.z < 0) return 2u;  /* outward +Z: brightest */
    if (inward.y != 0) return 4u; /* world Y faces: middle shade */
    return 5u;                    /* world X faces: darkest wall shade */
}

static uint8_t body_projected_bounds(
    uint8_t vertex_mask,
    int16_t *first_column,
    int16_t *last_column,
    int16_t *first_row,
    int16_t *last_row
) {
    int24_t minimum_x;
    int24_t maximum_x;
    int24_t minimum_y;
    int24_t maximum_y;
    uint8_t corner;

    for (corner = 0; corner < 8u; ++corner) {
        if ((vertex_mask & vertex_mask_bit[corner]) != 0 &&
            !vertex_projectable[corner]) {
            return 0;
        }
    }
    corner = 0;
    while ((vertex_mask & vertex_mask_bit[corner]) == 0) ++corner;
    minimum_x = maximum_x = screen_vertices[corner].x;
    minimum_y = maximum_y = screen_vertices[corner].y;
    for (++corner; corner < 8u; ++corner) {
        if ((vertex_mask & vertex_mask_bit[corner]) == 0) continue;
        if (screen_vertices[corner].x < minimum_x) {
            minimum_x = screen_vertices[corner].x;
        }
        if (screen_vertices[corner].x > maximum_x) {
            maximum_x = screen_vertices[corner].x;
        }
        if (screen_vertices[corner].y < minimum_y) {
            minimum_y = screen_vertices[corner].y;
        }
        if (screen_vertices[corner].y > maximum_y) {
            maximum_y = screen_vertices[corner].y;
        }
    }
    *first_column = ceil_q8(minimum_x - FIXED_ONE / 2);
    *last_column = floor_q8(maximum_x - 1 - FIXED_ONE / 2);
    *first_row = ceil_q8(minimum_y - FIXED_ONE / 2);
    *last_row = floor_q8(maximum_y - 1 - FIXED_ONE / 2);
    return (uint8_t)(
        *first_column <= *last_column && *first_row <= *last_row
    );
}

static void render_body_flat_lod(
    const T3D3Body *body,
    const RenderLayer *layer,
    int16_t first_column,
    int16_t last_column,
    int16_t first_row,
    int16_t last_row
) {
    uint8_t base_color = (uint8_t)(
        SHADED_PALETTE_FIRST + (body->color << 2)
    );
    int16_t clipped_first_row_value = first_row;
    int16_t clipped_last_row_value = last_row;
    uint8_t clipped_first_column;
    uint8_t clipped_last_column;
    uint8_t clipped_first_row;
    uint8_t clipped_last_row;
    uint8_t row;

    if (clipped_first_row_value < layer->first_row) {
        clipped_first_row_value = layer->first_row;
    }
    if (clipped_last_row_value > layer->last_row) {
        clipped_last_row_value = layer->last_row;
    }
    if (clipped_first_row_value < 0) clipped_first_row_value = 0;
    if (clipped_last_row_value >= active_render_height) {
        clipped_last_row_value = active_render_height - 1;
    }
    if (clipped_first_row_value > clipped_last_row_value ||
        last_column < 0 || first_column >= active_render_width ||
        last_column < layer->bound_left ||
        first_column > layer->bound_right) {
        return;
    }
    if (first_column < 0) first_column = 0;
    if (last_column >= active_render_width) {
        last_column = active_render_width - 1;
    }
    if (first_column < layer->bound_left) first_column = layer->bound_left;
    if (last_column > layer->bound_right) last_column = layer->bound_right;
    clipped_first_column = (uint8_t)first_column;
    clipped_last_column = (uint8_t)last_column;
    clipped_first_row = (uint8_t)clipped_first_row_value;
    clipped_last_row = (uint8_t)clipped_last_row_value;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);
    if (layer->lod_shift == 0) {
        int16_t light_last = first_row + ((last_row - first_row + 1) >> 2);
        uint8_t has_light_rows = (uint8_t)(light_last >= clipped_first_row);
        uint8_t light_last_row = light_last >= clipped_last_row ?
            clipped_last_row : (uint8_t)light_last;

        RENDER_BENCHMARK_COUNT(
            raster_rows,
            (uint16_t)(clipped_last_row - clipped_first_row + 1)
        );
#if RENDER_WIDTH == 80 && !TRUE3D_BENCHMARK_COUNTERS
        raster_flat_body_80(
            layer,
            clipped_first_column,
            clipped_last_column,
            clipped_first_row,
            clipped_last_row,
            light_last_row,
            has_light_rows,
            base_color
        );
#else
        for (row = clipped_first_row; row <= clipped_last_row; ++row) {
            uint8_t left = clipped_first_column;
            uint8_t right = clipped_last_column;
            uint8_t color = has_light_rows && row <= light_last_row ?
                (uint8_t)(base_color + 3u) : (uint8_t)(base_color + 2u);

            if (left < layer->row_left[row]) left = layer->row_left[row];
            if (right > layer->row_right[row]) right = layer->row_right[row];
            if (left > right) continue;
            write_small_frame_span(row, left, right, color);
        }
#endif
    } else {
        uint8_t shift = layer->lod_shift;
        uint8_t step = (uint8_t)(1u << shift);
        uint8_t sample_origin = step >> 1;
        int16_t sample_first_value;
        int16_t sample_last_value;
        uint8_t sample_first;
        uint8_t sample_last;

        sample_first_value = sample_origin +
            (((clipped_first_row - sample_origin + step - 1u) >> shift) << shift);
        sample_last_value = sample_origin +
            (((clipped_last_row - sample_origin) >> shift) << shift);
        if (sample_first_value > sample_last_value || sample_last_value < 0) return;
        sample_first = (uint8_t)sample_first_value;
        sample_last = (uint8_t)sample_last_value;
        RENDER_BENCHMARK_COUNT(
            raster_rows,
            (uint16_t)(((sample_last - sample_first) >> shift) + 1)
        );
        for (row = sample_first; row <= sample_last; row += step) {
            uint8_t left = clipped_first_column;
            uint8_t right = clipped_last_column;
            uint8_t target_first;
            uint8_t target_last;
            uint8_t target_row;
            uint8_t target_width;
            uint8_t color;

            if (left < layer->row_left[row]) left = layer->row_left[row];
            if (right > layer->row_right[row]) right = layer->row_right[row];
            if (left > right || right < sample_origin) continue;
            target_first = left <= sample_origin ? 0u :
                (uint8_t)((left - sample_origin + step - 1u) >> shift);
            target_last = (uint8_t)((right - sample_origin) >> shift);
            target_row = (uint8_t)row >> shift;
            target_width = (uint8_t)(target_last - target_first + 1u);
            color = target_row <= (uint8_t)(first_row >> shift) ?
                (uint8_t)(base_color + 3u) : (uint8_t)(base_color + 2u);
            RENDER_BENCHMARK_COUNT(filled_spans, 1u);
            RENDER_BENCHMARK_COUNT(filled_pixels, target_width);
            {
                uint8_t *destination = &portal_lod_frame[
                    (uint16_t)target_row * PORTAL_LOD_STRIDE + target_first
                ];

                do {
                    *destination++ = color;
                } while (--target_width != 0);
            }
        }
    }
}

static void render_body(
    const T3D3Body *body,
    const Camera *camera,
    CameraPoint center,
    const CameraPoint *world_axis,
    const CameraPoint *projected_extent,
    RenderLayer *layer,
    fixed_t flat_lod_depth
) {
    Vec3 camera_relative;
    int16_t first_column;
    int16_t last_column;
    int16_t first_row;
    int16_t last_row;
    uint8_t visible_face[3];
    uint8_t visible_count = 0;
    uint8_t visible_index;
    uint8_t visible_vertex_mask = 0;
    if ((layer->lod_shift != 0 || center.depth >= flat_lod_depth) &&
        body_fast_projected_bounds(
            center,
            projected_extent,
            &first_column,
            &last_column,
            &first_row,
            &last_row
        )) {
        render_body_flat_lod(
            body,
            layer,
            first_column,
            last_column,
            first_row,
            last_row
        );
        return;
    }
    camera_relative = vec_subtract(camera->position, body->position);
    {
        fixed_t local_z = signed_axis_component(camera_relative, body->basis_z);
        fixed_t local_y = signed_axis_component(camera_relative, body->basis_y);
        fixed_t local_x = signed_axis_component(camera_relative, body->basis_x);
        if (local_z < 0) visible_face[visible_count++] = 0u;
        else if (local_z > 0) visible_face[visible_count++] = 1u;
        if (local_y < 0) visible_face[visible_count++] = 2u;
        else if (local_y > 0) visible_face[visible_count++] = 3u;
        if (local_x < 0) visible_face[visible_count++] = 4u;
        else if (local_x > 0) visible_face[visible_count++] = 5u;
    }
    for (visible_index = 0; visible_index < visible_count; ++visible_index) {
        visible_vertex_mask |= box_face_vertex_mask[visible_face[visible_index]];
    }
    if (visible_vertex_mask == 0) return;
    transform_body_vertices(body, center, world_axis);
    RENDER_BENCHMARK_COUNT(transformed_vertices, 8u);
    project_cached_box_vertices(visible_vertex_mask);
    if (layer != &render_layers[0]) {
        if (body_projected_bounds(
                visible_vertex_mask,
                &first_column,
                &last_column,
                &first_row,
                &last_row
            ) &&
            (last_column < layer->bound_left ||
             first_column > layer->bound_right ||
             last_row < layer->first_row || first_row > layer->last_row)) {
            return;
        }
    }
    for (visible_index = 0; visible_index < visible_count; ++visible_index) {
        uint8_t face_offset = visible_face[visible_index];
        DrawPolygon *polygon = &layer->polygon[0];
        uint8_t index;
        uint8_t inside_count = 0;

        for (index = 0; index < 4u; ++index) {
            uint8_t vertex = box_face_vertices[face_offset][index];

            if (vertex_projectable[vertex]) {
                polygon->point[index] = screen_vertices[vertex];
                ++inside_count;
            }
        }
        if (inside_count == 0) continue;
        if (inside_count == 4u) {
            polygon->count = 4u;
        } else if (!clip_cached_face_and_project(face_offset, polygon)) {
            continue;
        }
        if (!polygon_intersects_layer(polygon, layer)) continue;
        polygon->color = (uint8_t)(
            SHADED_PALETTE_FIRST + (body->color << 2)
        );
        polygon->portal = NO_PORTAL;
        polygon->face = NO_PORTAL;
        polygon->face_offset = body_shading_face_offset(body, face_offset);
        if (layer->lod_shift == 0) {
            rasterize_fill_polygon_full(polygon, layer);
        } else {
            rasterize_fill_polygon_lod(polygon, layer);
        }
    }
}

static void render_bodies(const Camera *camera, RenderLayer *layer) {
    uint8_t order[T3D3_MAX_BODIES];
    fixed_t depth[T3D3_MAX_BODIES];
    CameraPoint body_center[T3D3_MAX_BODIES];
    CameraPoint cached_world_axis[3];
    CameraPoint cached_projected_extent;
    fixed_t cached_axis_extent = -1;
    fixed_t flat_lod_depth = BODY_FLAT_LOD_DEPTH;
    uint8_t count = 0;
    uint8_t index;

    if (active_body_count == 0) return;
    /* The two-portal/four-body view is the renderer's pathological case: all
     * four root cubes are scan-converted again inside a destination view.
     * Preserve exact faces for held/very-near bodies, but use the established
     * box-silhouette LOD sooner for the rest of this one dense layout. */
    if (active_body_count >= T3D3_MAX_BODIES &&
        layer == &render_layers[0] && layer->count == PORTAL_COUNT) {
        flat_lod_depth = BODY_DENSE_PORTAL_FLAT_LOD_DEPTH;
    }
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        CameraPoint transformed_center;
        uint8_t insert;

        if (!bodies[index].active || bodies[index].room != camera->room) continue;
        transformed_center = transform_point(camera, bodies[index].position);
        /* At an oblique yaw/pitch, a cube's camera-depth radius is the sum of
         * all three projected half-axes (up to sqrt(3) * half_extent), not one
         * half_extent.  Two extents is a cheap conservative bound and avoids
         * dropping a cube while some of its corners still cross the near
         * plane.  The exact extent is computed below for surviving bodies. */
        if (transformed_center.depth +
                (fixed_t)(bodies[index].half_extent << 1) < NEAR_PLANE) {
            continue;
        }
        insert = count;
        while (insert != 0 &&
               depth[insert - 1u] < transformed_center.depth) {
            order[insert] = order[insert - 1u];
            depth[insert] = depth[insert - 1u];
            --insert;
        }
        order[insert] = index;
        depth[insert] = transformed_center.depth;
        body_center[index] = transformed_center;
        ++count;
    }
    for (index = 0; index < count; ++index) {
        const T3D3Body *body = &bodies[order[index]];

        /* Most scenes use one cube size. Camera-space box axes depend on the
         * camera and extent, not on the body's signed-axis portal basis, so
         * all equal-sized cubes in this camera share the expensive scale. */
        if (body->half_extent != cached_axis_extent) {
            cached_axis_extent = body->half_extent;
            scale_camera_room_edges_exact(
                camera,
                cached_axis_extent,
                cached_axis_extent,
                cached_axis_extent,
                cached_world_axis
            );
            cached_projected_extent.x =
                fixed_absolute(cached_world_axis[0].x) +
                fixed_absolute(cached_world_axis[1].x) +
                fixed_absolute(cached_world_axis[2].x);
            cached_projected_extent.y =
                fixed_absolute(cached_world_axis[0].y) +
                fixed_absolute(cached_world_axis[1].y) +
                fixed_absolute(cached_world_axis[2].y);
            cached_projected_extent.depth =
                fixed_absolute(cached_world_axis[0].depth) +
                fixed_absolute(cached_world_axis[1].depth) +
                fixed_absolute(cached_world_axis[2].depth);
        }
        render_body(
            body,
            camera,
            body_center[order[index]],
            cached_world_axis,
            &cached_projected_extent,
            layer,
            flat_lod_depth
        );
    }
}

#if T3D3_STATIC_BOX_LIMIT > 0
/* Static cabin scenery uses the same clipped six-face polygon path as dynamic
 * cubes, but permits independent dimensions and never enters collision or
 * portal physics.  Painter order is far-to-near because these fixtures are
 * all contained by the convex room shell. */
static uint8_t static_box_camera_bounds_visible(
    const CameraPoint *center,
    const CameraPoint *extent
) {
    fixed_t maximum_depth = center->depth + extent->depth;
    fixed_t minimum_x;
    fixed_t maximum_x;
    fixed_t minimum_y;
    fixed_t maximum_y;

    if (maximum_depth < NEAR_PLANE) return 0u;
    minimum_x = center->x - extent->x;
    maximum_x = center->x + extent->x;
    minimum_y = center->y - extent->y;
    maximum_y = center->y + extent->y;
    if ((int32_t)PROJECTION_FOCAL * maximum_x +
            (int32_t)ROOM_CULL_HALF_WIDTH * maximum_depth < 0) {
        return 0u;
    }
    if ((int32_t)PROJECTION_FOCAL * minimum_x -
            (int32_t)ROOM_CULL_HALF_WIDTH * maximum_depth >= 0) {
        return 0u;
    }
    if ((int32_t)PROJECTION_FOCAL * minimum_y -
            (int32_t)ROOM_CULL_HALF_HEIGHT * maximum_depth > 0) {
        return 0u;
    }
    if (-(int32_t)PROJECTION_FOCAL * maximum_y -
            (int32_t)ROOM_CULL_HALF_HEIGHT * maximum_depth >= 0) {
        return 0u;
    }
    return 1u;
}

static void render_static_boxes(const Camera *camera, RenderLayer *layer) {
    uint8_t count = 0u;
    uint8_t index;

    for (index = 0u; index < static_box_count; ++index) {
        const StaticBox *box = &static_boxes[index];
        uint8_t insert;

        if (box->render_body.room != camera->room) continue;
        static_box_center[index] = transform_point(camera, box->render_body.position);
        scale_camera_room_edges_exact(
            camera,
            box->half_extents.x,
            box->half_extents.y,
            box->half_extents.z,
            static_box_world_axis[index]
        );
        static_box_projected_extent[index].x =
            fixed_absolute(static_box_world_axis[index][0].x) +
            fixed_absolute(static_box_world_axis[index][1].x) +
            fixed_absolute(static_box_world_axis[index][2].x);
        static_box_projected_extent[index].y =
            fixed_absolute(static_box_world_axis[index][0].y) +
            fixed_absolute(static_box_world_axis[index][1].y) +
            fixed_absolute(static_box_world_axis[index][2].y);
        static_box_projected_extent[index].depth =
            fixed_absolute(static_box_world_axis[index][0].depth) +
            fixed_absolute(static_box_world_axis[index][1].depth) +
            fixed_absolute(static_box_world_axis[index][2].depth);
        if (!static_box_camera_bounds_visible(
                &static_box_center[index],
                &static_box_projected_extent[index]
            )) {
            continue;
        }
        insert = count;
        while (insert != 0u &&
               static_box_depth[insert - 1u] < static_box_center[index].depth) {
            static_box_order[insert] = static_box_order[insert - 1u];
            static_box_depth[insert] = static_box_depth[insert - 1u];
            --insert;
        }
        static_box_order[insert] = index;
        static_box_depth[insert] = static_box_center[index].depth;
        ++count;
    }

    for (index = 0u; index < count; ++index) {
        uint8_t box_index = static_box_order[index];
        const StaticBox *box = &static_boxes[box_index];

        render_body(
            &box->render_body,
            camera,
            static_box_center[box_index],
            static_box_world_axis[box_index],
            &static_box_projected_extent[box_index],
            layer,
            BODY_FLAT_LOD_DEPTH
        );
    }
}
#endif

static void render_scene_objects(const Camera *camera, RenderLayer *layer) {
    render_bodies(camera, layer);
#if T3D3_STATIC_BOX_LIMIT > 0
    render_static_boxes(camera, layer);
#endif
}

static void render_room_faces_immediate(
    const Camera *camera,
    RenderLayer *layer,
    uint8_t skipped_face,
    uint8_t lod
) {
    const Room *room = &rooms[camera->room];
    uint8_t offset;

    if (!prepare_room_geometry(layer, camera, 0)) {
        layer->count = 0;
        layer->solid_count = 0;
        return;
    }
    for (offset = 0; offset < ROOM_FACE_COUNT; ++offset) {
        uint8_t face_index = room->first_face + offset;
        DrawPolygon *polygon = &layer->polygon[0];

        if (face_index == skipped_face) continue;
        if (!prepare_face_polygon(layer, face_index, offset, polygon)) continue;
        if (lod != 0) {
            rasterize_fill_polygon_lod(polygon, layer);
        } else {
            rasterize_fill_polygon_full(polygon, layer);
        }
    }
    render_scene_objects(camera, layer);
    layer->count = 0;
    layer->solid_count = 0;
}

static void render_portal_lod_scratch(
    const Camera *camera,
    RenderLayer *layer,
    uint8_t skipped_face
) {
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_FILL);
    clear_portal_lod(layer);
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_GEOMETRY);
    render_room_faces_immediate(camera, layer, skipped_face, 1);
}

static void render_portal_lod(
    const Camera *camera,
    RenderLayer *layer,
    uint8_t skipped_face
) {
    render_portal_lod_scratch(camera, layer, skipped_face);
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_FILL);
    composite_portal_lod(layer);
}

static void render_camera(
    const Camera *camera,
    uint8_t depth,
    uint8_t skipped_face,
    uint8_t allow_room_cull
);

static uint8_t camera_exactly_equal(const Camera *first, const Camera *second) {
    return (uint8_t)(
        first->position.x == second->position.x &&
        first->position.y == second->position.y &&
        first->position.z == second->position.z &&
        first->right.x == second->right.x &&
        first->right.y == second->right.y &&
        first->right.z == second->right.z &&
        first->up.x == second->up.x &&
        first->up.y == second->up.y &&
        first->up.z == second->up.z &&
        first->forward.x == second->forward.x &&
        first->forward.y == second->forward.y &&
        first->forward.z == second->forward.z &&
        first->room == second->room
    );
}

static uint8_t portal_pair_has_shared_transform(
    const DrawPolygon *first,
    const DrawPolygon *second
) {
    const Portal *first_portal;
    const Portal *second_portal;
    Vec3 center_delta;

    if (first->portal >= PORTAL_COUNT || second->portal >= PORTAL_COUNT ||
        first->portal == second->portal) {
        return 0;
    }
    first_portal = &portals[first->portal];
    second_portal = &portals[second->portal];
    if (first_portal->linked != second->portal ||
        second_portal->linked != first->portal ||
        first_portal->room != second_portal->room ||
        first_portal->host_face != second_portal->host_face ||
        first_portal->right.x != second_portal->right.x ||
        first_portal->right.y != second_portal->right.y ||
        first_portal->right.z != second_portal->right.z ||
        first_portal->up.x != second_portal->up.x ||
        first_portal->up.y != second_portal->up.y ||
        first_portal->up.z != second_portal->up.z ||
        first_portal->normal.x != second_portal->normal.x ||
        first_portal->normal.y != second_portal->normal.y ||
        first_portal->normal.z != second_portal->normal.z) {
        return 0;
    }
    center_delta = vec_subtract(second_portal->center, first_portal->center);
    return signed_axis_component(center_delta, first_portal->up) == 0;
}

static void capture_portal_clip(
    PortalClipSnapshot *snapshot,
    const RenderLayer *layer
) {
    uint8_t row;

    snapshot->first_row = layer->first_row;
    snapshot->last_row = layer->last_row;
    snapshot->bound_left = layer->bound_left;
    snapshot->bound_right = layer->bound_right;
    snapshot->lod_shift = layer->lod_shift;
    snapshot->pixel_area = layer->pixel_area;
    for (row = layer->first_row; row <= layer->last_row; ++row) {
        snapshot->row_left[row] = layer->row_left[row];
        snapshot->row_right[row] = layer->row_right[row];
    }
}

static void restore_portal_clip(
    RenderLayer *layer,
    const PortalClipSnapshot *snapshot
) {
    uint8_t row;

    layer->first_row = snapshot->first_row;
    layer->last_row = snapshot->last_row;
    layer->bound_left = snapshot->bound_left;
    layer->bound_right = snapshot->bound_right;
    layer->lod_shift = snapshot->lod_shift;
    layer->pixel_area = snapshot->pixel_area;
    for (row = snapshot->first_row; row <= snapshot->last_row; ++row) {
        layer->row_left[row] = snapshot->row_left[row];
        layer->row_right[row] = snapshot->row_right[row];
    }
}

static void build_shared_portal_union(RenderLayer *layer) {
    uint8_t row;

    layer->first_row = shared_portal_clip[0].first_row <
            shared_portal_clip[1].first_row ?
        shared_portal_clip[0].first_row : shared_portal_clip[1].first_row;
    layer->last_row = shared_portal_clip[0].last_row >
            shared_portal_clip[1].last_row ?
        shared_portal_clip[0].last_row : shared_portal_clip[1].last_row;
    layer->bound_left = active_render_width;
    layer->bound_right = 0u;
    layer->pixel_area = 0u;
    layer->lod_shift = shared_portal_clip[0].lod_shift;
    for (row = layer->first_row; row <= layer->last_row; ++row) {
        uint8_t first_valid = (uint8_t)(
            row >= shared_portal_clip[0].first_row &&
            row <= shared_portal_clip[0].last_row &&
            shared_portal_clip[0].row_left[row] <=
                shared_portal_clip[0].row_right[row]
        );
        uint8_t second_valid = (uint8_t)(
            row >= shared_portal_clip[1].first_row &&
            row <= shared_portal_clip[1].last_row &&
            shared_portal_clip[1].row_left[row] <=
                shared_portal_clip[1].row_right[row]
        );
        uint8_t left;
        uint8_t right;

        if (!first_valid && !second_valid) {
            layer->row_left[row] = 255u;
            layer->row_right[row] = 0u;
            continue;
        }
        if (!second_valid || (first_valid &&
                shared_portal_clip[0].row_left[row] <
                    shared_portal_clip[1].row_left[row])) {
            left = shared_portal_clip[0].row_left[row];
        } else {
            left = shared_portal_clip[1].row_left[row];
        }
        if (!second_valid || (first_valid &&
                shared_portal_clip[0].row_right[row] >
                    shared_portal_clip[1].row_right[row])) {
            right = shared_portal_clip[0].row_right[row];
        } else {
            right = shared_portal_clip[1].row_right[row];
        }
        layer->row_left[row] = left;
        layer->row_right[row] = right;
        layer->pixel_area += (uint16_t)(right - left + 1u);
        if (left < layer->bound_left) layer->bound_left = left;
        if (right > layer->bound_right) layer->bound_right = right;
    }
}

/* A symmetric, coplanar portal pair can map both apertures to the exact same
 * destination camera.  Reduced-detail rendering already uses a scratch
 * buffer, so render that camera once over the union clip, then composite it
 * through the two saved aperture masks.  Full-detail children write directly
 * into the root frame and therefore retain the ordinary two-pass path. */
static uint8_t render_shared_reduced_portal_pair(
    const Camera *camera,
    RenderLayer *parent,
    uint8_t depth
) {
    RenderLayer *child;
    Camera destination[PORTAL_COUNT];
    uint8_t destination_face[PORTAL_COUNT];
    uint8_t index;

    if (depth >= PORTAL_RECURSION_LIMIT || parent->count != PORTAL_COUNT) {
        return 0;
    }
    if (!portal_pair_has_shared_transform(
            &parent->polygon[0],
            &parent->polygon[1]
        )) {
        return 0;
    }
    /* Avoid duplicate clip setup on the ordinary full-detail path.  A portal
     * that has just crossed into reduced LOD becomes shareable next frame. */
    if (portal_lod_state[parent->polygon[0].portal] == 0u ||
        portal_lod_state[parent->polygon[1].portal] == 0u) {
        return 0;
    }
    child = &render_layers[depth + 1u];
    for (index = 0; index < PORTAL_COUNT; ++index) {
        const DrawPolygon *polygon = &parent->polygon[index];

        destination[index] = transform_portal_camera(polygon->portal, camera);
        destination_face[index] =
            portals[portals[polygon->portal].linked].host_face;
    }
    if (destination_face[0] != destination_face[1] ||
        !camera_exactly_equal(&destination[0], &destination[1])) {
        return 0;
    }
    for (index = 0; index < PORTAL_COUNT; ++index) {
        if (!build_portal_clip(&parent->polygon[index], parent, child)) return 0;
        capture_portal_clip(&shared_portal_clip[index], child);
    }
    if (shared_portal_clip[0].lod_shift == 0u ||
        shared_portal_clip[0].lod_shift != shared_portal_clip[1].lod_shift) {
        return 0;
    }

    build_shared_portal_union(child);
    render_portal_lod_scratch(&destination[0], child, destination_face[0]);
    for (index = 0; index < PORTAL_COUNT; ++index) {
        restore_portal_clip(child, &shared_portal_clip[index]);
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_FILL);
        composite_portal_lod(child);
        draw_portal_outline(child, parent->polygon[index].color);
    }
    return 1;
}

/* When a nearby portal covers every root pixel, none of the source room's
 * six wall polygons can contribute to the image. Detect that exact case from
 * the aperture itself and render only the destination camera. */
static uint8_t render_fullscreen_portal(
    const Camera *camera,
    uint8_t allow_room_cull
) {
    const Room *room = &rooms[camera->room];
    RenderLayer *root = &render_layers[0];
    RenderLayer *child = &render_layers[1];
    uint8_t portal_index;
    uint8_t candidate = NO_PORTAL;

    /* The exterior shell is opaque. In noclip, neither a portal on its far
     * side nor its destination may replace the shell before root rendering. */
    if (allow_room_cull && camera_is_outside_room(camera, room)) return 0;

    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const Portal *portal = &portals[portal_index];
        Vec3 relative;
        fixed_t plane_distance;
        CameraPoint center;

        if (!portal->active || !portals[portal->linked].active ||
            portal->room != camera->room || portal->host_face < room->first_face ||
            portal->host_face >= room->first_face + ROOM_FACE_COUNT) {
            continue;
        }
        relative = vec_subtract(portal->center, camera->position);
        plane_distance = fixed_absolute(
            signed_axis_component(relative, portal->normal)
        );
        /* Below 1.25 world units the fixed-size aperture can cover the
         * complete viewport; the exact clip test below remains authoritative. */
        if (plane_distance > (5 * FIXED_ONE) / 4) continue;
        center = transform_point(camera, portal->center);
        if (center.depth < NEAR_PLANE) continue;
        if (candidate != NO_PORTAL) return 0;
        candidate = portal_index;
    }
    if (candidate == NO_PORTAL) return 0;

    root->count = 0;
    append_portal_polygon(root, camera, candidate);
    if (root->count != 1u ||
        !build_portal_clip(&root->polygon[0], root, child) ||
        child->pixel_area != root->pixel_area) {
        return 0;
    }
    {
        Camera destination = transform_portal_camera(candidate, camera);
        uint8_t destination_face = portals[portals[candidate].linked].host_face;

        memset(
            low_frame.data,
            COLOR_VOID,
            (uint16_t)active_render_width * active_render_height
        );
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_GEOMETRY);
        if (child->lod_shift == 0) {
            render_camera(&destination, 1u, destination_face, 0);
        } else {
            render_portal_lod(&destination, child, destination_face);
        }
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_FILL);
        draw_portal_outline(child, root->polygon[0].color);
    }
    return 1;
}

static void render_camera(
    const Camera *camera,
    uint8_t depth,
    uint8_t skipped_face,
    uint8_t allow_room_cull
) {
    RenderLayer *layer = &render_layers[depth];
    const Room *room = &rooms[camera->room];
    uint8_t face_visible[ROOM_FACE_COUNT] = {0, 0, 0, 0, 0, 0};
    uint8_t exterior_face_mask;
    uint8_t exterior_view;
    uint8_t index;

    if (depth != 0) {
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_GEOMETRY);
        render_room_faces_immediate(camera, layer, skipped_face, 0);
        return;
    }

    /* Draw the convex root shell immediately. Portal destinations are
     * composited afterwards and replace their host pixels exactly. */
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_ROOT_FILL);
    clear_render_layer(layer, depth);
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_ROOT_GEOMETRY);
    layer->count = 0;
    layer->solid_count = 0;
    if (!prepare_room_geometry(layer, camera, allow_room_cull)) return;
    exterior_view = (uint8_t)(
        allow_room_cull && camera_is_outside_room(camera, room)
    );
    exterior_face_mask = room_exterior_face_mask(camera, room, allow_room_cull);
    for (index = 0; index < ROOM_FACE_COUNT; ++index) {
        uint8_t face_index = room->first_face + index;
        DrawPolygon *polygon = &layer->polygon[0];

        if ((exterior_face_mask & (1u << index)) == 0) continue;
        if (face_index == skipped_face) continue;
        if (!prepare_face_polygon(layer, face_index, index, polygon)) continue;
        face_visible[index] = 1;
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_ROOT_FILL);
        rasterize_fill_polygon_full(polygon, layer);
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_ROOT_GEOMETRY);
        if (index <= 1u) {
            draw_surface_depth_seams(camera, layer, polygon, index);
        }
    }
    for (index = 0; !exterior_view && index < PORTAL_COUNT; ++index) {
        const Portal *portal = &portals[index];
        uint8_t host_offset;

        if (!portal->active || !portals[portal->linked].active ||
            portal->room != camera->room ||
            portal->host_face < room->first_face) {
            continue;
        }
        host_offset = portal->host_face - room->first_face;
        if (host_offset < ROOM_FACE_COUNT && face_visible[host_offset]) {
            append_portal_polygon(layer, camera, index);
        }
    }
    layer->solid_count = 0;
    if (depth < PORTAL_RECURSION_LIMIT) {
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_SETUP);
        if (!render_shared_reduced_portal_pair(camera, layer, depth)) {
            for (index = layer->solid_count; index < layer->count; ++index) {
                DrawPolygon *polygon = &layer->polygon[index];
                RenderLayer *child = &render_layers[depth + 1];
                Camera destination;
                uint8_t destination_face;

                RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_SETUP);
                if (!build_portal_clip(polygon, layer, child)) continue;
                destination = transform_portal_camera(polygon->portal, camera);
                destination_face = portals[portals[polygon->portal].linked].host_face;
                if (child->lod_shift == 0) {
                    render_camera(&destination, depth + 1, destination_face, 0);
                } else {
                    render_portal_lod(&destination, child, destination_face);
                }
                RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PORTAL_FILL);
                draw_portal_outline(child, polygon->color);
            }
        }
    }
    if (!exterior_view) {
        /* Portal rendering leaves the phase timer in PORTAL_FILL. Attribute
         * root-body projection and rasterization to root geometry explicitly
         * so portal composition is not blamed for the four-cube cost. */
        RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_ROOT_GEOMETRY);
        render_scene_objects(camera, layer);
    }
}

static void recover_camera_angles(EngineState *state) {
    uint8_t pitch_low = 0;
    uint8_t pitch_high = PITCH_LIMIT;
    uint8_t best_pitch;
    fixed_t vertical = fixed_absolute(state->forward.z);
    fixed_t best_pitch_error;
    uint16_t angle;
    uint8_t best_yaw = state->yaw;
    int32_t best_yaw_score = INT32_MIN;
    uint8_t heading_source;
    fixed_t heading_x;
    fixed_t heading_y;
    uint16_t first_angle;
    uint16_t last_angle;

    /* quarter_sine is monotonic. Find its lower bound, then compare the one
     * preceding sample. Walking back over a plateau preserves the exhaustive
     * search's earliest-index tie rule exactly. */
    while (pitch_low < pitch_high) {
        uint8_t middle = (uint8_t)((pitch_low + pitch_high) >> 1);

        if (quarter_sine[middle] < vertical) {
            pitch_low = (uint8_t)(middle + 1u);
        } else {
            pitch_high = middle;
        }
    }
    best_pitch = pitch_low;
    best_pitch_error = fixed_absolute(vertical - quarter_sine[best_pitch]);
    if (best_pitch != 0) {
        fixed_t previous_error = fixed_absolute(
            vertical - quarter_sine[best_pitch - 1u]
        );

        if (previous_error <= best_pitch_error) {
            --best_pitch;
        }
    }
    while (best_pitch != 0 &&
           quarter_sine[best_pitch - 1u] == quarter_sine[best_pitch]) {
        --best_pitch;
    }
    state->pitch = state->forward.z < 0 ? -(int8_t)best_pitch : (int8_t)best_pitch;

    if (fixed_absolute(state->forward.x) + fixed_absolute(state->forward.y) > 8) {
        heading_source = 0;
    } else if (fixed_absolute(state->right.x) + fixed_absolute(state->right.y) > 8) {
        heading_source = 1;
    } else {
        heading_source = 2;
    }

    if (heading_source == 0) {
        heading_x = state->forward.x;
        heading_y = state->forward.y;
    } else if (heading_source == 1) {
        heading_x = state->right.y;
        heading_y = -state->right.x;
    } else if (state->pitch > 0) {
        heading_x = -state->up.x;
        heading_y = -state->up.y;
    } else {
        heading_x = state->up.x;
        heading_y = state->up.y;
    }

    /* A dot product with a nonzero heading reaches its maximum in the same
     * quadrant. Include the two preceding samples because the Q8 sine table's
     * cardinal values have three-entry plateaus; this preserves the exhaustive
     * search's earliest-angle tie rule. In the wrapped fourth quadrant, test
     * angle zero first because the old exhaustive loop did. */
    if (heading_y >= 0) {
        if (heading_x >= 0) {
            first_angle = 0;
            last_angle = 64;
        } else {
            first_angle = 62;
            last_angle = 128;
        }
    } else if (heading_x < 0) {
        first_angle = 126;
        last_angle = 192;
    } else {
        int32_t zero_score = (int32_t)heading_x * quarter_sine[64];

        best_yaw = 0;
        best_yaw_score = zero_score;
        first_angle = 190;
        last_angle = 255;
    }

    for (angle = first_angle; angle <= last_angle; ++angle) {
        fixed_t sine = angle_sine((uint8_t)angle);
        fixed_t cosine = angle_sine((uint8_t)(angle + 64u));
        int32_t score = (int32_t)heading_x * cosine +
            (int32_t)heading_y * sine;

        if (score > best_yaw_score) {
            best_yaw_score = score;
            best_yaw = (uint8_t)angle;
        }
    }
    state->yaw = best_yaw;
    rebuild_camera_basis(state);
}

static Vec3 horizontal_forward(const EngineState *state) {
    Vec3 direction = {state->right.y, -state->right.x, 0};
    return direction;
}

static fixed_t clamp_fixed(fixed_t value, fixed_t minimum, fixed_t maximum) {
    if (value < minimum) return minimum;
    if (value > maximum) return maximum;
    return value;
}

static uint8_t point_inside_room_face(const Room *room, Vec3 point) {
    return (uint8_t)(
        point.x >= room->minimum_x && point.x <= room->maximum_x &&
        point.y >= room->minimum_y && point.y <= room->maximum_y &&
        point.z >= room->minimum_z && point.z <= room->maximum_z
    );
}

static uint8_t room_face_holds_portal(const Room *room, uint8_t face_offset) {
    fixed_t width;
    fixed_t height;

    if (face_offset <= 1) {
        width = room->maximum_x - room->minimum_x;
        height = room->maximum_y - room->minimum_y;
    } else if (face_offset <= 3) {
        width = room->maximum_x - room->minimum_x;
        height = room->maximum_z - room->minimum_z;
    } else {
        width = room->maximum_y - room->minimum_y;
        height = room->maximum_z - room->minimum_z;
    }
    return (uint8_t)(
        width >= 2 * PORTAL_HALF_WIDTH &&
        height >= 2 * PORTAL_HALF_HEIGHT
    );
}

static void configure_portal_on_face(
    uint8_t portal_index,
    uint8_t room_index,
    uint8_t face_offset,
    Vec3 center
) {
    const Room *room;

    if (portal_index >= PORTAL_COUNT || room_index >= room_count ||
        face_offset >= ROOM_FACE_COUNT) {
        return;
    }
    room = &rooms[room_index];
    portals[portal_index].room = room_index;
    portals[portal_index].host_face = room->first_face + face_offset;
    portals[portal_index].normal = face_normals[face_offset];
    portals[portal_index].right = face_right_vectors[face_offset];
    portals[portal_index].up = face_up_vectors[face_offset];
    portals[portal_index].active = 1;

    if (face_offset <= 1) {
        center.x = clamp_fixed(
            center.x,
            room->minimum_x + portals[portal_index].half_width,
            room->maximum_x - portals[portal_index].half_width
        );
        center.y = clamp_fixed(
            center.y,
            room->minimum_y + portals[portal_index].half_height,
            room->maximum_y - portals[portal_index].half_height
        );
        center.z = face_offset == 0 ? room->minimum_z : room->maximum_z;
    } else if (face_offset <= 3) {
        center.x = clamp_fixed(
            center.x,
            room->minimum_x + portals[portal_index].half_width,
            room->maximum_x - portals[portal_index].half_width
        );
        center.z = clamp_fixed(
            center.z,
            room->minimum_z + portals[portal_index].half_height,
            room->maximum_z - portals[portal_index].half_height
        );
        center.y = face_offset == 2 ? room->minimum_y : room->maximum_y;
    } else {
        center.y = clamp_fixed(
            center.y,
            room->minimum_y + portals[portal_index].half_width,
            room->maximum_y - portals[portal_index].half_width
        );
        center.z = clamp_fixed(
            center.z,
            room->minimum_z + portals[portal_index].half_height,
            room->maximum_z - portals[portal_index].half_height
        );
        center.x = face_offset == 4 ? room->minimum_x : room->maximum_x;
    }
    portals[portal_index].center = center;
}

static void place_portal(const EngineState *state, uint8_t portal_index) {
    const Room *room = &rooms[state->room];
    fixed_t nearest_distance = (fixed_t)0x7FFFFF;
    Vec3 nearest_hit = state->position;
    uint8_t nearest_face_offset = NO_PORTAL;
    uint8_t face_offset;

    for (face_offset = 0; face_offset < ROOM_FACE_COUNT; ++face_offset) {
        const WorldFace *face = &world_faces[room->first_face + face_offset];
        Vec3 plane_point = world_vertex(face->vertex[0]);
        Vec3 normal = face_normals[face_offset];
        fixed_t denominator = signed_axis_component(state->forward, normal);
        fixed_t numerator;
        fixed_t distance;
        Vec3 hit;

        if (denominator >= -4) continue;
        numerator = signed_axis_component(
            vec_subtract(plane_point, state->position),
            normal
        );
        distance = (fixed_t)(((int32_t)numerator * FIXED_ONE) / denominator);
        if (distance <= NEAR_PLANE || distance >= nearest_distance) continue;
        hit = vec_add(state->position, vec_scale(state->forward, distance));
        if (!point_inside_room_face(room, hit)) continue;
        nearest_distance = distance;
        nearest_hit = hit;
        nearest_face_offset = face_offset;
    }
    if (nearest_face_offset == NO_PORTAL ||
        !room_face_holds_portal(room, nearest_face_offset)) return;

    configure_portal_on_face(portal_index, state->room, nearest_face_offset, nearest_hit);
}

static fixed_t portal_crossing_extent(const EngineState *state, const Portal *portal) {
    if (!state->dev_mode && portal->normal.z > FIXED_ONE / 2) {
        return PLAYER_EYE_HEIGHT;
    }
    return PLAYER_RADIUS;
}

static uint8_t try_portal_crossing(
    EngineState *state,
    Vec3 start,
    Vec3 *candidate
) {
    uint8_t portal_index;

    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const Portal *portal = &portals[portal_index];
        Vec3 start_relative;
        Vec3 end_relative;
        fixed_t start_distance;
        fixed_t end_distance;
        fixed_t fraction;
        Vec3 hit;
        fixed_t local_right;
        fixed_t local_up;
        fixed_t source_extent;
        fixed_t destination_extent;
        uint8_t preserve_horizontal_momentum;

        if (!portal->active || !portals[portal->linked].active ||
            portal->room != state->room) {
            continue;
        }
        start_relative = vec_subtract(start, portal->center);
        end_relative = vec_subtract(*candidate, portal->center);
        start_distance = signed_axis_component(start_relative, portal->normal);
        end_distance = signed_axis_component(end_relative, portal->normal);
        source_extent = portal_crossing_extent(state, portal);
        destination_extent = portal_crossing_extent(state, &portals[portal->linked]);
        start_distance -= source_extent;
        end_distance -= source_extent;
        if (start_distance < 0 || end_distance > 0 ||
            (start_distance == 0 && end_distance == 0)) {
            continue;
        }
        fraction = (fixed_t)(
            ((int32_t)start_distance * FIXED_ONE) /
            (start_distance - end_distance)
        );
        hit = vec_add(start, vec_scale(vec_subtract(*candidate, start), fraction));
        hit = vec_subtract(hit, portal->center);
        local_right = fixed_absolute(signed_axis_component(hit, portal->right));
        local_up = fixed_absolute(signed_axis_component(hit, portal->up));
        if (local_right > portal->half_width - PORTAL_APERTURE_MARGIN ||
            local_up > portal->half_height - PORTAL_APERTURE_MARGIN) {
            continue;
        }

        preserve_horizontal_momentum = state->portal_momentum;
        if (portals[portal->linked].normal.z != 0) {
            /* A wall-to-floor/ceiling traversal rotates the launch back into
             * Z, which ordinary movement already preserves. */
            preserve_horizontal_momentum = 0u;
        } else if (portal->normal.z != 0 && state->velocity.z != 0) {
            preserve_horizontal_momentum = 1u;
        }
        *candidate = transform_portal_point(portal_index, *candidate);
        state->velocity = transform_portal_vector(portal_index, state->velocity);
        state->right = transform_portal_vector(portal_index, state->right);
        state->up = transform_portal_vector(portal_index, state->up);
        state->forward = transform_portal_vector(portal_index, state->forward);
        recover_camera_angles(state);
        state->room = portals[portal->linked].room;
        state->portal_momentum = (uint8_t)(
            preserve_horizontal_momentum &&
            (state->velocity.x != 0 || state->velocity.y != 0)
        );
        add_signed_axis(
            candidate,
            portals[portal->linked].normal,
            source_extent + destination_extent + 16
        );
        state->grounded = 0;
        return (uint8_t)(portal_index + 1u);
    }
    return 0;
}

static void collide_with_room(EngineState *state, Vec3 *position) {
    const Room *room = &rooms[state->room];
    fixed_t minimum_x = room->minimum_x + PLAYER_RADIUS;
    fixed_t maximum_x = room->maximum_x - PLAYER_RADIUS;
    fixed_t minimum_y = room->minimum_y + PLAYER_RADIUS;
    fixed_t maximum_y = room->maximum_y - PLAYER_RADIUS;
    fixed_t minimum_z = room->minimum_z +
        (state->dev_mode ? PLAYER_RADIUS : PLAYER_EYE_HEIGHT);
    fixed_t maximum_z = room->maximum_z -
        (state->dev_mode ? PLAYER_RADIUS : CEILING_MARGIN);

    if (position->x < minimum_x) {
        position->x = minimum_x;
        state->velocity.x = 0;
    } else if (position->x > maximum_x) {
        position->x = maximum_x;
        state->velocity.x = 0;
    }
    if (position->y < minimum_y) {
        position->y = minimum_y;
        state->velocity.y = 0;
    } else if (position->y > maximum_y) {
        position->y = maximum_y;
        state->velocity.y = 0;
    }
    if (position->z <= minimum_z) {
        position->z = minimum_z;
        if (state->velocity.z < 0) state->velocity.z = 0;
        state->grounded = (uint8_t)!state->dev_mode;
    } else {
        state->grounded = 0;
    }
    if (position->z > maximum_z) {
        position->z = maximum_z;
        if (state->velocity.z > 0) state->velocity.z = 0;
    }
}

void engine_bodies_reset(void) {
    memset(bodies, 0, sizeof(bodies));
    memset(body_sleep_ticks, 0, sizeof(body_sleep_ticks));
    active_body_count = 0;
    held_body = NO_BODY;
}

#if T3D3_STATIC_BOX_LIMIT > 0
void engine_static_scene_reset(void) {
    memset(static_boxes, 0, sizeof(static_boxes));
    static_box_count = 0u;
}

uint8_t engine_spawn_static_box(
    Vec3 position,
    Vec3 half_extents,
    uint8_t room,
    uint8_t color
) {
    StaticBox *box;
    fixed_t maximum_extent;

    if (static_box_count >= T3D3_STATIC_BOX_LIMIT || room >= room_count) {
        return 0u;
    }
    if (half_extents.x < 4 || half_extents.y < 4 || half_extents.z < 4) {
        return 0u;
    }
    if (color > TRUE3D_MAX_COLOR) color = COLOR_WALL_RED;
    maximum_extent = half_extents.x;
    if (half_extents.y > maximum_extent) maximum_extent = half_extents.y;
    if (half_extents.z > maximum_extent) maximum_extent = half_extents.z;

    box = &static_boxes[static_box_count];
    memset(box, 0, sizeof(*box));
    box->render_body.position = position;
    box->render_body.basis_x = (Vec3){FIXED_ONE, 0, 0};
    box->render_body.basis_y = (Vec3){0, FIXED_ONE, 0};
    box->render_body.basis_z = (Vec3){0, 0, FIXED_ONE};
    box->render_body.half_extent = maximum_extent;
    box->render_body.room = room;
    box->render_body.color = color;
    box->render_body.active = 1u;
    box->render_body.sleeping = 1u;
    box->half_extents = half_extents;
    ++static_box_count;
    return static_box_count;
}
#endif

const T3D3Body *engine_body_read(uint8_t index) {
    if (index >= T3D3_MAX_BODIES || !bodies[index].active) return NULL;
    return &bodies[index];
}

uint8_t engine_held_body(void) {
    return held_body;
}

static uint8_t collide_body_with_room(T3D3Body *body, Vec3 *position) {
    const Room *room = &rooms[body->room];
    fixed_t extent = body->half_extent;
    fixed_t minimum_x = room->minimum_x + extent;
    fixed_t maximum_x = room->maximum_x - extent;
    fixed_t minimum_y = room->minimum_y + extent;
    fixed_t maximum_y = room->maximum_y - extent;
    fixed_t minimum_z = room->minimum_z + extent;
    fixed_t maximum_z = room->maximum_z - extent;
    uint8_t grounded = 0;

    if (position->x < minimum_x) {
        position->x = minimum_x;
        if (body->velocity.x < 0) {
            body->velocity.x = -fixed_mul(body->velocity.x, BODY_RESTITUTION);
        }
    } else if (position->x > maximum_x) {
        position->x = maximum_x;
        if (body->velocity.x > 0) {
            body->velocity.x = -fixed_mul(body->velocity.x, BODY_RESTITUTION);
        }
    }
    if (position->y < minimum_y) {
        position->y = minimum_y;
        if (body->velocity.y < 0) {
            body->velocity.y = -fixed_mul(body->velocity.y, BODY_RESTITUTION);
        }
    } else if (position->y > maximum_y) {
        position->y = maximum_y;
        if (body->velocity.y > 0) {
            body->velocity.y = -fixed_mul(body->velocity.y, BODY_RESTITUTION);
        }
    }
    if (position->z <= minimum_z) {
        position->z = minimum_z;
        grounded = 1;
        if (body->velocity.z < -BODY_SETTLE_SPEED) {
            body->velocity.z = -fixed_mul(body->velocity.z, BODY_RESTITUTION);
        } else if (body->velocity.z < 0) {
            body->velocity.z = 0;
        }
    } else if (position->z > maximum_z) {
        position->z = maximum_z;
        if (body->velocity.z > 0) {
            body->velocity.z = -fixed_mul(body->velocity.z, BODY_RESTITUTION);
        }
    }
    if (grounded) {
        body->velocity.x = fixed_mul(body->velocity.x, BODY_FLOOR_FRICTION);
        body->velocity.y = fixed_mul(body->velocity.y, BODY_FLOOR_FRICTION);
    }
    return grounded;
}

uint8_t engine_spawn_body(
    Vec3 position,
    uint8_t room,
    fixed_t half_extent,
    uint8_t color
) {
    uint8_t index;
    T3D3Body *body;

    if (room >= room_count) return 0;
    if (half_extent < BODY_MIN_HALF_EXTENT) half_extent = BODY_MIN_HALF_EXTENT;
    if (half_extent > BODY_MAX_HALF_EXTENT) half_extent = BODY_MAX_HALF_EXTENT;
    if (color > TRUE3D_MAX_COLOR) color = COLOR_WALL_RED;
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        if (!bodies[index].active) break;
    }
    if (index == T3D3_MAX_BODIES) return 0;

    body = &bodies[index];
    memset(body, 0, sizeof(*body));
    body->position = position;
    body->basis_x = (Vec3){FIXED_ONE, 0, 0};
    body->basis_y = (Vec3){0, FIXED_ONE, 0};
    body->basis_z = (Vec3){0, 0, FIXED_ONE};
    body->half_extent = half_extent;
    body->room = room;
    body->color = color;
    body->active = 1;
    ++active_body_count;
    collide_body_with_room(body, &body->position);
    return (uint8_t)(index + 1u);
}

static uint8_t try_body_portal_crossing(
    T3D3Body *body,
    Vec3 start,
    Vec3 *candidate
) {
    uint8_t portal_index;

    if (body->portal_cooldown != 0) {
        --body->portal_cooldown;
        return 0;
    }
    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const Portal *portal = &portals[portal_index];
        Vec3 start_relative;
        Vec3 end_relative;
        fixed_t start_distance;
        fixed_t end_distance;
        fixed_t fraction;
        Vec3 hit;
        fixed_t local_right;
        fixed_t local_up;

        if (!portal->active || !portals[portal->linked].active ||
            portal->room != body->room) {
            continue;
        }
        start_relative = vec_subtract(start, portal->center);
        end_relative = vec_subtract(*candidate, portal->center);
        start_distance = signed_axis_component(start_relative, portal->normal) -
            body->half_extent;
        end_distance = signed_axis_component(end_relative, portal->normal) -
            body->half_extent;
        if (start_distance < 0 || end_distance > 0 ||
            (start_distance == 0 && end_distance == 0)) {
            continue;
        }
        fraction = (fixed_t)(
            ((int32_t)start_distance * FIXED_ONE) /
            (start_distance - end_distance)
        );
        hit = vec_add(start, vec_scale(vec_subtract(*candidate, start), fraction));
        hit = vec_subtract(hit, portal->center);
        local_right = fixed_absolute(signed_axis_component(hit, portal->right));
        local_up = fixed_absolute(signed_axis_component(hit, portal->up));
        /* A cube resting on the floor exactly touches the bottom edge of a
         * floor-aligned wall portal. Keep that mathematically valid fit and
         * allow one 1/32-unit rounding tolerance; the old negative margin
         * rejected the exact fit and pinned continuously pushed cubes to the
         * host wall unless they were first lifted by a throw. */
        if (local_right > portal->half_width - body->half_extent +
                BODY_PORTAL_FIT_TOLERANCE ||
            local_up > portal->half_height - body->half_extent +
                BODY_PORTAL_FIT_TOLERANCE) {
            continue;
        }

        *candidate = transform_portal_point(portal_index, *candidate);
        body->velocity = transform_portal_vector(portal_index, body->velocity);
        body->basis_x = transform_portal_vector(portal_index, body->basis_x);
        body->basis_y = transform_portal_vector(portal_index, body->basis_y);
        body->basis_z = transform_portal_vector(portal_index, body->basis_z);
        body->room = portals[portal->linked].room;
        add_signed_axis(
            candidate,
            portals[portal->linked].normal,
            body->half_extent * 2 + 16
        );
        body->portal_cooldown = BODY_PORTAL_COOLDOWN;
        body->sleeping = 0;
        return (uint8_t)(portal_index + 1u);
    }
    return 0;
}

static void resolve_body_pair(uint8_t first_index, uint8_t second_index) {
    T3D3Body *first = &bodies[first_index];
    T3D3Body *second = &bodies[second_index];
    Vec3 delta;
    fixed_t overlap_x;
    fixed_t overlap_y;
    fixed_t overlap_z;
    fixed_t separation;
    fixed_t first_velocity;
    fixed_t second_velocity;
    uint8_t axis;

    if (!first->active || !second->active || first->room != second->room ||
        first_index == held_body || second_index == held_body) {
        return;
    }
    delta = vec_subtract(second->position, first->position);
    overlap_x = first->half_extent + second->half_extent - fixed_absolute(delta.x);
    overlap_y = first->half_extent + second->half_extent - fixed_absolute(delta.y);
    overlap_z = first->half_extent + second->half_extent - fixed_absolute(delta.z);
    if (overlap_x <= 0 || overlap_y <= 0 || overlap_z <= 0) return;

    axis = 0;
    separation = overlap_x;
    if (overlap_y < separation) {
        axis = 1;
        separation = overlap_y;
    }
    if (overlap_z < separation) {
        axis = 2;
        separation = overlap_z;
    }
    separation = (separation + 1) >> 1;
    if (axis == 0) {
        fixed_t direction = delta.x < 0 ? -1 : 1;
        first->position.x -= direction * separation;
        second->position.x += direction * separation;
        first_velocity = first->velocity.x;
        second_velocity = second->velocity.x;
        first->velocity.x = fixed_mul(second_velocity, BODY_RESTITUTION);
        second->velocity.x = fixed_mul(first_velocity, BODY_RESTITUTION);
    } else if (axis == 1) {
        fixed_t direction = delta.y < 0 ? -1 : 1;
        first->position.y -= direction * separation;
        second->position.y += direction * separation;
        first_velocity = first->velocity.y;
        second_velocity = second->velocity.y;
        first->velocity.y = fixed_mul(second_velocity, BODY_RESTITUTION);
        second->velocity.y = fixed_mul(first_velocity, BODY_RESTITUTION);
    } else {
        fixed_t direction = delta.z < 0 ? -1 : 1;
        first->position.z -= direction * separation;
        second->position.z += direction * separation;
        first_velocity = first->velocity.z;
        second_velocity = second->velocity.z;
        first->velocity.z = fixed_mul(second_velocity, BODY_RESTITUTION);
        second->velocity.z = fixed_mul(first_velocity, BODY_RESTITUTION);
    }
    first->sleeping = 0;
    second->sleeping = 0;
    body_sleep_ticks[first_index] = 0;
    body_sleep_ticks[second_index] = 0;
    collide_body_with_room(first, &first->position);
    collide_body_with_room(second, &second->position);
}

static void set_held_body_target(const EngineState *state) {
    T3D3Body *body;
    Vec3 target;

    if (held_body >= T3D3_MAX_BODIES || !bodies[held_body].active) {
        held_body = NO_BODY;
        return;
    }
    body = &bodies[held_body];
    target = vec_add(state->position, vec_scale(state->forward, BODY_HOLD_DISTANCE));
    body->room = state->room;
    body->position = target;
    body->velocity = (Vec3){0, 0, 0};
    body->sleeping = 0;
    body_sleep_ticks[held_body] = 0;
    collide_body_with_room(body, &body->position);
}

static void pickup_or_drop_body(const EngineState *state) {
    uint8_t index;
    uint8_t best = NO_BODY;
    fixed_t best_depth = BODY_PICKUP_DISTANCE + 1;

    if (held_body != NO_BODY) {
        bodies[held_body].velocity = state->velocity;
        held_body = NO_BODY;
        return;
    }
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        T3D3Body *body = &bodies[index];
        Vec3 relative;
        fixed_t depth;
        fixed_t horizontal;
        fixed_t vertical;

        if (!body->active || body->room != state->room) continue;
        relative = vec_subtract(body->position, state->position);
        depth = vec_dot(relative, state->forward);
        if (depth <= NEAR_PLANE || depth >= best_depth) continue;
        horizontal = fixed_absolute(vec_dot(relative, state->right));
        vertical = fixed_absolute(vec_dot(relative, state->up));
        if (horizontal > body->half_extent + 160 ||
            vertical > body->half_extent + 160) {
            continue;
        }
        best = index;
        best_depth = depth;
    }
    if (best == NO_BODY) {
        Vec3 target = vec_add(
            state->position,
            vec_scale(state->forward, BODY_HOLD_DISTANCE)
        );
        uint8_t spawned = engine_spawn_body(
            target,
            state->room,
            BODY_DEFAULT_HALF_EXTENT,
            COLOR_WALL_RED
        );
        if (spawned == 0) return;
        best = (uint8_t)(spawned - 1u);
    }
    held_body = best;
    set_held_body_target(state);
}

static void throw_held_body(const EngineState *state) {
    T3D3Body *body;

    if (held_body >= T3D3_MAX_BODIES || !bodies[held_body].active) return;
    body = &bodies[held_body];
    body->velocity = vec_add(
        state->velocity,
        vec_scale(state->forward, BODY_THROW_SPEED)
    );
    body->sleeping = 0;
    body_sleep_ticks[held_body] = 0;
    held_body = NO_BODY;
}

static void transform_held_body_through_portal(uint8_t portal_index) {
    T3D3Body *body;

    if (portal_index >= PORTAL_COUNT || held_body >= T3D3_MAX_BODIES ||
        !bodies[held_body].active) {
        return;
    }
    body = &bodies[held_body];
    body->position = transform_portal_point(portal_index, body->position);
    body->velocity = transform_portal_vector(portal_index, body->velocity);
    body->basis_x = transform_portal_vector(portal_index, body->basis_x);
    body->basis_y = transform_portal_vector(portal_index, body->basis_y);
    body->basis_z = transform_portal_vector(portal_index, body->basis_z);
    body->room = portals[portal_index].linked < PORTAL_COUNT ?
        portals[portals[portal_index].linked].room : body->room;
    body->portal_cooldown = BODY_PORTAL_COOLDOWN;
}

static uint8_t update_bodies(
    const EngineState *state,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    uint8_t index;
    uint8_t changed = 0;

    if (ticks_per_second == 0 || active_body_count == 0) return 0;
    set_held_body_target(state);
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        T3D3Body *body = &bodies[index];
        T3D3Body previous;
        Vec3 candidate;
        uint8_t grounded;

        if (!body->active || index == held_body || body->sleeping) continue;
        previous = *body;
        body->velocity.z -= (fixed_t)(
            ((int32_t)GRAVITY * elapsed_ticks) / ticks_per_second
        );
        candidate.x = body->position.x + (fixed_t)(
            ((int32_t)body->velocity.x * elapsed_ticks) / ticks_per_second
        );
        candidate.y = body->position.y + (fixed_t)(
            ((int32_t)body->velocity.y * elapsed_ticks) / ticks_per_second
        );
        candidate.z = body->position.z + (fixed_t)(
            ((int32_t)body->velocity.z * elapsed_ticks) / ticks_per_second
        );
        try_body_portal_crossing(body, body->position, &candidate);
        grounded = collide_body_with_room(body, &candidate);
        body->position = candidate;
        if (grounded && fixed_absolute(body->velocity.x) <= BODY_SLEEP_SPEED &&
            fixed_absolute(body->velocity.y) <= BODY_SLEEP_SPEED &&
            fixed_absolute(body->velocity.z) <= BODY_SLEEP_SPEED) {
            if (body_sleep_ticks[index] < BODY_SLEEP_TICKS) {
                ++body_sleep_ticks[index];
            }
            if (body_sleep_ticks[index] >= BODY_SLEEP_TICKS) {
                body->velocity = (Vec3){0, 0, 0};
                body->sleeping = 1;
            }
        } else {
            body_sleep_ticks[index] = 0;
        }
        if (memcmp(&previous, body, sizeof(*body)) != 0) changed = 1;
    }
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        uint8_t second;
        for (second = (uint8_t)(index + 1u); second < T3D3_MAX_BODIES; ++second) {
            T3D3Body *first_body = &bodies[index];
            T3D3Body *second_body = &bodies[second];
            Vec3 before_first;
            Vec3 before_second;

            /* Two sleeping bodies cannot develop a new overlap until an
             * external interaction wakes one of them. Avoid re-running all
             * pair solvers for a settled multi-body scene. */
            if (!first_body->active || !second_body->active ||
                first_body->room != second_body->room ||
                index == held_body || second == held_body ||
                (first_body->sleeping && second_body->sleeping)) {
                continue;
            }
            before_first = first_body->position;
            before_second = second_body->position;
            resolve_body_pair(index, second);
            if (memcmp(&before_first, &bodies[index].position, sizeof(Vec3)) != 0 ||
                memcmp(&before_second, &bodies[second].position, sizeof(Vec3)) != 0) {
                changed = 1;
            }
        }
    }
    return changed;
}

static fixed_t push_body_from_player(
    EngineState *state,
    T3D3Body *body,
    uint8_t body_index,
    uint8_t axis,
    fixed_t direction,
    fixed_t penetration
) {
    Vec3 start = body->position;
    Vec3 candidate = start;
    fixed_t actual;

    if (axis == 0) {
        candidate.x += direction * penetration;
    } else {
        candidate.y += direction * penetration;
    }
    if (try_body_portal_crossing(body, start, &candidate) != 0) {
        body->position = candidate;
        collide_body_with_room(body, &body->position);
        actual = penetration;
    } else {
        collide_body_with_room(body, &candidate);
        body->position = candidate;
        actual = axis == 0 ?
            fixed_absolute(candidate.x - start.x) :
            fixed_absolute(candidate.y - start.y);
        if (actual > penetration) actual = penetration;
    }

    if (actual < penetration) {
        if (axis == 0) {
            body->velocity.x = 0;
        } else {
            body->velocity.y = 0;
        }
    } else if (axis == 0) {
        fixed_t player_impulse = fixed_mul(
            state->velocity.x,
            PLAYER_BODY_PUSH_SCALE
        );
        if (direction * body->velocity.x < 0) {
            body->velocity.x = -fixed_mul(body->velocity.x, BODY_RESTITUTION);
        }
        if (direction * player_impulse > direction * body->velocity.x) {
            body->velocity.x = player_impulse;
        }
    } else {
        fixed_t player_impulse = fixed_mul(
            state->velocity.y,
            PLAYER_BODY_PUSH_SCALE
        );
        if (direction * body->velocity.y < 0) {
            body->velocity.y = -fixed_mul(body->velocity.y, BODY_RESTITUTION);
        }
        if (direction * player_impulse > direction * body->velocity.y) {
            body->velocity.y = player_impulse;
        }
    }
    body->sleeping = 0;
    body_sleep_ticks[body_index] = 0;
    return penetration - actual;
}

static uint8_t resolve_player_body_collisions(
    EngineState *state,
    Vec3 previous_position
) {
    uint8_t index;
    uint8_t contacted = 0;

    if (active_body_count == 0) return 0;
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        T3D3Body *body = &bodies[index];
        fixed_t minimum_x;
        fixed_t maximum_x;
        fixed_t minimum_y;
        fixed_t maximum_y;
        fixed_t body_bottom;
        fixed_t body_top;
        fixed_t player_bottom;
        fixed_t player_top;
        fixed_t previous_bottom;
        fixed_t previous_top;
        fixed_t penetration_left;
        fixed_t penetration_right;
        fixed_t penetration_near;
        fixed_t penetration_far;
        fixed_t minimum_penetration;
        fixed_t direction;
        fixed_t remaining;
        uint8_t axis;

        if (!body->active || index == held_body || body->room != state->room) {
            continue;
        }
        minimum_x = body->position.x - body->half_extent - PLAYER_RADIUS;
        maximum_x = body->position.x + body->half_extent + PLAYER_RADIUS;
        minimum_y = body->position.y - body->half_extent - PLAYER_RADIUS;
        maximum_y = body->position.y + body->half_extent + PLAYER_RADIUS;
        body_bottom = body->position.z - body->half_extent;
        body_top = body->position.z + body->half_extent;
        player_bottom = state->position.z - PLAYER_EYE_HEIGHT;
        player_top = state->position.z + CEILING_MARGIN;
        if (state->position.x <= minimum_x || state->position.x >= maximum_x ||
            state->position.y <= minimum_y || state->position.y >= maximum_y ||
            player_top <= body_bottom || player_bottom >= body_top) {
            continue;
        }

        previous_bottom = previous_position.z - PLAYER_EYE_HEIGHT;
        previous_top = previous_position.z + CEILING_MARGIN;
        if (!state->dev_mode && state->velocity.z <= 0 &&
            previous_bottom >= body_top - PLAYER_BODY_VERTICAL_SLOP &&
            body_top + PLAYER_EYE_HEIGHT <=
                rooms[state->room].maximum_z - CEILING_MARGIN) {
            state->position.z = body_top + PLAYER_EYE_HEIGHT;
            state->velocity.z = body->velocity.z > 0 ? body->velocity.z : 0;
            state->grounded = 1;
            contacted = 1;
            continue;
        }
        if (state->velocity.z > 0 &&
            previous_top <= body_bottom + PLAYER_BODY_VERTICAL_SLOP) {
            state->position.z = body_bottom - CEILING_MARGIN;
            state->velocity.z = body->velocity.z < 0 ? body->velocity.z : 0;
            body->sleeping = 0;
            body_sleep_ticks[index] = 0;
            contacted = 1;
            continue;
        }

        penetration_left = state->position.x - minimum_x;
        penetration_right = maximum_x - state->position.x;
        penetration_near = state->position.y - minimum_y;
        penetration_far = maximum_y - state->position.y;
        axis = 0;
        direction = 1;
        minimum_penetration = penetration_left;
        if (penetration_right < minimum_penetration) {
            direction = -1;
            minimum_penetration = penetration_right;
        }
        if (penetration_near < minimum_penetration) {
            axis = 1;
            direction = 1;
            minimum_penetration = penetration_near;
        }
        if (penetration_far < minimum_penetration) {
            axis = 1;
            direction = -1;
            minimum_penetration = penetration_far;
        }
        remaining = push_body_from_player(
            state,
            body,
            index,
            axis,
            direction,
            minimum_penetration
        );
        if (remaining > 0) {
            if (axis == 0) {
                state->position.x -= direction * remaining;
                state->velocity.x = 0;
            } else {
                state->position.y -= direction * remaining;
                state->velocity.y = 0;
            }
        }
        contacted = 1;
    }
    return contacted;
}

static uint8_t build_world(const True3DLevelView *level) {
    uint8_t room_index;
    uint8_t portal_index;

    if (level == NULL || level->header == NULL || level->rooms == NULL ||
        level->header->room_count == 0 ||
        level->header->room_count > TRUE3D_MAX_ROOMS) {
        return 0;
    }
    room_count = level->header->room_count;
    for (room_index = 0; room_index < room_count; ++room_index) {
        const True3DRoomRecord *source = &level->rooms[room_index];
        Room *destination = &rooms[room_index];
        uint8_t vertex_base = room_index * 8u;
        uint8_t face_base = room_index * ROOM_FACE_COUNT;
        uint8_t face_offset;

        destination->first_face = face_base;
        destination->minimum_x = source->minimum_x;
        destination->maximum_x = source->maximum_x;
        destination->minimum_y = source->minimum_y;
        destination->maximum_y = source->maximum_y;
        destination->minimum_z = source->minimum_z;
        destination->maximum_z = source->maximum_z;

        world_vertices[vertex_base + 0] = (WorldVertex){
            source->minimum_x, source->minimum_y, source->minimum_z
        };
        world_vertices[vertex_base + 1] = (WorldVertex){
            source->maximum_x, source->minimum_y, source->minimum_z
        };
        world_vertices[vertex_base + 2] = (WorldVertex){
            source->maximum_x, source->maximum_y, source->minimum_z
        };
        world_vertices[vertex_base + 3] = (WorldVertex){
            source->minimum_x, source->maximum_y, source->minimum_z
        };
        world_vertices[vertex_base + 4] = (WorldVertex){
            source->minimum_x, source->minimum_y, source->maximum_z
        };
        world_vertices[vertex_base + 5] = (WorldVertex){
            source->maximum_x, source->minimum_y, source->maximum_z
        };
        world_vertices[vertex_base + 6] = (WorldVertex){
            source->maximum_x, source->maximum_y, source->maximum_z
        };
        world_vertices[vertex_base + 7] = (WorldVertex){
            source->minimum_x, source->maximum_y, source->maximum_z
        };

        for (face_offset = 0; face_offset < ROOM_FACE_COUNT; ++face_offset) {
            WorldFace *face = &world_faces[face_base + face_offset];
            uint8_t corner;
            for (corner = 0; corner < 4; ++corner) {
                face->vertex[corner] = vertex_base +
                    box_face_vertices[face_offset][corner];
            }
            face->color = (uint8_t)(
                SHADED_PALETTE_FIRST + (source->face_color[face_offset] << 2)
            );
            face->portal = NO_PORTAL;
        }
    }

    portals[0].linked = 1;
    portals[1].linked = 0;
    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const True3DPortalSpawn *spawn = &level->header->portal[portal_index];
        portals[portal_index].half_width = PORTAL_HALF_WIDTH;
        portals[portal_index].half_height = PORTAL_HALF_HEIGHT;
        portals[portal_index].active = 0;
        if ((level->header->portal_active_mask & (1u << portal_index)) != 0 &&
            room_face_holds_portal(&rooms[spawn->room], spawn->face)) {
            Vec3 center = {spawn->x, spawn->y, spawn->z};
            configure_portal_on_face(
                portal_index,
                spawn->room,
                spawn->face,
                center
            );
        }
    }
    return 1;
}

uint8_t engine_init(EngineState *state, const True3DLevelView *level) {
    if (state == NULL || !build_world(level)) return 0;
    engine_bodies_reset();
#if T3D3_STATIC_BOX_LIMIT > 0
    engine_static_scene_reset();
#endif
    state->position.x = level->header->spawn_x;
    state->position.y = level->header->spawn_y;
    state->position.z = level->header->spawn_z;
    state->velocity.x = 0;
    state->velocity.y = 0;
    state->velocity.z = 0;
    state->yaw = 64;
    state->pitch = 0;
    rebuild_camera_basis(state);
    state->room = level->header->spawn_room;
    state->previous_buttons = 0;
    state->grounded = 1;
    state->dev_mode = 0;
    state->render_shift = 0;
    state->noclip = 0;
    state->portal_momentum = 0;
    memset(portal_lod_state, 0, sizeof(portal_lod_state));
    collide_with_room(state, &state->position);
#if T3D3_PORTAL_PUSH_TEST
    /* Deterministic regression fixture: the source portal is flush with the
     * floor and the resting cube exactly fits its lower edge. Walking forward
     * must push the cube through without requiring pickup or throw. */
    configure_portal_on_face(
        0u,
        0u,
        3u,
        (Vec3){0, 10 * FIXED_ONE, PORTAL_HALF_HEIGHT}
    );
    configure_portal_on_face(
        1u,
        1u,
        2u,
        (Vec3){12 * FIXED_ONE, 0, PORTAL_HALF_HEIGHT}
    );
    state->position = (Vec3){0, 8 * FIXED_ONE, PLAYER_EYE_HEIGHT};
    state->velocity = (Vec3){0, 0, 0};
    state->yaw = 64u;
    state->pitch = 0;
    state->room = 0u;
    state->grounded = 1u;
    rebuild_camera_basis(state);
    collide_with_room(state, &state->position);
    if (engine_spawn_body(
            (Vec3){0, 9 * FIXED_ONE, BODY_DEFAULT_HALF_EXTENT},
            0u,
            BODY_DEFAULT_HALF_EXTENT,
            COLOR_WALL_RED
        ) == 0) {
        return 0;
    }
#endif
#if T3D3_PLAYER_FLING_TEST
    /* Deterministic regression fixture: begin just above a floor portal with
     * a ten-unit-per-second fall.  Its wall exit converts that entire vertical
     * speed into -Y motion, which must survive later input/update frames. */
    configure_portal_on_face(
        0u,
        0u,
        0u,
        (Vec3){0, 5 * FIXED_ONE, 0}
    );
    configure_portal_on_face(
        1u,
        0u,
        3u,
        (Vec3){0, 10 * FIXED_ONE, 640}
    );
    state->position = (Vec3){
        0,
        5 * FIXED_ONE,
        PLAYER_EYE_HEIGHT + 64
    };
    state->velocity = (Vec3){0, 0, -2560};
    state->yaw = 64u;
    state->pitch = 0;
    state->room = 0u;
    state->grounded = 0u;
    state->portal_momentum = 0u;
    rebuild_camera_basis(state);
#endif
    return 1;
}

#if TRUE3D_RENDER_BENCHMARK
/* Fixed, authored stress view used by the body benchmark layout 3.  Both
 * linked portals occupy the far wall while four full-detail cubes cover the
 * root view and are repeated in each destination aperture.  Keeping fixture
 * setup inside the engine avoids exposing portal internals in the runtime ABI. */
uint8_t engine_benchmark_configure_dual_portal_stress(EngineState *state) {
    static const Vec3 positions[T3D3_MAX_BODIES] = {
        {-3 * FIXED_ONE, 6 * FIXED_ONE, BODY_DEFAULT_HALF_EXTENT},
        {-1 * FIXED_ONE, 7 * FIXED_ONE, BODY_DEFAULT_HALF_EXTENT},
        { 1 * FIXED_ONE, 7 * FIXED_ONE, BODY_DEFAULT_HALF_EXTENT},
        { 3 * FIXED_ONE, 6 * FIXED_ONE, BODY_DEFAULT_HALF_EXTENT}
    };
    uint8_t index;

    if (state == NULL || room_count == 0u) return 0;
    configure_portal_on_face(
        0u,
        0u,
        3u,
        (Vec3){-2 * FIXED_ONE, 10 * FIXED_ONE, 2 * FIXED_ONE}
    );
    configure_portal_on_face(
        1u,
        0u,
        3u,
        (Vec3){ 2 * FIXED_ONE, 10 * FIXED_ONE, 2 * FIXED_ONE}
    );
    state->position = (Vec3){0, 2 * FIXED_ONE, PLAYER_EYE_HEIGHT};
    state->velocity = (Vec3){0, 0, 0};
    state->yaw = 64u;
    state->pitch = 0;
    state->room = 0u;
    state->previous_buttons = 0u;
    state->grounded = 1u;
    state->dev_mode = 0u;
    state->render_shift = 0u;
    state->noclip = 0u;
    state->portal_momentum = 0u;
    rebuild_camera_basis(state);
    collide_with_room(state, &state->position);
    engine_bodies_reset();
    for (index = 0; index < T3D3_MAX_BODIES; ++index) {
        if (engine_spawn_body(
                positions[index],
                0u,
                BODY_DEFAULT_HALF_EXTENT,
                COLOR_WALL_RED
            ) == 0u) {
            return 0;
        }
    }
    return 1;
}
#endif

static void configure_render_mode(uint8_t shift) {
    uint8_t row;
    uint16_t offset = 0;

    if (shift > 1u) shift = 1u;
    if (active_render_width != 0 && active_render_shift == shift) return;
#if RENDER_WIDTH < 160
    present_frame_cache_valid[0] = 0;
    present_frame_cache_valid[1] = 0;
#endif
    active_render_shift = shift;
    active_render_width = shift == 0 ? RENDER_WIDTH : LOW_RENDER_WIDTH;
    active_render_height = shift == 0 ? RENDER_HEIGHT : LOW_RENDER_HEIGHT;
    active_horizon_near_limit = shift == 0 ? 4u : 2u;
    active_horizon_far_limit = shift == 0 ? 12u : 6u;
    low_frame.width = active_render_width;
    low_frame.height = active_render_height;
    for (row = 0; row < active_render_height; ++row) {
        low_row_offsets[row] = offset;
        offset += active_render_width;
    }
}

void engine_graphics_init(void) {
    uint8_t color;
    uint8_t shade;
    uint16_t index;
    uint16_t *near_scale = projection_scale_table;

#if RENDER_WIDTH < 160
    present_frame_cache_valid[0] = 0;
    present_frame_cache_valid[1] = 0;
#endif
    configure_render_mode(0);
    for (index = 0; index < NEAR_PROJECTION_TABLE_SIZE; ++index) {
        uint16_t scale;

        if (index < (NEAR_PLANE >> PROJECTION_TABLE_SHIFT)) {
            scale = 65535u;
        } else {
            scale = (uint16_t)(
                ((uint32_t)PROJECTION_FOCAL * FIXED_ONE *
                    (1u << PROJECTION_SCALE_SHIFT)) /
                ((uint24_t)index << PROJECTION_TABLE_SHIFT)
            );
        }
        *near_scale++ = scale;
        *near_scale++ = scale;
        *near_scale++ = scale;
        *near_scale++ = scale;
    }
    for (index = NEAR_PROJECTION_DEPTH_COUNT >>
            FAR_PROJECTION_TABLE_SHIFT;
         index < T3D3_FAR_PROJECTION_TABLE_SIZE;
         ++index) {
        far_projection_scale_table[index] = (uint16_t)(
            ((uint32_t)PROJECTION_FOCAL * FIXED_ONE *
                (1u << PROJECTION_SCALE_SHIFT)) /
            ((uint24_t)index << FAR_PROJECTION_TABLE_SHIFT)
        );
    }
    edge_reciprocal_table[0] = 0;
    for (index = 1; index < EDGE_RECIPROCAL_SIZE; ++index) {
        uint24_t denominator = (uint24_t)index << EDGE_RECIPROCAL_SHIFT;
        uint24_t reciprocal =
            ((1u << (EDGE_STEP_PRECISION_SHIFT + FIXED_SHIFT)) +
             denominator / 2u) / denominator;
        if (reciprocal > 65535u) reciprocal = 65535u;
        edge_reciprocal_table[index] = (uint16_t)reciprocal;
    }
    for (color = 0; color <= COLOR_HUD; ++color) {
        gfx_palette[color] = gfx_RGBTo1555(
            base_palette_rgb[color][0],
            base_palette_rgb[color][1],
            base_palette_rgb[color][2]
        );
        for (shade = 0; shade < SHADE_LEVEL_COUNT; ++shade) {
            uint8_t factor = shade_numerator[shade];
            gfx_palette[
                SHADED_PALETTE_FIRST + (color << 2) + shade
            ] = gfx_RGBTo1555(
                ((uint16_t)base_palette_rgb[color][0] * factor) >> 4,
                ((uint16_t)base_palette_rgb[color][1] * factor) >> 4,
                ((uint16_t)base_palette_rgb[color][2] * factor) >> 4
            );
        }
    }
}

uint8_t engine_update(
    EngineState *state,
    int8_t move_axis,
    int8_t turn_axis,
    int8_t look_axis,
    uint8_t buttons,
    uint8_t toggles,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    EngineState previous = *state;
    uint8_t pressed = (uint8_t)(buttons & (uint8_t)~state->previous_buttons);
    uint24_t maximum_ticks;
    uint8_t camera_changed = 0;
    Vec3 movement_direction;
    Vec3 candidate;
    uint8_t crossed_portal;
    uint8_t world_changed = 0;

    state->previous_buttons = buttons;
    if (ticks_per_second == 0) return 0;
    maximum_ticks = ticks_per_second / 8u;
    if (elapsed_ticks > maximum_ticks) elapsed_ticks = maximum_ticks;

    if (turn_axis != 0) {
        uint8_t turn_step = (uint8_t)(
            ((uint32_t)TURN_UNITS_PER_SECOND * elapsed_ticks + ticks_per_second / 2u) /
            ticks_per_second
        );
        if (turn_step == 0) turn_step = 1;
        state->yaw = (uint8_t)(state->yaw + turn_axis * turn_step);
        camera_changed = 1;
    }
    if (look_axis != 0) {
        uint8_t pitch_step = (uint8_t)(
            ((uint32_t)PITCH_UNITS_PER_SECOND * elapsed_ticks + ticks_per_second / 2u) /
            ticks_per_second
        );
        int16_t pitch;
        if (pitch_step == 0) pitch_step = 1;
        pitch = state->pitch + look_axis * pitch_step;
        if (pitch > PITCH_LIMIT) pitch = PITCH_LIMIT;
        if (pitch < -PITCH_LIMIT) pitch = -PITCH_LIMIT;
        if (pitch != state->pitch) {
            state->pitch = (int8_t)pitch;
            camera_changed = 1;
        }
    }
    if (camera_changed) rebuild_camera_basis(state);
    if ((pressed & ENGINE_BUTTON_DEV_MODE) != 0) {
        state->dev_mode = (uint8_t)!state->dev_mode;
        if (!state->dev_mode) state->noclip = 0;
        state->velocity.x = 0;
        state->velocity.y = 0;
        state->velocity.z = 0;
        state->grounded = 0;
        state->portal_momentum = 0;
    }
    if (state->dev_mode && (toggles & ENGINE_TOGGLE_NOCLIP) != 0) {
        state->noclip = (uint8_t)!state->noclip;
        state->velocity.x = 0;
        state->velocity.y = 0;
        state->velocity.z = 0;
        state->grounded = 0;
        state->portal_momentum = 0;
#if RENDER_WIDTH < 160
        /* A stationary transition can move from a culled black frame back to
         * room geometry with only one swap. Force both physical buffers to
         * accept that complete logical frame once. */
        present_frame_cache_valid[0] = 0;
        present_frame_cache_valid[1] = 0;
#endif
    }
    if ((pressed & ENGINE_BUTTON_RESOLUTION) != 0) {
        state->render_shift ^= 1u;
    }
    if ((pressed & ENGINE_BUTTON_ORANGE_PORTAL) != 0) {
        place_portal(state, 0);
        world_changed = 1;
    }
    if ((pressed & ENGINE_BUTTON_BLUE_PORTAL) != 0) {
        place_portal(state, 1);
        world_changed = 1;
    }
    if (!state->dev_mode &&
        (pressed & ENGINE_BUTTON_JUMP) != 0 && state->grounded) {
        state->velocity.z = JUMP_SPEED;
        state->grounded = 0;
    }

    if (state->dev_mode) {
        movement_direction = state->forward;
        state->velocity = vec_scale(movement_direction, move_axis * MOVE_SPEED);
        if ((buttons & ENGINE_BUTTON_JUMP) != 0) {
            state->velocity.z += MOVE_SPEED;
        }
        if ((buttons & ENGINE_BUTTON_FLY_DOWN) != 0) {
            state->velocity.z -= MOVE_SPEED;
        }
    } else {
        movement_direction = horizontal_forward(state);
        if (!state->portal_momentum) {
            state->velocity.x = fixed_mul(
                movement_direction.x,
                move_axis * MOVE_SPEED
            );
            state->velocity.y = fixed_mul(
                movement_direction.y,
                move_axis * MOVE_SPEED
            );
        }
        state->velocity.z -= (fixed_t)(
            ((int32_t)GRAVITY * elapsed_ticks) / ticks_per_second
        );
    }
    candidate.x = state->position.x + (fixed_t)(
        ((int32_t)state->velocity.x * elapsed_ticks) / ticks_per_second
    );
    candidate.y = state->position.y + (fixed_t)(
        ((int32_t)state->velocity.y * elapsed_ticks) / ticks_per_second
    );
    candidate.z = state->position.z + (fixed_t)(
        ((int32_t)state->velocity.z * elapsed_ticks) / ticks_per_second
    );

    crossed_portal = 0;
    if (!(state->dev_mode && state->noclip)) {
        crossed_portal = try_portal_crossing(
            state,
            state->position,
            &candidate
        );
        collide_with_room(state, &candidate);
        if (state->portal_momentum &&
            state->velocity.x == 0 && state->velocity.y == 0) {
            state->portal_momentum = 0;
        }
    }
    state->position = candidate;
    if (crossed_portal != 0) {
        transform_held_body_through_portal((uint8_t)(crossed_portal - 1u));
    }
    if ((pressed & ENGINE_BUTTON_OBJECT_USE) != 0) {
        pickup_or_drop_body(state);
        world_changed = 1;
    }
    if ((pressed & ENGINE_BUTTON_OBJECT_THROW) != 0 && held_body != NO_BODY) {
        throw_held_body(state);
        world_changed = 1;
    }
    if (update_bodies(state, elapsed_ticks, ticks_per_second)) {
        world_changed = 1;
    }
    if (!(state->dev_mode && state->noclip) && resolve_player_body_collisions(
            state,
            crossed_portal != 0 ? state->position : previous.position
        )) {
        world_changed = 1;
    }
    previous.previous_buttons = state->previous_buttons;

    return (uint8_t)(
        world_changed || memcmp(&previous, state, sizeof(EngineState)) != 0
    );
}

enum HudGlyph {
    HUD_GLYPH_F = 0,
    HUD_GLYPH_P,
    HUD_GLYPH_S,
    HUD_GLYPH_R,
    HUD_GLYPH_E,
    HUD_GLYPH_C,
    HUD_GLYPH_A,
    HUD_GLYPH_M,
    HUD_GLYPH_SPACE,
    HUD_GLYPH_DASH,
    HUD_GLYPH_DOT,
    HUD_GLYPH_DIGIT_0,
    HUD_GLYPH_COUNT = HUD_GLYPH_DIGIT_0 + 10
};

static const uint8_t hud_glyph_rows[5][HUD_GLYPH_COUNT] = {
    {7, 6, 7, 6, 7, 7, 2, 5, 0, 0, 0, 7, 2, 7, 7, 5, 7, 7, 7, 7, 7},
    {4, 5, 4, 5, 4, 4, 5, 7, 0, 0, 0, 5, 6, 1, 1, 5, 4, 4, 1, 5, 5},
    {6, 6, 7, 6, 6, 4, 7, 7, 0, 7, 0, 5, 2, 7, 7, 7, 7, 7, 2, 7, 7},
    {4, 4, 1, 5, 4, 4, 5, 5, 0, 0, 0, 5, 2, 4, 1, 1, 1, 5, 2, 5, 1},
    {4, 4, 7, 5, 7, 7, 5, 5, 0, 0, 2, 7, 7, 7, 7, 1, 7, 7, 2, 7, 7}
};

static const uint8_t hud_left_pixel[8] = {
    COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK,
    COLOR_HUD, COLOR_HUD, COLOR_HUD, COLOR_HUD
};
static const uint8_t hud_middle_pixel[8] = {
    COLOR_BLACK, COLOR_BLACK, COLOR_HUD, COLOR_HUD,
    COLOR_BLACK, COLOR_BLACK, COLOR_HUD, COLOR_HUD
};
static const uint8_t hud_right_pixel[8] = {
    COLOR_BLACK, COLOR_HUD, COLOR_BLACK, COLOR_HUD,
    COLOR_BLACK, COLOR_HUD, COLOR_BLACK, COLOR_HUD
};

static void draw_hud_text(
    uint8_t *destination,
    const uint8_t *glyph,
    uint8_t count
) {
    while (count-- != 0) {
        const uint8_t *source = &hud_glyph_rows[0][*glyph++];
        uint8_t *row_destination = destination;
        uint8_t row;

        for (row = 0; row < 5; ++row) {
            uint8_t bits = *source;
            row_destination[0] = hud_left_pixel[bits];
            row_destination[1] = hud_middle_pixel[bits];
            row_destination[2] = hud_right_pixel[bits];
            row_destination += GFX_LCD_WIDTH;
            source += HUD_GLYPH_COUNT;
        }
        destination += 4;
    }
}

static void draw_hud(
    uint16_t fps_tenths,
    uint8_t dev_mode
) {
    static const uint8_t freecam_glyphs[] = {
        HUD_GLYPH_F, HUD_GLYPH_R, HUD_GLYPH_E, HUD_GLYPH_E,
        HUD_GLYPH_C, HUD_GLYPH_A, HUD_GLYPH_M
    };
    uint8_t fps_glyphs[9] = {
        HUD_GLYPH_F, HUD_GLYPH_P, HUD_GLYPH_S, HUD_GLYPH_SPACE
    };
    uint8_t *frame = &gfx_vbuffer[0][0];
    uint16_t whole_fps;
    uint8_t digit_count;
    uint8_t count = 4;
    uint8_t row;

    for (row = 0; row < 8; ++row) {
        uint8_t *screen_row = frame + (uint16_t)row * GFX_LCD_WIDTH;
        memset(screen_row, COLOR_BLACK, 38);
        if (dev_mode) memset(screen_row + 78, COLOR_BLACK, 31);
    }

    if (fps_tenths == 0) {
        fps_glyphs[count++] = HUD_GLYPH_DASH;
        fps_glyphs[count++] = HUD_GLYPH_DASH;
        fps_glyphs[count++] = HUD_GLYPH_DOT;
        fps_glyphs[count++] = HUD_GLYPH_DASH;
    } else {
        whole_fps = fps_tenths / 10u;
        digit_count = whole_fps >= 100u ? 3u : (whole_fps >= 10u ? 2u : 1u);
        if (digit_count == 3u) {
            whole_fps %= 1000u;
            fps_glyphs[count++] = (uint8_t)(
                HUD_GLYPH_DIGIT_0 + whole_fps / 100u
            );
        }
        if (digit_count >= 2u) {
            fps_glyphs[count++] = (uint8_t)(
                HUD_GLYPH_DIGIT_0 + (whole_fps / 10u) % 10u
            );
        }
        fps_glyphs[count++] = (uint8_t)(
            HUD_GLYPH_DIGIT_0 + whole_fps % 10u
        );
        fps_glyphs[count++] = HUD_GLYPH_DOT;
        fps_glyphs[count++] = (uint8_t)(
            HUD_GLYPH_DIGIT_0 + fps_tenths % 10u
        );
    }
    draw_hud_text(frame + 2u * GFX_LCD_WIDTH + 2u, fps_glyphs, count);
    if (dev_mode) {
        draw_hud_text(
            frame + 2u * GFX_LCD_WIDTH + 80u,
            freecam_glyphs,
            sizeof(freecam_glyphs)
        );
    }

    memset(
        &frame[(uint24_t)(GFX_LCD_HEIGHT / 2) * GFX_LCD_WIDTH +
            GFX_LCD_WIDTH / 2 - 2],
        COLOR_HUD,
        5
    );
    for (row = GFX_LCD_HEIGHT / 2 - 2; row <= GFX_LCD_HEIGHT / 2 + 2; ++row) {
        frame[(uint16_t)row * GFX_LCD_WIDTH + GFX_LCD_WIDTH / 2] = COLOR_HUD;
    }
}

/* HUD pixels are drawn after presentation, so invalidate every logical group
 * whose physical block intersects an overlay before comparing with the cache. */
#if RENDER_WIDTH == 80
static void invalidate_present_cache_rectangle(
    uint8_t *cache,
    uint16_t physical_left,
    uint8_t physical_top,
    uint16_t physical_right,
    uint8_t physical_bottom
) {
    uint8_t scale = active_render_shift == 0 ?
        RENDER_SCALE : LOW_RENDER_SCALE;
    uint8_t first_row = physical_top / scale;
    uint8_t last_row = physical_bottom / scale;
    uint8_t first_group = (uint8_t)((physical_left / scale) & 0xF0u);
    uint8_t last_group = (uint8_t)((physical_right / scale) & 0xF0u);
    uint8_t row;

    if (last_row >= active_render_height) last_row = active_render_height - 1u;
    if (last_group >= active_render_width) {
        last_group = (uint8_t)((active_render_width - 1u) & 0xF0u);
    }
    for (row = first_row; row <= last_row; ++row) {
        uint8_t group;
        uint16_t row_offset = (uint16_t)row * active_render_width;

        for (group = first_group; group <= last_group; group += 16u) {
            uint16_t offset = row_offset + group;

            cache[offset] = (uint8_t)(low_frame.data[offset] ^ 0xFFu);
        }
    }
}
#endif

/* GraphX alternates two physical 320x240 buffers. Keep one exact logical
 * cache per draw buffer and expand only changed 8x1 source groups. */
#if RENDER_WIDTH < 160
static void present_low_frame_cached(uint8_t dev_mode) {
#if RENDER_WIDTH == 64
    static const uint16_t overlay_group[] = {
        0u, RENDER_WIDTH,
        23u * RENDER_WIDTH + 24u, 23u * RENDER_WIDTH + 32u,
        24u * RENDER_WIDTH + 24u, 24u * RENDER_WIDTH + 32u
    };
    static const uint16_t dev_overlay_group[] = {
        8u, 16u, RENDER_WIDTH + 8u, RENDER_WIDTH + 16u
    };
#endif
    uint8_t slot = (uint8_t)(&gfx_vbuffer[0][0] != gfx_vram);
    uint8_t *cache = present_frame_cache[slot];
    uint16_t frame_size = (uint16_t)active_render_width * active_render_height;

    if (!present_frame_cache_valid[slot]) {
#if RENDER_WIDTH == 64
        present_low_frame_fast();
#elif RENDER_WIDTH == 80
        present_low_frame_80_fast();
#endif
        memcpy(cache, low_frame.data, frame_size);
        present_frame_cache_valid[slot] = 1;
        return;
    }
#if RENDER_WIDTH == 64
    {
        uint8_t index;

        for (index = 0;
             index < sizeof(overlay_group) / sizeof(overlay_group[0]);
             ++index) {
            uint16_t offset = overlay_group[index];

            cache[offset] = (uint8_t)(low_frame.data[offset] ^ 0xFFu);
        }
        if (dev_mode) {
            for (index = 0;
                 index < sizeof(dev_overlay_group) /
                    sizeof(dev_overlay_group[0]);
                 ++index) {
                uint16_t offset = dev_overlay_group[index];

                cache[offset] = (uint8_t)(low_frame.data[offset] ^ 0xFFu);
            }
        }
    }
#elif RENDER_WIDTH == 80
    invalidate_present_cache_rectangle(cache, 2u, 2u, 36u, 6u);
    if (dev_mode) {
        invalidate_present_cache_rectangle(cache, 80u, 2u, 106u, 6u);
    }
    invalidate_present_cache_rectangle(cache, 158u, 118u, 162u, 122u);
#endif
#if RENDER_WIDTH == 64
    present_low_frame_dirty_fast(cache);
#elif RENDER_WIDTH == 80
    present_low_frame_dirty_80_fast(cache);
#endif
}
#endif

#if T3D3_MATERIAL_TEXTURE
/* Sparse procedural wear is much smaller than a texture atlas and avoids a
 * branch-heavy full-frame post-process on the eZ80.  Only corrosion samples
 * and occasional horizontal weld rows are visited; all other pixels retain
 * the polygon renderer's depth and face lighting unchanged. */
static void apply_material_texture(const EngineState *state) {
    uint8_t row;
    uint8_t phase_x = (uint8_t)((state->position.x >> 6) + (state->yaw >> 2));
    uint8_t phase_y = (uint8_t)((state->position.y >> 6) - (state->yaw >> 3));
    uint8_t shaded_end = (uint8_t)(
        SHADED_PALETTE_FIRST + (COLOR_HUD + 1u) * SHADE_LEVEL_COUNT
    );

    for (row = 0u; row < active_render_height; ++row) {
        uint8_t v = (uint8_t)(row + phase_y);
        uint8_t column = (uint8_t)(
            ((3u ^ (uint8_t)(v << 1)) - phase_x) & 15u
        );

        /* Five possible samples per 80-pixel row, instead of testing every
         * framebuffer pixel.  A palette decrement preserves the material and
         * changes only its four-level light shade. */
        for (; column < active_render_width; column = (uint8_t)(column + 16u)) {
            uint8_t *pixel = &low_frame.data[
                (uint16_t)row * active_render_width + column
            ];
            uint8_t color = *pixel;

            if (color >= SHADED_PALETTE_FIRST && color < shaded_end) {
                uint8_t relative = (uint8_t)(color - SHADED_PALETTE_FIRST);

                if ((relative >> 2) >= COLOR_WALL_RED &&
                    (relative & (SHADE_LEVEL_COUNT - 1u)) != 0u) {
                    --*pixel;
                }
            }
        }
    }

    /* Four widely spaced welded rows add readable panel scale at low
     * resolution without reintroducing the old 4,800-pixel scan. */
    row = (uint8_t)((16u - (phase_y & 15u)) & 15u);
    for (; row < active_render_height; row = (uint8_t)(row + 16u)) {
        uint8_t column;
        uint8_t *pixel = &low_frame.data[(uint16_t)row * active_render_width];

        for (column = 0u; column < active_render_width; ++column, ++pixel) {
            uint8_t color = *pixel;

            if (color >= SHADED_PALETTE_FIRST && color < shaded_end &&
                ((color - SHADED_PALETTE_FIRST) &
                    (SHADE_LEVEL_COUNT - 1u)) != 0u) {
                --*pixel;
            }
        }
    }
}
#endif

void engine_render(const EngineState *state, uint16_t fps_tenths) {
    Camera camera;
    uint8_t row;

    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_SETUP);
    configure_render_mode(state->render_shift);
    camera.position = state->position;
    camera.right = state->right;
    camera.up = state->up;
    camera.forward = state->forward;
    camera.room = state->room;
    render_layers[0].first_row = 0;
    render_layers[0].last_row = active_render_height - 1;
    render_layers[0].bound_left = 0;
    render_layers[0].bound_right = active_render_width - 1;
    render_layers[0].lod_shift = 0;
    render_layers[0].pixel_area =
        (uint16_t)active_render_width * active_render_height;
    for (row = 0; row < active_render_height; ++row) {
        render_layers[0].row_left[row] = 0;
        render_layers[0].row_right[row] = active_render_width - 1;
    }
    if (static_scene_only) {
        clear_render_layer(&render_layers[0], 0u);
        render_layers[0].count = 0u;
        render_layers[0].solid_count = 0u;
        render_scene_objects(&camera, &render_layers[0]);
    } else if (!render_fullscreen_portal(
            &camera,
            (uint8_t)(state->dev_mode && state->noclip)
        )) {
        render_camera(
            &camera,
            0,
            NO_PORTAL,
            (uint8_t)(state->dev_mode && state->noclip)
        );
    }
#if T3D3_MATERIAL_TEXTURE
    apply_material_texture(state);
#endif
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_WAIT);
    gfx_Wait();
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_PRESENT);
#if RENDER_WIDTH == 64
    if (active_render_shift == 0) present_low_frame_cached(state->dev_mode);
    else present_low_frame_32_fast();
#elif RENDER_WIDTH == 80
    if (active_render_shift == 0) present_low_frame_cached(state->dev_mode);
    else present_low_frame_40_fast();
#elif RENDER_WIDTH == 160
    if (active_render_shift == 0) present_low_frame_160_fast();
    else present_low_frame_80_fast();
#endif
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_OVERLAY);
    draw_hud(fps_tenths, state->dev_mode);
    RENDER_BENCHMARK_SWITCH(TRUE3D_BENCH_ADMIN);
}

void engine_set_static_scene_only(uint8_t enabled) {
    static_scene_only = enabled != 0u;
}
