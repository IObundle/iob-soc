# DEFINES
DEFINE+=FREQ=$(FREQ)
DEFINE+=BAUD=$(BAUD)

# HEADERS
HDR+=defines.h

# SOURCES
# exclude bootloader sources
SRC:=$(filter-out %boot.c,$(SRC))

TEST_LIST+=test1
test1:
	make run TEST_LOG="> test.log"

defines.h:
	../python/sw_defines.py $@ $(DEFINE)

CLEAN_LIST+=clean1
clean1:
	@rm -rf defines.h
