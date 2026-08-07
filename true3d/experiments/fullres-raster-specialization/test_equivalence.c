#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FIXED_ONE 256
#define PROJECTED_LIMIT 1048576L
#define EDGE_RECIPROCAL_SHIFT 4
#define EDGE_RECIPROCAL_SIZE 2048
#define EDGE_STEP_PRECISION_SHIFT 12
#define MAX_HEIGHT 48
#define MAX_POINTS 8

typedef struct {
    int32_t x;
    int32_t y;
} Point;

typedef struct {
    uint8_t width;
    uint8_t height;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t row_left[MAX_HEIGHT];
    uint8_t row_right[MAX_HEIGHT];
} Layer;

typedef struct {
    uint8_t returned;
    uint8_t first_row;
    uint8_t last_row;
    uint8_t span_left[MAX_HEIGHT];
    uint8_t span_right[MAX_HEIGHT];
} Result;

static uint16_t reciprocal_table[EDGE_RECIPROCAL_SIZE];
static uint32_t random_state = 0x3df011u;

static uint32_t next_random(void) {
    uint32_t value = random_state;
    value ^= value << 13;
    value ^= value >> 17;
    value ^= value << 5;
    random_state = value;
    return value;
}

static int32_t random_range(int32_t minimum, int32_t maximum) {
    return minimum + (int32_t)(next_random() % (uint32_t)(maximum - minimum));
}

static int16_t floor_q8(int32_t value) {
    if (value >= 0) return (int16_t)(value / FIXED_ONE);
    return (int16_t)-(((-value) + FIXED_ONE - 1) / FIXED_ONE);
}

static int16_t ceil_q8(int32_t value) {
    if (value >= 0) return (int16_t)((value + FIXED_ONE - 1) / FIXED_ONE);
    return (int16_t)-((-value) / FIXED_ONE);
}

static int32_t clamp_projected(int32_t value) {
    if (value < -PROJECTED_LIMIT) return -PROJECTED_LIMIT;
    if (value > PROJECTED_LIMIT) return PROJECTED_LIMIT;
    return value;
}

static int32_t edge_x_step(int32_t delta_x, int32_t delta_y) {
    uint32_t index = ((uint32_t)delta_y +
        (1u << (EDGE_RECIPROCAL_SHIFT - 1))) >> EDGE_RECIPROCAL_SHIFT;

    if (delta_y < FIXED_ONE || index >= EDGE_RECIPROCAL_SIZE ||
        delta_x > 32767 || delta_x < -32767) {
        return (delta_x * FIXED_ONE) / delta_y;
    }
    return (delta_x * reciprocal_table[index]) >> EDGE_STEP_PRECISION_SHIFT;
}

static void reset_result(Result *result) {
    memset(result, 0, sizeof(*result));
    memset(result->span_left, 0xa5, sizeof(result->span_left));
    memset(result->span_right, 0x5a, sizeof(result->span_right));
}

static uint8_t finish_result(
    Result *result,
    const Layer *layer,
    const int32_t *work_left,
    const int32_t *work_right,
    int16_t first_row,
    int16_t last_row
) {
    int16_t row;
    uint8_t any = 0;

    result->first_row = (uint8_t)first_row;
    result->last_row = (uint8_t)last_row;
    for (row = first_row; row <= last_row; ++row) {
        int16_t first_column;
        int16_t last_column;

        if (work_left[row] == PROJECTED_LIMIT + 1) {
            result->span_left[row] = 255;
            result->span_right[row] = 0;
            continue;
        }
        first_column = ceil_q8(work_left[row] - FIXED_ONE / 2);
        last_column = floor_q8(work_right[row] - FIXED_ONE / 2);
        if (first_column < 0) first_column = 0;
        if (last_column >= layer->width) last_column = layer->width - 1;
        if (first_column <= last_column) {
            result->span_left[row] = (uint8_t)first_column;
            result->span_right[row] = (uint8_t)last_column;
            if (row >= layer->first_row && row <= layer->last_row &&
                last_column >= layer->row_left[row] &&
                first_column <= layer->row_right[row]) {
                any = 1;
            }
        } else {
            result->span_left[row] = 255;
            result->span_right[row] = 0;
        }
    }
    result->returned = any;
    return any;
}

static uint8_t raster_original_shift_zero(
    Result *result,
    const Point *point,
    uint8_t count,
    const Layer *layer
) {
    uint8_t step = 1;
    uint8_t sample_origin = 0;
    uint8_t shift = 0;
    uint8_t index;
    int32_t minimum_y = point[0].y;
    int32_t maximum_y = minimum_y;
    int16_t first_row;
    int16_t last_row;
    int16_t row;
    int32_t work_left[MAX_HEIGHT];
    int32_t work_right[MAX_HEIGHT];

    reset_result(result);
    for (index = 1; index < count; ++index) {
        if (point[index].y < minimum_y) minimum_y = point[index].y;
        if (point[index].y > maximum_y) maximum_y = point[index].y;
    }
    first_row = ceil_q8(minimum_y - FIXED_ONE / 2);
    last_row = floor_q8(maximum_y - 1 - FIXED_ONE / 2);
    if (first_row < layer->first_row) first_row = layer->first_row;
    if (last_row > layer->last_row) last_row = layer->last_row;
    if (first_row < 0) first_row = 0;
    if (last_row >= layer->height) last_row = layer->height - 1;
    if (first_row <= sample_origin) {
        first_row = sample_origin;
    } else {
        first_row = sample_origin +
            (((first_row - sample_origin + step - 1u) >> shift) << shift);
    }
    if (last_row < sample_origin) return 0;
    last_row = sample_origin +
        (((last_row - sample_origin) >> shift) << shift);
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; row += step) {
        work_left[row] = PROJECTED_LIMIT + 1;
        work_right[row] = -PROJECTED_LIMIT - 1;
    }
    for (index = 0; index < count; ++index) {
        Point a = point[index];
        Point b = point[index + 1 == count ? 0 : index + 1];
        int32_t delta_x;
        int32_t delta_y;
        int32_t x_step;
        int32_t x_value;
        int16_t edge_first;
        int16_t edge_last;
        int16_t current_row;

        if (a.y == b.y) continue;
        if (a.y > b.y) {
            Point swap = a;
            a = b;
            b = swap;
        }
        delta_x = b.x - a.x;
        delta_y = b.y - a.y;
        edge_first = ceil_q8(a.y - FIXED_ONE / 2);
        edge_last = floor_q8(b.y - 1 - FIXED_ONE / 2);
        if (edge_first < first_row) edge_first = first_row;
        if (edge_last > last_row) edge_last = last_row;
        if (edge_first <= sample_origin) {
            edge_first = sample_origin;
        } else {
            edge_first = sample_origin +
                (((edge_first - sample_origin + step - 1u) >> shift) << shift);
        }
        if (edge_first > edge_last) continue;

        x_step = edge_x_step(delta_x, delta_y);
        x_value = a.x +
            ((x_step * (edge_first * FIXED_ONE + FIXED_ONE / 2 - a.y)) >> 8);
        for (current_row = edge_first; current_row <= edge_last;
             current_row += step) {
            if (x_value < work_left[current_row]) {
                work_left[current_row] = clamp_projected(x_value);
            }
            if (x_value > work_right[current_row]) {
                work_right[current_row] = clamp_projected(x_value);
            }
            if (current_row + step <= edge_last) x_value += x_step * step;
        }
    }
    return finish_result(
        result, layer, work_left, work_right, first_row, last_row
    );
}

static uint8_t raster_specialized_full(
    Result *result,
    const Point *point,
    uint8_t count,
    const Layer *layer
) {
    uint8_t index;
    int32_t minimum_y = point[0].y;
    int32_t maximum_y = minimum_y;
    int16_t first_row;
    int16_t last_row;
    int16_t row;
    int32_t work_left[MAX_HEIGHT];
    int32_t work_right[MAX_HEIGHT];

    reset_result(result);
    for (index = 1; index < count; ++index) {
        if (point[index].y < minimum_y) minimum_y = point[index].y;
        if (point[index].y > maximum_y) maximum_y = point[index].y;
    }
    first_row = ceil_q8(minimum_y - FIXED_ONE / 2);
    last_row = floor_q8(maximum_y - 1 - FIXED_ONE / 2);
    if (first_row < layer->first_row) first_row = layer->first_row;
    if (last_row > layer->last_row) last_row = layer->last_row;
    if (first_row < 0) first_row = 0;
    if (last_row >= layer->height) last_row = layer->height - 1;
    if (first_row <= 0) first_row = 0;
    if (last_row < 0) return 0;
    if (first_row > last_row) return 0;

    for (row = first_row; row <= last_row; ++row) {
        work_left[row] = PROJECTED_LIMIT + 1;
        work_right[row] = -PROJECTED_LIMIT - 1;
    }
    for (index = 0; index < count; ++index) {
        Point a = point[index];
        Point b = point[index + 1 == count ? 0 : index + 1];
        int32_t delta_x;
        int32_t delta_y;
        int32_t x_step;
        int32_t x_value;
        int16_t edge_first;
        int16_t edge_last;
        int16_t current_row;

        if (a.y == b.y) continue;
        if (a.y > b.y) {
            Point swap = a;
            a = b;
            b = swap;
        }
        delta_x = b.x - a.x;
        delta_y = b.y - a.y;
        edge_first = ceil_q8(a.y - FIXED_ONE / 2);
        edge_last = floor_q8(b.y - 1 - FIXED_ONE / 2);
        if (edge_first < first_row) edge_first = first_row;
        if (edge_last > last_row) edge_last = last_row;
        if (edge_first <= 0) edge_first = 0;
        if (edge_first > edge_last) continue;

        x_step = edge_x_step(delta_x, delta_y);
        x_value = a.x +
            ((x_step * (edge_first * FIXED_ONE + FIXED_ONE / 2 - a.y)) >> 8);
        for (current_row = edge_first; current_row <= edge_last; ++current_row) {
            if (x_value < work_left[current_row]) {
                work_left[current_row] = clamp_projected(x_value);
            }
            if (x_value > work_right[current_row]) {
                work_right[current_row] = clamp_projected(x_value);
            }
            if (current_row < edge_last) x_value += x_step;
        }
    }
    return finish_result(
        result, layer, work_left, work_right, first_row, last_row
    );
}

static void initialize_reciprocals(void) {
    uint32_t index;
    for (index = 1; index < EDGE_RECIPROCAL_SIZE; ++index) {
        uint32_t denominator = index << EDGE_RECIPROCAL_SHIFT;
        uint32_t reciprocal =
            ((1u << (EDGE_STEP_PRECISION_SHIFT + 8)) + denominator / 2u) /
            denominator;
        reciprocal_table[index] =
            (uint16_t)(reciprocal > 65535u ? 65535u : reciprocal);
    }
}

int main(void) {
    static const int32_t boundary_y[] = {
        -80 * 256, -257, -256, -129, -128, -1, 0, 1, 127, 128,
        129, 255, 256, 257, 23 * 256, 24 * 256, 47 * 256,
        48 * 256, 80 * 256
    };
    const uint32_t trials = 100000;
    uint32_t trial;

    initialize_reciprocals();
    for (trial = 0; trial < trials; ++trial) {
        Layer layer;
        Point point[MAX_POINTS];
        Result original;
        Result specialized;
        uint8_t count = (uint8_t)random_range(3, MAX_POINTS + 1);
        uint8_t index;

        layer.width = (next_random() & 1u) != 0 ? 64 : 32;
        layer.height = layer.width == 64 ? 48 : 24;
        layer.first_row = (uint8_t)random_range(0, layer.height);
        layer.last_row = (uint8_t)random_range(layer.first_row, layer.height);
        for (index = 0; index < layer.height; ++index) {
            layer.row_left[index] = (uint8_t)random_range(0, layer.width);
            layer.row_right[index] = (uint8_t)random_range(
                layer.row_left[index], layer.width
            );
        }
        for (index = 0; index < count; ++index) {
            point[index].x = random_range(-60 * 256, 60 * 256 + 1);
            if (trial < sizeof(boundary_y) / sizeof(boundary_y[0]) * 8u) {
                point[index].y = boundary_y[
                    next_random() % (sizeof(boundary_y) / sizeof(boundary_y[0]))
                ];
            } else {
                point[index].y = random_range(-80 * 256, 112 * 256 + 1);
            }
        }
        raster_original_shift_zero(&original, point, count, &layer);
        raster_specialized_full(&specialized, point, count, &layer);
        if (memcmp(&original, &specialized, sizeof(original)) != 0) {
            fprintf(stderr, "FAIL: raster mismatch at randomized trial %lu\n",
                (unsigned long)trial);
            return EXIT_FAILURE;
        }
    }
    printf("PASS: %lu randomized full-resolution raster cases are exact\n",
        (unsigned long)trials);
    return EXIT_SUCCESS;
}
