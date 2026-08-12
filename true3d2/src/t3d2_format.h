#ifndef T3D2_FORMAT_H
#define T3D2_FORMAT_H

#include <stdint.h>

#define T3D2_MAP_VERSION 1u
#define T3D2_GEOMETRY_VERSION 1u
#define T3D2_MAX_CELLS 64u
#define T3D2_MAX_GATEWAYS 128u
#define T3D2_MAX_MESHLETS 1024u
#define T3D2_MAX_PORTAL_SURFACES 64u
#define T3D2_MAX_MATERIALS 32u
#define T3D2_MAX_BODIES 8u
#define T3D2_MESHLET_MAX_VERTICES 32u
#define T3D2_MESHLET_MAX_TRIANGLES 48u
#define T3D2_GEOMETRY_PAGE_MAX 55000u

#define T3D2_MATERIAL_CUTOUT (1u << 0)
#define T3D2_MESHLET_ESSENTIAL (1u << 0)
#define T3D2_GATEWAY_TWO_WAY (1u << 0)
#define T3D2_PORTAL_SURFACE_PLACEABLE (1u << 0)

typedef struct __attribute__((packed)) {
    uint8_t magic[4];
    uint8_t version;
    uint8_t flags;
    uint16_t header_size;
    uint32_t total_size;
    uint32_t payload_crc32;
    uint16_t cell_count;
    uint16_t gateway_count;
    uint16_t meshlet_count;
    uint16_t portal_surface_count;
    uint8_t material_count;
    uint8_t body_count;
    uint16_t spawn_cell;
    int32_t spawn_x;
    int32_t spawn_y;
    int32_t spawn_z;
    uint32_t cell_offset;
    uint32_t gateway_offset;
    uint32_t meshlet_offset;
    uint32_t portal_surface_offset;
    uint32_t body_offset;
    uint32_t pvs_offset;
    uint32_t vertex_pool_offset;
    uint32_t collision_offset;
    uint32_t palette_offset;
    uint32_t material_offset;
} T3D2MapHeader;

typedef struct __attribute__((packed)) {
    int32_t minimum_x;
    int32_t maximum_x;
    int32_t minimum_y;
    int32_t maximum_y;
    int32_t minimum_z;
    int32_t maximum_z;
    uint16_t first_meshlet;
    uint16_t meshlet_count;
    uint16_t first_gateway;
    uint16_t gateway_count;
    uint32_t pvs_offset;
    uint16_t pvs_size;
    uint16_t collision_root;
} T3D2CellRecord;

typedef struct __attribute__((packed)) {
    uint16_t source_cell;
    uint16_t destination_cell;
    uint8_t vertex_count;
    uint8_t flags;
    uint32_t vertex_offset;
    int16_t normal_x;
    int16_t normal_y;
    int16_t normal_z;
    int32_t plane_distance;
} T3D2GatewayRecord;

typedef struct __attribute__((packed)) {
    uint16_t cell;
    uint8_t page;
    uint8_t priority;
    uint8_t material;
    uint8_t flags;
    uint8_t vertex_count;
    uint8_t triangle_count;
    uint16_t payload_offset;
    int32_t origin_x;
    int32_t origin_y;
    int32_t origin_z;
    int16_t bound_x;
    int16_t bound_y;
    int16_t bound_z;
    uint16_t bound_radius;
    int8_t cone_x;
    int8_t cone_y;
    int8_t cone_z;
    int8_t cone_cutoff;
} T3D2MeshletRecord;

typedef struct __attribute__((packed)) {
    uint16_t cell;
    uint8_t vertex_count;
    uint8_t flags;
    uint32_t vertex_offset;
    int32_t center_x;
    int32_t center_y;
    int32_t center_z;
    int16_t right_x;
    int16_t right_y;
    int16_t right_z;
    int16_t up_x;
    int16_t up_y;
    int16_t up_z;
    int16_t normal_x;
    int16_t normal_y;
    int16_t normal_z;
    uint16_t half_width;
    uint16_t half_height;
} T3D2PortalSurfaceRecord;

typedef struct __attribute__((packed)) {
    uint8_t shape;
    uint8_t flags;
    uint16_t cell;
    int32_t position_x;
    int32_t position_y;
    int32_t position_z;
    int32_t velocity_x;
    int32_t velocity_y;
    int32_t velocity_z;
    uint16_t half_x;
    uint16_t half_y;
    uint16_t half_z;
    uint16_t inverse_mass;
} T3D2BodySpawnRecord;

typedef struct __attribute__((packed)) {
    uint8_t flags;
    int8_t mip_bias;
    uint8_t shade;
    uint8_t reserved;
} T3D2MaterialRecord;

typedef struct __attribute__((packed)) {
    uint8_t magic[4];
    uint8_t version;
    uint8_t page;
    uint16_t header_size;
    uint32_t payload_size;
    uint32_t payload_crc32;
    uint16_t meshlet_count;
    uint16_t reserved;
} T3D2GeometryHeader;

typedef struct __attribute__((packed)) {
    int16_t x;
    int16_t y;
    int16_t z;
    uint8_t u;
    uint8_t v;
    int8_t normal_x;
    int8_t normal_y;
    int8_t normal_z;
    uint8_t shade;
} T3D2PackedVertex;

typedef struct __attribute__((packed)) {
    uint8_t index[3];
} T3D2PackedTriangle;

typedef struct __attribute__((packed)) {
    uint8_t magic[4];
    uint8_t version;
    uint8_t quantization_shift;
    uint16_t header_size;
    uint16_t node_count;
    uint16_t reference_count;
    uint32_t nodes_offset;
    uint32_t references_offset;
} T3D2CollisionHeader;

typedef struct __attribute__((packed)) {
    int16_t minimum_x;
    int16_t maximum_x;
    int16_t minimum_y;
    int16_t maximum_y;
    int16_t minimum_z;
    int16_t maximum_z;
    uint16_t left_child;
    uint16_t right_child;
    uint16_t first_reference;
    uint8_t reference_count;
    uint8_t split_axis;
} T3D2CollisionNode;

typedef struct __attribute__((packed)) {
    uint16_t meshlet;
    uint8_t triangle;
    uint8_t flags;
} T3D2CollisionReference;

_Static_assert(sizeof(T3D2MapHeader) == 80u, "T3D2 map header layout changed");
_Static_assert(sizeof(T3D2CellRecord) == 40u, "T3D2 cell layout changed");
_Static_assert(sizeof(T3D2GatewayRecord) == 20u, "T3D2 gateway layout changed");
_Static_assert(sizeof(T3D2MeshletRecord) == 34u, "T3D2 meshlet layout changed");
_Static_assert(sizeof(T3D2PortalSurfaceRecord) == 42u, "T3D2 portal surface layout changed");
_Static_assert(sizeof(T3D2BodySpawnRecord) == 36u, "T3D2 body layout changed");
_Static_assert(sizeof(T3D2GeometryHeader) == 20u, "T3D2 geometry header layout changed");
_Static_assert(sizeof(T3D2PackedVertex) == 12u, "T3D2 packed vertex layout changed");
_Static_assert(sizeof(T3D2PackedTriangle) == 3u, "T3D2 packed triangle layout changed");
_Static_assert(sizeof(T3D2CollisionHeader) == 20u, "T3D2 collision header layout changed");
_Static_assert(sizeof(T3D2CollisionNode) == 20u, "T3D2 collision node layout changed");
_Static_assert(sizeof(T3D2CollisionReference) == 4u, "T3D2 collision reference layout changed");

#endif
