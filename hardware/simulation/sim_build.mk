CONSOLE_CMD=../../scripts/console.py -L
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

#produce waveform dump
ifeq ($(VCD),1)
UFLAGS+=VCD
endif

VTOP:=system_tb

# Simulation programs
VHDR+=iob_soc_boot.hex iob_soc_firmware.hex

include ../../software/sw_build.mk

# SOURCES
ifeq ($(SIMULATOR),verilator)

# get header files (needed for iob_soc_tb.cpp)
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../software/esrc/iob_uart_swreg.h
	cp $< $@

# remove system_tb.v from source list
#VSRC:=$(filter-out system_tb.v, $(VSRC))
#
# verilator top module
VTOP:=system_top

endif

TEST_LOG=">> test.log"
TEST_LIST+=test1
test1:
	make clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"
TEST_LIST+=test2 
test2:
	make clean SIMULATOR=$(SIMULATOR)
	make run SIMULATOR=$(SIMULATOR) INIT_MEM=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
TEST_LIST+=test3
test3:
	make -C $(SOC_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(SOC_DIR) sim-run SIMULATOR=$(SIMULATOR) INIT_MEM=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
TEST_LIST+=test4
test4:
	make -C $(SOC_DIR) sim-clean SIMULATOR=$(SIMULATOR)
	make -C $(SOC_DIR) sim-run SIMULATOR=$(SIMULATOR) INIT_MEM=0 RUN_EXTMEM=1 TEST_LOG=">> test.log"
