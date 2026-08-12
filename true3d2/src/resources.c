#include "internal.h"

#include <fileioc.h>
#include <stdlib.h>
#include <string.h>

#define T3D2_MIP_CHAIN_SIZE 21845u

static uint8_t bind_named_payload(
    const char *name,
    uint24_t required_size,
    const uint8_t **payload
) {
    ti_var_t handle = ti_Open(name, "r");
    uint24_t size;

    if (handle == 0u) return T3D2_ERROR_RESOURCE_MISSING;
    size = ti_GetSize(handle);
    if (size != required_size) {
        ti_Close(handle);
        return T3D2_ERROR_RESOURCE_FORMAT;
    }
    *payload = (const uint8_t *)ti_GetDataPtr(handle);
    ti_Close(handle);
    return T3D2_OK;
}

uint8_t t3d2_resources_load(T3D2Engine *engine) {
    const uint8_t *texture_source;
    const uint8_t *mip_source;
    uint16_t index;
    uint8_t maximum_page = 0u;
    uint8_t status;

    if (engine == NULL || engine->scene.header == NULL) return T3D2_ERROR_ARGUMENT;
    memset(engine->geometry_payload, 0, sizeof(engine->geometry_payload));
    memset(engine->geometry_payload_size, 0, sizeof(engine->geometry_payload_size));
    for (index = 0; index < engine->scene.header->meshlet_count; ++index) {
        uint8_t page = engine->scene.meshlets[index].page;

        if (page >= T3D2_MAX_GEOMETRY_PAGES) return T3D2_ERROR_SCENE_BOUNDS;
        if (page > maximum_page) maximum_page = page;
    }
    engine->geometry_page_count = (uint8_t)(maximum_page + 1u);
    for (index = 0; index < engine->geometry_page_count; ++index) {
        char name[8] = "T3D2G00";
        ti_var_t handle;
        uint24_t size;
        const T3D2GeometryHeader *header;
        const uint8_t *data;
        uint16_t payload_size;

        name[5] = (char)('0' + index / 10u);
        name[6] = (char)('0' + index % 10u);
        handle = ti_Open(name, "r");
        if (handle == 0u) return T3D2_ERROR_RESOURCE_MISSING;
        size = ti_GetSize(handle);
        data = (const uint8_t *)ti_GetDataPtr(handle);
        if (size < sizeof(T3D2GeometryHeader)) {
            ti_Close(handle);
            return T3D2_ERROR_RESOURCE_FORMAT;
        }
        header = (const T3D2GeometryHeader *)data;
        if (memcmp(header->magic, "T3DG", 4u) != 0 ||
            header->version != T3D2_GEOMETRY_VERSION ||
            header->page != index ||
            header->header_size != sizeof(T3D2GeometryHeader) ||
            header->payload_size > T3D2_GEOMETRY_PAGE_MAX ||
            (uint32_t)header->payload_size + sizeof(T3D2GeometryHeader) != size) {
            ti_Close(handle);
            return T3D2_ERROR_RESOURCE_FORMAT;
        }
        if (t3d2_crc32(data + sizeof(T3D2GeometryHeader),
                       (uint24_t)header->payload_size) != header->payload_crc32) {
            ti_Close(handle);
            return T3D2_ERROR_RESOURCE_CRC;
        }
        payload_size = (uint16_t)header->payload_size;
        free(engine->geometry_cache[index]);
        engine->geometry_cache[index] = (uint8_t *)malloc(payload_size);
        if (engine->geometry_cache[index] == NULL) {
            ti_Close(handle);
            return T3D2_ERROR_MEMORY_SPACE;
        }
        memcpy(engine->geometry_cache[index],
               data + sizeof(T3D2GeometryHeader), payload_size);
        engine->geometry_payload[index] = engine->geometry_cache[index];
        engine->geometry_payload_size[index] = (uint16_t)header->payload_size;
        ti_Close(handle);
    }
    status = bind_named_payload("T3D2TX0", 32768u, &texture_source);
    if (status != T3D2_OK) return status;
    status = bind_named_payload("T3D2TX1", 32768u, &texture_source);
    if (status != T3D2_OK) return status;
    status = bind_named_payload("T3D2MIP", T3D2_MIP_CHAIN_SIZE, &mip_source);
    if (status != T3D2_OK) return status;
    if (engine->texture_cache[0] == NULL) {
        engine->texture_cache[0] = (uint8_t *)malloc(32768u);
        if (engine->texture_cache[0] == NULL) return T3D2_ERROR_MEMORY_SPACE;
    }
    /* The 80x60 root view selects the 128x128 mip. Duplicate each texel
       horizontally so the hot sampler retains its cheap V:U address build;
       it only needs to halve V. This uses one safe 32 KiB heap block instead
       of sampling flash or requiring the unproven full-RAM takeover. */
    for (index = 0u; index < 16384u; ++index) {
        engine->texture_cache[0][(uint24_t)index * 2u] = mip_source[index];
        engine->texture_cache[0][(uint24_t)index * 2u + 1u] = mip_source[index];
    }
    engine->texture_half[0] = engine->texture_cache[0];
    engine->texture_half[1] = engine->texture_cache[0];
    engine->texture_shift = 1u;
    engine->mip_chain = mip_source;
    engine->resources_loaded = 1u;
    return T3D2_OK;
}
