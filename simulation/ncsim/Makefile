#simulation baud rate
BAUD := 10000000
FREQ := 100000000

#software paths
FIRM_DIR := ../../software/firmware
BOOT_DIR := ../../software/bootloader
PYTHON_DIR := ../../software/python

#hardware paths
RTL_DIR := ../../rtl
RISCV_DIR := ../../submodules/iob-rv32
UART_DIR := ../../submodules/iob-uart
FIFO_DIR := ../../submodules/iob-mem/afifo
MEM_DIR := ../../submodules/iob-mem/sp_mem_be
CACHE_DIR := ../../submodules/iob-cache
AXI_RAM := ../../submodules/axi-mem

#hardware includes
HW_INCLUDE := -incdir . -incdir $(RTL_DIR)/include -incdir $(UART_DIR)/rtl/include -incdir $(CACHE_DIR)/rtl/header

#hardware defines
HW_DEFINE = -define VCD
HW_DEFINE += -define PROG_SIZE=$(shell wc -c ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1)
HW_DEFINE += -define UART_BAUD_RATE=$(BAUD)
HW_DEFINE += -define UART_CLK_FREQ=$(FREQ)

#hardware sources
VSRC =  $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v $(MEM_DIR)/iob_sp_mem_be.v $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RTL_DIR)/src/memory/*.v $(CACHE_DIR)/rtl/src/gen_mem_reg.v $(CACHE_DIR)/rtl/src/iob-cache.v $(AXI_RAM)/rtl/axi_ram.v

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(HW_DEFINE) $(HW_INCLUDE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(RTL_DIR)/testbench

#simulate
all: console.vh firmware boot $(VSRC)
	VSRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

#make firmware
firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/firmware.hex firmware.dat
	cp $(FIRM_DIR)/firmware.bin .

#make boot loader
boot:
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(BOOT_DIR)/boot.hex boot.dat

console.vh: ../../software/ld-sw/console.h
	sed "s/\#/\`/;s/0x/8\'h/" $^ | sed "/CONSOLE_H\|endif/d" > $@

clean:
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh xmsim.key *.log
	@rm -rf xcelium.d
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean

.PHONY: all boot firmware clean
