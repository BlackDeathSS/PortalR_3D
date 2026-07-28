#include "benchmark.h"
#include "game.h"

#include <fileioc.h>
#include <graphx.h>
#include <stdint.h>
#include <string.h>
#include <sys/timers.h>
#include <ti/getcsc.h>
#include <ti/screen.h>
#include <time.h>

#ifndef RENDER_BENCHMARK
#define RENDER_BENCHMARK 0
#endif
#ifndef BENCHMARK_AUTOTEST_HOLD
#define BENCHMARK_AUTOTEST_HOLD 0
#endif
#ifndef RENDER_LIVE_BENCHMARK
#define RENDER_LIVE_BENCHMARK 0
#endif

#if RENDER_BENCHMARK && !RENDER_LIVE_BENCHMARK

#define BENCHMARK_MAGIC "P3DBEN2"
#define BENCHMARK_RESULT_NAME "P3DRES"
#define BENCHMARK_TEMP_NAME "P3DTMP"

#define BENCHMARK_HEADER_SIZE 64u
#define BENCHMARK_SCENE_RECORD_SIZE 40u
#define BENCHMARK_SAMPLE_RECORD_SIZE 80u
#define BENCHMARK_SCENE_COUNT 6u
#define BENCHMARK_WARMUPS 2u
#define BENCHMARK_CLEAN_SAMPLES 8u
#define BENCHMARK_DETAIL_SAMPLES 4u
#define BENCHMARK_SAMPLES_PER_SCENE \
    (BENCHMARK_CLEAN_SAMPLES + BENCHMARK_DETAIL_SAMPLES)
#define BENCHMARK_SAMPLE_COUNT \
    (BENCHMARK_SCENE_COUNT * BENCHMARK_SAMPLES_PER_SCENE)
#define BENCHMARK_REPORT_SIZE \
    (BENCHMARK_HEADER_SIZE + \
        BENCHMARK_SCENE_COUNT * BENCHMARK_SCENE_RECORD_SIZE + \
        BENCHMARK_SAMPLE_COUNT * BENCHMARK_SAMPLE_RECORD_SIZE)

#define BENCHMARK_FIXED_ONE 256
#define BENCHMARK_ANGLE_SHIFT 8
#define BENCHMARK_TRACE_TIMER_HZ CLOCKS_PER_SEC
#define BENCHMARK_SUITE_FINGERPRINT 0xB203060EUL

#define BENCHMARK_FLAG_STAGE_TIMINGS  (1UL << 0)
#define BENCHMARK_FLAG_FRAME_HASH     (1UL << 1)
#define BENCHMARK_FLAG_SWAP_SAMPLES   (1UL << 2)
#define BENCHMARK_FLAG_ARCHIVE_RESULT (1UL << 3)
#define BENCHMARK_FLAG_CYCLE_TRACE    (1UL << 4)
#define BENCHMARK_FLAG_CLEAN_SAMPLES  (1UL << 5)
#define BENCHMARK_FLAG_SWITCH_COST_Q8 (1UL << 6)

#define BENCHMARK_SCENE_CUSTOM_PORTALS (1u << 0)
#define BENCHMARK_SAMPLE_DETAILED      (1u << 0)

enum BenchmarkDirection {
    BENCHMARK_DIR_NORTH = 0,
    BENCHMARK_DIR_SOUTH = 1
};

typedef struct {
    uint8_t id;
    uint8_t flags;
    char name[13];
    fixed_t player_x;
    fixed_t player_y;
    uint16_t angle;
    Portal primary;
    Portal secondary;
} BenchmarkScene;

static const BenchmarkScene benchmark_scenes[BENCHMARK_SCENE_COUNT] = {
    {
        1, 0, "NEAR_WALL",
        384, 384, 32u << BENCHMARK_ANGLE_SHIFT,
        {0, 0, 0, 0}, {0, 0, 0, 0}
    },
    {
        2, 0, "MID_DIRECT",
        2432, 640, 48u << BENCHMARK_ANGLE_SHIFT,
        {0, 0, 0, 0}, {0, 0, 0, 0}
    },
    {
        3, 0, "LONG_DDA",
        896, 384, 6u << BENCHMARK_ANGLE_SHIFT,
        {0, 0, 0, 0}, {0, 0, 0, 0}
    },
    {
        4, 0, "PORTAL_CHAIN",
        384, 640, 32u << BENCHMARK_ANGLE_SHIFT,
        {0, 0, 0, 0}, {0, 0, 0, 0}
    },
    {
        5, 0, "PORTAL_WIDE",
        1920, 1920, 0,
        {0, 0, 0, 0}, {0, 0, 0, 0}
    },
    {
        6, BENCHMARK_SCENE_CUSTOM_PORTALS, "CUSTOM_PAIR",
        384, 384, 32u << BENCHMARK_ANGLE_SHIFT,
        {0, 1, BENCHMARK_DIR_SOUTH, 1},
        {14, 10, BENCHMARK_DIR_NORTH, 1}
    }
};

static uint8_t benchmark_report[BENCHMARK_REPORT_SIZE];
static GameState benchmark_game;

extern const uint8_t _start[];
extern const uint8_t __data_low[];

_Static_assert(BENCHMARK_REPORT_SIZE < 65536u,
    "Benchmark report must fit in one AppVar write");
_Static_assert(GAME_RENDER_BENCH_CATEGORY_COUNT == 7,
    "Benchmark binary format requires seven render categories");

static void write_u16(uint8_t *destination, uint16_t value) {
    destination[0] = (uint8_t)value;
    destination[1] = (uint8_t)(value >> 8);
}

static void write_u24(uint8_t *destination, int32_t value) {
    uint32_t raw = (uint32_t)value & 0xFFFFFFUL;

    destination[0] = (uint8_t)raw;
    destination[1] = (uint8_t)(raw >> 8);
    destination[2] = (uint8_t)(raw >> 16);
}

static void write_u32(uint8_t *destination, uint32_t value) {
    destination[0] = (uint8_t)value;
    destination[1] = (uint8_t)(value >> 8);
    destination[2] = (uint8_t)(value >> 16);
    destination[3] = (uint8_t)(value >> 24);
}

static uint16_t clamp_u16(uint32_t value) {
    return value > 65535UL ? 65535u : (uint16_t)value;
}

static uint32_t benchmark_crc32(const uint8_t *data, uint16_t size) {
    uint32_t crc = 0xFFFFFFFFUL;
    uint16_t index;

    for (index = 0; index < size; ++index) {
        uint8_t bit;

        crc ^= data[index];
        for (bit = 0; bit < 8; ++bit) {
            uint32_t mask = (uint32_t)-(int32_t)(crc & 1u);

            crc = (crc >> 1) ^ (0xEDB88320UL & mask);
        }
    }
    return ~crc;
}

static uint32_t benchmark_frame_hash(void) {
    const uint8_t *pixels = &gfx_vbuffer[0][0];
    uint32_t hash = 2166136261UL;
    uint24_t index;

    for (index = 0; index < GFX_LCD_WIDTH * GFX_LCD_HEIGHT; ++index) {
        hash ^= pixels[index];
        hash *= 16777619UL;
    }
    return hash;
}

static uint32_t benchmark_build_fingerprint(void) {
    const uint8_t *cursor = _start;
    uint32_t hash = 2166136261UL;

    while (cursor != __data_low) {
        hash ^= *cursor++;
        hash *= 16777619UL;
    }
    return hash;
}

static void benchmark_load_scene(const BenchmarkScene *scene) {
    benchmark_game.player_x = scene->player_x;
    benchmark_game.player_y = scene->player_y;
    benchmark_game.angle = scene->angle;
    benchmark_game.primary = scene->primary;
    benchmark_game.secondary = scene->secondary;
    benchmark_game.previous_buttons = 0;
}

static uint8_t *benchmark_scene_record(uint8_t scene_index) {
    return benchmark_report + BENCHMARK_HEADER_SIZE +
        (uint16_t)scene_index * BENCHMARK_SCENE_RECORD_SIZE;
}

static uint8_t *benchmark_sample_record(uint16_t sample_index) {
    return benchmark_report + BENCHMARK_HEADER_SIZE +
        BENCHMARK_SCENE_COUNT * BENCHMARK_SCENE_RECORD_SIZE +
        sample_index * BENCHMARK_SAMPLE_RECORD_SIZE;
}

static void benchmark_write_scene(
    uint8_t scene_index,
    const BenchmarkScene *scene
) {
    uint8_t *record = benchmark_scene_record(scene_index);
    uint8_t name_length = (uint8_t)strlen(scene->name);

    if (name_length > 12u) name_length = 12u;
    record[0] = scene->id;
    record[1] = scene->flags;
    write_u16(record + 2, BENCHMARK_SAMPLES_PER_SCENE);
    write_u16(
        record + 4,
        (uint16_t)scene_index * BENCHMARK_SAMPLES_PER_SCENE
    );
    write_u24(record + 12, scene->player_x);
    write_u24(record + 15, scene->player_y);
    write_u16(record + 18, scene->angle);
    memcpy(record + 20, &scene->primary, sizeof(Portal));
    memcpy(record + 24, &scene->secondary, sizeof(Portal));
    memcpy(record + 28, scene->name, name_length);
}

static void benchmark_write_sample(
    uint16_t sample_index,
    uint8_t detailed,
    clock_t total_ticks,
    const GameRenderProfile *profile,
    const GameRenderBenchmark *detail
) {
    uint8_t *record = benchmark_sample_record(sample_index);
    uint8_t category;

    write_u32(record + 0, total_ticks);
    write_u32(record + 4, profile->wait_ticks);
    write_u32(record + 8, profile->background_ticks);
    write_u32(record + 12, profile->columns_ticks);
    write_u16(record + 16, profile->cast_count);
    record[18] = profile->max_depth;
    record[19] = detailed ? BENCHMARK_SAMPLE_DETAILED : 0;

    if (!detailed || detail == NULL) {
        return;
    }

    write_u32(record + 20, detail->total_ticks);
    for (category = 0;
         category < GAME_RENDER_BENCH_CATEGORY_COUNT;
         ++category) {
        write_u32(record + 24 + category * 4, detail->raw_ticks[category]);
        write_u16(record + 52 + category * 2, detail->entries[category]);
    }
    write_u16(record + 66, detail->portal_transforms);
    write_u16(record + 68, detail->wall_calls);
    write_u16(record + 70, detail->mask_calls);
    write_u16(record + 72, detail->portal_candidates);
    write_u16(record + 74, detail->linked_exits);
    write_u16(record + 76, clamp_u16(detail->textured_rows));
    write_u16(record + 78, clamp_u16(detail->dda_steps));
}

static void benchmark_render_progress(
    uint8_t scene_index,
    const char *phase
) {
    gfx_SetColor(0);
    gfx_FillScreen(0);
    gfx_SetTextFGColor(15);
    gfx_SetTextBGColor(0);
    gfx_SetTextTransparentColor(0);
    gfx_SetTextScale(1, 1);
    gfx_PrintStringXY("PortalR benchmark", 8, 8);
    gfx_PrintStringXY("Scene", 8, 32);
    gfx_PrintUInt((uint24_t)scene_index + 1u, 1);
    gfx_PrintString("/");
    gfx_PrintUInt(BENCHMARK_SCENE_COUNT, 1);
    gfx_PrintStringXY(benchmark_scenes[scene_index].name, 8, 48);
    gfx_PrintStringXY(phase, 8, 72);
    gfx_PrintStringXY("80 rays / full detail", 8, 96);
    gfx_SwapDraw();
}

static void benchmark_render_sample(uint16_t sample_index, uint8_t detailed) {
    clock_t started;
    clock_t elapsed;
    GameRenderProfile profile;
    const GameRenderBenchmark *detail = NULL;

    game_render_benchmark_reset();
    started = clock();
    if (detailed) {
        game_render_benchmark_begin();
    }
    game_render(&benchmark_game);
    if (detailed) {
        game_render_benchmark_end();
        detail = game_render_benchmark_read();
    }
    elapsed = clock() - started;
    profile = *game_get_render_profile();
    benchmark_write_sample(
        sample_index, detailed, elapsed, &profile, detail
    );
    gfx_SwapDraw();
}

static void benchmark_write_header(uint32_t switch_cost_q8) {
    uint8_t *header = benchmark_report;
    uint32_t flags =
        BENCHMARK_FLAG_STAGE_TIMINGS |
        BENCHMARK_FLAG_FRAME_HASH |
        BENCHMARK_FLAG_SWAP_SAMPLES |
        BENCHMARK_FLAG_ARCHIVE_RESULT |
        BENCHMARK_FLAG_CYCLE_TRACE |
        BENCHMARK_FLAG_CLEAN_SAMPLES |
        BENCHMARK_FLAG_SWITCH_COST_Q8;
    uint32_t body_crc;

    memcpy(header, BENCHMARK_MAGIC, 7);
    write_u16(header + 8, 2);
    write_u16(header + 10, BENCHMARK_HEADER_SIZE);
    write_u32(header + 12, flags);
    write_u32(header + 16, CLOCKS_PER_SEC);
    write_u32(header + 20, BENCHMARK_TRACE_TIMER_HZ);
    write_u32(header + 24, benchmark_build_fingerprint());
    write_u32(header + 28, BENCHMARK_SUITE_FINGERPRINT);
    write_u16(header + 32, BENCHMARK_REPORT_SIZE);
    write_u16(header + 34, BENCHMARK_SCENE_COUNT);
    write_u16(header + 36, BENCHMARK_WARMUPS);
    write_u16(header + 38, BENCHMARK_SAMPLES_PER_SCENE);
    write_u16(header + 40, BENCHMARK_SCENE_RECORD_SIZE);
    write_u16(header + 42, BENCHMARK_SAMPLE_RECORD_SIZE);
    write_u16(header + 44, GAME_RENDER_LOGICAL_COLUMNS);
    header[46] = GAME_RENDER_COLUMN_WIDTH;
    header[47] = GAME_RENDER_TEXTURE_SIZE;
    header[48] = GAME_RENDER_MAX_PORTAL_DEPTH;
    header[49] = 1;
    header[50] = GAME_RENDER_BENCH_CATEGORY_COUNT;
    write_u32(header + 52, switch_cost_q8);

    body_crc = benchmark_crc32(
        benchmark_report + BENCHMARK_HEADER_SIZE,
        BENCHMARK_REPORT_SIZE - BENCHMARK_HEADER_SIZE
    );
    write_u32(header + 56, body_crc);
}

static uint8_t benchmark_save_result(void) {
    uint8_t handle;

    (void)ti_Delete(BENCHMARK_TEMP_NAME);
    handle = ti_Open(BENCHMARK_TEMP_NAME, "w");
    if (handle == 0) {
        return 0;
    }
    if (ti_Write(
            benchmark_report,
            BENCHMARK_REPORT_SIZE,
            1,
            handle
        ) != 1 ||
        ti_GetSize(handle) != BENCHMARK_REPORT_SIZE) {
        ti_Close(handle);
        return 0;
    }
    ti_Close(handle);

    (void)ti_Delete(BENCHMARK_RESULT_NAME);
    if (ti_Rename(BENCHMARK_TEMP_NAME, BENCHMARK_RESULT_NAME) != 0) {
        return 0;
    }
    return 1;
}

#if !BENCHMARK_AUTOTEST_HOLD
static uint8_t benchmark_archive_result(void) {
    uint8_t handle = ti_Open(BENCHMARK_RESULT_NAME, "r+");
    uint8_t archived;

    if (handle == 0) {
        return 0;
    }
    archived = ti_SetArchiveStatus(true, handle) != 0;
    ti_Close(handle);
    return archived;
}
#endif

static void benchmark_show_result(uint8_t saved, uint8_t archived) {
    os_ClrHome();
    os_SetCursorPos(0, 0);
    os_PutStrFull(saved ? "Benchmark complete" : "Benchmark failed");
    if (saved) {
        os_SetCursorPos(2, 0);
        os_PutStrFull("Result: P3DRES");
        os_SetCursorPos(3, 0);
        os_PutStrFull(archived ? "Archived safely" : "Saved in RAM");
        os_SetCursorPos(5, 0);
        os_PutStrFull("Send P3DRES.8xv");
        os_SetCursorPos(6, 0);
        os_PutStrFull("back to Codex.");
    } else {
        os_SetCursorPos(2, 0);
        os_PutStrFull("Could not save");
        os_SetCursorPos(3, 0);
        os_PutStrFull("the result AppVar.");
    }
    os_SetCursorPos(8, 0);
    os_PutStrFull("Press any key");
    while (os_GetCSC() != 0) {
    }
    while (os_GetCSC() == 0) {
    }
}

int benchmark_run(void) {
    uint16_t saved_timer_control;
    uint32_t saved_timer_count;
    uint32_t switch_cost_q8;
    uint8_t scene_index;
    uint8_t saved;
    uint8_t archived = 0;

    memset(benchmark_report, 0, sizeof(benchmark_report));

    saved_timer_control = timer_Control;
    saved_timer_count = timer_GetSafe(
        3,
        (saved_timer_control & TIMER3_UP) != 0 ? TIMER_UP : TIMER_DOWN
    );
    timer_Disable(3);
    timer_Set(3, 0);
    timer_Enable(3, TIMER_32K, TIMER_NOINT, TIMER_UP);

    gfx_Begin();
    gfx_SetDrawBuffer();
    game_graphics_init();
    switch_cost_q8 = game_render_benchmark_calibrate();

    for (scene_index = 0;
         scene_index < BENCHMARK_SCENE_COUNT;
         ++scene_index) {
        const BenchmarkScene *scene = &benchmark_scenes[scene_index];
        uint16_t first_sample =
            (uint16_t)scene_index * BENCHMARK_SAMPLES_PER_SCENE;
        uint8_t sample;
        uint32_t frame_hash;

        benchmark_load_scene(scene);
        benchmark_write_scene(scene_index, scene);
        benchmark_render_progress(scene_index, "Warming up...");
        for (sample = 0; sample < BENCHMARK_WARMUPS; ++sample) {
            game_render_benchmark_reset();
            game_render(&benchmark_game);
            gfx_SwapDraw();
        }

        benchmark_render_progress(scene_index, "Clean timing...");
        for (sample = 0; sample < BENCHMARK_CLEAN_SAMPLES; ++sample) {
            benchmark_render_sample(first_sample + sample, 0);
        }

        benchmark_render_progress(scene_index, "Cycle trace...");
        for (sample = 0; sample < BENCHMARK_DETAIL_SAMPLES; ++sample) {
            benchmark_render_sample(
                first_sample + BENCHMARK_CLEAN_SAMPLES + sample,
                1
            );
        }

        game_render_benchmark_reset();
        game_render(&benchmark_game);
        frame_hash = benchmark_frame_hash();
        write_u32(benchmark_scene_record(scene_index) + 8, frame_hash);
        gfx_SwapDraw();
    }

    benchmark_write_header(switch_cost_q8);
    saved = benchmark_save_result();
    gfx_End();
    if (saved) {
#if BENCHMARK_AUTOTEST_HOLD
        archived = 0;
#else
        archived = benchmark_archive_result();
#endif
    }
#if BENCHMARK_AUTOTEST_HOLD
    for (;;) {
    }
#endif

    timer_Disable(3);
    timer_Set(3, saved_timer_count);
    timer_Control = saved_timer_control;

    benchmark_show_result(saved, archived);
    return saved ? 0 : 1;
}

#endif
