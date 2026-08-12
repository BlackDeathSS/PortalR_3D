#ifndef T3D2_INTERNAL_H
#define T3D2_INTERNAL_H

#include "t3d2.h"

#define T3D2_NEAR_PLANE 32
/* True3D uses focal 42 at 64x48. Scale it with the 80-pixel root width so
   both engines have the same approximately 75x60 degree field of view. */
#define T3D2_PROJECTION_FOCAL 53
#define T3D2_PLAYER_RADIUS 64
#define T3D2_PLAYER_EYE_HEIGHT 384
#define T3D2_GRAVITY 2560
#define T3D2_JUMP_SPEED 1792
#define T3D2_MOVE_SPEED 640
#define T3D2_TURN_SPEED 80u
#define T3D2_BODY_SLEEP_TICKS 30u

extern const uint16_t t3d2_reciprocal_q16[256];

typedef struct {
    int16_t x;
    int16_t y;
    uint16_t inverse_depth;
    int16_t u;
    int16_t v;
} T3D2ProjectedVertex;

extern uint8_t t3d2_portal1_color[T3D2_PORTAL1_WIDTH * T3D2_PORTAL1_HEIGHT];
extern uint16_t t3d2_portal1_depth[T3D2_PORTAL1_WIDTH * T3D2_PORTAL1_HEIGHT];
extern uint8_t t3d2_portal2_color[T3D2_PORTAL2_WIDTH * T3D2_PORTAL2_HEIGHT];
extern uint16_t t3d2_portal2_depth[T3D2_PORTAL2_WIDTH * T3D2_PORTAL2_HEIGHT];

int16_t t3d2_sin_q8(uint8_t angle);
int16_t t3d2_cos_q8(uint8_t angle);
uint32_t t3d2_crc32(const void *data, uint24_t size);
uint8_t t3d2_scene_bind(T3D2SceneView *view, const void *data, uint24_t size);
uint8_t t3d2_resources_load(T3D2Engine *engine);
void t3d2_physics_init(T3D2Engine *engine);
uint8_t t3d2_physics_tick(
    T3D2Engine *engine,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
);
void t3d2_reference_render(T3D2Engine *engine);
void t3d2_raster_span(void);
void t3d2_solid_span(void);
void t3d2_triangle_normalize(void);
void t3d2_triangle_gradients(void);
void t3d2_triangle_raster(
    T3D2Engine *engine,
    uint8_t *color,
    uint16_t *depth,
    uint8_t width,
    uint8_t height,
    const T3D2ProjectedVertex *a,
    const T3D2ProjectedVertex *b,
    const T3D2ProjectedVertex *c,
    uint8_t shade,
    uint16_t *sample_counter
);
uint16_t t3d2_kernel_raster_4800(T3D2Engine *engine);
uint16_t t3d2_kernel_span_4800(T3D2Engine *engine);
uint32_t t3d2_kernel_geometry_96(void);
uint8_t t3d2_memory_prepare(void);
uint8_t t3d2_memory_restore(void);
void t3d2_memory_discard_backup(void);
void t3d2_input_poll(T3D2Engine *engine);

#endif
