#include "internal.h"

static const int16_t quarter_sine[65] = {
    0, 6, 13, 19, 25, 31, 38, 44, 50, 56, 62, 68, 74, 80, 86, 92,
    98, 104, 109, 115, 121, 126, 132, 137, 142, 147, 152, 157, 162,
    167, 172, 177, 181, 185, 190, 194, 198, 202, 206, 209, 213, 216,
    220, 223, 226, 229, 231, 234, 237, 239, 241, 243, 245, 247, 248,
    250, 251, 252, 253, 254, 255, 255, 256, 256, 256
};

int16_t t3d2_sin_q8(uint8_t angle) {
    uint8_t quadrant = (uint8_t)(angle >> 6);
    uint8_t offset = (uint8_t)(angle & 63u);

    if (quadrant == 0u) return quarter_sine[offset];
    if (quadrant == 1u) return quarter_sine[64u - offset];
    if (quadrant == 2u) return (int16_t)-quarter_sine[offset];
    return (int16_t)-quarter_sine[64u - offset];
}

int16_t t3d2_cos_q8(uint8_t angle) {
    return t3d2_sin_q8((uint8_t)(angle + 64u));
}
