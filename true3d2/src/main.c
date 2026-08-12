#include "internal.h"

#include <fileioc.h>
#include <graphx.h>
#include <keypadc.h>
#include <time.h>

#if T3D2_KERNEL_BENCHMARK

int main(void) {
    return t3d2_kernel_benchmark_run();
}

#else

static T3D2Engine engine;

static void install_development_palette(void) {
    uint16_t index;

    for (index = 0; index < 256u; ++index) {
        uint8_t bank = (uint8_t)(index / 60u);
        uint8_t value = (uint8_t)(index % 60u);
        uint8_t red = (uint8_t)((value * 31u) / 59u);
        uint8_t green = (uint8_t)(((59u - value) * 31u) / 59u);
        uint8_t blue = (uint8_t)(((value ^ 31u) * 31u) / 63u);

        red = (uint8_t)(red * (4u - (bank > 3u ? 3u : bank)) / 4u);
        green = (uint8_t)(green * (4u - (bank > 3u ? 3u : bank)) / 4u);
        blue = (uint8_t)(blue * (4u - (bank > 3u ? 3u : bank)) / 4u);
        gfx_palette[index] = (uint16_t)(red << 10 | green << 5 | blue);
    }
    gfx_palette[10] = (uint16_t)(4u << 10 | 14u << 5 | 31u);
    gfx_palette[11] = (uint16_t)(31u << 10 | 17u << 5 | 2u);
    gfx_palette[240] = 0u;
    gfx_palette[243] = 0x7FFFu;
}

static void install_scene_palette(void) {
    uint16_t index;

    for (index = 0; index < 256u; ++index) {
        gfx_palette[index] = engine.scene.palette[index];
    }
}

static void show_status_and_wait(uint8_t status) {
    gfx_FillScreen(240u);
    gfx_SetTextFGColor(243u);
    gfx_PrintStringXY("True3D2 cannot start", 8, 24);
    if (status == T3D2_ERROR_SCENE_MISSING) {
        gfx_PrintStringXY("T3D2MAP is missing.", 8, 48);
        gfx_PrintStringXY("Transfer all scene AppVars.", 8, 64);
    } else {
        gfx_PrintStringXY("Scene/resource error:", 8, 48);
        gfx_PrintUInt(status, 2);
    }
    gfx_PrintStringXY("Press Clear to exit.", 8, 96);
    gfx_SwapDraw();
    do {
        kb_Scan();
    } while (!kb_IsDown(kb_KeyClear));
}

int main(void) {
    ti_var_t scene_slot = 0u;
    clock_t previous;
    clock_t wall_started;
    uint24_t accumulated = 0u;
    uint8_t scene_status = T3D2_ERROR_SCENE_MISSING;
    const uint24_t tick_interval = (uint24_t)(CLOCKS_PER_SEC / T3D2_TICK_RATE);

    if (t3d2_boot(&engine) != T3D2_OK) return 1;
    scene_slot = ti_Open("T3D2MAP", "r");
    if (scene_slot != 0u) {
        void *scene_data = ti_GetDataPtr(scene_slot);
        uint24_t scene_size = ti_GetSize(scene_slot);

        scene_status = t3d2_load_scene(&engine, scene_data, scene_size);
    }
    gfx_Begin();
    gfx_SetDrawBuffer();
    if (engine.scene_loaded != 0u) install_scene_palette();
    else install_development_palette();
    if (scene_status != T3D2_OK) {
        show_status_and_wait(scene_status);
        kb_Reset();
        gfx_End();
        if (scene_slot != 0u) ti_Close(scene_slot);
        t3d2_shutdown(&engine);
        return scene_status;
    }
    gfx_FillScreen(240u);
    gfx_SetTextFGColor(243u);
    gfx_PrintStringXY("Loading True3D2 scene...", 8, 24);
    gfx_SwapDraw();
    kb_SetMode(MODE_3_CONTINUOUS);
    wall_started = clock();
    previous = wall_started;
    t3d2_render(&engine);
    gfx_SwapDraw();

    while (1) {
        clock_t now = clock();
        uint8_t input;
        uint8_t buttons;
        int8_t move_axis;
        int8_t turn_axis;
        uint8_t updated = 0u;

        t3d2_input_poll(&engine);
        if (engine.exit_requested != 0u) break;
        input = engine.input_latch;
        accumulated += (uint24_t)(now - previous);
        if (accumulated > tick_interval * 6u) accumulated = tick_interval * 6u;
        previous = now;
        move_axis = (int8_t)(((input & T3D2_INPUT_UP) != 0u) -
                             ((input & T3D2_INPUT_DOWN) != 0u));
        turn_axis = (int8_t)(((input & T3D2_INPUT_RIGHT) != 0u) -
                             ((input & T3D2_INPUT_LEFT) != 0u));
        buttons = input & (T3D2_BUTTON_JUMP | T3D2_BUTTON_PORTAL_A |
                           T3D2_BUTTON_PORTAL_B | T3D2_BUTTON_CANCEL_PORTALS);
        while (accumulated >= tick_interval) {
            (void)t3d2_tick(&engine, move_axis, turn_axis, buttons,
                            tick_interval, (uint24_t)CLOCKS_PER_SEC);
            accumulated -= tick_interval;
            updated = 1u;
        }
        if (updated != 0u) {
            /* Keep one-frame action presses latched until at least one fixed
               simulation step has consumed them. */
            engine.input_latch = 0u;
            t3d2_render(&engine);
            gfx_SwapDraw();
        }
#if T3D2_RUNTIME_AUTOTEST
        if (engine.benchmark.frame_count >= 120u ||
            (uint32_t)(clock() - wall_started) >= 15UL * CLOCKS_PER_SEC) {
            break;
        }
#endif
    }
    {
        uint32_t wall_ticks = (uint32_t)(clock() - wall_started);

        kb_Reset();
        gfx_End();
        if (scene_slot != 0u) ti_Close(scene_slot);
        (void)t3d2_runtime_report_write(&engine, wall_ticks);
    }
    t3d2_shutdown(&engine);
    return 0;
}

#endif
