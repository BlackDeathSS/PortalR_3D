#include "internal.h"

#include <fileioc.h>
#include <string.h>
#include <time.h>

#define T3D2_RUNTIME_REPORT_NAME "T3DFPS"

typedef struct __attribute__((packed)) {
    uint8_t magic[8];
    uint8_t version;
    uint8_t flags;
    uint16_t header_size;
    uint32_t build_version;
    uint32_t clock_rate;
    uint32_t frame_count;
    uint32_t wall_ticks;
    uint32_t render_ticks;
    uint32_t update_ticks;
    uint32_t raster_ticks;
    uint32_t present_ticks;
    uint32_t logical_hash;
    int32_t player_x;
    int32_t player_y;
    int32_t player_z;
    uint16_t player_cell;
    uint8_t player_yaw;
    uint8_t reserved;
    uint16_t sample_count;
    uint16_t sample_capacity;
    uint16_t submitted_triangles[3];
    uint16_t shaded_samples[3];
    uint8_t dropped_meshlets[3];
    uint8_t diagnostic_version;
    uint32_t visibility_ticks;
    uint32_t transform_ticks;
    uint32_t triangle_ticks;
    uint32_t crc32;
} T3D2RuntimeReport;

_Static_assert(sizeof(T3D2RuntimeReport) == 100u, "runtime report layout changed");

uint8_t t3d2_runtime_report_write(const T3D2Engine *engine, uint32_t wall_ticks) {
    ti_var_t handle;
    uint24_t report_size;
    uint8_t *destination;
    T3D2RuntimeReport *header;
    uint16_t index;

    if (engine == NULL) return 0u;
    report_size = (uint24_t)(sizeof(T3D2RuntimeReport) +
        (uint24_t)engine->benchmark.frame_sample_count * 3u);
    (void)ti_Delete(T3D2_RUNTIME_REPORT_NAME);
    handle = ti_Open(T3D2_RUNTIME_REPORT_NAME, "w");
    if (handle == 0u) return 0u;
    if ((uint24_t)ti_Resize(report_size, handle) != report_size) {
        ti_Close(handle);
        (void)ti_Delete(T3D2_RUNTIME_REPORT_NAME);
        return 0u;
    }
    destination = (uint8_t *)ti_GetDataPtr(handle);
    if (destination == NULL) {
        ti_Close(handle);
        (void)ti_Delete(T3D2_RUNTIME_REPORT_NAME);
        return 0u;
    }
    memset(destination, 0, report_size);
    header = (T3D2RuntimeReport *)destination;
    memcpy(header->magic, "T3DFPS1", 8u);
    header->version = 2u;
    header->flags = (uint8_t)((engine->scene_loaded != 0u ? 1u : 0u) |
                              (T3D2_RUNTIME_AUTOTEST ? 2u : 0u));
    header->header_size = sizeof(*header);
    header->build_version = T3D2_BUILD_VERSION;
    header->clock_rate = CLOCKS_PER_SEC;
    header->frame_count = engine->benchmark.frame_count;
    header->wall_ticks = wall_ticks;
    header->render_ticks = engine->benchmark.total_ticks;
    header->update_ticks = engine->benchmark.update_ticks;
    header->raster_ticks = engine->benchmark.raster_ticks;
    header->present_ticks = engine->benchmark.present_ticks;
    /* Final-frame certification hashes are computed after the timed route.
       Hashing all 4,800 pixels inside every production frame distorted the
       very performance benchmark the hash is meant to validate. */
    header->logical_hash = t3d2_crc32(
        t3d2_root_color, T3D2_ROOT_WIDTH * T3D2_ROOT_HEIGHT);
    header->player_x = engine->player.position.x;
    header->player_y = engine->player.position.y;
    header->player_z = engine->player.position.z;
    header->player_cell = engine->player.cell;
    header->player_yaw = engine->player.yaw;
    header->reserved = (uint8_t)(
        (engine->portal[0].active != 0u ? 1u : 0u) |
        (engine->portal[1].active != 0u ? 2u : 0u) |
        (engine->portal[0].linked != 0u && engine->portal[1].linked != 0u ? 4u : 0u));
    header->sample_count = engine->benchmark.frame_sample_count;
    header->sample_capacity = T3D2_FRAME_SAMPLE_CAPACITY;
    memcpy(header->submitted_triangles, engine->benchmark.submitted_triangles,
           sizeof(header->submitted_triangles));
    memcpy(header->shaded_samples, engine->benchmark.shaded_samples,
           sizeof(header->shaded_samples));
    memcpy(header->dropped_meshlets, engine->benchmark.dropped_meshlets,
           sizeof(header->dropped_meshlets));
    header->diagnostic_version = 1u;
    header->visibility_ticks = engine->benchmark.visibility_ticks;
    header->transform_ticks = engine->benchmark.transform_ticks;
    header->triangle_ticks = engine->benchmark.portal_ticks;
    for (index = 0u; index < header->sample_count; ++index) {
        uint24_t sample = engine->benchmark.frame_ticks[index];
        uint8_t *packed = destination + sizeof(*header) + (uint24_t)index * 3u;

        packed[0] = (uint8_t)sample;
        packed[1] = (uint8_t)(sample >> 8);
        packed[2] = (uint8_t)(sample >> 16);
    }
    header->crc32 = 0u;
    header->crc32 = t3d2_crc32(destination, report_size);
    ti_Close(handle);
    return 1u;
}
