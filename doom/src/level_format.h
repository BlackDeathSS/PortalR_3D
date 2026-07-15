#ifndef DOOMCE_LEVEL_FORMAT_H
#define DOOMCE_LEVEL_FORMAT_H

#include <stddef.h>
#include <stdint.h>

#define LEVEL_MAGIC_0 'D'
#define LEVEL_MAGIC_1 'C'
#define LEVEL_MAGIC_2 'E'
#define LEVEL_MAGIC_3 '1'
#define LEVEL_FORMAT_VERSION 1u

#define LEVEL_MAX_VERTICES 64u
#define LEVEL_MAX_EDGES 96u
#define LEVEL_MAX_SECTORS 16u
#define LEVEL_MAX_PORTALS 16u

#define LEVEL_NO_NEIGHBOR (-1)
#define LEVEL_NO_PORTAL 255u

#define LEVEL_EDGE_PORTAL_CAPABLE (1u << 0)
#define LEVEL_PORTAL_ENABLED (1u << 0)

/*
 * Disk units:
 *   X/Y vertex coordinates: signed Q12.4 (1/16 world unit)
 *   Floor/ceiling/portal Z:  signed Q8.8 (1/256 world unit)
 *
 * A level blob is header, vertices, edges, sectors, then portals. The editor
 * writes exactly this packed layout; no pointer values are stored on disk.
 */
typedef struct __attribute__((packed)) {
    uint8_t magic[4];
    uint8_t version;
    uint8_t vertex_count;
    uint8_t edge_count;
    uint8_t sector_count;
    uint8_t portal_count;
    int16_t spawn_x;
    int16_t spawn_y;
    int16_t spawn_z;
    uint8_t spawn_sector;
    uint8_t spawn_angle;
} LevelHeader;

typedef struct __attribute__((packed)) {
    int16_t x;
    int16_t y;
} LevelVertex;

typedef struct __attribute__((packed)) {
    uint8_t vertex_a;
    uint8_t vertex_b;
    int8_t neighbor_sector;
    uint8_t color;
    uint8_t flags;
} LevelEdge;

typedef struct __attribute__((packed)) {
    uint8_t first_edge;
    uint8_t edge_count;
    int16_t floor_z;
    int16_t ceiling_z;
    uint8_t floor_color;
    uint8_t ceiling_color;
} LevelSector;

/*
 * A portal is centered along an edge. center_u and half_width are Q0.8 edge
 * fractions. Its linked record may live on a wall with any horizontal angle.
 */
typedef struct __attribute__((packed)) {
    uint8_t edge;
    uint8_t linked_portal;
    uint8_t center_u;
    uint8_t half_width;
    int16_t bottom_z;
    int16_t top_z;
    uint8_t flags;
} LevelPortal;

typedef struct {
    const LevelHeader *header;
    const LevelVertex *vertices;
    const LevelEdge *edges;
    const LevelSector *sectors;
    const LevelPortal *portals;
} LevelView;

_Static_assert(sizeof(LevelHeader) == 17u, "LevelHeader layout changed");
_Static_assert(sizeof(LevelVertex) == 4u, "LevelVertex layout changed");
_Static_assert(sizeof(LevelEdge) == 5u, "LevelEdge layout changed");
_Static_assert(sizeof(LevelSector) == 8u, "LevelSector layout changed");
_Static_assert(sizeof(LevelPortal) == 9u, "LevelPortal layout changed");

uint8_t level_bind(LevelView *view, const void *data, size_t size);
uint8_t level_bind_builtin(LevelView *view);
const void *level_builtin_data(void);
size_t level_builtin_size(void);

#endif
