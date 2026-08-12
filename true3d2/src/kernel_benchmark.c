#include "internal.h"

#include <fileioc.h>
#include <graphx.h>
#include <string.h>
#include <time.h>

#define KERNEL_REPORT_NAME "T3DKERN"
#define KERNEL_PRESENT_ITERATIONS 8u
#define KERNEL_FLAG_PRESENTER_PASS (1u << 0)
#define KERNEL_FLAG_RASTER_PASS (1u << 1)
#define KERNEL_FLAG_GEOMETRY_PASS (1u << 2)

static uint8_t benchmark_texture_half[32768];

typedef struct __attribute__((packed)) {
    uint8_t magic[8];
    uint8_t version;
    uint8_t flags;
    uint16_t header_size;
    uint32_t build_version;
    uint32_t clock_rate;
    uint16_t presenter_iterations;
    uint16_t raster_samples;
    uint16_t geometry_triangles;
    uint16_t reserved;
    uint32_t presenter_ticks;
    uint32_t raster_ticks;
    uint32_t geometry_ticks;
    uint32_t presenter_hash;
    uint32_t raster_hash;
    uint32_t crc32;
} T3D2KernelReport;

_Static_assert(sizeof(T3D2KernelReport) == 52u, "kernel report layout changed");

static uint8_t write_report(const T3D2KernelReport *report) {
    ti_var_t handle;
    uint8_t *destination;
    uint8_t success;

    (void)ti_Delete(KERNEL_REPORT_NAME);
    handle = ti_Open(KERNEL_REPORT_NAME, "w");
    if (handle == 0u) return 0u;
    if (ti_Resize(sizeof(*report), handle) != sizeof(*report)) {
        ti_Close(handle);
        (void)ti_Delete(KERNEL_REPORT_NAME);
        return 0u;
    }
    destination = (uint8_t *)ti_GetDataPtr(handle);
    if (destination == NULL) {
        ti_Close(handle);
        (void)ti_Delete(KERNEL_REPORT_NAME);
        return 0u;
    }
    memcpy(destination, report, sizeof(*report));
    ti_Close(handle);
    handle = ti_Open(KERNEL_REPORT_NAME, "r+");
    if (handle == 0u) return 0u;
    success = (uint8_t)(ti_GetSize(handle) == sizeof(*report) &&
        memcmp(ti_GetDataPtr(handle), report, sizeof(*report)) == 0);
#if !T3D2_KERNEL_AUTOTEST
    if (success != 0u) success = (uint8_t)(ti_SetArchiveStatus(true, handle) != 0u);
#endif
    ti_Close(handle);
    return success;
}

int t3d2_kernel_benchmark_run(void) {
    static T3D2Engine benchmark_engine;
    T3D2KernelReport report;
    clock_t started;
    uint8_t iteration;
    uint16_t pixel_index;

    if (t3d2_boot(&benchmark_engine) != T3D2_OK) return 1;
    for (pixel_index = 0u; pixel_index < sizeof(benchmark_texture_half);
         ++pixel_index) {
        benchmark_texture_half[pixel_index] = (uint8_t)(pixel_index % 60u);
    }
    benchmark_engine.texture_half[0] = benchmark_texture_half;
    benchmark_engine.texture_half[1] = benchmark_texture_half;
    benchmark_engine.texture_shift = 1u;
    benchmark_engine.resources_loaded = 1u;
    memset(&report, 0, sizeof(report));
    memcpy(report.magic, "T3DKRN1", 8u);
    report.version = 1u;
    report.header_size = sizeof(report);
    report.build_version = T3D2_BUILD_VERSION;
    report.clock_rate = CLOCKS_PER_SEC;
    report.presenter_iterations = KERNEL_PRESENT_ITERATIONS;
    report.geometry_triangles = 96u;

    gfx_Begin();
    gfx_SetDrawBuffer();
    for (pixel_index = 0u; pixel_index < sizeof(t3d2_root_color); ++pixel_index) {
        t3d2_root_color[pixel_index] = (uint8_t)pixel_index;
    }
    started = clock();
    for (iteration = 0u; iteration < KERNEL_PRESENT_ITERATIONS; ++iteration) {
        t3d2_present_80x60();
    }
    report.presenter_ticks = (uint32_t)(clock() - started);
    report.presenter_hash = t3d2_crc32(t3d2_root_color, sizeof(t3d2_root_color));

    started = clock();
    report.raster_samples = t3d2_kernel_raster_4800(&benchmark_engine);
    report.raster_ticks = (uint32_t)(clock() - started);
    report.raster_hash = t3d2_crc32(t3d2_root_color, sizeof(t3d2_root_color));

    started = clock();
    (void)t3d2_kernel_span_4800(&benchmark_engine);
    report.reserved = (uint16_t)(clock() - started);

    started = clock();
    report.presenter_hash ^= t3d2_kernel_geometry_96();
    report.geometry_ticks = (uint32_t)(clock() - started);
    gfx_End();

    if ((uint64_t)report.presenter_ticks * 1000000ULL <=
        (uint64_t)12500u * report.clock_rate * report.presenter_iterations) {
        report.flags |= KERNEL_FLAG_PRESENTER_PASS;
    }
    if (report.raster_samples == 4800u &&
        (uint64_t)report.raster_ticks * 1000000ULL <=
            (uint64_t)8000u * report.clock_rate) {
        report.flags |= KERNEL_FLAG_RASTER_PASS;
    }
    if ((uint64_t)report.geometry_ticks * 1000000ULL <=
        (uint64_t)4000u * report.clock_rate) {
        report.flags |= KERNEL_FLAG_GEOMETRY_PASS;
    }
    report.crc32 = t3d2_crc32(&report, sizeof(report) - sizeof(report.crc32));
    t3d2_shutdown(&benchmark_engine);
    if (write_report(&report) == 0u) return 2;
    return report.flags == 7u ? 0 : 3;
}
