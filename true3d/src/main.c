#include "engine.h"

#include <graphx.h>
#include <keypadc.h>
#include <time.h>

#define UPDATE_RATE 60u

static EngineState engine;
static True3DLevelView level;
static True3DLevelSource level_source;

_Static_assert(
    sizeof(EngineState) + 4096u < 150u * 1024u,
    "Player state plus reserved CEdev stack exceeds 150 KiB"
);

int main(void) {
    clock_t previous_tick;
    clock_t fps_window_start;
    uint24_t accumulated_ticks = 0;
    uint24_t rendered_frames = 1;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);
    uint8_t displayed_fps = 0;

    if (!true3d_level_open(&level, &level_source) || !engine_init(&engine, &level)) {
        true3d_level_close(&level_source);
        return 1;
    }
    gfx_Begin();
    gfx_SetDrawBuffer();
    engine_graphics_init();
    engine_render(&engine, displayed_fps);
    gfx_SwapDraw();

    kb_SetMode(MODE_3_CONTINUOUS);
    previous_tick = clock();
    fps_window_start = previous_tick;

    while ((kb_Data[6] & kb_Clear) == 0) {
        clock_t current_tick = clock();
        clock_t elapsed = current_tick - previous_tick;
        int8_t move_axis;
        int8_t turn_axis;
        int8_t look_axis;
        uint8_t buttons = 0;
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
        }

        move_axis = (int8_t)(
            ((kb_Data[7] & kb_Up) != 0) - ((kb_Data[7] & kb_Down) != 0)
        );
        turn_axis = (int8_t)(
            ((kb_Data[7] & kb_Right) != 0) - ((kb_Data[7] & kb_Left) != 0)
        );
        look_axis = (int8_t)(
            ((kb_Data[1] & kb_Yequ) != 0) - ((kb_Data[1] & kb_Window) != 0)
        );
        if ((kb_Data[1] & kb_2nd) != 0) buttons |= ENGINE_BUTTON_JUMP;
        if ((kb_Data[2] & kb_Alpha) != 0) buttons |= ENGINE_BUTTON_ORANGE_PORTAL;
        if ((kb_Data[1] & kb_Mode) != 0) buttons |= ENGINE_BUTTON_BLUE_PORTAL;
        if ((kb_Data[1] & kb_Graph) != 0) buttons |= ENGINE_BUTTON_DEV_MODE;
        if ((kb_Data[1] & kb_Del) != 0) buttons |= ENGINE_BUTTON_FLY_DOWN;
        if ((kb_Data[1] & kb_Zoom) != 0) buttons |= ENGINE_BUTTON_RESOLUTION;

        if (accumulated_ticks >= update_ticks) {
            uint8_t changed = engine_update(
                &engine,
                move_axis,
                turn_axis,
                look_axis,
                buttons,
                accumulated_ticks,
                (uint24_t)CLOCKS_PER_SEC
            );
            accumulated_ticks = 0;
            if (changed) {
                engine_render(&engine, displayed_fps);
                gfx_SwapDraw();
                ++rendered_frames;
            }
        }
    }

    kb_Reset();
    gfx_End();
    true3d_level_close(&level_source);
    return 0;
}
