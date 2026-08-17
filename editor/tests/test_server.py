import sys
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

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

    def test_portal_pairs_generate_both_directions(self):
        source = server.generate_portal3d(sample_project(1))
        self.assertIn("{0,4,1,14,4,0}", source)
        self.assertIn("{14,4,0,0,4,1}", source)
        self.assertIn("[64]=1", source)
        self.assertIn("[78]=1", source)

    def test_spawn_degrees_use_the_engine_64_step_turn(self):
        source = server.generate_portal3d(sample_project(1))
        self.assertIn("640, 640, 4096, 2, level_0_enemies", source)

    def test_generates_gameplay_records_and_boss_exit(self):
        project = sample_project(1)
        project["portal3d"]["levels"][0].update({
            "enemies": [{"x": 10, "y": 10, "kind": "boss"}],
            "pickups": [{"x": 3, "y": 3, "kind": "shells"}],
            "doors": [{"x": 5, "y": 5, "orientation": 1}],
            "exit": {"x": 12, "y": 12},
        })
        source = server.generate_portal3d(project)
        self.assertIn("{10,10,2}", source)
        self.assertIn("{3,3,2}", source)
        self.assertIn("{5,5,1}", source)
        self.assertIn(", 1, 1, 1, 12, 12}", source)

    def test_generates_portal_render_settings(self):
        project = sample_project(1)
        project["portal3d"]["settings"] = {
            "portalRecursion": 4,
            "alwaysShowFps": False,
        }
        source = server.generate_portal3d(project)
        self.assertIn("portal3d_render_max_depth = 4", source)
        self.assertIn("portal3d_always_show_fps = 0", source)

    def test_rejects_portal_recursion_above_runtime_limit(self):
        project = sample_project(1)
        project["portal3d"]["settings"] = {"portalRecursion": 7}
        with self.assertRaisesRegex(server.ProjectError, "integer from 1 to 6"):
            server.generate_portal3d(project)

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

    def test_allows_any_portal_facing(self):
        project = sample_project(1)
        project["portal3d"]["levels"][0]["portals"][0]["direction"] = 0
        source = server.generate_portal3d(project)
        self.assertIn("{0,4,0,14,4,0}", source)

    def test_allows_different_faces_on_the_same_wall_cell(self):
        project = sample_project(1)
        project["portal3d"]["levels"][0]["portals"].append({
            "x": 0, "y": 4, "direction": 2,
            "targetX": 0, "targetY": 5, "targetDirection": 3,
        })
        source = server.generate_portal3d(project)
        self.assertIn("{0,4,1,14,4,0}", source)
        self.assertIn("{0,4,2,0,5,3}", source)


class ToolchainTests(unittest.TestCase):
    @patch("server.subprocess.run")
    def test_accepts_cedev_15(self, run):
        run.return_value = Mock(returncode=0, stdout="15.0\n")
        server._require_supported_toolchain()

    @patch("server.subprocess.run")
    def test_rejects_old_cedev_with_upgrade_message(self, run):
        run.return_value = Mock(returncode=0, stdout="13.0\n")
        with self.assertRaisesRegex(RuntimeError, "CEdev 15 or newer.*found CEdev 13.0"):
            server._require_supported_toolchain()


if __name__ == "__main__":
    unittest.main()
