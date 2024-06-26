# Add iob-soc software as a build dependency
HEX+=iob_soc_boot.hex iob_soc_firmware.hex

ROOT_DIR :=../..
include $(ROOT_DIR)/software/sw_build.mk

VTOP:=iob_soc_tb

# SOURCES
ifeq ($(SIMULATOR),verilator)

VSRC+=./src/iob_tasks.cpp

ifeq ($(USE_ETHERNET),1)
VSRC+=./src/iob_eth_swreg_emb_verilator.c ./src/iob_eth_driver_tb.cpp
endif

# get header files (needed for iob_soc_tb.cpp)
VHDR+=iob_uart_swreg.h
iob_uart_swreg.h: ../../software/src/iob_uart_swreg.h
	cp $< $@

# verilator top module
VTOP:=iob_soc_sim_wrapper

endif

CONSOLE_CMD ?=rm -f soc2cnsl cnsl2soc; ../../scripts/console.py -L

GRAB_TIMEOUT ?= 3600
