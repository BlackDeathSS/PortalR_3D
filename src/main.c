#include "game.h"

#include <graphx.h>
#include <keypadc.h>
#include <time.h>

#define UPDATE_RATE 60u

static GameState game;

int main(void) {
    clock_t previous_tick;
    clock_t fps_window_start;
    uint24_t accumulated_ticks = 0;
    uint24_t rendered_frames = 1;
    uint8_t displayed_fps = 0;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);

    gfx_Begin();
    gfx_SetDrawBuffer();
    game_graphics_init();
    game_init(&game);

    game_render(&game, displayed_fps);
    gfx_SwapDraw();

    kb_SetMode(MODE_3_CONTINUOUS);
    previous_tick = clock();
    fps_window_start = previous_tick;

    while ((kb_Data[6] & kb_Clear) == 0) {
        clock_t current_tick = clock();
        clock_t elapsed = current_tick - previous_tick;
        int8_t move_axis;
        int8_t turn_axis;
        uint8_t buttons = 0;
        uint8_t fps_changed = 0;
        uint24_t fps_elapsed;

        previous_tick = current_tick;
        accumulated_ticks += (uint24_t)elapsed;
        fps_elapsed = (uint24_t)(current_tick - fps_window_start);
        if (fps_elapsed >= (uint24_t)CLOCKS_PER_SEC) {
            uint24_t measured =
                (rendered_frames * (uint24_t)CLOCKS_PER_SEC) / fps_elapsed;
            if (measured > 255u) measured = 255u;
            displayed_fps = (uint8_t)measured;
            rendered_frames = 0;
            fps_window_start = current_tick;
            fps_changed = 1;
        }
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
            if (changed || fps_changed) {
                game_render(&game, displayed_fps);
                gfx_SwapDraw();
                ++rendered_frames;
            }
        }
    }

    kb_Reset();
    gfx_End();
    return 0;
}
