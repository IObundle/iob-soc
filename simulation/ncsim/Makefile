#
# Edit configuration here
#

#hardware configuration

BAUD = 10000000
#software configuration
TEST_DIR = software/firmware
BOOT_DIR = software/bootloader
PYTHON_DIR := ../../software/python
#
# Do not edit beyond this point
#
REMOTE_DIR := sandbox/iob-soc-e

#hardware
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart/rtl
FIFO_DIR = ../../submodules/fifo

#defines

DEFINE := -define VCD

DEFINE := $(DEFINE) -define UART_BAUD_RATE=$(BAUD)
GCC_DEFINE := $(GCC_DEFINE) -DBAUD=$(BAUD)

ifeq ($(USE_RAM),1)
DEFINE := $(DEFINE) -define USE_RAM
GCC_DEFINE := $(GCC_DEFINE) -DUSE_RAM
endif	

ifeq ($(USE_DDR),1)
DEFINE := $(DEFINE) -define USE_DDR
GCC_DEFINE := $(GCC_DEFINE) -DUSE_DDR
endif

#includes
INCLUDE = -incdir $(RTL_DIR)/include -incdir $(UART_DIR)/include -incdir ../../$(BOOT_DIR) -incdir ../../$(TEST_DIR)

VSRC =  $(RISCV_DIR)/picorv32.v $(UART_DIR)/src/iob-uart.v $(FIFO_DIR)/afifo.v $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v

#ncsim verilog simulator
CFLAGS = -errormax 15 -status -update -linedebug -sv $(DEFINE) $(INCLUDE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(RTL_DIR)/testbench


all: firmware.hex boot.hex $(VSRC)
	SRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" PROG_SIZE="-define PROG_SIZE=$(shell wc -c firmware.bin | head -n1 | cut -d " " -f1)" ./run_ncsim.sh

firmware.hex:
	scp -P 1415 ../../rtl/include/system.vh ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/rtl/include/system.vh
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(TEST_DIR) BAUD=$(BAUD) DEFINE="$(GCC_DEFINE)"'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware.hex .
	$(PYTHON_DIR)/hex_split.py firmware
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware.bin .

boot.hex: 
	scp -P 1415 ../../rtl/include/system.vh ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/rtl/include/system.vh
ifeq ($(shell grep USE_ $(RTL_DIR)/include/system.vh | grep -v \/\/),)
	cp firmware.hex boot.hex
else 
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) BAUD=$(BAUD) DEFINE="$(GCC_DEFINE)"'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(BOOT_DIR)/boot.hex .
endif
	$(PYTHON_DIR)/hex_split.py boot

clean:
	@rm -f *# *~ *.vcd *.dat *.hex firmware.bin
	@rm -f xmsim.key
	@rm -f *.log
	@rm -rf xcelium.d
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(TEST_DIR) clean --no-print-directory'
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) clean --no-print-directory'

.PHONY: all clean boot firmware
