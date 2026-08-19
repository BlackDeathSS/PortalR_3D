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

# `make ray` produces a portal-free DDA raycaster experiment alongside the
# existing T3D3 build. It keeps TI Lung's helm/map/save code intact.
RAYCASTER ?= 0
ifeq ($(RAYCASTER),1)
NAME = TILRAY
DESCRIPTION = "TI Lung raycaster prototype"
OBJDIR = obj/ray
BUDGET_MAP = bin/TILRAY.map
CFLAGS += -DTI_LUNG_RAYCASTER=1
endif

# The normal game is 2D; 3D is used only for one-shot photos and Trace debug.
# A 64-wide untextured pass keeps enough calculator RAM available to launch.
CFLAGS += -DT3D3_RENDER_WIDTH=64 -DT3D3_STATIC_BOX_LIMIT=76 -DT3D3_MATERIAL_TEXTURE=0
# These tables affect only one-shot 3D photos/Trace debug.  Smaller tables
# trade distant precision for the RAM necessary to launch on a real CE.
CFLAGS += -DT3D3_NEAR_PROJECTION_DEPTH_COUNT=1024u -DT3D3_FAR_PROJECTION_TABLE_SIZE=512u -DT3D3_EDGE_RECIPROCAL_TABLE_SIZE=512u

LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

include $(shell cedev-config --makefile)

.PHONY: budget ray
ray:
	$(MAKE) RAYCASTER=1 build

budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath $(BUDGET_MAP) -ObjectPath $(OBJDIR) -MaximumBytes 153600 -ReservedStackBytes 4096
