#simulation baud rate
BAUD = 10000000

#software paths
FIRM_DIR = ../../software/firmware
BOOT_DIR = ../../software/bootloader
PYTHON_DIR := ../../software/python

#hardware paths
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart/rtl
FIFO_DIR = ../../submodules/fifo

#hardware includes
HW_INCLUDE = -incdir $(RTL_DIR)/include -incdir $(UART_DIR)/include

#hardware defines
HW_DEFINE := -define VCD
HW_DEFINE += -define PROG_SIZE=$(shell wc -c firmware.bin | head -n1 | cut -d " " -f1)
HW_DEFINE += -define UART_BAUD_RATE=$(BAUD)

#hardware sources
VSRC =  $(RISCV_DIR)/picorv32.v $(UART_DIR)/src/iob-uart.v $(FIFO_DIR)/afifo.v $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(HW_DEFINE) $(HW_INCLUDE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(RTL_DIR)/testbench

#simulate
all: firmware.hex boot.hex $(VSRC)
	VSRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

#make firmware
firmware.hex:
	make -C $(FIRM_DIR) BAUD=$(BAUD)
	cp $(FIRM_DIR)/firmware.hex .
	$(PYTHON_DIR)/hex_split.py firmware
	cp $(FIRM_DIR)/firmware.bin .

#make boot loader
boot.hex: 
ifeq ($(shell grep USE_ $(RTL_DIR)/include/system.vh | grep -v \/\/),)
	cp firmware.hex boot.hex
else 
	make -C $(BOOT_DIR) BAUD=$(BAUD)
	cp $(BOOT_DIR)/boot.hex .
endif
	$(PYTHON_DIR)/hex_split.py boot

clean:
	@rm -f *# *~ *.vcd *.dat *.hex firmware.bin xmsim.key *.log
	@rm -rf xcelium.d
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean

.PHONY: all clean
