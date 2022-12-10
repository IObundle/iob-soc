# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file is included in BUILD_DIR/sw/emb/Makefile.

## HEADERS
HDR+=../system.h

#Include software/ directory as it contains system.h file
INCLUDES+=-I..
# Aditional defines to pass to the compiles
DEFINES+=
# Aditional flags to pass to the compiles
CFLAGS+=
# Aditional sources to pass to the compiles
#FW_SRC+=
