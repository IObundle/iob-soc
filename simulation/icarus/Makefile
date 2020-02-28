FIRM_DIR = ../../software/firmware
BOOT_DIR = ../../software/bootloader
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo
PYTHON_DIR := ../../software/python
BAUD := 1000000

#hw includes
HW_INCLUDE = -I$(RTL_DIR)/include -I$(UART_DIR)/rtl/include

#hw defines
HW_DEFINE = -DPROG_SIZE=$(shell wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1)
HW_DEFINE += -DBOOT_SIZE=$(shell wc -c   ../../software/bootloader/boot.bin | head -n1 | cut -d " " -f1)
HW_DEFINE += -DUART_BAUD_RATE=$(BAUD)

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv -DVCD

#hardware sources
VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

all: $(VSRC) firmware.hex boot.hex
	$(VLOG) $(HW_INCLUDE) $(HW_DEFINE) $(VSRC)
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
