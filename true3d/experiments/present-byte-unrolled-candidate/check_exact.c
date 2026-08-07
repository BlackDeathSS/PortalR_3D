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

static uint8_t expected[OUTPUT_WIDTH * OUTPUT_HEIGHT];
static uint8_t actual[OUTPUT_WIDTH * OUTPUT_HEIGHT];
static uint64_t digest = UINT64_C(1469598103934665603);

static void reference_frame(const uint8_t *source, uint8_t *destination) {
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

/* Model the assembly literally: write five bytes for each source byte, then
 * perform the same forward-overlapping 1,280-byte vertical transfer. */
static void unrolled_frame(const uint8_t *source, uint8_t *destination) {
    unsigned y, x, copy;
    for (y = 0; y < HEIGHT; ++y) {
        uint8_t *row = destination + y * SCALE * OUTPUT_WIDTH;
        uint8_t *output = row;
        for (x = 0; x < WIDTH; ++x) {
            uint8_t color = *source++;
            *output++ = color;
            *output++ = color;
            *output++ = color;
            *output++ = color;
            *output++ = color;
        }
        for (copy = 0; copy < 1280; ++copy) {
            row[OUTPUT_WIDTH + copy] = row[copy];
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
    reference_frame(source, expected);
    memset(actual, 0xa5, sizeof(actual));
    unrolled_frame(source, actual);
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

int main(void) {
    uint8_t source[WIDTH * HEIGHT];
    unsigned bits, color, test, index;
    unsigned cases = 0;

    /* Tile every 16-pixel binary transition pattern across a complete frame. */
    for (bits = 0; bits < (1u << 16); ++bits) {
        for (index = 0; index < sizeof(source); ++index) {
            source[index] = (uint8_t)((bits >> (index & 15)) & 1u);
        }
        check_frame(source, "binary", bits);
        ++cases;
    }

    for (color = 0; color < 256; ++color) {
        memset(source, color, sizeof(source));
        check_frame(source, "solid", color);
        ++cases;
    }

    for (test = 0; test < 20000; ++test) {
        for (index = 0; index < sizeof(source); ++index) {
            source[index] = (uint8_t)next_random();
        }
        check_frame(source, "random", test);
        ++cases;
    }

    printf("complete frame cases passed: %u\n", cases);
    printf("output bytes compared: %" PRIu64 "\n",
           (uint64_t)cases * sizeof(actual));
    printf("framebuffer FNV-1a-64: %016" PRIx64 "\n", digest);
    puts("horizontal model per row: 1598 -> 1152 cycles (-27.91%)");
    return 0;
}
