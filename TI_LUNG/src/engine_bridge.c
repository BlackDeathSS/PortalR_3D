#include "engine_bridge.h"

/* Compile the compatibility renderer into this independent game without
 * duplicating its maintained 3D implementation. */
#include "../../t3d3/src/engine.c"

void ti_lung_engine_invalidate(void) {
#if T3D3_RENDER_WIDTH < 160
    present_frame_cache_valid[0] = 0;
    present_frame_cache_valid[1] = 0;
#endif
}
