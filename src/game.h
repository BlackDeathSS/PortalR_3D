#ifndef PORTAL3D_GAME_H
#define PORTAL3D_GAME_H

#include <stdint.h>

#define PORTAL_BUTTON_PRIMARY  (1u << 0)
#define PORTAL_BUTTON_SECONDARY (1u << 1)
#define PORTAL_BUTTON_CLEAR    (1u << 2)

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

#endif
