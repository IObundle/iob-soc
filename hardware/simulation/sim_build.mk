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

CONSOLE_CMD=../../scripts/console.py -L

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean SIMULATOR=$(SIMULATOR) && make -C ../../ sim-clean SIMULATOR=$(SIMULATOR) && make run SIMULATOR=$(SIMULATOR)
