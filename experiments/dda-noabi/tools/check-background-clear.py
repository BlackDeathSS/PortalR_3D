#!/usr/bin/env python3
"""Check the exact byte coverage of the split-color assembly clear."""

from __future__ import annotations

from pathlib import Path
import re


ASM_PATH = Path(__file__).resolve().parents[1] / "src" / "render_asm.s"


def read_equ(source: str, name: str) -> int:
    match = re.search(
        rf"(?m)^\s*\.equ\s+{re.escape(name)}\s*,\s*(\d+)\s*$",
        source,
    )
    if match is None:
        raise AssertionError(f"missing numeric .equ {name} in {ASM_PATH}")
    return int(match.group(1))


def push_color(
    buffer: list[int | None],
    sp: int,
    color: int,
    pushes: int,
) -> int:
    for _ in range(pushes):
        sp -= 3
        buffer[sp : sp + 3] = [color, color, color]
    return sp


def main() -> None:
    source = ASM_PATH.read_text(encoding="utf-8")
    values = {
        name: read_equ(source, name)
        for name in (
            "BACKGROUND_HORIZON_COLOR",
            "BACKGROUND_FLOOR_COLOR",
            "BACKGROUND_CEILING_COLOR",
            "BACKGROUND_BUFFER_BYTES",
            "BACKGROUND_CEILING_BYTES",
            "BACKGROUND_HORIZON_BYTES",
            "BACKGROUND_FLOOR_BYTES",
            "BACKGROUND_PUSHES_PER_ITER",
            "BACKGROUND_FLOOR_ITERS",
            "BACKGROUND_FLOOR_TAIL",
            "BACKGROUND_HORIZON_ITERS",
            "BACKGROUND_HORIZON_TAIL",
            "BACKGROUND_CEILING_ITERS",
            "BACKGROUND_CEILING_TAIL",
            "BACKGROUND_REPAIR_TOP_OFFSET",
            "BACKGROUND_REPAIR_TOP_BYTES",
            "BACKGROUND_REPAIR_BOTTOM_OFFSET",
            "BACKGROUND_REPAIR_BOTTOM_BYTES",
            "GRID_NEAR_SCREEN_Y",
            "GRID_FAR_SCREEN_Y",
            "GRID_CEILING_NEAR_SCREEN_Y",
            "GRID_CEILING_FAR_SCREEN_Y",
        )
    }

    floor = values["BACKGROUND_FLOOR_COLOR"]
    ceiling = values["BACKGROUND_CEILING_COLOR"]
    horizon = values["BACKGROUND_HORIZON_COLOR"]
    total = values["BACKGROUND_BUFFER_BYTES"]
    ceiling_bytes = values["BACKGROUND_CEILING_BYTES"]
    horizon_bytes = values["BACKGROUND_HORIZON_BYTES"]
    floor_bytes = values["BACKGROUND_FLOOR_BYTES"]
    pushes_per_iteration = values["BACKGROUND_PUSHES_PER_ITER"]
    floor_pushes = (
        pushes_per_iteration * values["BACKGROUND_FLOOR_ITERS"]
        + values["BACKGROUND_FLOOR_TAIL"]
    )
    ceiling_pushes = (
        pushes_per_iteration * values["BACKGROUND_CEILING_ITERS"]
        + values["BACKGROUND_CEILING_TAIL"]
    )
    horizon_pushes = (
        pushes_per_iteration * values["BACKGROUND_HORIZON_ITERS"]
        + values["BACKGROUND_HORIZON_TAIL"]
    )

    if total != 320 * 240:
        raise AssertionError(f"unexpected framebuffer size: {total}")
    if (
        ceiling_bytes != 320 * 112
        or horizon_bytes != 320 * 16
        or floor_bytes != 320 * 112
    ):
        raise AssertionError(
            "split is not the exact 112/16/112-row background"
        )
    if ceiling_bytes + horizon_bytes + floor_bytes != total:
        raise AssertionError("background regions do not cover the framebuffer")
    if floor_pushes * 3 != floor_bytes - 2:
        raise AssertionError("floor PUSH run does not leave its two-byte head")
    if horizon_pushes * 3 != horizon_bytes - 2:
        raise AssertionError("horizon PUSH run does not leave its two-byte head")
    if ceiling_pushes * 3 != ceiling_bytes - 2:
        raise AssertionError("ceiling PUSH run does not leave its two-byte head")
    if source.count(".rept BACKGROUND_PUSHES_PER_ITER") != 1:
        raise AssertionError("split clear no longer has one shared unrolled PUSH run")

    horizon_rows = set(range(112, 128))
    ceiling_grid_rows = set(
        range(
            min(
                values["GRID_CEILING_NEAR_SCREEN_Y"],
                values["GRID_CEILING_FAR_SCREEN_Y"],
            ),
            max(
                values["GRID_CEILING_NEAR_SCREEN_Y"],
                values["GRID_CEILING_FAR_SCREEN_Y"],
            )
            + 1,
        )
    )
    floor_grid_rows = set(
        range(
            min(values["GRID_NEAR_SCREEN_Y"], values["GRID_FAR_SCREEN_Y"]),
            max(values["GRID_NEAR_SCREEN_Y"], values["GRID_FAR_SCREEN_Y"]) + 1,
        )
    )
    touched_horizon_rows = horizon_rows & (
        ceiling_grid_rows | floor_grid_rows
    )
    if touched_horizon_rows != {112, 113, 127}:
        raise AssertionError(
            "grid/horizon intersection changed: "
            f"{sorted(touched_horizon_rows)}"
        )

    # Model only framebuffer writes. CALL pushes its return vector into the
    # not-yet-filled range and the assembly helper immediately POPs it again.
    buffer: list[int | None] = [None] * total
    sp = total
    sp = push_color(buffer, sp, floor, floor_pushes)
    sp -= 2
    buffer[sp : sp + 2] = [floor, floor]
    expected_floor_start = ceiling_bytes + horizon_bytes
    if sp != expected_floor_start:
        raise AssertionError(
            f"floor landed at byte {sp}, expected {expected_floor_start}"
        )

    sp = push_color(buffer, sp, horizon, horizon_pushes)
    sp -= 2
    buffer[sp : sp + 2] = [horizon, horizon]
    if sp != ceiling_bytes:
        raise AssertionError(
            f"horizon landed at byte {sp}, expected {ceiling_bytes}"
        )

    sp = push_color(buffer, sp, ceiling, ceiling_pushes)
    sp -= 2
    buffer[sp : sp + 2] = [ceiling, ceiling]
    if sp != 0:
        raise AssertionError(
            f"ceiling landed at byte {sp}, expected framebuffer byte zero"
        )

    expected = (
        [ceiling] * ceiling_bytes
        + [horizon] * horizon_bytes
        + [floor] * floor_bytes
    )
    if buffer != expected:
        mismatch = next(
            index
            for index, (actual, wanted) in enumerate(zip(buffer, expected))
            if actual != wanted
        )
        raise AssertionError(
            f"background byte {mismatch}: got {buffer[mismatch]}, "
            f"expected {expected[mismatch]}"
        )

    # Model the only grid rows intersecting the horizon, then compare the
    # optimized three-row repair with the former full 16-row overwrite.
    old_pipeline = [ceiling] * ceiling_bytes + [floor] * (
        horizon_bytes + floor_bytes
    )
    new_pipeline = expected.copy()
    for x in range(0, 320, 3):
        for y in (112, 113):
            old_pipeline[y * 320 + x] = 17
            new_pipeline[y * 320 + x] = 17
        old_pipeline[127 * 320 + x] = 4
        new_pipeline[127 * 320 + x] = 4

    old_pipeline[112 * 320 : 128 * 320] = [horizon] * horizon_bytes
    repair_top_offset = values["BACKGROUND_REPAIR_TOP_OFFSET"]
    repair_top_bytes = values["BACKGROUND_REPAIR_TOP_BYTES"]
    repair_bottom_offset = values["BACKGROUND_REPAIR_BOTTOM_OFFSET"]
    repair_bottom_bytes = values["BACKGROUND_REPAIR_BOTTOM_BYTES"]
    new_pipeline[
        repair_top_offset : repair_top_offset + repair_top_bytes
    ] = [horizon] * repair_top_bytes
    new_pipeline[
        repair_bottom_offset : repair_bottom_offset + repair_bottom_bytes
    ] = [horizon] * repair_bottom_bytes

    if (repair_top_offset, repair_top_bytes) != (112 * 320, 2 * 320):
        raise AssertionError("top horizon repair must cover rows 112-113")
    if (repair_bottom_offset, repair_bottom_bytes) != (127 * 320, 320):
        raise AssertionError("bottom horizon repair must cover row 127")
    if new_pipeline != old_pipeline:
        raise AssertionError("three-row horizon repair differs from full repair")

    writes = total + repair_top_bytes + repair_bottom_bytes
    print(
        "split background clear exact: "
        f"{total} bytes in 112/16/112 rows + "
        f"{repair_top_bytes + repair_bottom_bytes} repaired bytes, "
        f"{writes} total writes, whole-phase interrupt mask"
    )


if __name__ == "__main__":
    main()
