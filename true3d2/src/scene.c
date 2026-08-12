#include "internal.h"

#include <stddef.h>
#include <string.h>

static uint8_t range_is_valid(
    uint32_t offset,
    uint32_t count,
    uint32_t element_size,
    uint32_t total_size
) {
    return offset <= total_size &&
           count <= (total_size - offset) / element_size;
}

static uint8_t index_range_is_valid(uint16_t first, uint16_t count, uint16_t limit) {
    return first <= limit && count <= (uint16_t)(limit - first);
}

static uint8_t fits_runtime_fixed(int32_t value) {
    return value >= -8388608L && value <= 8388607L;
}

uint8_t t3d2_scene_bind(T3D2SceneView *view, const void *data, uint24_t size) {
    const uint8_t *bytes = (const uint8_t *)data;
    const T3D2MapHeader *header;
    uint16_t index;
    uint32_t total_size;
    uint32_t pvs_bytes;
    const T3D2CollisionHeader *collision_header;
    const T3D2CollisionNode *collision_nodes;
    const T3D2CollisionReference *collision_references;

    if (view == NULL || data == NULL || size < sizeof(T3D2MapHeader)) {
        return T3D2_ERROR_ARGUMENT;
    }
    memset(view, 0, sizeof(*view));
    header = (const T3D2MapHeader *)data;
    total_size = header->total_size;
    if (memcmp(header->magic, "T3D2", 4u) != 0 ||
        header->version != T3D2_MAP_VERSION ||
        header->header_size != sizeof(T3D2MapHeader) ||
        total_size != (uint32_t)size) {
        return T3D2_ERROR_SCENE_FORMAT;
    }
    if (t3d2_crc32(
            bytes + sizeof(T3D2MapHeader),
            (uint24_t)(total_size - sizeof(T3D2MapHeader))
        ) != header->payload_crc32) {
        return T3D2_ERROR_SCENE_CRC;
    }
    if (header->cell_count == 0u || header->cell_count > T3D2_MAX_CELLS ||
        header->gateway_count > T3D2_MAX_GATEWAYS ||
        header->meshlet_count > T3D2_MAX_MESHLETS ||
        header->portal_surface_count > T3D2_MAX_PORTAL_SURFACES ||
        header->material_count == 0u || header->material_count > T3D2_MAX_MATERIALS ||
        header->body_count > T3D2_MAX_BODIES ||
        header->spawn_cell >= header->cell_count ||
        !fits_runtime_fixed(header->spawn_x) ||
        !fits_runtime_fixed(header->spawn_y) ||
        !fits_runtime_fixed(header->spawn_z)) {
        return T3D2_ERROR_SCENE_BOUNDS;
    }
    if (!range_is_valid(header->cell_offset, header->cell_count,
                        sizeof(T3D2CellRecord), total_size) ||
        !range_is_valid(header->gateway_offset, header->gateway_count,
                        sizeof(T3D2GatewayRecord), total_size) ||
        !range_is_valid(header->meshlet_offset, header->meshlet_count,
                        sizeof(T3D2MeshletRecord), total_size) ||
        !range_is_valid(header->portal_surface_offset, header->portal_surface_count,
                        sizeof(T3D2PortalSurfaceRecord), total_size) ||
        !range_is_valid(header->body_offset, header->body_count,
                        sizeof(T3D2BodySpawnRecord), total_size) ||
        !range_is_valid(header->material_offset, header->material_count,
                        sizeof(T3D2MaterialRecord), total_size) ||
        !range_is_valid(header->palette_offset, 256u, sizeof(uint16_t), total_size) ||
        header->pvs_offset > total_size ||
        header->vertex_pool_offset > total_size ||
        header->collision_offset > total_size) {
        return T3D2_ERROR_SCENE_BOUNDS;
    }

    view->header = header;
    view->cells = (const T3D2CellRecord *)(bytes + header->cell_offset);
    view->gateways = (const T3D2GatewayRecord *)(bytes + header->gateway_offset);
    view->meshlets = (const T3D2MeshletRecord *)(bytes + header->meshlet_offset);
    view->portal_surfaces =
        (const T3D2PortalSurfaceRecord *)(bytes + header->portal_surface_offset);
    view->body_spawns = (const T3D2BodySpawnRecord *)(bytes + header->body_offset);
    view->materials = (const T3D2MaterialRecord *)(bytes + header->material_offset);
    view->pvs = bytes + header->pvs_offset;
    view->vertex_pool = (const int32_t *)(bytes + header->vertex_pool_offset);
    view->collision = bytes + header->collision_offset;
    view->palette = (const uint16_t *)(bytes + header->palette_offset);
    view->size = size;

    if (!range_is_valid(header->collision_offset, 1u,
                        sizeof(T3D2CollisionHeader), total_size)) {
        memset(view, 0, sizeof(*view));
        return T3D2_ERROR_SCENE_BOUNDS;
    }
    collision_header = (const T3D2CollisionHeader *)view->collision;
    if (memcmp(collision_header->magic, "C2BV", 4u) != 0 ||
        collision_header->version != 1u ||
        collision_header->quantization_shift != 4u ||
        collision_header->header_size != sizeof(T3D2CollisionHeader) ||
        collision_header->nodes_offset > total_size - header->collision_offset ||
        collision_header->references_offset > total_size - header->collision_offset ||
        !range_is_valid(header->collision_offset + collision_header->nodes_offset,
                        collision_header->node_count,
                        sizeof(T3D2CollisionNode), total_size) ||
        !range_is_valid(header->collision_offset + collision_header->references_offset,
                        collision_header->reference_count,
                        sizeof(T3D2CollisionReference), total_size)) {
        memset(view, 0, sizeof(*view));
        return T3D2_ERROR_SCENE_BOUNDS;
    }
    collision_nodes = (const T3D2CollisionNode *)(
        view->collision + collision_header->nodes_offset);
    collision_references = (const T3D2CollisionReference *)(
        view->collision + collision_header->references_offset);

    pvs_bytes = (header->cell_count + 7u) / 8u;
    for (index = 0; index < header->cell_count; ++index) {
        const T3D2CellRecord *cell = &view->cells[index];

        if (cell->minimum_x >= cell->maximum_x ||
            cell->minimum_y >= cell->maximum_y ||
            cell->minimum_z >= cell->maximum_z ||
            !index_range_is_valid(cell->first_meshlet, cell->meshlet_count,
                                  header->meshlet_count) ||
            !index_range_is_valid(cell->first_gateway, cell->gateway_count,
                                  header->gateway_count) ||
            cell->pvs_size != pvs_bytes ||
            !range_is_valid(cell->pvs_offset, cell->pvs_size, 1u, total_size) ||
            (cell->collision_root != 0xFFFFu &&
             cell->collision_root >= collision_header->node_count)) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    for (index = 0; index < header->gateway_count; ++index) {
        const T3D2GatewayRecord *gateway = &view->gateways[index];

        if (gateway->source_cell >= header->cell_count ||
            gateway->destination_cell >= header->cell_count ||
            gateway->source_cell == gateway->destination_cell ||
            gateway->vertex_count < 3u || gateway->vertex_count > 8u ||
            !range_is_valid(gateway->vertex_offset,
                            (uint32_t)gateway->vertex_count * 3u,
                            sizeof(int32_t), total_size)) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    for (index = 0; index < header->meshlet_count; ++index) {
        const T3D2MeshletRecord *meshlet = &view->meshlets[index];

        if (meshlet->cell >= header->cell_count ||
            meshlet->material >= header->material_count ||
            meshlet->vertex_count == 0u ||
            meshlet->vertex_count > T3D2_MESHLET_MAX_VERTICES ||
            meshlet->triangle_count == 0u ||
            meshlet->triangle_count > T3D2_MESHLET_MAX_TRIANGLES) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    for (index = 0; index < header->portal_surface_count; ++index) {
        const T3D2PortalSurfaceRecord *surface = &view->portal_surfaces[index];

        if (surface->cell >= header->cell_count ||
            surface->vertex_count < 3u || surface->vertex_count > 8u ||
            surface->half_width == 0u || surface->half_height == 0u ||
            !range_is_valid(surface->vertex_offset,
                            (uint32_t)surface->vertex_count * 3u,
                            sizeof(int32_t), total_size)) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    for (index = 0; index < header->body_count; ++index) {
        const T3D2BodySpawnRecord *body = &view->body_spawns[index];

        if (body->cell >= header->cell_count ||
            !fits_runtime_fixed(body->position_x) ||
            !fits_runtime_fixed(body->position_y) ||
            !fits_runtime_fixed(body->position_z) ||
            !fits_runtime_fixed(body->velocity_x) ||
            !fits_runtime_fixed(body->velocity_y) ||
            !fits_runtime_fixed(body->velocity_z)) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    for (index = 0; index < collision_header->node_count; ++index) {
        const T3D2CollisionNode *node = &collision_nodes[index];

        if (node->minimum_x > node->maximum_x ||
            node->minimum_y > node->maximum_y ||
            node->minimum_z > node->maximum_z ||
            (node->reference_count == 0u &&
             (node->left_child >= collision_header->node_count ||
              node->right_child >= collision_header->node_count)) ||
            (node->reference_count != 0u &&
             (node->reference_count > 8u ||
              node->first_reference > collision_header->reference_count ||
              node->reference_count >
                  collision_header->reference_count - node->first_reference))) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    for (index = 0; index < collision_header->reference_count; ++index) {
        const T3D2CollisionReference *reference = &collision_references[index];

        if (reference->meshlet >= header->meshlet_count ||
            reference->triangle >= view->meshlets[reference->meshlet].triangle_count) {
            memset(view, 0, sizeof(*view));
            return T3D2_ERROR_SCENE_BOUNDS;
        }
    }
    return T3D2_OK;
}
