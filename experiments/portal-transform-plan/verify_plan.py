"""Exhaustively compare the predecoded affine plan to the original geometry.

This is a host-only arithmetic oracle. It does not launch CEmu or touch any
root build output. It includes the small out-of-cell tangent range seen at
fixed-point boundaries, so the optimized renderer cannot silently substitute
the wrapped wall_u byte for the exact signed wall position.
"""

DIR_NORTH = 0
DIR_SOUTH = 1
DIR_WEST = 2
DIR_EAST = 3

FLAGS = (
    0x82, 0x00, 0x03, 0x81,
    0x00, 0x82, 0x81, 0x03,
    0x01, 0x83, 0x82, 0x00,
    0x83, 0x01, 0x00, 0x82,
)

KIND_PRIMARY = 1
KIND_SECONDARY = 2
KIND_BUILTIN = 3
FACE_LINKED = 0x04
FACE_INVALID = 0xFFFF

# source x/y/direction, target x/y/direction
BUILTINS = (
    (0, 13, DIR_SOUTH, 5, 13, DIR_NORTH),
    (5, 13, DIR_NORTH, 0, 13, DIR_SOUTH),
    (0, 4, DIR_SOUTH, 5, 9, DIR_NORTH),
    (5, 9, DIR_NORTH, 0, 4, DIR_SOUTH),
    (5, 0, DIR_EAST, 7, 0, DIR_EAST),
    (7, 0, DIR_EAST, 5, 0, DIR_EAST),
    (14, 5, DIR_NORTH, 14, 6, DIR_NORTH),
    (14, 6, DIR_NORTH, 14, 5, DIR_NORTH),
    (0, 2, DIR_SOUTH, 3, 0, DIR_EAST),
    (3, 0, DIR_EAST, 0, 2, DIR_SOUTH),
)


def portal_rotation(entry, exit_direction):
    if entry == exit_direction:
        return 2
    if entry == DIR_NORTH:
        return 0 if exit_direction == DIR_SOUTH else (
            1 if exit_direction == DIR_EAST else -1
        )
    if entry == DIR_EAST:
        return 0 if exit_direction == DIR_WEST else (
            1 if exit_direction == DIR_SOUTH else -1
        )
    if entry == DIR_SOUTH:
        return 0 if exit_direction == DIR_NORTH else (
            1 if exit_direction == DIR_WEST else -1
        )
    return 0 if exit_direction == DIR_EAST else (
        1 if exit_direction == DIR_NORTH else -1
    )


def rotate(x, y, quarters):
    if quarters == 1:
        return -y, x
    if quarters == -1:
        return y, -x
    if abs(quarters) == 2:
        return -x, -y
    return x, y


def geometric_reference(entry, exit_direction, tangent, exit_x, exit_y):
    # Exact local point after transform_ray's step across the entry wall.
    if entry == DIR_NORTH:
        local_x, local_y = 256, tangent
    elif entry == DIR_SOUTH:
        local_x, local_y = 0, tangent
    elif entry == DIR_WEST:
        local_x, local_y = tangent, 256
    else:
        local_x, local_y = tangent, 0

    rotation = portal_rotation(entry, exit_direction)
    local_x, local_y = rotate(local_x, local_y, rotation)
    if abs(rotation) == 2:
        local_x += 256
        local_y += 256
    elif rotation == 1:
        local_x += 256
    elif rotation == -1:
        local_y += 256

    x = exit_x * 256 + local_x
    y = exit_y * 256 + local_y
    if exit_direction == DIR_NORTH:
        x = exit_x * 256 - 1
    elif exit_direction == DIR_SOUTH:
        x = (exit_x + 1) * 256 + 1
    elif exit_direction == DIR_WEST:
        y = exit_y * 256 - 1
    else:
        y = (exit_y + 1) * 256 + 1
    return x, y, rotation


def build_plan(entry, exit_direction, exit_x, exit_y):
    flags = FLAGS[entry * 4 + exit_direction]
    if exit_direction in (DIR_NORTH, DIR_SOUTH):
        tangent_base = exit_y * 256
        normal = (
            exit_x * 256 - 1
            if exit_direction == DIR_NORTH
            else (exit_x + 1) * 256 + 1
        )
        tangent_to_x = 0
    else:
        tangent_base = exit_x * 256
        normal = (
            exit_y * 256 - 1
            if exit_direction == DIR_WEST
            else (exit_y + 1) * 256 + 1
        )
        tangent_to_x = 1
    return tangent_base, normal, flags, tangent_to_x


def planned(entry, exit_direction, tangent, exit_x, exit_y):
    tangent_base, normal, flags, tangent_to_x = build_plan(
        entry, exit_direction, exit_x, exit_y
    )
    oriented = 256 - tangent if flags & 0x80 else tangent
    if tangent_to_x:
        x, y = tangent_base + oriented, normal
    else:
        x, y = normal, tangent_base + oriented
    packed_rotation = flags & 3
    rotation = -1 if packed_rotation == 3 else packed_rotation
    return x, y, rotation


def face_index(portal):
    if portal is None:
        return FACE_INVALID
    x, y, direction = portal
    return (direction << 8) | (y << 4) | x


def face_value(kind, portal_id, linked):
    return kind | (FACE_LINKED if linked else 0) | (portal_id << 3)


class FaceTable:
    """Host model of the candidate's patch/restore state machine."""

    def __init__(self):
        self.base = [0] * 1024
        for portal_id, link in enumerate(BUILTINS):
            self.base[face_index(link[:3])] = face_value(
                KIND_BUILTIN, portal_id, True
            )
        self.table = self.base.copy()
        self.primary_face = FACE_INVALID
        self.secondary_face = FACE_INVALID

    def prepare(self, primary, secondary):
        primary_face = face_index(primary)
        secondary_face = face_index(secondary)
        if (primary_face, secondary_face) == (
            self.primary_face, self.secondary_face
        ):
            return
        if self.primary_face != FACE_INVALID:
            self.table[self.primary_face] = self.base[self.primary_face]
        if self.secondary_face != FACE_INVALID:
            self.table[self.secondary_face] = self.base[self.secondary_face]
        self.primary_face = primary_face
        self.secondary_face = secondary_face
        if secondary is not None:
            self.table[secondary_face] = face_value(
                KIND_SECONDARY, 11, primary is not None
            )
        if primary is not None:
            self.table[primary_face] = face_value(
                KIND_PRIMARY, 10, secondary is not None
            )


def check_face_table():
    faces = [
        (x, y, direction)
        for direction in range(4)
        for y in range(15)
        for x in range(15)
    ]
    model = FaceTable()
    assert sum(value != 0 for value in model.base) == len(BUILTINS)

    checks = 0
    for portal in faces:
        index = face_index(portal)
        model.prepare(portal, None)
        assert model.table[index] == face_value(KIND_PRIMARY, 10, False)
        model.prepare(None, None)
        assert model.table == model.base
        model.prepare(None, portal)
        assert model.table[index] == face_value(KIND_SECONDARY, 11, False)
        model.prepare(None, None)
        assert model.table == model.base
        checks += 4

    # Exercise every face in a moving linked sequence, including all ten
    # builtin overlaps; vacated faces must recover their exact base byte.
    previous = set()
    for index, primary in enumerate(faces):
        secondary = faces[-1 - index]
        model.prepare(primary, secondary)
        current = {face_index(primary), face_index(secondary)}
        for old in previous - current:
            assert model.table[old] == model.base[old]
            checks += 1
        expected_secondary = face_value(KIND_SECONDARY, 11, True)
        expected_primary = face_value(KIND_PRIMARY, 10, True)
        assert model.table[face_index(secondary)] == (
            expected_primary if primary == secondary else expected_secondary
        )
        assert model.table[face_index(primary)] == expected_primary
        checks += 2
        previous = current

    model.prepare(None, None)
    assert model.table == model.base
    return checks


def main():
    cases = 0
    coordinates = range(15)
    for entry in range(4):
        for exit_direction in range(4):
            for exit_x in coordinates:
                for exit_y in coordinates:
                    for tangent in range(-8, 265):
                        reference = geometric_reference(
                            entry, exit_direction, tangent, exit_x, exit_y
                        )
                        candidate = planned(
                            entry, exit_direction, tangent, exit_x, exit_y
                        )
                        if candidate != reference:
                            raise AssertionError(
                                (entry, exit_direction, exit_x, exit_y,
                                 tangent, reference, candidate)
                            )
                        cases += 1

    ray_values = (-256, -169, -1, 0, 1, 169, 256)
    ray_cases = 0
    for entry in range(4):
        for exit_direction in range(4):
            expected_rotation = portal_rotation(entry, exit_direction)
            packed = FLAGS[entry * 4 + exit_direction] & 3
            plan_rotation = -1 if packed == 3 else packed
            assert plan_rotation == expected_rotation
            for ray_x in ray_values:
                for ray_y in ray_values:
                    assert rotate(ray_x, ray_y, plan_rotation) == rotate(
                        ray_x, ray_y, expected_rotation
                    )
                    ray_cases += 1

    face_checks = check_face_table()

    print(
        f"predecoded portal plan exact: {cases:,} origins "
        "(all 16 direction pairs, all 15x15 exits, tangents -8..264), "
        f"{ray_cases:,} ray rotations; {face_checks:,} direction-major "
        "face-table patch/restore checks"
    )


if __name__ == "__main__":
    main()
