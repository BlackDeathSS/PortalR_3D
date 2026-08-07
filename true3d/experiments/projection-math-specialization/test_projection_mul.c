#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define INT24_MINIMUM (-8388608)
#define INT24_MAXIMUM 8388607

static uint32_t random_state = 0x260806u;

static uint32_t next_random(void) {
    uint32_t value = random_state;
    value ^= value << 13;
    value ^= value >> 17;
    value ^= value << 5;
    random_state = value;
    return value;
}

static int32_t arithmetic_shift6(uint32_t bits) {
    int64_t signed_value = bits <= INT32_MAX ?
        (int64_t)bits : (int64_t)bits - 0x100000000LL;

    if (signed_value >= 0) return (int32_t)(signed_value / 64);
    return (int32_t)-((-signed_value + 63) / 64);
}

static int32_t reference_projection_mul(int32_t value, uint16_t scale) {
    uint32_t product = (uint32_t)value * (uint32_t)scale;
    return arithmetic_shift6(product);
}

/* Byte-for-byte model of src/projection_math.s. */
static int32_t assembly_projection_mul(int32_t value, uint16_t scale) {
    uint32_t x = (uint32_t)value & 0x00ffffffu;
    uint16_t p00 = (uint8_t)x * (uint8_t)scale;
    uint16_t p01 = (uint8_t)x * (uint8_t)(scale >> 8);
    uint16_t p10 = (uint8_t)(x >> 8) * (uint8_t)scale;
    uint16_t p11 = (uint8_t)(x >> 8) * (uint8_t)(scale >> 8);
    uint16_t p20 = (uint8_t)(x >> 16) * (uint8_t)scale;
    uint16_t p21 = (uint8_t)(x >> 16) * (uint8_t)(scale >> 8);
    uint16_t column;
    uint8_t byte0;
    uint8_t byte1;
    uint8_t byte2;
    uint8_t byte3;
    uint8_t iteration;

    byte0 = (uint8_t)p00;
    column = (p00 >> 8) + (uint8_t)p01 + (uint8_t)p10;
    byte1 = (uint8_t)column;
    column = (column >> 8) + (p01 >> 8) + (p10 >> 8) +
        (uint8_t)p11 + (uint8_t)p20;
    byte2 = (uint8_t)column;
    column = (column >> 8) + (p11 >> 8) + (p20 >> 8) + (uint8_t)p21;
    byte3 = (uint8_t)column;
    if (value < 0) byte3 = (uint8_t)(byte3 - (uint8_t)scale);

    for (iteration = 0; iteration < 6; ++iteration) {
        uint8_t carry3 = byte3 & 1u;
        uint8_t carry2 = byte2 & 1u;
        uint8_t carry1 = byte1 & 1u;

        byte3 = (uint8_t)((byte3 >> 1) | (byte3 & 0x80u));
        byte2 = (uint8_t)((byte2 >> 1) | (carry3 << 7));
        byte1 = (uint8_t)((byte1 >> 1) | (carry2 << 7));
        byte0 = (uint8_t)((byte0 >> 1) | (carry1 << 7));
    }
    return (int32_t)(
        (uint32_t)byte0 |
        (uint32_t)byte1 << 8 |
        (uint32_t)byte2 << 16 |
        (uint32_t)byte3 << 24
    );
}

static int32_t sign_extend24(uint32_t bits) {
    bits &= 0x00ffffffu;
    return (bits & 0x00800000u) != 0 ?
        (int32_t)(bits | 0xff000000u) : (int32_t)bits;
}

static int32_t reference_clamp(int32_t value) {
    if (value < -1048576) return -1048576;
    if (value > 1048576) return 1048576;
    return value;
}

/* Mirrors .Lproject_clamp's high-byte and low-24 comparisons. */
static int32_t assembly_clamp(uint32_t bits) {
    uint8_t high = (uint8_t)(bits >> 24);
    uint32_t low = bits & 0x00ffffffu;

    if ((high & 0x80u) == 0) {
        if (high != 0 || low > 0x00100000u) return 1048576;
        return (int32_t)low;
    }
    if (high != 0xffu || low < 0x00f00000u) return -1048576;
    return sign_extend24(low);
}

static int32_t reference_half24(int32_t value) {
    if (value >= 0) return value / 2;
    return -((-value + 1) / 2);
}

/* Mirrors SRA high / RR middle / RR low in the fused routine. */
static int32_t assembly_half24(int32_t value) {
    uint32_t bits = (uint32_t)value & 0x00ffffffu;
    uint8_t low = (uint8_t)bits;
    uint8_t middle = (uint8_t)(bits >> 8);
    uint8_t high = (uint8_t)(bits >> 16);
    uint8_t carry_high = high & 1u;
    uint8_t carry_middle = middle & 1u;

    high = (uint8_t)((high >> 1) | (high & 0x80u));
    middle = (uint8_t)((middle >> 1) | (carry_high << 7));
    low = (uint8_t)((low >> 1) | (carry_middle << 7));
    return sign_extend24(
        (uint32_t)low | (uint32_t)middle << 8 | (uint32_t)high << 16
    );
}

static void verify_pair(
    int32_t x,
    int32_t y,
    uint16_t scale,
    uint8_t render_shift,
    uint64_t *checks
) {
    int32_t reference_x = reference_clamp(
        8192 + reference_projection_mul(x, scale)
    );
    int32_t reference_y = reference_clamp(
        6144 - reference_projection_mul(y, scale)
    );
    uint32_t candidate_x_bits =
        (uint32_t)assembly_projection_mul(x, scale) + 8192u;
    uint32_t candidate_y_bits =
        6144u - (uint32_t)assembly_projection_mul(y, scale);
    int32_t candidate_x = assembly_clamp(candidate_x_bits);
    int32_t candidate_y = assembly_clamp(candidate_y_bits);

    if (render_shift != 0) {
        reference_x = reference_half24(reference_x);
        reference_y = reference_half24(reference_y);
        candidate_x = assembly_half24(candidate_x);
        candidate_y = assembly_half24(candidate_y);
    }
    ++*checks;
    if (reference_x != candidate_x || reference_y != candidate_y) {
        fprintf(
            stderr,
            "FAIL pair x=%ld y=%ld scale=%u shift=%u "
            "reference=(%ld,%ld) candidate=(%ld,%ld)\n",
            (long)x,
            (long)y,
            (unsigned)scale,
            (unsigned)render_shift,
            (long)reference_x,
            (long)reference_y,
            (long)candidate_x,
            (long)candidate_y
        );
        exit(EXIT_FAILURE);
    }
}

static void verify(int32_t value, uint16_t scale, uint64_t *checks) {
    int32_t reference = reference_projection_mul(value, scale);
    int32_t candidate = assembly_projection_mul(value, scale);

    ++*checks;
    if (reference != candidate) {
        fprintf(
            stderr,
            "FAIL value=%ld scale=%u reference=%ld candidate=%ld\n",
            (long)value,
            (unsigned)scale,
            (long)reference,
            (long)candidate
        );
        exit(EXIT_FAILURE);
    }
}

int main(void) {
    static const int32_t boundary_values[] = {
        INT24_MINIMUM, INT24_MINIMUM + 1, -1048576, -262144, -227001,
        -131071, -65536, -32769, -32768, -257, -256, -255, -65, -64,
        -63, -2, -1, 0, 1, 2, 63, 64, 65, 255, 256, 257, 32767,
        32768, 65535, 65536, 131070, 227001, 262143, 1048576,
        INT24_MAXIMUM - 1, INT24_MAXIMUM
    };
    static const uint16_t boundary_scales[] = {
        0, 1, 2, 3, 63, 64, 65, 127, 128, 255, 256, 257, 1023,
        4095, 8191, 16383, 21503, 21504, 32767, 32768, 65534, 65535
    };
    static const uint16_t exhaustive_scales[] = {
        0, 1, 63, 64, 255, 256, 21504, 65535
    };
    uint64_t checks = 0;
    size_t value_index;
    size_t scale_index;
    int32_t value;
    uint32_t trial;

    for (value_index = 0;
         value_index < sizeof(boundary_values) / sizeof(boundary_values[0]);
         ++value_index) {
        for (scale_index = 0;
             scale_index < sizeof(boundary_scales) / sizeof(boundary_scales[0]);
             ++scale_index) {
            verify(boundary_values[value_index], boundary_scales[scale_index], &checks);
        }
    }

    /* This exceeds the analytically bounded one-recursion camera-coordinate
     * range and exhausts every value within it at representative scales. */
    for (value = -262144; value <= 262143; ++value) {
        for (scale_index = 0;
             scale_index < sizeof(exhaustive_scales) / sizeof(exhaustive_scales[0]);
             ++scale_index) {
            verify(value, exhaustive_scales[scale_index], &checks);
        }
    }

    for (trial = 0; trial < 2000000u; ++trial) {
        int32_t random_value = (int32_t)(next_random() & 0x00ffffffu);
        uint16_t random_scale = (uint16_t)next_random();

        if ((random_value & 0x00800000L) != 0) random_value -= 0x01000000L;
        verify(random_value, random_scale, &checks);
    }

    /* Exercise the fused add/subtract, signed clamp, and int24 half shift. */
    for (trial = 0; trial < 2000000u; ++trial) {
        int32_t random_x = (int32_t)(next_random() & 0x00ffffffu);
        int32_t random_y = (int32_t)(next_random() & 0x00ffffffu);
        uint16_t random_scale = (uint16_t)next_random();

        if ((random_x & 0x00800000L) != 0) random_x -= 0x01000000L;
        if ((random_y & 0x00800000L) != 0) random_y -= 0x01000000L;
        verify_pair(
            random_x,
            random_y,
            random_scale,
            (uint8_t)(trial & 1u),
            &checks
        );
    }

    printf("PASS: %llu exact projection multiply/pair checks\n",
        (unsigned long long)checks);
    return EXIT_SUCCESS;
}
