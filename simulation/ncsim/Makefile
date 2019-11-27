#
# Edit configuration here
#

#hardware configuration
USE_RAM = 1
USE_DDR = 0
BAUD = 10000000
#software configuration
TEST_DIR = software/hello_world
BOOT_DIR = software/bootloader

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
GCC_DEFINE := -DVCD

DEFINE := $(DEFINE) -define UART_BAUD_RATE=$(BAUD)
GCC_DEFINE := $(GCC_DEFINE) -DUART_BAUD_RATE=$(BAUD)

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


all: firmware boot $(VSRC)
	SRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

firmware:
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(TEST_DIR) BAUD="$(BAUD)"'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware.hex .
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_0.hex ./firmware_0.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_1.hex ./firmware_1.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_2.hex ./firmware_2.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_3.hex ./firmware_3.dat

boot: 
ifeq ($(USE_RAM)$(USE_DDR),00)
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) DEFINE="$(GCC_DEFINE)"'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_0.hex ./boot_0.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_1.hex ./boot_1.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_2.hex ./boot_2.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_3.hex ./boot_3.dat
else 
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) DEFINE="$(GCC_DEFINE)"'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(BOOT_DIR)/boot_0.hex ./boot_0.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(BOOT_DIR)/boot_1.hex ./boot_1.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(BOOT_DIR)/boot_2.hex ./boot_2.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(BOOT_DIR)/boot_3.hex ./boot_3.dat
endif

clean:
	@rm -f *# *~ *.vcd *.dat *.hex
	@rm -f ncsim.key
	@rm -f *.log
	@rm -rf INCA_libs
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(TEST_DIR) clean'
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) clean'

.PHONY: all clean boot firmware
