# TI_LUNG reuses the proven T3D3 renderer and owns a separate submarine game.
NAME = TILUNG
DESCRIPTION = "TI Lung submarine horror prototype"
COMPRESSED = YES
ARCHIVED = YES
OUTPUT_MAP = YES

OPTIMIZE ?= -Os
CFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
CXXFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
OBJDIR = obj/release
BUDGET_MAP = bin/TILUNG.map

CFLAGS += -DT3D3_RENDER_WIDTH=80 -DT3D3_STATIC_BOX_LIMIT=20 -DT3D3_MATERIAL_TEXTURE=1

LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

include $(shell cedev-config --makefile)

.PHONY: budget
budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath $(BUDGET_MAP) -ObjectPath $(OBJDIR) -MaximumBytes 153600 -ReservedStackBytes 4096
