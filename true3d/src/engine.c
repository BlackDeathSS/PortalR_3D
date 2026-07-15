#include "engine.h"

#include <graphx.h>
#include <limits.h>
#include <string.h>

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)

#define BASE_RENDER_WIDTH 64
#define BASE_RENDER_HEIGHT 48
#define MAX_RENDER_WIDTH 320
#define MAX_RENDER_HEIGHT 240
#define VIEW_CENTER_X (BASE_RENDER_WIDTH / 2)
#define VIEW_CENTER_Y (BASE_RENDER_HEIGHT / 2)
#define PROJECTION_FOCAL 42
#define NEAR_PLANE 32
#define PROJECTED_LIMIT 1048576L
#define PROJECTION_TABLE_SHIFT 2
#define PROJECTION_TABLE_SIZE 2048
#define FAR_PROJECTION_TABLE_SHIFT 6
#define PROJECTION_SCALE_SHIFT 6
#define EDGE_RECIPROCAL_SHIFT 5
#define EDGE_RECIPROCAL_SIZE 1024
#define EDGE_STEP_PRECISION_SHIFT 12
#define NEAR_INTERSECTION_SHIFT 14

#define MAX_WORLD_VERTICES (TRUE3D_MAX_ROOMS * 8u)
#define MAX_WORLD_FACES (TRUE3D_MAX_ROOMS * ROOM_FACE_COUNT)
#define PORTAL_COUNT 2
#define ROOM_FACE_COUNT 6
#define MAX_POLYGON_VERTICES 10
#define MAX_DRAW_POLYGONS 8
#define PORTAL_RECURSION_MAX 4
#define RENDER_LAYER_COUNT (PORTAL_RECURSION_MAX + 1)
#define NO_PORTAL 255u
#define PORTAL_LOD_QUARTER_ENTER_AREA 160u
#define PORTAL_LOD_QUARTER_LEAVE_AREA 256u
#define PORTAL_LOD_HALF_ENTER_AREA 960u
#define PORTAL_LOD_FULL_ENTER_AREA 1280u
#define SHADED_PALETTE_FIRST 16u
#define SHADE_LEVEL_COUNT 4u

enum RenderMode {
    RENDER_MODE_320 = 0,
    RENDER_MODE_128 = 1,
    RENDER_MODE_64 = 2,
    RENDER_MODE_32 = 3,
    RENDER_MODE_COUNT = 4
};

#define MOVE_SPEED 640
#define TURN_UNITS_PER_SECOND 80u
#define PITCH_UNITS_PER_SECOND 72u
#define PITCH_LIMIT 64
#define GRAVITY 2560
#define JUMP_SPEED 1792
#define PLAYER_RADIUS 64
#define PLAYER_EYE_HEIGHT 384
#define CEILING_MARGIN 64
#define PORTAL_APERTURE_MARGIN PLAYER_RADIUS
#define PORTAL_HALF_WIDTH 384
#define PORTAL_HALF_HEIGHT 448

enum PaletteIndex {
    COLOR_BLACK = 0,
    COLOR_VOID = 1,
    COLOR_FLOOR_A = 2,
    COLOR_CEILING_A = 3,
    COLOR_WALL_GREEN = 4,
    COLOR_WALL_GREEN_DARK = 5,
    COLOR_FLOOR_B = 6,
    COLOR_CEILING_B = 7,
    COLOR_WALL_RED = 8,
    COLOR_WALL_RED_DARK = 9,
    COLOR_PORTAL_BLUE = 10,
    COLOR_PORTAL_ORANGE = 11,
    COLOR_HUD = 12
};

static const uint8_t base_palette_rgb[COLOR_HUD + 1u][3] = {
    {0, 0, 0},
    {12, 14, 25},
    {54, 57, 62},
    {32, 35, 48},
    {38, 205, 75},
    {24, 118, 52},
    {65, 57, 54},
    {48, 32, 35},
    {215, 52, 52},
    {125, 30, 34},
    {45, 105, 245},
    {240, 145, 28},
    {240, 240, 240}
};

static const uint8_t shade_numerator[SHADE_LEVEL_COUNT] = {9, 11, 14, 16};
static const uint8_t face_light_level[ROOM_FACE_COUNT] = {3, 2, 3, 2, 2, 1};

typedef struct __attribute__((packed)) {
    int16_t x;
    int16_t y;
    int16_t z;
} WorldVertex;

typedef struct __attribute__((packed)) {
    uint8_t vertex[4];
    uint8_t color;
    uint8_t portal;
} WorldFace;

typedef struct __attribute__((packed)) {
    uint8_t first_face;
    int16_t minimum_x;
    int16_t maximum_x;
    int16_t minimum_y;
    int16_t maximum_y;
    int16_t minimum_z;
    int16_t maximum_z;
} Room;

typedef struct {
    Vec3 center;
    Vec3 right;
    Vec3 up;
    Vec3 normal;
    fixed_t half_width;
    fixed_t half_height;
    uint8_t room;
    uint8_t host_face;
    uint8_t linked;
    uint8_t active;
} Portal;

typedef struct {
    Vec3 position;
    Vec3 right;
    Vec3 up;
    Vec3 forward;
    uint8_t room;
} Camera;

typedef struct {
    fixed_t x;
    fixed_t y;
    fixed_t depth;
} CameraPoint;

typedef struct {
    int24_t x;
    int24_t y;
} ScreenPoint;

typedef struct {
    ScreenPoint point[MAX_POLYGON_VERTICES];
    uint16_t span_left[MAX_RENDER_HEIGHT];
    uint16_t span_right[MAX_RENDER_HEIGHT];
    uint8_t count;
    uint8_t color;
    uint8_t portal;
    uint8_t face;
    uint8_t face_offset;
    uint8_t first_row;
    uint8_t last_row;
} DrawPolygon;

typedef struct {
    DrawPolygon polygon[MAX_DRAW_POLYGONS];
    uint16_t row_left[MAX_RENDER_HEIGHT];
    uint16_t row_right[MAX_RENDER_HEIGHT];
    uint8_t count;
    uint8_t solid_count;
    uint8_t first_row;
    uint8_t last_row;
    uint16_t bound_left;
    uint16_t bound_right;
    uint8_t lod_shift;
    uint24_t pixel_area;
    int16_t horizon_row;
    uint8_t horizon_valid;
} RenderLayer;

_Static_assert(MAX_RENDER_WIDTH == GFX_LCD_WIDTH, "Native render width mismatch");
_Static_assert(MAX_RENDER_HEIGHT == GFX_LCD_HEIGHT, "Native render height mismatch");
_Static_assert(
    SHADED_PALETTE_FIRST + (COLOR_HUD + 1u) * SHADE_LEVEL_COUNT <= 256u,
    "Shaded palette exceeds eight-bit indices"
);

static WorldVertex world_vertices[MAX_WORLD_VERTICES];
static WorldFace world_faces[MAX_WORLD_FACES];
static Room rooms[TRUE3D_MAX_ROOMS];
static uint8_t room_count;

static const Vec3 face_normals[ROOM_FACE_COUNT] = {
    {0, 0, 256},
    {0, 0, -256},
    {0, 256, 0},
    {0, -256, 0},
    {256, 0, 0},
    {-256, 0, 0}
};

static const Vec3 face_right_vectors[ROOM_FACE_COUNT] = {
    {256, 0, 0},
    {256, 0, 0},
    {-256, 0, 0},
    {256, 0, 0},
    {0, 256, 0},
    {0, -256, 0}
};

static const Vec3 face_up_vectors[ROOM_FACE_COUNT] = {
    {0, 256, 0},
    {0, -256, 0},
    {0, 0, 256},
    {0, 0, 256},
    {0, 0, 256},
    {0, 0, 256}
};

static const uint8_t box_face_vertices[ROOM_FACE_COUNT][4] = {
    {0, 3, 2, 1},
    {4, 5, 6, 7},
    {0, 1, 5, 4},
    {3, 7, 6, 2},
    {0, 4, 7, 3},
    {1, 2, 6, 5}
};

/* Quarter-wave Q8 sine table. Angles use 256 units per turn. */
static const int16_t quarter_sine[65] = {
    0, 6, 13, 19, 25, 31, 38, 44, 50, 56, 62, 68, 74, 80, 86, 92,
    98, 104, 109, 115, 121, 126, 132, 137, 142, 147, 152, 157, 162,
    167, 172, 177, 181, 185, 190, 194, 198, 202, 206, 209, 213, 216,
    220, 223, 226, 229, 231, 234, 237, 239, 241, 243, 245, 247, 248,
    250, 251, 252, 253, 254, 255, 255, 256, 256, 256
};

/* Portal 0 is vertical. Portal 1 lies on a ceiling. right x up = inward normal. */
static Portal portals[PORTAL_COUNT] = {
    {
        {0 * 256, 10 * 256, 640},
        {256, 0, 0},
        {0, 0, 256},
        {0, -256, 0},
        384,
        448,
        0,
        3,
        1,
        1
    },
    {
        {12 * 256, 4 * 256, 5 * 256},
        {256, 0, 0},
        {0, -256, 0},
        {0, 0, -256},
        384,
        448,
        1,
        7,
        0,
        1
    }
};

static CameraPoint camera_vertices[MAX_WORLD_VERTICES];
static ScreenPoint screen_vertices[MAX_WORLD_VERTICES];
static uint8_t vertex_outcode[MAX_WORLD_VERTICES];
static CameraPoint clip_input[MAX_POLYGON_VERTICES];
static CameraPoint clip_output[MAX_POLYGON_VERTICES];
static RenderLayer render_layers[RENDER_LAYER_COUNT];
static int24_t span_left[MAX_RENDER_HEIGHT];
static int24_t span_right[MAX_RENDER_HEIGHT];
static uint16_t projection_scale_table[PROJECTION_TABLE_SIZE];
static uint16_t far_projection_scale_table[PROJECTION_TABLE_SIZE];
static uint16_t edge_reciprocal_table[EDGE_RECIPROCAL_SIZE];
static uint8_t portal_lod_state[PORTAL_RECURSION_MAX][PORTAL_COUNT];
static uint8_t *render_target;
static uint16_t active_render_width;
static uint8_t active_render_height;
static uint8_t active_render_mode;
static uint8_t active_portal_recursion;
static uint8_t active_horizon_near_limit;
static uint8_t active_horizon_far_limit;

_Static_assert(
    sizeof(camera_vertices) + sizeof(screen_vertices) +
        sizeof(vertex_outcode) + sizeof(clip_input) + sizeof(clip_output) +
        sizeof(render_layers) + sizeof(span_left) + sizeof(span_right) +
        sizeof(portal_lod_state) +
        sizeof(render_target) +
        sizeof(active_render_width) + sizeof(active_render_height) +
        sizeof(active_render_mode) + sizeof(active_portal_recursion) +
        sizeof(active_horizon_near_limit) +
        sizeof(active_horizon_far_limit) +
        sizeof(projection_scale_table) + sizeof(far_projection_scale_table) +
        sizeof(edge_reciprocal_table) +
        sizeof(world_vertices) + sizeof(world_faces) + sizeof(rooms) < 60600u,
    "True-3D render scratch exceeded the CEdev BSS partition"
);

static fixed_t fixed_mul(fixed_t left, fixed_t right) {
    return (fixed_t)(((int32_t)left * right) >> FIXED_SHIFT);
}

static fixed_t fixed_absolute(fixed_t value) {
    return value < 0 ? -value : value;
}

static fixed_t angle_sine(uint8_t angle) {
    uint8_t quadrant = angle >> 6;
    uint8_t offset = angle & 63u;

    if (quadrant == 0) return quarter_sine[offset];
    if (quadrant == 1) return quarter_sine[64u - offset];
    if (quadrant == 2) return -quarter_sine[offset];
    return -quarter_sine[64u - offset];
}

static void rebuild_camera_basis(EngineState *state) {
    uint8_t pitch_magnitude = (uint8_t)(state->pitch < 0 ? -state->pitch : state->pitch);
    fixed_t sine_yaw = angle_sine(state->yaw);
    fixed_t cosine_yaw = angle_sine((uint8_t)(state->yaw + 64u));
    fixed_t sine_pitch = quarter_sine[pitch_magnitude];
    fixed_t cosine_pitch = quarter_sine[64u - pitch_magnitude];

    if (state->pitch < 0) sine_pitch = -sine_pitch;
    state->right.x = -sine_yaw;
    state->right.y = cosine_yaw;
    state->right.z = 0;
    state->forward.x = fixed_mul(cosine_pitch, cosine_yaw);
    state->forward.y = fixed_mul(cosine_pitch, sine_yaw);
    state->forward.z = sine_pitch;
    state->up.x = -fixed_mul(sine_pitch, cosine_yaw);
    state->up.y = -fixed_mul(sine_pitch, sine_yaw);
    state->up.z = cosine_pitch;
}

static Vec3 vec_add(Vec3 left, Vec3 right) {
    Vec3 result = {left.x + right.x, left.y + right.y, left.z + right.z};
    return result;
}

static Vec3 vec_subtract(Vec3 left, Vec3 right) {
    Vec3 result = {left.x - right.x, left.y - right.y, left.z - right.z};
    return result;
}

static Vec3 vec_scale(Vec3 vector, fixed_t scale) {
    Vec3 result = {
        fixed_mul(vector.x, scale),
        fixed_mul(vector.y, scale),
        fixed_mul(vector.z, scale)
    };
    return result;
}

/* Portal face bases are signed world axes, so these avoid fixed-point matrix multiplies. */
static fixed_t signed_axis_component(Vec3 vector, Vec3 axis) {
    if (axis.x != 0) return axis.x > 0 ? vector.x : -vector.x;
    if (axis.y != 0) return axis.y > 0 ? vector.y : -vector.y;
    return axis.z > 0 ? vector.z : -vector.z;
}

static void add_signed_axis(Vec3 *vector, Vec3 axis, fixed_t amount) {
    if (axis.x != 0) {
        vector->x += axis.x > 0 ? amount : -amount;
    } else if (axis.y != 0) {
        vector->y += axis.y > 0 ? amount : -amount;
    } else {
        vector->z += axis.z > 0 ? amount : -amount;
    }
}

static fixed_t vec_dot(Vec3 left, Vec3 right) {
    return (fixed_t)(
        ((int32_t)left.x * right.x +
         (int32_t)left.y * right.y +
         (int32_t)left.z * right.z) >> FIXED_SHIFT
    );
}

static Vec3 world_vertex(uint8_t index) {
    Vec3 result = {
        world_vertices[index].x,
        world_vertices[index].y,
        world_vertices[index].z
    };
    return result;
}

static CameraPoint transform_point(const Camera *camera, Vec3 point) {
    Vec3 relative = vec_subtract(point, camera->position);
    CameraPoint result = {
        vec_dot(relative, camera->right),
        vec_dot(relative, camera->up),
        vec_dot(relative, camera->forward)
    };
    return result;
}

static int24_t scale_projected_coordinate(int32_t value, uint16_t limit) {
    int32_t scaled;

    if (active_render_mode == RENDER_MODE_320) {
        scaled = value * 5;
    } else if (active_render_mode == RENDER_MODE_128) {
        scaled = value << 1;
    } else if (active_render_mode == RENDER_MODE_32) {
        scaled = value >> 1;
    } else {
        scaled = value;
    }
    if (scaled < 0) return 0;
    if (scaled > (int32_t)limit * FIXED_ONE) {
        return (int24_t)limit * FIXED_ONE;
    }
    return (int24_t)scaled;
}

static int16_t scale_base_row(int16_t row) {
    if (active_render_mode == RENDER_MODE_320) return row * 5;
    if (active_render_mode == RENDER_MODE_128) return row * 2;
    if (active_render_mode == RENDER_MODE_32) return row >> 1;
    return row;
}

static uint16_t projection_scale_for_depth(fixed_t depth) {
    uint24_t index;

    if (depth >= (fixed_t)(PROJECTION_TABLE_SIZE << PROJECTION_TABLE_SHIFT)) {
        index = (uint24_t)depth >> FAR_PROJECTION_TABLE_SHIFT;
        if (index >= PROJECTION_TABLE_SIZE) index = PROJECTION_TABLE_SIZE - 1;
        return far_projection_scale_table[index];
    }
    index = (uint24_t)depth >> PROJECTION_TABLE_SHIFT;
    if (index == 0) index = 1;
    if (index >= PROJECTION_TABLE_SIZE) index = PROJECTION_TABLE_SIZE - 1;
    return projection_scale_table[index];
}

static ScreenPoint project_camera_point(const CameraPoint *point) {
    uint16_t scale = projection_scale_for_depth(point->depth);
    int32_t projected_x =
        VIEW_CENTER_X * FIXED_ONE +
        (((int32_t)point->x * scale) >> PROJECTION_SCALE_SHIFT);
    int32_t projected_y =
        VIEW_CENTER_Y * FIXED_ONE -
        (((int32_t)point->y * scale) >> PROJECTION_SCALE_SHIFT);
    ScreenPoint result = {
        scale_projected_coordinate(projected_x, active_render_width),
        scale_projected_coordinate(projected_y, active_render_height)
    };
    return result;
}

static int32_t clip_plane_distance(const CameraPoint *point, uint8_t plane) {
    if (plane == 0) return (int32_t)point->depth - NEAR_PLANE;
    if (plane == 1) return (int32_t)PROJECTION_FOCAL * point->x +
        (int32_t)VIEW_CENTER_X * point->depth;
    if (plane == 2) return (int32_t)VIEW_CENTER_X * point->depth -
        (int32_t)PROJECTION_FOCAL * point->x;
    if (plane == 3) return (int32_t)VIEW_CENTER_Y * point->depth -
        (int32_t)PROJECTION_FOCAL * point->y;
    return (int32_t)VIEW_CENTER_Y * point->depth +
        (int32_t)PROJECTION_FOCAL * point->y;
}

static uint8_t camera_point_outcode(const CameraPoint *point) {
    uint8_t code = 0;
    uint8_t plane;
    for (plane = 0; plane < 5; ++plane) {
        if (clip_plane_distance(point, plane) < 0) code |= (uint8_t)(1u << plane);
    }
    return code;
}

static CameraPoint intersect_clip_plane(
    CameraPoint outside,
    CameraPoint inside,
    int32_t outside_plane_distance,
    int32_t inside_plane_distance,
    uint8_t plane
) {
    uint32_t outside_distance = (uint32_t)-outside_plane_distance;
    uint32_t inside_distance = (uint32_t)inside_plane_distance;
    uint32_t denominator;
    int32_t fraction;
    CameraPoint result;

    while (outside_distance > 65535u || inside_distance > 65535u) {
        outside_distance >>= 1;
        inside_distance >>= 1;
    }
    denominator = outside_distance + inside_distance;
    if (denominator == 0) return inside;
    fraction = (int32_t)(
        (outside_distance * (1u << NEAR_INTERSECTION_SHIFT) + denominator / 2u) /
        denominator
    );
    result.x = outside.x + (fixed_t)(
        (((int32_t)inside.x - outside.x) * fraction) >> NEAR_INTERSECTION_SHIFT
    );
    result.y = outside.y + (fixed_t)(
        (((int32_t)inside.y - outside.y) * fraction) >> NEAR_INTERSECTION_SHIFT
    );
    result.depth = outside.depth + (fixed_t)(
        (((int32_t)inside.depth - outside.depth) * fraction) >>
        NEAR_INTERSECTION_SHIFT
    );
    if (plane == 0) result.depth = NEAR_PLANE;
    return result;
}

static uint8_t clip_and_project(
    const CameraPoint *source,
    uint8_t source_count,
    DrawPolygon *polygon
) {
    CameraPoint *input = clip_input;
    CameraPoint *output = clip_output;
    uint8_t input_count = source_count;
    uint8_t output_count;
    uint8_t index;
    uint8_t plane;

    if (source_count < 3 || source_count > MAX_POLYGON_VERTICES) return 0;
    memcpy(clip_input, source, (size_t)source_count * sizeof(CameraPoint));
    for (plane = 0; plane < 5; ++plane) {
        output_count = 0;
        for (index = 0; index < input_count; ++index) {
            const CameraPoint *current = &input[index];
            const CameraPoint *previous = &input[
                index == 0 ? input_count - 1 : index - 1
            ];
            int32_t current_distance = clip_plane_distance(current, plane);
            int32_t previous_distance = clip_plane_distance(previous, plane);
            uint8_t current_inside = current_distance >= 0;
            uint8_t previous_inside = previous_distance >= 0;

            if (current_inside != previous_inside) {
                CameraPoint intersection = previous_inside ?
                    intersect_clip_plane(
                        *current, *previous, current_distance, previous_distance, plane
                    ) :
                    intersect_clip_plane(
                        *previous, *current, previous_distance, current_distance, plane
                    );
                if (output_count >= MAX_POLYGON_VERTICES) return 0;
                output[output_count++] = intersection;
            }
            if (current_inside) {
                if (output_count >= MAX_POLYGON_VERTICES) return 0;
                output[output_count++] = *current;
            }
        }
        if (output_count < 3) return 0;
        input_count = output_count;
        {
            CameraPoint *swap = input;
            input = output;
            output = swap;
        }
    }

    for (index = 0; index < input_count; ++index) {
        const CameraPoint *point = &input[index];
        polygon->point[index] = project_camera_point(point);
    }
    polygon->count = input_count;
    return 1;
}

static uint8_t polygon_intersects_layer(
    const DrawPolygon *polygon,
    const RenderLayer *layer
) {
    int24_t minimum_x = polygon->point[0].x;
    int24_t maximum_x = minimum_x;
    int24_t minimum_y = polygon->point[0].y;
    int24_t maximum_y = minimum_y;
    uint16_t bound_left = layer->bound_left;
    uint16_t bound_right = layer->bound_right;
    uint8_t first_row = layer->first_row;
    uint8_t last_row = layer->last_row;
    uint8_t index;

    for (index = 1; index < polygon->count; ++index) {
        if (polygon->point[index].x < minimum_x) minimum_x = polygon->point[index].x;
        if (polygon->point[index].x > maximum_x) maximum_x = polygon->point[index].x;
        if (polygon->point[index].y < minimum_y) minimum_y = polygon->point[index].y;
        if (polygon->point[index].y > maximum_y) maximum_y = polygon->point[index].y;
    }
    if (layer->lod_shift != 0) {
        bound_left = (bound_left >> layer->lod_shift) << layer->lod_shift;
        bound_right = (uint16_t)(
            (((bound_right >> layer->lod_shift) + 1u) << layer->lod_shift) - 1u
        );
        first_row = (first_row >> layer->lod_shift) << layer->lod_shift;
        last_row = (uint8_t)(
            (((last_row >> layer->lod_shift) + 1u) << layer->lod_shift) - 1u
        );
        if (bound_right >= active_render_width) bound_right = active_render_width - 1u;
        if (last_row >= active_render_height) last_row = active_render_height - 1u;
    }
    return (uint8_t)(
        layer->first_row <= layer->last_row &&
        maximum_x >= (int24_t)bound_left * FIXED_ONE &&
        minimum_x < (int24_t)(bound_right + 1u) * FIXED_ONE &&
        maximum_y >= (int24_t)first_row * FIXED_ONE &&
        minimum_y < (int24_t)(last_row + 1u) * FIXED_ONE
    );
}

static CameraPoint camera_point_add(CameraPoint left, CameraPoint right) {
    CameraPoint result = {
        left.x + right.x,
        left.y + right.y,
        left.depth + right.depth
    };
    return result;
}

static void transform_world_vertices(const Camera *camera) {
    const Room *room = &rooms[camera->room];
    Vec3 minimum = {room->minimum_x, room->minimum_y, room->minimum_z};
    fixed_t extent_x = room->maximum_x - room->minimum_x;
    fixed_t extent_y = room->maximum_y - room->minimum_y;
    fixed_t extent_z = room->maximum_z - room->minimum_z;
    CameraPoint base = transform_point(camera, minimum);
    CameraPoint edge_x = {
        fixed_mul(extent_x, camera->right.x),
        fixed_mul(extent_x, camera->up.x),
        fixed_mul(extent_x, camera->forward.x)
    };
    CameraPoint edge_y = {
        fixed_mul(extent_y, camera->right.y),
        fixed_mul(extent_y, camera->up.y),
        fixed_mul(extent_y, camera->forward.y)
    };
    CameraPoint edge_z = {
        fixed_mul(extent_z, camera->right.z),
        fixed_mul(extent_z, camera->up.z),
        fixed_mul(extent_z, camera->forward.z)
    };
    uint8_t index;
    uint8_t first = camera->room * 8u;
    uint8_t end = first + 8u;

    camera_vertices[first] = base;
    camera_vertices[first + 1] = camera_point_add(base, edge_x);
    camera_vertices[first + 3] = camera_point_add(base, edge_y);
    camera_vertices[first + 2] = camera_point_add(camera_vertices[first + 1], edge_y);
    camera_vertices[first + 4] = camera_point_add(base, edge_z);
    camera_vertices[first + 5] = camera_point_add(camera_vertices[first + 1], edge_z);
    camera_vertices[first + 7] = camera_point_add(camera_vertices[first + 3], edge_z);
    camera_vertices[first + 6] = camera_point_add(camera_vertices[first + 2], edge_z);
    for (index = first; index < end; ++index) {
        vertex_outcode[index] = camera_point_outcode(&camera_vertices[index]);
        if (vertex_outcode[index] == 0) {
            screen_vertices[index] = project_camera_point(&camera_vertices[index]);
        }
    }
}

static uint8_t rasterize_polygon(
    DrawPolygon *polygon,
    const RenderLayer *layer
);

static uint8_t append_face_polygon(
    RenderLayer *layer,
    uint8_t face_index,
    uint8_t face_offset
) {
    const WorldFace *face = &world_faces[face_index];
    CameraPoint point[4];
    DrawPolygon *polygon;
    uint8_t index;
    uint8_t combined_outcode = 0;
    uint8_t shared_outcode = 31u;

    if (layer->count >= MAX_DRAW_POLYGONS) return 0;
    polygon = &layer->polygon[layer->count];
    for (index = 0; index < 4; ++index) {
        uint8_t vertex = face->vertex[index];
        point[index] = camera_vertices[vertex];
        combined_outcode |= vertex_outcode[vertex];
        shared_outcode &= vertex_outcode[vertex];
        if (vertex_outcode[vertex] == 0) {
            polygon->point[index] = screen_vertices[vertex];
        }
    }
    if (shared_outcode != 0) return 0;
    if (combined_outcode == 0) {
        polygon->count = 4;
    } else if (!clip_and_project(point, 4, polygon)) {
        return 0;
    }
    if (!polygon_intersects_layer(polygon, layer)) return 0;
    polygon->color = face->color;
    polygon->portal = NO_PORTAL;
    polygon->face = face_index;
    polygon->face_offset = face_offset;
    if (!rasterize_polygon(polygon, layer)) return 0;
    ++layer->count;
    return 1;
}

static CameraPoint camera_axis_scaled(
    const Camera *camera,
    Vec3 axis,
    fixed_t scale
) {
    CameraPoint result = {
        fixed_mul(signed_axis_component(camera->right, axis), scale),
        fixed_mul(signed_axis_component(camera->up, axis), scale),
        fixed_mul(signed_axis_component(camera->forward, axis), scale)
    };
    return result;
}

static void append_portal_polygon(
    RenderLayer *layer,
    const Camera *camera,
    uint8_t portal_index
) {
    const Portal *portal = &portals[portal_index];
    CameraPoint point[4];
    CameraPoint center;
    CameraPoint horizontal;
    CameraPoint vertical;
    DrawPolygon *polygon;

    if (layer->count >= MAX_DRAW_POLYGONS) return;
    center = transform_point(camera, portal->center);
    horizontal = camera_axis_scaled(camera, portal->right, portal->half_width);
    vertical = camera_axis_scaled(camera, portal->up, portal->half_height);
    point[0] = (CameraPoint){
        center.x - horizontal.x - vertical.x,
        center.y - horizontal.y - vertical.y,
        center.depth - horizontal.depth - vertical.depth
    };
    point[1] = (CameraPoint){
        center.x + horizontal.x - vertical.x,
        center.y + horizontal.y - vertical.y,
        center.depth + horizontal.depth - vertical.depth
    };
    point[2] = (CameraPoint){
        center.x + horizontal.x + vertical.x,
        center.y + horizontal.y + vertical.y,
        center.depth + horizontal.depth + vertical.depth
    };
    point[3] = (CameraPoint){
        center.x - horizontal.x + vertical.x,
        center.y - horizontal.y + vertical.y,
        center.depth - horizontal.depth + vertical.depth
    };
    polygon = &layer->polygon[layer->count];
    if (!clip_and_project(point, 4, polygon)) return;
    if (!polygon_intersects_layer(polygon, layer)) return;
    polygon->color = portal_index == 0 ? COLOR_PORTAL_ORANGE : COLOR_PORTAL_BLUE;
    polygon->portal = portal_index;
    polygon->face = portal->host_face;
    polygon->face_offset = NO_PORTAL;
    if (!rasterize_polygon(polygon, layer)) return;
    ++layer->count;
}

static void collect_room_polygons(
    RenderLayer *layer,
    const Camera *camera,
    uint8_t skipped_face,
    uint8_t allow_portals
) {
    const Room *room = &rooms[camera->room];
    uint8_t face_added[ROOM_FACE_COUNT] = {0, 0, 0, 0, 0, 0};
    uint8_t offset;
    uint8_t portal_index;

    layer->count = 0;
    layer->horizon_valid = (uint8_t)(
        fixed_absolute(camera->right.z) <= 8 &&
        fixed_absolute(camera->up.z) >= 64
    );
    if (layer->horizon_valid) {
        fixed_t vertical_depth = fixed_absolute(camera->up.z);
        fixed_t signed_forward = camera->up.z < 0 ?
            -camera->forward.z : camera->forward.z;
        int24_t horizon_offset = (int24_t)(
            ((int32_t)signed_forward * projection_scale_for_depth(vertical_depth)) >>
            (PROJECTION_SCALE_SHIFT + FIXED_SHIFT)
        );
        layer->horizon_row = scale_base_row(
            (int16_t)(VIEW_CENTER_Y + horizon_offset)
        );
    }
    transform_world_vertices(camera);
    for (offset = 0; offset < ROOM_FACE_COUNT; ++offset) {
        uint8_t face_index = room->first_face + offset;

        if (face_index == skipped_face) continue;
        face_added[offset] = append_face_polygon(layer, face_index, offset);
    }
    layer->solid_count = layer->count;
    if (!allow_portals) return;
    /* Append apertures after every solid face so recursion cannot be overdrawn. */
    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const Portal *portal = &portals[portal_index];
        uint8_t host_offset;
        if (!portal->active || !portals[portal->linked].active ||
            portal->room != camera->room || portal->host_face < room->first_face) {
            continue;
        }
        host_offset = portal->host_face - room->first_face;
        if (host_offset < ROOM_FACE_COUNT && face_added[host_offset]) {
            append_portal_polygon(layer, camera, portal_index);
        }
    }
}

static int16_t floor_q8(int24_t value) {
    if (value >= 0) return (int16_t)(value / FIXED_ONE);
    return (int16_t)-(((-value) + FIXED_ONE - 1) / FIXED_ONE);
}

static int16_t ceil_q8(int24_t value) {
    if (value >= 0) return (int16_t)((value + FIXED_ONE - 1) / FIXED_ONE);
    return (int16_t)-((-value) / FIXED_ONE);
}

static int32_t edge_x_step(int24_t delta_x, int24_t delta_y) {
    uint24_t index = ((uint24_t)delta_y +
        (1u << (EDGE_RECIPROCAL_SHIFT - 1))) >> EDGE_RECIPROCAL_SHIFT;

    if (delta_y < FIXED_ONE || index >= EDGE_RECIPROCAL_SIZE) {
        return ((int32_t)delta_x * FIXED_ONE) / delta_y;
    }
    return ((int32_t)delta_x * edge_reciprocal_table[index]) >>
        EDGE_STEP_PRECISION_SHIFT;
}

static uint8_t rasterize_polygon(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    uint8_t step = (uint8_t)(1u << layer->lod_shift);
    uint8_t sample_origin = step >> 1;
    uint8_t index;
    int24_t minimum_y = polygon->point[0].y;
    int24_t maximum_y = minimum_y;
    int16_t first_row;
    int16_t last_row;
    int16_t row;
    uint8_t any = 0;

    for (index = 1; index < polygon->count; ++index) {
        if (polygon->point[index].y < minimum_y) minimum_y = polygon->point[index].y;
        if (polygon->point[index].y > maximum_y) maximum_y = polygon->point[index].y;
    }
    first_row = ceil_q8(minimum_y - FIXED_ONE / 2);
    last_row = floor_q8(maximum_y - 1 - FIXED_ONE / 2);
    if (layer->lod_shift == 0) {
        if (first_row < layer->first_row) first_row = layer->first_row;
        if (last_row > layer->last_row) last_row = layer->last_row;
    } else {
        int16_t clip_first =
            ((int16_t)layer->first_row >> layer->lod_shift) * step + sample_origin;
        int16_t clip_last =
            ((int16_t)layer->last_row >> layer->lod_shift) * step + sample_origin;
        if (first_row < clip_first) first_row = clip_first;
        if (last_row > clip_last) last_row = clip_last;
    }
    if (first_row < 0) first_row = 0;
    if (last_row >= active_render_height) last_row = active_render_height - 1;
    if (first_row <= sample_origin) {
        first_row = sample_origin;
    } else {
        first_row = sample_origin +
            (((first_row - sample_origin + step - 1u) >> layer->lod_shift) <<
             layer->lod_shift);
    }
    if (last_row < sample_origin) return 0;
    last_row = sample_origin +
        (((last_row - sample_origin) >> layer->lod_shift) << layer->lod_shift);
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; row += step) {
        span_left[row] = PROJECTED_LIMIT + 1;
        span_right[row] = -PROJECTED_LIMIT - 1;
    }
    for (index = 0; index < polygon->count; ++index) {
        ScreenPoint a = polygon->point[index];
        ScreenPoint b = polygon->point[
            index + 1 == polygon->count ? 0 : index + 1
        ];
        int24_t delta_x;
        int24_t delta_y;
        int32_t x_step;
        int32_t x_value;
        int16_t edge_first;
        int16_t edge_last;
        int16_t current_row;

        if (a.y == b.y) continue;
        if (a.y > b.y) {
            ScreenPoint swap = a;
            a = b;
            b = swap;
        }
        delta_x = (int24_t)b.x - a.x;
        delta_y = (int24_t)b.y - a.y;
        edge_first = ceil_q8((int24_t)a.y - FIXED_ONE / 2);
        edge_last = floor_q8((int24_t)b.y - 1 - FIXED_ONE / 2);
        if (edge_first < first_row) edge_first = first_row;
        if (edge_last > last_row) edge_last = last_row;
        if (edge_first <= sample_origin) {
            edge_first = sample_origin;
        } else {
            edge_first = sample_origin +
                (((edge_first - sample_origin + step - 1u) >> layer->lod_shift) <<
                 layer->lod_shift);
        }
        if (edge_first > edge_last) continue;

        x_step = edge_x_step(delta_x, delta_y);
        {
            int24_t sample_delta =
                (int24_t)edge_first * FIXED_ONE + FIXED_ONE / 2 - a.y;
            int32_t fraction = (
                ((int32_t)sample_delta << NEAR_INTERSECTION_SHIFT) +
                delta_y / 2
            ) / delta_y;
            x_value = a.x + (int32_t)(
                ((int32_t)delta_x * fraction) >> NEAR_INTERSECTION_SHIFT
            );
        }
        for (current_row = edge_first; current_row <= edge_last; current_row += step) {
            if (x_value < span_left[current_row]) {
                span_left[current_row] = (int24_t)x_value;
            }
            if (x_value > span_right[current_row]) {
                span_right[current_row] = (int24_t)x_value;
            }
            if (current_row + step <= edge_last) x_value += x_step * step;
        }
    }

    polygon->first_row = (uint8_t)first_row;
    polygon->last_row = (uint8_t)last_row;
    for (row = first_row; row <= last_row; row += step) {
        int16_t first_column;
        int16_t last_column;

        if (span_left[row] == PROJECTED_LIMIT + 1) {
            polygon->span_left[row] = UINT16_MAX;
            polygon->span_right[row] = 0;
            continue;
        }
        first_column = ceil_q8((int24_t)span_left[row] - FIXED_ONE / 2);
        last_column = floor_q8((int24_t)span_right[row] - FIXED_ONE / 2);
        if (first_column < 0) first_column = 0;
        if (last_column >= active_render_width) last_column = active_render_width - 1;
        if (first_column <= last_column) {
            polygon->span_left[row] = (uint16_t)first_column;
            polygon->span_right[row] = (uint16_t)last_column;
            if (layer->lod_shift != 0 ||
                (row >= layer->first_row && row <= layer->last_row &&
                 last_column >= layer->row_left[row] &&
                 first_column <= layer->row_right[row])) {
                any = 1;
            }
        } else {
            polygon->span_left[row] = UINT16_MAX;
            polygon->span_right[row] = 0;
        }
    }
    return any;
}

static void write_frame_span(
    uint8_t row,
    int16_t first_column,
    int16_t last_column,
    uint8_t color
) {
    if (first_column <= last_column) {
        uint16_t physical_left;
        uint16_t physical_right;
        uint16_t physical_top;
        uint16_t physical_bottom;
        uint16_t physical_row;

        if (active_render_mode == RENDER_MODE_320) {
            physical_left = (uint16_t)first_column;
            physical_right = (uint16_t)last_column;
            physical_top = row;
            physical_bottom = row;
        } else if (active_render_mode == RENDER_MODE_128) {
            physical_left = ((uint16_t)first_column * 5u) >> 1;
            physical_right =
                ((((uint16_t)last_column + 1u) * 5u) >> 1) - 1u;
            physical_top = ((uint16_t)row * 5u) >> 1;
            physical_bottom = ((((uint16_t)row + 1u) * 5u) >> 1) - 1u;
        } else {
            uint8_t scale = active_render_mode == RENDER_MODE_64 ? 5u : 10u;
            physical_left = (uint16_t)first_column * scale;
            physical_right = ((uint16_t)last_column + 1u) * scale - 1u;
            physical_top = (uint16_t)row * scale;
            physical_bottom = ((uint16_t)row + 1u) * scale - 1u;
        }
        for (physical_row = physical_top;
             physical_row <= physical_bottom;
             ++physical_row) {
            memset(
                &render_target[(uint24_t)physical_row * GFX_LCD_WIDTH + physical_left],
                color,
                (size_t)(physical_right - physical_left + 1u)
            );
        }
    }
}

static __attribute__((always_inline)) inline uint8_t face_color_for_row(
    const DrawPolygon *polygon,
    const RenderLayer *layer,
    uint8_t row
) {
    uint8_t light = face_light_level[polygon->face_offset];

    if (polygon->face_offset <= 1u && layer->horizon_valid) {
        int16_t signed_distance = (int16_t)row - layer->horizon_row;
        uint16_t distance;
        if (signed_distance < 0) signed_distance = -signed_distance;
        distance = (uint16_t)signed_distance;
        if (distance < active_horizon_near_limit) {
            light = light > 1u ? light - 2u : 0u;
        } else if (distance < active_horizon_far_limit && light != 0) {
            --light;
        }
    }
    return polygon->color + light;
}

static void fill_polygon(const DrawPolygon *polygon, const RenderLayer *layer) {
    uint8_t aperture_index[PORTAL_COUNT];
    uint8_t aperture_count = 0;
    uint8_t index;
    uint8_t row;

    for (index = layer->solid_count;
         index < layer->count && aperture_count < PORTAL_COUNT;
         ++index) {
        const DrawPolygon *aperture = &layer->polygon[index];
        if (aperture->portal != NO_PORTAL &&
            portals[aperture->portal].host_face == polygon->face) {
            aperture_index[aperture_count++] = index;
        }
    }
    if (aperture_count == 0) {
        for (row = polygon->first_row; row <= polygon->last_row; ++row) {
            int16_t first_column;
            int16_t last_column;
            if (polygon->span_left[row] > polygon->span_right[row] ||
                row < layer->first_row || row > layer->last_row) {
                continue;
            }
            first_column = polygon->span_left[row];
            last_column = polygon->span_right[row];
            if (first_column < layer->row_left[row]) first_column = layer->row_left[row];
            if (last_column > layer->row_right[row]) last_column = layer->row_right[row];
            write_frame_span(
                row,
                first_column,
                last_column,
                face_color_for_row(polygon, layer, row)
            );
        }
        return;
    }
    for (row = polygon->first_row; row <= polygon->last_row; ++row) {
        int16_t first_column;
        int16_t last_column;
        uint16_t hole_left[PORTAL_COUNT];
        uint16_t hole_right[PORTAL_COUNT];
        uint8_t hole_count = 0;
        uint8_t aperture_number;
        uint8_t row_color;
        int16_t cursor;

        if (polygon->span_left[row] > polygon->span_right[row] ||
            row < layer->first_row || row > layer->last_row) {
            continue;
        }
        first_column = polygon->span_left[row];
        last_column = polygon->span_right[row];
        if (first_column < layer->row_left[row]) first_column = layer->row_left[row];
        if (last_column > layer->row_right[row]) last_column = layer->row_right[row];
        if (first_column > last_column) continue;
        row_color = face_color_for_row(polygon, layer, row);

        /* The only systematic overdraw in a convex room is its portal host wall. */
        for (aperture_number = 0;
             aperture_number < aperture_count && hole_count < PORTAL_COUNT;
             ++aperture_number) {
            const DrawPolygon *aperture =
                &layer->polygon[aperture_index[aperture_number]];
            int16_t left;
            int16_t right;
            if (row < aperture->first_row || row > aperture->last_row ||
                aperture->span_left[row] > aperture->span_right[row]) {
                continue;
            }
            left = aperture->span_left[row];
            right = aperture->span_right[row];
            if (left < first_column) left = first_column;
            if (right > last_column) right = last_column;
            if (left <= right) {
                hole_left[hole_count] = (uint16_t)left;
                hole_right[hole_count] = (uint16_t)right;
                ++hole_count;
            }
        }
        if (hole_count == 2 && hole_left[1] < hole_left[0]) {
            uint16_t swap = hole_left[0];
            hole_left[0] = hole_left[1];
            hole_left[1] = swap;
            swap = hole_right[0];
            hole_right[0] = hole_right[1];
            hole_right[1] = swap;
        }
        cursor = first_column;
        for (aperture_number = 0; aperture_number < hole_count; ++aperture_number) {
            if (hole_right[aperture_number] < cursor) continue;
            write_frame_span(
                row,
                cursor,
                (int16_t)hole_left[aperture_number] - 1,
                row_color
            );
            cursor = (int16_t)hole_right[aperture_number] + 1;
            if (cursor > last_column) break;
        }
        write_frame_span(row, cursor, last_column, row_color);
    }
}

static uint8_t build_portal_clip(
    const DrawPolygon *portal_polygon,
    const RenderLayer *parent,
    RenderLayer *child,
    uint8_t child_depth
) {
    uint8_t row;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t any = 0;

    memset(child->row_left, 255, sizeof(child->row_left));
    memset(child->row_right, 0, sizeof(child->row_right));
    child->first_row = active_render_height;
    child->last_row = 0;
    child->bound_left = active_render_width;
    child->bound_right = 0;
    child->pixel_area = 0;
    first_row = portal_polygon->first_row > parent->first_row ?
        portal_polygon->first_row : parent->first_row;
    last_row = portal_polygon->last_row < parent->last_row ?
        portal_polygon->last_row : parent->last_row;
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; ++row) {
        uint16_t first_column;
        uint16_t last_column;
        if (portal_polygon->span_left[row] > portal_polygon->span_right[row] ||
            parent->row_left[row] > parent->row_right[row]) {
            continue;
        }
        first_column = portal_polygon->span_left[row];
        last_column = portal_polygon->span_right[row];
        if (first_column < parent->row_left[row]) first_column = parent->row_left[row];
        if (last_column > parent->row_right[row]) last_column = parent->row_right[row];
        if (first_column > last_column) continue;

        child->row_left[row] = first_column;
        child->row_right[row] = last_column;
        child->pixel_area += (uint24_t)(last_column - first_column + 1u);
        if (!any || row < child->first_row) child->first_row = row;
        if (!any || row > child->last_row) child->last_row = row;
        if (!any || first_column < child->bound_left) child->bound_left = first_column;
        if (!any || last_column > child->bound_right) child->bound_right = last_column;
        any = 1;
    }
    if (any) {
        uint16_t width = child->bound_right - child->bound_left + 1u;
        uint8_t height = child->last_row - child->first_row + 1u;
        uint24_t normalized_area = child->pixel_area;
        uint16_t normalized_width = width;
        uint16_t normalized_height = height;
        uint8_t lod_slot = child_depth == 0 ? 0 : child_depth - 1u;
        uint8_t lod;

        if (lod_slot >= PORTAL_RECURSION_MAX) {
            lod_slot = PORTAL_RECURSION_MAX - 1u;
        }
        lod = portal_lod_state[lod_slot][portal_polygon->portal];

        if (active_render_mode == RENDER_MODE_320) {
            normalized_area = (normalized_area + 12u) / 25u;
            normalized_width = (normalized_width + 2u) / 5u;
            normalized_height = (normalized_height + 2u) / 5u;
        } else if (active_render_mode == RENDER_MODE_128) {
            normalized_area = (normalized_area + 2u) >> 2;
            normalized_width = (normalized_width + 1u) >> 1;
            normalized_height = (normalized_height + 1u) >> 1;
        } else if (active_render_mode == RENDER_MODE_32) {
            normalized_area <<= 2;
            normalized_width <<= 1;
            normalized_height <<= 1;
        }

        if (lod == 0) {
            if (normalized_area < PORTAL_LOD_QUARTER_ENTER_AREA) {
                lod = 2;
            } else if (normalized_area < PORTAL_LOD_HALF_ENTER_AREA ||
                       normalized_width < 40u || normalized_height < 30u) {
                lod = 1;
            }
        } else if (lod == 1) {
            if (normalized_area < PORTAL_LOD_QUARTER_ENTER_AREA) {
                lod = 2;
            } else if (normalized_area > PORTAL_LOD_FULL_ENTER_AREA &&
                       normalized_width > 48u && normalized_height > 36u) {
                lod = 0;
            }
        } else if (normalized_area > PORTAL_LOD_QUARTER_LEAVE_AREA) {
            if (normalized_area > PORTAL_LOD_FULL_ENTER_AREA &&
                normalized_width > 48u && normalized_height > 36u) {
                lod = 0;
            } else {
                lod = 1;
            }
        }
        portal_lod_state[lod_slot][portal_polygon->portal] = lod;
        child->lod_shift = child_depth < active_portal_recursion ? 0 : lod;
    }
    return any;
}

static Vec3 transform_portal_vector(uint8_t portal_index, Vec3 vector) {
    const Portal *source = &portals[portal_index];
    const Portal *destination = &portals[source->linked];
    fixed_t local_right = signed_axis_component(vector, source->right);
    fixed_t local_up = signed_axis_component(vector, source->up);
    fixed_t local_normal = signed_axis_component(vector, source->normal);
    Vec3 result = {0, 0, 0};

    add_signed_axis(&result, destination->right, -local_right);
    add_signed_axis(&result, destination->up, local_up);
    add_signed_axis(&result, destination->normal, -local_normal);
    return result;
}

static Vec3 transform_portal_point(uint8_t portal_index, Vec3 point) {
    const Portal *source = &portals[portal_index];
    const Portal *destination = &portals[source->linked];
    Vec3 relative = vec_subtract(point, source->center);
    return vec_add(destination->center, transform_portal_vector(portal_index, relative));
}

static Camera transform_portal_camera(uint8_t portal_index, const Camera *source) {
    const Portal *destination_portal = &portals[portals[portal_index].linked];
    Camera destination;

    destination.position = transform_portal_point(portal_index, source->position);
    destination.right = transform_portal_vector(portal_index, source->right);
    destination.up = transform_portal_vector(portal_index, source->up);
    destination.forward = transform_portal_vector(portal_index, source->forward);
    destination.room = destination_portal->room;
    return destination;
}

static void clear_render_layer(const RenderLayer *layer, uint8_t depth) {
    if (depth == 0) {
        memset(render_target, COLOR_VOID, GFX_LCD_WIDTH * GFX_LCD_HEIGHT);
    } else {
        uint8_t row;
        for (row = layer->first_row; row <= layer->last_row; ++row) {
            if (layer->row_left[row] <= layer->row_right[row]) {
                write_frame_span(
                    row,
                    layer->row_left[row],
                    layer->row_right[row],
                    COLOR_VOID
                );
            }
        }
    }
}

static void draw_portal_outline(const RenderLayer *clip, uint8_t color) {
    uint8_t row;

    for (row = clip->first_row; row <= clip->last_row; ++row) {
        uint16_t left = clip->row_left[row];
        uint16_t right = clip->row_right[row];
        if (left <= right) {
            write_frame_span(row, left, left, color);
            write_frame_span(row, right, right, color);
        }
    }
    write_frame_span(
        clip->first_row,
        clip->row_left[clip->first_row],
        clip->row_right[clip->first_row],
        color
    );
    if (clip->last_row != clip->first_row) {
        write_frame_span(
            clip->last_row,
            clip->row_left[clip->last_row],
            clip->row_right[clip->last_row],
            color
        );
    }
}

static void fill_polygon_lod(
    const DrawPolygon *polygon,
    const RenderLayer *layer
) {
    uint8_t shift = layer->lod_shift;
    uint8_t step = (uint8_t)(1u << shift);
    uint8_t sample_origin = step >> 1;
    uint16_t maximum_column = (active_render_width >> shift) - 1u;
    uint8_t row;

    for (row = polygon->first_row; row <= polygon->last_row; row += step) {
        uint16_t first_column;
        uint16_t last_column;
        uint16_t block_left;
        uint16_t block_right;
        uint16_t block_top;
        uint16_t block_bottom;
        uint16_t target_row;
        uint8_t color;

        if (polygon->span_left[row] > polygon->span_right[row]) continue;
        if (polygon->span_right[row] < sample_origin) continue;
        first_column = polygon->span_left[row] <= sample_origin ? 0 :
            (uint16_t)((polygon->span_left[row] - sample_origin + step - 1u) >> shift);
        last_column = (uint16_t)(
            (polygon->span_right[row] - sample_origin) >> shift
        );
        if (last_column > maximum_column) last_column = maximum_column;
        if (first_column > last_column) continue;
        block_left = first_column << shift;
        block_right = ((last_column + 1u) << shift) - 1u;
        if (block_right >= active_render_width) block_right = active_render_width - 1u;
        block_top = ((uint16_t)row >> shift) << shift;
        block_bottom = block_top + step - 1u;
        if (block_bottom >= active_render_height) block_bottom = active_render_height - 1u;
        color = face_color_for_row(polygon, layer, row);

        for (target_row = block_top; target_row <= block_bottom; ++target_row) {
            int16_t clipped_left;
            int16_t clipped_right;
            if (target_row < layer->first_row || target_row > layer->last_row ||
                layer->row_left[target_row] > layer->row_right[target_row]) {
                continue;
            }
            clipped_left = block_left;
            clipped_right = block_right;
            if (clipped_left < layer->row_left[target_row]) {
                clipped_left = layer->row_left[target_row];
            }
            if (clipped_right > layer->row_right[target_row]) {
                clipped_right = layer->row_right[target_row];
            }
            if (clipped_left <= clipped_right) {
                write_frame_span(
                    (uint8_t)target_row,
                    clipped_left,
                    clipped_right,
                    color
                );
            }
        }
    }
}

static void render_portal_lod(
    const Camera *camera,
    RenderLayer *layer,
    uint8_t skipped_face
) {
    uint8_t index;
    collect_room_polygons(layer, camera, skipped_face, 0);
    clear_render_layer(layer, 1);
    for (index = 0; index < layer->solid_count; ++index) {
        fill_polygon_lod(&layer->polygon[index], layer);
    }
}

static void render_camera(
    const Camera *camera,
    uint8_t depth,
    uint8_t skipped_face
) {
    RenderLayer *layer = &render_layers[depth];
    uint8_t index;

    collect_room_polygons(
        layer,
        camera,
        skipped_face,
        (uint8_t)(depth < active_portal_recursion)
    );
    clear_render_layer(layer, depth);
    for (index = 0; index < layer->solid_count; ++index) {
        fill_polygon(&layer->polygon[index], layer);
    }
    if (depth < active_portal_recursion) {
        for (index = layer->solid_count; index < layer->count; ++index) {
            DrawPolygon *polygon = &layer->polygon[index];
            RenderLayer *child = &render_layers[depth + 1];
            Camera destination;
            uint8_t destination_face;

            if (!build_portal_clip(polygon, layer, child, depth + 1u)) continue;
            destination = transform_portal_camera(polygon->portal, camera);
            destination_face = portals[portals[polygon->portal].linked].host_face;
            if (child->lod_shift == 0) {
                render_camera(&destination, depth + 1, destination_face);
            } else {
                render_portal_lod(&destination, child, destination_face);
            }
            draw_portal_outline(child, polygon->color);
        }
    }
}

static void recover_camera_angles(EngineState *state) {
    uint8_t pitch_index;
    uint8_t best_pitch = 0;
    fixed_t vertical = fixed_absolute(state->forward.z);
    fixed_t best_pitch_error = INT_MAX;
    uint16_t angle;
    uint8_t best_yaw = state->yaw;
    int32_t best_yaw_score = INT32_MIN;
    uint8_t heading_source;

    for (pitch_index = 0; pitch_index <= PITCH_LIMIT; ++pitch_index) {
        fixed_t error = fixed_absolute(vertical - quarter_sine[pitch_index]);
        if (error < best_pitch_error) {
            best_pitch_error = error;
            best_pitch = pitch_index;
        }
    }
    state->pitch = state->forward.z < 0 ? -(int8_t)best_pitch : (int8_t)best_pitch;

    if (fixed_absolute(state->forward.x) + fixed_absolute(state->forward.y) > 8) {
        heading_source = 0;
    } else if (fixed_absolute(state->right.x) + fixed_absolute(state->right.y) > 8) {
        heading_source = 1;
    } else {
        heading_source = 2;
    }

    for (angle = 0; angle < 256u; ++angle) {
        fixed_t sine = angle_sine((uint8_t)angle);
        fixed_t cosine = angle_sine((uint8_t)(angle + 64u));
        int32_t score;
        if (heading_source == 0) {
            score = (int32_t)state->forward.x * cosine +
                (int32_t)state->forward.y * sine;
        } else if (heading_source == 1) {
            score = -(int32_t)state->right.x * sine +
                (int32_t)state->right.y * cosine;
        } else {
            score = (int32_t)state->up.x * cosine +
                (int32_t)state->up.y * sine;
            if (state->pitch > 0) score = -score;
        }
        if (score > best_yaw_score) {
            best_yaw_score = score;
            best_yaw = (uint8_t)angle;
        }
    }
    state->yaw = best_yaw;
    rebuild_camera_basis(state);
}

static Vec3 horizontal_forward(const EngineState *state) {
    Vec3 direction = {state->right.y, -state->right.x, 0};
    return direction;
}

static fixed_t clamp_fixed(fixed_t value, fixed_t minimum, fixed_t maximum) {
    if (value < minimum) return minimum;
    if (value > maximum) return maximum;
    return value;
}

static uint8_t point_inside_room_face(const Room *room, Vec3 point) {
    return (uint8_t)(
        point.x >= room->minimum_x && point.x <= room->maximum_x &&
        point.y >= room->minimum_y && point.y <= room->maximum_y &&
        point.z >= room->minimum_z && point.z <= room->maximum_z
    );
}

static uint8_t room_face_holds_portal(const Room *room, uint8_t face_offset) {
    fixed_t width;
    fixed_t height;

    if (face_offset <= 1) {
        width = room->maximum_x - room->minimum_x;
        height = room->maximum_y - room->minimum_y;
    } else if (face_offset <= 3) {
        width = room->maximum_x - room->minimum_x;
        height = room->maximum_z - room->minimum_z;
    } else {
        width = room->maximum_y - room->minimum_y;
        height = room->maximum_z - room->minimum_z;
    }
    return (uint8_t)(
        width >= 2 * PORTAL_HALF_WIDTH &&
        height >= 2 * PORTAL_HALF_HEIGHT
    );
}

static void configure_portal_on_face(
    uint8_t portal_index,
    uint8_t room_index,
    uint8_t face_offset,
    Vec3 center
) {
    const Room *room;

    if (portal_index >= PORTAL_COUNT || room_index >= room_count ||
        face_offset >= ROOM_FACE_COUNT) {
        return;
    }
    room = &rooms[room_index];
    portals[portal_index].room = room_index;
    portals[portal_index].host_face = room->first_face + face_offset;
    portals[portal_index].normal = face_normals[face_offset];
    portals[portal_index].right = face_right_vectors[face_offset];
    portals[portal_index].up = face_up_vectors[face_offset];
    portals[portal_index].active = 1;

    if (face_offset <= 1) {
        center.x = clamp_fixed(
            center.x,
            room->minimum_x + portals[portal_index].half_width,
            room->maximum_x - portals[portal_index].half_width
        );
        center.y = clamp_fixed(
            center.y,
            room->minimum_y + portals[portal_index].half_height,
            room->maximum_y - portals[portal_index].half_height
        );
        center.z = face_offset == 0 ? room->minimum_z : room->maximum_z;
    } else if (face_offset <= 3) {
        center.x = clamp_fixed(
            center.x,
            room->minimum_x + portals[portal_index].half_width,
            room->maximum_x - portals[portal_index].half_width
        );
        center.z = clamp_fixed(
            center.z,
            room->minimum_z + portals[portal_index].half_height,
            room->maximum_z - portals[portal_index].half_height
        );
        center.y = face_offset == 2 ? room->minimum_y : room->maximum_y;
    } else {
        center.y = clamp_fixed(
            center.y,
            room->minimum_y + portals[portal_index].half_width,
            room->maximum_y - portals[portal_index].half_width
        );
        center.z = clamp_fixed(
            center.z,
            room->minimum_z + portals[portal_index].half_height,
            room->maximum_z - portals[portal_index].half_height
        );
        center.x = face_offset == 4 ? room->minimum_x : room->maximum_x;
    }
    portals[portal_index].center = center;
}

static void place_portal(const EngineState *state, uint8_t portal_index) {
    const Room *room = &rooms[state->room];
    fixed_t nearest_distance = (fixed_t)0x7FFFFF;
    Vec3 nearest_hit = state->position;
    uint8_t nearest_face_offset = NO_PORTAL;
    uint8_t face_offset;

    for (face_offset = 0; face_offset < ROOM_FACE_COUNT; ++face_offset) {
        const WorldFace *face = &world_faces[room->first_face + face_offset];
        Vec3 plane_point = world_vertex(face->vertex[0]);
        Vec3 normal = face_normals[face_offset];
        fixed_t denominator = signed_axis_component(state->forward, normal);
        fixed_t numerator;
        fixed_t distance;
        Vec3 hit;

        if (denominator >= -4) continue;
        numerator = signed_axis_component(
            vec_subtract(plane_point, state->position),
            normal
        );
        distance = (fixed_t)(((int32_t)numerator * FIXED_ONE) / denominator);
        if (distance <= NEAR_PLANE || distance >= nearest_distance) continue;
        hit = vec_add(state->position, vec_scale(state->forward, distance));
        if (!point_inside_room_face(room, hit)) continue;
        nearest_distance = distance;
        nearest_hit = hit;
        nearest_face_offset = face_offset;
    }
    if (nearest_face_offset == NO_PORTAL ||
        !room_face_holds_portal(room, nearest_face_offset)) return;

    configure_portal_on_face(portal_index, state->room, nearest_face_offset, nearest_hit);
}

static fixed_t portal_crossing_extent(const EngineState *state, const Portal *portal) {
    if (!state->dev_mode && portal->normal.z > FIXED_ONE / 2) {
        return PLAYER_EYE_HEIGHT;
    }
    return PLAYER_RADIUS;
}

static uint8_t try_portal_crossing(
    EngineState *state,
    Vec3 start,
    Vec3 *candidate
) {
    uint8_t portal_index;

    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const Portal *portal = &portals[portal_index];
        Vec3 start_relative;
        Vec3 end_relative;
        fixed_t start_distance;
        fixed_t end_distance;
        fixed_t fraction;
        Vec3 hit;
        fixed_t local_right;
        fixed_t local_up;
        fixed_t source_extent;
        fixed_t destination_extent;

        if (!portal->active || !portals[portal->linked].active ||
            portal->room != state->room) {
            continue;
        }
        start_relative = vec_subtract(start, portal->center);
        end_relative = vec_subtract(*candidate, portal->center);
        start_distance = signed_axis_component(start_relative, portal->normal);
        end_distance = signed_axis_component(end_relative, portal->normal);
        source_extent = portal_crossing_extent(state, portal);
        destination_extent = portal_crossing_extent(state, &portals[portal->linked]);
        start_distance -= source_extent;
        end_distance -= source_extent;
        if (start_distance < 0 || end_distance > 0 ||
            (start_distance == 0 && end_distance == 0)) {
            continue;
        }
        fraction = (fixed_t)(
            ((int32_t)start_distance * FIXED_ONE) /
            (start_distance - end_distance)
        );
        hit = vec_add(start, vec_scale(vec_subtract(*candidate, start), fraction));
        hit = vec_subtract(hit, portal->center);
        local_right = fixed_absolute(signed_axis_component(hit, portal->right));
        local_up = fixed_absolute(signed_axis_component(hit, portal->up));
        if (local_right > portal->half_width - PORTAL_APERTURE_MARGIN ||
            local_up > portal->half_height - PORTAL_APERTURE_MARGIN) {
            continue;
        }

        *candidate = transform_portal_point(portal_index, *candidate);
        state->velocity = transform_portal_vector(portal_index, state->velocity);
        state->right = transform_portal_vector(portal_index, state->right);
        state->up = transform_portal_vector(portal_index, state->up);
        state->forward = transform_portal_vector(portal_index, state->forward);
        recover_camera_angles(state);
        state->room = portals[portal->linked].room;
        add_signed_axis(
            candidate,
            portals[portal->linked].normal,
            source_extent + destination_extent + 16
        );
        state->grounded = 0;
        return 1;
    }
    return 0;
}

static void collide_with_room(EngineState *state, Vec3 *position) {
    const Room *room = &rooms[state->room];
    fixed_t minimum_x = room->minimum_x + PLAYER_RADIUS;
    fixed_t maximum_x = room->maximum_x - PLAYER_RADIUS;
    fixed_t minimum_y = room->minimum_y + PLAYER_RADIUS;
    fixed_t maximum_y = room->maximum_y - PLAYER_RADIUS;
    fixed_t minimum_z = room->minimum_z +
        (state->dev_mode ? PLAYER_RADIUS : PLAYER_EYE_HEIGHT);
    fixed_t maximum_z = room->maximum_z -
        (state->dev_mode ? PLAYER_RADIUS : CEILING_MARGIN);

    if (position->x < minimum_x) {
        position->x = minimum_x;
        state->velocity.x = 0;
    } else if (position->x > maximum_x) {
        position->x = maximum_x;
        state->velocity.x = 0;
    }
    if (position->y < minimum_y) {
        position->y = minimum_y;
        state->velocity.y = 0;
    } else if (position->y > maximum_y) {
        position->y = maximum_y;
        state->velocity.y = 0;
    }
    if (position->z <= minimum_z) {
        position->z = minimum_z;
        if (state->velocity.z < 0) state->velocity.z = 0;
        state->grounded = (uint8_t)!state->dev_mode;
    } else {
        state->grounded = 0;
    }
    if (position->z > maximum_z) {
        position->z = maximum_z;
        if (state->velocity.z > 0) state->velocity.z = 0;
    }
}

static uint8_t build_world(const True3DLevelView *level) {
    uint8_t room_index;
    uint8_t portal_index;

    if (level == NULL || level->header == NULL || level->rooms == NULL ||
        level->header->room_count == 0 ||
        level->header->room_count > TRUE3D_MAX_ROOMS) {
        return 0;
    }
    room_count = level->header->room_count;
    for (room_index = 0; room_index < room_count; ++room_index) {
        const True3DRoomRecord *source = &level->rooms[room_index];
        Room *destination = &rooms[room_index];
        uint8_t vertex_base = room_index * 8u;
        uint8_t face_base = room_index * ROOM_FACE_COUNT;
        uint8_t face_offset;

        destination->first_face = face_base;
        destination->minimum_x = source->minimum_x;
        destination->maximum_x = source->maximum_x;
        destination->minimum_y = source->minimum_y;
        destination->maximum_y = source->maximum_y;
        destination->minimum_z = source->minimum_z;
        destination->maximum_z = source->maximum_z;

        world_vertices[vertex_base + 0] = (WorldVertex){
            source->minimum_x, source->minimum_y, source->minimum_z
        };
        world_vertices[vertex_base + 1] = (WorldVertex){
            source->maximum_x, source->minimum_y, source->minimum_z
        };
        world_vertices[vertex_base + 2] = (WorldVertex){
            source->maximum_x, source->maximum_y, source->minimum_z
        };
        world_vertices[vertex_base + 3] = (WorldVertex){
            source->minimum_x, source->maximum_y, source->minimum_z
        };
        world_vertices[vertex_base + 4] = (WorldVertex){
            source->minimum_x, source->minimum_y, source->maximum_z
        };
        world_vertices[vertex_base + 5] = (WorldVertex){
            source->maximum_x, source->minimum_y, source->maximum_z
        };
        world_vertices[vertex_base + 6] = (WorldVertex){
            source->maximum_x, source->maximum_y, source->maximum_z
        };
        world_vertices[vertex_base + 7] = (WorldVertex){
            source->minimum_x, source->maximum_y, source->maximum_z
        };

        for (face_offset = 0; face_offset < ROOM_FACE_COUNT; ++face_offset) {
            WorldFace *face = &world_faces[face_base + face_offset];
            uint8_t corner;
            for (corner = 0; corner < 4; ++corner) {
                face->vertex[corner] = vertex_base +
                    box_face_vertices[face_offset][corner];
            }
            face->color = (uint8_t)(
                SHADED_PALETTE_FIRST + (source->face_color[face_offset] << 2)
            );
            face->portal = NO_PORTAL;
        }
    }

    portals[0].linked = 1;
    portals[1].linked = 0;
    for (portal_index = 0; portal_index < PORTAL_COUNT; ++portal_index) {
        const True3DPortalSpawn *spawn = &level->header->portal[portal_index];
        portals[portal_index].half_width = PORTAL_HALF_WIDTH;
        portals[portal_index].half_height = PORTAL_HALF_HEIGHT;
        portals[portal_index].active = 0;
        if ((level->header->portal_active_mask & (1u << portal_index)) != 0 &&
            room_face_holds_portal(&rooms[spawn->room], spawn->face)) {
            Vec3 center = {spawn->x, spawn->y, spawn->z};
            configure_portal_on_face(
                portal_index,
                spawn->room,
                spawn->face,
                center
            );
        }
    }
    return 1;
}

uint8_t engine_init(EngineState *state, const True3DLevelView *level) {
    if (state == NULL || !build_world(level)) return 0;
    state->position.x = level->header->spawn_x;
    state->position.y = level->header->spawn_y;
    state->position.z = level->header->spawn_z;
    state->velocity.x = 0;
    state->velocity.y = 0;
    state->velocity.z = 0;
    state->yaw = 64;
    state->pitch = 0;
    rebuild_camera_basis(state);
    state->room = level->header->spawn_room;
    state->previous_buttons = 0;
    state->grounded = 1;
    state->dev_mode = 0;
    state->render_mode = RENDER_MODE_64;
    state->portal_recursion = 1;
    memset(portal_lod_state, 0, sizeof(portal_lod_state));
    collide_with_room(state, &state->position);
    return 1;
}

static void configure_render_mode(uint8_t mode) {
    if (mode >= RENDER_MODE_COUNT) mode = RENDER_MODE_64;
    active_render_mode = mode;
    if (mode == RENDER_MODE_320) {
        active_render_width = 320;
        active_render_height = 240;
        active_horizon_near_limit = 20;
        active_horizon_far_limit = 60;
    } else if (mode == RENDER_MODE_128) {
        active_render_width = 128;
        active_render_height = 96;
        active_horizon_near_limit = 8;
        active_horizon_far_limit = 24;
    } else if (mode == RENDER_MODE_32) {
        active_render_width = 32;
        active_render_height = 24;
        active_horizon_near_limit = 2;
        active_horizon_far_limit = 6;
    } else {
        active_render_width = 64;
        active_render_height = 48;
        active_horizon_near_limit = 4;
        active_horizon_far_limit = 12;
    }
}

void engine_graphics_init(void) {
    uint8_t color;
    uint8_t shade;
    uint16_t index;

    configure_render_mode(RENDER_MODE_64);
    for (index = 0; index < (NEAR_PLANE >> PROJECTION_TABLE_SHIFT); ++index) {
        projection_scale_table[index] = 65535u;
    }
    for (; index < PROJECTION_TABLE_SIZE; ++index) {
        projection_scale_table[index] = (uint16_t)(
            ((uint32_t)PROJECTION_FOCAL * FIXED_ONE *
                (1u << PROJECTION_SCALE_SHIFT)) /
            ((uint24_t)index << PROJECTION_TABLE_SHIFT)
        );
    }
    for (index = (PROJECTION_TABLE_SIZE << PROJECTION_TABLE_SHIFT) >>
            FAR_PROJECTION_TABLE_SHIFT;
         index < PROJECTION_TABLE_SIZE;
         ++index) {
        far_projection_scale_table[index] = (uint16_t)(
            ((uint32_t)PROJECTION_FOCAL * FIXED_ONE *
                (1u << PROJECTION_SCALE_SHIFT)) /
            ((uint24_t)index << FAR_PROJECTION_TABLE_SHIFT)
        );
    }
    edge_reciprocal_table[0] = 0;
    for (index = 1; index < EDGE_RECIPROCAL_SIZE; ++index) {
        uint24_t denominator = (uint24_t)index << EDGE_RECIPROCAL_SHIFT;
        uint24_t reciprocal =
            ((1u << (EDGE_STEP_PRECISION_SHIFT + FIXED_SHIFT)) +
             denominator / 2u) / denominator;
        if (reciprocal > 65535u) reciprocal = 65535u;
        edge_reciprocal_table[index] = (uint16_t)reciprocal;
    }
    for (color = 0; color <= COLOR_HUD; ++color) {
        gfx_palette[color] = gfx_RGBTo1555(
            base_palette_rgb[color][0],
            base_palette_rgb[color][1],
            base_palette_rgb[color][2]
        );
        for (shade = 0; shade < SHADE_LEVEL_COUNT; ++shade) {
            uint8_t factor = shade_numerator[shade];
            gfx_palette[
                SHADED_PALETTE_FIRST + (color << 2) + shade
            ] = gfx_RGBTo1555(
                ((uint16_t)base_palette_rgb[color][0] * factor) >> 4,
                ((uint16_t)base_palette_rgb[color][1] * factor) >> 4,
                ((uint16_t)base_palette_rgb[color][2] * factor) >> 4
            );
        }
    }
}

uint8_t engine_update(
    EngineState *state,
    int8_t move_axis,
    int8_t turn_axis,
    int8_t look_axis,
    uint8_t buttons,
    uint24_t elapsed_ticks,
    uint24_t ticks_per_second
) {
    EngineState previous = *state;
    uint8_t pressed = (uint8_t)(buttons & (uint8_t)~state->previous_buttons);
    uint24_t maximum_ticks;
    uint8_t camera_changed = 0;
    Vec3 movement_direction;
    Vec3 candidate;
    uint8_t world_changed = 0;

    state->previous_buttons = buttons;
    if (ticks_per_second == 0) return 0;
    maximum_ticks = ticks_per_second / 8u;
    if (elapsed_ticks > maximum_ticks) elapsed_ticks = maximum_ticks;

    if (turn_axis != 0) {
        uint8_t turn_step = (uint8_t)(
            ((uint32_t)TURN_UNITS_PER_SECOND * elapsed_ticks + ticks_per_second / 2u) /
            ticks_per_second
        );
        if (turn_step == 0) turn_step = 1;
        state->yaw = (uint8_t)(state->yaw + turn_axis * turn_step);
        camera_changed = 1;
    }
    if (look_axis != 0) {
        uint8_t pitch_step = (uint8_t)(
            ((uint32_t)PITCH_UNITS_PER_SECOND * elapsed_ticks + ticks_per_second / 2u) /
            ticks_per_second
        );
        int16_t pitch;
        if (pitch_step == 0) pitch_step = 1;
        pitch = state->pitch + look_axis * pitch_step;
        if (pitch > PITCH_LIMIT) pitch = PITCH_LIMIT;
        if (pitch < -PITCH_LIMIT) pitch = -PITCH_LIMIT;
        if (pitch != state->pitch) {
            state->pitch = (int8_t)pitch;
            camera_changed = 1;
        }
    }
    if (camera_changed) rebuild_camera_basis(state);
    if ((pressed & ENGINE_BUTTON_DEV_MODE) != 0) {
        state->dev_mode = (uint8_t)!state->dev_mode;
        state->velocity.x = 0;
        state->velocity.y = 0;
        state->velocity.z = 0;
        state->grounded = 0;
    }
    if ((pressed & ENGINE_BUTTON_RESOLUTION) != 0) {
        state->render_mode = (uint8_t)(
            (state->render_mode + 1u) % RENDER_MODE_COUNT
        );
    }
    if ((pressed & ENGINE_BUTTON_RECURSION) != 0) {
        ++state->portal_recursion;
        if (state->portal_recursion > PORTAL_RECURSION_MAX) {
            state->portal_recursion = 1;
        }
    }
    if ((pressed & ENGINE_BUTTON_ORANGE_PORTAL) != 0) {
        place_portal(state, 0);
        world_changed = 1;
    }
    if ((pressed & ENGINE_BUTTON_BLUE_PORTAL) != 0) {
        place_portal(state, 1);
        world_changed = 1;
    }
    if (!state->dev_mode &&
        (pressed & ENGINE_BUTTON_JUMP) != 0 && state->grounded) {
        state->velocity.z = JUMP_SPEED;
        state->grounded = 0;
    }

    if (state->dev_mode) {
        movement_direction = state->forward;
        state->velocity = vec_scale(movement_direction, move_axis * MOVE_SPEED);
        if ((buttons & ENGINE_BUTTON_JUMP) != 0) {
            state->velocity.z += MOVE_SPEED;
        }
        if ((buttons & ENGINE_BUTTON_FLY_DOWN) != 0) {
            state->velocity.z -= MOVE_SPEED;
        }
    } else {
        movement_direction = horizontal_forward(state);
        state->velocity.x = fixed_mul(movement_direction.x, move_axis * MOVE_SPEED);
        state->velocity.y = fixed_mul(movement_direction.y, move_axis * MOVE_SPEED);
        state->velocity.z -= (fixed_t)(
            ((int32_t)GRAVITY * elapsed_ticks) / ticks_per_second
        );
    }
    candidate.x = state->position.x + (fixed_t)(
        ((int32_t)state->velocity.x * elapsed_ticks) / ticks_per_second
    );
    candidate.y = state->position.y + (fixed_t)(
        ((int32_t)state->velocity.y * elapsed_ticks) / ticks_per_second
    );
    candidate.z = state->position.z + (fixed_t)(
        ((int32_t)state->velocity.z * elapsed_ticks) / ticks_per_second
    );

    try_portal_crossing(state, state->position, &candidate);
    collide_with_room(state, &candidate);
    state->position = candidate;
    previous.previous_buttons = state->previous_buttons;

    return (uint8_t)(
        world_changed || memcmp(&previous, state, sizeof(EngineState)) != 0
    );
}

/* 3-by-5 glyphs: F, P, S, R, D, digits 0 through 9, then X. */
static const uint8_t hud_glyphs[16][5] = {
    {7, 4, 6, 4, 4},
    {6, 5, 6, 4, 4},
    {7, 4, 7, 1, 7},
    {6, 5, 6, 5, 5},
    {6, 5, 5, 5, 6},
    {7, 5, 5, 5, 7},
    {2, 6, 2, 2, 7},
    {7, 1, 7, 4, 7},
    {7, 1, 7, 1, 7},
    {5, 5, 7, 1, 1},
    {7, 4, 7, 1, 7},
    {7, 4, 7, 5, 7},
    {7, 1, 2, 2, 2},
    {7, 5, 7, 5, 7},
    {7, 5, 7, 1, 7},
    {5, 5, 2, 5, 5}
};

static void draw_hud_glyph(uint8_t *frame, uint8_t glyph, uint16_t x, uint8_t y) {
    uint8_t row;
    for (row = 0; row < 5; ++row) {
        uint8_t bits = hud_glyphs[glyph][row];
        uint8_t column;
        for (column = 0; column < 3; ++column) {
            if ((bits & (4u >> column)) != 0) {
                frame[(uint24_t)(y + row) * GFX_LCD_WIDTH + x + column] = COLOR_HUD;
            }
        }
    }
}

static void draw_hud(
    uint8_t fps,
    uint8_t room,
    uint8_t dev_mode,
    uint8_t render_mode,
    uint8_t portal_recursion
) {
    uint8_t *frame = render_target;
    uint16_t width;
    uint8_t height;
    uint8_t row;

    for (row = 0; row < 8; ++row) {
        memset(&frame[(uint16_t)row * GFX_LCD_WIDTH], COLOR_BLACK, 48);
        memset(
            &frame[(uint16_t)row * GFX_LCD_WIDTH + 276u],
            COLOR_BLACK,
            44
        );
    }
    draw_hud_glyph(frame, 0, 2, 2);
    draw_hud_glyph(frame, 1, 6, 2);
    draw_hud_glyph(frame, 2, 10, 2);
    draw_hud_glyph(frame, (uint8_t)(5 + fps / 100u), 18, 2);
    draw_hud_glyph(frame, (uint8_t)(5 + (fps / 10u) % 10u), 22, 2);
    draw_hud_glyph(frame, (uint8_t)(5 + fps % 10u), 26, 2);
    draw_hud_glyph(frame, 3, 34, 2);
    draw_hud_glyph(frame, (uint8_t)(5 + room + 1), 38, 2);
    if (dev_mode) draw_hud_glyph(frame, 4, 44, 2);

    if (render_mode == RENDER_MODE_320) {
        width = 320;
        height = 240;
    } else if (render_mode == RENDER_MODE_128) {
        width = 128;
        height = 96;
    } else if (render_mode == RENDER_MODE_32) {
        width = 32;
        height = 24;
    } else {
        width = 64;
        height = 48;
    }
    draw_hud_glyph(frame, (uint8_t)(5u + width / 100u), 278, 2);
    draw_hud_glyph(frame, (uint8_t)(5u + (width / 10u) % 10u), 282, 2);
    draw_hud_glyph(frame, (uint8_t)(5u + width % 10u), 286, 2);
    draw_hud_glyph(frame, 15, 290, 2);
    draw_hud_glyph(frame, (uint8_t)(5u + height / 100u), 294, 2);
    draw_hud_glyph(frame, (uint8_t)(5u + (height / 10u) % 10u), 298, 2);
    draw_hud_glyph(frame, (uint8_t)(5u + height % 10u), 302, 2);
    draw_hud_glyph(frame, 1, 310, 2);
    draw_hud_glyph(frame, (uint8_t)(5u + portal_recursion), 314, 2);

    memset(
        &frame[(uint24_t)(GFX_LCD_HEIGHT / 2) * GFX_LCD_WIDTH +
            GFX_LCD_WIDTH / 2 - 2],
        COLOR_HUD,
        5
    );
    for (row = GFX_LCD_HEIGHT / 2 - 2; row <= GFX_LCD_HEIGHT / 2 + 2; ++row) {
        frame[(uint16_t)row * GFX_LCD_WIDTH + GFX_LCD_WIDTH / 2] = COLOR_HUD;
    }
}

void engine_render(const EngineState *state, uint8_t fps) {
    Camera camera;
    uint8_t row;

    configure_render_mode(state->render_mode);
    active_portal_recursion = state->portal_recursion;
    if (active_portal_recursion < 1u ||
        active_portal_recursion > PORTAL_RECURSION_MAX) {
        active_portal_recursion = 1;
    }
    gfx_Wait();
    render_target = &gfx_vbuffer[0][0];
    camera.position = state->position;
    camera.right = state->right;
    camera.up = state->up;
    camera.forward = state->forward;
    camera.room = state->room;
    render_layers[0].first_row = 0;
    render_layers[0].last_row = active_render_height - 1;
    render_layers[0].bound_left = 0;
    render_layers[0].bound_right = active_render_width - 1;
    render_layers[0].lod_shift = 0;
    render_layers[0].pixel_area =
        (uint24_t)active_render_width * active_render_height;
    for (row = 0; row < active_render_height; ++row) {
        render_layers[0].row_left[row] = 0;
        render_layers[0].row_right[row] = active_render_width - 1;
    }
    render_camera(&camera, 0, NO_PORTAL);
    draw_hud(
        fps,
        state->room,
        state->dev_mode,
        active_render_mode,
        active_portal_recursion
    );
}
