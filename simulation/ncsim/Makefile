#simulation baud rate
BAUD := 10000000
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

HW_DEFINE=-define VCD
ifeq ($(CPU),PICORV32)
	HW_DEFINE+=-define PICORV32
endif
ifeq ($(CPU),DARKRV)
	HW_DEFINE+=-define ARKRV
endif
ifeq ($(USE_LA_IF),1)
	HW_DEFINE+=-define USE_LA_IF
endif
ifeq ($(USE_DDR),1)
	HW_DEFINE+=-define SHOW_DDR_IF
endif
HW_DEFINE+=-define MEM_TYPE=$(MEM_TYPE)
HW_DEFINE+=-define MEM_ADDR_W=$(MEM_ADDR_W)
HW_DEFINE+=-define BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
HW_DEFINE+=-define SRAM_ADDR_W=$(SRAM_ADDR_W)
HW_DEFINE+=-define N_SLAVES=$(N_SLAVES)
HW_DEFINE+=-define USE_DDR=$(USE_DDR)
HW_DEFINE+=-define USE_BOOT=$(USE_BOOT)
HW_DEFINE+=-define BOOT_CTR=$(BOOT_CTR)
HW_DEFINE+=-define UART=$(UART)


#hardware includes
HW_INCLUDE := -incdir . \
-incdir $(RTL_DIR)/include -incdir $(UART_DIR)/rtl/include \
-incdir $(CACHE_DIR)/rtl/include -incdir $(INTERCON_DIR)/rtl/include
#testbench defines
TB_DEFINE = -define PROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
TB_DEFINE += -define UART_BAUD_RATE=$(BAUD)
TB_DEFINE += -define UART_CLK_FREQ=$(FREQ)


#hardware sources
VSRC =  $(RISCV_DIR)/picorv32.v $(RISCV_DIR)/iob_picorv32.v\
$(UART_DIR)/rtl/src/iob-uart.v \
$(MEM_DIR)/afifo/afifo.v $(MEM_DIR)/sp_mem_be/iob_sp_mem_be.v\
$(MEM_DIR)/tdp_mem/iob_tdp_mem.v $(MEM_DIR)/reg_file/iob_reg_file.v\
$(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v\
$(CACHE_DIR)/rtl/src/iob-cache.v $(AXI_RAM_DIR)/rtl/axi_ram.v

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(HW_DEFINE) $(TB_DEFINE) $(HW_INCLUDE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(RTL_DIR)/testbench

#simulate
all: console.vh firmware boot $(VSRC)
	VSRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

#make firmware
firmware:
	@echo "Making firmware"
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/firmware.hex .
	cp $(FIRM_DIR)/firmware.bin .
	$(PYTHON_DIR)/hex_split.py firmware

#make boot loader
boot:
ifeq ($(USE_BOOT),1)
	@echo "Making bootloader"
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(BOOT_DIR)/boot.hex .
	$(PYTHON_DIR)/hex_split.py boot
endif

console.vh: ../../software/ld-sw/console.h
	sed "s/\#/\`/;s/0x/8\'h/" $^ | sed "/CONSOLE_H\|endif/d" > $@

clean:
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh xmsim.key *.log
	@rm -rf xcelium.d
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean

.PHONY: all boot firmware clean
