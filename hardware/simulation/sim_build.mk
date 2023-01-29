VHDR+=iob_soc_boot.hex iob_soc_firmware.hex
include ../../software/sw_build.mk

CONSOLE_CMD=../../scripts/console.py -L


VTOP:=system_tb


# SOURCES
ifeq ($(SIMULATOR),verilator)

# get header files (needed for iob_soc_tb.cpp)
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../software/esrc/iob_uart_swreg.h
	cp $< $@

# verilator top module
VTOP:=system_top

endif

TEST_LIST+=test1
test1:
	make -C ../../ clean SIMULATOR=$(SIMULATOR) && make run SIMULATOR=$(SIMULATOR)
