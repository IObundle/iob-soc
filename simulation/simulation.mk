#simulation baud rate
BAUD := 30000000
FREQ := 100000000

#file paths
ROOT_DIR := ../..
FIRM_DIR := $(ROOT_DIR)/software/firmware
BOOT_DIR := $(ROOT_DIR)/software/bootloader
PYTHON_DIR := $(ROOT_DIR)/software/python
RTL_DIR := $(ROOT_DIR)/rtl
SRC_DIR := $(RTL_DIR)/src

SUBMODULES_DIR := $(ROOT_DIR)/submodules
RISCV_DIR := $(SUBMODULES_DIR)/picorv32
UART_DIR := $(SUBMODULES_DIR)/uart
MEM_DIR := $(SUBMODULES_DIR)/mem
CACHE_DIR := $(SUBMODULES_DIR)/cache
AXI_RAM_DIR := $(SUBMODULES_DIR)/axi-mem
INTERCON_DIR := $(SUBMODULES_DIR)/interconnect

#hw defines
include $(ROOT_DIR)/system.mk

#include hardware sources and definitions
include $(SRC_DIR)/src.mk

HW_DEFINE+=$(define) VCD

#testbench defines
TB_DEFINE = $(define) PROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
TB_DEFINE += $(define) UART_BAUD_RATE=$(BAUD)
TB_DEFINE += $(define) UART_CLK_FREQ=$(FREQ)

all: run

firmware:
	@echo "Making firmware"
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/firmware.hex .
	cp $(FIRM_DIR)/firmware.bin .
	$(PYTHON_DIR)/hex_split.py firmware

boot:
ifeq ($(USE_BOOT),1)
	@echo "Making bootloader"
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(BOOT_DIR)/boot.hex .
	cp $(BOOT_DIR)/boot.hex boot.dat
	$(PYTHON_DIR)/hex_split.py boot
endif

ifeq ($(SIM_DIR),simulation/icarus)
sim_clean:=icarus_clean
endif

ifeq ($(SIM_DIR),simulation/ncsim)
sim_clean:=ncsim_clean
endif

clean: $(sim_clean)
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(FIRM_DIR) clean --no-print-directory

.PHONY: all run boot firmware clean
