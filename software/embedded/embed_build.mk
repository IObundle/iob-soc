# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file is included in BUILD_DIR/sw/emb/Makefile.

# DEFINES
#SW_DEFINE+=FREQ=$(FREQ)
#SW_DEFINE+=BAUD=$(BAUD)

## HEADERS
HDR+=../system.h

#Include software/ directory as it contains system.h file
CFLAGS+=-I..

#iob_soc_conf.h:
#	../python/sw_defines.py $@ $(SW_DEFINE)
#
## SOURCES
## exclude print from bootloader sources
#BOOT_SRC:=$(filter-out printf.c, $(BOOT_SRC))
#
#CLEAN_LIST+=clean1
#clean1:
#	@rm -rf iob_soc_conf.h
