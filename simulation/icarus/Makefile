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
RISCV_DIR := $(SUBMODULES_DIR)/iob-rv32
UART_DIR := $(SUBMODULES_DIR)/iob-uart
MEM_DIR := $(SUBMODULES_DIR)/iob-mem
CACHE_DIR := $(SUBMODULES_DIR)/iob-cache
AXI_RAM_DIR := $(SUBMODULES_DIR)/axi-mem
INTERCON_DIR := $(SUBMODULES_DIR)/interconnect

#hw defines
include $(ROOT_DIR)/system.mk

HW_DEFINE=-DVCD

ifeq ($(CPU),PICORV32)
HW_DEFINE += -DPICORV32
endif

ifeq ($(CPU),DARKRV)
HW_DEFINE += -DARKRV
endif

ifeq ($(USE_LA_IF),1)
HW_DEFINE += -DUSE_LA_IF
endif

ifeq ($(USE_SRAM),1)
HW_DEFINE += -DUSE_SRAM -DSRAM_ADDR_W=$(SRAM_ADDR_W)
RAM_VSRC:=$(SRC_DIR)/int_mem.v $(SRC_DIR)/ram.v $(MEM_DIR)/tdp_ram/iob_tdp_ram.v
endif

ifeq ($(USE_DDR),1)
HW_DEFINE += -DUSE_DDR
DDR_VSRC:=$(SRC_DIR)/ext_mem.v $(SRC_DIR)/ram.v $(CACHE_DIR)/rtl/src/iob-cache.v \
$(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/reg_file/iob_reg_file.v $(MEM_DIR)/fifo/afifo/afifo.v
endif

ifeq ($(RUN_DDR),1)
HW_DEFINE += -DRUN_DDR
endif

ifeq ($(USE_BOOT),1)
HW_DEFINE += -DUSE_BOOT -DBOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
ROM_VSRC$:=$(MEM_DIR)/sp_rom/sp_rom.v $(SRC_DIR)/boot_ctr.v
endif

HW_DEFINE+=-DMEM_ADDR_W=$(MEM_ADDR_W)
HW_DEFINE+=-DN_SLAVES=$(N_SLAVES)
HW_DEFINE+=-DUART=$(UART)

#testbench defines
TB_DEFINE = -DPROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
TB_DEFINE += -DUART_BAUD_RATE=$(BAUD)
TB_DEFINE += -DUART_CLK_FREQ=$(FREQ)

#hw includes
HW_INCLUDE := -I. -I$(RTL_DIR)/include -I$(UART_DIR)/rtl/include \
-I$(CACHE_DIR)/rtl/include -I$(INTERCON_DIR)/rtl/include

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv $(HW_DEFINE) $(TB_DEFINE) $(HW_INCLUDE)

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

all: $(VSRC) console.vh firmware boot
	$(VLOG) $(VSRC)
	./a.out

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

console.vh: $(ROOT_DIR)/software/ld-sw/console.h
	sed "s/\#/\`/;s/0x/8\'h/" $^ | sed "/CONSOLE_H\|endif/d" > $@

clean:
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh ./a.out
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(FIRM_DIR) clean --no-print-directory

.PHONY: all boot firmware clean

