# True-3D convex-cell and arbitrary-plane portal performance prototype.
# This is separate from both the original raycaster and the Doom-sector build.
NAME = TRUE3D06
DESCRIPTION = "True 3D portal engine prototype"
COMPRESSED = NO
ARCHIVED = YES
OUTPUT_MAP = YES

OPTIMIZE ?= -Oz
CFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
CXXFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage
OBJDIR = obj/release
BUDGET_MAP = bin/TRUE3D06.map

ifeq ($(LIVE_BENCHMARK),1)
NAME = T3DLIVE
DESCRIPTION = "True3D live gameplay benchmark"
CFLAGS += -DTRUE3D_RENDER_BENCHMARK=1 -DTRUE3D_LIVE_BENCHMARK=1
OBJDIR = obj/live-benchmark
BUDGET_MAP = bin/T3DLIVE.map
ifeq ($(LIVE_BENCHMARK_AUTOTEST),1)
NAME = T3DLVAT
DESCRIPTION = "True3D live benchmark autotest"
CFLAGS += -DTRUE3D_LIVE_AUTOTEST_HOLD=1
OBJDIR = obj/live-benchmark-autotest
BUDGET_MAP = bin/T3DLVAT.map
endif
else ifeq ($(LIVE_BENCHMARK_AUTOTEST),1)
$(error LIVE_BENCHMARK_AUTOTEST requires LIVE_BENCHMARK=1)
endif
LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

include $(shell cedev-config --makefile)

.PHONY: budget
budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath $(BUDGET_MAP) -ObjectPath $(OBJDIR) -MaximumBytes 153600 -ReservedStackBytes 4096
