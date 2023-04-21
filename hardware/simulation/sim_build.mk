HEX+=iob_soc_boot.hex iob_soc_firmware.hex
include ../../software/sw_build.mk

VTOP:=iob_soc_tb

# SOURCES
ifeq ($(SIMULATOR),verilator)

# get header files (needed for iob_soc_tb.cpp)
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../software/src/iob_uart_swreg.h
	cp $< $@

# verilator top module
VTOP:=iob_soc_sim_wrapper

endif

CONSOLE_CMD=rm -f soc2cnsl cnsl2soc; ../../scripts/console.py -L

GRAB_TIMEOUT ?= 3600

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean SIMULATOR=$(SIMULATOR) && make -C ../../ sim-clean SIMULATOR=$(SIMULATOR) && make run SIMULATOR=$(SIMULATOR)
