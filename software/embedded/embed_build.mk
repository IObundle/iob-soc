# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file is included in BUILD_DIR/sw/emb/Makefile.

## HEADERS
HDR+=$(wildcard ../*.h)

# Aditional flags to pass to the compiles
#Include software/ directory as it contains system.h file
INCLUDES+=-I..

# Aditional sources to pass to the compiles
#FW_SRC+=
