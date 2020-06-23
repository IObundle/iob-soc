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
RISCV_DIR:=$(SUBMODULES_DIR)/picorv32
UART_DIR:=$(SUBMODULES_DIR)/uart
MEM_DIR:=$(SUBMODULES_DIR)/mem
CACHE_DIR:=$(SUBMODULES_DIR)/cache
AXI_RAM_DIR:=$(SUBMODULES_DIR)/axi-mem
INTERCON_DIR:=$(SUBMODULES_DIR)/interconnect

# hw defines
include $(ROOT_DIR)/system.mk

VSRC = \
$(UART_DIR)/rtl/include/iob-uart.vh \
$(INTERCON_DIR)/rtl/include/interconnect.vh \
verilog/top_system.v

# Include hardware sources and definitions
include $(SRC_DIR)/src.mk

all: run

firmware.bin: $(FIRM_DIR)/firmware.hex
	cp $(FIRM_DIR)/firmware.bin .

firmware.dat: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

boot.dat: $(BOOT_DIR)/boot.hex
	cp $< ./boot.dat

$(BOOT_DIR)/boot.hex: FORCE
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

ld-sw:
	cp firmware.bin $(LD_SW_DIR)
	make -C $(LD_SW_DIR)

clean: clean_xilinx clean_altera
	@rm -f *.hex *.dat *.bin
	make -C $(FIRM_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(LD_SW_DIR) clean --no-print-directory

.PHONY: all run ld-hw ld-sw clean clean_xilinx clean_altera FORCE
