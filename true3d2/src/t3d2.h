#ifndef T3D2_H
#define T3D2_H

#include <stdint.h>

#include "t3d2_format.h"

#define T3D2_ROOT_WIDTH 80u
#define T3D2_ROOT_HEIGHT 60u
#define T3D2_PORTAL1_WIDTH 40u
#define T3D2_PORTAL1_HEIGHT 30u
#define T3D2_PORTAL2_WIDTH 20u
#define T3D2_PORTAL2_HEIGHT 15u
#define T3D2_FIXED_ONE 256L
#define T3D2_TICK_RATE 60u
#define T3D2_BUILD_VERSION 0x26081005UL
#define T3D2_MAX_GEOMETRY_PAGES 100u
#define T3D2_FRAME_SAMPLE_CAPACITY 512u

#ifndef T3D2_ENABLE_FULL_TAKEOVER
#define T3D2_ENABLE_FULL_TAKEOVER 0
#endif

#ifndef T3D2_KERNEL_BENCHMARK
#define T3D2_KERNEL_BENCHMARK 0
#endif

#ifndef T3D2_RUNTIME_AUTOTEST
#define T3D2_RUNTIME_AUTOTEST 0
#endif

#ifndef T3D2_KERNEL_AUTOTEST
#define T3D2_KERNEL_AUTOTEST 0
#endif

typedef int24_t t3d2_fixed_t;

typedef struct {
    t3d2_fixed_t x;
    t3d2_fixed_t y;
    t3d2_fixed_t z;
} T3D2Vec3;

typedef struct {
    T3D2Vec3 position;
    T3D2Vec3 velocity;
    T3D2Vec3 right;
    T3D2Vec3 up;
    T3D2Vec3 forward;
    uint16_t cell;
    uint8_t yaw;
    int8_t pitch;
    uint8_t grounded;
    uint8_t portal_exclusion_ticks;
} T3D2Player;

typedef struct {
    T3D2Vec3 center;
    T3D2Vec3 right;
    T3D2Vec3 up;
    T3D2Vec3 normal;
    t3d2_fixed_t half_width;
    t3d2_fixed_t half_height;
    uint16_t cell;
    uint8_t linked;
    uint8_t active;
    uint8_t charging;
} T3D2Portal;

typedef struct {
    T3D2Vec3 position;
    T3D2Vec3 velocity;
    T3D2Vec3 half_extent;
    int16_t orientation[9];
    uint16_t cell;
    uint8_t shape;
    uint8_t flags;
    uint8_t sleep_ticks;
    uint8_t portal_exclusion_ticks;
    uint8_t active;
} T3D2Body;

typedef struct {
    const T3D2MapHeader *header;
    const T3D2CellRecord *cells;
    const T3D2GatewayRecord *gateways;
    const T3D2MeshletRecord *meshlets;
    const T3D2PortalSurfaceRecord *portal_surfaces;
    const T3D2BodySpawnRecord *body_spawns;
    const T3D2MaterialRecord *materials;
    const uint8_t *pvs;
    const int32_t *vertex_pool;
    const uint8_t *collision;
    const uint16_t *palette;
    uint24_t size;
} T3D2SceneView;

typedef struct {
    uint32_t frame_count;
    uint32_t total_ticks;
    uint32_t update_ticks;
    uint32_t visibility_ticks;
    uint32_t transform_ticks;
    uint32_t raster_ticks;
    uint32_t portal_ticks;
    uint32_t present_ticks;
    uint32_t logical_hash;
    uint16_t submitted_triangles[3];
    uint16_t shaded_samples[3];
    uint8_t dropped_meshlets[3];
    uint24_t frame_ticks[T3D2_FRAME_SAMPLE_CAPACITY];
    uint16_t frame_sample_count;
    uint16_t frame_sample_cursor;
} T3D2Benchmark;

typedef struct {
    T3D2Player player;
    T3D2Portal portal[2];
    T3D2Body body[T3D2_MAX_BODIES];
    T3D2SceneView scene;
    T3D2Benchmark benchmark;
    const uint8_t *geometry_payload[T3D2_MAX_GEOMETRY_PAGES];
    uint8_t *geometry_cache[T3D2_MAX_GEOMETRY_PAGES];
    uint16_t geometry_payload_size[T3D2_MAX_GEOMETRY_PAGES];
    const uint8_t *texture_half[2];
    uint8_t *texture_cache[2];
    uint8_t *scene_cache;
    const uint8_t *mip_chain;
    uint8_t previous_buttons;
    uint8_t body_count;
    uint8_t geometry_page_count;
    uint8_t texture_shift;
    uint8_t scene_loaded;
    uint8_t resources_loaded;
    uint8_t takeover_ready;
    uint8_t input_latch;
    uint8_t exit_requested;
} T3D2Engine;

enum {
    T3D2_BUTTON_JUMP = 1u << 0,
    T3D2_BUTTON_PORTAL_A = 1u << 1,
    T3D2_BUTTON_PORTAL_B = 1u << 2,
    T3D2_BUTTON_CANCEL_PORTALS = 1u << 7
};

enum {
    T3D2_INPUT_UP = 1u << 3,
    T3D2_INPUT_DOWN = 1u << 4,
    T3D2_INPUT_LEFT = 1u << 5,
    T3D2_INPUT_RIGHT = 1u << 6
};

enum {
    T3D2_OK = 0,
    T3D2_ERROR_ARGUMENT,
    T3D2_ERROR_SCENE_MISSING,
    T3D2_ERROR_SCENE_FORMAT,
    T3D2_ERROR_SCENE_CRC,
    T3D2_ERROR_SCENE_BOUNDS,
    T3D2_ERROR_RESOURCE_MISSING,
    T3D2_ERROR_RESOURCE_FORMAT,
    T3D2_ERROR_RESOURCE_CRC,
    T3D2_ERROR_MEMORY_DISABLED,
    T3D2_ERROR_MEMORY_SPACE,
    T3D2_ERROR_MEMORY_BATTERY,
    T3D2_ERROR_MEMORY_BACKUP,
    T3D2_ERROR_MEMORY_UNPROVEN
};

extern uint8_t t3d2_root_color[T3D2_ROOT_WIDTH * T3D2_ROOT_HEIGHT];
extern uint16_t t3d2_root_depth[T3D2_ROOT_WIDTH * T3D2_ROOT_HEIGHT];

uint8_t t3d2_boot(T3D2Engine *engine);
void t3d2_shutdown(T3D2Engine *engine);
uint8_t t3d2_load_scene(T3D2Engine *engine, const void *data, uint24_t size);
uint8_t t3d2_tick(
    T3D2Engine *engine,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
);
void t3d2_render(T3D2Engine *engine);
uint8_t t3d2_place_portal(T3D2Engine *engine, uint8_t portal_index);
int8_t t3d2_spawn_body(T3D2Engine *engine, const T3D2Body *body);
const T3D2Benchmark *t3d2_benchmark_read(const T3D2Engine *engine);
int t3d2_kernel_benchmark_run(void);
uint8_t t3d2_runtime_report_write(const T3D2Engine *engine, uint32_t wall_ticks);

void t3d2_present_80x60(void);
void t3d2_clear_depth_80x60(void);

#endif
