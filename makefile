# ----------------------------
# CEdev project configuration
# ----------------------------
NAME = PORTAL3D
DESCRIPTION = "Portal raycaster"
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
	powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-memory.ps1
