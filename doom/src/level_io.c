#include "level_io.h"

#include <fileioc.h>

uint8_t level_source_open(LevelView *view, LevelSource *source) {
    uint8_t handle;

    if (view == NULL || source == NULL) return 0;
    source->handle = 0;
    source->external = 0;

    handle = ti_Open(LEVEL_APPVAR_NAME, "r");
    if (handle != 0) {
        const void *data = ti_GetDataPtr(handle);
        size_t size = ti_GetSize(handle);

        if (level_bind(view, data, size)) {
            source->handle = handle;
            source->external = 1;
            return 1;
        }
        ti_Close(handle);
    }

    return level_bind_builtin(view);
}

void level_source_close(LevelSource *source) {
    if (source != NULL && source->handle != 0) {
        ti_Close(source->handle);
        source->handle = 0;
        source->external = 0;
    }
}
