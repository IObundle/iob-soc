# Local pc-emul makefile fragment for custom pc emulation targets.
# This file is included in BUILD_DIR/sw/pc/Makefile.

# Include directory with system.h
INCLUDE+=-I.. -I../psrc

# SOURCES
# exclude bootloader sources
SRC:=$(filter-out %boot.c,$(SRC))

TEST_LIST+=test1
test1:
	make run TEST_LOG="> test.log"


CLEAN_LIST+=clean1
clean1:
	@rm -rf iob_soc_conf.h
