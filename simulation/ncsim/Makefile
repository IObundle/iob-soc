#simulation baud rate
BAUD := 10000000
FREQ := 100000000

#software paths
FIRM_DIR = ../../software/firmware
BOOT_DIR = ../../software/bootloader
PYTHON_DIR := ../../software/python

#hardware paths
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo
CACHE_DIR = ../../submodules/iob-cache
AXI_RAM = ../../submodules/axi-mem

#hardware includes
HW_INCLUDE = -incdir . -incdir $(RTL_DIR)/include -incdir $(UART_DIR)/rtl/include -incdir $(CACHE_DIR)/rtl/header

#hardware defines
HW_DEFINE = -define VCD
HW_DEFINE += -define PROG_SIZE=$(shell wc -c ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1)
HW_DEFINE += -define UART_BAUD_RATE=$(BAUD)
HW_DEFINE += -define UART_CLK_FREQ=$(FREQ)

#hardware sources
VSRC =  $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RTL_DIR)/src/memory/behav/*.v $(CACHE_DIR)/rtl/src/gen_mem_reg.v $(CACHE_DIR)/rtl/src/iob-cache.v $(AXI_RAM)/rtl/axi_ram.v

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(HW_DEFINE) $(HW_INCLUDE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(RTL_DIR)/testbench

#simulate
all: console.vh firmware.hex boot.hex $(VSRC)
	VSRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

#make firmware
firmware.hex:
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/progmem.hex .
	cp $(FIRM_DIR)/firmware.hex .
	$(PYTHON_DIR)/hex_split.py firmware

#make boot loader
boot.hex:
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(BOOT_DIR)/boot.hex .
	$(PYTHON_DIR)/hex_split.py boot
	cp boot.hex boot.dat

console.vh: ../../software/ld-sw/console.h
	sed "s/\#/\`/;s/0x/4\'h/" $^ | sed "/CONSOLE_H\|endif/d" > $@

clean:
	@rm -f *# *~ *.vcd *.dat *.hex firmware.bin *.vh xmsim.key *.log
	@rm -rf xcelium.d
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean

.PHONY: all clean
