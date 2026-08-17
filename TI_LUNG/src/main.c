#include "engine_bridge.h"

#include <graphx.h>
#include <keypadc.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)
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
#define PHOTO_POSITION_TOLERANCE (18 * FIXED_ONE)
#define PHOTO_HEADING_TOLERANCE 1000u
#define CAMERA_HEIGHT 640

#define EVENT_SENSOR_GHOST (1u << 0)
#define EVENT_FISH_ONE (1u << 1)
#define EVENT_FIRE (1u << 2)
#define EVENT_FISH_TWO (1u << 3)
#define EVENT_EYE_ACTIVE (1u << 4)
#define EVENT_EYE_SEEN (1u << 5)
#define EVENT_FINAL (1u << 6)

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
    VIEW_END
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
    EDGE_BRIEFING = 1u << 2
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
    MESSAGE_FIRE_OUT
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
    fixed_t sensor[4];
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
} LungState;

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

static fixed_t fixed_absolute(fixed_t value) {
    return value < 0 ? -value : value;
}

static fixed_t fixed_mul(fixed_t left, fixed_t right) {
    return (fixed_t)(((int32_t)left * right) >> FIXED_SHIFT);
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

static uint8_t angle_difference_u8(uint8_t first, uint8_t second) {
    uint8_t difference = first > second ? first - second : second - first;

    return difference > 128u ? (uint8_t)(256u - difference) : difference;
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

static void print_fixed_hundredths(fixed_t value) {
    uint24_t magnitude;
    uint24_t hundredths;

    if (value < 0) {
        gfx_PrintChar('-');
        magnitude = (uint24_t)-value;
    } else {
        magnitude = (uint24_t)value;
    }
    hundredths = (magnitude * 100u + 128u) >> FIXED_SHIFT;
    gfx_PrintUInt(hundredths / 100u, 1u);
    gfx_PrintChar('.');
    gfx_PrintUInt(hundredths % 100u, 2u);
}

static void print_heading(void) {
    gfx_PrintUInt(lung.heading_cdeg / 100u, 3u);
    gfx_PrintChar('.');
    gfx_PrintUInt(lung.heading_cdeg % 100u, 2u);
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

static void update_sensors(void) {
    uint8_t angle = heading_angle();

    lung.sensor[0] = cast_sensor(angle);
    lung.sensor[1] = cast_sensor((uint8_t)(angle + 64u));
    lung.sensor[2] = cast_sensor((uint8_t)(angle + 128u));
    lung.sensor[3] = cast_sensor((uint8_t)(angle - 64u));

    if ((lung.x >= 532 * FIXED_ONE && lung.x <= 550 * FIXED_ONE &&
         documented_count() >= 4u) ||
        (lung.event_flags & EVENT_EYE_ACTIVE) != 0u) {
        lung.sensor[0] = FIXED_ONE;
    }
}

static fixed_t nearest_sensor(void) {
    fixed_t result = lung.sensor[0];
    uint8_t index;

    for (index = 1u; index < 4u; ++index) {
        if (lung.sensor[index] < result) result = lung.sensor[index];
    }
    return result;
}

static void set_message(uint8_t message, uint8_t ticks) {
    lung.message = message;
    lung.message_ticks = ticks;
}

static void update_scripted_events(void) {
    uint8_t photos = documented_count();

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
        lung.x = 576 * FIXED_ONE;
        lung.y = 355 * FIXED_ONE;
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
        lung.x = 276 * FIXED_ONE;
        lung.y = 635 * FIXED_ONE;
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
        fixed_t travel = (fixed_t)(
            ((int32_t)NAV_SPEED * elapsed_ticks) / ticks_per_second
        );
        uint8_t angle = heading_angle();
        fixed_t candidate_x;
        fixed_t candidate_y;

        if (travel == 0) travel = 1;
        candidate_x = lung.x + fixed_mul(
            angle_sine(angle),
            throttle * travel
        );
        candidate_y = lung.y + fixed_mul(
            angle_sine((uint8_t)(angle + 64u)),
            throttle * travel
        );
        if (point_blocked(candidate_x, candidate_y)) {
            set_message(MESSAGE_HULL_CONTACT, 45u);
        } else {
            lung.x = candidate_x;
            lung.y = candidate_y;
            lung.has_moved = 1u;
        }
        changed = 1u;
    }
    if (changed) update_scripted_events();
    return changed;
}

static uint8_t station_in_reach(void) {
    if (cabin_camera.position.y > 300 &&
        angle_difference_u8(cabin_camera.yaw, 64u) < 42u) {
        return STATION_HELM;
    }
    if (cabin_camera.position.y < -360 &&
        angle_difference_u8(cabin_camera.yaw, 192u) < 48u) {
        return cabin_camera.position.x < 160 ?
            STATION_CAMERA : STATION_EXTINGUISHER;
    }
    return STATION_NONE;
}

static uint8_t sensor_color(fixed_t distance) {
    if (distance <= 12 * FIXED_ONE) return UI_RED;
    if (distance <= 35 * FIXED_ONE) return UI_ORANGE;
    return UI_GREEN_DARK;
}

static void draw_sensor_lamp(int16_t x, int16_t y, fixed_t distance) {
    uint8_t color = sensor_color(distance);

    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(x, y, 13, 13);
    gfx_SetColor(color);
    gfx_Rectangle_NoClip(x, y, 13, 13);
    if (distance <= 35 * FIXED_ONE && ((clock() >> 10) & 1u) != 0u) {
        gfx_FillRectangle_NoClip(x + 3, y + 3, 7, 7);
    }
}

/* The helm readout is shown only after the player physically engages the
 * world-space console.  It never slides with yaw, so every NoClip coordinate
 * is a fixed, verified on-screen value. */
static void draw_helm_readout(void) {
    gfx_SetColor(UI_BROWN_DARK);
    gfx_FillRectangle_NoClip(18, 132, 284, 84);
    gfx_SetColor(UI_RUST_LIGHT);
    gfx_Rectangle_NoClip(18, 132, 284, 84);
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(29, 143, 91, 25);
    gfx_FillRectangle_NoClip(127, 143, 91, 25);
    gfx_FillRectangle_NoClip(225, 143, 66, 25);

    set_text(UI_GREEN, 35, 150);
    gfx_PrintString("X ");
    print_fixed_hundredths(lung.x);
    set_text(UI_GREEN, 133, 150);
    gfx_PrintString("Y ");
    print_fixed_hundredths(lung.y);
    set_text(UI_GREEN, 231, 150);
    gfx_PrintString("A ");
    print_heading();

    draw_sensor_lamp(36, 180, lung.sensor[0]);
    draw_sensor_lamp(57, 180, lung.sensor[1]);
    draw_sensor_lamp(78, 180, lung.sensor[2]);
    draw_sensor_lamp(99, 180, lung.sensor[3]);
    set_text(UI_RUST_LIGHT, 34, 198);
    gfx_PrintString("F  R  B  L");

    set_text(lung.waypoint_active ? UI_GREEN : UI_RUST_LIGHT, 137, 181);
    if (lung.waypoint_active) {
        gfx_PrintString("WAYPOINT X");
        gfx_PrintUInt(lung.waypoint_x, 1u);
        gfx_PrintString(" Y");
        gfx_PrintUInt(lung.waypoint_y, 1u);
    } else {
        gfx_PrintString("GRAPH: SET WAYPOINT");
    }
    set_text(UI_WHITE, 137, 199);
    gfx_PrintString("ARROWS: THRUST / TURN");
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
        default: return "";
    }
}

static void draw_cabin_prompt(void) {
    uint8_t station = station_in_reach();

    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(0, 218, GFX_LCD_WIDTH, 22);
    gfx_SetColor(nearest_sensor() <= 12 * FIXED_ONE ? UI_RED : UI_RUST_LIGHT);
    gfx_HorizLine_NoClip(0, 217, GFX_LCD_WIDTH);
    set_text(UI_WHITE, 7, 225);
    if (lung.message_ticks != 0u) {
        gfx_PrintString(message_text(lung.message));
    } else if (lung.helm_active) {
        gfx_PrintString("ARROWS PILOT  2ND EXIT  GRAPH MAP");
    } else if (station == STATION_HELM) {
        gfx_PrintString("2ND: OPERATE NAVIGATION CONTROLS");
    } else if (station == STATION_CAMERA) {
        gfx_PrintString("2ND: ACTIVATE EXTERNAL CAMERA");
    } else if (station == STATION_EXTINGUISHER && lung.fire_level != 0u) {
        gfx_PrintString("2ND: DISCHARGE EXTINGUISHER");
    } else {
        gfx_PrintString("ARROWS WALK/TURN   2ND USE   GRAPH MAP");
    }
}

static void draw_cabin(void) {
    clock_t render_start = clock();
    uint24_t render_ticks;

    ti_lung_engine_invalidate();
    engine_render(&cabin_camera, displayed_fps_tenths);
    if (lung.helm_active) draw_helm_readout();
    draw_fire_and_leaks();
    draw_cabin_prompt();
    gfx_SwapDraw();

    render_ticks = (uint24_t)(clock() - render_start);
    if (render_ticks != 0u) {
        uint32_t measured = ((uint32_t)CLOCKS_PER_SEC * 10u) / render_ticks;

        if (measured > 9999u) measured = 9999u;
        displayed_fps_tenths = (uint16_t)measured;
    }
}

static int16_t map_x(uint16_t coordinate) {
    return (int16_t)(20 + ((uint24_t)coordinate * 280u) / MAP_LIMIT);
}

static int16_t map_y(uint16_t coordinate) {
    return (int16_t)(210 - ((uint24_t)coordinate * 180u) / MAP_LIMIT);
}

static void draw_map(void) {
    uint8_t x;
    uint8_t y;
    uint8_t index;

    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_PAPER_DARK);
    gfx_FillRectangle_NoClip(13, 18, 294, 201);
    gfx_SetColor(UI_PAPER);
    gfx_FillRectangle_NoClip(20, 24, 280, 192);

    for (y = 0u; y < CAVE_SIZE; ++y) {
        for (x = 0u; x < CAVE_SIZE; ++x) {
            if (cave_cell_open(x, y)) {
                gfx_SetColor(((x + y) & 3u) == 0u ? UI_VOID : UI_CEILING);
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
        int16_t submarine_x = map_x((uint16_t)(lung.x >> FIXED_SHIFT));
        int16_t submarine_y = map_y((uint16_t)(lung.y >> FIXED_SHIFT));
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
    gfx_FillRectangle_NoClip(0, 0, 320, 17);
    gfx_FillRectangle_NoClip(0, 220, 320, 20);
    set_text(UI_WHITE, 1, 5);
    gfx_PrintString("AT-5  ARROWS MOVE  2ND SET  GRAPH OUT");
    set_text(UI_GREEN, 7, 226);
    gfx_PrintString("SUB ");
    gfx_PrintUInt((uint16_t)(lung.x >> FIXED_SHIFT), 1u);
    gfx_PrintString(",");
    gfx_PrintUInt((uint16_t)(lung.y >> FIXED_SHIFT), 1u);
    set_text(UI_WHITE, 112, 226);
    gfx_PrintString("CUR ");
    gfx_PrintUInt(lung.map_cursor_x, 1u);
    gfx_PrintString(",");
    gfx_PrintUInt(lung.map_cursor_y, 1u);
    set_text(UI_GREEN, 232, 226);
    gfx_PrintString("2ND SET");
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

/* The external image is deliberately a bounded photographic projection, not
   another live 3D room.  Its vanishing point and cave throat come from the
   four proximity rays, while the rock grain is seeded by coordinates and
   heading.  This preserves the game's separate "camera reality" and avoids
   making the tiny calculator render an unbounded exterior scene. */
static void draw_photo_environment(uint8_t scene) {
    uint8_t front = (uint8_t)(lung.sensor[0] >> FIXED_SHIFT);
    uint8_t right = (uint8_t)(lung.sensor[1] >> FIXED_SHIFT);
    uint8_t left = (uint8_t)(lung.sensor[3] >> FIXED_SHIFT);
    int16_t vanishing_x;
    int16_t throat;
    uint16_t seed = (uint16_t)(
        (lung.x >> 3) ^ (lung.y >> 2) ^ lung.heading_cdeg ^
        ((uint16_t)scene << 11)
    );
    uint8_t band;

    if (front > SENSOR_MAX_UNITS) front = SENSOR_MAX_UNITS;
    if (right > SENSOR_MAX_UNITS) right = SENSOR_MAX_UNITS;
    if (left > SENSOR_MAX_UNITS) left = SENSOR_MAX_UNITS;
    vanishing_x = 160 + (int16_t)right - (int16_t)left;
    if (vanishing_x < 125) vanishing_x = 125;
    if (vanishing_x > 195) vanishing_x = 195;
    throat = 18 + front;
    if (throat > 63) throat = 63;

    gfx_FillScreen(PHOTO_BLACK);
    gfx_SetColor(PHOTO_DARK);
    gfx_FillTriangle_NoClip(24, 24, vanishing_x - throat, 111,
                            24, 204);
    gfx_FillTriangle_NoClip(296, 24, vanishing_x + throat, 111,
                            296, 204);
    gfx_SetColor(PHOTO_MID);
    gfx_FillTriangle_NoClip(24, 24, 296, 24,
                            vanishing_x, 111 - throat / 2);
    gfx_SetColor(PHOTO_DARK);
    gfx_FillTriangle_NoClip(24, 204, 296, 204,
                            vanishing_x, 111 + throat / 2);

    /* Receding seams make distance legible in the developed still. */
    for (band = 1u; band <= 6u; ++band) {
        int16_t inset = band * 18;
        int16_t top = 24 + band * 12;
        int16_t bottom = 204 - band * 12;
        int16_t left_edge = 24 + inset;
        int16_t right_edge = 296 - inset;

        gfx_SetColor((band & 1u) != 0u ? PHOTO_MID : PHOTO_DARK);
        gfx_Line_NoClip(left_edge, top, vanishing_x - throat, 111);
        gfx_Line_NoClip(right_edge, top, vanishing_x + throat, 111);
        gfx_HorizLine_NoClip(left_edge, top,
            (uint16_t)(right_edge - left_edge));
        gfx_HorizLine_NoClip(left_edge, bottom,
            (uint16_t)(right_edge - left_edge));
    }

    /* Coordinate-stable stone silhouettes make two photographs taken at
       different map positions visibly different. */
    for (band = 0u; band < 11u; ++band) {
        int16_t x;
        int16_t y;
        uint8_t radius;

        seed = (uint16_t)(seed * 25173u + 13849u);
        x = (int16_t)(30 + seed % 260u);
        seed = (uint16_t)(seed * 25173u + 13849u);
        y = (int16_t)(36 + seed % 154u);
        radius = (uint8_t)(4u + (seed >> 12));
        gfx_SetColor((band & 2u) != 0u ? PHOTO_MID : PHOTO_DARK);
        gfx_FillCircle_NoClip(x, y, radius);
    }
}

static void draw_photo_scene(uint8_t scene) {
    uint8_t index;

    gfx_SetColor(PHOTO_LIGHT);
    switch (scene) {
        case 0u:
            for (index = 0u; index < 7u; ++index) {
                gfx_Line_NoClip(88 + index * 20, 172,
                                106 + index * 16, 72 + (index & 1u) * 20);
                gfx_Line_NoClip(91 + index * 20, 172,
                                109 + index * 16, 72 + (index & 1u) * 20);
            }
            break;
        case 1u:
            for (index = 0u; index < 5u; ++index) {
                gfx_FillRectangle_NoClip(60 + index * 45,
                    70 + (index & 1u) * 18, 17, 112 - (index & 1u) * 18);
            }
            gfx_HorizLine_NoClip(50, 67, 230);
            break;
        case 2u:
            for (index = 0u; index < 9u; ++index) {
                gfx_Line_NoClip(160, 177, 55 + index * 27,
                    55 + ((index * 31u) % 80u));
            }
            gfx_FillCircle_NoClip(160, 176, 16);
            break;
        case 3u:
            gfx_Rectangle_NoClip(79, 54, 163, 129);
            gfx_Rectangle_NoClip(100, 74, 121, 91);
            for (index = 0u; index < 4u; ++index) {
                gfx_VertLine_NoClip(121 + index * 25, 75, 89);
            }
            break;
        case 4u:
            gfx_Line_NoClip(58, 176, 157, 62);
            gfx_Line_NoClip(262, 176, 157, 62);
            for (index = 0u; index < 7u; ++index) {
                gfx_Line_NoClip(88 + index * 24, 150,
                    157, 70 + index * 8);
            }
            break;
        case 5u:
            for (index = 0u; index < 6u; ++index) {
                gfx_FillRectangle_NoClip(46 + index * 46, 92, 22, 89);
                gfx_Rectangle_NoClip(39 + index * 46, 82, 36, 99);
            }
            break;
        case 6u:
            gfx_FillCircle_NoClip(160, 112, 34);
            gfx_SetColor(PHOTO_WHITE);
            gfx_FillCircle_NoClip(160, 112, 16);
            gfx_SetColor(PHOTO_LIGHT);
            for (index = 0u; index < 8u; ++index) {
                gfx_Line_NoClip(160, 112, 50 + index * 32,
                    52 + ((index * 43u) % 128u));
            }
            break;
        case 7u:
            gfx_Rectangle_NoClip(46, 51, 230, 134);
            for (index = 0u; index < 7u; ++index) {
                gfx_HorizLine_NoClip(46, 51 + index * 20, 230);
            }
            for (index = 0u; index < 9u; ++index) {
                gfx_VertLine_NoClip(46 + index * 28,
                    51 + (index & 1u) * 10, 124);
            }
            break;
        case 8u:
            gfx_Line_NoClip(65, 178, 101, 72);
            gfx_Line_NoClip(101, 72, 132, 178);
            gfx_Line_NoClip(132, 178, 166, 61);
            gfx_Line_NoClip(166, 61, 205, 178);
            gfx_Line_NoClip(205, 178, 236, 83);
            break;
        case 9u:
            gfx_Rectangle_NoClip(64, 58, 192, 121);
            gfx_Rectangle_NoClip(83, 76, 154, 86);
            gfx_FillRectangle_NoClip(150, 77, 20, 84);
            break;
        case 10u:
            gfx_SetColor(PHOTO_WHITE);
            gfx_FillCircle_NoClip(160, 111, 63);
            gfx_SetColor(PHOTO_DARK);
            gfx_FillCircle_NoClip(160, 111, 36);
            gfx_SetColor(PHOTO_BLACK);
            gfx_FillCircle_NoClip(160, 111, 16);
            gfx_SetColor(PHOTO_LIGHT);
            gfx_HorizLine_NoClip(97, 111, 126);
            break;
        default:
            break;
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

static void draw_camera_charge(uint8_t stage) {
    gfx_FillScreen(UI_BLACK);
    gfx_SetColor(UI_RUST);
    gfx_FillRectangle_NoClip(42, 42, 236, 144);
    gfx_SetColor(UI_RUST_LIGHT);
    gfx_Rectangle_NoClip(42, 42, 236, 144);
    set_text(UI_GREEN, 88, 77);
    gfx_PrintString("EXTERNAL CAMERA CYCLING");
    gfx_SetColor(UI_BLACK);
    gfx_FillRectangle_NoClip(72, 111, 176, 18);
    gfx_SetColor(UI_GREEN);
    gfx_FillRectangle_NoClip(76, 115, stage * 42, 10);
    set_text(UI_WHITE, 101, 151);
    gfx_PrintString("HOLD POSITION");
    gfx_SwapDraw();
}

static void capture_photo(void) {
    uint8_t target = valid_photo_point();
    uint8_t scene = target == 0xFFu ? 0xFFu : photo_points[target].scene;
    uint8_t stage;

    for (stage = 1u; stage <= 4u; ++stage) {
        volatile uint16_t camera_delay;

        draw_camera_charge(stage);
        /* A bounded hardware-speed pause cannot deadlock when an emulator's
           real-time clock is paused during deterministic input playback. */
        for (camera_delay = 0u; camera_delay < 9000u; ++camera_delay) { }
    }
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
    lung.last_scene = scene;

    draw_photo_environment(scene);
    draw_photo_scene(scene);
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
    print_fixed_hundredths(lung.x);
    gfx_PrintString(" Y");
    print_fixed_hundredths(lung.y);
    gfx_PrintString(" A");
    print_heading();
    set_text(target < 9u ? UI_GREEN : UI_WHITE, 7, 215);
    gfx_PrintString(target < 9u ?
        "MARKED SITE RECORDED" :
        (scene == 10u ? "UNIDENTIFIED ORGANISM" : "NO MARKED SUBJECT"));
    set_text(UI_WHITE, 232, 227);
    gfx_PrintString("2ND RETURN");
    gfx_SwapDraw();
    lung.view = VIEW_PHOTO;
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
    gfx_PrintString("SM-13 TELEMETRY TERMINATED");
    set_text(UI_RUST_LIGHT, 40, 139);
    gfx_PrintString("NO RECOVERY METHOD IS AVAILABLE.");
    set_text(UI_GREEN, 75, 178);
    gfx_PrintString("SURVEY RECORD: 9 / 10");
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
        default: draw_cabin(); break;
    }
}

static uint8_t read_edge_keys(void) {
    return (uint8_t)(
        ((kb_Data[1] & kb_2nd) != 0u ? EDGE_USE : 0u) |
        ((kb_Data[1] & kb_Graph) != 0u ? EDGE_MAP : 0u) |
        ((kb_Data[1] & kb_Mode) != 0u ? EDGE_BRIEFING : 0u)
    );
}

static void extinguish_fire(void) {
    if (lung.fire_level == 0u) return;
    lung.fire_level = lung.fire_level > 25u ? lung.fire_level - 25u : 0u;
    if (lung.fire_level == 0u) {
        lung.hazard_ticks = 0u;
        set_message(MESSAGE_FIRE_OUT, 90u);
    }
}

static void begin_final_attack(void) {
    lung.event_flags |= EVENT_FINAL;
    lung.view = VIEW_ATTACK;
    lung.attack_ticks = 60u;
    lung.helm_active = 0u;
    draw_attack();
}

static void use_station(void) {
    uint8_t station;

    if (lung.helm_active) {
        lung.helm_active = 0u;
        return;
    }
    station = station_in_reach();
    if (station == STATION_HELM) {
        lung.helm_active = 1u;
        cabin_camera.position = (Vec3){0, 560, 384};
        cabin_camera.velocity = (Vec3){0, 0, 0};
        cabin_camera.yaw = 64u;
        cabin_camera.pitch = 0;
        rebuild_basis(&cabin_camera);
    } else if (station == STATION_CAMERA) {
        if (valid_photo_point() == 9u && documented_count() >= 9u) {
            begin_final_attack();
        } else {
            capture_photo();
        }
    } else if (station == STATION_EXTINGUISHER) {
        extinguish_fire();
    }
}

static uint8_t wait_for_deploy(void) {
    uint8_t previous = 0u;

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
    gfx_PrintString("ONE CABIN. TEN PHOTOGRAPHS.");
    set_text(UI_RED, 72, 145);
    gfx_PrintString("THE HATCH WILL BE WELDED.");
    set_text(UI_GREEN, 78, 181);
    gfx_PrintString("2ND: DESCEND   CLEAR: ABORT");
    gfx_SwapDraw();

    for (;;) {
        uint8_t current;

        kb_Scan();
        current = (uint8_t)(
            ((kb_Data[1] & kb_2nd) != 0u ? 1u : 0u) |
            ((kb_Data[6] & kb_Clear) != 0u ? 2u : 0u)
        );
        if ((current & 1u) != 0u && (previous & 1u) == 0u) return 1u;
        if ((current & 2u) != 0u) return 0u;
        previous = current;
    }
}

static uint8_t add_cabin_box(
    fixed_t x,
    fixed_t y,
    fixed_t z,
    fixed_t half_x,
    fixed_t half_y,
    fixed_t half_z,
    uint8_t color
) {
    return engine_spawn_static_box(
        (Vec3){x, y, z},
        (Vec3){half_x, half_y, half_z},
        CABIN_ROOM,
        color
    );
}

/* Twenty world-space rectangular meshes form the cabin.  Every visible
 * station now passes through T3D3's camera transform, near clipping, face
 * shading, depth sort, and material texture pass; none of these pieces can
 * address framebuffer memory from an off-screen UI coordinate. */
static uint8_t build_cabin_mesh(void) {
    uint8_t pipe;

    engine_static_scene_reset();
    if (!add_cabin_box(0, 620, 145, 520, 210, 145, UI_RED_DARK) ||
        !add_cabin_box(0, 455, 312, 500, 55, 28, UI_BROWN_DARK) ||
        !add_cabin_box(0, 1090, 500, 255, 26, 268, UI_RED) ||
        !add_cabin_box(0, 1055, 500, 210, 18, 220, UI_BROWN_DARK) ||
        !add_cabin_box(-350, 1025, 520, 46, 34, 188, UI_GREEN_DARK) ||
        !add_cabin_box(350, 1025, 520, 46, 34, 188, UI_GREEN) ||
        !add_cabin_box(0, 405, 365, 306, 24, 54, UI_GREEN_DARK) ||
        !add_cabin_box(0, -1070, 540, 292, 36, 212, UI_RED) ||
        !add_cabin_box(0, -1028, 540, 246, 18, 162, UI_BLACK) ||
        !add_cabin_box(-365, -930, 310, 70, 72, 70, UI_GREEN) ||
        !add_cabin_box(430, -920, 300, 58, 66, 188, UI_RED) ||
        !add_cabin_box(0, 0, 846, 112, 175, 28, UI_WHITE)) {
        return 0u;
    }

    for (pipe = 0u; pipe < 3u; ++pipe) {
        fixed_t height = (fixed_t)(190 + pipe * 250);
        uint8_t color = pipe == 1u ? UI_RED : UI_RED_DARK;

        if (!add_cabin_box(-775, 0, height, 24, 920, 38, color) ||
            !add_cabin_box(775, 0, height, 24, 920, 38, color)) {
            return 0u;
        }
    }
    if (!add_cabin_box(744, 30, 470, 25, 285, 220, UI_BROWN) ||
        !add_cabin_box(712, 30, 470, 12, 246, 182, UI_FLOOR)) {
        return 0u;
    }
    return 1u;
}

static uint8_t initialize_game(void) {
    if (!true3d_level_embedded_view(0u, &level) ||
        !engine_init(&cabin_camera, &level)) {
        return 0u;
    }
    build_cave();
    memset(&lung, 0, sizeof(lung));
    lung.x = 182 * FIXED_ONE + 77;
    lung.y = 116 * FIXED_ONE + 182;
    lung.heading_cdeg = 0u;
    lung.oxygen = 4u;
    lung.pressure = 4u;
    lung.last_scene = 0xFFu;
    lung.view = VIEW_CABIN;
    lung.map_cursor_x = 182u;
    lung.map_cursor_y = 116u;

    cabin_camera.position = (Vec3){0, -512, 384};
    cabin_camera.velocity = (Vec3){0, 0, 0};
    cabin_camera.room = CABIN_ROOM;
    cabin_camera.yaw = 64u;
    cabin_camera.pitch = 0;
    rebuild_basis(&cabin_camera);
    if (!build_cabin_mesh()) return 0u;
    update_sensors();
    return 1u;
}

static void initialize_palette(void) {
    engine_graphics_init();
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

int main(void) {
    clock_t previous_tick;
    uint24_t accumulated_ticks = 0u;
    const uint24_t update_ticks = (uint24_t)(CLOCKS_PER_SEC / UPDATE_RATE);

    gfx_Begin();
    gfx_SetDrawBuffer();
    initialize_palette();
    gfx_SetTextBGColor(UI_BLACK);
    gfx_SetTextTransparentColor(UI_BLACK);
    kb_SetMode(MODE_3_CONTINUOUS);
    if (!wait_for_deploy()) {
        kb_Reset();
        gfx_End();
        return 0;
    }
    while ((kb_Data[1] & kb_2nd) != 0u) kb_Scan();
    if (!initialize_game()) {
        gfx_FillScreen(UI_BLACK);
        set_text(UI_RED, 80, 112);
        gfx_PrintString("PRESSURE SYSTEM FAILURE");
        gfx_SwapDraw();
        while ((kb_Data[6] & kb_Clear) == 0u) kb_Scan();
        kb_Reset();
        gfx_End();
        return 1;
    }
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
            if ((pressed & (EDGE_USE | EDGE_BRIEFING)) != 0u) {
                lung.view = VIEW_CABIN;
                draw_cabin();
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

            if (lung.helm_active) {
                changed = update_navigation(
                    forward,
                    turn,
                    accumulated_ticks,
                    (uint24_t)CLOCKS_PER_SEC
                );
            } else if (forward != 0 || turn != 0) {
                changed = engine_update(
                    &cabin_camera,
                    forward,
                    turn,
                    0,
                    0u,
                    0u,
                    accumulated_ticks,
                    (uint24_t)CLOCKS_PER_SEC
                );
            } else {
                changed = 0u;
            }
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
            if (changed) draw_cabin();
            accumulated_ticks = 0u;
        }
    }

    kb_Reset();
    gfx_End();
    return 0;
}
