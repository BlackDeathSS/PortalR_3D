#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static uint32_t rng_state = UINT32_C(0x9E3779B9);

static uint32_t next_random(void) {
    uint32_t value = rng_state;
    value ^= value << 13;
    value ^= value >> 17;
    value ^= value << 5;
    rng_state = value;
    return value;
}

static int32_t reference_dot(const int32_t a[3], const int32_t c[3]) {
    int64_t sum = (int64_t)a[0] * c[0] +
        (int64_t)a[1] * c[1] + (int64_t)a[2] * c[2];
    return (int32_t)(sum >> 8);
}

/* Algebra used by transform_point_exact before its byte-column assembly. */
static int32_t candidate_dot(const int32_t a[3], const int32_t c[3]) {
    int64_t sum = 0;
    unsigned index;

    for (index = 0; index < 3; ++index) {
        uint32_t unsigned_a = (uint32_t)a[index] & UINT32_C(0xFFFFFF);
        uint32_t c0 = (uint32_t)c[index] & UINT32_C(0xFF);
        int32_t c1 = c[index] < 0 ? -1 : c[index] > 255 ? 1 : 0;
        int64_t product = (int64_t)unsigned_a * c0;

        if (a[index] < 0) product -= (int64_t)c0 << 24;
        product += (int64_t)a[index] * c1 * 256;
        sum += product;
    }
    return (int32_t)(sum >> 8);
}

static int32_t reference_scale(uint32_t extent, int32_t coefficient) {
    return (int32_t)(((int64_t)extent * coefficient) >> 8);
}

/* Algebra used by scale_camera_axis_exact before its two byte multiplies. */
static int32_t candidate_scale(uint32_t extent, int32_t coefficient) {
    uint32_t c0 = (uint32_t)coefficient & UINT32_C(0xFF);
    int32_t c1 = coefficient < 0 ? -1 : coefficient > 255 ? 1 : 0;
    return (int32_t)((extent * c0) >> 8) + (int32_t)extent * c1;
}

int main(void) {
    uint64_t checks = 0;
    unsigned iteration;

    for (iteration = 0; iteration < 5000000u; ++iteration) {
        int32_t a[3];
        int32_t c[3];
        unsigned index;

        for (index = 0; index < 3; ++index) {
            a[index] = (int32_t)(next_random() % 262141u) - 131070;
            c[index] = (int32_t)(next_random() % 513u) - 256;
        }
        if (reference_dot(a, c) != candidate_dot(a, c)) {
            fprintf(stderr, "dot mismatch at iteration %u\n", iteration);
            return EXIT_FAILURE;
        }
        ++checks;
    }

    for (iteration = 0; iteration <= 65535u; ++iteration) {
        int32_t coefficient;

        for (coefficient = -256; coefficient <= 256; ++coefficient) {
            if (reference_scale(iteration, coefficient) !=
                candidate_scale(iteration, coefficient)) {
                fprintf(
                    stderr,
                    "scale mismatch: extent=%u coefficient=%" PRId32 "\n",
                    iteration,
                    coefficient
                );
                return EXIT_FAILURE;
            }
            ++checks;
        }
    }

    printf("PASS: %" PRIu64 " exact transform/scale checks\n", checks);
    return EXIT_SUCCESS;
}
