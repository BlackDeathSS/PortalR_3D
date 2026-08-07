#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    WIDTH = 64,
    HEIGHT = 48,
    SCALE = 5,
    OUTPUT_WIDTH = 320,
    OUTPUT_HEIGHT = 240
};

static uint8_t color_table[256 * 3];
static uint8_t expected[OUTPUT_WIDTH * OUTPUT_HEIGHT];
static uint8_t actual[OUTPUT_WIDTH * OUTPUT_HEIGHT];
static uint64_t digest = UINT64_C(1469598103934665603);

static void initialize_table(void) {
    unsigned color;
    for (color = 0; color < 256; ++color) {
        color_table[color * 3 + 0] = (uint8_t)color;
        color_table[color * 3 + 1] = (uint8_t)color;
        color_table[color * 3 + 2] = (uint8_t)color;
    }
}

static void fixed_frame(const uint8_t *source, uint8_t *destination) {
    unsigned y, x, sy, sx;
    for (y = 0; y < HEIGHT; ++y) {
        for (sy = 0; sy < SCALE; ++sy) {
            uint8_t *row = destination + (y * SCALE + sy) * OUTPUT_WIDTH;
            for (x = 0; x < WIDTH; ++x) {
                for (sx = 0; sx < SCALE; ++sx) {
                    row[x * SCALE + sx] = source[y * WIDTH + x];
                }
            }
        }
    }
}

static void wide_frame(const uint8_t *source, uint8_t *destination) {
    unsigned y, x, sy;
    for (y = 0; y < HEIGHT; ++y) {
        uint8_t *row = destination + y * SCALE * OUTPUT_WIDTH;
        const uint8_t *packed = NULL;
        uint8_t previous = 0;

        for (x = 0; x < WIDTH; ++x) {
            uint8_t color = *source++;
            if (x == 0 || color != previous) {
                packed = color_table + color * 3;
                previous = color;
            }
            memcpy(row + x * SCALE, packed, 3);
            memcpy(row + x * SCALE + 2, packed, 3);
        }
        for (sy = 1; sy < SCALE; ++sy) {
            memcpy(row + sy * OUTPUT_WIDTH, row, OUTPUT_WIDTH);
        }
    }
}

static uint32_t random_state = UINT32_C(0x5eed1e23);

static uint32_t next_random(void) {
    uint32_t x = random_state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return random_state = x;
}

static void include_digest(const uint8_t *data, size_t size) {
    size_t index;
    for (index = 0; index < size; ++index) {
        digest ^= data[index];
        digest *= UINT64_C(1099511628211);
    }
}

static void check_frame(const uint8_t *source, const char *category,
                        unsigned case_number) {
    fixed_frame(source, expected);
    memset(actual, 0xa5, sizeof(actual));
    wide_frame(source, actual);
    if (memcmp(expected, actual, sizeof(actual)) != 0) {
        size_t index;
        for (index = 0; index < sizeof(actual); ++index) {
            if (expected[index] != actual[index]) {
                fprintf(stderr,
                        "%s case %u differs at %zu: %u != %u\n",
                        category, case_number, index,
                        expected[index], actual[index]);
                exit(1);
            }
        }
    }
    include_digest(actual, sizeof(actual));
}

static unsigned row_runs(const uint8_t *row) {
    unsigned index, runs = 1;
    for (index = 1; index < WIDTH; ++index) {
        runs += row[index] != row[index - 1];
    }
    return runs;
}

int main(void) {
    uint8_t source[WIDTH * HEIGHT];
    unsigned bits, color, test, index;
    unsigned row_cases = 0;
    uint64_t modeled_baseline = 0;
    uint64_t modeled_candidate = 0;

    initialize_table();

    /* Exhaust every transition mask through 16 binary pixels, tiled over an
     * actual 64-pixel row and repeated through the complete frame. */
    for (bits = 0; bits < (1u << 16); ++bits) {
        for (index = 0; index < sizeof(source); ++index) {
            source[index] = (uint8_t)((bits >> (index & 15)) & 1u);
        }
        check_frame(source, "binary", bits);
        ++row_cases;
    }

    for (color = 0; color < 256; ++color) {
        memset(source, color, sizeof(source));
        check_frame(source, "solid", color);
        ++row_cases;
    }

    for (test = 0; test < 20000; ++test) {
        for (index = 0; index < sizeof(source); ++index) {
            if ((test & 3u) == 0) {
                /* Blocky spans similar to projected walls/background. */
                source[index] = (uint8_t)(next_random() & 15u);
                if ((index & 7u) != 0) source[index] = source[index - 1];
            } else if ((test & 3u) == 1) {
                source[index] = (uint8_t)((index & 1u) ? 255u : 0u);
            } else {
                source[index] = (uint8_t)next_random();
            }
        }
        check_frame(source, "random", test);
        for (index = 0; index < HEIGHT; ++index) {
            unsigned runs = row_runs(source + index * WIDTH);
            unsigned hits = WIDTH - runs;
            modeled_baseline += 1598;
            modeled_candidate += 2054 - 13 * hits;
        }
        ++row_cases;
    }

    printf("complete frame cases passed: %u\n", row_cases);
    printf("output bytes compared: %" PRIu64 "\n",
           (uint64_t)row_cases * sizeof(actual));
    printf("framebuffer FNV-1a-64: %016" PRIx64 "\n", digest);
    printf("horizontal model over random/adversarial corpus: "
           "%" PRIu64 " -> %" PRIu64 " cycles (%+.3f%%)\n",
           modeled_baseline, modeled_candidate,
           ((double)modeled_candidate / modeled_baseline - 1.0) * 100.0);
    puts("candidate row break-even: at least 36 adjacent-color hits "
         "(28 runs or fewer)");
    return 0;
}
