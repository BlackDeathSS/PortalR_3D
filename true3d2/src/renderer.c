#include "internal.h"

#include <string.h>
#include <time.h>

uint8_t t3d2_root_color[T3D2_ROOT_WIDTH * T3D2_ROOT_HEIGHT];
uint16_t t3d2_root_depth[T3D2_ROOT_WIDTH * T3D2_ROOT_HEIGHT];
uint8_t t3d2_portal1_color[T3D2_PORTAL1_WIDTH * T3D2_PORTAL1_HEIGHT];
uint16_t t3d2_portal1_depth[T3D2_PORTAL1_WIDTH * T3D2_PORTAL1_HEIGHT];
uint8_t t3d2_portal2_color[T3D2_PORTAL2_WIDTH * T3D2_PORTAL2_HEIGHT];
uint16_t t3d2_portal2_depth[T3D2_PORTAL2_WIDTH * T3D2_PORTAL2_HEIGHT];

/* Stable scratch ABI consumed by span.s and gradient.s. Keeping this state
   private avoids per-pixel C call overhead; C retains the auditable edge walk
   while assembly owns gradient normalization, reciprocal setup and spans. */
uint8_t *t3d2_span_color;
uint16_t *t3d2_span_depth;
const uint8_t *t3d2_span_texture0;
const uint8_t *t3d2_span_texture1;
uint16_t t3d2_span_depth_value;
int16_t t3d2_span_depth_step;
uint24_t t3d2_span_u_value;
int24_t t3d2_span_u_step;
uint24_t t3d2_span_v_value;
int24_t t3d2_span_v_step;
uint8_t t3d2_span_length;
uint8_t t3d2_span_shade_offset;
uint8_t t3d2_span_texture_loaded;
uint8_t t3d2_span_texture_shift;
uint8_t *t3d2_solid_color_pointer;
uint16_t *t3d2_solid_depth_pointer;
uint16_t t3d2_solid_depth_value;
uint8_t t3d2_solid_length;
uint8_t t3d2_solid_color;
int24_t t3d2_gradient_input[6];
int24_t t3d2_gradient_output[6];
uint16_t t3d2_gradient_reciprocal;
uint24_t t3d2_gradient_area;

typedef struct {
    int16_t x;
    int16_t y;
    uint16_t inverse_depth;
    int16_t u;
    int16_t v;
} ReferenceVertex;

typedef struct {
    int24_t x;
    int24_t y;
    int24_t z;
    int24_t u;
    int24_t v;
} CameraVertex;

typedef struct {
    T3D2Vec3 position;
    T3D2Vec3 right;
    T3D2Vec3 up;
    T3D2Vec3 forward;
    uint16_t cell;
} RenderCamera;

typedef struct {
    uint8_t *color;
    uint16_t *depth;
    uint8_t width;
    uint8_t height;
    uint8_t layer;
    uint8_t focal;
} RenderTarget;

static const uint16_t layer_triangle_budget[3] = {96u, 64u, 32u};
static const uint16_t layer_sample_budget[3] = {4800u, 1200u, 300u};

static int32_t edge_twice(
    const ReferenceVertex *a,
    const ReferenceVertex *b,
    int16_t x_twice,
    int16_t y_twice
) {
    return (int32_t)(b->x - a->x) * (y_twice - 2 * a->y) -
           (int32_t)(b->y - a->y) * (x_twice - 2 * a->x);
}

static void reference_triangle(
    T3D2Engine *engine,
    uint8_t *color,
    uint16_t *depth,
    uint8_t width,
    uint8_t height,
    const ReferenceVertex *a,
    const ReferenceVertex *b,
    const ReferenceVertex *c,
    uint8_t shade,
    uint16_t *sample_counter
) {
    const ReferenceVertex *first = a;
    const ReferenceVertex *second = b;
    const ReferenceVertex *third = c;
    const ReferenceVertex *top;
    const ReferenceVertex *middle;
    const ReferenceVertex *bottom;
    int16_t minimum_x = first->x;
    int16_t maximum_x = first->x;
    int16_t minimum_y = first->y;
    int16_t maximum_y = first->y;
    int24_t area = (int24_t)edge_twice(first, second, (int16_t)(2 * third->x),
                                       (int16_t)(2 * third->y));
    int24_t step_wb_x;
    int24_t step_wc_x;
    int24_t step_wb_y;
    int24_t step_wc_y;
    int24_t depth_step_x;
    int24_t depth_step_y;
    int24_t u_step_x;
    int24_t u_step_y;
    int24_t v_step_x;
    int24_t v_step_y;
    int24_t long_x;
    int24_t long_step;
    int24_t short_x;
    int24_t short_step;
    int24_t depth_anchor;
    int24_t u_anchor;
    int24_t v_anchor;
    int16_t attribute_x;
    int16_t y;

    (void)engine;

    if (area < 0) {
        const ReferenceVertex *swap = second;

        second = third;
        third = swap;
        area = -area;
    }
    if (second->x < minimum_x) minimum_x = second->x;
    if (third->x < minimum_x) minimum_x = third->x;
    if (second->x > maximum_x) maximum_x = second->x;
    if (third->x > maximum_x) maximum_x = third->x;
    if (second->y < minimum_y) minimum_y = second->y;
    if (third->y < minimum_y) minimum_y = third->y;
    if (second->y > maximum_y) maximum_y = second->y;
    if (third->y > maximum_y) maximum_y = third->y;
    if (minimum_x < 0) minimum_x = 0;
    if (minimum_y < 0) minimum_y = 0;
    if (maximum_x >= width) maximum_x = (int16_t)(width - 1u);
    if (maximum_y >= height) maximum_y = (int16_t)(height - 1u);
    if (area < 4 || minimum_x > maximum_x || minimum_y > maximum_y) return;
    step_wb_x = -2 * (first->y - third->y);
    step_wc_x = -2 * (second->y - first->y);
    step_wb_y = 2 * (first->x - third->x);
    step_wc_y = 2 * (second->x - first->x);
    t3d2_gradient_input[0] =
        ((int24_t)(second->inverse_depth >> 2) - (first->inverse_depth >> 2)) *
            step_wb_x +
        ((int24_t)(third->inverse_depth >> 2) - (first->inverse_depth >> 2)) *
            step_wc_x;
    t3d2_gradient_input[1] =
        ((int24_t)(second->inverse_depth >> 2) - (first->inverse_depth >> 2)) *
            step_wb_y +
        ((int24_t)(third->inverse_depth >> 2) - (first->inverse_depth >> 2)) *
            step_wc_y;
    t3d2_gradient_input[2] = (second->u - first->u) * step_wb_x +
        (third->u - first->u) * step_wc_x;
    t3d2_gradient_input[3] = (second->u - first->u) * step_wb_y +
        (third->u - first->u) * step_wc_y;
    t3d2_gradient_input[4] = (second->v - first->v) * step_wb_x +
        (third->v - first->v) * step_wc_x;
    t3d2_gradient_input[5] = (second->v - first->v) * step_wb_y +
        (third->v - first->v) * step_wc_y;
    t3d2_gradient_area = (uint24_t)area;
    t3d2_triangle_normalize();
    t3d2_gradient_reciprocal =
        t3d2_reciprocal_q16[(uint8_t)t3d2_gradient_area];
    t3d2_triangle_gradients();
    depth_step_x = t3d2_gradient_output[0];
    depth_step_y = t3d2_gradient_output[1];
    u_step_x = t3d2_gradient_output[2];
    u_step_y = t3d2_gradient_output[3];
    v_step_x = t3d2_gradient_output[4];
    v_step_y = t3d2_gradient_output[5];
    /* Sort only for the scan conversion edges. Attribute gradients continue
       to use the consistently wound vertices above. The half-open y ranges
       and right edge below implement the same crack-free top-left ownership
       rule without testing every pixel in the bounding rectangle. */
    top = first;
    middle = second;
    bottom = third;
    if (top->y > middle->y) {
        const ReferenceVertex *swap = top;
        top = middle;
        middle = swap;
    }
    if (middle->y > bottom->y) {
        const ReferenceVertex *swap = middle;
        middle = bottom;
        bottom = swap;
    }
    if (top->y > middle->y) {
        const ReferenceVertex *swap = top;
        top = middle;
        middle = swap;
    }
    if (bottom->y == top->y) return;
    if (maximum_y >= bottom->y) maximum_y = (int16_t)(bottom->y - 1);
    if (minimum_y > maximum_y) return;
    long_step = ((int24_t)(bottom->x - top->x) << 8) /
        (bottom->y - top->y);
    long_x = ((int24_t)top->x << 8) + (long_step >> 1) +
        long_step * (minimum_y - top->y);
    if (middle->y != top->y && minimum_y < middle->y) {
        short_step = ((int24_t)(middle->x - top->x) << 8) /
            (middle->y - top->y);
        short_x = ((int24_t)top->x << 8) + (short_step >> 1) +
            short_step * (minimum_y - top->y);
    } else {
        short_step = ((int24_t)(bottom->x - middle->x) << 8) /
            (bottom->y - middle->y);
        short_x = ((int24_t)middle->x << 8) + (short_step >> 1) +
            short_step * (minimum_y - middle->y);
    }
    attribute_x = minimum_x;
    depth_anchor = (int24_t)(first->inverse_depth >> 2) * 128 +
        depth_step_x * (attribute_x - first->x) +
        depth_step_y * (minimum_y - first->y) +
        ((depth_step_x + depth_step_y) >> 1);
    u_anchor = (int24_t)first->u * 128 +
        u_step_x * (attribute_x - first->x) +
        u_step_y * (minimum_y - first->y) +
        ((u_step_x + u_step_y) >> 1);
    v_anchor = (int24_t)first->v * 128 +
        v_step_x * (attribute_x - first->x) +
        v_step_y * (minimum_y - first->y) +
        ((v_step_x + v_step_y) >> 1);

    for (y = minimum_y; y <= maximum_y; ++y) {
        int24_t left_x;
        int24_t right_x;
        int16_t span_start;
        int16_t span_end;
        int24_t depth_value;
        int24_t u_value;
        int24_t v_value;

        if (y == middle->y && middle->y != top->y &&
            middle->y != bottom->y) {
            short_step = ((int24_t)(bottom->x - middle->x) << 8) /
                (bottom->y - middle->y);
            short_x = ((int24_t)middle->x << 8) + (short_step >> 1);
        }
        if (long_x < short_x) {
            left_x = long_x;
            right_x = short_x;
        } else {
            left_x = short_x;
            right_x = long_x;
        }
        span_start = (int16_t)((left_x + 127) >> 8);
        span_end = (int16_t)(((right_x + 127) >> 8) - 1);
        if (span_start < minimum_x) span_start = minimum_x;
        if (span_end > maximum_x) span_end = maximum_x;
        if (span_start <= span_end) {
            while (attribute_x < span_start) {
                depth_anchor += depth_step_x;
                u_anchor += u_step_x;
                v_anchor += v_step_x;
                ++attribute_x;
            }
            while (attribute_x > span_start) {
                depth_anchor -= depth_step_x;
                u_anchor -= u_step_x;
                v_anchor -= v_step_x;
                --attribute_x;
            }
            depth_value = depth_anchor;
            u_value = u_anchor;
            v_value = v_anchor;
            t3d2_span_length = (uint8_t)(span_end - span_start + 1);
            t3d2_span_color = color + (uint16_t)y * width + (uint16_t)span_start;
            t3d2_span_depth = depth + (uint16_t)y * width + (uint16_t)span_start;
            t3d2_span_texture0 = engine->texture_half[0];
            t3d2_span_texture1 = engine->texture_half[1];
            t3d2_span_depth_value = (uint16_t)(depth_value >> 5);
            t3d2_span_depth_step = (int16_t)(depth_step_x >> 5);
            t3d2_span_u_value = (uint24_t)((int32_t)u_value << 1);
            t3d2_span_u_step = (int24_t)((int32_t)u_step_x << 1);
            t3d2_span_v_value = (uint24_t)((int32_t)v_value << 1);
            t3d2_span_v_step = (int24_t)((int32_t)v_step_x << 1);
            t3d2_span_shade_offset = (uint8_t)((shade & 3u) * 60u);
            t3d2_span_texture_loaded = engine->resources_loaded;
            t3d2_span_texture_shift = engine->texture_shift;
            t3d2_raster_span();
            if ((uint16_t)(65535u - *sample_counter) < t3d2_span_length) {
                *sample_counter = 65535u;
            } else {
                *sample_counter = (uint16_t)(*sample_counter + t3d2_span_length);
            }
        }
        long_x += long_step;
        short_x += short_step;
        depth_anchor += depth_step_y;
        u_anchor += u_step_y;
        v_anchor += v_step_y;
    }
}

static void render_layer(
    T3D2Engine *engine,
    uint8_t *color,
    uint16_t *depth,
    uint8_t width,
    uint8_t height,
    uint8_t layer,
    T3D2Benchmark *benchmark
) {
    ReferenceVertex a;
    ReferenceVertex b;
    ReferenceVertex c;
    uint16_t pixels = (uint16_t)width * height;

    memset(color, (int)(2u + layer), pixels);
    memset(depth, 0, (size_t)pixels * sizeof(uint16_t));
    a.x = 2;
    a.y = (int16_t)(height - 3u);
    a.inverse_depth = (uint16_t)(50000u - layer * 7000u);
    a.u = 0;
    a.v = 255;
    b.x = (int16_t)(width - 3u);
    b.y = (int16_t)(height - 3u);
    b.inverse_depth = (uint16_t)(38000u - layer * 5000u);
    b.u = 255;
    b.v = 255;
    c.x = (int16_t)(width / 2u);
    c.y = 2;
    c.inverse_depth = (uint16_t)(45000u - layer * 6000u);
    c.u = 128;
    c.v = 0;
    reference_triangle(engine, color, depth, width, height, &a, &b, &c, layer,
                       &benchmark->shaded_samples[layer]);
    benchmark->submitted_triangles[layer] = 1u;

    /* A small depth-overlap regression triangle catches painter-sort regressions. */
    a.x = (int16_t)(width / 4u);
    a.y = (int16_t)(height / 2u);
    a.inverse_depth = (uint16_t)(51000u - layer * 5000u);
    b.x = (int16_t)(width * 3u / 4u);
    b.y = (int16_t)(height / 2u);
    b.inverse_depth = a.inverse_depth;
    c.x = (int16_t)(width / 2u);
    c.y = (int16_t)(height - 5u);
    c.inverse_depth = a.inverse_depth;
    reference_triangle(engine, color, depth, width, height, &a, &b, &c,
                       (uint8_t)(3u - layer),
                       &benchmark->shaded_samples[layer]);
    benchmark->submitted_triangles[layer] = 2u;

}

static CameraVertex interpolate_near(
    const CameraVertex *outside,
    const CameraVertex *inside
) {
    CameraVertex result;
    int24_t denominator = inside->z - outside->z;
    int24_t numerator = T3D2_NEAR_PLANE - outside->z;
    int24_t amount = numerator * 256 / denominator;

    result.x = outside->x + (inside->x - outside->x) * amount / 256;
    result.y = outside->y + (inside->y - outside->y) * amount / 256;
    result.z = T3D2_NEAR_PLANE;
    result.u = outside->u + (inside->u - outside->u) * amount / 256;
    result.v = outside->v + (inside->v - outside->v) * amount / 256;
    return result;
}

static uint8_t clip_near(
    const CameraVertex input[3],
    CameraVertex output[4]
) {
    uint8_t output_count = 0u;
    uint8_t index;
    CameraVertex previous = input[2];
    uint8_t previous_inside = (uint8_t)(previous.z >= T3D2_NEAR_PLANE);

    for (index = 0; index < 3u; ++index) {
        CameraVertex current = input[index];
        uint8_t current_inside = (uint8_t)(current.z >= T3D2_NEAR_PLANE);

        if (current_inside != previous_inside) {
            if (previous_inside != 0u) {
                output[output_count++] = interpolate_near(&current, &previous);
            } else {
                output[output_count++] = interpolate_near(&previous, &current);
            }
        }
        if (current_inside != 0u) output[output_count++] = current;
        previous = current;
        previous_inside = current_inside;
    }
    return output_count;
}

static ReferenceVertex project_vertex(
    const CameraVertex *vertex,
    const RenderTarget *target
) {
    ReferenceVertex result;
    int24_t inverse_depth = 2097120 / vertex->z;
    int24_t screen_x = (int24_t)(target->width / 2u) +
        vertex->x * target->focal / vertex->z;
    int24_t screen_y = (int24_t)(target->height / 2u) -
        vertex->y * target->focal / vertex->z;

    /* This vertical slice has a fixed 80x60 viewport. Clamping to the one-pixel
       guard band prevents setup overflow and stands in for the planned exact
       screen-polygon clipper. */
    if (screen_x < -1L) screen_x = -1L;
    if (screen_x > target->width) screen_x = target->width;
    if (screen_y < -1L) screen_y = -1L;
    if (screen_y > target->height) screen_y = target->height;
    result.x = (int16_t)screen_x;
    result.y = (int16_t)screen_y;
    if (inverse_depth > 65535L) inverse_depth = 65535L;
    if (inverse_depth < 1L) inverse_depth = 1L;
    result.inverse_depth = (uint16_t)inverse_depth;
    result.u = (int16_t)vertex->u;
    result.v = (int16_t)vertex->v;
    return result;
}

static uint8_t triangle_faces_camera(const CameraVertex triangle[3]) {
    int24_t origin_x = triangle[0].x >> 6;
    int24_t origin_y = triangle[0].y >> 6;
    int24_t origin_z = triangle[0].z >> 6;
    int24_t ab_x = (triangle[1].x >> 6) - origin_x;
    int24_t ab_y = (triangle[1].y >> 6) - origin_y;
    int24_t ab_z = (triangle[1].z >> 6) - origin_z;
    int24_t ac_x = (triangle[2].x >> 6) - origin_x;
    int24_t ac_y = (triangle[2].y >> 6) - origin_y;
    int24_t ac_z = (triangle[2].z >> 6) - origin_z;
    int24_t normal_x = ab_y * ac_z - ab_z * ac_y;
    int24_t normal_y = ab_z * ac_x - ab_x * ac_z;
    int24_t normal_z = ab_x * ac_y - ab_y * ac_x;

    return (uint8_t)(normal_x * origin_x + normal_y * origin_y +
                     normal_z * origin_z > 0);
}

static uint8_t meshlet_payload(
    const T3D2Engine *engine,
    const T3D2MeshletRecord *meshlet,
    const T3D2PackedVertex **vertices,
    const T3D2PackedTriangle **triangles
) {
    uint32_t required;
    const uint8_t *payload;

    if (meshlet->page >= engine->geometry_page_count ||
        engine->geometry_payload[meshlet->page] == NULL) return 0u;
    required = (uint32_t)meshlet->vertex_count * sizeof(T3D2PackedVertex) +
               (uint32_t)meshlet->triangle_count * sizeof(T3D2PackedTriangle);
    if (meshlet->payload_offset > engine->geometry_payload_size[meshlet->page] ||
        required > engine->geometry_payload_size[meshlet->page] - meshlet->payload_offset) {
        return 0u;
    }
    payload = engine->geometry_payload[meshlet->page] + meshlet->payload_offset;
    *vertices = (const T3D2PackedVertex *)payload;
    *triangles = (const T3D2PackedTriangle *)(
        payload + (uint16_t)meshlet->vertex_count * sizeof(T3D2PackedVertex));
    return 1u;
}

static int32_t render_portal_plane_distance(
    T3D2Vec3 point,
    const T3D2Portal *portal
) {
    T3D2Vec3 relative;

    relative.x = point.x - portal->center.x;
    relative.y = point.y - portal->center.y;
    relative.z = point.z - portal->center.z;
    return (int32_t)(((int64_t)relative.x * portal->normal.x +
                      (int64_t)relative.y * portal->normal.y +
                      (int64_t)relative.z * portal->normal.z) >> 8);
}

static uint8_t triangle_is_on_portal_host(
    const T3D2Vec3 triangle[3],
    const T3D2Portal *portal
) {
    uint8_t index;

    if (portal == NULL) return 0u;
    for (index = 0u; index < 3u; ++index) {
        int32_t distance = render_portal_plane_distance(triangle[index], portal);

        if (distance < -8 || distance > 8) return 0u;
    }
    return 1u;
}

static void render_meshlet(
    T3D2Engine *engine,
    const T3D2MeshletRecord *meshlet,
    const RenderCamera *camera,
    const RenderTarget *target,
    const T3D2Portal *open_host
) {
    const T3D2PackedVertex *vertices;
    const T3D2PackedTriangle *triangles;
    CameraVertex transformed[T3D2_MESHLET_MAX_VERTICES];
    T3D2Vec3 world[T3D2_MESHLET_MAX_VERTICES];
    uint8_t shade = engine->scene.materials[meshlet->material].shade;
    uint8_t index;
    clock_t phase_started;

    if (meshlet_payload(engine, meshlet, &vertices, &triangles) == 0u) {
        if (engine->benchmark.dropped_meshlets[target->layer] != 255u) {
            ++engine->benchmark.dropped_meshlets[target->layer];
        }
        return;
    }
    if (target->layer != 0u &&
        (meshlet->flags & T3D2_MESHLET_ESSENTIAL) == 0u &&
        (engine->benchmark.submitted_triangles[target->layer] >=
             layer_triangle_budget[target->layer] ||
         engine->benchmark.shaded_samples[target->layer] >=
             layer_sample_budget[target->layer])) {
        if (engine->benchmark.dropped_meshlets[target->layer] != 255u) {
            ++engine->benchmark.dropped_meshlets[target->layer];
        }
        return;
    }
    /* Slow development frames still need to latch short presses, but polling
       once per meshlet is sufficient and avoids keypad work per triangle. */
    if (target->layer == 0u) t3d2_input_poll(engine);
    phase_started = clock();
    for (index = 0; index < meshlet->vertex_count; ++index) {
        int24_t world_x = (int24_t)meshlet->origin_x + vertices[index].x;
        int24_t world_y = (int24_t)meshlet->origin_y + vertices[index].y;
        int24_t world_z = (int24_t)meshlet->origin_z + vertices[index].z;
        int24_t relative_x = world_x - camera->position.x;
        int24_t relative_y = world_y - camera->position.y;
        int24_t relative_z =
            world_z - camera->position.z;

        world[index].x = world_x;
        world[index].y = world_y;
        world[index].z = world_z;

        transformed[index].x =
            (relative_x * camera->right.x +
             relative_y * camera->right.y +
             relative_z * camera->right.z) >> 8;
        transformed[index].z =
            (relative_x * camera->forward.x +
             relative_y * camera->forward.y +
             relative_z * camera->forward.z) >> 8;
        transformed[index].y =
            (relative_x * camera->up.x +
             relative_y * camera->up.y +
             relative_z * camera->up.z) >> 8;
        transformed[index].u = vertices[index].u;
        transformed[index].v = vertices[index].v;
    }
    engine->benchmark.transform_ticks += (uint32_t)(clock() - phase_started);
    phase_started = clock();
    for (index = 0; index < meshlet->triangle_count; ++index) {
        CameraVertex triangle[3];
        T3D2Vec3 world_triangle[3];
        CameraVertex clipped[4];
        uint8_t clipped_count;
        uint8_t corner;

        if (target->layer != 0u &&
            (engine->benchmark.submitted_triangles[target->layer] >=
                 layer_triangle_budget[target->layer] ||
             engine->benchmark.shaded_samples[target->layer] >=
                 layer_sample_budget[target->layer]) &&
            (meshlet->flags & T3D2_MESHLET_ESSENTIAL) == 0u) {
            if (engine->benchmark.dropped_meshlets[target->layer] != 255u) {
                ++engine->benchmark.dropped_meshlets[target->layer];
            }
            return;
        }
        for (corner = 0; corner < 3u; ++corner) {
            uint8_t vertex_index = triangles[index].index[corner];

            if (vertex_index >= meshlet->vertex_count) return;
            triangle[corner] = transformed[vertex_index];
            world_triangle[corner] = world[vertex_index];
        }
        if (triangle_is_on_portal_host(world_triangle, open_host) != 0u) continue;
        if (triangle_faces_camera(triangle) == 0u) continue;
        clipped_count = clip_near(triangle, clipped);
        if (clipped_count >= 3u) {
            uint8_t fan;

            for (fan = 1u; fan + 1u < clipped_count; ++fan) {
                ReferenceVertex a = project_vertex(&clipped[0], target);
                ReferenceVertex b = project_vertex(&clipped[fan], target);
                ReferenceVertex c = project_vertex(&clipped[fan + 1u], target);

                reference_triangle(engine, target->color, target->depth,
                                   target->width, target->height,
                                   &a, &b, &c, shade,
                                   &engine->benchmark.shaded_samples[target->layer]);
                if (engine->benchmark.submitted_triangles[target->layer] != 65535u) {
                    ++engine->benchmark.submitted_triangles[target->layer];
                }
            }
        }
    }
    engine->benchmark.portal_ticks += (uint32_t)(clock() - phase_started);
}

static uint8_t gateway_is_visible(
    const T3D2Engine *engine,
    const T3D2GatewayRecord *gateway,
    const RenderCamera *camera,
    const RenderTarget *target
) {
    uint8_t outside_near = 0u;
    uint8_t outside_left = 0u;
    uint8_t outside_right = 0u;
    uint8_t outside_top = 0u;
    uint8_t outside_bottom = 0u;
    uint8_t index;

    for (index = 0u; index < gateway->vertex_count; ++index) {
        const int32_t *packed =
            (const int32_t *)((const uint8_t *)engine->scene.header +
                              gateway->vertex_offset) + (uint16_t)index * 3u;
        int24_t relative_x = (int24_t)packed[0] - camera->position.x;
        int24_t relative_y = (int24_t)packed[1] - camera->position.y;
        int24_t relative_z = (int24_t)packed[2] - camera->position.z;
        int24_t camera_x =
            (relative_x * camera->right.x +
             relative_y * camera->right.y +
             relative_z * camera->right.z) >> 8;
        int24_t camera_y =
            (relative_x * camera->up.x +
             relative_y * camera->up.y +
             relative_z * camera->up.z) >> 8;
        int24_t camera_z =
            (relative_x * camera->forward.x +
             relative_y * camera->forward.y +
             relative_z * camera->forward.z) >> 8;
        int32_t projected_x = (int32_t)camera_x * target->focal;
        int32_t projected_y = (int32_t)camera_y * target->focal;
        int32_t horizontal_limit = (int32_t)camera_z * (target->width / 2u);
        int32_t vertical_limit = (int32_t)camera_z * (target->height / 2u);

        outside_near += (uint8_t)(camera_z < T3D2_NEAR_PLANE);
        outside_left += (uint8_t)(projected_x < -horizontal_limit);
        outside_right += (uint8_t)(projected_x > horizontal_limit);
        outside_top += (uint8_t)(projected_y > vertical_limit);
        outside_bottom += (uint8_t)(projected_y < -vertical_limit);
    }
    return (uint8_t)(outside_near != gateway->vertex_count &&
                     outside_left != gateway->vertex_count &&
                     outside_right != gateway->vertex_count &&
                     outside_top != gateway->vertex_count &&
                     outside_bottom != gateway->vertex_count);
}

static void render_scene_view(
    T3D2Engine *engine,
    const RenderCamera *camera,
    const RenderTarget *target,
    const T3D2Portal *open_host
) {
    clock_t phase_started = clock();
    uint32_t transform_before = engine->benchmark.transform_ticks;
    uint32_t triangle_before = engine->benchmark.portal_ticks;
    uint16_t cell_index;
    uint8_t visible_cells[T3D2_MAX_CELLS];
    uint8_t pass;

    uint16_t pixel_count = (uint16_t)target->width * target->height;

    memset(target->color, 240, pixel_count);
    memset(target->depth, 0, (size_t)pixel_count * sizeof(uint16_t));
    if (camera->cell >= engine->scene.header->cell_count) return;
    memset(visible_cells, 0, sizeof(visible_cells));
    visible_cells[camera->cell] = 1u;
    for (pass = 0u; pass < engine->scene.header->cell_count; ++pass) {
        uint8_t changed = 0u;
        uint16_t source;

        for (source = 0u; source < engine->scene.header->cell_count; ++source) {
            const T3D2CellRecord *source_cell;
            uint16_t gateway_offset;

            if (visible_cells[source] == 0u) continue;
            source_cell = &engine->scene.cells[source];
            for (gateway_offset = 0u; gateway_offset < source_cell->gateway_count;
                 ++gateway_offset) {
                const T3D2GatewayRecord *gateway = &engine->scene.gateways[
                    source_cell->first_gateway + gateway_offset];

                if (visible_cells[gateway->destination_cell] == 0u &&
                    gateway_is_visible(engine, gateway, camera, target) != 0u) {
                    visible_cells[gateway->destination_cell] = 1u;
                    changed = 1u;
                }
            }
        }
        if (changed == 0u) break;
    }
    for (cell_index = 0; cell_index < engine->scene.header->cell_count; ++cell_index) {
        const T3D2CellRecord *cell;
        uint16_t meshlet_offset;

        if (visible_cells[cell_index] == 0u) continue;
        cell = &engine->scene.cells[cell_index];
        for (meshlet_offset = 0; meshlet_offset < cell->meshlet_count; ++meshlet_offset) {
            render_meshlet(engine,
                           &engine->scene.meshlets[cell->first_meshlet + meshlet_offset],
                           camera, target, open_host);
        }
    }
    {
        uint32_t elapsed = (uint32_t)(clock() - phase_started);
        uint32_t accounted = (engine->benchmark.transform_ticks - transform_before) +
            (engine->benchmark.portal_ticks - triangle_before);

        if (elapsed > accounted) engine->benchmark.visibility_ticks += elapsed - accounted;
    }
}

static CameraVertex camera_point_from_world(
    const RenderCamera *camera,
    T3D2Vec3 point
) {
    CameraVertex result;
    int24_t relative_x = point.x - camera->position.x;
    int24_t relative_y = point.y - camera->position.y;
    int24_t relative_z = point.z - camera->position.z;

    result.x = (relative_x * camera->right.x +
                relative_y * camera->right.y +
                relative_z * camera->right.z) >> 8;
    result.y = (relative_x * camera->up.x +
                relative_y * camera->up.y +
                relative_z * camera->up.z) >> 8;
    result.z = (relative_x * camera->forward.x +
                relative_y * camera->forward.y +
                relative_z * camera->forward.z) >> 8;
    result.u = 0;
    result.v = 0;
    return result;
}

static RenderCamera render_camera_from_player(const T3D2Player *player) {
    RenderCamera camera;

    camera.position = player->position;
    camera.right = player->right;
    camera.up = player->up;
    camera.forward = player->forward;
    camera.cell = player->cell;
    return camera;
}

static int32_t render_fixed_dot(T3D2Vec3 first, T3D2Vec3 second) {
    return (int32_t)(((int64_t)first.x * second.x +
                      (int64_t)first.y * second.y +
                      (int64_t)first.z * second.z) >> 8);
}

static T3D2Vec3 render_rotate_portal_vector(
    T3D2Vec3 vector,
    const T3D2Portal *source,
    const T3D2Portal *destination
) {
    int32_t local_right = render_fixed_dot(vector, source->right);
    int32_t local_up = render_fixed_dot(vector, source->up);
    int32_t local_normal = render_fixed_dot(vector, source->normal);
    T3D2Vec3 result;

    result.x = (t3d2_fixed_t)(
        (-(int64_t)destination->right.x * local_right +
          (int64_t)destination->up.x * local_up -
          (int64_t)destination->normal.x * local_normal) >> 8);
    result.y = (t3d2_fixed_t)(
        (-(int64_t)destination->right.y * local_right +
          (int64_t)destination->up.y * local_up -
          (int64_t)destination->normal.y * local_normal) >> 8);
    result.z = (t3d2_fixed_t)(
        (-(int64_t)destination->right.z * local_right +
          (int64_t)destination->up.z * local_up -
          (int64_t)destination->normal.z * local_normal) >> 8);
    return result;
}

static T3D2Vec3 render_transform_portal_point(
    T3D2Vec3 point,
    const T3D2Portal *source,
    const T3D2Portal *destination
) {
    T3D2Vec3 relative;
    T3D2Vec3 result;

    relative.x = point.x - source->center.x;
    relative.y = point.y - source->center.y;
    relative.z = point.z - source->center.z;
    result = render_rotate_portal_vector(relative, source, destination);
    result.x += destination->center.x;
    result.y += destination->center.y;
    result.z += destination->center.z;
    return result;
}

static RenderCamera render_camera_through_portal(
    const RenderCamera *camera,
    const T3D2Portal *source,
    const T3D2Portal *destination
) {
    RenderCamera result;

    result.position = render_transform_portal_point(camera->position, source, destination);
    result.right = render_rotate_portal_vector(camera->right, source, destination);
    result.up = render_rotate_portal_vector(camera->up, source, destination);
    result.forward = render_rotate_portal_vector(camera->forward, source, destination);
    result.cell = destination->cell;
    return result;
}

#define T3D2_PORTAL_POLYGON_POINTS 4u

/* Match True3D's planar portal aperture. Every corner remains in the portal
   host basis until after the camera transform, so an oblique wall produces
   the expected foreshortened quadrilateral instead of a camera-facing sprite. */
static const int16_t portal_aperture_q8[T3D2_PORTAL_POLYGON_POINTS][2] = {
    {-256, -256}, {256, -256}, {256, 256}, {-256, 256}
};

static uint8_t build_portal_camera_polygon(
    const RenderCamera *camera,
    const T3D2Portal *portal,
    t3d2_fixed_t inset,
    CameraVertex output[T3D2_PORTAL_POLYGON_POINTS]
) {
    t3d2_fixed_t half_width = portal->half_width - inset;
    t3d2_fixed_t half_height = portal->half_height - inset;
    uint8_t index;

    if (half_width <= 0 || half_height <= 0) return 0u;
    for (index = 0u; index < T3D2_PORTAL_POLYGON_POINTS; ++index) {
        t3d2_fixed_t local_right = (t3d2_fixed_t)(
            (half_width * portal_aperture_q8[index][0]) >> 8);
        t3d2_fixed_t local_up = (t3d2_fixed_t)(
            (half_height * portal_aperture_q8[index][1]) >> 8);
        T3D2Vec3 point;

        point.x = portal->center.x + (t3d2_fixed_t)(
            ((int32_t)portal->right.x * local_right +
             (int32_t)portal->up.x * local_up) >> 8);
        point.y = portal->center.y + (t3d2_fixed_t)(
            ((int32_t)portal->right.y * local_right +
             (int32_t)portal->up.y * local_up) >> 8);
        point.z = portal->center.z + (t3d2_fixed_t)(
            ((int32_t)portal->right.z * local_right +
             (int32_t)portal->up.z * local_up) >> 8);
        output[index] = camera_point_from_world(camera, point);
    }
    return T3D2_PORTAL_POLYGON_POINTS;
}

static uint8_t clip_portal_polygon_near(
    const CameraVertex *input,
    uint8_t input_count,
    CameraVertex *output
) {
    uint8_t output_count = 0u;
    uint8_t index;
    CameraVertex previous;
    uint8_t previous_inside;

    if (input_count < 3u) return 0u;
    previous = input[input_count - 1u];
    previous_inside = (uint8_t)(previous.z >= T3D2_NEAR_PLANE);
    for (index = 0u; index < input_count; ++index) {
        CameraVertex current = input[index];
        uint8_t current_inside = (uint8_t)(current.z >= T3D2_NEAR_PLANE);

        if (current_inside != previous_inside) {
            output[output_count++] = previous_inside != 0u ?
                interpolate_near(&current, &previous) :
                interpolate_near(&previous, &current);
        }
        if (current_inside != 0u) output[output_count++] = current;
        previous = current;
        previous_inside = current_inside;
    }
    return output_count;
}

static void draw_solid_portal_span(
    const RenderTarget *target,
    uint8_t row,
    int16_t left,
    int16_t right,
    uint16_t depth,
    uint8_t color
) {
    if (row >= target->height || right < 0 ||
        left >= (int16_t)target->width) return;
    if (left < 0) left = 0;
    if (right >= (int16_t)target->width) right = target->width - 1;
    if (left > right) return;
    t3d2_solid_color_pointer = target->color +
        (uint16_t)row * target->width + (uint16_t)left;
    t3d2_solid_depth_pointer = target->depth +
        (uint16_t)row * target->width + (uint16_t)left;
    t3d2_solid_depth_value = depth;
    t3d2_solid_length = (uint8_t)(right - left + 1);
    t3d2_solid_color = color;
    t3d2_solid_span();
}

static void draw_projected_portal_polygon(
    const RenderTarget *target,
    const ReferenceVertex *point,
    uint8_t point_count,
    uint16_t depth,
    uint8_t color
) {
    int16_t span_left[T3D2_ROOT_HEIGHT];
    int16_t span_right[T3D2_ROOT_HEIGHT];
    int16_t row;
    uint8_t index;

    for (row = 0; row < (int16_t)target->height; ++row) {
        span_left[row] = 32767;
        span_right[row] = -32768;
    }
    for (index = 0u; index < point_count; ++index) {
        const ReferenceVertex *first = &point[index];
        const ReferenceVertex *second = &point[
            index + 1u == point_count ? 0u : index + 1u];
        int16_t first_y = first->y;
        int16_t second_y = second->y;
        int16_t first_x = first->x;
        int16_t second_x = second->x;
        int16_t first_row;
        int16_t last_row;
        int24_t x;
        int24_t step;

        if (first_y == second_y) continue;
        if (first_y > second_y) {
            int16_t swap = first_y;

            first_y = second_y;
            second_y = swap;
            swap = first_x;
            first_x = second_x;
            second_x = swap;
        }
        first_row = first_y < 0 ? 0 : first_y;
        last_row = second_y > (int16_t)target->height ?
            (int16_t)(target->height - 1u) : (int16_t)(second_y - 1);
        if (first_row > last_row) continue;
        step = ((int24_t)(second_x - first_x) << 8) /
            (second_y - first_y);
        x = ((int24_t)first_x << 8) + (step >> 1) +
            step * (first_row - first_y);
        for (row = first_row; row <= last_row; ++row) {
            int16_t edge_x = (int16_t)((x + 127) >> 8);

            if (edge_x < span_left[row]) span_left[row] = edge_x;
            if (edge_x > span_right[row]) span_right[row] = edge_x;
            x += step;
        }
    }
    for (row = 0; row < (int16_t)target->height; ++row) {
        if (span_left[row] <= span_right[row]) {
            draw_solid_portal_span(target, (uint8_t)row, span_left[row],
                                   span_right[row], depth, color);
        }
    }
}

static void composite_projected_portal_polygon(
    const RenderTarget *target,
    const ReferenceVertex *point,
    uint8_t point_count,
    const RenderTarget *child,
    uint16_t depth
) {
    int16_t span_left[T3D2_ROOT_HEIGHT];
    int16_t span_right[T3D2_ROOT_HEIGHT];
    int16_t row;
    uint8_t index;

    for (row = 0; row < (int16_t)target->height; ++row) {
        span_left[row] = 32767;
        span_right[row] = -32768;
    }
    for (index = 0u; index < point_count; ++index) {
        const ReferenceVertex *first = &point[index];
        const ReferenceVertex *second = &point[
            index + 1u == point_count ? 0u : index + 1u];
        int16_t first_y = first->y;
        int16_t second_y = second->y;
        int16_t first_x = first->x;
        int16_t second_x = second->x;
        int16_t first_row;
        int16_t last_row;
        int24_t x;
        int24_t step;

        if (first_y == second_y) continue;
        if (first_y > second_y) {
            int16_t swap = first_y;

            first_y = second_y;
            second_y = swap;
            swap = first_x;
            first_x = second_x;
            second_x = swap;
        }
        first_row = first_y < 0 ? 0 : first_y;
        last_row = second_y > (int16_t)target->height ?
            (int16_t)(target->height - 1u) : (int16_t)(second_y - 1);
        if (first_row > last_row) continue;
        step = ((int24_t)(second_x - first_x) << 8) /
            (second_y - first_y);
        x = ((int24_t)first_x << 8) + (step >> 1) +
            step * (first_row - first_y);
        for (row = first_row; row <= last_row; ++row) {
            int16_t edge_x = (int16_t)((x + 127) >> 8);

            if (edge_x < span_left[row]) span_left[row] = edge_x;
            if (edge_x > span_right[row]) span_right[row] = edge_x;
            x += step;
        }
    }
    for (row = 0; row < (int16_t)target->height; ++row) {
        int16_t left = span_left[row];
        int16_t right = span_right[row];
        uint8_t child_y;
        int16_t column;

        if (left > right || right < 0 || left >= target->width) continue;
        if (left < 0) left = 0;
        if (right >= target->width) right = target->width - 1;
        child_y = (uint8_t)((uint16_t)row * child->height / target->height);
        for (column = left; column <= right; ++column) {
            uint16_t target_index = (uint16_t)row * target->width + (uint16_t)column;

            if (target->depth[target_index] < depth) {
                uint8_t child_x = (uint8_t)(
                    (uint16_t)column * child->width / target->width);
                uint16_t child_index = (uint16_t)child_y * child->width + child_x;

                target->depth[target_index] = depth;
                target->color[target_index] = child->color[child_index];
            }
        }
    }
}

static uint8_t project_portal_polygon(
    const RenderCamera *camera,
    const RenderTarget *target,
    const T3D2Portal *portal,
    t3d2_fixed_t inset,
    ReferenceVertex *projected,
    uint8_t *projected_count,
    uint16_t *nearest_depth
) {
    CameraVertex polygon_camera[T3D2_PORTAL_POLYGON_POINTS];
    CameraVertex clipped[T3D2_PORTAL_POLYGON_POINTS + 1u];
    uint8_t camera_count = build_portal_camera_polygon(
        camera, portal, inset, polygon_camera);
    uint8_t clipped_count = clip_portal_polygon_near(
        polygon_camera, camera_count, clipped);
    uint8_t index;
    uint16_t maximum_depth = 0u;

    if (clipped_count < 3u) return 0u;
    for (index = 0u; index < clipped_count; ++index) {
        projected[index] = project_vertex(&clipped[index], target);
        if (projected[index].inverse_depth > maximum_depth) {
            maximum_depth = projected[index].inverse_depth;
        }
    }
    *projected_count = clipped_count;
    *nearest_depth = maximum_depth;
    return 1u;
}

static void draw_portal_recursive(
    T3D2Engine *engine,
    const RenderCamera *camera,
    const RenderTarget *target,
    uint8_t portal_index,
    uint8_t depth
) {
    const T3D2Portal *portal = &engine->portal[portal_index];
    ReferenceVertex outer[T3D2_PORTAL_POLYGON_POINTS + 1u];
    ReferenceVertex inner[T3D2_PORTAL_POLYGON_POINTS + 1u];
    T3D2Vec3 relative;
    int24_t facing;
    uint8_t outer_count;
    uint8_t inner_count;
    uint16_t outer_depth;
    uint16_t inner_depth;
    uint8_t outline = portal_index == 0u ? 241u : 242u;

    if (portal->active == 0u || portal->cell != camera->cell) return;
    relative.x = camera->position.x - portal->center.x;
    relative.y = camera->position.y - portal->center.y;
    relative.z = camera->position.z - portal->center.z;
    facing = (relative.x * portal->normal.x +
              relative.y * portal->normal.y +
              relative.z * portal->normal.z) >> 8;
    if (facing <= 0) return;
    if (project_portal_polygon(camera, target, portal, 0, outer, &outer_count,
                               &outer_depth) == 0u) return;
    /* The aperture is submitted after its host wall, matching True3D's host
       hole ordering. Reserve the two nearest depth values so interpolation
       error in the textured wall cannot punch holes through the outline. */
    (void)outer_depth;
    outer_depth = 65534u;
    draw_projected_portal_polygon(target, outer, outer_count, outer_depth, outline);
    if (project_portal_polygon(camera, target, portal, 32, inner, &inner_count,
                               &inner_depth) != 0u) {
        const T3D2Portal *destination = &engine->portal[portal_index ^ 1u];

        (void)inner_depth;
        inner_depth = 65535u;
        if (portal->linked != 0u && destination->linked != 0u &&
            portal->charging == 0u && destination->charging == 0u &&
            destination->active != 0u && depth < 2u) {
            RenderCamera child_camera = render_camera_through_portal(
                camera, portal, destination);
            RenderTarget child;

            if (depth == 0u) {
                child.color = t3d2_portal1_color;
                child.depth = t3d2_portal1_depth;
                child.width = T3D2_PORTAL1_WIDTH;
                child.height = T3D2_PORTAL1_HEIGHT;
                child.layer = 1u;
                child.focal = 27u;
            } else {
                child.color = t3d2_portal2_color;
                child.depth = t3d2_portal2_depth;
                child.width = T3D2_PORTAL2_WIDTH;
                child.height = T3D2_PORTAL2_HEIGHT;
                child.layer = 2u;
                child.focal = 13u;
            }
            render_scene_view(engine, &child_camera, &child, destination);
            if (depth + 1u < 2u) {
                draw_portal_recursive(engine, &child_camera, &child, 0u,
                                      (uint8_t)(depth + 1u));
                draw_portal_recursive(engine, &child_camera, &child, 1u,
                                      (uint8_t)(depth + 1u));
            }
            composite_projected_portal_polygon(
                target, inner, inner_count, &child, inner_depth);
        } else {
            draw_projected_portal_polygon(
                target, inner, inner_count, inner_depth, 240u);
        }
    }
}

uint16_t t3d2_kernel_raster_4800(T3D2Engine *engine) {
    ReferenceVertex a = {0, 0, 30000u, 0, 0};
    ReferenceVertex b = {80, 0, 30000u, 255, 0};
    ReferenceVertex c = {80, 60, 30000u, 255, 255};
    ReferenceVertex d = {0, 60, 30000u, 0, 255};
    uint16_t samples = 0u;

    memset(t3d2_root_color, 0, sizeof(t3d2_root_color));
    memset(t3d2_root_depth, 0, sizeof(t3d2_root_depth));
    reference_triangle(engine, t3d2_root_color, t3d2_root_depth,
                       T3D2_ROOT_WIDTH, T3D2_ROOT_HEIGHT,
                       &a, &b, &c, 3u, &samples);
    reference_triangle(engine, t3d2_root_color, t3d2_root_depth,
                       T3D2_ROOT_WIDTH, T3D2_ROOT_HEIGHT,
                       &a, &c, &d, 3u, &samples);
    return samples;
}

uint16_t t3d2_kernel_span_4800(T3D2Engine *engine) {
    uint8_t row;

    memset(t3d2_root_color, 0, sizeof(t3d2_root_color));
    memset(t3d2_root_depth, 0, sizeof(t3d2_root_depth));
    for (row = 0u; row < T3D2_ROOT_HEIGHT; ++row) {
        t3d2_span_color = t3d2_root_color + (uint16_t)row * T3D2_ROOT_WIDTH;
        t3d2_span_depth = t3d2_root_depth + (uint16_t)row * T3D2_ROOT_WIDTH;
        t3d2_span_texture0 = engine->texture_half[0];
        t3d2_span_texture1 = engine->texture_half[1];
        t3d2_span_depth_value = 12000u;
        t3d2_span_depth_step = 0;
        t3d2_span_u_value = 0u;
        t3d2_span_u_step = 3u << 8;
        t3d2_span_v_value = (uint24_t)row * 4u << 8;
        t3d2_span_v_step = 0;
        t3d2_span_length = T3D2_ROOT_WIDTH;
        t3d2_span_shade_offset = 180u;
        t3d2_span_texture_loaded = engine->resources_loaded;
        t3d2_span_texture_shift = engine->texture_shift;
        t3d2_raster_span();
    }
    return T3D2_ROOT_WIDTH * T3D2_ROOT_HEIGHT;
}

uint32_t t3d2_kernel_geometry_96(void) {
    uint32_t checksum = 2166136261UL;
    RenderTarget target = {
        t3d2_root_color, t3d2_root_depth,
        T3D2_ROOT_WIDTH, T3D2_ROOT_HEIGHT, 0u, T3D2_PROJECTION_FOCAL
    };
    uint8_t triangle_index;
    int16_t sine = t3d2_sin_q8(23u);
    int16_t cosine = t3d2_cos_q8(23u);

    for (triangle_index = 0u; triangle_index < 96u; ++triangle_index) {
        CameraVertex input[3];
        CameraVertex clipped[4];
        uint8_t clipped_count;
        uint8_t index;

        int24_t world_x[3];
        int24_t world_y[3];
        int24_t world_z[3];

        world_x[0] = -320 + triangle_index * 3;
        world_y[0] = (triangle_index & 7u) == 0u ? 16 : 192 + triangle_index;
        world_z[0] = -180;
        world_x[1] = 256 + triangle_index * 2;
        world_y[1] = 224 + triangle_index;
        world_z[1] = -160;
        world_x[2] = 0;
        world_y[2] = 208 + triangle_index;
        world_z[2] = 256;
        for (index = 0u; index < 3u; ++index) {
            input[index].x = (world_x[index] * cosine - world_y[index] * sine) >> 8;
            input[index].z = (world_x[index] * sine + world_y[index] * cosine) >> 8;
            input[index].y = world_z[index];
            input[index].u = index == 0u ? 0 : (index == 1u ? 255 : 128);
            input[index].v = index == 2u ? 255 : 0;
        }
        /* Include the production cull predicate even when this synthetic
           triangle is rejected; clip/project work follows for survivors. */
        checksum ^= triangle_faces_camera(input);
        checksum *= 16777619UL;
        /* Keep one vertex behind the near plane every eighth case. */
        if ((triangle_index & 7u) == 0u) input[0].z = 16;
        clipped_count = clip_near(input, clipped);
        for (index = 0u; index < clipped_count; ++index) {
            ReferenceVertex projected = project_vertex(&clipped[index], &target);

            checksum ^= (uint16_t)projected.x;
            checksum *= 16777619UL;
            checksum ^= (uint16_t)projected.y;
            checksum *= 16777619UL;
            checksum ^= projected.inverse_depth;
            checksum *= 16777619UL;
        }
    }
    return checksum;
}

void t3d2_reference_render(T3D2Engine *engine) {
    RenderTarget root = {
        t3d2_root_color, t3d2_root_depth,
        T3D2_ROOT_WIDTH, T3D2_ROOT_HEIGHT, 0u, T3D2_PROJECTION_FOCAL
    };
    RenderCamera camera = render_camera_from_player(&engine->player);

    memset(engine->benchmark.submitted_triangles, 0,
           sizeof(engine->benchmark.submitted_triangles));
    memset(engine->benchmark.shaded_samples, 0,
           sizeof(engine->benchmark.shaded_samples));
    memset(engine->benchmark.dropped_meshlets, 0,
           sizeof(engine->benchmark.dropped_meshlets));
    if (engine->scene_loaded != 0u && engine->resources_loaded != 0u) {
        render_scene_view(engine, &camera, &root, NULL);
    } else {
        render_layer(engine, t3d2_root_color, t3d2_root_depth,
                     T3D2_ROOT_WIDTH, T3D2_ROOT_HEIGHT, 0u,
                     &engine->benchmark);
    }
    draw_portal_recursive(engine, &camera, &root, 0u, 0u);
    draw_portal_recursive(engine, &camera, &root, 1u, 0u);
}
