#ifndef DOOMCE_ENGINE_H
#define DOOMCE_ENGINE_H

#include "level_format.h"

#include <stdint.h>

#define ENGINE_BUTTON_JUMP (1u << 0)

typedef int24_t fixed_t;

typedef struct {
    fixed_t x;
    fixed_t y;
    fixed_t z;
    fixed_t vertical_velocity;
    uint16_t angle;
    int16_t pitch;
    uint8_t sector;
    uint8_t previous_buttons;
    uint8_t grounded;
} EngineState;

_Static_assert(sizeof(EngineState) <= 32u, "EngineState exceeded RAM budget");

uint8_t engine_init(EngineState *state, LevelView *level);
void engine_graphics_init(void);
uint8_t engine_update(
    EngineState *state,
    const LevelView *level,
    int8_t move_axis,
    int8_t turn_axis,
    int8_t look_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
);
void engine_render(
    const EngineState *state,
    const LevelView *level,
    uint8_t fps,
    uint8_t external_level
);

#endif
