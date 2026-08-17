#!/usr/bin/env python3
"""Convert a CEmu 8-bit VRAM/palette hash dump to a PNG."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def component(value: int) -> int:
    return value * 255 // 31


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("vram", type=Path)
    parser.add_argument("palette", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    vram = args.vram.read_bytes()
    palette_data = args.palette.read_bytes()
    if len(vram) != 320 * 240:
        raise SystemExit(f"expected 76800 VRAM bytes, found {len(vram)}")
    if len(palette_data) != 512:
        raise SystemExit(f"expected 512 palette bytes, found {len(palette_data)}")

    palette = []
    for offset in range(0, len(palette_data), 2):
        color = palette_data[offset] | palette_data[offset + 1] << 8
        palette.append((
            component((color >> 10) & 31),
            component((color >> 5) & 31),
            component(color & 31),
        ))

    image = Image.new("RGB", (320, 240))
    image.putdata([palette[index] for index in vram])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output)


if __name__ == "__main__":
    main()
