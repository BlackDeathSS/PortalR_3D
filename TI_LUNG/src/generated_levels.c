#include "../../t3d3/src/level.h"

typedef struct __attribute__((packed)) {
    True3DLevelHeader header;
    True3DRoomRecord rooms[2];
} TiLungLevel;

/* Room 0 is the walkable SM-13 pressure cabin. Room 1 is a 96 x 96 x 12
 * exterior volume; navigation coordinates are divided by ten before the
 * photographic camera is placed in this room. Portals remain disabled because
 * the cabin and the blood-ocean representation are deliberately separate. */
static const TiLungLevel ti_lung_level = {
    {
        {'T', '3', 'D', '1'}, TRUE3D_LEVEL_VERSION,
        2, 0, 0,
        0, -512, 384,
        {
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    {
        {-832, 832, -1152, 1152, 0, 896, {6, 7, 9, 8, 9, 8}},
        {0, 24576, 0, 24576, 0, 3072, {1, 1, 9, 9, 9, 9}}
    }
};

const T3D3EmbeddedLevel t3d3_embedded_levels[] = {
    {"TI Lung survey", &ti_lung_level, sizeof(ti_lung_level)}
};

const uint8_t t3d3_embedded_level_count = 1u;
