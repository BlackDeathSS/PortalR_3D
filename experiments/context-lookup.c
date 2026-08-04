#include <stdint.h>

typedef int24_t fixed_t;

typedef struct {
    uint16_t full_height;
    uint8_t start;
    uint8_t end;
    const uint8_t *boundaries;
    uint8_t center;
} WallContext;

extern uint16_t offsets[2048];
extern WallContext profiles[256];
extern const uint16_t *pages[32];
extern uint8_t direct_profiles[8192];

const WallContext *lookup_original(fixed_t distance) {
    uint24_t table_index = (uint24_t)distance >> 2;
    uint16_t profile_offset;

    if (table_index >= 2048) table_index = 2047;
    profile_offset = offsets[table_index];
    return (const WallContext *)((const uint8_t *)profiles + profile_offset);
}

const WallContext *lookup_bytes(fixed_t distance) {
    const volatile uint8_t *bytes = (const uint8_t *)&distance;
    uint16_t index;

    if (bytes[2] != 0 || bytes[1] >= 32) {
        index = 2047;
    } else {
        index = (uint16_t)((uint16_t)bytes[1] * 64u + (bytes[0] >> 2));
    }
    return (const WallContext *)((const uint8_t *)profiles + offsets[index]);
}

const WallContext *lookup_pages(fixed_t distance) {
    const volatile uint8_t *bytes = (const uint8_t *)&distance;
    const uint16_t *page;
    uint8_t low;

    if (bytes[2] != 0 || bytes[1] >= 32) {
        return (const WallContext *)((const uint8_t *)profiles + offsets[2047]);
    }
    page = pages[bytes[1]];
    low = (uint8_t)(bytes[0] >> 2);
    return (const WallContext *)((const uint8_t *)profiles + page[low]);
}

const WallContext *lookup_direct_profile(fixed_t distance) {
    uint24_t index = (uint24_t)distance;

    if (index >= 8192u) index = 8191u;
    return &profiles[direct_profiles[index]];
}
