# ----------------------------
# CEdev project configuration
# ----------------------------
NAME = PORTAL3D
DESCRIPTION = "Portal raycaster"
COMPRESSED = NO
ARCHIVED = YES
OUTPUT_MAP = YES

OPTIMIZE ?= -Oz
CFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
CXXFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
ROW_MAJOR_WALLS ?= 0
CFLAGS += -DRENDER_ROW_MAJOR_WALLS=$(ROW_MAJOR_WALLS)
CXXFLAGS += -DRENDER_ROW_MAJOR_WALLS=$(ROW_MAJOR_WALLS)
OBJDIR = obj/release
BUDGET_MAP = bin/PORTAL3D.map

ifeq ($(BENCHMARK),1)
ifneq ($(filter 1,$(PROFILE) $(RAY_DIAGNOSTIC)),)
$(error BENCHMARK cannot be combined with PROFILE or RAY_DIAGNOSTIC)
endif
else ifeq ($(BENCHMARK_AUTOTEST),1)
$(error BENCHMARK_AUTOTEST requires BENCHMARK=1)
endif

ifeq ($(LIVE_BENCHMARK),1)
ifneq ($(filter 1,$(BENCHMARK) $(PROFILE) $(RAY_DIAGNOSTIC)),)
$(error LIVE_BENCHMARK cannot be combined with BENCHMARK, PROFILE, or RAY_DIAGNOSTIC)
endif
else ifeq ($(LIVE_BENCHMARK_AUTOTEST),1)
$(error LIVE_BENCHMARK_AUTOTEST requires LIVE_BENCHMARK=1)
endif

ifeq ($(PROFILE),1)
NAME = P3DPROF
DESCRIPTION = "Portal raycaster profiler"
CFLAGS += -DRENDER_PROFILE=1
OBJDIR = obj/profile
BUDGET_MAP = bin/P3DPROF.map
endif
ifeq ($(RAY_DIAGNOSTIC),1)
NAME = P3DRAY
DESCRIPTION = "Portal ray diagnostic"
CFLAGS += -DRENDER_PROFILE=1 -DRENDER_RAY_DIAGNOSTIC=1
OBJDIR = obj/ray-diagnostic
BUDGET_MAP = bin/P3DRAY.map
endif

ifeq ($(BENCHMARK),1)
NAME = P3DBNCH
DESCRIPTION = "Portal raycaster benchmark"
CFLAGS += -DRENDER_PROFILE=1 -DRENDER_BENCHMARK=1
OBJDIR = obj/benchmark
BUDGET_MAP = bin/P3DBNCH.map
ifeq ($(BENCHMARK_AUTOTEST),1)
NAME = P3DBAT
DESCRIPTION = "Portal benchmark autotest"
CFLAGS += -DBENCHMARK_AUTOTEST_HOLD=1
OBJDIR = obj/benchmark-autotest
BUDGET_MAP = bin/P3DBAT.map
endif
endif

ifeq ($(LIVE_BENCHMARK),1)
NAME = P3DLIVE
DESCRIPTION = "Portal live gameplay benchmark"
CFLAGS += -DRENDER_PROFILE=1 -DRENDER_BENCHMARK=1 -DRENDER_LIVE_BENCHMARK=1
OBJDIR = obj/live-benchmark
BUDGET_MAP = bin/P3DLIVE.map
ifeq ($(LIVE_BENCHMARK_AUTOTEST),1)
NAME = P3DLVAT
DESCRIPTION = "Portal live benchmark autotest"
CFLAGS += -DLIVE_BENCHMARK_AUTOTEST_HOLD=1
OBJDIR = obj/live-benchmark-autotest
BUDGET_MAP = bin/P3DLVAT.map
endif
endif

LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

# Optional per-translation-unit overrides make optimizer bisects reproducible.
# They are intentionally empty in release builds; the last -O flag wins.
BENCHMARK_OPTIMIZE ?=
GAME_OPTIMIZE ?=
LIVE_BENCHMARK_OPTIMIZE ?=
MAIN_OPTIMIZE ?=

ifneq ($(strip $(BENCHMARK_OPTIMIZE)),)
$(OBJDIR)/src/benchmark.c.s $(OBJDIR)/src/benchmark.c.bc: CFLAGS += $(BENCHMARK_OPTIMIZE)
endif
ifneq ($(strip $(GAME_OPTIMIZE)),)
$(OBJDIR)/src/game.c.s $(OBJDIR)/src/game.c.bc: CFLAGS += $(GAME_OPTIMIZE)
endif
ifneq ($(strip $(LIVE_BENCHMARK_OPTIMIZE)),)
$(OBJDIR)/src/live_benchmark.c.s $(OBJDIR)/src/live_benchmark.c.bc: CFLAGS += $(LIVE_BENCHMARK_OPTIMIZE)
endif
ifneq ($(strip $(MAIN_OPTIMIZE)),)
$(OBJDIR)/src/main.c.s $(OBJDIR)/src/main.c.bc: CFLAGS += $(MAIN_OPTIMIZE)
endif

include $(shell cedev-config --makefile)

.PHONY: budget
budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-memory.ps1 -MapPath $(BUDGET_MAP) -ObjectPath $(OBJDIR)
