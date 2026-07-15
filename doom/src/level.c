#include "level_format.h"

#include <string.h>

typedef struct __attribute__((packed)) {
    LevelHeader header;
    LevelVertex vertices[8];
    LevelEdge edges[12];
    LevelSector sectors[3];
} BuiltinLevelBlob;

/* Three connected rooms. Each doorway rises by half a world unit; the last
 * room has angled outer walls to exercise non-axis-aligned projection. */
static const BuiltinLevelBlob builtin_level = {
    {
        {LEVEL_MAGIC_0, LEVEL_MAGIC_1, LEVEL_MAGIC_2, LEVEL_MAGIC_3},
        LEVEL_FORMAT_VERSION,
        8,
        12,
        3,
        0,
        2 * 16,
        3 * 16,
        0,
        0,
        0
    },
    {
        {0 * 16, 0 * 16},
        {5 * 16, 0 * 16},
        {5 * 16, 6 * 16},
        {0 * 16, 6 * 16},
        {9 * 16, 0 * 16},
        {9 * 16, 6 * 16},
        {14 * 16, 1 * 16},
        {14 * 16, 5 * 16}
    },
    {
        {0, 1, LEVEL_NO_NEIGHBOR, 8, LEVEL_EDGE_PORTAL_CAPABLE},
        {1, 2, 1,                 7, 0},
        {2, 3, LEVEL_NO_NEIGHBOR, 8, LEVEL_EDGE_PORTAL_CAPABLE},
        {3, 0, LEVEL_NO_NEIGHBOR, 8, LEVEL_EDGE_PORTAL_CAPABLE},

        {1, 4, LEVEL_NO_NEIGHBOR, 10, LEVEL_EDGE_PORTAL_CAPABLE},
        {4, 5, 2,                 9,  0},
        {5, 2, LEVEL_NO_NEIGHBOR, 10, LEVEL_EDGE_PORTAL_CAPABLE},
        {2, 1, 0,                 7,  0},

        {4, 6, LEVEL_NO_NEIGHBOR, 12, LEVEL_EDGE_PORTAL_CAPABLE},
        {6, 7, LEVEL_NO_NEIGHBOR, 12, LEVEL_EDGE_PORTAL_CAPABLE},
        {7, 5, LEVEL_NO_NEIGHBOR, 12, LEVEL_EDGE_PORTAL_CAPABLE},
        {5, 4, 1,                 9,  0}
    },
    {
        {0, 4,   0, 3 * 256, 3, 2},
        {4, 4, 128, 3 * 256 + 128, 4, 2},
        {8, 4, 256, 4 * 256, 5, 2}
    }
};

uint8_t level_bind(LevelView *view, const void *data, size_t size) {
    const uint8_t *cursor = data;
    const LevelHeader *header;
    uint8_t edge_owner[LEVEL_MAX_EDGES];
    size_t needed;

    if (view == NULL || data == NULL || size < sizeof(LevelHeader)) {
        return 0;
    }

    header = (const LevelHeader *)cursor;
    if (header->magic[0] != LEVEL_MAGIC_0 ||
        header->magic[1] != LEVEL_MAGIC_1 ||
        header->magic[2] != LEVEL_MAGIC_2 ||
        header->magic[3] != LEVEL_MAGIC_3 ||
        header->version != LEVEL_FORMAT_VERSION ||
        header->vertex_count == 0 ||
        header->vertex_count > LEVEL_MAX_VERTICES ||
        header->edge_count == 0 ||
        header->edge_count > LEVEL_MAX_EDGES ||
        header->sector_count == 0 ||
        header->sector_count > LEVEL_MAX_SECTORS ||
        header->portal_count > LEVEL_MAX_PORTALS ||
        header->spawn_sector >= header->sector_count) {
        return 0;
    }

    needed = sizeof(LevelHeader) +
        (size_t)header->vertex_count * sizeof(LevelVertex) +
        (size_t)header->edge_count * sizeof(LevelEdge) +
        (size_t)header->sector_count * sizeof(LevelSector) +
        (size_t)header->portal_count * sizeof(LevelPortal);
    if (needed > size) {
        return 0;
    }

    view->header = header;
    cursor += sizeof(LevelHeader);
    view->vertices = (const LevelVertex *)cursor;
    cursor += (size_t)header->vertex_count * sizeof(LevelVertex);
    view->edges = (const LevelEdge *)cursor;
    cursor += (size_t)header->edge_count * sizeof(LevelEdge);
    view->sectors = (const LevelSector *)cursor;
    cursor += (size_t)header->sector_count * sizeof(LevelSector);
    view->portals = (const LevelPortal *)cursor;
    memset(edge_owner, LEVEL_NO_PORTAL, sizeof(edge_owner));

    {
        uint8_t sector_index;
        for (sector_index = 0; sector_index < header->sector_count; ++sector_index) {
            const LevelSector *sector = &view->sectors[sector_index];
            uint16_t edge_end = (uint16_t)sector->first_edge + sector->edge_count;
            uint8_t edge_index;

            if (sector->edge_count < 3 || edge_end > header->edge_count ||
                sector->floor_z >= sector->ceiling_z) {
                return 0;
            }
            for (edge_index = sector->first_edge; edge_index < edge_end; ++edge_index) {
                const LevelEdge *edge = &view->edges[edge_index];
                if (edge_owner[edge_index] != LEVEL_NO_PORTAL ||
                    edge->vertex_a >= header->vertex_count ||
                    edge->vertex_b >= header->vertex_count ||
                    edge->vertex_a == edge->vertex_b ||
                    edge->neighbor_sector < LEVEL_NO_NEIGHBOR ||
                    edge->neighbor_sector >= (int8_t)header->sector_count ||
                    edge->neighbor_sector == (int8_t)sector_index) {
                    return 0;
                }
                edge_owner[edge_index] = sector_index;
            }
        }
    }

    {
        uint8_t portal_index;
        if ((header->portal_count & 1u) != 0) return 0;
        for (portal_index = 0; portal_index < header->portal_count; ++portal_index) {
            const LevelPortal *portal = &view->portals[portal_index];
            const LevelEdge *edge;
            const LevelSector *sector;
            uint16_t right = (uint16_t)portal->center_u + portal->half_width;

            if (portal->edge >= header->edge_count ||
                portal->linked_portal >= header->portal_count ||
                portal->linked_portal == portal_index ||
                portal->half_width == 0 ||
                portal->half_width > portal->center_u ||
                right > 255u ||
                portal->bottom_z >= portal->top_z ||
                view->portals[portal->linked_portal].linked_portal != portal_index) {
                return 0;
            }
            if (edge_owner[portal->edge] == LEVEL_NO_PORTAL) return 0;
            edge = &view->edges[portal->edge];
            sector = &view->sectors[edge_owner[portal->edge]];
            if (edge->neighbor_sector != LEVEL_NO_NEIGHBOR ||
                (edge->flags & LEVEL_EDGE_PORTAL_CAPABLE) == 0 ||
                portal->bottom_z < sector->floor_z ||
                portal->top_z > sector->ceiling_z) {
                return 0;
            }
        }
    }
    return 1;
}

uint8_t level_bind_builtin(LevelView *view) {
    return level_bind(view, &builtin_level, sizeof(builtin_level));
}

const void *level_builtin_data(void) {
    return &builtin_level;
}

size_t level_builtin_size(void) {
    return sizeof(builtin_level);
}
