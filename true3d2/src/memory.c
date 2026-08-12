#include "internal.h"

/* Full-RAM mode is intentionally fail-closed. Defining the build flag makes the
   recovery milestone compile, but cannot make an unverified takeover execute. */
uint8_t t3d2_memory_prepare(void) {
#if T3D2_ENABLE_FULL_TAKEOVER
    return T3D2_ERROR_MEMORY_UNPROVEN;
#else
    return T3D2_ERROR_MEMORY_DISABLED;
#endif
}

uint8_t t3d2_memory_restore(void) {
#if T3D2_ENABLE_FULL_TAKEOVER
    return T3D2_ERROR_MEMORY_UNPROVEN;
#else
    return T3D2_ERROR_MEMORY_DISABLED;
#endif
}

void t3d2_memory_discard_backup(void) {
}
