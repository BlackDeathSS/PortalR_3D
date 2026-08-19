#include "engine_bridge.h"

#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

#ifndef TI_LUNG_RAYCASTER
#define TI_LUNG_RAYCASTER 0
#endif

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)
#define NAV_SHIFT 12
#define NAV_ONE ((int32_t)1 << NAV_SHIFT)
#define UPDATE_RATE 30u

#define CABIN_ROOM 0u
#define EXTERIOR_ROOM 1u
#define CAVE_SIZE 64u
#define MAP_LIMIT 950u
#define SUB_RADIUS (8 * FIXED_ONE)
#define NAV_SPEED (10 * FIXED_ONE)
#define TURN_CDEG_PER_SECOND 2800u
#define SENSOR_RANGE (120 * FIXED_ONE)
#define SENSOR_STEP (6 * FIXED_ONE)
#define SENSOR_MAX_UNITS 120u
#define PROXIMITY_DISPLAY_RANGE 13u
#define PHOTO_POSITION_TOLERANCE (18 * FIXED_ONE)
#define PHOTO_HEADING_TOLERANCE 1000u
#define CAMERA_HEIGHT 640
#define EXTERIOR_WORLD_SCALE 60
#define EXTERIOR_WORLD_MIN (-28500)
#define EXTERIOR_WORLD_MAX 28500
#define PHOTO_RENDER_DISTANCE (30u * EXTERIOR_WORLD_SCALE)
#define EXTERIOR_CHUNK_RADIUS 16u
#define EXTERIOR_WALL_LIMIT 60u
#define SAVE_NAME "TILUNGS"
#define SAVE_MAGIC 0x54494C55UL
#define SAVE_VERSION 2u

#define EVENT_SENSOR_GHOST (1u << 0)
#define EVENT_FISH_ONE (1u << 1)
#define EVENT_FIRE (1u << 2)
#define EVENT_FISH_TWO (1u << 3)
#define EVENT_EYE_ACTIVE (1u << 4)
#define EVENT_EYE_SEEN (1u << 5)
#define EVENT_FINAL (1u << 6)
#define EVENT_BONE_FISH (1u << 7)
#define EVENT_BONE_EEL (1u << 8)
#define EVENT_BONE_MAW (1u << 9)

enum UiColor {
    UI_BLACK = 0,
    UI_VOID = 1,
    UI_FLOOR = 2,
    UI_CEILING = 3,
    UI_GREEN = 4,
    UI_GREEN_DARK = 5,
    UI_BROWN = 6,
    UI_BROWN_DARK = 7,
    UI_RED = 8,
    UI_RED_DARK = 9,
    UI_BLUE = 10,
    UI_ORANGE = 11,
    UI_WHITE = 12,
    UI_RUST = 240,
    UI_RUST_LIGHT = 241,
    UI_PAPER = 242,
    UI_PAPER_DARK = 243,
    PHOTO_BLACK = 244,
    PHOTO_DARK = 245,
    PHOTO_MID = 246,
    PHOTO_LIGHT = 247,
    PHOTO_WHITE = 248
};

enum LungView {
    VIEW_CABIN = 0,
    VIEW_MAP,
    VIEW_BRIEFING,
    VIEW_PHOTO,
    VIEW_ATTACK,
    VIEW_END,
    VIEW_DEBUG
};

enum Station {
    STATION_NONE = 0,
    STATION_HELM,
    STATION_CAMERA,
    STATION_EXTINGUISHER
};

enum EdgeKey {
    EDGE_USE = 1u << 0,
    EDGE_MAP = 1u << 1,
    EDGE_BRIEFING = 1u << 2,
    EDGE_DEBUG = 1u << 3
};

enum MessageId {
    MESSAGE_NONE = 0,
    MESSAGE_HULL_CONTACT,
    MESSAGE_SENSOR_CONTACT,
    MESSAGE_FISH_IMPACT,
    MESSAGE_FIRE,
    MESSAGE_SECOND_IMPACT,
    MESSAGE_EYE,
    MESSAGE_PHOTO_VALID,
    MESSAGE_PHOTO_INVALID,
    MESSAGE_FIRE_OUT,
    MESSAGE_BONE_FISH,
    MESSAGE_BONE_EEL,
    MESSAGE_BONE_MAW,
    MESSAGE_BONE_PHOTO
};

typedef struct {
    uint16_t x;
    uint16_t y;
} CaveNode;

typedef struct {
    fixed_t x;
    fixed_t y;
    uint16_t heading_cdeg;
    uint8_t scene;
} PhotoPoint;

typedef struct {
    fixed_t x;
    fixed_t y;
    uint8_t phase;
    uint8_t speed;
    uint8_t radius;
    uint8_t kind;
    uint8_t active;
} SkeletalCreature;

typedef struct {
    fixed_t x;
    fixed_t y;
    /* Navigation lives at 1/4096th-coordinate precision.  x/y are compact
       Q8 mirrors retained for the sensor field and legacy level helpers. */
    int32_t precise_x;
    int32_t precise_y;
    fixed_t sensor[16];
    uint16_t heading_cdeg;
    uint16_t photo_count;
    uint16_t documented_mask;
    uint16_t event_flags;
    uint16_t hazard_ticks;
    uint8_t view;
    uint8_t previous_edge_keys;
    uint8_t helm_active;
    uint8_t fire_level;
    uint8_t oxygen;
    uint8_t pressure;
    uint8_t leak_level;
    uint8_t distortion;
    uint8_t message;
    uint8_t message_ticks;
    uint8_t last_scene;
    uint8_t attack_ticks;
    uint8_t has_moved;
    uint16_t map_cursor_x;
    uint16_t map_cursor_y;
    uint16_t waypoint_x;
    uint16_t waypoint_y;
    uint8_t waypoint_active;
    uint16_t photo_ticks;
    uint16_t autosave_ticks;
} LungState;

typedef struct {
    uint32_t magic;
    uint8_t version;
    LungState state;
} LungSave;

static const int16_t quarter_sine[65] = {
    0, 6, 13, 19, 25, 31, 38, 44, 50, 56, 62, 68, 74, 80, 86, 92,
    98, 104, 109, 115, 121, 126, 132, 137, 142, 147, 152, 157, 162,
    167, 172, 177, 181, 185, 190, 194, 198, 202, 206, 209, 213, 216,
    220, 223, 226, 229, 231, 234, 237, 239, 241, 243, 245, 247, 248,
    250, 251, 252, 253, 254, 255, 255, 256, 256, 256
};

/* This route is carved into a compact occupancy field. It follows the known
 * SM-13 navigation path while leaving enough uncertainty around each bend for
 * the proximity array to matter. */
static const CaveNode cave_route[] = {
    {182, 116}, {200, 210}, {225, 116}, {322, 186}, {378, 263},
    {275, 350}, {259, 406}, {325, 310}, {400, 325}, {560, 277},
    {613, 197}, {825, 300}, {864, 258}, {700, 230}, {576, 355},
    {562, 450}, {623, 520}, {370, 525}, {370, 637}, {250, 662},
    {180, 614}, {180, 576}, {276, 635}, {325, 741}, {500, 685},
    {550, 700}, {675, 800}, {675, 828}
};

static const PhotoPoint photo_points[10] = {
    {322 * FIXED_ONE, 186 * FIXED_ONE,  3300u, 0u},
    {378 * FIXED_ONE, 263 * FIXED_ONE,  5000u, 1u},
    {259 * FIXED_ONE, 406 * FIXED_ONE, 29600u, 2u},
    {560 * FIXED_ONE, 277 * FIXED_ONE,  4300u, 3u},
    {613 * FIXED_ONE, 197 * FIXED_ONE,  5500u, 4u},
    {864 * FIXED_ONE, 258 * FIXED_ONE, 20900u, 5u},
    {623 * FIXED_ONE, 520 * FIXED_ONE,  6300u, 6u},
    {180 * FIXED_ONE, 576 * FIXED_ONE, 18400u, 7u},
    {325 * FIXED_ONE, 741 * FIXED_ONE,  1800u, 8u},
    {675 * FIXED_ONE, 828 * FIXED_ONE, 29500u, 9u}
};

static True3DLevelView level;
static EngineState cabin_camera;
static LungState lung;
static uint8_t cave_bits[CAVE_SIZE][CAVE_SIZE / 8u];
static uint16_t displayed_fps_tenths = 100u;
static uint8_t exterior_chunk_x = 0xFFu;
static uint8_t exterior_chunk_y = 0xFFu;
static uint8_t debug_poi_index = 0xFFu;
static uint8_t debug_prgm_held;
static uint8_t debug_stat_held;
static uint8_t debug_creature_index = 0xFFu;
static SkeletalCreature creatures[3];

static uint8_t build_exterior_scene(
    uint8_t scene, uint8_t debug_red, uint8_t include_subject
);
static void setup_exterior_camera(void);
static void draw_debug_view(void);
static void configure_ui_palette(void);
static void initialize_palette(void);
static void debug_teleport_next_poi(void);

static fixed_t fixed_absolute(fixed_t value) {
    return value < 0 ? -value : value;
}

static fixed_t fixed_mul(fixed_t left, fixed_t right) {
    return (fixed_t)(((int32_t)left * right) >> FIXED_SHIFT);
}

static fixed_t precise_to_fixed(int32_t value) {
    return (fixed_t)(value >> (NAV_SHIFT - FIXED_SHIFT));
}

/* The navigation map remains 950 units wide, but its 3D representation is
   centred and stretched to make the blood ocean feel properly enormous. */
static fixed_t exterior_world_from_map(uint16_t coordinate) {
    return (fixed_t)(((int32_t)coordinate - (MAP_LIMIT / 2u)) *
        EXTERIOR_WORLD_SCALE);
}

static uint16_t exterior_map_from_world(fixed_t coordinate) {
    int32_t map_coordinate = (int32_t)coordinate / EXTERIOR_WORLD_SCALE +
        (MAP_LIMIT / 2u);

    if (map_coordinate < 0) return 0u;
    if (map_coordinate > MAP_LIMIT) return MAP_LIMIT;
    return (uint16_t)map_coordinate;
}

static void set_navigation_position(uint16_t x, uint16_t y) {
    lung.precise_x = (int32_t)x * NAV_ONE;
    lung.precise_y = (int32_t)y * NAV_ONE;
    lung.x = precise_to_fixed(lung.precise_x);
    lung.y = precise_to_fixed(lung.precise_y);
}

static void sync_navigation_position(void) {
    lung.x = precise_to_fixed(lung.precise_x);
    lung.y = precise_to_fixed(lung.precise_y);
}

static fixed_t angle_sine(uint8_t angle) {
    uint8_t quadrant = angle >> 6;
    uint8_t offset = angle & 63u;

    if (quadrant == 0u) return quarter_sine[offset];
    if (quadrant == 1u) return quarter_sine[64u - offset];
    if (quadrant == 2u) return -quarter_sine[offset];
    return -quarter_sine[64u - offset];
}

static uint8_t heading_angle(void) {
    return (uint8_t)(((uint32_t)lung.heading_cdeg * 256u + 18000u) / 36000u);
}

static uint16_t heading_difference(uint16_t first, uint16_t second) {
    uint16_t difference = first > second ? first - second : second - first;

    return difference > 18000u ? 36000u - difference : difference;
}

static void rebuild_basis(EngineState *state) {
    uint8_t pitch_magnitude = (uint8_t)(
        state->pitch < 0 ? -state->pitch : state->pitch
    );
    fixed_t sine_yaw = angle_sine(state->yaw);
    fixed_t cosine_yaw = angle_sine((uint8_t)(state->yaw + 64u));
    fixed_t sine_pitch = quarter_sine[pitch_magnitude];
    fixed_t cosine_pitch = quarter_sine[64u - pitch_magnitude];

    if (state->pitch < 0) sine_pitch = -sine_pitch;
    state->right = (Vec3){-sine_yaw, cosine_yaw, 0};
    state->forward = (Vec3){
        fixed_mul(cosine_pitch, cosine_yaw),
        fixed_mul(cosine_pitch, sine_yaw),
        sine_pitch
    };
    state->up = (Vec3){
        -fixed_mul(sine_pitch, cosine_yaw),
        -fixed_mul(sine_pitch, sine_yaw),
        cosine_pitch
    };
}

static void set_text(uint8_t color, int16_t x, int16_t y) {
    gfx_SetTextFGColor(color);
    gfx_SetTextXY(x, y);
}

static void print_precise_hundredths(int32_t value) {
    uint32_t magnitude;
    uint32_t hundredths;

    if (value < 0) {
        gfx_PrintChar('-');
        magnitude = (uint32_t)-value;
    } else {
        magnitude = (uint32_t)value;
    }
    hundredths = (magnitude * 100u + NAV_ONE / 2u) >> NAV_SHIFT;
    gfx_PrintUInt(hundredths / 100u, 1u);
    gfx_PrintChar('.');
    gfx_PrintUInt(hundredths % 100u, 2u);
}

static void print_heading(void) {
    gfx_PrintUInt(lung.heading_cdeg / 100u, 3u);
    gfx_PrintChar('.');
    gfx_PrintUInt(lung.heading_cdeg % 100u, 2u);
}

static void print_heading_value(uint16_t heading_cdeg) {
    gfx_PrintUInt(heading_cdeg / 100u, 3u);
    gfx_PrintChar('.');
    gfx_PrintUInt(heading_cdeg % 100u, 2u);
}

static uint8_t documented_count(void) {
    uint16_t mask = lung.documented_mask & 0x01FFu;
    uint8_t count = 0u;

    while (mask != 0u) {
        count += (uint8_t)(mask & 1u);
        mask >>= 1;
    }
    return count;
}

static int16_t integer_absolute(int16_t value) {
    return value < 0 ? -value : value;
}

static uint8_t coordinate_cell(uint16_t coordinate) {
    if (coordinate >= MAP_LIMIT) return CAVE_SIZE - 1u;
    return (uint8_t)(((uint24_t)coordinate * (CAVE_SIZE - 1u)) / MAP_LIMIT);
}

static void cave_set(int16_t x, int16_t y) {
    if (x < 0 || y < 0 || x >= (int16_t)CAVE_SIZE ||
        y >= (int16_t)CAVE_SIZE) return;
    cave_bits[y][(uint8_t)x >> 3] |= (uint8_t)(1u << ((uint8_t)x & 7u));
}

static uint8_t cave_cell_open(uint8_t x, uint8_t y) {
    return (uint8_t)(
        (cave_bits[y][x >> 3] & (uint8_t)(1u << (x & 7u))) != 0u
    );
}

static void carve_disc(int16_t center_x, int16_t center_y, uint8_t radius) {
    int16_t x;
    int16_t y;
    int16_t radius_squared = (int16_t)radius * radius;

    for (y = center_y - radius; y <= center_y + radius; ++y) {
        for (x = center_x - radius; x <= center_x + radius; ++x) {
            int16_t dx = x - center_x;
            int16_t dy = y - center_y;

            if (dx * dx + dy * dy <= radius_squared) cave_set(x, y);
        }
    }
}

static void carve_line(CaveNode first, CaveNode second, uint8_t radius) {
    int16_t x0 = coordinate_cell(first.x);
    int16_t y0 = coordinate_cell(first.y);
    int16_t x1 = coordinate_cell(second.x);
    int16_t y1 = coordinate_cell(second.y);
    int16_t dx = integer_absolute(x1 - x0);
    int16_t dy = integer_absolute(y1 - y0);
    int16_t sx = x0 < x1 ? 1 : -1;
    int16_t sy = y0 < y1 ? 1 : -1;
    int16_t error = dx - dy;

    for (;;) {
        carve_disc(x0, y0, radius);
        if (x0 == x1 && y0 == y1) break;
        {
            int16_t doubled = error * 2;

            if (doubled > -dy) {
                error -= dy;
                x0 += sx;
            }
            if (doubled < dx) {
                error += dx;
                y0 += sy;
            }
        }
    }
}

static void build_cave(void) {
    uint8_t index;

    memset(cave_bits, 0, sizeof(cave_bits));
    for (index = 1u;
         index < sizeof(cave_route) / sizeof(cave_route[0]);
         ++index) {
        carve_line(cave_route[index - 1u], cave_route[index], 2u);
    }
    for (index = 0u; index < 10u; ++index) {
        carve_disc(
            coordinate_cell((uint16_t)(photo_points[index].x >> FIXED_SHIFT)),
            coordinate_cell((uint16_t)(photo_points[index].y >> FIXED_SHIFT)),
            index == 9u ? 4u : 3u
        );
    }
    carve_disc(coordinate_cell(500u), coordinate_cell(690u), 6u);
    carve_disc(coordinate_cell(575u), coordinate_cell(360u), 5u);
}

static uint8_t cave_open_at(fixed_t x, fixed_t y) {
    int24_t integer_x;
    int24_t integer_y;
    uint8_t cell_x;
    uint8_t cell_y;

    if (x < 0 || y < 0 ||
        x >= (fixed_t)MAP_LIMIT * FIXED_ONE ||
        y >= (fixed_t)MAP_LIMIT * FIXED_ONE) {
        return 0u;
    }
    integer_x = x >> FIXED_SHIFT;
    integer_y = y >> FIXED_SHIFT;
    cell_x = coordinate_cell((uint16_t)integer_x);
    cell_y = coordinate_cell((uint16_t)integer_y);
    return cave_cell_open(cell_x, cell_y);
}

static uint8_t point_blocked(fixed_t x, fixed_t y) {
    return (uint8_t)(
        !cave_open_at(x, y) ||
        !cave_open_at(x + SUB_RADIUS, y) ||
        !cave_open_at(x - SUB_RADIUS, y) ||
        !cave_open_at(x, y + SUB_RADIUS) ||
        !cave_open_at(x, y - SUB_RADIUS)
    );
}

static fixed_t cast_sensor(uint8_t angle) {
    fixed_t sine = angle_sine(angle);
    fixed_t cosine = angle_sine((uint8_t)(angle + 64u));
    fixed_t distance;

    for (distance = SENSOR_STEP;
         distance <= SENSOR_RANGE;
         distance += SENSOR_STEP) {
        if (point_blocked(
                lung.x + fixed_mul(sine, distance),
                lung.y + fixed_mul(cosine, distance)
            )) {
            return distance;
        }
    }
    return SENSOR_RANGE;
}

static void update_creatures(void) {
    static const uint16_t event_mask[3] = {
        EVENT_BONE_FISH, EVENT_BONE_EEL, EVENT_BONE_MAW
    };
    uint8_t index;

    for (index = 0u; index < 3u; ++index) {
        SkeletalCreature *creature = &creatures[index];
        creature->active = (uint8_t)(
            (lung.event_flags & event_mask[index]) != 0u ||
            debug_creature_index == index
        );
        if (!creature->active) continue;
        creature->phase = (uint8_t)(creature->phase + creature->speed);
        /* The organisms circle the hull rather than occupying a fixed map
           prop. Different radii/speeds make the returns cross the camera and
           four proximity quadrants independently. */
        creature->x = lung.x + fixed_mul(
            angle_sine(creature->phase),
            (fixed_t)creature->radius * FIXED_ONE
        );
        creature->y = lung.y + fixed_mul(
            angle_sine((uint8_t)(creature->phase + 64u)),
            (fixed_t)creature->radius * FIXED_ONE
        );
    }
}

static fixed_t creature_distance(const SkeletalCreature *creature) {
    fixed_t dx = fixed_absolute(creature->x - lung.x);
    fixed_t dy = fixed_absolute(creature->y - lung.y);
    return dx > dy ? dx : dy;
}

static void update_sensors(void) {
    uint8_t angle = heading_angle();
    uint8_t index;

    for (index = 0u; index < 16u; ++index) {
        lung.sensor[index] = cast_sensor((uint8_t)(angle + index * 16u));
    }

    if ((lung.x >= 532 * FIXED_ONE && lung.x <= 550 * FIXED_ONE &&
         documented_count() >= 4u) ||
        (lung.event_flags & EVENT_EYE_ACTIVE) != 0u) {
        lung.sensor[0] = FIXED_ONE;
    }

    /* A close moving skeleton is a real sonar return. Choose the nearest of
       the four body-relative transducers; distant creatures remain silent. */
    for (index = 0u; index < 3u; ++index) {
        SkeletalCreature *creature = &creatures[index];
        fixed_t distance;
        fixed_t dx;
        fixed_t dy;
        int32_t best_dot = INT32_MIN;
        uint8_t direction;
        uint8_t best_direction = 0u;

        if (!creature->active) continue;
        distance = creature_distance(creature);
        if (distance > (fixed_t)PROXIMITY_DISPLAY_RANGE * FIXED_ONE) continue;
        dx = creature->x - lung.x;
        dy = creature->y - lung.y;
        for (direction = 0u; direction < 4u; ++direction) {
            uint8_t sensor_angle = (uint8_t)(angle + direction * 64u);
            int32_t dot = (int32_t)fixed_mul(angle_sine(sensor_angle), dx) +
                fixed_mul(angle_sine((uint8_t)(sensor_angle + 64u)), dy);
            if (dot > best_dot) {
                best_dot = dot;
                best_direction = direction;
            }
        }
        best_direction = (uint8_t)(best_direction * 4u);
        if (distance < lung.sensor[best_direction]) {
            lung.sensor[best_direction] = distance;
        }
    }
}

static void set_message(uint8_t message, uint8_t ticks) {
    lung.message = message;
    lung.message_ticks = ticks;
}

static void update_scripted_events(void) {
    uint8_t photos = documented_count();

    if (photos >= 2u && (lung.event_flags & EVENT_BONE_FISH) == 0u) {
        lung.event_flags |= EVENT_BONE_FISH;
        creatures[0].phase = heading_angle();
        set_message(MESSAGE_BONE_FISH, 120u);
    }
    if (photos >= 5u && (lung.event_flags & EVENT_BONE_EEL) == 0u) {
        lung.event_flags |= EVENT_BONE_EEL;
        creatures[1].phase = heading_angle();
        set_message(MESSAGE_BONE_EEL, 120u);
    }
    if (photos >= 8u && (lung.event_flags & EVENT_BONE_MAW) == 0u) {
        lung.event_flags |= EVENT_BONE_MAW;
        creatures[2].phase = heading_angle();
        set_message(MESSAGE_BONE_MAW, 120u);
    }

    if (photos >= 4u && lung.x >= 532 * FIXED_ONE &&
        lung.x <= 550 * FIXED_ONE &&
        (lung.event_flags & EVENT_SENSOR_GHOST) == 0u) {
        lung.event_flags |= EVENT_SENSOR_GHOST;
        set_message(MESSAGE_SENSOR_CONTACT, 90u);
    }
    if (photos >= 6u && lung.x >= 700 * FIXED_ONE &&
        lung.y <= 330 * FIXED_ONE &&
        (lung.event_flags & EVENT_FISH_ONE) == 0u) {
        lung.event_flags |= EVENT_FISH_ONE;
        set_navigation_position(576u, 355u);
        lung.pressure = 3u;
        lung.leak_level = 1u;
        set_message(MESSAGE_FISH_IMPACT, 120u);
    }
    if (photos >= 7u && lung.y >= 620 * FIXED_ONE &&
        (lung.event_flags & EVENT_FIRE) == 0u) {
        lung.event_flags |= EVENT_FIRE;
        lung.fire_level = 100u;
        lung.distortion = 1u;
        set_message(MESSAGE_FIRE, 120u);
    }
    if (photos >= 8u && lung.x <= 215 * FIXED_ONE &&
        lung.y >= 570 * FIXED_ONE &&
        (lung.event_flags & EVENT_FISH_TWO) == 0u) {
        lung.event_flags |= EVENT_FISH_TWO;
        set_navigation_position(276u, 635u);
        lung.pressure = 2u;
        lung.leak_level = 2u;
        lung.distortion = 2u;
        set_message(MESSAGE_SECOND_IMPACT, 120u);
    }
    if (photos >= 9u && lung.x >= 440 * FIXED_ONE &&
        lung.y >= 650 * FIXED_ONE) {
        lung.event_flags |= EVENT_EYE_ACTIVE;
    }
    update_sensors();
}

static uint8_t update_navigation(
    int8_t throttle,
    int8_t turn,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    uint8_t changed = 0u;

    if (turn != 0) {
        uint24_t step = (
            (uint32_t)TURN_CDEG_PER_SECOND * elapsed_ticks +
            ticks_per_second / 2u
        ) / ticks_per_second;
        int24_t heading;

        if (step == 0u) step = 1u;
        heading = (int24_t)lung.heading_cdeg + turn * (int24_t)step;
        while (heading < 0) heading += 36000;
        while (heading >= 36000) heading -= 36000;
        lung.heading_cdeg = (uint16_t)heading;
        changed = 1u;
    }
    if (throttle != 0) {
        int32_t travel = (int32_t)(
            ((int32_t)(10 * NAV_ONE) * elapsed_ticks) / ticks_per_second
        );
        uint8_t angle = heading_angle();
        int32_t candidate_precise_x;
        int32_t candidate_precise_y;
        fixed_t candidate_x;
        fixed_t candidate_y;

        if (travel == 0) travel = 1;
        candidate_precise_x = lung.precise_x +
            (((int32_t)angle_sine(angle) * throttle * travel) >> FIXED_SHIFT);
        candidate_precise_y = lung.precise_y +
            (((int32_t)angle_sine((uint8_t)(angle + 64u)) * throttle * travel) >> FIXED_SHIFT);
        candidate_x = precise_to_fixed(candidate_precise_x);
        candidate_y = precise_to_fixed(candidate_precise_y);
        if (point_blocked(candidate_x, candidate_y)) {
            set_message(MESSAGE_HULL_CONTACT, 45u);
            lung.view = VIEW_END;
        } else {
            lung.precise_x = candidate_precise_x;
            lung.precise_y = candidate_precise_y;
            sync_navigation_position();
            lung.has_moved = 1u;
        }
        changed = 1u;
    }
    if (changed) update_scripted_events();
    return changed;
}

static uint8_t sensor_color(fixed_t distance) {
    (void)distance;
    return UI_WHITE;
}

static void draw_radar_proximity(
    int16_t x,
    int16_t y,
    fixed_t distance,
    uint8_t index
) {
    uint8_t units = (uint8_t)(distance >> FIXED_SHIFT);
    uint8_t period;
    uint8_t pulse;

    if (units > SENSOR_MAX_UNITS) units = SENSOR_MAX_UNITS;
    /* Clear ocean is completely silent on the helm: don't even leave an
       outline until a wall enters the close-range proximity envelope. */
    if (units > PROXIMITY_DISPLAY_RANGE) return;
    /* Fewer clock ticks per period as a wall gets closer = faster blink. */
    period = (uint8_t)(2u + units / 7u);
    pulse = (uint8_t)(((uint24_t)clock() >> 8) + index * 5u) % period;
    gfx_SetColor(sensor_color(distance));
    if (units <= SENSOR_STEP / FIXED_ONE && point_blocked(lung.x, lung.y)) {
        /* The hull is touching the wall: hold the marker solid. */
        gfx_FillCircle_NoClip(x, y, 5);
    } else if (pulse == 0u) {
        gfx_Circle_NoClip(x, y, 6);
        gfx_FillCircle_NoClip(x, y, units <= 12u ? 5 : 3);
    }
}

static void draw_fire_and_leaks(void) {
    uint8_t index;

    if (lung.leak_level != 0u) {
        gfx_SetColor(UI_RED);
        for (index = 0u; index < lung.leak_level * 4u; ++index) {
            int16_t x = (int16_t)(21 + index * 43u +
                ((uint16_t)clock() >> (index & 3u)) % 17u);
            int16_t length = (int16_t)(18 + (index * 13u) % 60u);

            gfx_VertLine_NoClip(x, 0, length);
            gfx_SetPixel(x - 1, (uint8_t)(length + 2));
        }
    }
    if (lung.fire_level != 0u) {
        for (index = 0u; index < 11u; ++index) {
            int16_t x = 16 + index * 29;
            int16_t height = 14 +
                (int16_t)(((uint16_t)clock() >> 8) + index * 11u) % 27u;

            gfx_SetColor((index & 1u) != 0u ? UI_ORANGE : UI_RED);
            gfx_FillRectangle_NoClip(x, 217 - height, 15, height);
            gfx_SetColor(UI_WHITE);
            gfx_VertLine_NoClip(x + 7, 211 - height / 2, height / 3);
        }
    }
}

static const char *message_text(uint8_t message) {
    switch (message) {
        case MESSAGE_HULL_CONTACT: return "HULL CONTACT";
        case MESSAGE_SENSOR_CONTACT: return "UNIDENTIFIED PROXIMITY RETURN";
        case MESSAGE_FISH_IMPACT: return "IMPACT / NAVIGATION DISPLACED";
        case MESSAGE_FIRE: return "FIRE AFT / FIND EXTINGUISHER";
        case MESSAGE_SECOND_IMPACT: return "MASSIVE IMPACT / PRESSURE LOSS";
        case MESSAGE_EYE: return "IT SAW THE CAMERA";
        case MESSAGE_PHOTO_VALID: return "SURVEY IMAGE ACCEPTED";
        case MESSAGE_PHOTO_INVALID: return "NO MARKED SUBJECT";
        case MESSAGE_FIRE_OUT: return "FIRE SUPPRESSED";
        case MESSAGE_BONE_FISH: return "MOVEMENT: EXPOSED BONE STRUCTURE";
        case MESSAGE_BONE_EEL: return "LONG SKELETAL RETURN CIRCLING";
        case MESSAGE_BONE_MAW: return "LARGE DENTAL MASS APPROACHING";
        case MESSAGE_BONE_PHOTO: return "MOVING SKELETON PHOTOGRAPHED";
        default: return "";
    }
}

static void draw_meter(
    int16_t x,
    int16_t y,
    const char *label,
    uint8_t value,
    uint8_t color
) {
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(x, y, 27, 116);
    gfx_SetColor(UI_RUST_LIGHT);
    gfx_Rectangle_NoClip(x, y, 27, 116);
    gfx_SetColor(color);
    gfx_FillRectangle_NoClip(x + 6, y + 18 + (80 - value * 80 / 100u),
        15, value * 80 / 100u);
    set_text(UI_WHITE, x + 3, y + 4);
    gfx_PrintString(label);
    set_text(UI_GREEN, x + 4, y + 101);
    gfx_PrintUInt(value, 2u);
}

/* This is the normal submarine view.  It intentionally draws no 3D frame:
   one-shot 3D is reserved for the camera and the trace-key debug view. */
static void draw_cabin(void) {
    uint8_t angle = heading_angle();
    int16_t pointer_x = (int16_t)(160 +
        (angle_sine(angle) * 42 >> FIXED_SHIFT));
    int16_t pointer_y = (int16_t)(112 -
        (angle_sine((uint8_t)(angle + 64u)) * 42 >> FIXED_SHIFT));
    uint8_t depth = (uint8_t)(20u +
        ((uint32_t)(lung.precise_y >> NAV_SHIFT) * 70u / MAP_LIMIT));
    uint8_t index;
    uint8_t heading_slot;
    int16_t radar_x[16];
    int16_t radar_y[16];

    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_RUST);
    gfx_FillRectangle_NoClip(8, 8, 304, 224);
    gfx_SetColor(UI_RUST_LIGHT);
    gfx_Rectangle_NoClip(8, 8, 304, 224);
    gfx_SetColor(UI_BROWN_DARK);
    gfx_FillRectangle_NoClip(42, 21, 236, 181);
    gfx_SetColor(UI_BLACK);
    gfx_FillCircle_NoClip(160, 112, 54);
    gfx_SetColor(UI_RUST_LIGHT);
    for (index = 0u; index < 16u; ++index) {
        uint8_t radar_angle = (uint8_t)(index * 16u);
        radar_x[index] = (int16_t)(160 +
            (angle_sine(radar_angle) * 45 >> FIXED_SHIFT));
        radar_y[index] = (int16_t)(112 -
            (angle_sine((uint8_t)(radar_angle + 64u)) * 45 >> FIXED_SHIFT));
    }
    for (index = 0u; index < 16u; ++index) {
        uint8_t next = (uint8_t)((index + 1u) & 15u);
        gfx_Line_NoClip(radar_x[index], radar_y[index], radar_x[next], radar_y[next]);
    }
    gfx_SetColor(UI_GREEN);
    gfx_Line_NoClip(160, 112, pointer_x, pointer_y);
    gfx_FillCircle_NoClip(160, 112, 4);
    set_text(UI_GREEN, 135, 27);
    gfx_PrintString("HEADING");
    set_text(UI_WHITE, 140, 43);
    print_heading();

    draw_meter(15, 39, "O2", (uint8_t)(lung.oxygen * 25u), UI_GREEN);
    draw_meter(278, 39, "DEP", depth, depth > 75u ? UI_RED : UI_GREEN);
    /* Compact, instrument-style coordinate readout. */
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(82, 163, 156, 38);
    gfx_SetColor(UI_RUST_LIGHT);
    gfx_Rectangle_NoClip(82, 163, 156, 38);
    gfx_HorizLine_NoClip(87, 182, 146);
    gfx_SetColor(UI_BROWN_DARK);
    gfx_FillRectangle_NoClip(87, 167, 19, 11);
    gfx_FillRectangle_NoClip(87, 186, 19, 11);
    set_text(UI_WHITE, 93, 168);
    gfx_PrintString("X");
    set_text(UI_GREEN, 112, 168);
    print_precise_hundredths(lung.precise_x);
    set_text(UI_WHITE, 93, 187);
    gfx_PrintString("Y");
    set_text(UI_GREEN, 112, 187);
    print_precise_hundredths(lung.precise_y);
    /* The ring stays bolted to the helm, while front/right/rear/left move to
       the four slots matching the submarine's quantized 45-degree heading. */
    heading_slot = (uint8_t)((((uint8_t)(angle + 16u) >> 5) * 2u) & 15u);
    for (index = 0u; index < 4u; ++index) {
        uint8_t sensor_index = (uint8_t)(index * 4u);
        uint8_t radar_index = (uint8_t)((heading_slot + sensor_index) & 15u);
        draw_radar_proximity(radar_x[radar_index], radar_y[radar_index],
            lung.sensor[sensor_index], radar_index);
    }

    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(10, 205, 300, 21);
    set_text(lung.message_ticks != 0u ? UI_RED : UI_WHITE, 15, 212);
    if (lung.message_ticks != 0u) {
        gfx_PrintString(message_text(lung.message));
    } else {
        gfx_PrintString("ARROWS PILOT  2ND PHOTO  GRAPH MAP  TRACE 3D");
    }
    draw_fire_and_leaks();
    gfx_SwapDraw();
}

static int16_t map_x(uint16_t coordinate) {
    return (int16_t)(20 + ((uint24_t)coordinate * 280u) / MAP_LIMIT);
}

static int16_t map_y(uint16_t coordinate) {
    return (int16_t)(210 - ((uint24_t)coordinate * 180u) / MAP_LIMIT);
}

static uint8_t map_target_index(void) {
    uint8_t index;
    uint8_t result = 0u;
    uint32_t best = UINT32_MAX;

    for (index = 0u; index < 10u; ++index) {
        int32_t dx = (int32_t)lung.map_cursor_x -
            (photo_points[index].x >> FIXED_SHIFT);
        int32_t dy = (int32_t)lung.map_cursor_y -
            (photo_points[index].y >> FIXED_SHIFT);
        uint32_t distance = (uint32_t)(dx * dx + dy * dy);

        if (distance < best) {
            best = distance;
            result = index;
        }
    }
    return result;
}

static void draw_map(void) {
    uint8_t x;
    uint8_t y;
    uint8_t index;
    uint8_t target = map_target_index();
    uint8_t target_angle = (uint8_t)(
        ((uint32_t)photo_points[target].heading_cdeg * 256u) / 36000u
    );

    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_PAPER_DARK);
    gfx_FillRectangle_NoClip(13, 18, 294, 201);
    /* The uncarved area is a black wall; only safe cave water is charted. */
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(20, 24, 280, 192);

    for (y = 0u; y < CAVE_SIZE; ++y) {
        for (x = 0u; x < CAVE_SIZE; ++x) {
            if (cave_cell_open(x, y)) {
                gfx_SetColor(((x + y) & 3u) == 0u ? UI_PAPER_DARK : UI_PAPER);
                gfx_FillRectangle_NoClip(
                    20 + (int16_t)((uint16_t)x * 280u / CAVE_SIZE),
                    24 + (int16_t)((uint16_t)(CAVE_SIZE - 1u - y) *
                        192u / CAVE_SIZE),
                    5,
                    4
                );
            }
        }
    }
    gfx_SetColor(UI_BROWN_DARK);
    for (index = 1u; index < 10u; ++index) {
        int16_t gx = 20 + index * 28;
        int16_t gy = 24 + index * 19;

        gfx_VertLine_NoClip(gx, 24, 192);
        gfx_HorizLine_NoClip(20, gy, 280);
    }
    for (index = 0u; index < 10u; ++index) {
        int16_t px = map_x((uint16_t)(photo_points[index].x >> FIXED_SHIFT));
        int16_t py = map_y((uint16_t)(photo_points[index].y >> FIXED_SHIFT));
        uint8_t done = (uint8_t)(
            (lung.documented_mask & (1u << index)) != 0u
        );

        gfx_SetColor(done ? UI_GREEN : UI_BLACK);
        gfx_Rectangle_NoClip(px - 4, py - 4, 9, 9);
        if (done) {
            gfx_Line_NoClip(px - 3, py, px - 1, py + 3);
            gfx_Line_NoClip(px - 1, py + 3, px + 4, py - 4);
        } else {
            gfx_HorizLine_NoClip(px - 2, py, 5);
            gfx_VertLine_NoClip(px, py - 2, 5);
        }
    }
    {
        int16_t submarine_x = map_x((uint16_t)(lung.precise_x >> NAV_SHIFT));
        int16_t submarine_y = map_y((uint16_t)(lung.precise_y >> NAV_SHIFT));
        int16_t cursor_x = map_x(lung.map_cursor_x);
        int16_t cursor_y = map_y(lung.map_cursor_y);

        gfx_SetColor(UI_RED);
        gfx_FillCircle_NoClip(submarine_x, submarine_y, 3);
        gfx_SetColor(UI_GREEN);
        gfx_HorizLine_NoClip(cursor_x - 6, cursor_y, 13);
        gfx_VertLine_NoClip(cursor_x, cursor_y - 6, 13);
        gfx_Rectangle_NoClip(cursor_x - 3, cursor_y - 3, 7, 7);
    }

    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(0, 0, 320, 23);
    gfx_FillRectangle_NoClip(0, 220, 320, 20);
    set_text(UI_WHITE, 1, 5);
    gfx_PrintString("AT-5 MAP  ARROWS CURSOR  2ND WAYPOINT  GRAPH OUT");
    set_text(UI_GREEN, 6, 14);
    gfx_PrintString("OBJ ");
    gfx_PrintUInt(target + 1u, 2u);
    gfx_PrintString(" X");
    gfx_PrintUInt((uint16_t)(photo_points[target].x >> FIXED_SHIFT), 1u);
    gfx_PrintString(" Y");
    gfx_PrintUInt((uint16_t)(photo_points[target].y >> FIXED_SHIFT), 1u);
    gfx_PrintString(" A");
    print_heading_value(photo_points[target].heading_cdeg);
    set_text(UI_GREEN, 7, 226);
    gfx_PrintString("SUB ");
    gfx_PrintUInt((uint16_t)(lung.precise_x >> NAV_SHIFT), 1u);
    gfx_PrintString(",");
    gfx_PrintUInt((uint16_t)(lung.precise_y >> NAV_SHIFT), 1u);
    set_text(UI_WHITE, 112, 226);
    gfx_PrintString("CUR ");
    gfx_PrintUInt(lung.map_cursor_x, 1u);
    gfx_PrintString(",");
    gfx_PrintUInt(lung.map_cursor_y, 1u);
    set_text(UI_GREEN, 232, 226);
    gfx_PrintString("A ");
    print_heading();
    gfx_SetColor(UI_GREEN);
    gfx_Line_NoClip(299, 37, (int16_t)(299 +
        (angle_sine(target_angle) * 10 >> FIXED_SHIFT)),
        (int16_t)(37 - (angle_sine((uint8_t)(target_angle + 64u)) * 10 >> FIXED_SHIFT)));
    gfx_SwapDraw();
}

static uint8_t update_map_cursor(void) {
    int16_t x = lung.map_cursor_x;
    int16_t y = lung.map_cursor_y;

    if ((kb_Data[7] & kb_Left) != 0u) x -= 5;
    if ((kb_Data[7] & kb_Right) != 0u) x += 5;
    if ((kb_Data[7] & kb_Down) != 0u) y -= 5;
    if ((kb_Data[7] & kb_Up) != 0u) y += 5;
    if (x < 0) x = 0;
    if (x > (int16_t)MAP_LIMIT) x = MAP_LIMIT;
    if (y < 0) y = 0;
    if (y > (int16_t)MAP_LIMIT) y = MAP_LIMIT;
    if ((uint16_t)x == lung.map_cursor_x &&
        (uint16_t)y == lung.map_cursor_y) {
        return 0u;
    }
    lung.map_cursor_x = (uint16_t)x;
    lung.map_cursor_y = (uint16_t)y;
    return 1u;
}

static void draw_briefing(void) {
    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_RUST);
    gfx_Rectangle_NoClip(10, 10, 300, 220);
    set_text(UI_RED, 24, 23);
    gfx_PrintString("CONSOLIDATION OF IRON / SM-13");
    set_text(UI_WHITE, 24, 48);
    gfx_PrintString("MOON AT-5: BLOOD OCEAN SURVEY");
    set_text(UI_RUST_LIGHT, 24, 72);
    gfx_PrintString("THE FORWARD PORTHOLE IS SEALED.");
    set_text(UI_RUST_LIGHT, 24, 86);
    gfx_PrintString("NAVIGATE BY X/Y, HEADING, MAP,");
    set_text(UI_RUST_LIGHT, 24, 100);
    gfx_PrintString("AND FOUR PROXIMITY TRANSDUCERS.");
    set_text(UI_WHITE, 24, 126);
    gfx_PrintString("PHOTOGRAPH THE TEN MARKED SITES.");
    set_text(UI_GREEN, 24, 150);
    gfx_PrintString("PHOTO TOLERANCE: +/-18 COORDS");
    set_text(UI_GREEN, 24, 164);
    gfx_PrintString("HEADING TOLERANCE: +/-10 DEGREES");
    set_text(UI_RED, 24, 193);
    gfx_PrintString("THE HATCH HAS BEEN WELDED SHUT.");
    set_text(UI_WHITE, 80, 215);
    gfx_PrintString("MODE/2ND: RETURN TO CABIN");
    gfx_SwapDraw();
}

static uint8_t valid_photo_point(void) {
    uint8_t index;

    for (index = 0u; index < 10u; ++index) {
        if (fixed_absolute(lung.x - photo_points[index].x) <=
                PHOTO_POSITION_TOLERANCE &&
            fixed_absolute(lung.y - photo_points[index].y) <=
                PHOTO_POSITION_TOLERANCE &&
            heading_difference(lung.heading_cdeg,
                photo_points[index].heading_cdeg) <=
                PHOTO_HEADING_TOLERANCE) {
            return index;
        }
    }
    return 0xFFu;
}

static uint8_t visible_creature(void) {
    uint8_t index;
    uint8_t result = 0xFFu;
    fixed_t nearest = SENSOR_RANGE * 2;
    uint8_t angle = heading_angle();
    fixed_t forward_x = angle_sine(angle);
    fixed_t forward_y = angle_sine((uint8_t)(angle + 64u));
    fixed_t right_x = forward_y;
    fixed_t right_y = -forward_x;

    for (index = 0u; index < 3u; ++index) {
        const SkeletalCreature *creature = &creatures[index];
        fixed_t dx;
        fixed_t dy;
        fixed_t forward;
        fixed_t side;

        if (!creature->active) continue;
        dx = creature->x - lung.x;
        dy = creature->y - lung.y;
        forward = fixed_mul(forward_x, dx) + fixed_mul(forward_y, dy);
        side = fixed_mul(right_x, dx) + fixed_mul(right_y, dy);
        if (forward <= 4 * FIXED_ONE || forward >= nearest ||
            fixed_absolute(side) > forward) continue;
        nearest = forward;
        result = index;
    }
    return result;
}

/* The external image is deliberately a bounded photographic projection, not
   another live 3D room.  Its vanishing point and cave throat come from the
   four proximity rays, while the rock grain is seeded by coordinates and
   heading.  This preserves the game's separate "camera reality" and avoids
   making the tiny calculator render an unbounded exterior scene. */
static void draw_photo_environment(uint8_t scene) {
    uint16_t seed = (uint16_t)(
        (lung.x >> 3) ^ (lung.y >> 2) ^ lung.heading_cdeg ^
        ((uint16_t)scene << 11)
    );
    uint16_t index;

    gfx_FillScreen(PHOTO_BLACK);
    /* Dense, low-contrast ocean noise leaves the feed nearly black, like an
       overloaded monochrome camera rather than a corridor or room. */
    for (index = 0u; index < 2400u; ++index) {
        seed = (uint16_t)(seed * 25173u + 13849u);
        gfx_SetColor((seed & 7u) == 0u ? PHOTO_MID : PHOTO_DARK);
        {
            int16_t x = (int16_t)(25 + seed % 270u);
            int16_t y;
            seed = (uint16_t)(seed * 25173u + 13849u);
            y = (int16_t)(25 + (seed >> 8) % 178u);
            gfx_SetPixel(x, y);
        }
    }
    for (index = 0u; index < 14u; ++index) {
        seed = (uint16_t)(seed * 25173u + 13849u);
        gfx_SetColor(PHOTO_DARK);
        gfx_HorizLine_NoClip(25, (uint8_t)(30 + seed % 166u), 270);
    }
}

static void draw_photo_scene(uint8_t scene) {
    uint8_t index;

    gfx_SetColor(PHOTO_LIGHT);
    switch (scene % 5u) {
        case 0u:
            /* Curled vertebrae and ribs. */
            for (index = 0u; index < 12u; ++index) {
                int16_t x = 68 + index * 15;
                int16_t y = 110 + (index < 6u ? index * 6 : (11u - index) * 6);
                gfx_FillCircle_NoClip(x, y, 8);
                gfx_SetColor(PHOTO_BLACK);
                gfx_FillCircle_NoClip(x, y, 3);
                gfx_SetColor(PHOTO_LIGHT);
                gfx_Line_NoClip(x, y, x - 18, y + 24);
                gfx_Line_NoClip(x + 3, y + 2, x + 25, y + 21);
            }
            break;
        case 1u:
            /* A broad rib cage around a dark central cavity. */
            gfx_FillCircle_NoClip(160, 119, 37);
            gfx_SetColor(PHOTO_BLACK);
            gfx_FillCircle_NoClip(160, 119, 24);
            gfx_SetColor(PHOTO_LIGHT);
            for (index = 0u; index < 8u; ++index) {
                int16_t y = 67 + index * 15;
                gfx_Line_NoClip(151, 112, 64 + index * 8, y);
                gfx_Line_NoClip(169, 112, 256 - index * 8, y);
                gfx_Line_NoClip(64 + index * 8, y, 84 + index * 8, y + 8);
                gfx_Line_NoClip(256 - index * 8, y, 236 - index * 8, y + 8);
            }
            break;
        case 2u:
            /* Branching claws reaching out of the darkness. */
            for (index = 0u; index < 6u; ++index) {
                int16_t x = 48 + index * 43;
                int16_t y = 166 - (index & 1u) * 22;
                gfx_Line_NoClip(160, 105, x, y);
                gfx_Line_NoClip(x, y, x - 15, y - 34);
                gfx_Line_NoClip(x, y, x + 17, y - 29);
                gfx_FillCircle_NoClip(x, y, 5);
            }
            break;
        case 3u:
            /* Distant, leaning monoliths with broken antennae. */
            for (index = 0u; index < 5u; ++index) {
                int16_t x = 62 + index * 48;
                int16_t top = 55 + ((index * 23u) % 54u);
                gfx_Line_NoClip(x, 177, x + 20, top);
                gfx_Line_NoClip(x + 8, 177, x + 31, top + 10);
                gfx_Line_NoClip(x + 20, top, x + 38, top - 18);
            }
            break;
        default: /* Tangled skeletal arches. */
            for (index = 0u; index < 9u; ++index) {
                int16_t x = 52 + index * 28;
                gfx_Line_NoClip(x, 174, x + 23, 64 + (index & 1u) * 25);
                gfx_Line_NoClip(x + 6, 174, x + 31, 75 + (index & 1u) * 24);
                gfx_Line_NoClip(x + 14, 150, x + 38, 136);
            }
            break;
    }
}

static void draw_skeletal_creature_photo(
    uint8_t kind, uint8_t animation_phase
) {
    uint8_t index;
    int16_t sway = (int16_t)((animation_phase >> 4) & 3u) - 1;

    gfx_SetColor(PHOTO_WHITE);
    if (kind == 0u) {
        /* A complete predatory fish: hollow skull, separated jaws, teeth,
           linked vertebrae, paired ribs, and a shredded bony tail fan. */
        gfx_Circle_NoClip(230, 102 + sway, 26);
        gfx_Line_NoClip(208, 90 + sway, 246, 75 + sway);
        gfx_Line_NoClip(246, 75 + sway, 269, 101 + sway);
        gfx_Line_NoClip(269, 101 + sway, 207, 111 + sway);
        gfx_Line_NoClip(207, 113 + sway, 266, 126 + sway);
        gfx_Line_NoClip(266, 126 + sway, 213, 135 + sway);
        gfx_SetColor(PHOTO_BLACK);
        gfx_FillCircle_NoClip(239, 94 + sway, 8);
        gfx_SetColor(PHOTO_WHITE);
        for (index = 0u; index < 9u; ++index) {
            int16_t x = 216 + index * 6;
            gfx_Line_NoClip(x, 112 + sway, x + 2, 122 + sway);
            gfx_Line_NoClip(x + 2, 129 + sway, x + 4, 119 + sway);
        }
        for (index = 0u; index < 11u; ++index) {
            int16_t x = 194 - index * 12;
            int16_t y = 109 + ((index + animation_phase / 16u) & 1u) * 3;
            gfx_Circle_NoClip(x, y, 4);
            gfx_Line_NoClip(x, y + 2, x - 5, y + 30);
            gfx_Line_NoClip(x, y - 2, x - 3, y - 25);
        }
        gfx_Line_NoClip(65, 110, 34, 70);
        gfx_Line_NoClip(65, 110, 30, 110);
        gfx_Line_NoClip(65, 110, 35, 151);
        gfx_Line_NoClip(35, 70, 30, 110);
        gfx_Line_NoClip(30, 110, 35, 151);
    } else if (kind == 1u) {
        /* An eel skeleton bends across the frame. The repeated vertebrae and
           long dorsal/ventral spines keep it readable through heavy grain. */
        static const int8_t curve[16] = {
            0, -9, -15, -18, -15, -8, 2, 12,
            18, 16, 10, 0, -10, -16, -13, -4
        };
        for (index = 0u; index < 16u; ++index) {
            int16_t x = 43 + index * 14;
            int16_t y = 114 + curve[index] + sway;
            gfx_Circle_NoClip(x, y, 4);
            if (index != 15u) {
                gfx_Line_NoClip(x + 3, y, x + 11,
                    114 + curve[index + 1u] + sway);
            }
            gfx_Line_NoClip(x, y - 2, x - 5, y - 22 - (index & 3u) * 3);
            gfx_Line_NoClip(x, y + 2, x + 4, y + 21 + (index & 3u) * 3);
        }
        gfx_Line_NoClip(250, 96 + sway, 286, 78 + sway);
        gfx_Line_NoClip(286, 78 + sway, 296, 111 + sway);
        gfx_Line_NoClip(296, 111 + sway, 252, 123 + sway);
        gfx_Line_NoClip(252, 123 + sway, 291, 138 + sway);
        gfx_SetColor(PHOTO_BLACK);
        gfx_FillCircle_NoClip(277, 100 + sway, 7);
        gfx_SetColor(PHOTO_WHITE);
        for (index = 0u; index < 6u; ++index) {
            gfx_Line_NoClip(259 + index * 5, 117 + sway,
                261 + index * 5, 128 + sway);
        }
    } else {
        /* The late-game organism is mostly skull and teeth, emerging from a
           dark body large enough that the camera cannot find its edges. */
        gfx_Circle_NoClip(160, 101 + sway, 61);
        gfx_Circle_NoClip(160, 106 + sway, 56);
        gfx_SetColor(PHOTO_BLACK);
        gfx_FillCircle_NoClip(137, 91 + sway, 15);
        gfx_FillCircle_NoClip(184, 91 + sway, 15);
        gfx_FillCircle_NoClip(160, 113 + sway, 9);
        gfx_FillRectangle_NoClip(99, 127 + sway, 123, 32);
        gfx_SetColor(PHOTO_WHITE);
        gfx_Line_NoClip(96, 126 + sway, 224, 126 + sway);
        gfx_Line_NoClip(99, 177 + sway, 221, 177 + sway);
        for (index = 0u; index < 13u; ++index) {
            int16_t x = 102 + index * 10;
            gfx_Line_NoClip(x, 126 + sway, x + 4, 158 + sway);
            gfx_Line_NoClip(x + 4, 177 + sway, x + 8, 146 + sway);
        }
        gfx_Line_NoClip(99, 177 + sway, 82, 150 + sway);
        gfx_Line_NoClip(221, 177 + sway, 238, 150 + sway);
    }
}

static void draw_photo_noise(void) {
    uint16_t seed = (uint16_t)(lung.photo_count * 877u + 0x319Du);
    uint16_t index;

    for (index = 0u; index < 720u; ++index) {
        seed = (uint16_t)(seed * 25173u + 13849u);
        gfx_SetColor((seed & 1u) != 0u ? PHOTO_LIGHT : PHOTO_DARK);
        gfx_SetPixel(27 + seed % 266u,
            (uint8_t)(29 + (seed >> 8) % 167u));
    }
    gfx_SetColor(PHOTO_DARK);
    for (index = 31u; index < 196u; index += 4u) {
        gfx_HorizLine_NoClip(27, index, 266);
    }
}

static void draw_photo_flash(uint8_t color, uint8_t grain) {
    uint16_t seed = (uint16_t)(0x331Du + grain * 911u);
    uint8_t index;

    gfx_FillScreen(color);
    if (grain != 0u) {
        for (index = 0u; index < grain * 35u; ++index) {
            seed = (uint16_t)(seed * 25173u + 13849u);
            gfx_SetColor((seed & 1u) != 0u ? PHOTO_LIGHT : PHOTO_DARK);
            gfx_SetPixel(seed % GFX_LCD_WIDTH, (uint8_t)(seed >> 8));
        }
    }
    gfx_SwapDraw();
    gfx_Wait();
}

static void set_photo_palette(void) {
    uint8_t index;

    /* T3D3's low-poly camera mesh has no material colors in a photograph. */
    for (index = 0u; index < 68u; ++index) {
        uint8_t intensity = (uint8_t)(18u + (index & 3u) * 55u);
        gfx_palette[index] = gfx_RGBTo1555(intensity, intensity, intensity);
    }
    gfx_palette[UI_BLACK] = gfx_RGBTo1555(0, 0, 0);
}

static void capture_photo(void) {
    uint8_t target = valid_photo_point();
    uint8_t scene = target == 0xFFu ? 0xFFu : photo_points[target].scene;
    uint8_t creature = visible_creature();

    /* Flash -> pale grain -> darkness -> developed still. The 3D scene is
       still rendered only once, after the flash has hidden the work. */
    draw_photo_flash(UI_WHITE, 0u);
    draw_photo_flash(PHOTO_LIGHT, 1u);
    draw_photo_flash(PHOTO_DARK, 3u);
    ++lung.photo_count;
    if (target < 9u) {
        lung.documented_mask |= (uint16_t)(1u << target);
        set_message(MESSAGE_PHOTO_VALID, 75u);
    } else if ((lung.event_flags & EVENT_EYE_ACTIVE) != 0u &&
               (lung.event_flags & EVENT_EYE_SEEN) == 0u) {
        scene = 10u;
        lung.event_flags |= EVENT_EYE_SEEN;
        lung.leak_level = 3u;
        lung.pressure = 1u;
        set_message(MESSAGE_EYE, 120u);
    } else {
        set_message(MESSAGE_PHOTO_INVALID, 60u);
    }
    if (scene != 10u && creature != 0xFFu) {
        set_message(MESSAGE_BONE_PHOTO, 90u);
    }
    lung.last_scene = scene;

    ti_lung_engine_invalidate();
    gfx_FillScreen(PHOTO_BLACK);
    set_photo_palette();
    /* The camera is a low-light survey instrument, not the debug renderer.
       Its developed still contains ocean grain and a detected subject only:
       never room faces, chunk boxes, a floor, or a ceiling. */
    draw_photo_environment(scene);
    if (target != 0xFFu) draw_photo_scene(scene);
    if (scene != 10u && creature != 0xFFu) {
        draw_skeletal_creature_photo(
            creatures[creature].kind, creatures[creature].phase
        );
    }
    draw_photo_noise();

    gfx_SetColor(UI_RUST);
    gfx_FillRectangle_NoClip(0, 0, 320, 24);
    gfx_FillRectangle_NoClip(0, 204, 320, 36);
    gfx_FillRectangle_NoClip(0, 24, 24, 180);
    gfx_FillRectangle_NoClip(296, 24, 24, 180);
    gfx_SetColor(UI_RUST_LIGHT);
    gfx_Rectangle_NoClip(24, 24, 272, 180);
    set_text(UI_WHITE, 7, 7);
    gfx_PrintString("PHOTO ");
    gfx_PrintUInt(lung.photo_count, lung.photo_count >= 10u ? 2u : 1u);
    set_text(UI_GREEN, 88, 7);
    gfx_PrintString("X");
    print_precise_hundredths(lung.precise_x);
    gfx_PrintString(" Y");
    print_precise_hundredths(lung.precise_y);
    gfx_PrintString(" A");
    print_heading();
    set_text(target < 9u ? UI_GREEN : UI_WHITE, 7, 215);
    if (scene == 10u) {
        gfx_PrintString("UNIDENTIFIED ORGANISM");
    } else if (creature != 0xFFu) {
        gfx_PrintString("MOVING SKELETAL RETURN");
    } else {
        gfx_PrintString(target < 9u ?
            "MARKED SITE RECORDED" : "NO MARKED SUBJECT");
    }
    set_text(UI_WHITE, 232, 227);
    gfx_PrintString("2ND RETURN");
    gfx_SwapDraw();
    lung.view = VIEW_PHOTO;
    lung.photo_ticks = 0u;
}

static void draw_attack(void) {
    int16_t jitter = (int16_t)((lung.attack_ticks & 3u) - 1u) * 3;

    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_RED_DARK);
    gfx_FillCircle_NoClip(160 + jitter, 118, 110);
    gfx_SetColor(UI_RED);
    gfx_FillCircle_NoClip(160 - jitter, 118, 73);
    gfx_SetColor(UI_WHITE);
    gfx_FillCircle_NoClip(160 + jitter, 105, 45);
    gfx_SetColor(UI_BLACK);
    gfx_FillCircle_NoClip(160 + jitter, 105, 24);
    gfx_SetColor(UI_WHITE);
    gfx_FillRectangle_NoClip(90, 174, 14, 48);
    gfx_FillRectangle_NoClip(123, 167, 14, 58);
    gfx_FillRectangle_NoClip(157, 165, 14, 61);
    gfx_FillRectangle_NoClip(191, 167, 14, 58);
    gfx_FillRectangle_NoClip(224, 174, 14, 48);
    set_text(UI_RED, 99, 8);
    gfx_PrintString("AFT HULL BREACH");
    gfx_SwapDraw();
}

static void draw_end(void) {
    gfx_FillScreen(UI_BLACK);
    gfx_SetTextScale(2, 2);
    set_text(UI_RED, 88, 68);
    gfx_PrintString("TI LUNG");
    gfx_SetTextScale(1, 1);
    set_text(UI_WHITE, 52, 114);
    gfx_PrintString("HULL CONTACT: TELEMETRY LOST");
    set_text(UI_RUST_LIGHT, 40, 139);
    gfx_PrintString("NO RECOVERY METHOD IS AVAILABLE.");
    set_text(UI_GREEN, 75, 178);
    gfx_PrintString("SURVEY RECORD: ");
    gfx_PrintUInt(documented_count(), 1u);
    gfx_PrintString(" / 10");
    set_text(UI_WHITE, 110, 216);
    gfx_PrintString("CLEAR TO EXIT");
    gfx_SwapDraw();
}

static void draw_current_view(void) {
    switch (lung.view) {
        case VIEW_MAP: draw_map(); break;
        case VIEW_BRIEFING: draw_briefing(); break;
        case VIEW_PHOTO: break;
        case VIEW_ATTACK: draw_attack(); break;
        case VIEW_END: draw_end(); break;
        case VIEW_DEBUG: draw_debug_view(); break;
        default: draw_cabin(); break;
    }
}

static uint8_t read_edge_keys(void) {
    return (uint8_t)(
        ((kb_Data[1] & kb_2nd) != 0u ? EDGE_USE : 0u) |
        ((kb_Data[1] & kb_Graph) != 0u ? EDGE_MAP : 0u) |
        ((kb_Data[1] & kb_Mode) != 0u ? EDGE_BRIEFING : 0u) |
        ((kb_Data[1] & kb_Trace) != 0u ? EDGE_DEBUG : 0u)
    );
}

static void begin_final_attack(void) {
    lung.event_flags |= EVENT_FINAL;
    lung.view = VIEW_ATTACK;
    lung.attack_ticks = 60u;
    lung.helm_active = 0u;
    draw_attack();
}

static void use_station(void) {
    if (valid_photo_point() == 9u && documented_count() >= 9u) {
        begin_final_attack();
    } else {
        capture_photo();
    }
}

static uint8_t load_saved_game(LungState *destination) {
    LungSave save;
    uint8_t handle = ti_Open(SAVE_NAME, "r");

    if (handle == 0u) return 0u;
    if (ti_Read(&save, sizeof(save), 1u, handle) != 1u) {
        ti_Close(handle);
        return 0u;
    }
    ti_Close(handle);
    if (save.magic != SAVE_MAGIC || save.version != SAVE_VERSION) return 0u;
    *destination = save.state;
    destination->view = VIEW_CABIN;
    destination->previous_edge_keys = 0u;
    destination->photo_ticks = 0u;
    destination->autosave_ticks = 0u;
    destination->x = precise_to_fixed(destination->precise_x);
    destination->y = precise_to_fixed(destination->precise_y);
    return 1u;
}

static uint8_t save_current_game(void) {
    LungSave save;
    uint8_t handle;

    save.magic = SAVE_MAGIC;
    save.version = SAVE_VERSION;
    save.state = lung;
    save.state.view = VIEW_CABIN;
    save.state.previous_edge_keys = 0u;
    handle = ti_Open(SAVE_NAME, "w");
    if (handle == 0u) return 0u;
    if (ti_Resize(sizeof(save), handle) != (int)sizeof(save)) {
        ti_Close(handle);
        return 0u;
    }
    if (ti_Write(&save, sizeof(save), 1u, handle) != 1u) {
        ti_Close(handle);
        return 0u;
    }
    ti_Close(handle);
    return 1u;
}

static uint8_t saved_game_available(void) {
    LungState saved;
    return load_saved_game(&saved);
}

static uint8_t wait_for_deploy(void) {
    uint8_t previous = 0u;
    uint8_t saved = saved_game_available();

    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_RUST);
    gfx_Rectangle_NoClip(34, 24, 252, 188);
    gfx_SetTextScale(2, 2);
    set_text(UI_RED, 88, 45);
    gfx_PrintString("TI LUNG");
    gfx_SetTextScale(1, 1);
    set_text(UI_WHITE, 78, 88);
    gfx_PrintString("SM-13 BLOOD OCEAN SURVEY");
    set_text(UI_RUST_LIGHT, 54, 115);
    gfx_PrintString("ONE SUB. TEN PHOTOGRAPHS.");
    set_text(UI_RED, 72, 145);
    gfx_PrintString("THE HATCH WILL BE WELDED.");
    set_text(UI_GREEN, 78, 181);
    gfx_PrintString(saved ? "2ND: NEW   GRAPH: CONTINUE" : "2ND: NEW GAME   CLEAR: ABORT");
    gfx_SwapDraw();

    for (;;) {
        uint8_t current;

        kb_Scan();
        current = (uint8_t)(
            ((kb_Data[1] & kb_2nd) != 0u ? 1u : 0u) |
            ((kb_Data[1] & kb_Graph) != 0u ? 2u : 0u) |
            ((kb_Data[6] & kb_Clear) != 0u ? 4u : 0u)
        );
        if ((current & 1u) != 0u && (previous & 1u) == 0u) return 1u;
        if (saved && (current & 2u) != 0u && (previous & 2u) == 0u) return 2u;
        if ((current & 4u) != 0u) return 0u;
        previous = current;
    }
}

static void setup_exterior_camera(void) {
    cabin_camera.position.x = exterior_world_from_map(
        (uint16_t)(lung.precise_x >> NAV_SHIFT)
    );
    cabin_camera.position.y = exterior_world_from_map(
        (uint16_t)(lung.precise_y >> NAV_SHIFT)
    );
    cabin_camera.position.z = 330;
    cabin_camera.velocity = (Vec3){0, 0, 0};
    cabin_camera.room = EXTERIOR_ROOM;
    cabin_camera.yaw = heading_angle();
    cabin_camera.pitch = 0;
    cabin_camera.dev_mode = 1u;
    cabin_camera.noclip = 1u;
    rebuild_basis(&cabin_camera);
}

/* Build only the cave cells around the camera, like small Minecraft chunks.
   Their absolute map positions mean moving the sub produces a different 3D
   location instead of rebuilding the same local tunnel in front of it. */
static uint8_t spawn_interest_model(uint8_t scene) {
    typedef struct {
        int16_t side;
        int16_t forward;
        int16_t z;
        uint8_t half_x;
        uint8_t half_y;
        uint8_t half_z;
    } SitePiece;
    /* A marked site must fit inside one photograph.  This is a real 16-part
       low-poly silhouette (tower, legs, cross-braces, antenna and annex), not
       the former six generic blocks. */
    static const SitePiece pieces[] = {
        {0, 0, 445, 52, 52, 150},
        {-118, -92, 260, 20, 20, 175}, {118, -92, 260, 20, 20, 175},
        {-118, 92, 260, 20, 20, 175}, {118, 92, 260, 20, 20, 175},
        {-72, -65, 355, 82, 16, 16}, {72, 65, 440, 82, 16, 16},
        {-72, 65, 525, 82, 16, 16}, {72, -65, 610, 82, 16, 16},
        {0, 0, 680, 25, 25, 100},
        {0, 0, 820, 12, 12, 55},
        {-200, 40, 300, 72, 58, 72}, {200, -40, 300, 72, 58, 72},
        {-210, 40, 405, 45, 38, 36}, {210, -40, 405, 45, 38, 36},
        {0, -175, 260, 145, 35, 38}
    };
    const fixed_t distance = (fixed_t)(PHOTO_RENDER_DISTANCE * 2u / 3u);
    const fixed_t scale = (fixed_t)(FIXED_ONE + (scene % 3u) * 28u);
    Vec3 base = {
        cabin_camera.position.x + fixed_mul(cabin_camera.forward.x, distance),
        cabin_camera.position.y + fixed_mul(cabin_camera.forward.y, distance),
        0
    };
    uint8_t index;

    for (index = 0u; index < sizeof(pieces) / sizeof(pieces[0]); ++index) {
        fixed_t side = fixed_mul((fixed_t)pieces[index].side, scale);
        fixed_t forward = fixed_mul((fixed_t)pieces[index].forward, scale);
        if (!engine_spawn_static_box(
                (Vec3){base.x + fixed_mul(cabin_camera.right.x, side) +
                           fixed_mul(cabin_camera.forward.x, forward),
                       base.y + fixed_mul(cabin_camera.right.y, side) +
                           fixed_mul(cabin_camera.forward.y, forward),
                       fixed_mul((fixed_t)pieces[index].z, scale)},
                (Vec3){pieces[index].half_x, pieces[index].half_y,
                       pieces[index].half_z}, EXTERIOR_ROOM, UI_WHITE)) return 0u;
    }
    return 1u;
}

static uint8_t rebuild_exterior_chunks(
    uint8_t scene, uint8_t debug_red, uint8_t include_subject
) {
    uint8_t center_x = coordinate_cell(exterior_map_from_world(cabin_camera.position.x));
    uint8_t center_y = coordinate_cell(exterior_map_from_world(cabin_camera.position.y));
    uint8_t ring;
    uint8_t wall_count = 0u;

    engine_static_scene_reset();

    /* Stream a broad ring of map-aligned walls.  The 16-cell / 60-wall window
       is twice the previous range, so freecam has no short-distance holes.
       Sixteen boxes remain for a detailed marked-site silhouette. */
    for (ring = 1u; ring <= EXTERIOR_CHUNK_RADIUS &&
         wall_count < EXTERIOR_WALL_LIMIT; ++ring) {
        int16_t y;
        for (y = (int16_t)center_y - ring;
             y <= (int16_t)center_y + ring && wall_count < EXTERIOR_WALL_LIMIT;
             ++y) {
            int16_t x;
            for (x = (int16_t)center_x - ring;
                 x <= (int16_t)center_x + ring && wall_count < EXTERIOR_WALL_LIMIT;
                 ++x) {
                uint16_t map_x_units;
                uint16_t map_y_units;

                if (x < 0 || y < 0 || x >= (int16_t)CAVE_SIZE ||
                    y >= (int16_t)CAVE_SIZE ||
                    (integer_absolute(x - center_x) != ring &&
                     integer_absolute(y - center_y) != ring) ||
                    cave_cell_open((uint8_t)x, (uint8_t)y)) continue;
                map_x_units = (uint16_t)((uint24_t)x * MAP_LIMIT /
                    (CAVE_SIZE - 1u));
                map_y_units = (uint16_t)((uint24_t)y * MAP_LIMIT /
                    (CAVE_SIZE - 1u));
                if (!engine_spawn_static_box(
                        (Vec3){exterior_world_from_map(map_x_units),
                               exterior_world_from_map(map_y_units), 420},
                        (Vec3){150, 150, 430}, EXTERIOR_ROOM,
                        debug_red ? UI_RED : UI_WHITE)) return 0u;
                ++wall_count;
            }
        }
    }
    if (include_subject && !spawn_interest_model(scene)) return 0u;
    exterior_chunk_x = center_x;
    exterior_chunk_y = center_y;
    return 1u;
}

static uint8_t build_exterior_scene(
    uint8_t scene, uint8_t debug_red, uint8_t include_subject
) {
    setup_exterior_camera();
    engine_set_static_scene_only(1u);
    if (!rebuild_exterior_chunks(scene, debug_red, include_subject)) return 0u;
    return 1u;
}

static void draw_debug_view(void) {
#if TI_LUNG_RAYCASTER
    uint8_t ray;
    const uint8_t ray_count = 80u;
    const fixed_t step = 4 * FIXED_ONE;

    gfx_FillScreen(UI_BLACK);
    for (ray = 0u; ray < ray_count; ++ray) {
        int8_t offset = (int8_t)ray - 40;
        uint8_t angle = (uint8_t)(heading_angle() + offset);
        fixed_t x = lung.x;
        fixed_t y = lung.y;
        fixed_t sine = angle_sine(angle);
        fixed_t cosine = angle_sine((uint8_t)(angle + 64u));
        uint8_t distance;

        for (distance = 1u; distance < 180u; ++distance) {
            int16_t map_x;
            int16_t map_y;
            /* Match navigation and proximity convention: heading zero is
               positive map Y, while positive angles turn toward map X. */
            x += fixed_mul(sine, step);
            y += fixed_mul(cosine, step);
            map_x = x >> FIXED_SHIFT;
            map_y = y >> FIXED_SHIFT;
            if (map_x < 0 || map_y < 0 || map_x > (int16_t)MAP_LIMIT ||
                map_y > (int16_t)MAP_LIMIT || !cave_cell_open(
                    coordinate_cell((uint16_t)map_x),
                    coordinate_cell((uint16_t)map_y)
                )) break;
        }
        {
            uint8_t height = (uint8_t)(1500u / (distance + 6u));
            uint8_t top;
            if (height < 2u) height = 2u;
            if (height > 170u) height = 170u;
            top = (uint8_t)(109u - height / 2u);
            gfx_SetColor(distance < 28u ? UI_RED : UI_RED_DARK);
            gfx_FillRectangle_NoClip(ray * 4u, top, 4u, height);
        }
    }
    {
        uint8_t creature_index;
        uint8_t view_angle = heading_angle();
        fixed_t view_sine = angle_sine(view_angle);
        fixed_t view_cosine = angle_sine((uint8_t)(view_angle + 64u));

        for (creature_index = 0u; creature_index < 3u; ++creature_index) {
            const SkeletalCreature *creature = &creatures[creature_index];
            fixed_t dx;
            fixed_t dy;
            fixed_t forward;
            fixed_t side;
            int16_t screen_x;
            uint8_t size;
            uint8_t bone;

            if (!creature->active) continue;
            dx = creature->x - lung.x;
            dy = creature->y - lung.y;
            forward = fixed_mul(view_sine, dx) + fixed_mul(view_cosine, dy);
            side = fixed_mul(view_cosine, dx) - fixed_mul(view_sine, dy);
            if (forward <= 4 * FIXED_ONE || fixed_absolute(side) > forward)
                continue;
            screen_x = 160 + (int16_t)(((int32_t)side * 120) / forward);
            if (screen_x < 24 || screen_x > 296) continue;
            size = (uint8_t)(300u / (uint16_t)(forward >> FIXED_SHIFT));
            if (size < 8u) size = 8u;
            if (size > 38u) size = 38u;
            gfx_SetColor(UI_WHITE);
            gfx_Circle_NoClip(screen_x + size / 2u, 108, size / 3u);
            gfx_SetColor(UI_BLACK);
            gfx_FillCircle_NoClip(screen_x + size / 2u + 2, 105,
                size > 18u ? 3u : 2u);
            gfx_SetColor(UI_WHITE);
            gfx_Line_NoClip(screen_x - size, 112, screen_x + size / 3u, 112);
            for (bone = 0u; bone < 5u; ++bone) {
                int16_t bx = screen_x - size + bone * (size / 3u + 2u);
                gfx_Line_NoClip(bx, 112, bx - 3, 112 - size / 2u);
                gfx_Line_NoClip(bx, 112, bx + 3, 112 + size / 2u);
            }
        }
    }
    if (debug_poi_index < 10u) {
        const PhotoPoint *point = &photo_points[debug_poi_index];
        fixed_t dx = point->x - lung.x;
        fixed_t dy = point->y - lung.y;
        fixed_t forward = fixed_mul(angle_sine((uint8_t)(heading_angle() + 64u)), dx) +
            fixed_mul(angle_sine(heading_angle()), dy);
        fixed_t side = -fixed_mul(angle_sine(heading_angle()), dx) +
            fixed_mul(angle_sine((uint8_t)(heading_angle() + 64u)), dy);
        if (forward > 4 * FIXED_ONE) {
            int16_t screen_x = 160 + (int16_t)(((int32_t)side * 120) / forward);
            uint8_t size = (uint8_t)(1200u / (uint16_t)(forward >> FIXED_SHIFT));
            if (size > 70u) size = 70u;
            if (size < 9u) size = 9u;
            gfx_SetColor(UI_WHITE);
            gfx_Line_NoClip(screen_x - size, 170, screen_x, 105 - size / 2u);
            gfx_Line_NoClip(screen_x + size, 170, screen_x, 105 - size / 2u);
            gfx_Line_NoClip(screen_x - size, 170, screen_x + size, 170);
            gfx_Line_NoClip(screen_x - size / 2u, 148, screen_x + size / 2u, 148);
            gfx_FillCircle_NoClip(screen_x, 128, size / 4u);
        }
    }
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(0, 218, 320, 22);
    set_text(UI_WHITE, 5, 219);
    gfx_PrintString("RAY TRACE EXIT ARROWS FLY PRGM POI");
    set_text(UI_GREEN, 5, 230);
    gfx_PrintString("RAYCAST OCEAN ");
    if (debug_poi_index < 10u) gfx_PrintUInt(debug_poi_index + 1u, 2u);
    else gfx_PrintString("--");
    gfx_PrintString(" STAT BONE ");
    if (debug_creature_index < 3u) {
        gfx_PrintUInt(debug_creature_index + 1u, 1u);
    } else {
        gfx_PrintString("-");
    }
    gfx_SwapDraw();
    return;
#endif
    ti_lung_engine_invalidate();
    engine_render(&cabin_camera, displayed_fps_tenths);
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(0, 218, 320, 22);
    set_text(UI_WHITE, 5, 219);
    gfx_PrintString("TRACE EXIT ARROWS FLY 2ND UP MODE DOWN");
    set_text(UI_GREEN, 5, 230);
    gfx_PrintString("POI ");
    if (debug_poi_index < 10u) {
        const PhotoPoint *point = &photo_points[debug_poi_index];
        gfx_PrintUInt(debug_poi_index + 1u, 2u);
        gfx_PrintString(" X");
        gfx_PrintUInt((uint16_t)(point->x >> FIXED_SHIFT), 1u);
        gfx_PrintString(" Y");
        gfx_PrintUInt((uint16_t)(point->y >> FIXED_SHIFT), 1u);
        gfx_PrintString(" A");
        print_heading_value(point->heading_cdeg);
    } else {
        gfx_PrintString("--");
    }
    set_text(UI_WHITE, 228, 230);
    gfx_PrintString("PRGM NEXT");
    gfx_SwapDraw();
}

static void debug_teleport_next_poi(void) {
    const PhotoPoint *point;

    debug_poi_index = (uint8_t)(debug_poi_index + 1u);
    if (debug_poi_index >= 10u) debug_poi_index = 0u;
    point = &photo_points[debug_poi_index];
    lung.precise_x = (int32_t)point->x << (NAV_SHIFT - FIXED_SHIFT);
    lung.precise_y = (int32_t)point->y << (NAV_SHIFT - FIXED_SHIFT);
    lung.x = point->x;
    lung.y = point->y;
    lung.heading_cdeg = point->heading_cdeg;
    lung.map_cursor_x = (uint16_t)(point->x >> FIXED_SHIFT);
    lung.map_cursor_y = (uint16_t)(point->y >> FIXED_SHIFT);
    lung.last_scene = point->scene;
#if !TI_LUNG_RAYCASTER
    setup_exterior_camera();
    rebuild_exterior_chunks(point->scene, 1u, 1u);
#endif
}

#if TI_LUNG_RAYCASTER
static void update_ray_debug(
    int8_t move_axis, int8_t turn_axis, uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    int32_t travel;
    uint8_t angle;
    if (ticks_per_second == 0u) return;
    if (turn_axis != 0) {
        int24_t heading = (int24_t)lung.heading_cdeg + turn_axis * (int24_t)(
            ((uint32_t)TURN_CDEG_PER_SECOND * elapsed_ticks) / ticks_per_second
        );
        while (heading < 0) heading += 36000;
        while (heading >= 36000) heading -= 36000;
        lung.heading_cdeg = (uint16_t)heading;
    }
    if (move_axis == 0) return;
    travel = ((int32_t)(24 * NAV_ONE) * elapsed_ticks) / ticks_per_second;
    angle = heading_angle();
    lung.precise_x += move_axis * (((int32_t)angle_sine((uint8_t)(angle + 64u)) * travel) >> FIXED_SHIFT);
    lung.precise_y += move_axis * (((int32_t)angle_sine(angle) * travel) >> FIXED_SHIFT);
    if (lung.precise_x < 0) lung.precise_x = 0;
    if (lung.precise_x > (int32_t)MAP_LIMIT * NAV_ONE) lung.precise_x = (int32_t)MAP_LIMIT * NAV_ONE;
    if (lung.precise_y < 0) lung.precise_y = 0;
    if (lung.precise_y > (int32_t)MAP_LIMIT * NAV_ONE) lung.precise_y = (int32_t)MAP_LIMIT * NAV_ONE;
    sync_navigation_position();
}
#endif

/* Trace mode needs free flight, not T3D3's full portal/body physics loop.
   Keeping this controller local lets the linker discard that large subsystem
   from the always-resident calculator program. */
static void update_debug_camera(
    int8_t move_axis,
    int8_t turn_axis,
    uint8_t rise,
    uint8_t fall,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    const fixed_t speed = 3600;
    fixed_t travel;
    uint8_t changed = 0u;

    if (ticks_per_second == 0u) return;
    if (turn_axis != 0) {
        uint8_t step = (uint8_t)(((uint32_t)80u * elapsed_ticks +
            ticks_per_second / 2u) / ticks_per_second);
        if (step == 0u) step = 1u;
        cabin_camera.yaw = (uint8_t)(cabin_camera.yaw + turn_axis * step);
        rebuild_basis(&cabin_camera);
        changed = 1u;
    }
    travel = (fixed_t)(((int32_t)speed * elapsed_ticks) / ticks_per_second);
    if (move_axis != 0) {
        cabin_camera.position.x += fixed_mul(cabin_camera.forward.x,
            move_axis * travel);
        cabin_camera.position.y += fixed_mul(cabin_camera.forward.y,
            move_axis * travel);
        changed = 1u;
    }
    if (rise != fall) {
        cabin_camera.position.z += (rise ? travel : -travel);
        changed = 1u;
    }
    if (!changed) return;
    if (cabin_camera.position.x < EXTERIOR_WORLD_MIN + 64) {
        cabin_camera.position.x = EXTERIOR_WORLD_MIN + 64;
    }
    if (cabin_camera.position.x > EXTERIOR_WORLD_MAX - 64) {
        cabin_camera.position.x = EXTERIOR_WORLD_MAX - 64;
    }
    if (cabin_camera.position.y < EXTERIOR_WORLD_MIN + 64) {
        cabin_camera.position.y = EXTERIOR_WORLD_MIN + 64;
    }
    if (cabin_camera.position.y > EXTERIOR_WORLD_MAX - 64) {
        cabin_camera.position.y = EXTERIOR_WORLD_MAX - 64;
    }
    if (cabin_camera.position.z < 96) cabin_camera.position.z = 96;
    if (cabin_camera.position.z > 2976) cabin_camera.position.z = 2976;
    {
        uint8_t chunk_x = coordinate_cell(
            exterior_map_from_world(cabin_camera.position.x)
        );
        uint8_t chunk_y = coordinate_cell(
            exterior_map_from_world(cabin_camera.position.y)
        );
        if (chunk_x != exterior_chunk_x || chunk_y != exterior_chunk_y) {
            rebuild_exterior_chunks(
                lung.last_scene == 0xFFu ? 0u : lung.last_scene,
                1u, 0u
            );
        }
    }
}

static uint8_t initialize_game(uint8_t continue_game) {
#if !TI_LUNG_RAYCASTER
    if (!true3d_level_embedded_view(0u, &level) ||
        !engine_init(&cabin_camera, &level)) {
        return 0u;
    }
#endif
    build_cave();
    memset(&lung, 0, sizeof(lung));
    set_navigation_position(182u, 116u);
    lung.heading_cdeg = 0u;
    lung.oxygen = 4u;
    lung.pressure = 4u;
    lung.last_scene = 0xFFu;
    lung.view = VIEW_CABIN;
    lung.map_cursor_x = 182u;
    lung.map_cursor_y = 116u;
    debug_creature_index = 0xFFu;

    memset(creatures, 0, sizeof(creatures));
    creatures[0].phase = 0u;
    creatures[0].speed = 3u;
    creatures[0].radius = 11u;
    creatures[0].kind = 0u;
    creatures[1].phase = 85u;
    creatures[1].speed = 2u;
    creatures[1].radius = 27u;
    creatures[1].kind = 1u;
    creatures[2].phase = 170u;
    creatures[2].speed = 1u;
    creatures[2].radius = 43u;
    creatures[2].kind = 2u;

    if (continue_game && !load_saved_game(&lung)) return 0u;

#if !TI_LUNG_RAYCASTER
    cabin_camera.position = (Vec3){0, -512, 384};
    cabin_camera.velocity = (Vec3){0, 0, 0};
    cabin_camera.room = CABIN_ROOM;
    cabin_camera.yaw = 64u;
    cabin_camera.pitch = 0;
    rebuild_basis(&cabin_camera);
#endif
    update_creatures();
    update_sensors();
    return 1u;
}

static void configure_ui_palette(void) {
    /* TI Lung owns every palette slot it uses.  The stripped ray build does
       not call T3D3's palette initializer, so relying on calculator residue
       here caused the green/white helm corruption seen after a photo. */
    gfx_palette[UI_BLACK] = gfx_RGBTo1555(0, 0, 0);
    gfx_palette[UI_VOID] = gfx_RGBTo1555(4, 5, 12);
    gfx_palette[UI_FLOOR] = gfx_RGBTo1555(22, 20, 24);
    gfx_palette[UI_CEILING] = gfx_RGBTo1555(35, 30, 31);
    gfx_palette[UI_GREEN] = gfx_RGBTo1555(25, 220, 92);
    gfx_palette[UI_GREEN_DARK] = gfx_RGBTo1555(8, 108, 43);
    gfx_palette[UI_BROWN] = gfx_RGBTo1555(86, 40, 25);
    gfx_palette[UI_BROWN_DARK] = gfx_RGBTo1555(47, 23, 20);
    gfx_palette[UI_RED] = gfx_RGBTo1555(210, 47, 36);
    gfx_palette[UI_RED_DARK] = gfx_RGBTo1555(104, 23, 25);
    gfx_palette[UI_BLUE] = gfx_RGBTo1555(26, 42, 112);
    gfx_palette[UI_ORANGE] = gfx_RGBTo1555(220, 116, 30);
    gfx_palette[UI_WHITE] = gfx_RGBTo1555(228, 232, 215);
    gfx_palette[UI_RUST] = gfx_RGBTo1555(78, 28, 20);
    gfx_palette[UI_RUST_LIGHT] = gfx_RGBTo1555(145, 57, 31);
    gfx_palette[UI_PAPER] = gfx_RGBTo1555(135, 137, 112);
    gfx_palette[UI_PAPER_DARK] = gfx_RGBTo1555(71, 67, 55);
    gfx_palette[PHOTO_BLACK] = gfx_RGBTo1555(2, 3, 3);
    gfx_palette[PHOTO_DARK] = gfx_RGBTo1555(28, 31, 30);
    gfx_palette[PHOTO_MID] = gfx_RGBTo1555(78, 82, 78);
    gfx_palette[PHOTO_LIGHT] = gfx_RGBTo1555(157, 160, 147);
    gfx_palette[PHOTO_WHITE] = gfx_RGBTo1555(238, 235, 211);
}

static void initialize_palette(void) {
#if !TI_LUNG_RAYCASTER
    engine_graphics_init();
#endif
    configure_ui_palette();
}

int main(void) {
    clock_t previous_tick;
    uint24_t accumulated_ticks = 0u;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);
    uint8_t start_mode;

    gfx_Begin();
    gfx_SetDrawBuffer();
    initialize_palette();
    gfx_SetTextBGColor(UI_BLACK);
    gfx_SetTextTransparentColor(UI_BLACK);
    kb_SetMode(MODE_3_CONTINUOUS);
    start_mode = wait_for_deploy();
    if (start_mode == 0u) {
        kb_Reset();
        gfx_End();
        return 0;
    }
    while ((kb_Data[1] & (kb_2nd | kb_Graph)) != 0u) kb_Scan();
    if (!initialize_game((uint8_t)(start_mode == 2u))) {
        gfx_FillScreen(UI_BLACK);
        set_text(UI_RED, 80, 112);
        gfx_PrintString("PRESSURE SYSTEM FAILURE");
        gfx_SwapDraw();
        while ((kb_Data[6] & kb_Clear) == 0u) kb_Scan();
        kb_Reset();
        gfx_End();
        return 1;
    }
    if (start_mode == 1u) save_current_game();
    /* Prime both GraphX buffers so the first idle cabin frame cannot expose
       remnants of the deployment/title screen. */
    draw_current_view();
    draw_current_view();
    previous_tick = clock();

    for (;;) {
        clock_t current_tick;
        uint8_t edge_keys;
        uint8_t pressed;

        kb_Scan();
        if ((kb_Data[6] & kb_Clear) != 0u) break;
        current_tick = clock();
        accumulated_ticks += (uint24_t)(current_tick - previous_tick);
        previous_tick = current_tick;
        edge_keys = read_edge_keys();
        pressed = (uint8_t)(edge_keys & (uint8_t)~lung.previous_edge_keys);
        lung.previous_edge_keys = edge_keys;

        if (lung.view == VIEW_END) continue;
        if (lung.view == VIEW_ATTACK) {
            if (accumulated_ticks >= update_ticks) {
                if (lung.attack_ticks != 0u) --lung.attack_ticks;
                if (lung.attack_ticks == 0u) lung.view = VIEW_END;
                draw_current_view();
                accumulated_ticks = 0u;
            }
            continue;
        }
        if (lung.view == VIEW_PHOTO) {
            if ((pressed & EDGE_USE) != 0u) {
                /* Restore every engine/UI palette entry changed for the
                   monochrome camera before the 2D helm draws again. */
                initialize_palette();
                lung.view = VIEW_CABIN;
                draw_cabin();
            }
            continue;
        }
        if (lung.view == VIEW_DEBUG) {
            if ((pressed & EDGE_DEBUG) != 0u) {
                lung.view = VIEW_CABIN;
                draw_cabin();
                continue;
            }
            if ((kb_Data[4] & kb_Prgm) != 0u) {
                if (!debug_prgm_held) {
                    debug_teleport_next_poi();
                    draw_debug_view();
                }
                debug_prgm_held = 1u;
            } else {
                debug_prgm_held = 0u;
            }
            if ((kb_Data[4] & kb_Stat) != 0u) {
                if (!debug_stat_held) {
                    debug_creature_index = (uint8_t)(debug_creature_index + 1u);
                    if (debug_creature_index > 3u) debug_creature_index = 0u;
                    if (debug_creature_index == 3u) {
                        debug_creature_index = 0xFFu;
                    } else {
                        creatures[debug_creature_index].phase = heading_angle();
                    }
                    update_creatures();
                    update_sensors();
                    draw_debug_view();
                }
                debug_stat_held = 1u;
            } else {
                debug_stat_held = 0u;
            }
            if (accumulated_ticks >= update_ticks) {
                int8_t forward = (int8_t)(
                    ((kb_Data[7] & kb_Up) != 0u) -
                    ((kb_Data[7] & kb_Down) != 0u)
                );
                int8_t turn = (int8_t)(
                    ((kb_Data[7] & kb_Right) != 0u) -
                    ((kb_Data[7] & kb_Left) != 0u)
                );

#if TI_LUNG_RAYCASTER
                update_ray_debug(
                    forward, turn, accumulated_ticks, (uint24_t)CLOCKS_PER_SEC
                );
#else
                update_debug_camera(
                    forward,
                    turn,
                    (uint8_t)((kb_Data[1] & kb_2nd) != 0u),
                    (uint8_t)((kb_Data[1] & kb_Mode) != 0u),
                    accumulated_ticks,
                    (uint24_t)CLOCKS_PER_SEC
                );
#endif
                update_creatures();
                update_sensors();
                draw_debug_view();
                accumulated_ticks = 0u;
            }
            continue;
        }
        if (lung.view == VIEW_MAP) {
            if ((pressed & (EDGE_MAP | EDGE_BRIEFING)) != 0u) {
                lung.view = VIEW_CABIN;
                draw_cabin();
                continue;
            }
            if ((pressed & EDGE_USE) != 0u) {
                lung.waypoint_x = lung.map_cursor_x;
                lung.waypoint_y = lung.map_cursor_y;
                lung.waypoint_active = 1u;
                draw_map();
            }
            if (accumulated_ticks >= update_ticks) {
                if (update_map_cursor()) draw_map();
                accumulated_ticks = 0u;
            }
            continue;
        }
        if (lung.view == VIEW_BRIEFING) {
            if ((pressed & (EDGE_USE | EDGE_BRIEFING)) != 0u) {
                lung.view = VIEW_CABIN;
                draw_cabin();
            }
            continue;
        }
        if ((pressed & EDGE_MAP) != 0u) {
            lung.view = VIEW_MAP;
            lung.helm_active = 0u;
            if (!lung.waypoint_active) {
                lung.map_cursor_x = (uint16_t)(lung.x >> FIXED_SHIFT);
                lung.map_cursor_y = (uint16_t)(lung.y >> FIXED_SHIFT);
            }
            draw_map();
            continue;
        }
        if ((pressed & EDGE_BRIEFING) != 0u) {
            lung.view = VIEW_BRIEFING;
            lung.helm_active = 0u;
            draw_briefing();
            continue;
        }
        if ((pressed & EDGE_DEBUG) != 0u) {
            lung.view = VIEW_DEBUG;
#if TI_LUNG_RAYCASTER
            draw_debug_view();
#else
            if (!build_exterior_scene(
                    lung.last_scene == 0xFFu ? 0u : lung.last_scene, 1u, 0u
                )) {
                lung.view = VIEW_CABIN;
                set_message(MESSAGE_HULL_CONTACT, 45u);
                draw_cabin();
            } else {
                draw_debug_view();
            }
#endif
            continue;
        }
        if ((pressed & EDGE_USE) != 0u) {
            use_station();
            if (lung.view != VIEW_CABIN) {
                accumulated_ticks = 0u;
                previous_tick = clock();
                continue;
            }
            draw_cabin();
        }

        if (accumulated_ticks >= update_ticks) {
            int8_t forward = (int8_t)(
                ((kb_Data[7] & kb_Up) != 0u) -
                ((kb_Data[7] & kb_Down) != 0u)
            );
            int8_t turn = (int8_t)(
                ((kb_Data[7] & kb_Right) != 0u) -
                ((kb_Data[7] & kb_Left) != 0u)
            );
            uint8_t changed;

            changed = update_navigation(
                forward,
                turn,
                accumulated_ticks,
                (uint24_t)CLOCKS_PER_SEC
            );
            update_creatures();
            update_scripted_events();
            if (lung.fire_level != 0u) {
                lung.hazard_ticks += 1u;
                if (lung.hazard_ticks >= UPDATE_RATE * 5u) {
                    lung.hazard_ticks = 0u;
                    if (lung.oxygen > 1u) --lung.oxygen;
                }
                changed = 1u;
            }
            if (lung.message_ticks != 0u) {
                --lung.message_ticks;
                changed = 1u;
            }
            /* The sonar is a living instrument: redraw the cheap 2D helm at
               the fixed update rate so its white proximity rings keep pulsing
               even when the submarine is stationary. */
            changed = 1u;
            if (changed) {
                ++lung.autosave_ticks;
                if (lung.autosave_ticks >= UPDATE_RATE * 3u) {
                    save_current_game();
                    lung.autosave_ticks = 0u;
                }
                draw_current_view();
            }
            accumulated_ticks = 0u;
        }
    }

    kb_Reset();
    gfx_End();
    return 0;
}
