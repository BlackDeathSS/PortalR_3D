#ifndef TRUE3D_LEVEL_H
#define TRUE3D_LEVEL_H

#include <fileioc.h>
#include <stddef.h>
#include <stdint.h>

#define T3D3_LEVEL_APPVAR "T3D3LVL"
#define TRUE3D_LEVEL_APPVAR "T3DLVL1"
#define TRUE3D_LEVEL_VERSION 1u
#define TRUE3D_MAX_ROOMS 8u
#define TRUE3D_FACE_COUNT 6u
#define TRUE3D_PORTAL_COUNT 2u
#define TRUE3D_MAX_COLOR 12u

typedef struct __attribute__((packed)) {
    uint8_t room;
    uint8_t face;
    int16_t x;
    int16_t y;
    int16_t z;
} True3DPortalSpawn;

typedef struct __attribute__((packed)) {
    uint8_t magic[4];
    uint8_t version;
    uint8_t room_count;
    uint8_t spawn_room;
    uint8_t portal_active_mask;
    int16_t spawn_x;
    int16_t spawn_y;
    int16_t spawn_z;
    True3DPortalSpawn portal[TRUE3D_PORTAL_COUNT];
} True3DLevelHeader;

typedef struct __attribute__((packed)) {
    int16_t minimum_x;
    int16_t maximum_x;
    int16_t minimum_y;
    int16_t maximum_y;
    int16_t minimum_z;
    int16_t maximum_z;
    uint8_t face_color[TRUE3D_FACE_COUNT];
} True3DRoomRecord;

typedef struct {
    const True3DLevelHeader *header;
    const True3DRoomRecord *rooms;
} True3DLevelView;

typedef struct {
    ti_var_t handle;
    uint8_t external;
} True3DLevelSource;

typedef struct {
    const char *name;
    const void *data;
    size_t size;
} T3D3EmbeddedLevel;

extern const T3D3EmbeddedLevel t3d3_embedded_levels[];
extern const uint8_t t3d3_embedded_level_count;

_Static_assert(sizeof(True3DPortalSpawn) == 8u, "Portal spawn layout changed");
_Static_assert(sizeof(True3DLevelHeader) == 30u, "True3D header layout changed");
_Static_assert(sizeof(True3DRoomRecord) == 18u, "Room record layout changed");

uint8_t true3d_level_open(True3DLevelView *view, True3DLevelSource *source);
uint8_t true3d_level_builtin_view(True3DLevelView *view);
uint8_t true3d_level_embedded_view(uint8_t index, True3DLevelView *view);
const char *true3d_level_embedded_name(uint8_t index);
void true3d_level_close(True3DLevelSource *source);

#endif
