HEX+=iob_soc_tester_boot.hex iob_soc_tester_firmware.hex
include ../../software/sw_build.mk

VTOP:=iob_soc_tester_tb

# SOURCES
ifeq ($(SIMULATOR),verilator)

# get header files (needed for iob_soc_tester_tb.cpp)
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../software/src/iob_uart_swreg.h
	cp $< $@

# verilator top module
VTOP:=iob_soc_tester_sim_wrapper

endif

CONSOLE_CMD=rm -f soc2cnsl cnsl2soc; ../../scripts/console.py -L

ifneq ($(wildcard uut_build.mk),)
include uut_build.mk
endif
