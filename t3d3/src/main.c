#include "engine.h"

#ifndef TRUE3D_LIVE_BENCHMARK
#define TRUE3D_LIVE_BENCHMARK 0
#endif

#if TRUE3D_LIVE_BENCHMARK

#include "live_benchmark.h"

int main(void) {
    return true3d_live_benchmark_run();
}

#else

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
    clock_t fps_smoothed_ticks = 0;
    uint24_t accumulated_ticks = 0;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);
    uint16_t fps_tenths = 0;
    uint8_t previous_trace = 0;
    uint8_t pending_toggles = 0;

    if (!true3d_level_open(&level, &level_source) || !engine_init(&engine, &level)) {
        true3d_level_close(&level_source);
        return 1;
    }
    gfx_Begin();
    gfx_SetDrawBuffer();
    engine_graphics_init();
    {
        clock_t started = clock();

        engine_render(&engine, fps_tenths);
        gfx_SwapDraw();
        fps_smoothed_ticks = clock() - started;
        if (fps_smoothed_ticks != 0) {
            uint24_t measured = (uint24_t)(
                (CLOCKS_PER_SEC * 10UL + fps_smoothed_ticks / 2u) /
                fps_smoothed_ticks
            );

            fps_tenths = (uint16_t)(measured > 9999u ? 9999u : measured);
        }
    }

    kb_SetMode(MODE_3_CONTINUOUS);
    previous_tick = clock();

    while ((kb_Data[6] & kb_Clear) == 0) {
        clock_t current_tick = clock();
        clock_t elapsed = current_tick - previous_tick;
        int8_t move_axis;
        int8_t turn_axis;
        int8_t look_axis;
        uint8_t buttons = 0;
        uint8_t trace;

        previous_tick = current_tick;
        accumulated_ticks += (uint24_t)elapsed;

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
        if ((kb_Data[2] & kb_Math) != 0) buttons |= ENGINE_BUTTON_OBJECT_USE;
        if ((kb_Data[5] & kb_Vars) != 0) buttons |= ENGINE_BUTTON_OBJECT_THROW;
        trace = (uint8_t)((kb_Data[1] & kb_Trace) != 0);
        if (trace && !previous_trace) pending_toggles |= ENGINE_TOGGLE_NOCLIP;
        previous_trace = trace;

        if (accumulated_ticks >= update_ticks) {
            uint8_t changed = engine_update(
                &engine,
                move_axis,
                turn_axis,
                look_axis,
                buttons,
                pending_toggles,
                accumulated_ticks,
                (uint24_t)CLOCKS_PER_SEC
            );
            pending_toggles = 0;
            accumulated_ticks = 0;
            if (changed) {
                clock_t started = clock();
                clock_t frame_ticks;
                uint24_t measured;

                engine_render(&engine, fps_tenths);
                gfx_SwapDraw();
                frame_ticks = clock() - started;
                if (frame_ticks != 0) {
                    /* Quarter-weight EMA matches Portal3D's stable overlay. */
                    fps_smoothed_ticks =
                        (fps_smoothed_ticks * 3u + frame_ticks + 2u) / 4u;
                    measured = (uint24_t)(
                        (CLOCKS_PER_SEC * 10UL + fps_smoothed_ticks / 2u) /
                        fps_smoothed_ticks
                    );
                    fps_tenths = (uint16_t)(
                        measured > 9999u ? 9999u : measured
                    );
                }
            }
        }
    }

    kb_Reset();
    gfx_End();
    true3d_level_close(&level_source);
    return 0;
}

#endif
