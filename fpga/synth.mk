# Baud rate and frequency
BAUD := 115200
FREQ := 100000000

# File paths
ROOT_DIR:=../../..
RTL_DIR:=$(ROOT_DIR)/rtl
SRC_DIR:=$(RTL_DIR)/src
FIRM_DIR:=$(ROOT_DIR)/software/firmware
BOOT_DIR:=$(ROOT_DIR)/software/bootloader
LD_SW_DIR:=$(ROOT_DIR)/software/ld-sw
PYTHON_DIR:=$(ROOT_DIR)/software/python

SUBMODULES_DIR:=$(ROOT_DIR)/submodules
PICORV_DIR := $(SUBMODULES_DIR)/picorv32
DARKRV_DIR := $(SUBMODULES_DIR)/darkrv
UART_DIR:=$(SUBMODULES_DIR)/uart
MEM_DIR:=$(SUBMODULES_DIR)/mem
CACHE_DIR:=$(SUBMODULES_DIR)/cache
AXI_RAM_DIR:=$(SUBMODULES_DIR)/axi-mem
INTERCON_DIR:=$(SUBMODULES_DIR)/interconnect

# hw defines
include $(ROOT_DIR)/system.mk

VSRC = \
$(DARKRV_DIR)/rtl/include/config.vh \
$(DARKRV_DIR)/rtl/include/decoder.vh \
$(UART_DIR)/rtl/include/iob-uart.vh \
$(INTERCON_DIR)/rtl/include/interconnect.vh \
verilog/top_system.v

# Include hardware sources and definitions
include $(SRC_DIR)/src.mk

all: run

firmware.dat: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

boot.dat: $(BOOT_DIR)/boot.hex
	cp $< ./boot.dat

$(BOOT_DIR)/boot.hex: FORCE
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

ld-hw:
	./ld-hw.sh

ld-sw:
	cp firmware.bin $(LD_SW_DIR)
	make -C $(LD_SW_DIR)

clean:
	@rm -rf .Xil/ *.hex *.dat *.bin *.map *.vh
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*# ./rtl/
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb
	@rm -rf table.txt tab_*/ *webtalk* *.jou *.log
	@rm -rf xelab.* xsim[._]* xvlog.* uart_loader
	@rm -rf *.ltx fsm_encoding.os
	make -C $(FIRM_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(LD_SW_DIR) clean --no-print-directory

.PHONY: all run ld-hw ld-sw clean FORCE
