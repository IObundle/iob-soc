#simulation baud rate
BAUD := 30000000
FREQ := 100000000

#file paths
ROOT_DIR := ../..
FIRM_DIR := $(ROOT_DIR)/software/firmware
BOOT_DIR := $(ROOT_DIR)/software/bootloader
PYTHON_DIR := $(ROOT_DIR)/software/python
RTL_DIR := $(ROOT_DIR)/rtl

SUBMODULES_DIR := $(ROOT_DIR)/submodules
RISCV_DIR := $(SUBMODULES_DIR)/iob-rv32
UART_DIR := $(SUBMODULES_DIR)/iob-uart
MEM_DIR := $(SUBMODULES_DIR)/iob-mem
CACHE_DIR = $(SUBMODULES_DIR)/iob-cache
AXI_RAM_DIR = $(SUBMODULES_DIR)/axi-mem
#hw includes
HW_INCLUDE := -I. -I$(RTL_DIR)/include -I$(UART_DIR)/rtl/include -I$(CACHE_DIR)/rtl/header

#testbench defines
TB_DEFINE = -DPROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
TB_DEFINE += -DUART_BAUD_RATE=$(BAUD)
TB_DEFINE += -DUART_CLK_FREQ=$(FREQ)

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv -DVCD

#hardware sources
VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RTL_DIR)/src/memory/rom.v $(RTL_DIR)/src/memory/ram.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(CACHE_DIR)/rtl/src/gen_mem_reg.v $(CACHE_DIR)/rtl/src/iob-cache.v $(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/tdp_mem/iob_tdp_mem.v $(MEM_DIR)/afifo/afifo.v

all: $(VSRC) console.vh firmware boot
	$(VLOG) $(HW_INCLUDE) $(TB_DEFINE) $(VSRC)
	./a.out

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/firmware.hex .
	cp $(FIRM_DIR)/firmware.bin .
	$(PYTHON_DIR)/hex_split.py firmware

boot:
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(BOOT_DIR)/boot.hex .
	$(PYTHON_DIR)/hex_split.py boot
	cp boot.hex boot.dat

console.vh: $(ROOT_DIR)/software/ld-sw/console.h
	sed "s/\#/\`/;s/0x/8\'h/" $^ | sed "/CONSOLE_H\|endif/d" > $@

clean:
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh ./a.out
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(FIRM_DIR) clean --no-print-directory

.PHONY: all boot firmware clean
