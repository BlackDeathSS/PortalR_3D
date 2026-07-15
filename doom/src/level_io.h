#ifndef DOOMCE_LEVEL_IO_H
#define DOOMCE_LEVEL_IO_H

#include "level_format.h"

#include <stdint.h>

#define LEVEL_APPVAR_NAME "DOOMLVL1"

typedef struct {
    uint8_t handle;
    uint8_t external;
} LevelSource;

uint8_t level_source_open(LevelView *view, LevelSource *source);
void level_source_close(LevelSource *source);

#endif
