# Isolated release-only build of the layer-major portal prototype.
NAME = P3DLAYER
DESCRIPTION = "Layer-major portal renderer prototype"
COMPRESSED = NO
ARCHIVED = YES
OUTPUT_MAP = YES

OPTIMIZE ?= -Oz
LAYER_MAJOR ?= 1
CFLAGS = -Wall -Wextra -Wshadow $(OPTIMIZE) -fstack-usage \
	-DRENDER_LAYER_MAJOR_PORTALS=$(LAYER_MAJOR)
CXXFLAGS = $(CFLAGS)
OBJDIR ?= obj

LTO = YES
PREFER_OS_CRT = YES
PREFER_OS_LIBC = YES

include $(shell cedev-config --makefile)
