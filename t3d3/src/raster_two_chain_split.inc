/*
 * Convex two-chain scan conversion prototype.
 *
 * Near clipping preserves convex vertex order, so every sampled row has one
 * intersection on each y-monotone chain.  Walking those chains directly
 * avoids clearing, indexing, comparing, and re-reading two int24 min/max
 * scratch rows for every polygon.  The full-resolution loop stays separate
 * so the compiler can fold step=1 and sample_origin=0.
 */
typedef struct {
    uint8_t vertex;
    int8_t direction;
    uint8_t edges_left;
    uint8_t last_row;
    int24_t x_value;
    int24_t x_advance;
} RasterChain;

static uint8_t raster_chain_begin_edge(
    RasterChain *chain,
    const DrawPolygon *polygon,
    uint8_t row,
    uint8_t step
) {
    while (chain->edges_left != 0) {
        uint8_t next;
        ScreenPoint a = polygon->point[chain->vertex];
        ScreenPoint b;
        int24_t delta_x;
        int24_t delta_y;
        int32_t x_step;
        int16_t first;
        int16_t last;

        if (chain->direction > 0) {
            next = chain->vertex + 1u;
            if (next == polygon->count) next = 0;
        } else {
            next = chain->vertex == 0 ? polygon->count - 1u :
                chain->vertex - 1u;
        }
        chain->vertex = next;
        --chain->edges_left;
        b = polygon->point[next];
        if (a.y == b.y) continue;
        if (a.y > b.y) return 0;

        delta_x = (int24_t)b.x - a.x;
        delta_y = (int24_t)b.y - a.y;
        first = ceil_q8((int24_t)a.y - FIXED_ONE / 2);
        last = floor_q8((int24_t)b.y - 1 - FIXED_ONE / 2);
        if (last < row) continue;
        if (first > row) return 0;
        if (last >= active_render_height) last = active_render_height - 1u;

        x_step = edge_x_step(delta_x, delta_y);
        chain->last_row = (uint8_t)last;
        chain->x_value = a.x + (int24_t)(
            (x_step *
                ((int24_t)row * FIXED_ONE + FIXED_ONE / 2 - a.y)) >>
            FIXED_SHIFT
        );
        chain->x_advance = (int24_t)(x_step * step);
        return 1;
    }
    return 0;
}

static uint8_t rasterize_polygon_lod(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    uint8_t step = (uint8_t)(1u << layer->lod_shift);
    uint8_t sample_origin = step >> 1;
    int16_t first_row = polygon->sample_first_row;
    int16_t last_row = polygon->sample_last_row;
    int16_t row;
    uint8_t any = 0;
    RasterChain first_chain;
    RasterChain second_chain;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);
    {
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

    polygon->first_row = (uint8_t)first_row;
    polygon->last_row = (uint8_t)last_row;
    RENDER_BENCHMARK_COUNT(
        raster_rows,
        (uint16_t)(((last_row - first_row) >> layer->lod_shift) + 1)
    );
    first_chain.vertex = polygon->top_vertex;
    first_chain.direction = 1;
    first_chain.edges_left = polygon->count;
    second_chain.vertex = polygon->top_vertex;
    second_chain.direction = -1;
    second_chain.edges_left = polygon->count;
    if (!raster_chain_begin_edge(&first_chain, polygon, first_row, step) ||
        !raster_chain_begin_edge(&second_chain, polygon, first_row, step)) {
        return 0;
    }

    for (row = first_row; row <= last_row; row += step) {
        int24_t left_value;
        int24_t right_value;
        uint8_t first_column;
        uint8_t last_column;

        if (row > first_chain.last_row &&
            !raster_chain_begin_edge(&first_chain, polygon, row, step)) {
            return 0;
        }
        if (row > second_chain.last_row &&
            !raster_chain_begin_edge(&second_chain, polygon, row, step)) {
            return 0;
        }
        left_value = first_chain.x_value;
        right_value = second_chain.x_value;
        if (left_value > right_value) {
            int24_t swap = left_value;
            left_value = right_value;
            right_value = swap;
        }
        first_column = raster_first_column(left_value);
        last_column = raster_last_column(right_value);
        if (last_column != 255u && first_column <= last_column &&
            first_column < active_render_width) {
            polygon->span_left[row] = first_column;
            polygon->span_right[row] = last_column;
            any = 1;
        } else {
            polygon->span_left[row] = 255;
            polygon->span_right[row] = 0;
        }
        if (row + step <= first_chain.last_row) {
            first_chain.x_value += first_chain.x_advance;
        }
        if (row + step <= second_chain.last_row) {
            second_chain.x_value += second_chain.x_advance;
        }
    }
    return any;
}

static uint8_t rasterize_polygon_full(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    int16_t first_row_value = polygon->sample_first_row;
    int16_t last_row_value = polygon->sample_last_row;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t row;
    uint8_t any = 0;
    RasterChain first_chain;
    RasterChain second_chain;

    RENDER_BENCHMARK_COUNT(rasterized_polygons, 1u);
    if (first_row_value < layer->first_row) first_row_value = layer->first_row;
    if (last_row_value > layer->last_row) last_row_value = layer->last_row;
    if (first_row_value < 0) first_row_value = 0;
    if (last_row_value >= active_render_height) {
        last_row_value = active_render_height - 1;
    }
    if (last_row_value < 0 || first_row_value > last_row_value) return 0;
    first_row = (uint8_t)first_row_value;
    last_row = (uint8_t)last_row_value;

    polygon->first_row = first_row;
    polygon->last_row = last_row;
    RENDER_BENCHMARK_COUNT(
        raster_rows,
        (uint16_t)(last_row - first_row + 1)
    );
    first_chain.vertex = polygon->top_vertex;
    first_chain.direction = 1;
    first_chain.edges_left = polygon->count;
    second_chain.vertex = polygon->top_vertex;
    second_chain.direction = -1;
    second_chain.edges_left = polygon->count;
    if (!raster_chain_begin_edge(&first_chain, polygon, first_row, 1u) ||
        !raster_chain_begin_edge(&second_chain, polygon, first_row, 1u)) {
        return 0;
    }

    for (row = first_row; row <= last_row; ++row) {
        int24_t left_value;
        int24_t right_value;
        uint8_t first_column;
        uint8_t last_column;

        if (row > first_chain.last_row &&
            !raster_chain_begin_edge(&first_chain, polygon, row, 1u)) {
            return 0;
        }
        if (row > second_chain.last_row &&
            !raster_chain_begin_edge(&second_chain, polygon, row, 1u)) {
            return 0;
        }
        left_value = first_chain.x_value;
        right_value = second_chain.x_value;
        if (left_value > right_value) {
            int24_t swap = left_value;
            left_value = right_value;
            right_value = swap;
        }
        first_column = raster_first_column(left_value);
        last_column = raster_last_column(right_value);
        if (last_column != 255u && first_column <= last_column &&
            first_column < active_render_width) {
            polygon->span_left[row] = first_column;
            polygon->span_right[row] = last_column;
            if (last_column >= layer->row_left[row] &&
                first_column <= layer->row_right[row]) {
                any = 1;
            }
        } else {
            polygon->span_left[row] = 255;
            polygon->span_right[row] = 0;
        }
        if (row < first_chain.last_row) {
            first_chain.x_value += first_chain.x_advance;
        }
        if (row < second_chain.last_row) {
            second_chain.x_value += second_chain.x_advance;
        }
    }
    return any;
}

static uint8_t rasterize_polygon(
    DrawPolygon *polygon,
    const RenderLayer *layer
) {
    if (layer->lod_shift == 0) {
        return rasterize_polygon_full(polygon, layer);
    }
    return rasterize_polygon_lod(polygon, layer);
}
