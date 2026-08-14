import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import server  # noqa: E402


def sample_project(level_count=2):
    cells = [[1 if x in (0, 14) or y in (0, 14) else 0 for x in range(15)] for y in range(15)]
    portal = {
        "name": "Grid",
        "cells": cells,
        "spawn": {"x": 2.5, "y": 2.5, "angle": 90},
        "portals": [
            {"x": 0, "y": 4, "direction": 1, "targetX": 14, "targetY": 4, "targetDirection": 0}
        ],
    }
    t3d3 = {
        "name": "Chamber",
        "rooms": [{
            "name": "Room", "minX": -4, "maxX": 4, "minY": 0, "maxY": 8,
            "minZ": 0, "maxZ": 5, "colors": [2, 3, 5, 4, 5, 5],
        }],
        "spawn": {"room": 0, "x": 0, "y": 2, "z": 1.5},
        "portals": [
            {"active": False, "room": 0, "face": 3, "x": 0, "y": 8, "z": 2.5},
            {"active": False, "room": 0, "face": 2, "x": 0, "y": 0, "z": 2.5},
        ],
    }
    return {
        "format": "PortalR3DProject", "version": 1,
        "portal3d": {"levels": [dict(portal, name=f"Grid {i + 1}") for i in range(level_count)]},
        "t3d3": {"levels": [dict(t3d3, name=f"Chamber {i + 1}") for i in range(level_count)]},
    }


class GeneratorTests(unittest.TestCase):
    def test_generates_multiple_portal3d_levels(self):
        source = server.generate_portal3d(sample_project())
        self.assertIn("level_1_walls", source)
        self.assertIn('"Grid 2"', source)
        self.assertIn("portal3d_level_count", source)

    def test_generates_multiple_t3d3_levels(self):
        source = server.generate_t3d3(sample_project())
        self.assertIn("GeneratedT3D3Level1", source)
        self.assertIn('"Chamber 2"', source)
        self.assertIn("t3d3_embedded_level_count", source)

    def test_rejects_open_raycaster_border(self):
        project = sample_project(1)
        project["portal3d"]["levels"][0]["cells"][0][2] = 0
        with self.assertRaisesRegex(server.ProjectError, "solid outer wall"):
            server.generate_portal3d(project)

    def test_rejects_spawn_in_wall(self):
        project = sample_project(1)
        project["portal3d"]["levels"][0]["spawn"] = {"x": 0.5, "y": 0.5, "angle": 0}
        with self.assertRaisesRegex(server.ProjectError, "empty cell"):
            server.generate_portal3d(project)


if __name__ == "__main__":
    unittest.main()
