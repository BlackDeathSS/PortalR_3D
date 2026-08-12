#include <fileioc.h>
#include <graphx.h>
#include <keypadc.h>
#include <stdint.h>
#include <string.h>

#define BACKUP_CHUNKS 5u

typedef struct __attribute__((packed)) {
    uint8_t magic[8];
    uint8_t version;
    uint8_t state;
    uint8_t chunk_count;
    uint8_t flags;
    uint32_t generation;
    uint32_t ram_size;
    uint32_t ram_crc32;
    uint32_t chunk_size[BACKUP_CHUNKS];
    uint32_t chunk_crc32[BACKUP_CHUNKS];
    uint32_t manifest_crc32;
} RecoveryJournal;

_Static_assert(sizeof(RecoveryJournal) == 68u, "recovery journal layout changed");

static uint32_t crc32(const void *data, uint24_t size) {
    const uint8_t *cursor = (const uint8_t *)data;
    uint32_t crc = 0xFFFFFFFFUL;
    uint24_t index;

    for (index = 0u; index < size; ++index) {
        uint8_t bit;

        crc ^= cursor[index];
        for (bit = 0u; bit < 8u; ++bit) {
            uint32_t mask = (uint32_t)-(int32_t)(crc & 1u);

            crc = (crc >> 1) ^ (0xEDB88320UL & mask);
        }
    }
    return crc ^ 0xFFFFFFFFUL;
}

static void print_line(const char *text, uint8_t row) {
    gfx_PrintStringXY(text, 8, (int)((uint24_t)row * 16u + 8u));
}

static uint8_t load_journal(RecoveryJournal *journal) {
    ti_var_t handle = ti_Open("T3DBKM", "r");

    if (handle == 0u || ti_GetSize(handle) != sizeof(*journal)) {
        if (handle != 0u) ti_Close(handle);
        return 0u;
    }
    memcpy(journal, ti_GetDataPtr(handle), sizeof(*journal));
    ti_Close(handle);
    return (uint8_t)(memcmp(journal->magic, "T3DBK1\0\0", 8u) == 0 &&
        journal->version == 1u && journal->chunk_count == BACKUP_CHUNKS &&
        journal->state >= 1u && journal->state <= 5u &&
        crc32(journal, sizeof(*journal) - sizeof(journal->manifest_crc32)) ==
            journal->manifest_crc32);
}

static uint8_t verify_chunks(const RecoveryJournal *journal) {
    uint8_t index;
    uint32_t combined_crc = 0xFFFFFFFFUL;
    uint32_t combined_size = 0u;

    for (index = 0u; index < BACKUP_CHUNKS; ++index) {
        char name[8] = "T3DBK0";
        ti_var_t handle;
        uint24_t size;
        const uint8_t *data;
        uint24_t byte_index;

        name[5] = (char)('0' + index);
        handle = ti_Open(name, "r");
        if (handle == 0u) return 0u;
        size = ti_GetSize(handle);
        data = (const uint8_t *)ti_GetDataPtr(handle);
        if (journal->chunk_size[index] != size ||
            crc32(data, size) != journal->chunk_crc32[index]) {
            ti_Close(handle);
            return 0u;
        }
        for (byte_index = 0u; byte_index < size; ++byte_index) {
            uint8_t bit;

            combined_crc ^= data[byte_index];
            for (bit = 0u; bit < 8u; ++bit) {
                uint32_t mask = (uint32_t)-(int32_t)(combined_crc & 1u);

                combined_crc = (combined_crc >> 1) ^ (0xEDB88320UL & mask);
            }
        }
        combined_size += size;
        ti_Close(handle);
    }
    combined_crc ^= 0xFFFFFFFFUL;
    return (uint8_t)(combined_size == journal->ram_size &&
                     combined_crc == journal->ram_crc32);
}

static void delete_backup(void) {
    uint8_t index;

    for (index = 0u; index < BACKUP_CHUNKS; ++index) {
        char name[8] = "T3DBK0";

        name[5] = (char)('0' + index);
        (void)ti_Delete(name);
    }
    (void)ti_Delete("T3DBKM");
}

int main(void) {
    RecoveryJournal journal;
    uint8_t journal_valid;
    uint8_t chunks_valid = 0u;

    gfx_Begin();
    gfx_SetDrawScreen();
    gfx_FillScreen(255u);
    gfx_SetTextFGColor(0u);
    print_line("True3D2 recovery inspector", 0u);
    print_line("Checking journal and chunks...", 2u);
    journal_valid = load_journal(&journal);
    if (journal_valid != 0u) chunks_valid = verify_chunks(&journal);
    gfx_FillScreen(255u);
    print_line("True3D2 recovery inspector", 0u);
    if (journal_valid == 0u) {
        print_line("Journal missing or invalid.", 2u);
        print_line("No restore will be attempted.", 3u);
    } else if (chunks_valid == 0u) {
        print_line("Backup CRC verification FAILED.", 2u);
        print_line("No restore will be attempted.", 3u);
    } else {
        print_line("All five chunks verified.", 2u);
        print_line("PC extraction is safe.", 3u);
        print_line("Del: remove set  Clear: keep", 5u);
    }
    while (kb_AnyKey()) kb_Scan();
    do {
        kb_Scan();
        if (chunks_valid != 0u && kb_IsDown(kb_KeyDel)) {
            while (kb_AnyKey()) kb_Scan();
            gfx_FillScreen(255u);
            print_line("Press Del again to DELETE", 2u);
            print_line("all verified backup chunks.", 3u);
            do {
                kb_Scan();
                if (kb_IsDown(kb_KeyClear)) break;
                if (kb_IsDown(kb_KeyDel)) {
                    delete_backup();
                    break;
                }
            } while (1);
            break;
        }
    } while (!kb_IsDown(kb_KeyClear));
    gfx_End();
    return 0;
}
