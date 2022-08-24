# Local pc-emul makefile fragment for custom pc emulation targets.
# This file is included in BUILD_DIR/sw/pc/Makefile.

# DEFINES
SW_DEFINE+=FREQ=$(FREQ)
SW_DEFINE+=BAUD=$(BAUD)

SW_DEFINE+=PC

# HEADERS
HDR+=iob_soc_conf.h

iob_soc_conf.h:
	../python/sw_defines.py $@ $(SW_DEFINE)

# SOURCES
# exclude bootloader sources
SRC:=$(filter-out %boot.c,$(SRC))

TEST_LIST+=test1
test1:
	make run TEST_LOG="> test.log"


CLEAN_LIST+=clean1
clean1:
	@rm -rf iob_soc_conf.h
