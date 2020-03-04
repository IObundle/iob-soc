#simulation baud rate
BAUD := 1000000
FREQ := 100000000

#file paths
FIRM_DIR = ../../software/firmware
BOOT_DIR = ../../software/bootloader
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo
PYTHON_DIR := ../../software/python
CACHE_DIR = ../../submodules/iob-cache
AXI_RAM = ../../submodules/axi-mem

#hw includes
HW_INCLUDE = -I$(RTL_DIR)/include -I$(UART_DIR)/rtl/include -I$(CACHE_DIR)/rtl/header

#testbench defines
TB_DEFINE = -DPROG_SIZE=$(shell wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1)
TB_DEFINE += -DUART_BAUD_RATE=$(BAUD)
TB_DEFINE += -DUART_CLK_FREQ=$(FREQ)

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv -DVCD

#hardware sources
VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RTL_DIR)/src/memory/behav/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v $(CACHE_DIR)/rtl/src/gen_mem_reg.v $(CACHE_DIR)/rtl/src/iob-cache.v $(AXI_RAM)/rtl/axi_ram.v

all: $(VSRC) firmware.hex boot.hex
	$(VLOG) $(HW_INCLUDE) $(TB_DEFINE) $(VSRC)
	./a.out

firmware.hex:
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/progmem.hex .
	cp $(FIRM_DIR)/firmware.hex .
	$(PYTHON_DIR)/hex_split.py firmware

boot.hex:
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(BOOT_DIR)/boot.hex .
	$(PYTHON_DIR)/hex_split.py boot
	cp boot.hex boot.dat

clean:
	@rm -f *# *~ *.vcd *.dat *.hex ./a.out
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(FIRM_DIR) clean --no-print-directory

.PHONY: all clean
