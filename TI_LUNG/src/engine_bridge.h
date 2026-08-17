#ifndef TI_LUNG_ENGINE_BRIDGE_H
#define TI_LUNG_ENGINE_BRIDGE_H

#include "../../t3d3/src/engine.h"

/* TI_LUNG draws full-screen navigation panels between 3D photographs.  The
 * T3D3 presenter normally assumes it owns both physical buffers, so explicitly
 * invalidate its caches before it writes a new cabin view or photograph. */
void ti_lung_engine_invalidate(void);

#endif
