# T3D3 starts from the proven True3D06 camera, collision, and portal engine.
# New rendering and gameplay systems are introduced behind compatibility tests.
NAME = T3D3DEV
DESCRIPTION = "T3D3 True3D-derived portal engine"
COMPRESSED = NO
ARCHIVED = YES
OUTPUT_MAP = YES

OPTIMIZE ?= -Os
CFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
CXXFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
OBJDIR = obj/release
BUDGET_MAP = bin/T3D3DEV.map
BODY_BENCHMARK ?= 0
PORTAL_PUSH_TEST ?= 0
PLAYER_FLING_TEST ?= 0
RENDER_WIDTH ?= 80

CFLAGS += -DT3D3_RENDER_WIDTH=$(RENDER_WIDTH)

ifneq ($(BODY_BENCHMARK),0)
CFLAGS += -DT3D3_BODY_BENCHMARK=$(BODY_BENCHMARK)
endif

ifneq ($(PORTAL_PUSH_TEST),0)
CFLAGS += -DT3D3_PORTAL_PUSH_TEST=$(PORTAL_PUSH_TEST)
endif

ifneq ($(PLAYER_FLING_TEST),0)
CFLAGS += -DT3D3_PLAYER_FLING_TEST=$(PLAYER_FLING_TEST)
endif

ifeq ($(LIVE_BENCHMARK),1)
NAME = T3D3LIVE
DESCRIPTION = "T3D3 deterministic live benchmark"
CFLAGS += -DTRUE3D_RENDER_BENCHMARK=1 -DTRUE3D_LIVE_BENCHMARK=1
ifeq ($(LIVE_BENCHMARK_COUNTERS),1)
CFLAGS += -DTRUE3D_BENCHMARK_COUNTERS=1
endif
OBJDIR = obj/live-benchmark
BUDGET_MAP = bin/T3D3LIVE.map
ifeq ($(LIVE_BENCHMARK_AUTOTEST),1)
NAME = T3D3LVAT
DESCRIPTION = "T3D3 live benchmark autotest"
CFLAGS += -DTRUE3D_LIVE_AUTOTEST_HOLD=1
OBJDIR = obj/live-benchmark-autotest
BUDGET_MAP = bin/T3D3LVAT.map
endif
else ifeq ($(LIVE_BENCHMARK_AUTOTEST),1)
$(error LIVE_BENCHMARK_AUTOTEST requires LIVE_BENCHMARK=1)
endif

LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

include $(shell cedev-config --makefile)

.PHONY: budget reference64
budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath $(BUDGET_MAP) -ObjectPath $(OBJDIR) -MaximumBytes 153600 -ReservedStackBytes 4096

reference64:
	$(MAKE) -B NAME=T3D3R60 RENDER_WIDTH=64
