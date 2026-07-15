# True-3D convex-cell and arbitrary-plane portal performance prototype.
# This is separate from both the original raycaster and the Doom-sector build.
NAME = TRUE3D07
DESCRIPTION = "True 3D portal engine prototype"
COMPRESSED = NO
ARCHIVED = YES
OUTPUT_MAP = YES

CFLAGS = -Wall -Wextra -Wshadow -Oz -fstack-usage
CXXFLAGS = -Wall -Wextra -Wshadow -Oz -fstack-usage
LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

include $(shell cedev-config --makefile)

.PHONY: budget
budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath bin/TRUE3D07.map -ObjectPath obj -MaximumBytes 153600 -ReservedStackBytes 4096
