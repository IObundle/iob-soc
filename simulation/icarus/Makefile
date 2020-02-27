FIRM_DIR = ../../software/firmware
BOOT_DIR = ../../software/bootloader
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo
PYTHON_DIR := ../../software/python

#includes
INCLUDE = -I$(RTL_DIR)/include -I$(UART_DIR)/rtl/include

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv -DVCD

BAUD = 1000000

#hardware sources
VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

all: $(VSRC) firmware.hex boot.hex
	$(VLOG) $(INCLUDE) -DUART_BAUD_RATE=$(BAUD) -DPROG_SIZE=$(shell wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1) $(VSRC)
	./a.out

firmware.hex:
	make -C $(FIRM_DIR) BAUD=$(BAUD)
	cp $(FIRM_DIR)/firmware.hex .
	$(PYTHON_DIR)/hex_split.py firmware


boot.hex:
	make -C $(BOOT_DIR) BAUD=$(BAUD)
	cp $(BOOT_DIR)/boot.hex .
	$(PYTHON_DIR)/hex_split.py boot
	cp boot.hex boot.dat

clean:
	@rm -f *# *~ *.vcd *.dat *.hex ./a.out
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(FIRM_DIR) clean --no-print-directory

.PHONY: all clean boot firmware
