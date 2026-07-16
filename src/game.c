#include "game.h"

#include <graphx.h>

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)
#define FIXED_INF ((fixed_t)0x3FFFFF)

#define MAP_WIDTH 15
#define MAP_HEIGHT 15
#define LOGICAL_COLUMNS 80
#define COLUMN_WIDTH 4
#define FLOOR_NEAR_DISTANCE (FIXED_ONE + 4)
#define FLOOR_FAR_DISTANCE (FIXED_ONE * 16)
#define FLOOR_PROJECT_LIMIT 4096
#define WALL_HEIGHT_TABLE_SHIFT 2
#define WALL_HEIGHT_TABLE_SIZE 2048
#define WALL_HEIGHT_FAR 7
#define MAX_PORTAL_DEPTH 12
#define PORTAL_RECURSE_MIN_HEIGHT 3
#define PLAYER_RADIUS 44
#define FIELD_OF_VIEW 169
#define MOVE_SPEED 600
#define TURN_SPEED 12
#define ANGLE_STEPS 64
#define ANGLE_FRACTION_BITS 8
#define ANGLE_WRAP (ANGLE_STEPS << ANGLE_FRACTION_BITS)
#define ANGLE_MASK (ANGLE_WRAP - 1)

enum Direction {
    DIR_NORTH = 0,
    DIR_SOUTH = 1,
    DIR_WEST = 2,
    DIR_EAST = 3
};

enum PortalKind {
    PORTAL_NONE = 0,
    PORTAL_PRIMARY = 1,
    PORTAL_SECONDARY = 2,
    PORTAL_BUILTIN = 3
};

enum ColorIndex {
    COLOR_BLACK = 0,
    COLOR_SKY = 1,
    COLOR_SKY_HORIZON = 2,
    COLOR_FLOOR = 3,
    COLOR_FLOOR_NEAR = 4,
    COLOR_NORTH = 5,
    COLOR_NORTH_DARK = 6,
    COLOR_SOUTH = 7,
    COLOR_SOUTH_DARK = 8,
    COLOR_EAST = 9,
    COLOR_EAST_DARK = 10,
    COLOR_WEST = 11,
    COLOR_WEST_DARK = 12,
    COLOR_PRIMARY = 13,
    COLOR_SECONDARY = 14,
    COLOR_BUILTIN = 15,
    COLOR_HUD = 16
};

typedef struct {
    uint8_t x;
    uint8_t y;
    uint8_t direction;
    uint8_t target_x;
    uint8_t target_y;
    uint8_t target_direction;
} PortalLink;

typedef struct {
    fixed_t distance;
    uint8_t map_x;
    uint8_t map_y;
    int8_t step_x;
    int8_t step_y;
    uint8_t side;
    uint8_t wall_u;
    uint8_t wall_direction;
    uint8_t portal_kind;
} RayHit;

typedef struct {
    uint16_t full_height;
    uint8_t start;
    uint8_t end;
} WallContext;

typedef struct {
    RayHit layers[MAX_PORTAL_DEPTH];
} RenderScratch;

static RenderScratch render_scratch;
static uint16_t wall_height_table[WALL_HEIGHT_TABLE_SIZE];

_Static_assert(sizeof(RenderScratch) <= 256u, "Render scratch exceeded its RAM budget");
_Static_assert(
    sizeof(GameState) + sizeof(RenderScratch) + sizeof(wall_height_table) + 4096u < 32u * 1024u,
    "Static state plus the reserved CEdev stack exceeds 32 KiB"
);

/* A padded 16-by-16 map makes every DDA lookup a shift and an indexed load. */
static const uint8_t wall_map[16 * 16] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
};

/* Link index + 1, keyed by the padded map tile. */
static const uint8_t builtin_portal_by_tile[16 * 16] = {
    [3] = 10, [5] = 5, [7] = 6, [32] = 9, [64] = 3,
    [94] = 7, [110] = 8, [149] = 4, [208] = 1, [213] = 2
};

/* 2*x/80-1 in 8.8 fixed point; removes a division from every wall column. */
static const int16_t camera_x_by_column[LOGICAL_COLUMNS] = {
    -256, -250, -244, -237, -231, -224, -218, -212, -205, -199, -192, -186, -180, -173, -167, -160,
    -154, -148, -141, -135, -128, -122, -116, -109, -103, -96, -90, -84, -77, -71, -64, -58,
    -52, -45, -39, -32, -26, -20, -13, -7, 0, 6, 12, 19, 25, 32, 38, 44,
    51, 57, 64, 70, 76, 83, 89, 96, 102, 108, 115, 121, 128, 134, 140, 147,
    153, 160, 166, 172, 179, 185, 192, 198, 204, 211, 217, 224, 230, 236, 243, 249
};

/* 65536/component for every possible 8.8 ray component. */
static const uint16_t reciprocal_delta[426] = {
    0, 0, 32768, 21845, 16384, 13107, 10922, 9362, 8192, 7281, 6553, 5957,
    5461, 5041, 4681, 4369, 4096, 3855, 3640, 3449, 3276, 3120, 2978, 2849,
    2730, 2621, 2520, 2427, 2340, 2259, 2184, 2114, 2048, 1985, 1927, 1872,
    1820, 1771, 1724, 1680, 1638, 1598, 1560, 1524, 1489, 1456, 1424, 1394,
    1365, 1337, 1310, 1285, 1260, 1236, 1213, 1191, 1170, 1149, 1129, 1110,
    1092, 1074, 1057, 1040, 1024, 1008, 992, 978, 963, 949, 936, 923,
    910, 897, 885, 873, 862, 851, 840, 829, 819, 809, 799, 789,
    780, 771, 762, 753, 744, 736, 728, 720, 712, 704, 697, 689,
    682, 675, 668, 661, 655, 648, 642, 636, 630, 624, 618, 612,
    606, 601, 595, 590, 585, 579, 574, 569, 564, 560, 555, 550,
    546, 541, 537, 532, 528, 524, 520, 516, 512, 508, 504, 500,
    496, 492, 489, 485, 481, 478, 474, 471, 468, 464, 461, 458,
    455, 451, 448, 445, 442, 439, 436, 434, 431, 428, 425, 422,
    420, 417, 414, 412, 409, 407, 404, 402, 399, 397, 394, 392,
    390, 387, 385, 383, 381, 378, 376, 374, 372, 370, 368, 366,
    364, 362, 360, 358, 356, 354, 352, 350, 348, 346, 344, 343,
    341, 339, 337, 336, 334, 332, 330, 329, 327, 326, 324, 322,
    321, 319, 318, 316, 315, 313, 312, 310, 309, 307, 306, 304,
    303, 302, 300, 299, 297, 296, 295, 293, 292, 291, 289, 288,
    287, 286, 284, 283, 282, 281, 280, 278, 277, 276, 275, 274,
    273, 271, 270, 269, 268, 267, 266, 265, 264, 263, 262, 261,
    260, 259, 258, 257, 256, 255, 254, 253, 252, 251, 250, 249,
    248, 247, 246, 245, 244, 243, 242, 241, 240, 240, 239, 238,
    237, 236, 235, 234, 234, 233, 232, 231, 230, 229, 229, 228,
    227, 226, 225, 225, 224, 223, 222, 222, 221, 220, 219, 219,
    218, 217, 217, 216, 215, 214, 214, 213, 212, 212, 211, 210,
    210, 209, 208, 208, 207, 206, 206, 205, 204, 204, 203, 202,
    202, 201, 201, 200, 199, 199, 198, 197, 197, 196, 196, 195,
    195, 194, 193, 193, 192, 192, 191, 191, 190, 189, 189, 188,
    188, 187, 187, 186, 186, 185, 185, 184, 184, 183, 183, 182,
    182, 181, 181, 180, 180, 179, 179, 178, 178, 177, 177, 176,
    176, 175, 175, 174, 174, 173, 173, 172, 172, 172, 171, 171,
    170, 170, 169, 169, 168, 168, 168, 167, 167, 166, 166, 165,
    165, 165, 164, 164, 163, 163, 163, 162, 162, 161, 161, 161,
    160, 160, 159, 159, 159, 158, 158, 157, 157, 157, 156, 156,
    156, 155, 155, 154, 154, 154
};

static const PortalLink builtin_portals[10] = {
    {0, 13, DIR_SOUTH, 5, 13, DIR_NORTH},
    {5, 13, DIR_NORTH, 0, 13, DIR_SOUTH},
    {0, 4, DIR_SOUTH, 5, 9, DIR_NORTH},
    {5, 9, DIR_NORTH, 0, 4, DIR_SOUTH},
    {5, 0, DIR_EAST, 7, 0, DIR_EAST},
    {7, 0, DIR_EAST, 5, 0, DIR_EAST},
    {14, 5, DIR_NORTH, 14, 6, DIR_NORTH},
    {14, 6, DIR_NORTH, 14, 5, DIR_NORTH},
    {0, 2, DIR_SOUTH, 3, 0, DIR_EAST},
    {3, 0, DIR_EAST, 0, 2, DIR_SOUTH}
};

static const int16_t direction_x[ANGLE_STEPS] = {
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25,
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255
};

static const int16_t direction_y[ANGLE_STEPS] = {
    0, 25, 50, 74, 98, 121, 142, 162,
    181, 198, 213, 226, 237, 245, 251, 255,
    256, 255, 251, 245, 237, 226, 213, 198,
    181, 162, 142, 121, 98, 74, 50, 25,
    0, -25, -50, -74, -98, -121, -142, -162,
    -181, -198, -213, -226, -237, -245, -251, -255,
    -256, -255, -251, -245, -237, -226, -213, -198,
    -181, -162, -142, -121, -98, -74, -50, -25
};

static fixed_t fixed_abs(fixed_t value) {
    return value < 0 ? -value : value;
}

static fixed_t fixed_mul(fixed_t left, fixed_t right) {
    return (fixed_t)(((int32_t)left * (int32_t)right) / FIXED_ONE);
}

/* Camera products stay below 2^23, so native eZ80-width math is sufficient. */
static fixed_t fixed_mul_camera(fixed_t left, fixed_t right) {
    return (fixed_t)((left * right) / FIXED_ONE);
}

static fixed_t delta_for_component(fixed_t component) {
    fixed_t magnitude = fixed_abs(component);

    if (magnitude == 0) {
        return FIXED_INF;
    }
    if (magnitude == 1) {
        return 65536;
    }
    if (magnitude > 425) magnitude = 425;
    return reciprocal_delta[magnitude];
}

static inline __attribute__((always_inline)) uint8_t map_is_wall(int24_t x, int24_t y) {
    if ((uint24_t)x >= MAP_WIDTH || (uint24_t)y >= MAP_HEIGHT) {
        return 1;
    }

    return wall_map[((uint16_t)y << 4) | (uint16_t)x];
}

static uint8_t builtin_portal_index(uint8_t x, uint8_t y, uint8_t direction) {
    uint8_t value = builtin_portal_by_tile[((uint16_t)y << 4) | x];

    if (value != 0 && builtin_portals[value - 1].direction == direction) {
        return value;
    }
    return 0;
}

static uint8_t portal_matches(const Portal *portal, uint8_t x, uint8_t y, uint8_t direction) {
    return portal->valid && portal->x == x && portal->y == y && portal->direction == direction;
}

static uint8_t portal_find_exit(
    const GameState *game,
    uint8_t x,
    uint8_t y,
    uint8_t direction,
    Portal *exit,
    uint8_t *kind,
    uint8_t *portal_id
) {
    uint8_t index;

    *kind = PORTAL_NONE;
    if (portal_matches(&game->primary, x, y, direction)) {
        *kind = PORTAL_PRIMARY;
        if (game->secondary.valid) {
            *exit = game->secondary;
            *portal_id = 10;
            return 1;
        }
        return 0;
    }
    if (portal_matches(&game->secondary, x, y, direction)) {
        *kind = PORTAL_SECONDARY;
        if (game->primary.valid) {
            *exit = game->primary;
            *portal_id = 11;
            return 1;
        }
        return 0;
    }

    index = builtin_portal_index(x, y, direction);
    if (index != 0) {
        const PortalLink *link = &builtin_portals[index - 1];
        exit->x = link->target_x;
        exit->y = link->target_y;
        exit->direction = link->target_direction;
        exit->valid = 1;
        *kind = PORTAL_BUILTIN;
        *portal_id = (uint8_t)(index - 1);
        return 1;
    }
    return 0;
}

static int8_t portal_rotation(uint8_t entry_direction, uint8_t exit_direction) {
    if (entry_direction == exit_direction) {
        return 2;
    }

    switch (entry_direction) {
        case DIR_NORTH:
            if (exit_direction == DIR_SOUTH) return 0;
            return exit_direction == DIR_EAST ? 1 : -1;
        case DIR_EAST:
            if (exit_direction == DIR_WEST) return 0;
            return exit_direction == DIR_SOUTH ? 1 : -1;
        case DIR_SOUTH:
            if (exit_direction == DIR_NORTH) return 0;
            return exit_direction == DIR_WEST ? 1 : -1;
        case DIR_WEST:
            if (exit_direction == DIR_EAST) return 0;
            return exit_direction == DIR_NORTH ? 1 : -1;
        default:
            return 0;
    }
}

static void rotate_quarter(fixed_t *x, fixed_t *y, int8_t quarters) {
    fixed_t old_x = *x;
    fixed_t old_y = *y;

    if (quarters == 1) {
        *x = -old_y;
        *y = old_x;
    } else if (quarters == -1) {
        *x = old_y;
        *y = -old_x;
    } else if (quarters == 2 || quarters == -2) {
        *x = -old_x;
        *y = -old_y;
    }
}

static void cast_wall(
    fixed_t origin_x,
    fixed_t origin_y,
    fixed_t ray_x,
    fixed_t ray_y,
    int24_t map_x,
    int24_t map_y,
    RayHit *hit
) {
    fixed_t delta_x;
    fixed_t delta_y;
    fixed_t side_x;
    fixed_t side_y;
    fixed_t wall_position;

    hit->step_x = ray_x < 0 ? -1 : 1;
    hit->step_y = ray_y < 0 ? -1 : 1;

    if (ray_x == 0) {
        delta_x = FIXED_INF;
        side_x = FIXED_INF;
    } else {
        delta_x = delta_for_component(ray_x);
        if (ray_x < 0) {
            side_x = fixed_mul(origin_x - map_x * FIXED_ONE, delta_x);
        } else {
            side_x = fixed_mul((map_x + 1) * FIXED_ONE - origin_x, delta_x);
        }
    }

    if (ray_y == 0) {
        delta_y = FIXED_INF;
        side_y = FIXED_INF;
    } else {
        delta_y = delta_for_component(ray_y);
        if (ray_y < 0) {
            side_y = fixed_mul(origin_y - map_y * FIXED_ONE, delta_y);
        } else {
            side_y = fixed_mul((map_y + 1) * FIXED_ONE - origin_y, delta_y);
        }
    }

    do {
        if (side_x < side_y) {
            side_x += delta_x;
            map_x += hit->step_x;
            hit->side = 0;
        } else {
            side_y += delta_y;
            map_y += hit->step_y;
            hit->side = 1;
        }
    } while (!map_is_wall(map_x, map_y));

    if (hit->side == 0) {
        hit->distance = side_x - delta_x;
        hit->wall_direction = ray_x >= 0 ? DIR_NORTH : DIR_SOUTH;
        wall_position = origin_y + fixed_mul(hit->distance, ray_y);
    } else {
        hit->distance = side_y - delta_y;
        hit->wall_direction = ray_y >= 0 ? DIR_WEST : DIR_EAST;
        wall_position = origin_x + fixed_mul(hit->distance, ray_x);
    }

    if (hit->distance < 1) {
        hit->distance = 1;
    }
    hit->map_x = (uint8_t)map_x;
    hit->map_y = (uint8_t)map_y;
    hit->wall_u = (uint8_t)(wall_position & 0xFF);
    hit->portal_kind = PORTAL_NONE;
}

static void transform_ray(
    const RayHit *entry,
    const Portal *exit,
    fixed_t *origin_x,
    fixed_t *origin_y,
    fixed_t *ray_x,
    fixed_t *ray_y
) {
    fixed_t local_x = *origin_x - (fixed_t)entry->map_x * FIXED_ONE;
    fixed_t local_y = *origin_y - (fixed_t)entry->map_y * FIXED_ONE;
    int8_t rotation = portal_rotation(entry->wall_direction, exit->direction);

    if (entry->side == 0) {
        local_x += (fixed_t)entry->step_x * FIXED_ONE;
    } else {
        local_y += (fixed_t)entry->step_y * FIXED_ONE;
    }

    rotate_quarter(&local_x, &local_y, rotation);
    rotate_quarter(ray_x, ray_y, rotation);

    if (rotation == 2 || rotation == -2) {
        local_x += FIXED_ONE;
        local_y += FIXED_ONE;
    } else if (rotation == 1) {
        local_x += FIXED_ONE;
    } else if (rotation == -1) {
        local_y += FIXED_ONE;
    }

    *origin_x = (fixed_t)exit->x * FIXED_ONE + local_x;
    *origin_y = (fixed_t)exit->y * FIXED_ONE + local_y;
}

static void transform_player(GameState *game, const Portal *exit, uint8_t entry_direction) {
    fixed_t local_x = game->player_x - (game->player_x / FIXED_ONE) * FIXED_ONE;
    fixed_t local_y = game->player_y - (game->player_y / FIXED_ONE) * FIXED_ONE;
    int8_t rotation = portal_rotation(entry_direction, exit->direction);

    rotate_quarter(&local_x, &local_y, rotation);
    if (rotation == 2 || rotation == -2) {
        local_x += FIXED_ONE;
        local_y += FIXED_ONE;
    } else if (rotation == 1) {
        local_x += FIXED_ONE;
    } else if (rotation == -1) {
        local_y += FIXED_ONE;
    }

    game->player_x = (fixed_t)exit->x * FIXED_ONE + local_x;
    game->player_y = (fixed_t)exit->y * FIXED_ONE + local_y;
    game->angle = (uint16_t)((game->angle + rotation * 16 * (1 << ANGLE_FRACTION_BITS)) & ANGLE_MASK);
}

static void direction_for_angle(uint16_t angle, fixed_t *x, fixed_t *y) {
    uint8_t index = (uint8_t)((angle >> ANGLE_FRACTION_BITS) & (ANGLE_STEPS - 1));
    uint8_t next = (uint8_t)((index + 1) & (ANGLE_STEPS - 1));
    uint8_t fraction = (uint8_t)angle;

    *x = direction_x[index] +
        (fixed_t)(((int24_t)(direction_x[next] - direction_x[index]) * fraction) / 256);
    *y = direction_y[index] +
        (fixed_t)(((int24_t)(direction_y[next] - direction_y[index]) * fraction) / 256);
}

static void move_without_portal(GameState *game, fixed_t amount) {
    fixed_t dir_x;
    fixed_t dir_y;
    fixed_t delta_x;
    fixed_t delta_y;
    fixed_t candidate;
    fixed_t probe;

    direction_for_angle(game->angle, &dir_x, &dir_y);
    delta_x = fixed_mul(dir_x, amount);
    delta_y = fixed_mul(dir_y, amount);

    if (delta_x != 0) {
        candidate = game->player_x + delta_x;
        probe = candidate + (delta_x > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);
        if (!map_is_wall(probe / FIXED_ONE, game->player_y / FIXED_ONE)) {
            game->player_x = candidate;
        }
    }

    if (delta_y != 0) {
        candidate = game->player_y + delta_y;
        probe = candidate + (delta_y > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);
        if (!map_is_wall(game->player_x / FIXED_ONE, probe / FIXED_ONE)) {
            game->player_y = candidate;
        }
    }
}

static uint8_t try_player_portal(
    GameState *game,
    fixed_t probe_x,
    fixed_t probe_y,
    fixed_t move_amount
) {
    int24_t current_x = game->player_x / FIXED_ONE;
    int24_t current_y = game->player_y / FIXED_ONE;
    int24_t target_x = probe_x / FIXED_ONE;
    int24_t target_y = probe_y / FIXED_ONE;
    uint8_t wall_direction;
    Portal exit;
    uint8_t kind;
    uint8_t portal_id;

    if (target_x != current_x) {
        wall_direction = target_x < current_x ? DIR_SOUTH : DIR_NORTH;
        target_y = current_y;
    } else if (target_y != current_y) {
        wall_direction = target_y < current_y ? DIR_EAST : DIR_WEST;
        target_x = current_x;
    } else {
        return 0;
    }

    if (target_x < 0 || target_y < 0 || target_x >= MAP_WIDTH || target_y >= MAP_HEIGHT) {
        return 0;
    }

    if (!portal_find_exit(
        game,
        (uint8_t)target_x,
        (uint8_t)target_y,
        wall_direction,
        &exit,
        &kind,
        &portal_id
    )) {
        return 0;
    }

    (void)kind;
    (void)portal_id;
    transform_player(game, &exit, wall_direction);
    move_without_portal(game, move_amount);
    return 1;
}

static void move_player(GameState *game, fixed_t amount) {
    fixed_t dir_x;
    fixed_t dir_y;
    fixed_t delta_x;
    fixed_t delta_y;
    fixed_t candidate_x;
    fixed_t candidate_y;
    fixed_t probe_x;
    fixed_t probe_y;

    if (amount == 0) {
        return;
    }

    direction_for_angle(game->angle, &dir_x, &dir_y);
    delta_x = fixed_mul(dir_x, amount);
    delta_y = fixed_mul(dir_y, amount);
    candidate_x = game->player_x + delta_x;
    candidate_y = game->player_y + delta_y;
    probe_x = candidate_x + (delta_x > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);
    probe_y = candidate_y + (delta_y > 0 ? PLAYER_RADIUS : -PLAYER_RADIUS);

    if (delta_x != 0 && try_player_portal(game, probe_x, game->player_y, amount)) {
        return;
    }
    if (delta_y != 0 && try_player_portal(game, game->player_x, probe_y, amount)) {
        return;
    }
    move_without_portal(game, amount);
}

static void place_portal(GameState *game, uint8_t primary) {
    fixed_t origin_x = game->player_x;
    fixed_t origin_y = game->player_y;
    fixed_t ray_x;
    fixed_t ray_y;
    int24_t map_x = origin_x / FIXED_ONE;
    int24_t map_y = origin_y / FIXED_ONE;
    uint8_t depth;

    direction_for_angle(game->angle, &ray_x, &ray_y);

    for (depth = 0; depth < MAX_PORTAL_DEPTH; ++depth) {
        RayHit hit;
        Portal exit;
        uint8_t kind;
        uint8_t portal_id;

        cast_wall(origin_x, origin_y, ray_x, ray_y, map_x, map_y, &hit);

        if (portal_find_exit(
            game,
            hit.map_x,
            hit.map_y,
            hit.wall_direction,
            &exit,
            &kind,
            &portal_id
        )) {
            (void)kind;
            (void)portal_id;
            transform_ray(&hit, &exit, &origin_x, &origin_y, &ray_x, &ray_y);
            map_x = exit.x;
            map_y = exit.y;
            continue;
        }

        if (kind != PORTAL_NONE) {
            return;
        }

        if (primary) {
            game->primary.x = hit.map_x;
            game->primary.y = hit.map_y;
            game->primary.direction = hit.wall_direction;
            game->primary.valid = 1;
        } else {
            game->secondary.x = hit.map_x;
            game->secondary.y = hit.map_y;
            game->secondary.direction = hit.wall_direction;
            game->secondary.valid = 1;
        }
        return;
    }
}

static uint16_t wall_height_for_distance(fixed_t distance) {
    uint24_t table_index = (uint24_t)distance >> WALL_HEIGHT_TABLE_SHIFT;

    return table_index < WALL_HEIGHT_TABLE_SIZE ?
        wall_height_table[table_index] : WALL_HEIGHT_FAR;
}

static WallContext wall_context(const RayHit *ray) {
    WallContext context;
    int24_t height = wall_height_for_distance(ray->distance);
    int24_t start;
    int24_t end;

    if (height < 1) {
        height = 1;
    } else if (height > GFX_LCD_HEIGHT * 4) {
        height = GFX_LCD_HEIGHT * 4;
    }

    start = (GFX_LCD_HEIGHT - height) / 2;
    end = (GFX_LCD_HEIGHT + height) / 2;
    if (start < 0) start = 0;
    if (end > GFX_LCD_HEIGHT) end = GFX_LCD_HEIGHT;

    context.full_height = (uint16_t)height;
    context.start = (uint8_t)start;
    context.end = (uint8_t)end;
    return context;
}

static uint8_t wall_color(const RayHit *ray) {
    uint8_t dark = ray->side != 0;

    switch (ray->wall_direction) {
        case DIR_NORTH: return dark ? COLOR_NORTH_DARK : COLOR_NORTH;
        case DIR_SOUTH: return dark ? COLOR_SOUTH_DARK : COLOR_SOUTH;
        case DIR_EAST: return dark ? COLOR_EAST_DARK : COLOR_EAST;
        default: return dark ? COLOR_WEST_DARK : COLOR_WEST;
    }
}

static uint8_t portal_color(uint8_t kind) {
    if (kind == PORTAL_PRIMARY) return COLOR_PRIMARY;
    if (kind == PORTAL_SECONDARY) return COLOR_SECONDARY;
    return COLOR_BUILTIN;
}

static void draw_grid_segment(
    int24_t far_x,
    uint8_t far_y,
    int24_t near_x,
    uint8_t near_y
) {
    if ((far_x < 0 && near_x < 0) ||
        (far_x >= GFX_LCD_WIDTH && near_x >= GFX_LCD_WIDTH)) {
        return;
    }

    if ((uint24_t)far_x < GFX_LCD_WIDTH && (uint24_t)near_x < GFX_LCD_WIDTH) {
        gfx_Line_NoClip(far_x, far_y, near_x, near_y);
    } else {
        gfx_Line(far_x, far_y, near_x, near_y);
    }
}

static void draw_floor_grid(
    const GameState *game,
    fixed_t direction_x_value,
    fixed_t direction_y_value,
    uint8_t ceiling
) {
    fixed_t inverse_x = direction_x_value == 0 ? 0 :
        delta_for_component(direction_x_value);
    fixed_t inverse_y = direction_y_value == 0 ? 0 :
        delta_for_component(direction_y_value);
    fixed_t x_near = fixed_mul(direction_x_value, FLOOR_NEAR_DISTANCE);
    fixed_t x_far = fixed_mul(direction_x_value, FLOOR_FAR_DISTANCE);
    fixed_t y_near = fixed_mul(direction_y_value, FLOOR_NEAR_DISTANCE);
    fixed_t y_far = fixed_mul(direction_y_value, FLOOR_FAR_DISTANCE);
    uint16_t near_height = wall_height_for_distance(FLOOR_NEAR_DISTANCE);
    uint16_t far_height = wall_height_for_distance(FLOOR_FAR_DISTANCE);
    uint8_t near_screen_y = ceiling
        ? (uint8_t)(GFX_LCD_HEIGHT / 2 - near_height / 2)
        : (uint8_t)(GFX_LCD_HEIGHT / 2 + near_height / 2);
    uint8_t far_screen_y = ceiling
        ? (uint8_t)(GFX_LCD_HEIGHT / 2 - far_height / 2)
        : (uint8_t)(GFX_LCD_HEIGHT / 2 + far_height / 2);
    uint8_t line;

    if (!ceiling) {
        gfx_SetColor(COLOR_FLOOR);
        gfx_FillRectangle_NoClip(0, GFX_LCD_HEIGHT / 2, GFX_LCD_WIDTH, GFX_LCD_HEIGHT / 2);
    }
    gfx_SetColor(ceiling ? COLOR_SKY_HORIZON : COLOR_FLOOR_NEAR);

    /* Project the map's world-space X and Y grid lines into camera space. */
    for (line = 0; line <= MAP_WIDTH; ++line) {
        fixed_t grid_x = (fixed_t)line * FIXED_ONE;

        if (direction_y_value == 0) {
            fixed_t distance = fixed_mul(grid_x - game->player_x, inverse_x);

            if (direction_x_value < 0) distance = -distance;
            if (distance >= FLOOR_NEAR_DISTANCE && distance <= FLOOR_FAR_DISTANCE) {
                int24_t screen_y = ceiling
                    ? GFX_LCD_HEIGHT / 2 - wall_height_for_distance(distance) / 2
                    : GFX_LCD_HEIGHT / 2 + wall_height_for_distance(distance) / 2;

                if (screen_y >= 0 && screen_y < GFX_LCD_HEIGHT) {
                    gfx_HorizLine_NoClip(0, (uint8_t)screen_y, GFX_LCD_WIDTH);
                }
            }
        } else {
            fixed_t lateral_near = fixed_mul(
                x_near - (grid_x - game->player_x),
                inverse_y
            );
            fixed_t lateral_far = fixed_mul(
                x_far - (grid_x - game->player_x),
                inverse_y
            );
            int24_t screen_x_near;
            int24_t screen_x_far;

            if (direction_y_value < 0) {
                lateral_near = -lateral_near;
                lateral_far = -lateral_far;
            }
            screen_x_near = GFX_LCD_WIDTH / 2 +
                ((int32_t)lateral_near * near_height >> FIXED_SHIFT);
            screen_x_far = GFX_LCD_WIDTH / 2 +
                ((int32_t)lateral_far * far_height >> FIXED_SHIFT);
            if (screen_x_near < -FLOOR_PROJECT_LIMIT) screen_x_near = -FLOOR_PROJECT_LIMIT;
            if (screen_x_near > FLOOR_PROJECT_LIMIT) screen_x_near = FLOOR_PROJECT_LIMIT;
            if (screen_x_far < -FLOOR_PROJECT_LIMIT) screen_x_far = -FLOOR_PROJECT_LIMIT;
            if (screen_x_far > FLOOR_PROJECT_LIMIT) screen_x_far = FLOOR_PROJECT_LIMIT;
            draw_grid_segment(
                screen_x_far,
                far_screen_y,
                screen_x_near,
                near_screen_y
            );
        }
    }

    for (line = 0; line <= MAP_HEIGHT; ++line) {
        fixed_t grid_y = (fixed_t)line * FIXED_ONE;

        if (direction_x_value == 0) {
            fixed_t distance = fixed_mul(grid_y - game->player_y, inverse_y);

            if (direction_y_value < 0) distance = -distance;
            if (distance >= FLOOR_NEAR_DISTANCE && distance <= FLOOR_FAR_DISTANCE) {
                int24_t screen_y = ceiling
                    ? GFX_LCD_HEIGHT / 2 - wall_height_for_distance(distance) / 2
                    : GFX_LCD_HEIGHT / 2 + wall_height_for_distance(distance) / 2;

                if (screen_y >= 0 && screen_y < GFX_LCD_HEIGHT) {
                    gfx_HorizLine_NoClip(0, (uint8_t)screen_y, GFX_LCD_WIDTH);
                }
            }
        } else {
            fixed_t lateral_near = fixed_mul(
                (grid_y - game->player_y) - y_near,
                inverse_x
            );
            fixed_t lateral_far = fixed_mul(
                (grid_y - game->player_y) - y_far,
                inverse_x
            );
            int24_t screen_x_near;
            int24_t screen_x_far;

            if (direction_x_value < 0) {
                lateral_near = -lateral_near;
                lateral_far = -lateral_far;
            }
            screen_x_near = GFX_LCD_WIDTH / 2 +
                ((int32_t)lateral_near * near_height >> FIXED_SHIFT);
            screen_x_far = GFX_LCD_WIDTH / 2 +
                ((int32_t)lateral_far * far_height >> FIXED_SHIFT);
            if (screen_x_near < -FLOOR_PROJECT_LIMIT) screen_x_near = -FLOOR_PROJECT_LIMIT;
            if (screen_x_near > FLOOR_PROJECT_LIMIT) screen_x_near = FLOOR_PROJECT_LIMIT;
            if (screen_x_far < -FLOOR_PROJECT_LIMIT) screen_x_far = -FLOOR_PROJECT_LIMIT;
            if (screen_x_far > FLOOR_PROJECT_LIMIT) screen_x_far = FLOOR_PROJECT_LIMIT;
            draw_grid_segment(
                screen_x_far,
                far_screen_y,
                screen_x_near,
                near_screen_y
            );
        }
    }
}

static void draw_span(uint24_t x, uint8_t start, uint8_t end, uint8_t color) {
    if (end <= start) {
        return;
    }

    gfx_SetColor(color);
    gfx_FillRectangle_NoClip(x, start, COLUMN_WIDTH, (uint8_t)(end - start));
}

static void portal_opening(const RayHit *ray, const WallContext *context, uint8_t *top, uint8_t *bottom) {
    uint24_t u = ray->wall_u;
    uint24_t profile = (u * (256u - u)) >> 7;
    uint24_t half_height = (profile * context->full_height) >> 8;
    uint8_t center = (uint8_t)(((uint16_t)context->start + context->end) / 2);
    uint8_t visible_half = (uint8_t)((context->end - context->start) / 2);

    /* Keep a distant portal visibly open after its ellipse becomes sub-pixel. */
    if (profile != 0 && visible_half >= 2 && half_height < 2) {
        half_height = 2;
    }
    if (half_height > visible_half) {
        half_height = visible_half;
    }
    *top = (uint8_t)(center - half_height);
    *bottom = (uint8_t)(center + half_height);
}

static uint8_t portal_ring_thickness(uint8_t top, uint8_t bottom) {
    return bottom - top >= 8 ? 2 : 1;
}

static void draw_wall_clipped(const RayHit *ray, uint24_t x, uint8_t clip_start, uint8_t clip_end) {
    WallContext context = wall_context(ray);

    if (context.start < clip_start) context.start = clip_start;
    if (context.end > clip_end) context.end = clip_end;
    draw_span(x, context.start, context.end, wall_color(ray));
}

static void draw_portal_ring(const RayHit *ray, uint24_t x) {
    WallContext context;
    uint8_t top;
    uint8_t bottom;
    uint8_t top_end;
    uint8_t bottom_start;
    uint8_t thickness;
    uint8_t color;

    if (ray->portal_kind == PORTAL_NONE) {
        return;
    }

    context = wall_context(ray);
    portal_opening(ray, &context, &top, &bottom);
    color = portal_color(ray->portal_kind);
    thickness = portal_ring_thickness(top, bottom);
    top_end = (uint8_t)(top + thickness);
    if (top_end > context.end) top_end = context.end;

    if (bottom <= top + thickness) {
        draw_span(x, top, top_end, color);
        return;
    }
    bottom_start = (uint8_t)(bottom - thickness);
    if (bottom_start < context.start) bottom_start = context.start;
    draw_span(x, top, top_end, color);
    draw_span(x, bottom_start, bottom, color);
}

static void draw_portal_mask(const RayHit *ray, uint24_t x) {
    WallContext context = wall_context(ray);
    uint8_t top;
    uint8_t bottom;
    uint8_t top_end;
    uint8_t bottom_start;
    uint8_t thickness;
    uint8_t wall = wall_color(ray);
    uint8_t ring = portal_color(ray->portal_kind);

    portal_opening(ray, &context, &top, &bottom);
    thickness = portal_ring_thickness(top, bottom);
    top_end = (uint8_t)(top + thickness);
    if (top_end > context.end) top_end = context.end;
    if (bottom <= top + thickness) {
        draw_span(x, context.start, context.end, wall);
        draw_span(x, top, top_end, ring);
        return;
    }

    bottom_start = (uint8_t)(bottom - thickness);
    if (bottom_start < context.start) bottom_start = context.start;
    draw_span(x, context.start, top, wall);
    draw_span(x, top, top_end, ring);
    draw_span(x, bottom_start, bottom, ring);
    draw_span(x, bottom, context.end, wall);
}

static void render_column(
    const GameState *game,
    uint24_t x,
    fixed_t ray_x,
    fixed_t ray_y,
    uint8_t start_map_x,
    uint8_t start_map_y
) {
    fixed_t origin_x = game->player_x;
    fixed_t origin_y = game->player_y;
    int24_t map_x = start_map_x;
    int24_t map_y = start_map_y;
    uint16_t visited = 0;
    uint8_t count = 0;
    uint8_t clip_start = 0;
    uint8_t clip_end = GFX_LCD_HEIGHT;
    uint8_t terminal_open = 0;

    while (count < MAX_PORTAL_DEPTH) {
        Portal exit;
        uint8_t kind;
        uint8_t portal_id;
        uint8_t has_exit;
        WallContext context;
        uint8_t opening_start;
        uint8_t opening_end;
        uint8_t next_clip_start;
        uint8_t next_clip_end;
        RayHit *hit = &render_scratch.layers[count];

        cast_wall(origin_x, origin_y, ray_x, ray_y, map_x, map_y, hit);
        has_exit = portal_find_exit(
            game,
            hit->map_x,
            hit->map_y,
            hit->wall_direction,
            &exit,
            &kind,
            &portal_id
        );
        hit->portal_kind = kind;
        ++count;

        if (!has_exit) {
            break;
        }

        context = wall_context(hit);
        portal_opening(hit, &context, &opening_start, &opening_end);
        next_clip_start = opening_start > clip_start ? opening_start : clip_start;
        next_clip_end = opening_end < clip_end ? opening_end : clip_end;

        /* This portal is behind the current aperture, so its wall is terminal. */
        if (next_clip_end <= next_clip_start) {
            break;
        }

        clip_start = next_clip_start;
        clip_end = next_clip_end;

        /* Preserve an open aperture at the recursion/visibility limit. */
        if (clip_end - clip_start < PORTAL_RECURSE_MIN_HEIGHT ||
            count >= MAX_PORTAL_DEPTH ||
            (visited & (1u << portal_id)) != 0) {
            terminal_open = 1;
            break;
        }

        visited |= (uint16_t)(1u << portal_id);
        transform_ray(hit, &exit, &origin_x, &origin_y, &ray_x, &ray_y);
        map_x = exit.x;
        map_y = exit.y;
    }

    if (terminal_open) {
        draw_portal_mask(&render_scratch.layers[count - 1], x);
    } else {
        draw_wall_clipped(&render_scratch.layers[count - 1], x, clip_start, clip_end);
        draw_portal_ring(&render_scratch.layers[count - 1], x);
    }

    while (count > 1) {
        --count;
        draw_portal_mask(&render_scratch.layers[count - 1], x);
    }
}

void game_init(GameState *game) {
    game->player_x = FIXED_ONE + FIXED_ONE / 2;
    game->player_y = FIXED_ONE * 2 + FIXED_ONE / 2;
    game->angle = 32u << ANGLE_FRACTION_BITS;
    game->primary.valid = 0;
    game->secondary.valid = 0;
    game->previous_buttons = 0;
}

void game_graphics_init(void) {
    uint24_t index;
    uint16_t height = GFX_LCD_HEIGHT * 4;

    wall_height_table[0] = height;
    for (index = 1; index < WALL_HEIGHT_TABLE_SIZE; ++index) {
        while (height > 1 && (uint24_t)height * index >
            ((uint24_t)GFX_LCD_HEIGHT * FIXED_ONE >> WALL_HEIGHT_TABLE_SHIFT)) {
            --height;
        }
        wall_height_table[index] = height;
    }

    gfx_palette[COLOR_BLACK] = gfx_RGBTo1555(0, 0, 0);
    gfx_palette[COLOR_SKY] = gfx_RGBTo1555(24, 28, 48);
    gfx_palette[COLOR_SKY_HORIZON] = gfx_RGBTo1555(48, 54, 78);
    gfx_palette[COLOR_FLOOR] = gfx_RGBTo1555(54, 54, 54);
    gfx_palette[COLOR_FLOOR_NEAR] = gfx_RGBTo1555(32, 32, 32);
    gfx_palette[COLOR_NORTH] = gfx_RGBTo1555(40, 90, 255);
    gfx_palette[COLOR_NORTH_DARK] = gfx_RGBTo1555(20, 45, 145);
    gfx_palette[COLOR_SOUTH] = gfx_RGBTo1555(40, 220, 80);
    gfx_palette[COLOR_SOUTH_DARK] = gfx_RGBTo1555(20, 120, 45);
    gfx_palette[COLOR_EAST] = gfx_RGBTo1555(240, 55, 55);
    gfx_palette[COLOR_EAST_DARK] = gfx_RGBTo1555(135, 25, 25);
    gfx_palette[COLOR_WEST] = gfx_RGBTo1555(30, 215, 215);
    gfx_palette[COLOR_WEST_DARK] = gfx_RGBTo1555(18, 115, 115);
    gfx_palette[COLOR_PRIMARY] = gfx_RGBTo1555(255, 140, 0);
    gfx_palette[COLOR_SECONDARY] = gfx_RGBTo1555(0, 130, 255);
    gfx_palette[COLOR_BUILTIN] = gfx_RGBTo1555(180, 180, 180);
    gfx_palette[COLOR_HUD] = gfx_RGBTo1555(255, 255, 255);
}

uint8_t game_update(
    GameState *game,
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    fixed_t previous_x = game->player_x;
    fixed_t previous_y = game->player_y;
    uint16_t previous_angle = game->angle;
    Portal previous_primary = game->primary;
    Portal previous_secondary = game->secondary;
    uint8_t pressed = (uint8_t)(buttons & (uint8_t)~game->previous_buttons);
    uint24_t maximum_ticks;
    fixed_t move_amount;
    int24_t turn_amount;

    game->previous_buttons = buttons;
    if (ticks_per_second == 0) {
        return 0;
    }

    maximum_ticks = ticks_per_second / 8u;
    if (elapsed_ticks > maximum_ticks) {
        elapsed_ticks = maximum_ticks;
    }

    if ((pressed & PORTAL_BUTTON_PRIMARY) != 0) {
        place_portal(game, 1);
    }
    if ((pressed & PORTAL_BUTTON_SECONDARY) != 0) {
        place_portal(game, 0);
    }
    if ((pressed & PORTAL_BUTTON_CLEAR) != 0) {
        game->primary.valid = 0;
        game->secondary.valid = 0;
    }

    turn_amount = (int24_t)(((int32_t)TURN_SPEED * (1 << ANGLE_FRACTION_BITS) * elapsed_ticks) / ticks_per_second);
    game->angle = (uint16_t)((game->angle + turn_axis * turn_amount) & ANGLE_MASK);

    move_amount = (fixed_t)(((int32_t)MOVE_SPEED * elapsed_ticks) / ticks_per_second);
    move_player(game, (fixed_t)(move_axis * move_amount));

    return (uint8_t)(
        game->player_x != previous_x ||
        game->player_y != previous_y ||
        game->angle != previous_angle ||
        game->primary.x != previous_primary.x ||
        game->primary.y != previous_primary.y ||
        game->primary.direction != previous_primary.direction ||
        game->primary.valid != previous_primary.valid ||
        game->secondary.x != previous_secondary.x ||
        game->secondary.y != previous_secondary.y ||
        game->secondary.direction != previous_secondary.direction ||
        game->secondary.valid != previous_secondary.valid
    );
}

/* 3-by-5 glyphs: F, P, S, then digits 0 through 9. */
static const uint8_t hud_glyphs[13][5] = {
    {7, 4, 6, 4, 4},
    {6, 5, 6, 4, 4},
    {7, 4, 7, 1, 7},
    {7, 5, 5, 5, 7},
    {2, 6, 2, 2, 7},
    {7, 1, 7, 4, 7},
    {7, 1, 7, 1, 7},
    {5, 5, 7, 1, 1},
    {7, 4, 7, 1, 7},
    {7, 4, 7, 5, 7},
    {7, 1, 2, 2, 2},
    {7, 5, 7, 5, 7},
    {7, 5, 7, 1, 7}
};

static void draw_hud_glyph(uint8_t glyph, uint8_t x, uint8_t y) {
    uint8_t row;

    for (row = 0; row < 5; ++row) {
        uint8_t bits = hud_glyphs[glyph][row];
        uint8_t column;

        for (column = 0; column < 3; ++column) {
            if ((bits & (4u >> column)) != 0) {
                gfx_vbuffer[y + row][x + column] = COLOR_HUD;
            }
        }
    }
}

static void draw_fps_counter(uint8_t fps) {
    uint8_t row;

    gfx_SetColor(COLOR_BLACK);
    for (row = 0; row < 8; ++row) {
        gfx_HorizLine_NoClip(0, row, 32);
    }
    draw_hud_glyph(0, 2, 2);
    draw_hud_glyph(1, 6, 2);
    draw_hud_glyph(2, 10, 2);
    draw_hud_glyph((uint8_t)(3 + fps / 100u), 18, 2);
    draw_hud_glyph((uint8_t)(3 + (fps / 10u) % 10u), 22, 2);
    draw_hud_glyph((uint8_t)(3 + fps % 10u), 26, 2);
}

void game_render(const GameState *game, uint8_t fps) {
    fixed_t dir_x;
    fixed_t dir_y;
    fixed_t plane_x;
    fixed_t plane_y;
    uint8_t player_map_x = (uint8_t)(game->player_x / FIXED_ONE);
    uint8_t player_map_y = (uint8_t)(game->player_y / FIXED_ONE);
    uint24_t column;

    direction_for_angle(game->angle, &dir_x, &dir_y);
    plane_x = -fixed_mul_camera(dir_y, FIELD_OF_VIEW);
    plane_y = fixed_mul_camera(dir_x, FIELD_OF_VIEW);

    gfx_SetColor(COLOR_SKY);
    gfx_FillRectangle_NoClip(0, 0, GFX_LCD_WIDTH, GFX_LCD_HEIGHT / 2);
    gfx_SetColor(COLOR_SKY_HORIZON);
    gfx_FillRectangle_NoClip(0, 96, GFX_LCD_WIDTH, 24);

    draw_floor_grid(game, dir_x, dir_y, 1);
    draw_floor_grid(game, dir_x, dir_y, 0);

    for (column = 0; column < LOGICAL_COLUMNS; ++column) {
        fixed_t camera_x = camera_x_by_column[column];
        fixed_t ray_x = dir_x + fixed_mul_camera(plane_x, camera_x);
        fixed_t ray_y = dir_y + fixed_mul_camera(plane_y, camera_x);
        render_column(
            game,
            column * COLUMN_WIDTH,
            ray_x,
            ray_y,
            player_map_x,
            player_map_y
        );
    }

    draw_fps_counter(fps);
}
