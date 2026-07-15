# CEdev sector-engine prototype. The proven Portal V8S target remains at the
# repository root and is intentionally not modified by this build.
NAME = DOOMCE10
DESCRIPTION = "Doom-style sector prototype"
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
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath bin/DOOMCE10.map -ObjectPath obj -MaximumBytes 153600 -ReservedStackBytes 4096
