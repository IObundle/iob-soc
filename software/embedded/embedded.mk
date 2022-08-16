# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file is included in BUILD_DIR/sw/emb/Makefile.

# DEFINES
DEFINE+=$(defmacro)FREQ=$(FREQ)
DEFINE+=$(defmacro)BAUD=$(BAUD)

# HEADERS
HDR+=defines.h

defines.h:
	../python/sw_defines.py $@ $(DEFINE)

# SOURCES
# exclude print from bootloader sources
BOOT_SRC:=$(filter-out printf.c, $(BOOT_SRC))

CLEAN_LIST+=clean1
clean1:
	@rm -rf defines.h
