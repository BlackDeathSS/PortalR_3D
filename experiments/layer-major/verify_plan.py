"""Exhaustively compare the predecoded affine plan to the original geometry.

This is a host-only arithmetic oracle. It does not launch CEmu or touch any
root build output.
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


def planned(entry, exit_direction, tangent, exit_x, exit_y):
    flags = FLAGS[entry * 4 + exit_direction]
    oriented = 256 - tangent if flags & 0x80 else tangent
    if exit_direction in (DIR_NORTH, DIR_SOUTH):
        tangent_base = exit_y * 256
        normal = (
            exit_x * 256 - 1
            if exit_direction == DIR_NORTH
            else (exit_x + 1) * 256 + 1
        )
        x, y = normal, tangent_base + oriented
    else:
        tangent_base = exit_x * 256
        normal = (
            exit_y * 256 - 1
            if exit_direction == DIR_WEST
            else (exit_y + 1) * 256 + 1
        )
        x, y = tangent_base + oriented, normal
    packed_rotation = flags & 3
    rotation = -1 if packed_rotation == 3 else packed_rotation
    return x, y, rotation


def main():
    cases = 0
    coordinates = (0, 1, 7, 14)
    for entry in range(4):
        for exit_direction in range(4):
            for exit_x in coordinates:
                for exit_y in coordinates:
                    for tangent in range(256):
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

    print(
        f"predecoded portal plan exact: {cases:,} origins, "
        f"{ray_cases:,} ray rotations"
    )


if __name__ == "__main__":
    main()
