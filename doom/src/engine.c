#include "engine.h"

#include <graphx.h>
#include <string.h>

#define FIXED_SHIFT 8
#define FIXED_ONE ((fixed_t)1 << FIXED_SHIFT)
#define ANGLE_STEPS 64
#define ANGLE_FRACTION_BITS 8
#define ANGLE_MASK ((ANGLE_STEPS << ANGLE_FRACTION_BITS) - 1)

#define PROJECTION_SCALE 240
#define VIEW_CENTER_X (GFX_LCD_WIDTH / 2)
#define VIEW_CENTER_Y (GFX_LCD_HEIGHT / 2)
#define NEAR_PLANE 32
#define MAX_DRAW_SURFACES (LEVEL_MAX_EDGES * 2u + LEVEL_MAX_PORTALS)
#define RENDER_WIDTH 80
#define RENDER_HEIGHT 120
#define RENDER_SCALE_X 4
#define RENDER_SCALE_Y 2
#define PROJECTION_TABLE_SHIFT 2
#define PROJECTION_TABLE_SIZE 2048
#define WALL_WIDTH_RECIPROCAL_SIZE 1601
#define PORTAL_RECURSION_LIMIT 3
#define RENDER_LAYER_COUNT (PORTAL_RECURSION_LIMIT + 1)

#define MOVE_SPEED 640
#define TURN_SPEED 13
#define LOOK_SPEED 96
#define PITCH_LIMIT 84
#define EYE_HEIGHT 384
#define PLAYER_HEIGHT 448
#define MAX_STEP_HEIGHT 144
#define JUMP_SPEED 832
#define GRAVITY 2560

enum PaletteIndex {
    COLOR_BLACK = 0,
    COLOR_CEILING = 1,
    COLOR_FLOOR_FAR = 2,
    COLOR_FLOOR_MID = 3,
    COLOR_FLOOR_NEAR = 4,
    COLOR_GREEN_DARK = 7,
    COLOR_GREEN = 8,
    COLOR_RED_DARK = 9,
    COLOR_RED = 10,
    COLOR_BLUE_DARK = 11,
    COLOR_BLUE = 12,
    COLOR_STEP = 13,
    COLOR_HUD = 14
};

typedef struct {
    fixed_t forward;
    fixed_t side;
} CameraVertex;

typedef struct {
    fixed_t forward_a;
    fixed_t forward_b;
    fixed_t scale_a;
    fixed_t scale_b;
    int24_t screen_x_a;
    int24_t screen_x_b;
} EdgeProjection;

typedef struct {
    int16_t x_a;
    int16_t x_b;
    int16_t top_a;
    int16_t top_b;
    int16_t bottom_a;
    int16_t bottom_b;
    fixed_t depth;
    uint8_t color;
    uint8_t opaque;
    uint8_t visible;
    uint8_t portal_index;
} DrawSurface;

typedef struct {
    fixed_t x;
    fixed_t y;
    fixed_t eye_z;
    fixed_t forward_x;
    fixed_t forward_y;
    int16_t pitch;
    uint8_t sector;
} RenderCamera;

typedef struct {
    DrawSurface surfaces[MAX_DRAW_SURFACES];
    uint8_t clip_top[RENDER_WIDTH];
    uint8_t clip_bottom[RENDER_WIDTH];
    uint8_t count;
    uint8_t clip_left;
    uint8_t clip_right;
} RenderLayer;

typedef struct {
    uint8_t width;
    uint8_t height;
    uint8_t data[RENDER_WIDTH * RENDER_HEIGHT];
} LowFrame;

static CameraVertex camera_vertices[LEVEL_MAX_VERTICES];
static RenderLayer render_layers[RENDER_LAYER_COUNT];
static uint8_t edge_portal_index[LEVEL_MAX_EDGES];
static uint8_t edge_sector_index[LEVEL_MAX_EDGES];
static uint16_t sector_visibility[LEVEL_MAX_SECTORS];
LowFrame low_frame;
static uint16_t low_row_offsets[RENDER_HEIGHT];
static uint16_t projection_scale_table[PROJECTION_TABLE_SIZE];
static uint16_t wall_width_reciprocal[WALL_WIDTH_RECIPROCAL_SIZE];

void present_low_frame_fast(void);

_Static_assert(
    sizeof(camera_vertices) + sizeof(render_layers) + sizeof(low_frame) +
        sizeof(projection_scale_table) + sizeof(wall_width_reciprocal) +
        sizeof(edge_portal_index) + sizeof(edge_sector_index) +
        sizeof(sector_visibility) < 64u * 1024u,
    "Renderer scratch exceeded 64 KiB"
);

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

/* 3-by-5 HUD glyphs: F, P, S, then digits 0 through 9. */
static const uint8_t hud_glyphs[15][5] = {
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
    {7, 5, 7, 1, 7},
    {2, 5, 7, 5, 5},
    {6, 5, 6, 5, 6}
};

static fixed_t fixed_mul(fixed_t left, fixed_t right) {
    return (fixed_t)(((int32_t)left * (int32_t)right) / FIXED_ONE);
}

static int16_t clamp_screen_coordinate(int24_t value, int24_t minimum, int24_t maximum) {
    if (value < minimum) value = minimum;
    if (value > maximum) value = maximum;
    return (int16_t)value;
}

static fixed_t projection_scale_for_forward(fixed_t forward) {
    uint24_t index = (uint24_t)forward >> PROJECTION_TABLE_SHIFT;

    if (index == 0) index = 1;
    if (index >= PROJECTION_TABLE_SIZE) index = PROJECTION_TABLE_SIZE - 1;
    return projection_scale_table[index];
}

static int24_t wall_slope(int24_t difference, int24_t width) {
    uint16_t reciprocal;

    if (width <= 0) return 0;
    if (width >= WALL_WIDTH_RECIPROCAL_SIZE) width = WALL_WIDTH_RECIPROCAL_SIZE - 1;
    reciprocal = wall_width_reciprocal[width];
    return (int24_t)(((int32_t)difference * reciprocal) / FIXED_ONE);
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

static uint8_t point_in_sector(const LevelView *level, uint8_t sector_index, fixed_t x, fixed_t y) {
    const LevelSector *sector = &level->sectors[sector_index];
    int24_t px = x >> 2;
    int24_t py = y >> 2;
    int8_t winding = 0;
    uint8_t index;

    for (index = 0; index < sector->edge_count; ++index) {
        const LevelEdge *edge = &level->edges[sector->first_edge + index];
        const LevelVertex *a = &level->vertices[edge->vertex_a];
        const LevelVertex *b = &level->vertices[edge->vertex_b];
        int24_t ax = (int24_t)a->x * 4;
        int24_t ay = (int24_t)a->y * 4;
        int24_t bx = (int24_t)b->x * 4;
        int24_t by = (int24_t)b->y * 4;
        int32_t cross = (int32_t)(bx - ax) * (py - ay) -
            (int32_t)(by - ay) * (px - ax);

        if (cross > 0) {
            if (winding < 0) return 0;
            winding = 1;
        } else if (cross < 0) {
            if (winding > 0) return 0;
            winding = -1;
        }
    }
    return 1;
}

static uint8_t sectors_are_neighbors(const LevelView *level, uint8_t from, uint8_t to) {
    const LevelSector *sector = &level->sectors[from];
    uint8_t index;

    for (index = 0; index < sector->edge_count; ++index) {
        if (level->edges[sector->first_edge + index].neighbor_sector == (int8_t)to) {
            return 1;
        }
    }
    return 0;
}

static uint8_t find_destination_sector(
    const LevelView *level,
    uint8_t current,
    fixed_t x,
    fixed_t y
) {
    uint8_t candidate;

    if (point_in_sector(level, current, x, y)) {
        return current;
    }
    for (candidate = 0; candidate < level->header->sector_count; ++candidate) {
        if (candidate != current &&
            sectors_are_neighbors(level, current, candidate) &&
            point_in_sector(level, candidate, x, y)) {
            return candidate;
        }
    }
    return 255u;
}

static uint8_t try_move_through_portal(
    EngineState *state,
    const LevelView *level,
    fixed_t candidate_x,
    fixed_t candidate_y
);

static uint8_t try_move_axis(
    EngineState *state,
    const LevelView *level,
    fixed_t candidate_x,
    fixed_t candidate_y
) {
    uint8_t destination;
    const LevelSector *from;
    const LevelSector *to;
    fixed_t floor_delta;

    if (level->header->portal_count != 0 &&
        try_move_through_portal(state, level, candidate_x, candidate_y)) {
        return 1;
    }
    destination = find_destination_sector(
        level,
        state->sector,
        candidate_x,
        candidate_y
    );

    if (destination == 255u) {
        return 0;
    }

    from = &level->sectors[state->sector];
    to = &level->sectors[destination];
    floor_delta = (fixed_t)to->floor_z - from->floor_z;
    if (floor_delta > MAX_STEP_HEIGHT ||
        (fixed_t)to->ceiling_z - to->floor_z < PLAYER_HEIGHT) {
        return 0;
    }

    state->x = candidate_x;
    state->y = candidate_y;
    if (destination != state->sector) {
        if (state->grounded && state->z < to->floor_z) {
            state->z = to->floor_z;
        }
        state->sector = destination;
    }
    return 0;
}

static uint16_t connected_sector_mask(const LevelView *level, uint8_t start_sector) {
    uint16_t visible = (uint16_t)(1u << start_sector);
    uint8_t changed;

    do {
        uint8_t sector_index;
        changed = 0;
        for (sector_index = 0; sector_index < level->header->sector_count; ++sector_index) {
            const LevelSector *sector;
            uint8_t edge_offset;

            if ((visible & (1u << sector_index)) == 0) continue;
            sector = &level->sectors[sector_index];
            for (edge_offset = 0; edge_offset < sector->edge_count; ++edge_offset) {
                int8_t neighbor = level->edges[sector->first_edge + edge_offset].neighbor_sector;
                if (neighbor >= 0 && (visible & (1u << neighbor)) == 0) {
                    visible |= (uint16_t)(1u << neighbor);
                    changed = 1;
                }
            }
        }
    } while (changed);
    return visible;
}

static void transform_vertices(
    const RenderCamera *camera,
    const LevelView *level,
    fixed_t direction_forward_x,
    fixed_t direction_forward_y
) {
    uint8_t index;

    for (index = 0; index < level->header->vertex_count; ++index) {
        fixed_t delta_x = (fixed_t)level->vertices[index].x * 16 - camera->x;
        fixed_t delta_y = (fixed_t)level->vertices[index].y * 16 - camera->y;

        camera_vertices[index].forward =
            fixed_mul(delta_x, direction_forward_x) +
            fixed_mul(delta_y, direction_forward_y);
        camera_vertices[index].side =
            fixed_mul(delta_y, direction_forward_x) -
            fixed_mul(delta_x, direction_forward_y);
    }
}

static uint8_t project_camera_segment(
    fixed_t forward_a,
    fixed_t forward_b,
    fixed_t side_a,
    fixed_t side_b,
    EdgeProjection *projection
) {
    if (forward_a < NEAR_PLANE && forward_b < NEAR_PLANE) {
        return 0;
    }

    if (forward_a < NEAR_PLANE) {
        fixed_t fraction = (fixed_t)(((int32_t)(NEAR_PLANE - forward_a) * FIXED_ONE) /
            (forward_b - forward_a));
        side_a += fixed_mul(side_b - side_a, fraction);
        forward_a = NEAR_PLANE;
    } else if (forward_b < NEAR_PLANE) {
        fixed_t fraction = (fixed_t)(((int32_t)(NEAR_PLANE - forward_b) * FIXED_ONE) /
            (forward_a - forward_b));
        side_b += fixed_mul(side_a - side_b, fraction);
        forward_b = NEAR_PLANE;
    }

    projection->forward_a = forward_a;
    projection->forward_b = forward_b;
    projection->scale_a = projection_scale_for_forward(forward_a);
    projection->scale_b = projection_scale_for_forward(forward_b);
    projection->screen_x_a = VIEW_CENTER_X + fixed_mul(side_a, projection->scale_a);
    projection->screen_x_b = VIEW_CENTER_X + fixed_mul(side_b, projection->scale_b);

    if ((projection->screen_x_a < -32 && projection->screen_x_b < -32) ||
        (projection->screen_x_a > GFX_LCD_WIDTH + 32 &&
         projection->screen_x_b > GFX_LCD_WIDTH + 32) ||
        projection->screen_x_a == projection->screen_x_b) {
        return 0;
    }
    return 1;
}

static uint8_t project_edge(const LevelEdge *edge, EdgeProjection *projection) {
    return project_camera_segment(
        camera_vertices[edge->vertex_a].forward,
        camera_vertices[edge->vertex_b].forward,
        camera_vertices[edge->vertex_a].side,
        camera_vertices[edge->vertex_b].side,
        projection
    );
}

static int24_t projected_z(fixed_t z, fixed_t eye_z, fixed_t scale, int24_t horizon) {
    return horizon - fixed_mul(z - eye_z, scale);
}

static void append_surface(
    RenderLayer *layer,
    const EdgeProjection *projection,
    fixed_t top_z,
    fixed_t bottom_z,
    fixed_t eye_z,
    int24_t horizon,
    uint8_t color,
    uint8_t opaque
) {
    int24_t top_a;
    int24_t top_b;
    int24_t bottom_a;
    int24_t bottom_b;
    DrawSurface *surface;

    if (layer->count >= MAX_DRAW_SURFACES || top_z <= bottom_z) return;

    top_a = projected_z(top_z, eye_z, projection->scale_a, horizon);
    top_b = projected_z(top_z, eye_z, projection->scale_b, horizon);
    bottom_a = projected_z(bottom_z, eye_z, projection->scale_a, horizon);
    bottom_b = projected_z(bottom_z, eye_z, projection->scale_b, horizon);
    if ((bottom_a < 0 && bottom_b < 0) ||
        (top_a > GFX_LCD_HEIGHT && top_b > GFX_LCD_HEIGHT)) {
        return;
    }

    surface = &layer->surfaces[layer->count++];
    surface->x_a = clamp_screen_coordinate(projection->screen_x_a, -640, 960);
    surface->x_b = clamp_screen_coordinate(projection->screen_x_b, -640, 960);
    surface->top_a = clamp_screen_coordinate(top_a, -512, 752);
    surface->top_b = clamp_screen_coordinate(top_b, -512, 752);
    surface->bottom_a = clamp_screen_coordinate(bottom_a, -512, 752);
    surface->bottom_b = clamp_screen_coordinate(bottom_b, -512, 752);
    surface->depth = (projection->forward_a + projection->forward_b) / 2;
    surface->color = color;
    surface->opaque = opaque;
    surface->visible = 1;
    surface->portal_index = LEVEL_NO_PORTAL;
}

static uint8_t solid_edge_faces_camera(
    const RenderCamera *camera,
    const LevelView *level,
    const LevelEdge *edge
) {
    const LevelVertex *a = &level->vertices[edge->vertex_a];
    const LevelVertex *b = &level->vertices[edge->vertex_b];
    int24_t player_x = camera->x / 16;
    int24_t player_y = camera->y / 16;
    int32_t side = (int32_t)(b->x - a->x) * (player_y - a->y) -
        (int32_t)(b->y - a->y) * (player_x - a->x);

    return side >= 0;
}

static uint8_t projection_overlaps_layer(
    const EdgeProjection *projection,
    const RenderLayer *layer
) {
    int24_t left = projection->screen_x_a < projection->screen_x_b ?
        projection->screen_x_a : projection->screen_x_b;
    int24_t right = projection->screen_x_a > projection->screen_x_b ?
        projection->screen_x_a : projection->screen_x_b;
    int24_t clip_left = (int24_t)layer->clip_left * RENDER_SCALE_X;
    int24_t clip_right = ((int24_t)layer->clip_right + 1) * RENDER_SCALE_X - 1;

    return (uint8_t)(right >= clip_left && left <= clip_right);
}

static uint8_t project_portal(
    const LevelView *level,
    uint8_t portal_index,
    EdgeProjection *projection
) {
    const LevelPortal *portal = &level->portals[portal_index];
    const LevelEdge *edge = &level->edges[portal->edge];
    const CameraVertex *a = &camera_vertices[edge->vertex_a];
    const CameraVertex *b = &camera_vertices[edge->vertex_b];
    fixed_t left_u = portal->center_u - portal->half_width;
    fixed_t right_u = portal->center_u + portal->half_width;
    fixed_t forward_a = a->forward + fixed_mul(b->forward - a->forward, left_u);
    fixed_t forward_b = a->forward + fixed_mul(b->forward - a->forward, right_u);
    fixed_t side_a = a->side + fixed_mul(b->side - a->side, left_u);
    fixed_t side_b = a->side + fixed_mul(b->side - a->side, right_u);

    return project_camera_segment(
        forward_a,
        forward_b,
        side_a,
        side_b,
        projection
    );
}

static void append_portal_surface(
    RenderLayer *layer,
    const LevelView *level,
    uint8_t portal_index,
    fixed_t eye_z,
    int24_t horizon
) {
    const LevelPortal *portal = &level->portals[portal_index];
    EdgeProjection projection;
    uint8_t previous_count = layer->count;

    if (!project_portal(level, portal_index, &projection) ||
        !projection_overlaps_layer(&projection, layer)) {
        return;
    }
    append_surface(
        layer,
        &projection,
        portal->top_z,
        portal->bottom_z,
        eye_z,
        horizon,
        0,
        0
    );
    if (layer->count != previous_count) {
        layer->surfaces[previous_count].portal_index = portal_index;
    }
}

static void collect_surfaces(
    const RenderCamera *camera,
    const LevelView *level,
    uint16_t visible_sectors,
    RenderLayer *layer
) {
    fixed_t eye_z = camera->eye_z;
    int24_t horizon = VIEW_CENTER_Y + camera->pitch;
    uint8_t sector_index;

    layer->count = 0;
    for (sector_index = 0; sector_index < level->header->sector_count; ++sector_index) {
        const LevelSector *sector;
        uint8_t edge_offset;

        if ((visible_sectors & (1u << sector_index)) == 0) continue;
        sector = &level->sectors[sector_index];
        for (edge_offset = 0; edge_offset < sector->edge_count; ++edge_offset) {
            const LevelEdge *edge = &level->edges[sector->first_edge + edge_offset];
            uint8_t flat_edge_index = (uint8_t)(sector->first_edge + edge_offset);
            EdgeProjection projection;

            if (edge->neighbor_sector == LEVEL_NO_NEIGHBOR &&
                !solid_edge_faces_camera(camera, level, edge)) {
                continue;
            }
            if (!project_edge(edge, &projection)) continue;
            if (!projection_overlaps_layer(&projection, layer)) continue;
            if (edge->neighbor_sector == LEVEL_NO_NEIGHBOR) {
                uint8_t wall_surface_index = layer->count;

                append_surface(
                    layer,
                    &projection,
                    sector->ceiling_z,
                    sector->floor_z,
                    eye_z,
                    horizon,
                    edge->color,
                    1
                );
                if (layer->count != wall_surface_index &&
                    edge_portal_index[flat_edge_index] != LEVEL_NO_PORTAL) {
                    uint8_t portal_surface_index = layer->count;

                    append_portal_surface(
                        layer,
                        level,
                        edge_portal_index[flat_edge_index],
                        eye_z,
                        horizon
                    );
                    if (layer->count != portal_surface_index) {
                        layer->surfaces[portal_surface_index].depth =
                            layer->surfaces[wall_surface_index].depth;
                    }
                }
            } else {
                const LevelSector *neighbor = &level->sectors[(uint8_t)edge->neighbor_sector];

                if (neighbor->ceiling_z < sector->ceiling_z) {
                    append_surface(
                        layer,
                        &projection,
                        sector->ceiling_z,
                        neighbor->ceiling_z,
                        eye_z,
                        horizon,
                        edge->color,
                        0
                    );
                }
                if (neighbor->floor_z > sector->floor_z) {
                    append_surface(
                        layer,
                        &projection,
                        neighbor->floor_z,
                        sector->floor_z,
                        eye_z,
                        horizon,
                        edge->color,
                        0
                    );
                }
            }
        }
    }
}

static void sort_surfaces_far_to_near(RenderLayer *layer) {
    uint8_t index;

    for (index = 1; index < layer->count; ++index) {
        DrawSurface value = layer->surfaces[index];
        uint8_t position = index;

        while (position > 0 && layer->surfaces[position - 1].depth < value.depth) {
            layer->surfaces[position] = layer->surfaces[position - 1];
            --position;
        }
        layer->surfaces[position] = value;
    }
}

static void mark_surface_column_coverage(
    const DrawSurface *surface,
    const RenderLayer *layer,
    uint8_t *covered_columns
) {
    int24_t x_a = surface->x_a;
    int24_t x_b = surface->x_b;
    int24_t top_a = surface->top_a;
    int24_t top_b = surface->top_b;
    int24_t bottom_a = surface->bottom_a;
    int24_t bottom_b = surface->bottom_b;
    int24_t width;
    int24_t top_slope;
    int24_t bottom_slope;
    int24_t top_value;
    int24_t bottom_value;
    int24_t top_step;
    int24_t bottom_step;
    uint8_t first_column;
    uint8_t last_column;
    uint8_t column;

    if (x_a > x_b) {
        int24_t swap;
        swap = x_a; x_a = x_b; x_b = swap;
        swap = top_a; top_a = top_b; top_b = swap;
        swap = bottom_a; bottom_a = bottom_b; bottom_b = swap;
    }
    if (x_b < 0 || x_a >= GFX_LCD_WIDTH || x_a == x_b) return;
    width = x_b - x_a;
    top_slope = wall_slope(top_b - top_a, width);
    bottom_slope = wall_slope(bottom_b - bottom_a, width);
    first_column = x_a <= 0 ? 0 : (uint8_t)(x_a / RENDER_SCALE_X);
    last_column = x_b >= GFX_LCD_WIDTH ?
        RENDER_WIDTH - 1 : (uint8_t)(x_b / RENDER_SCALE_X);
    if (first_column < layer->clip_left) first_column = layer->clip_left;
    if (last_column > layer->clip_right) last_column = layer->clip_right;
    if (first_column > last_column) return;

    top_value = top_a * FIXED_ONE +
        top_slope * ((int24_t)first_column * RENDER_SCALE_X + 2 - x_a);
    bottom_value = bottom_a * FIXED_ONE +
        bottom_slope * ((int24_t)first_column * RENDER_SCALE_X + 2 - x_a);
    top_step = top_slope * RENDER_SCALE_X;
    bottom_step = bottom_slope * RENDER_SCALE_X;
    for (column = first_column; column <= last_column; ++column) {
        int24_t logical_top = top_value / (FIXED_ONE * RENDER_SCALE_Y);
        int24_t logical_bottom = bottom_value / (FIXED_ONE * RENDER_SCALE_Y);

        if (logical_top <= layer->clip_top[column] &&
            logical_bottom >= layer->clip_bottom[column]) {
            covered_columns[column] = 1;
        }
        top_value += top_step;
        bottom_value += bottom_step;
    }
}

static void mark_fully_occluded_surfaces(RenderLayer *layer) {
    uint8_t covered_columns[RENDER_WIDTH] = {0};
    uint8_t fully_covered_columns[RENDER_WIDTH] = {0};
    uint8_t reverse = layer->count;
    uint8_t has_portal_surface = 0;
    uint8_t scan;

    for (scan = 0; scan < layer->count; ++scan) {
        if (layer->surfaces[scan].portal_index != LEVEL_NO_PORTAL) {
            has_portal_surface = 1;
            break;
        }
    }

    while (reverse > 0) {
        DrawSurface *surface = &layer->surfaces[--reverse];
        int24_t left = surface->x_a < surface->x_b ? surface->x_a : surface->x_b;
        int24_t right = surface->x_a > surface->x_b ? surface->x_a : surface->x_b;
        uint8_t first;
        uint8_t last;
        uint8_t column;
        uint8_t all_covered = 1;
        const uint8_t *coverage = surface->portal_index == LEVEL_NO_PORTAL ?
            covered_columns : fully_covered_columns;

        if (right < 0 || left >= GFX_LCD_WIDTH) {
            surface->visible = 0;
            continue;
        }
        if (left < 0) left = 0;
        if (right >= GFX_LCD_WIDTH) right = GFX_LCD_WIDTH - 1;
        first = (uint8_t)(left / RENDER_SCALE_X);
        last = (uint8_t)(right / RENDER_SCALE_X);
        if (first < layer->clip_left) first = layer->clip_left;
        if (last > layer->clip_right) last = layer->clip_right;
        if (first > last) {
            surface->visible = 0;
            continue;
        }

        for (column = first; column <= last; ++column) {
            if (!coverage[column]) {
                all_covered = 0;
                break;
            }
        }
        surface->visible = (uint8_t)!all_covered;
        if (surface->visible && surface->opaque) {
            for (column = first; column <= last; ++column) {
                covered_columns[column] = 1;
            }
            if (has_portal_surface) {
                mark_surface_column_coverage(surface, layer, fully_covered_columns);
            }
        }
    }
}

static void fill_surface(const DrawSurface *surface, const RenderLayer *layer) {
    int24_t x_a = surface->x_a;
    int24_t x_b = surface->x_b;
    int24_t top_a = surface->top_a;
    int24_t top_b = surface->top_b;
    int24_t bottom_a = surface->bottom_a;
    int24_t bottom_b = surface->bottom_b;
    int24_t width;
    int24_t top_slope;
    int24_t bottom_slope;
    int24_t top_value;
    int24_t bottom_value;
    int24_t top_step;
    int24_t bottom_step;
    uint8_t first_column;
    uint8_t last_column;
    uint8_t column;

    if (x_a > x_b) {
        int24_t swap;
        swap = x_a; x_a = x_b; x_b = swap;
        swap = top_a; top_a = top_b; top_b = swap;
        swap = bottom_a; bottom_a = bottom_b; bottom_b = swap;
    }
    if (x_b < 0 || x_a >= GFX_LCD_WIDTH || x_a == x_b) return;

    width = x_b - x_a;
    top_slope = wall_slope(top_b - top_a, width);
    bottom_slope = wall_slope(bottom_b - bottom_a, width);
    first_column = x_a <= 0 ? 0 : (uint8_t)(x_a / RENDER_SCALE_X);
    last_column = x_b >= GFX_LCD_WIDTH ?
        RENDER_WIDTH - 1 : (uint8_t)(x_b / RENDER_SCALE_X);
    if (first_column < layer->clip_left) first_column = layer->clip_left;
    if (last_column > layer->clip_right) last_column = layer->clip_right;
    if (first_column > last_column) return;

    top_value = top_a * FIXED_ONE +
        top_slope * ((int24_t)first_column * RENDER_SCALE_X + 2 - x_a);
    bottom_value = bottom_a * FIXED_ONE +
        bottom_slope * ((int24_t)first_column * RENDER_SCALE_X + 2 - x_a);
    top_step = top_slope * RENDER_SCALE_X;
    bottom_step = bottom_slope * RENDER_SCALE_X;

    for (column = first_column; column <= last_column; ++column) {
        if (bottom_value >= 0 && top_value < GFX_LCD_HEIGHT * FIXED_ONE) {
            uint8_t top = top_value <= 0 ? 0 :
                (uint8_t)(top_value / (FIXED_ONE * RENDER_SCALE_Y));
            uint8_t bottom = bottom_value >= GFX_LCD_HEIGHT * FIXED_ONE ?
                RENDER_HEIGHT - 1 : (bottom_value <= 0 ? 0 :
                (uint8_t)(bottom_value / (FIXED_ONE * RENDER_SCALE_Y)));

            if (top < layer->clip_top[column]) top = layer->clip_top[column];
            if (bottom > layer->clip_bottom[column]) bottom = layer->clip_bottom[column];

            if (bottom >= top) {
                uint8_t count = (uint8_t)(bottom - top + 1);
                uint8_t *pixel = &low_frame.data[low_row_offsets[top] + column];

                while (count-- > 0) {
                    *pixel = surface->color;
                    pixel += RENDER_WIDTH;
                }
            }
        }
        top_value += top_step;
        bottom_value += bottom_step;
    }
}

static fixed_t absolute_fixed(fixed_t value) {
    return value < 0 ? -value : value;
}

static void normalize_direction(fixed_t *x, fixed_t *y) {
    fixed_t absolute_x = absolute_fixed(*x);
    fixed_t absolute_y = absolute_fixed(*y);
    fixed_t maximum = absolute_x > absolute_y ? absolute_x : absolute_y;
    fixed_t minimum = absolute_x > absolute_y ? absolute_y : absolute_x;
    fixed_t approximate_length = maximum + (minimum * 3) / 8;

    if (approximate_length <= 0) {
        *x = FIXED_ONE;
        *y = 0;
        return;
    }
    *x = (fixed_t)(((int32_t)*x * FIXED_ONE) / approximate_length);
    *y = (fixed_t)(((int32_t)*y * FIXED_ONE) / approximate_length);
}

static uint8_t transform_xy_through_portal(
    const LevelView *level,
    uint8_t portal_index,
    fixed_t input_x,
    fixed_t input_y,
    fixed_t *output_x,
    fixed_t *output_y
) {
    const LevelPortal *source_portal = &level->portals[portal_index];
    const LevelPortal *destination_portal =
        &level->portals[source_portal->linked_portal];
    const LevelEdge *source_edge = &level->edges[source_portal->edge];
    const LevelEdge *destination_edge = &level->edges[destination_portal->edge];
    const LevelVertex *source_a = &level->vertices[source_edge->vertex_a];
    const LevelVertex *source_b = &level->vertices[source_edge->vertex_b];
    const LevelVertex *destination_a = &level->vertices[destination_edge->vertex_a];
    const LevelVertex *destination_b = &level->vertices[destination_edge->vertex_b];
    int24_t source_dx = source_b->x - source_a->x;
    int24_t source_dy = source_b->y - source_a->y;
    int24_t destination_dx = destination_b->x - destination_a->x;
    int24_t destination_dy = destination_b->y - destination_a->y;
    int24_t source_center_x = source_a->x +
        ((int32_t)source_dx * source_portal->center_u) / FIXED_ONE;
    int24_t source_center_y = source_a->y +
        ((int32_t)source_dy * source_portal->center_u) / FIXED_ONE;
    int24_t destination_center_x = destination_a->x +
        ((int32_t)destination_dx * destination_portal->center_u) / FIXED_ONE;
    int24_t destination_center_y = destination_a->y +
        ((int32_t)destination_dy * destination_portal->center_u) / FIXED_ONE;
    int24_t relative_x = input_x / 16 - source_center_x;
    int24_t relative_y = input_y / 16 - source_center_y;
    int32_t dot = (int32_t)relative_x * source_dx +
        (int32_t)relative_y * source_dy;
    int32_t cross = (int32_t)source_dx * relative_y -
        (int32_t)source_dy * relative_x;
    int32_t source_length_squared = (int32_t)source_dx * source_dx +
        (int32_t)source_dy * source_dy;
    int24_t transformed_x;
    int24_t transformed_y;

    if (source_length_squared <= 0) return 0;
    transformed_x = destination_center_x + (int24_t)(
        (-(int32_t)destination_dx * dot + (int32_t)destination_dy * cross) /
        source_length_squared
    );
    transformed_y = destination_center_y + (int24_t)(
        (-(int32_t)destination_dy * dot - (int32_t)destination_dx * cross) /
        source_length_squared
    );
    *output_x = (fixed_t)transformed_x * 16;
    *output_y = (fixed_t)transformed_y * 16;
    return 1;
}

static uint8_t transform_direction_through_portal(
    const LevelView *level,
    uint8_t portal_index,
    fixed_t input_x,
    fixed_t input_y,
    fixed_t *output_x,
    fixed_t *output_y
) {
    const LevelPortal *source_portal = &level->portals[portal_index];
    const LevelPortal *destination_portal =
        &level->portals[source_portal->linked_portal];
    const LevelEdge *source_edge = &level->edges[source_portal->edge];
    const LevelEdge *destination_edge = &level->edges[destination_portal->edge];
    const LevelVertex *source_a = &level->vertices[source_edge->vertex_a];
    const LevelVertex *source_b = &level->vertices[source_edge->vertex_b];
    const LevelVertex *destination_a = &level->vertices[destination_edge->vertex_a];
    const LevelVertex *destination_b = &level->vertices[destination_edge->vertex_b];
    int24_t source_dx = source_b->x - source_a->x;
    int24_t source_dy = source_b->y - source_a->y;
    int24_t destination_dx = destination_b->x - destination_a->x;
    int24_t destination_dy = destination_b->y - destination_a->y;
    int32_t dot = (int32_t)input_x * source_dx + (int32_t)input_y * source_dy;
    int32_t cross = (int32_t)source_dx * input_y - (int32_t)source_dy * input_x;
    int32_t source_length_squared = (int32_t)source_dx * source_dx +
        (int32_t)source_dy * source_dy;

    if (source_length_squared <= 0) return 0;
    *output_x = (fixed_t)(
        (-(int32_t)destination_dx * dot + (int32_t)destination_dy * cross) /
        source_length_squared
    );
    *output_y = (fixed_t)(
        (-(int32_t)destination_dy * dot - (int32_t)destination_dx * cross) /
        source_length_squared
    );
    normalize_direction(output_x, output_y);
    return 1;
}

static fixed_t transform_z_through_portal(
    const LevelView *level,
    uint8_t portal_index,
    fixed_t source_z
) {
    const LevelPortal *source = &level->portals[portal_index];
    const LevelPortal *destination = &level->portals[source->linked_portal];
    fixed_t source_height = source->top_z - source->bottom_z;
    fixed_t destination_height = destination->top_z - destination->bottom_z;

    return destination->bottom_z + (fixed_t)(
        ((int32_t)(source_z - source->bottom_z) * destination_height) /
        source_height
    );
}

static uint16_t angle_for_direction(fixed_t x, fixed_t y) {
    int32_t best_dot = INT32_MIN;
    uint8_t best_index = 0;
    uint8_t index;

    for (index = 0; index < ANGLE_STEPS; ++index) {
        int32_t dot = (int32_t)x * direction_x[index] +
            (int32_t)y * direction_y[index];
        if (dot > best_dot) {
            best_dot = dot;
            best_index = index;
        }
    }
    return (uint16_t)best_index << ANGLE_FRACTION_BITS;
}

static uint8_t try_move_through_portal(
    EngineState *state,
    const LevelView *level,
    fixed_t candidate_x,
    fixed_t candidate_y
) {
    int24_t start_x = state->x / 16;
    int24_t start_y = state->y / 16;
    int24_t end_x = candidate_x / 16;
    int24_t end_y = candidate_y / 16;
    uint8_t portal_index;

    for (portal_index = 0; portal_index < level->header->portal_count; ++portal_index) {
        const LevelPortal *portal = &level->portals[portal_index];
        const LevelEdge *edge;
        const LevelVertex *a;
        const LevelVertex *b;
        int24_t edge_x;
        int24_t edge_y;
        int32_t start_side;
        int32_t end_side;
        int32_t denominator;
        int24_t intersection_fraction;
        int24_t intersection_x;
        int24_t intersection_y;
        int24_t center_x;
        int24_t center_y;
        int32_t edge_length_squared;
        int24_t portal_u;
        fixed_t body_center;
        fixed_t transformed_x;
        fixed_t transformed_y;
        fixed_t transformed_direction_x;
        fixed_t transformed_direction_y;
        fixed_t transformed_center_z;
        fixed_t transformed_z;
        uint8_t destination_sector;
        const LevelSector *destination;

        if ((portal->flags & LEVEL_PORTAL_ENABLED) == 0 ||
            edge_sector_index[portal->edge] != state->sector) {
            continue;
        }
        edge = &level->edges[portal->edge];
        a = &level->vertices[edge->vertex_a];
        b = &level->vertices[edge->vertex_b];
        edge_x = b->x - a->x;
        edge_y = b->y - a->y;
        start_side = (int32_t)edge_x * (start_y - a->y) -
            (int32_t)edge_y * (start_x - a->x);
        end_side = (int32_t)edge_x * (end_y - a->y) -
            (int32_t)edge_y * (end_x - a->x);
        if (start_side == 0 ||
            (start_side > 0 && end_side > 0) ||
            (start_side < 0 && end_side < 0)) {
            continue;
        }
        denominator = start_side - end_side;
        if (denominator == 0) continue;
        intersection_fraction = (int24_t)(
            ((int32_t)start_side * FIXED_ONE) / denominator
        );
        if (intersection_fraction < 0 || intersection_fraction > FIXED_ONE) continue;
        intersection_x = start_x + (int24_t)(
            ((int32_t)(end_x - start_x) * intersection_fraction) / FIXED_ONE
        );
        intersection_y = start_y + (int24_t)(
            ((int32_t)(end_y - start_y) * intersection_fraction) / FIXED_ONE
        );
        center_x = a->x + ((int32_t)edge_x * portal->center_u) / FIXED_ONE;
        center_y = a->y + ((int32_t)edge_y * portal->center_u) / FIXED_ONE;
        edge_length_squared = (int32_t)edge_x * edge_x + (int32_t)edge_y * edge_y;
        if (edge_length_squared <= 0) continue;
        portal_u = (int24_t)(
            ((int32_t)(intersection_x - center_x) * edge_x +
             (int32_t)(intersection_y - center_y) * edge_y) * FIXED_ONE /
            edge_length_squared
        );
        if (portal_u < -(int24_t)portal->half_width ||
            portal_u > portal->half_width) {
            continue;
        }
        body_center = state->z + PLAYER_HEIGHT / 2;
        if (body_center < portal->bottom_z || body_center > portal->top_z ||
            portal->top_z - portal->bottom_z < PLAYER_HEIGHT) {
            continue;
        }
        if (!transform_xy_through_portal(
                level,
                portal_index,
                candidate_x,
                candidate_y,
                &transformed_x,
                &transformed_y
            )) {
            continue;
        }
        destination_sector = edge_sector_index[
            level->portals[portal->linked_portal].edge
        ];
        if (destination_sector >= level->header->sector_count ||
            !point_in_sector(level, destination_sector, transformed_x, transformed_y)) {
            continue;
        }
        transformed_center_z = transform_z_through_portal(
            level,
            portal_index,
            body_center
        );
        transformed_z = transformed_center_z - PLAYER_HEIGHT / 2;
        destination = &level->sectors[destination_sector];
        if (transformed_z < destination->floor_z) transformed_z = destination->floor_z;
        if (transformed_z + PLAYER_HEIGHT > destination->ceiling_z) continue;

        direction_for_angle(
            state->angle,
            &transformed_direction_x,
            &transformed_direction_y
        );
        if (!transform_direction_through_portal(
                level,
                portal_index,
                transformed_direction_x,
                transformed_direction_y,
                &transformed_direction_x,
                &transformed_direction_y
            )) {
            continue;
        }
        state->x = transformed_x;
        state->y = transformed_y;
        state->z = transformed_z;
        state->sector = destination_sector;
        state->angle = angle_for_direction(
            transformed_direction_x,
            transformed_direction_y
        );
        state->grounded = (uint8_t)(state->z <= destination->floor_z);
        return 1;
    }
    return 0;
}

static void prepare_level_tables(const LevelView *level) {
    uint8_t sector_index;
    uint8_t portal_index;

    memset(edge_portal_index, LEVEL_NO_PORTAL, sizeof(edge_portal_index));
    memset(edge_sector_index, LEVEL_NO_PORTAL, sizeof(edge_sector_index));
    for (sector_index = 0; sector_index < level->header->sector_count; ++sector_index) {
        const LevelSector *sector = &level->sectors[sector_index];
        uint8_t edge_offset;

        sector_visibility[sector_index] = connected_sector_mask(level, sector_index);
        for (edge_offset = 0; edge_offset < sector->edge_count; ++edge_offset) {
            edge_sector_index[sector->first_edge + edge_offset] = sector_index;
        }
    }
    for (portal_index = 0; portal_index < level->header->portal_count; ++portal_index) {
        const LevelPortal *portal = &level->portals[portal_index];
        if ((portal->flags & LEVEL_PORTAL_ENABLED) != 0) {
            edge_portal_index[portal->edge] = portal_index;
        }
    }
}

uint8_t engine_init(EngineState *state, LevelView *level) {
    if (state == NULL || level == NULL || level->header == NULL) return 0;

    state->x = (fixed_t)level->header->spawn_x * 16;
    state->y = (fixed_t)level->header->spawn_y * 16;
    state->sector = level->header->spawn_sector;
    state->z = level->header->spawn_z + level->sectors[state->sector].floor_z;
    state->vertical_velocity = 0;
    state->angle = (uint16_t)level->header->spawn_angle << ANGLE_FRACTION_BITS;
    state->pitch = 0;
    state->previous_buttons = 0;
    state->grounded = 1;
    prepare_level_tables(level);
    return 1;
}

void engine_graphics_init(void) {
    uint8_t row;
    uint16_t offset = 0;
    uint16_t index;

    low_frame.width = RENDER_WIDTH;
    low_frame.height = RENDER_HEIGHT;
    for (row = 0; row < RENDER_HEIGHT; ++row) {
        low_row_offsets[row] = offset;
        offset += RENDER_WIDTH;
    }
    projection_scale_table[0] = PROJECTION_SCALE * FIXED_ONE;
    for (index = 1; index < PROJECTION_TABLE_SIZE; ++index) {
        projection_scale_table[index] = (uint16_t)(
            (PROJECTION_SCALE * FIXED_ONE) /
            ((uint24_t)index << PROJECTION_TABLE_SHIFT)
        );
    }
    wall_width_reciprocal[0] = 0;
    for (index = 1; index < WALL_WIDTH_RECIPROCAL_SIZE; ++index) {
        wall_width_reciprocal[index] = (uint16_t)(65535u / index);
    }
    gfx_palette[COLOR_BLACK] = gfx_RGBTo1555(0, 0, 0);
    gfx_palette[COLOR_CEILING] = gfx_RGBTo1555(18, 20, 36);
    gfx_palette[COLOR_FLOOR_FAR] = gfx_RGBTo1555(42, 42, 46);
    gfx_palette[COLOR_FLOOR_MID] = gfx_RGBTo1555(51, 51, 55);
    gfx_palette[COLOR_FLOOR_NEAR] = gfx_RGBTo1555(59, 59, 63);
    gfx_palette[COLOR_GREEN_DARK] = gfx_RGBTo1555(20, 110, 45);
    gfx_palette[COLOR_GREEN] = gfx_RGBTo1555(35, 210, 75);
    gfx_palette[COLOR_RED_DARK] = gfx_RGBTo1555(125, 28, 28);
    gfx_palette[COLOR_RED] = gfx_RGBTo1555(225, 48, 48);
    gfx_palette[COLOR_BLUE_DARK] = gfx_RGBTo1555(25, 62, 145);
    gfx_palette[COLOR_BLUE] = gfx_RGBTo1555(42, 100, 245);
    gfx_palette[COLOR_STEP] = gfx_RGBTo1555(150, 105, 38);
    gfx_palette[COLOR_HUD] = gfx_RGBTo1555(235, 235, 235);
}

uint8_t engine_update(
    EngineState *state,
    const LevelView *level,
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
    fixed_t direction_forward_x;
    fixed_t direction_forward_y;
    fixed_t move_amount;
    fixed_t delta_x;
    fixed_t delta_y;
    int24_t turn_amount;
    fixed_t floor_z;
    fixed_t ceiling_z;

    state->previous_buttons = buttons;
    if (ticks_per_second == 0) return 0;
    maximum_ticks = ticks_per_second / 8u;
    if (elapsed_ticks > maximum_ticks) elapsed_ticks = maximum_ticks;

    if ((pressed & ENGINE_BUTTON_JUMP) != 0 && state->grounded) {
        state->vertical_velocity = JUMP_SPEED;
        state->grounded = 0;
    }

    turn_amount = (int24_t)(((int32_t)TURN_SPEED *
        (1 << ANGLE_FRACTION_BITS) * elapsed_ticks) / ticks_per_second);
    state->angle = (uint16_t)((state->angle + turn_axis * turn_amount) & ANGLE_MASK);
    if (look_axis != 0) {
        int24_t look_amount = (int24_t)(((int32_t)LOOK_SPEED * elapsed_ticks) /
            ticks_per_second);
        int24_t next_pitch = state->pitch + look_axis * look_amount;

        if (next_pitch > PITCH_LIMIT) next_pitch = PITCH_LIMIT;
        if (next_pitch < -PITCH_LIMIT) next_pitch = -PITCH_LIMIT;
        state->pitch = (int16_t)next_pitch;
    }

    direction_for_angle(state->angle, &direction_forward_x, &direction_forward_y);
    move_amount = (fixed_t)(((int32_t)MOVE_SPEED * elapsed_ticks) / ticks_per_second);
    delta_x = fixed_mul(direction_forward_x, move_axis * move_amount);
    delta_y = fixed_mul(direction_forward_y, move_axis * move_amount);
    if (delta_x != 0) {
        if (try_move_axis(state, level, state->x + delta_x, state->y)) {
            delta_y = 0;
        }
    }
    if (delta_y != 0) {
        try_move_axis(state, level, state->x, state->y + delta_y);
    }

    floor_z = level->sectors[state->sector].floor_z;
    ceiling_z = level->sectors[state->sector].ceiling_z;
    if (!state->grounded || state->vertical_velocity != 0) {
        state->vertical_velocity -= (fixed_t)(
            ((int32_t)GRAVITY * elapsed_ticks) / ticks_per_second
        );
        state->z += (fixed_t)(
            ((int32_t)state->vertical_velocity * elapsed_ticks) / ticks_per_second
        );
        if (state->z + PLAYER_HEIGHT > ceiling_z) {
            state->z = ceiling_z - PLAYER_HEIGHT;
            if (state->vertical_velocity > 0) state->vertical_velocity = 0;
        }
        if (state->z <= floor_z) {
            state->z = floor_z;
            state->vertical_velocity = 0;
            state->grounded = 1;
        }
    } else if (state->z != floor_z) {
        state->z = floor_z;
    }

    return (uint8_t)(
        state->x != previous.x ||
        state->y != previous.y ||
        state->z != previous.z ||
        state->angle != previous.angle ||
        state->pitch != previous.pitch ||
        state->sector != previous.sector
    );
}

static void draw_hud_glyph(uint8_t *frame, uint8_t glyph, uint8_t x, uint8_t y) {
    uint8_t row;

    for (row = 0; row < 5; ++row) {
        uint8_t bits = hud_glyphs[glyph][row];
        uint8_t column;

        for (column = 0; column < 3; ++column) {
            if ((bits & (4u >> column)) != 0) {
                frame[(uint16_t)(y + row) * GFX_LCD_WIDTH + x + column] = COLOR_HUD;
            }
        }
    }
}

static void draw_fps_counter(uint8_t *frame, uint8_t fps, uint8_t external_level) {
    uint8_t row;

    for (row = 0; row < 8; ++row) {
        memset(&frame[(uint16_t)row * GFX_LCD_WIDTH], COLOR_BLACK, 36);
    }
    draw_hud_glyph(frame, 0, 2, 2);
    draw_hud_glyph(frame, 1, 6, 2);
    draw_hud_glyph(frame, 2, 10, 2);
    draw_hud_glyph(frame, (uint8_t)(3 + fps / 100u), 18, 2);
    draw_hud_glyph(frame, (uint8_t)(3 + (fps / 10u) % 10u), 22, 2);
    draw_hud_glyph(frame, (uint8_t)(3 + fps % 10u), 26, 2);
    draw_hud_glyph(frame, external_level ? 13 : 14, 32, 2);
}

static void clear_low_frame(int24_t full_horizon) {
    uint8_t horizon = (uint8_t)(full_horizon / RENDER_SCALE_Y);
    uint8_t floor_height = (uint8_t)(RENDER_HEIGHT - horizon);
    uint8_t far_height = floor_height / 3;
    uint8_t middle_height = floor_height / 3;
    uint16_t offset = 0;

    if (horizon > 0) {
        uint16_t count = (uint16_t)horizon * RENDER_WIDTH;
        memset(low_frame.data, COLOR_CEILING, count);
        offset = count;
    }
    if (far_height > 0) {
        uint16_t count = (uint16_t)far_height * RENDER_WIDTH;
        memset(&low_frame.data[offset], COLOR_FLOOR_FAR, count);
        offset += count;
    }
    if (middle_height > 0) {
        uint16_t count = (uint16_t)middle_height * RENDER_WIDTH;
        memset(&low_frame.data[offset], COLOR_FLOOR_MID, count);
        offset += count;
    }
    if (offset < sizeof(low_frame.data)) {
        memset(
            &low_frame.data[offset],
            COLOR_FLOOR_NEAR,
            sizeof(low_frame.data) - offset
        );
    }
}

static uint8_t linked_render_camera(
    const LevelView *level,
    uint8_t portal_index,
    const RenderCamera *source,
    RenderCamera *destination
) {
    const LevelPortal *portal = &level->portals[portal_index];
    uint8_t destination_sector = edge_sector_index[
        level->portals[portal->linked_portal].edge
    ];

    if (destination_sector >= level->header->sector_count ||
        !transform_xy_through_portal(
            level,
            portal_index,
            source->x,
            source->y,
            &destination->x,
            &destination->y
        ) ||
        !transform_direction_through_portal(
            level,
            portal_index,
            source->forward_x,
            source->forward_y,
            &destination->forward_x,
            &destination->forward_y
        )) {
        return 0;
    }
    destination->eye_z = transform_z_through_portal(
        level,
        portal_index,
        source->eye_z
    );
    destination->pitch = source->pitch;
    destination->sector = destination_sector;
    return 1;
}

static uint8_t build_portal_clip(
    const DrawSurface *surface,
    const RenderLayer *parent,
    RenderLayer *child
) {
    int24_t x_a = surface->x_a;
    int24_t x_b = surface->x_b;
    int24_t top_a = surface->top_a;
    int24_t top_b = surface->top_b;
    int24_t bottom_a = surface->bottom_a;
    int24_t bottom_b = surface->bottom_b;
    int24_t width;
    int24_t top_slope;
    int24_t bottom_slope;
    int24_t top_value;
    int24_t bottom_value;
    int24_t top_step;
    int24_t bottom_step;
    uint8_t first_column;
    uint8_t last_column;
    uint8_t column;
    uint8_t any = 0;

    memset(child->clip_top, 255, sizeof(child->clip_top));
    memset(child->clip_bottom, 0, sizeof(child->clip_bottom));
    child->clip_left = RENDER_WIDTH;
    child->clip_right = 0;

    if (x_a > x_b) {
        int24_t swap;
        swap = x_a; x_a = x_b; x_b = swap;
        swap = top_a; top_a = top_b; top_b = swap;
        swap = bottom_a; bottom_a = bottom_b; bottom_b = swap;
    }
    if (x_b < 0 || x_a >= GFX_LCD_WIDTH || x_a == x_b) return 0;

    width = x_b - x_a;
    top_slope = wall_slope(top_b - top_a, width);
    bottom_slope = wall_slope(bottom_b - bottom_a, width);
    first_column = x_a <= 0 ? 0 : (uint8_t)(x_a / RENDER_SCALE_X);
    last_column = x_b >= GFX_LCD_WIDTH ?
        RENDER_WIDTH - 1 : (uint8_t)(x_b / RENDER_SCALE_X);
    if (first_column < parent->clip_left) first_column = parent->clip_left;
    if (last_column > parent->clip_right) last_column = parent->clip_right;
    if (first_column > last_column) return 0;

    top_value = top_a * FIXED_ONE +
        top_slope * ((int24_t)first_column * RENDER_SCALE_X + 2 - x_a);
    bottom_value = bottom_a * FIXED_ONE +
        bottom_slope * ((int24_t)first_column * RENDER_SCALE_X + 2 - x_a);
    top_step = top_slope * RENDER_SCALE_X;
    bottom_step = bottom_slope * RENDER_SCALE_X;

    for (column = first_column; column <= last_column; ++column) {
        if (bottom_value >= 0 && top_value < GFX_LCD_HEIGHT * FIXED_ONE &&
            parent->clip_top[column] <= parent->clip_bottom[column]) {
            uint8_t top = top_value <= 0 ? 0 :
                (uint8_t)(top_value / (FIXED_ONE * RENDER_SCALE_Y));
            uint8_t bottom = bottom_value >= GFX_LCD_HEIGHT * FIXED_ONE ?
                RENDER_HEIGHT - 1 : (bottom_value <= 0 ? 0 :
                (uint8_t)(bottom_value / (FIXED_ONE * RENDER_SCALE_Y)));

            if (top < parent->clip_top[column]) top = parent->clip_top[column];
            if (bottom > parent->clip_bottom[column]) bottom = parent->clip_bottom[column];
            if (top <= bottom) {
                child->clip_top[column] = top;
                child->clip_bottom[column] = bottom;
                if (!any) child->clip_left = column;
                child->clip_right = column;
                any = 1;
            }
        }
        top_value += top_step;
        bottom_value += bottom_step;
    }
    return any;
}

static void clear_layer_background(const RenderLayer *layer, int24_t full_horizon) {
    uint8_t horizon = (uint8_t)(full_horizon / RENDER_SCALE_Y);
    uint8_t floor_height = (uint8_t)(RENDER_HEIGHT - horizon);
    uint8_t far_end = horizon + floor_height / 3;
    uint8_t middle_end = far_end + floor_height / 3;
    uint8_t column;

    for (column = layer->clip_left; column <= layer->clip_right; ++column) {
        uint8_t row;
        uint8_t bottom = layer->clip_bottom[column];

        if (layer->clip_top[column] > bottom) continue;
        for (row = layer->clip_top[column]; row <= bottom; ++row) {
            uint8_t color = row < horizon ? COLOR_CEILING :
                (row < far_end ? COLOR_FLOOR_FAR :
                (row < middle_end ? COLOR_FLOOR_MID : COLOR_FLOOR_NEAR));
            low_frame.data[low_row_offsets[row] + column] = color;
        }
    }
}

static void render_camera_context(
    const LevelView *level,
    const RenderCamera *camera,
    uint8_t depth
) {
    RenderLayer *layer = &render_layers[depth];
    int24_t horizon = VIEW_CENTER_Y + camera->pitch;
    uint8_t index;

    if (horizon < 0) horizon = 0;
    if (horizon >= GFX_LCD_HEIGHT) horizon = GFX_LCD_HEIGHT - 1;
    transform_vertices(
        camera,
        level,
        camera->forward_x,
        camera->forward_y
    );
    collect_surfaces(
        camera,
        level,
        sector_visibility[camera->sector],
        layer
    );
    sort_surfaces_far_to_near(layer);
    mark_fully_occluded_surfaces(layer);

    if (depth == 0) {
        clear_low_frame(horizon);
    } else {
        clear_layer_background(layer, horizon);
    }
    for (index = 0; index < layer->count; ++index) {
        DrawSurface *surface = &layer->surfaces[index];

        if (!surface->visible) continue;
        if (surface->portal_index == LEVEL_NO_PORTAL) {
            fill_surface(surface, layer);
        } else if (depth < PORTAL_RECURSION_LIMIT) {
            RenderLayer *child = &render_layers[depth + 1];
            RenderCamera destination;

            if (build_portal_clip(surface, layer, child) &&
                linked_render_camera(
                    level,
                    surface->portal_index,
                    camera,
                    &destination
                )) {
                render_camera_context(level, &destination, depth + 1);
            }
        }
    }
}

void engine_render(
    const EngineState *state,
    const LevelView *level,
    uint8_t fps,
    uint8_t external_level
) {
    RenderCamera camera;
    fixed_t direction_forward_x;
    fixed_t direction_forward_y;
    int24_t horizon = VIEW_CENTER_Y + state->pitch;
    uint8_t column;
    uint8_t *frame;

    if (horizon < 0) horizon = 0;
    if (horizon >= GFX_LCD_HEIGHT) horizon = GFX_LCD_HEIGHT - 1;

    direction_for_angle(state->angle, &direction_forward_x, &direction_forward_y);
    camera.x = state->x;
    camera.y = state->y;
    camera.eye_z = state->z + EYE_HEIGHT;
    camera.forward_x = direction_forward_x;
    camera.forward_y = direction_forward_y;
    camera.pitch = state->pitch;
    camera.sector = state->sector;
    render_layers[0].clip_left = 0;
    render_layers[0].clip_right = RENDER_WIDTH - 1;
    for (column = 0; column < RENDER_WIDTH; ++column) {
        render_layers[0].clip_top[column] = 0;
        render_layers[0].clip_bottom[column] = RENDER_HEIGHT - 1;
    }
    render_camera_context(level, &camera, 0);
    present_low_frame_fast();

    frame = &gfx_vbuffer[0][0];
    memset(
        &frame[(uint24_t)horizon * GFX_LCD_WIDTH + GFX_LCD_WIDTH / 2 - 2],
        COLOR_HUD,
        5
    );
    if (horizon >= 2 && horizon < GFX_LCD_HEIGHT - 2) {
        uint8_t crosshair_y;
        for (crosshair_y = (uint8_t)(horizon - 2);
             crosshair_y <= horizon + 2;
             ++crosshair_y) {
            frame[(uint16_t)crosshair_y * GFX_LCD_WIDTH + GFX_LCD_WIDTH / 2] = COLOR_HUD;
        }
    }
    draw_fps_counter(frame, fps, external_level);
}
