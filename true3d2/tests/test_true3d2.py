from __future__ import annotations

import json
import shutil
import struct
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))

import t3d2_compile
import t3d2_format as fmt
import t3d2_reference as reference
import t3d1_to_t3d2
import decode_kernel
import decode_runtime
import t3d2_recovery as recovery


class FormatTests(unittest.TestCase):
    def test_appvar_round_trip_and_checksum(self) -> None:
        payload = bytes(range(251))
        wrapped = fmt.wrap_appvar("T3D2MAP", payload)
        name, unpacked = fmt.unwrap_appvar(wrapped, "T3D2MAP")
        self.assertEqual(name, "T3D2MAP")
        self.assertEqual(unpacked, payload)
        corrupted = bytearray(wrapped)
        corrupted[-3] ^= 0x40
        with self.assertRaisesRegex(ValueError, "checksum"):
            fmt.unwrap_appvar(bytes(corrupted))

    def test_layouts_are_locked(self) -> None:
        self.assertEqual(fmt.MAP_HEADER.size, 80)
        self.assertEqual(fmt.MESHLET.size, 34)
        self.assertEqual(fmt.COLLISION_NODE.size, 20)

    def test_recovery_journal_detects_each_corrupted_chunk(self) -> None:
        snapshot = bytes(index & 255 for index in range(262144))
        journal, chunks = recovery.make_backup(snapshot, generation=17)
        self.assertEqual(recovery.verify_chunks(journal, chunks), snapshot)
        self.assertEqual(journal.recovery_action, "extract-or-restore")
        for corrupt_index in range(recovery.CHUNK_COUNT):
            corrupted = list(chunks)
            changed = bytearray(corrupted[corrupt_index])
            changed[len(changed) // 2] ^= 0x80
            corrupted[corrupt_index] = bytes(changed)
            with self.assertRaisesRegex(ValueError, f"chunk {corrupt_index} CRC"):
                recovery.verify_chunks(journal, corrupted)

    def test_recovery_state_machine_never_restores_writing_journal(self) -> None:
        snapshot = b"safe" * 1024
        journal, _ = recovery.make_backup(
            snapshot, generation=4, state=recovery.STATE_WRITING)
        self.assertEqual(journal.recovery_action, "discard-incomplete")
        reparsed = recovery.BackupJournal.unpacked(journal.packed())
        self.assertEqual(reparsed, journal)


class CompilerTests(unittest.TestCase):
    def test_example_compiles_and_all_outputs_validate(self) -> None:
        source = ROOT / "examples" / "two_cell"
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary) / "scene"
            shutil.copytree(source, workspace, ignore=shutil.ignore_patterns("build"))
            output = Path(temporary) / "output"
            report = t3d2_compile.compile_scene(workspace / "scene.t3d2.json", output)
            self.assertEqual(report["cells"], 2)
            self.assertGreaterEqual(report["stored_triangles"], report["source_triangles"])
            _, map_payload = fmt.unwrap_appvar((output / "T3D2MAP.8xv").read_bytes(), "T3D2MAP")
            counts = fmt.validate_map(map_payload)
            self.assertEqual(counts["gateways"], 2)
            _, geometry = fmt.unwrap_appvar((output / "T3D2G00.8xv").read_bytes(), "T3D2G00")
            geometry_info = fmt.validate_geometry(geometry, 0)
            self.assertEqual(geometry_info["meshlets"], report["meshlets"])
            _, mip = fmt.unwrap_appvar((output / "T3D2MIP.8xv").read_bytes(), "T3D2MIP")
            self.assertEqual(len(mip), 21845)

    def test_certified_budget_overflow_is_rejected(self) -> None:
        source = ROOT / "examples" / "two_cell"
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary) / "scene"
            shutil.copytree(source, workspace, ignore=shutil.ignore_patterns("build"))
            manifest_path = workspace / "scene.t3d2.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest["certification"]["views"][0]["triangles"][0] = 97
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            with self.assertRaisesRegex(t3d2_compile.CompileError, "exceeds layer 0"):
                t3d2_compile.compile_scene(manifest_path, Path(temporary) / "output")

    def test_obj_mtl_material_discovery(self) -> None:
        source = ROOT / "examples" / "two_cell"
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary) / "scene"
            shutil.copytree(source, workspace, ignore=shutil.ignore_patterns("build"))
            manifest_path = workspace / "scene.t3d2.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            del manifest["materials"]
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            obj_path = workspace / "scene.obj"
            obj_path.write_text("mtllib scene.mtl\n" + obj_path.read_text(encoding="utf-8"),
                                encoding="utf-8")
            (workspace / "scene.mtl").write_text(
                "newmtl wall\nKd 0.8 0.8 0.8\n"
                "newmtl floor\nKd 0.6 0.6 0.6\n"
                "newmtl ceiling\nKd 0.9 0.9 0.9\n"
                "newmtl divider\nKd 0.7 0.7 0.7\n", encoding="utf-8")
            report = t3d2_compile.compile_scene(manifest_path, Path(temporary) / "output")
            self.assertGreater(report["meshlets"], 0)

    def test_map_crc_corruption_is_rejected(self) -> None:
        source = ROOT / "examples" / "two_cell"
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "output"
            t3d2_compile.compile_scene(source / "scene.t3d2.json", output)
            _, payload = fmt.unwrap_appvar((output / "T3D2MAP.8xv").read_bytes())
            corrupted = bytearray(payload)
            corrupted[-1] ^= 1
            with self.assertRaisesRegex(ValueError, "CRC"):
                fmt.validate_map(bytes(corrupted))

    def test_legacy_box_level_converts_and_compiles(self) -> None:
        header = t3d1_to_t3d2.HEADER.pack(
            b"T3D1", 1, 2, 0, 0,
            2 * 256, 2 * 256, 384,
            0, 3, 2 * 256, 4 * 256, 2 * 256,
            1, 2, 6 * 256, 0, 2 * 256,
        )
        first = t3d1_to_t3d2.ROOM.pack(
            0, 4 * 256, 0, 4 * 256, 0, 4 * 256, 2, 3, 4, 5, 6, 7)
        second = t3d1_to_t3d2.ROOM.pack(
            4 * 256, 8 * 256, 0, 4 * 256, 0, 4 * 256, 2, 3, 4, 5, 6, 7)
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            source = directory / "T3DLVL1.t3d"
            source.write_bytes(header + first + second)
            manifest = t3d1_to_t3d2.convert(source, directory / "converted")
            report = t3d2_compile.compile_scene(manifest, directory / "build")
            self.assertEqual(report["cells"], 2)
            self.assertEqual(report["gateways"], 2)
            self.assertGreater(report["stored_triangles"], 12)

    def test_kernel_report_decoder_checks_gates_and_crc(self) -> None:
        values = (
            b"T3DKRN1\0", 1, 7, decode_kernel.REPORT.size, 0x26081001, 1000,
            8, 4800, 96, 0, 80, 7, 3, 0x12345678, 0x87654321, 0,
        )
        raw = bytearray(decode_kernel.REPORT.pack(*values))
        struct.pack_into("<I", raw, len(raw) - 4, fmt.crc32(raw[:-4]))
        with tempfile.TemporaryDirectory() as temporary:
            report_path = Path(temporary) / "T3DKERN.8xv"
            report_path.write_bytes(fmt.wrap_appvar("T3DKERN", bytes(raw)))
            decoded = decode_kernel.decode(report_path)
            self.assertTrue(decoded["all_gates_pass"])
            self.assertEqual(decoded["raster"]["samples"], 4800)

    def test_report_decoders_find_crc_valid_data_in_ram_dump(self) -> None:
        kernel_values = (
            b"T3DKRN1\0", 1, 7, decode_kernel.REPORT.size, 0x26081001, 1000,
            8, 4800, 96, 0, 80, 7, 3, 0x12345678, 0x87654321, 0,
        )
        kernel = bytearray(decode_kernel.REPORT.pack(*kernel_values))
        struct.pack_into("<I", kernel, len(kernel) - 4, fmt.crc32(kernel[:-4]))
        self.assertEqual(decode_kernel.extract_report(b"prefix" + kernel + b"suffix")[7],
                         4800)

        samples = [32768, 65536, 98304]
        runtime_values = (
            b"T3DFPS1\0", 1, 3, decode_runtime.HEADER.size, 0x26081001,
            32768, 3, 98304, sum(samples), 30, 150000, 10000,
            0xAABBCCDD, 512, -256, 384, 2, 64, 0, len(samples), 512, 0,
        )
        runtime = bytearray(decode_runtime.HEADER.pack(*runtime_values))
        for sample in samples:
            runtime.extend(sample.to_bytes(3, "little"))
        struct.pack_into("<I", runtime, decode_runtime.CRC_OFFSET, fmt.crc32(runtime))
        values, decoded_samples = decode_runtime.extract_report(
            b"ram-prefix" + runtime + b"ram-suffix")
        self.assertEqual(decoded_samples, samples)
        self.assertEqual(values[16], 2)


class ReferenceTests(unittest.TestCase):
    def test_top_left_pair_fills_shared_quad_once(self) -> None:
        frame = reference.Frame(8, 8)
        texture = bytes((1,)) * 65536
        first = (
            reference.RasterVertex(1, 1, 100, 0, 0),
            reference.RasterVertex(5, 1, 100, 0, 0),
            reference.RasterVertex(5, 5, 100, 0, 0),
        )
        second = (
            reference.RasterVertex(1, 1, 100, 0, 0),
            reference.RasterVertex(5, 5, 100, 0, 0),
            reference.RasterVertex(1, 5, 100, 0, 0),
        )
        samples = reference.raster_triangle(frame, first, texture)
        samples += reference.raster_triangle(frame, second, texture)
        self.assertEqual(samples, 16)
        self.assertTrue(all(frame.color[y * 8 + x] == 1
                            for y in range(1, 5) for x in range(1, 5)))

    def test_inverse_depth_wins_independent_of_submission_order(self) -> None:
        texture = bytes((7,)) * 65536
        vertices = lambda depth: (
            reference.RasterVertex(1, 1, depth, 0, 0),
            reference.RasterVertex(6, 1, depth, 0, 0),
            reference.RasterVertex(1, 6, depth, 0, 0),
        )
        frame = reference.Frame(8, 8)
        reference.raster_triangle(frame, vertices(100), texture, 0)
        reference.raster_triangle(frame, vertices(200), texture, 1)
        self.assertEqual(frame.depth[2 * 8 + 2], 200)
        self.assertEqual(frame.color[2 * 8 + 2], 67)

    def test_portal_transform_round_trip(self) -> None:
        source = reference.Portal(reference.Vec3(0, 0, 0), reference.Vec3(1, 0, 0),
                                  reference.Vec3(0, 0, 1), reference.Vec3(0, 1, 0))
        destination = reference.Portal(reference.Vec3(10, 2, 3), reference.Vec3(0, 1, 0),
                                       reference.Vec3(0, 0, 1), reference.Vec3(-1, 0, 0))
        point = reference.Vec3(2, -3, 4)
        transformed = reference.transform_point_through_portal(point, source, destination)
        restored = reference.transform_point_through_portal(transformed, destination, source)
        self.assertAlmostEqual(restored.x, point.x)
        self.assertAlmostEqual(restored.y, point.y)
        self.assertAlmostEqual(restored.z, point.z)

    def test_reference_route_is_deterministic(self) -> None:
        first = reference.benchmark(40)
        second = reference.benchmark(40)
        self.assertEqual(first, second)
        self.assertNotEqual(first["route_crc32"], 0)


if __name__ == "__main__":
    unittest.main()
