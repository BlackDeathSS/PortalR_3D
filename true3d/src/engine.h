#ifndef TRUE3D_ENGINE_H
#define TRUE3D_ENGINE_H

#include <stdint.h>

#include "level.h"

#define ENGINE_BUTTON_JUMP (1u << 0)
#define ENGINE_BUTTON_ORANGE_PORTAL (1u << 1)
#define ENGINE_BUTTON_BLUE_PORTAL (1u << 2)
#define ENGINE_BUTTON_DEV_MODE (1u << 3)
#define ENGINE_BUTTON_FLY_DOWN (1u << 4)
#define ENGINE_BUTTON_RESOLUTION (1u << 5)
#define ENGINE_BUTTON_RECURSION (1u << 6)

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
    uint8_t render_mode;
    uint8_t portal_recursion;
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
void engine_render(const EngineState *state, uint8_t fps);

#endif
