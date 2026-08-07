#!/usr/bin/env python3
"""Exhaustively prove the experimental prepacked wall records are exact."""

from __future__ import annotations


MATERIALS = 4
SHADES = 4
WIDTH = 16
HEIGHT = 8
COLORS = 8
COLOR_TEXTURE_BASE = 18
PALETTE_STRIDE = SHADES * COLORS
RECORD_SIZE = 4
TABLE_SIZE = MATERIALS * SHADES * WIDTH * HEIGHT * RECORD_SIZE


def texel(material: int, x: int, source_row: int) -> int:
    y = source_row * 2
    if material == 0:
        mortar = x == 0 or y == 0 or y == 8 or (y >= 8 and x == 8)
        noise = (x * 5 + y * 3 + ((x ^ y) * 7)) & 3
        return 0 if mortar else 2 + noise
    if material == 1:
        seam = x in (0, 8) or y in (0, 8)
        rivet = (x & 7) in (2, 6) and (y & 7) in (2, 6)
        brushed = 2 + ((x * 3 + y * 5 + (x ^ y)) & 3)
        return 0 if seam else (7 if rivet else brushed)
    if material == 2:
        joint = y in (0, 8) or (x == 0 if y < 8 else x == 8)
        aggregate = 2 + ((x * 7 + y * 11 + (x ^ (y * 3))) & 3)
        pock = ((x * 13 + y * 5) & 31) == 0
        return 0 if joint else (1 if pock else aggregate)

    seam = x in (0, 8) or y in (0, 8)
    hazard = (x + y) & 7
    plate = 2 + ((x * 5 + y * 3 + (x ^ y)) & 3)
    return 0 if seam else (6 + (hazard & 1) if hazard < 2 else plate)


def next_source_row(material: int, x: int, source_row: int) -> int:
    value = texel(material, x, source_row)
    next_row = source_row + 1
    while next_row < HEIGHT and texel(material, x, next_row) == value:
        next_row += 1
    return next_row


def palette(material: int, shade: int, value: int) -> int:
    return COLOR_TEXTURE_BASE + material * PALETTE_STRIDE + shade * COLORS + value


def c_record_offset(material: int, shade: int, x: int, source_row: int) -> int:
    return (
        (((material * SHADES + shade) * WIDTH + x) * HEIGHT + source_row)
        * RECORD_SIZE
    )


def asm_column_base(material: int, shade: int, x: int) -> int:
    # Assembly starts with H=material*4+shade and L=x<<4, then doubles HL.
    return (((material * SHADES + shade) << 8) | (x << 4)) << 1


def main() -> None:
    table = bytearray(TABLE_SIZE)
    checked = 0

    for material in range(MATERIALS):
        for shade in range(SHADES):
            for x in range(WIDTH):
                base = asm_column_base(material, shade, x)
                assert base == c_record_offset(material, shade, x, 0)

                for source_row in range(HEIGHT):
                    value = texel(material, x, source_row)
                    next_row = next_source_row(material, x, source_row)
                    color = palette(material, shade, value)
                    offset = c_record_offset(material, shade, x, source_row)
                    assembly_offset = base + (source_row << 2)
                    assert offset == assembly_offset
                    assert 0 <= color <= 255
                    assert source_row < next_row <= HEIGHT

                    table[offset] = next_row
                    table[offset + 1 : offset + 4] = bytes((color, color, color))

                    legacy_packed = color | (color << 8) | (color << 16)
                    packed = int.from_bytes(table[offset + 1 : offset + 4], "little")
                    assert table[offset] == next_row
                    assert packed == legacy_packed
                    checked += 1

                # Follow the same run chain used by the assembly full-wall loop.
                row = 0
                covered: list[int] = []
                while row < HEIGHT:
                    offset = base + (row << 2)
                    next_row = table[offset]
                    color = table[offset + 1]
                    expected = palette(material, shade, texel(material, x, row))
                    assert color == expected
                    covered.extend([color] * (next_row - row))
                    row = next_row
                assert row == HEIGHT
                assert covered == [
                    palette(material, shade, texel(material, x, y))
                    for y in range(HEIGHT)
                ]

    assert len(table) == 8192
    assert checked == 2048
    print(
        "prepacked wall runs exact: 2,048 records / 8,192 bytes; "
        "512 complete material-shade-column run chains"
    )


if __name__ == "__main__":
    main()
