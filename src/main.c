#include "game.h"

#include <graphx.h>
#include <keypadc.h>
#include <time.h>

#define UPDATE_RATE 60u

static GameState game;

int main(void) {
    clock_t previous_tick;
    uint24_t accumulated_ticks = 0;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);

    gfx_Begin();
    gfx_SetDrawBuffer();
    game_graphics_init();
    game_init(&game);

    game_render(&game);
    gfx_SwapDraw();

    kb_SetMode(MODE_3_CONTINUOUS);
    previous_tick = clock();

    while ((kb_Data[6] & kb_Clear) == 0) {
        clock_t current_tick = clock();
        clock_t elapsed = current_tick - previous_tick;
        int8_t move_axis;
        int8_t turn_axis;
        uint8_t buttons = 0;

        previous_tick = current_tick;
        accumulated_ticks += (uint24_t)elapsed;
        move_axis = (int8_t)(((kb_Data[7] & kb_Up) != 0) - ((kb_Data[7] & kb_Down) != 0));
        turn_axis = (int8_t)(((kb_Data[7] & kb_Right) != 0) - ((kb_Data[7] & kb_Left) != 0));

        if ((kb_Data[1] & kb_2nd) != 0) buttons |= PORTAL_BUTTON_PRIMARY;
        if ((kb_Data[2] & kb_Alpha) != 0) buttons |= PORTAL_BUTTON_SECONDARY;
        if ((kb_Data[1] & kb_Del) != 0) buttons |= PORTAL_BUTTON_CLEAR;

        if (accumulated_ticks >= update_ticks) {
            uint8_t changed = game_update(
                &game,
                move_axis,
                turn_axis,
                buttons,
                accumulated_ticks,
                (uint24_t)CLOCKS_PER_SEC
            );

            accumulated_ticks = 0;
            if (changed) {
                game_render(&game);
                gfx_SwapDraw();
            }
        }
    }

    kb_Reset();
    gfx_End();
    return 0;
}
