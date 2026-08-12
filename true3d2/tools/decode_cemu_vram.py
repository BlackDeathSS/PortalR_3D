#!/usr/bin/env python3
"""Convert a CEmu 8-bit VRAM and LCD palette dump to a 320x240 PNG."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


WIDTH = 320
HEIGHT = 240


def decode(source: Path, palette_path: Path, destination: Path) -> None:
    data = source.read_bytes()
    palette_data = palette_path.read_bytes()
    expected = WIDTH * HEIGHT
    if len(data) != expected:
        raise ValueError(f"VRAM dump is {len(data)} bytes, expected {expected}")
    if len(palette_data) != 512:
        raise ValueError(f"palette dump is {len(palette_data)} bytes, expected 512")
    palette: list[tuple[int, int, int]] = []
    for offset in range(0, 512, 2):
        value = palette_data[offset] | palette_data[offset + 1] << 8
        red = (value >> 10) & 31
        green = (value >> 5) & 31
        blue = value & 31
        palette.append(((red << 3) | (red >> 2),
                        (green << 3) | (green >> 2),
                        (blue << 3) | (blue >> 2)))
    image = Image.new("RGB", (WIDTH, HEIGHT))
    pixels = image.load()
    for index, color in enumerate(data):
        pixels[index % WIDTH, index // WIDTH] = palette[color]
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("palette", type=Path)
    parser.add_argument("destination", type=Path)
    arguments = parser.parse_args()
    decode(arguments.source, arguments.palette, arguments.destination)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
