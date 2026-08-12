# True3D2 hybrid mesh/portal engine development target.
NAME = T3D2DEV
DESCRIPTION = "True3D2 hybrid engine development build"
COMPRESSED = NO
ARCHIVED = YES
OUTPUT_MAP = YES

OPTIMIZE ?= -Os
CFLAGS = -Wall -Wextra -Wshadow -Wconversion $(OPTIMIZE) -fstack-usage
CXXFLAGS = $(CFLAGS)

# Keep the recursive renderer size-bounded. Hot scan conversion and span work
# is supplied by assembly modules rather than whole-file loop expansion.
LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

# The takeover remains disabled until the recovery milestone is hardware-tested.
ifeq ($(FULL_TAKEOVER),1)
CFLAGS += -DT3D2_ENABLE_FULL_TAKEOVER=1
endif

ifeq ($(KERNEL_BENCHMARK),1)
NAME = T3D2KERN
CFLAGS += -DT3D2_KERNEL_BENCHMARK=1
endif

ifeq ($(KERNEL_AUTOTEST),1)
CFLAGS += -DT3D2_KERNEL_AUTOTEST=1
endif

ifeq ($(RUNTIME_AUTOTEST),1)
NAME = T3D2AUTO
CFLAGS += -DT3D2_RUNTIME_AUTOTEST=1
endif

include $(shell cedev-config --makefile)

.PHONY: budget
budget: build
	powershell -NoProfile -ExecutionPolicy Bypass -File ../tools/check-memory.ps1 -MapPath bin/$(NAME).map -ObjectPath obj -MaximumBytes 153600 -ReservedStackBytes 6144
