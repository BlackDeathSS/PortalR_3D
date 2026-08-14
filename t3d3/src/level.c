#include "level.h"

static uint8_t bind_level(True3DLevelView *view, const void *data, size_t size) {
    const True3DLevelHeader *header = data;
    const True3DRoomRecord *rooms;
    size_t required;
    uint8_t index;

    if (view == NULL || data == NULL || size < sizeof(True3DLevelHeader)) return 0;
    if (header->magic[0] != 'T' || header->magic[1] != '3' ||
        header->magic[2] != 'D' || header->magic[3] != '1' ||
        header->version != TRUE3D_LEVEL_VERSION ||
        header->room_count == 0 || header->room_count > TRUE3D_MAX_ROOMS ||
        header->spawn_room >= header->room_count) {
        return 0;
    }
    required = sizeof(True3DLevelHeader) +
        (size_t)header->room_count * sizeof(True3DRoomRecord);
    if (required > size) return 0;
    rooms = (const True3DRoomRecord *)(header + 1);

    for (index = 0; index < header->room_count; ++index) {
        const True3DRoomRecord *room = &rooms[index];
        uint8_t face;
        if (room->maximum_x - room->minimum_x < 2 * 256 ||
            room->maximum_y - room->minimum_y < 2 * 256 ||
            room->maximum_z - room->minimum_z < 2 * 256) {
            return 0;
        }
        for (face = 0; face < TRUE3D_FACE_COUNT; ++face) {
            if (room->face_color[face] > TRUE3D_MAX_COLOR) return 0;
        }
    }
    {
        const True3DRoomRecord *spawn_room = &rooms[header->spawn_room];
        if (header->spawn_x <= spawn_room->minimum_x ||
            header->spawn_x >= spawn_room->maximum_x ||
            header->spawn_y <= spawn_room->minimum_y ||
            header->spawn_y >= spawn_room->maximum_y ||
            header->spawn_z < spawn_room->minimum_z + 64 ||
            header->spawn_z >= spawn_room->maximum_z) {
            return 0;
        }
    }
    for (index = 0; index < TRUE3D_PORTAL_COUNT; ++index) {
        if ((header->portal_active_mask & (1u << index)) != 0 &&
            (header->portal[index].room >= header->room_count ||
             header->portal[index].face >= TRUE3D_FACE_COUNT)) {
            return 0;
        }
    }
    view->header = header;
    view->rooms = rooms;
    return 1;
}

uint8_t true3d_level_open(True3DLevelView *view, True3DLevelSource *source) {
    ti_var_t handle;

    if (view == NULL || source == NULL) return 0;
    source->handle = 0;
    source->external = 0;
    handle = ti_Open(T3D3_LEVEL_APPVAR, "r");
    if (handle != 0) {
        if (bind_level(view, ti_GetDataPtr(handle), ti_GetSize(handle))) {
            source->handle = handle;
            source->external = 1;
            return 1;
        }
        ti_Close(handle);
    }
    handle = ti_Open(TRUE3D_LEVEL_APPVAR, "r");
    if (handle != 0) {
        if (bind_level(view, ti_GetDataPtr(handle), ti_GetSize(handle))) {
            source->handle = handle;
            source->external = 1;
            return 1;
        }
        ti_Close(handle);
    }
    return true3d_level_builtin_view(view);
}

uint8_t true3d_level_builtin_view(True3DLevelView *view) {
    return true3d_level_embedded_view(0u, view);
}

uint8_t true3d_level_embedded_view(uint8_t index, True3DLevelView *view) {
    const T3D3EmbeddedLevel *level;

    if (index >= t3d3_embedded_level_count) return 0;
    level = &t3d3_embedded_levels[index];
    return bind_level(view, level->data, level->size);
}

const char *true3d_level_embedded_name(uint8_t index) {
    return index < t3d3_embedded_level_count ?
        t3d3_embedded_levels[index].name : "";
}

void true3d_level_close(True3DLevelSource *source) {
    if (source != NULL && source->handle != 0) {
        ti_Close(source->handle);
        source->handle = 0;
        source->external = 0;
    }
}
