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

HW_DEFINE := $(define) VCD


ifeq ($(CPU),PICORV32)
HW_DEFINE += $(define) PICORV32
endif


ifeq ($(CPU),DARKRV)
HW_DEFINE += $(define) DARKRV
endif

ifeq ($(USE_LA_IF),1)
HW_DEFINE += $(define) USE_LA_IF
endif

ifeq ($(USE_SRAM),1)
HW_DEFINE += $(define) USE_SRAM $(define) SRAM_ADDR_W=$(SRAM_ADDR_W)
endif

ifeq ($(USE_DDR),1)
HW_DEFINE += $(define) USE_DDR
endif

ifeq ($(RUN_DDR),1)
HW_DEFINE += $(define) RUN_DDR
endif

ifeq ($(USE_BOOT),1)
HW_DEFINE += $(define) USE_BOOT $(define) BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
endif


HW_DEFINE+=$(define) DDR_ADDR_W=$(DDR_ADDR_W)
HW_DEFINE+=$(define) N_SLAVES=$(N_SLAVES)
HW_DEFINE+=$(define) UART=$(UART)

#testbench defines
TB_DEFINE = $(define) PROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
TB_DEFINE += $(define) UART_BAUD_RATE=$(BAUD)
TB_DEFINE += $(define) UART_CLK_FREQ=$(FREQ)

#hw includes
HW_INCLUDE := $(incdir) . $(incdir) $(RTL_DIR)/include $(incdir) $(UART_DIR)/rtl/include \
$(incdir) $(CACHE_DIR)/rtl/include $(incdir) $(INTERCON_DIR)/rtl/include

ifeq ($(USE_SRAM),1)
RAM_VSRC:=$(SRC_DIR)/int_mem.v $(SRC_DIR)/ram.v $(MEM_DIR)/tdp_ram/iob_tdp_ram.v
endif

ifeq ($(USE_DDR),1)
DDR_VSRC:=$(SRC_DIR)/ext_mem.v $(CACHE_DIR)/rtl/src/iob-cache.v \
$(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/reg_file/iob_reg_file.v $(MEM_DIR)/fifo/afifo/afifo.v \
$(MEM_DIR)/sp_ram/iob_sp_mem.v
endif

ifeq ($(USE_BOOT),1)
ROM_VSRC$:=$(MEM_DIR)/sp_rom/sp_rom.v $(SRC_DIR)/boot_ctr.v
endif

#hardware sources
VSRC = \
$(RTL_DIR)/testbench/system_tb.v \
$(SRC_DIR)/system.v \
$(RISCV_DIR)/picorv32.v \
$(RISCV_DIR)/iob_picorv32.v \
$(UART_DIR)/rtl/src/iob-uart.v \
$(INTERCON_DIR)/rtl/src/merge.v \
$(INTERCON_DIR)/rtl/src/split.v \
$(ROM_VSRC) $(RAM_VSRC) $(DDR_VSRC)

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
