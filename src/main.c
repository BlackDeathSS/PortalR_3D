#include "game.h"

#ifndef RENDER_BENCHMARK
#define RENDER_BENCHMARK 0
#endif
#ifndef RENDER_LIVE_BENCHMARK
#define RENDER_LIVE_BENCHMARK 0
#endif

#if RENDER_LIVE_BENCHMARK

#include "live_benchmark.h"

int main(void) {
    return live_benchmark_run();
}

#elif RENDER_BENCHMARK

#include "benchmark.h"

int main(void) {
    return benchmark_run();
}

#else

#include <graphx.h>
#include <keypadc.h>
#include <time.h>

#define UPDATE_RATE 60u

#ifndef RENDER_PROFILE
#define RENDER_PROFILE 0
#endif

static GameState game;

static void draw_level_menu(uint8_t selected) {
    uint8_t first = selected >= 7u ? (uint8_t)(selected - 6u) : 0u;
    uint8_t index;

    gfx_FillScreen(0);
    gfx_SetTextFGColor(15);
    gfx_SetTextBGColor(0);
    gfx_SetTextTransparentColor(0);
    gfx_SetTextScale(2, 2);
    gfx_PrintStringXY("PORTAL3D", 12, 12);
    gfx_SetTextScale(1, 1);
    gfx_SetTextFGColor(12);
    gfx_PrintStringXY("CHOOSE A LEVEL", 14, 38);
    for (index = first; index < portal3d_level_count && index < first + 7u; ++index) {
        uint8_t y = (uint8_t)(60u + (index - first) * 22u);
        if (index == selected) {
            gfx_SetColor(4);
            gfx_FillRectangle_NoClip(10, (uint8_t)(y - 5u), 300, 18);
            gfx_SetTextFGColor(15);
            gfx_PrintStringXY(">", 16, y);
        } else {
            gfx_SetTextFGColor(12);
        }
        gfx_PrintStringXY(game_level_name(index), 30, y);
    }
    gfx_SetTextFGColor(8);
    gfx_PrintStringXY("UP/DOWN: SELECT   2ND: PLAY   CLEAR: EXIT", 12, 222);
    gfx_SwapDraw();
}

static uint8_t select_level(void) {
    uint8_t selected = 0;
    uint8_t previous = 0;

    draw_level_menu(selected);
    for (;;) {
        uint8_t keys;
        kb_Scan();
        keys = (uint8_t)(
            ((kb_Data[7] & kb_Up) != 0 ? 1u : 0u) |
            ((kb_Data[7] & kb_Down) != 0 ? 2u : 0u) |
            ((kb_Data[1] & kb_2nd) != 0 ? 4u : 0u) |
            ((kb_Data[6] & kb_Clear) != 0 ? 8u : 0u)
        );
        if ((keys & 1u) != 0 && (previous & 1u) == 0) {
            selected = selected == 0u ? (uint8_t)(portal3d_level_count - 1u) :
                (uint8_t)(selected - 1u);
            draw_level_menu(selected);
        }
        if ((keys & 2u) != 0 && (previous & 2u) == 0) {
            selected = (uint8_t)((selected + 1u) % portal3d_level_count);
            draw_level_menu(selected);
        }
        if ((keys & 4u) != 0 && (previous & 4u) == 0) return selected;
        if ((keys & 8u) != 0) return 0xFFu;
        previous = keys;
    }
}

#if RENDER_PROFILE
static uint24_t ticks_to_milliseconds(clock_t ticks) {
    return (uint24_t)((ticks * 1000UL) / CLOCKS_PER_SEC);
}

static void print_profile_value(
    const char *label,
    uint24_t x,
    uint8_t y,
    uint24_t value,
    uint8_t width
) {
    gfx_PrintStringXY(label, x, y);
    gfx_SetTextXY(x + 8, y);
    gfx_PrintUInt(value, width);
}
#else
#define FPS_OVERLAY_X 248
#define FPS_OVERLAY_Y 2
#define FPS_OVERLAY_BOX_X 244
#define FPS_OVERLAY_BOX_WIDTH 76
#define FPS_OVERLAY_BOX_HEIGHT 12

static uint8_t fps_overlay_enabled;
static clock_t fps_smoothed_ticks;
static uint16_t fps_tenths;

static void fps_overlay_toggle(void) {
    fps_overlay_enabled ^= 1u;
    fps_smoothed_ticks = 0;
    fps_tenths = 0;
}

static void fps_overlay_draw(void) {
    uint16_t whole_fps;
    uint8_t digits;

    gfx_SetColor(0);
    gfx_FillRectangle_NoClip(
        FPS_OVERLAY_BOX_X,
        0,
        FPS_OVERLAY_BOX_WIDTH,
        FPS_OVERLAY_BOX_HEIGHT
    );
    gfx_SetTextFGColor(15);
    gfx_SetTextBGColor(0);
    gfx_SetTextTransparentColor(0);
    gfx_SetTextScale(1, 1);

    if (fps_tenths == 0) {
        gfx_PrintStringXY("FPS --.-", FPS_OVERLAY_X, FPS_OVERLAY_Y);
        return;
    }

    whole_fps = fps_tenths / 10u;
    digits = whole_fps >= 100u ? 3u : (whole_fps >= 10u ? 2u : 1u);
    gfx_PrintStringXY("FPS ", FPS_OVERLAY_X, FPS_OVERLAY_Y);
    gfx_PrintUInt(whole_fps, digits);
    gfx_PrintChar('.');
    gfx_PrintUInt(fps_tenths % 10u, 1);
}

static void fps_overlay_record(clock_t elapsed) {
    uint24_t measured_fps;

    if (elapsed == 0) {
        return;
    }

    if (fps_smoothed_ticks == 0) {
        fps_smoothed_ticks = elapsed;
    } else {
        /* A quarter-weight EMA is responsive without making the text jitter. */
        fps_smoothed_ticks =
            (fps_smoothed_ticks * 3u + elapsed + 2u) / 4u;
    }

    measured_fps = (uint24_t)(
        (CLOCKS_PER_SEC * 10UL + fps_smoothed_ticks / 2u) /
        fps_smoothed_ticks
    );
    fps_tenths = (uint16_t)(measured_fps > 9999u ? 9999u : measured_fps);
}
#endif

static void render_frame(void) {
#if RENDER_PROFILE
    clock_t started = clock();
    clock_t elapsed;
    const GameRenderProfile *profile;

    game_render(&game);
    elapsed = clock() - started;
    profile = game_get_render_profile();

    gfx_SetColor(0);
#if RENDER_RAY_DIAGNOSTIC
    gfx_FillRectangle_NoClip(0, 0, GFX_LCD_WIDTH, 20);
#else
    gfx_FillRectangle_NoClip(0, 0, 216, 20);
#endif
    gfx_SetTextFGColor(15);
    gfx_SetTextBGColor(0);
    gfx_SetTextTransparentColor(0);
    print_profile_value("T", 2, 1, ticks_to_milliseconds(elapsed), 3);
    print_profile_value("W", 42, 1, ticks_to_milliseconds(profile->wait_ticks), 3);
    print_profile_value("B", 82, 1, ticks_to_milliseconds(profile->background_ticks), 3);
    print_profile_value("C", 122, 1, ticks_to_milliseconds(profile->columns_ticks), 3);
    print_profile_value("R", 2, 11, profile->cast_count, 3);
    print_profile_value("D", 42, 11, profile->max_depth, 1);
#if RENDER_RAY_DIAGNOSTIC
    print_profile_value("A", 62, 11, profile->near_column, 2);
    print_profile_value("L", 90, 11, profile->near_layer, 1);
    print_profile_value("Q", 110, 11, profile->near_raw_distance, 3);
    print_profile_value("P", 146, 11, profile->near_projected_distance, 3);
    print_profile_value("N", 182, 11, profile->near_minor, 3);
    print_profile_value("F", 218, 11, profile->near_origin_fraction, 3);
    print_profile_value("M", 250, 11, profile->near_hit_cell, 3);
    print_profile_value("S", 284, 11, profile->near_side, 1);
    print_profile_value("V", 302, 11, profile->near_valid, 1);
#endif
#else
    clock_t started;

    if (!fps_overlay_enabled) {
        game_render(&game);
        gfx_SwapDraw();
        return;
    }

    started = clock();
    game_render(&game);
    fps_overlay_draw();
    gfx_SwapDraw();
    fps_overlay_record(clock() - started);
#endif
#if RENDER_PROFILE
    gfx_SwapDraw();
#endif
}

int main(void) {
    clock_t previous_tick;
    uint24_t accumulated_ticks = 0;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);
#if !RENDER_PROFILE
    uint8_t f5_was_down = 0;
#endif
    uint8_t selected_level;

    gfx_Begin();
    gfx_SetDrawBuffer();
    selected_level = select_level();
    if (selected_level == 0xFFu || !game_level_select(selected_level)) {
        gfx_End();
        return selected_level == 0xFFu ? 0 : 1;
    }
#if !RENDER_PROFILE
    fps_overlay_enabled = portal3d_always_show_fps;
#endif
    game_graphics_init();
    game_init(&game);

    render_frame();

    kb_SetMode(MODE_3_CONTINUOUS);
    previous_tick = clock();

    while ((kb_Data[6] & kb_Clear) == 0) {
        clock_t current_tick = clock();
        clock_t elapsed = current_tick - previous_tick;
        int8_t move_axis;
        int8_t turn_axis;
        uint8_t buttons = 0;
#if !RENDER_PROFILE
        uint8_t redraw = 0;
        uint8_t f5_is_down;
#endif

        previous_tick = current_tick;
        accumulated_ticks += (uint24_t)elapsed;
        move_axis = (int8_t)(((kb_Data[7] & kb_Up) != 0) - ((kb_Data[7] & kb_Down) != 0));
        turn_axis = (int8_t)(((kb_Data[7] & kb_Right) != 0) - ((kb_Data[7] & kb_Left) != 0));

        if ((kb_Data[1] & kb_2nd) != 0) buttons |= PORTAL_BUTTON_PRIMARY;
        if ((kb_Data[2] & kb_Alpha) != 0) buttons |= PORTAL_BUTTON_SECONDARY;
        if ((kb_Data[1] & kb_Del) != 0) buttons |= PORTAL_BUTTON_CLEAR;
        if ((kb_Data[1] & kb_Mode) != 0) buttons |= GAME_BUTTON_FIRE;
        if ((kb_Data[2] & kb_Math) != 0) buttons |= GAME_BUTTON_USE;
        if ((kb_Data[3] & kb_1) != 0) buttons |= GAME_BUTTON_WEAPON_1;
        if ((kb_Data[4] & kb_2) != 0) buttons |= GAME_BUTTON_WEAPON_2;

#if !RENDER_PROFILE
        /* F5 is the rightmost top-row GRAPH key. */
        f5_is_down = (uint8_t)((kb_Data[1] & kb_Graph) != 0);
        if (!portal3d_always_show_fps && f5_is_down && !f5_was_down) {
            fps_overlay_toggle();
            redraw = 1;
        }
        f5_was_down = f5_is_down;
#endif

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
#if RENDER_PROFILE
            if (changed) {
                render_frame();
            }
#else
            redraw |= changed;
#endif
        }
#if !RENDER_PROFILE
        if (redraw) {
            render_frame();
        }
#endif
    }

    kb_Reset();
    gfx_End();
    return 0;
}

#endif
