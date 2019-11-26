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

#deriving hardware defines
ifeq ($(USE_RAM),1)
HW_CONF = -DUSE_RAM 
endif	

ifeq ($(USE_DDR),1)
HW_CONF = $(HW_CONF) -DUSE_DDR
endif

#hardware
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo

VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

#ncsim verilog simulator
CFLAGS = -errormax 15  -incdir $(RTL_DIR)/include -incdir $(UART_DIR)/include -status -update -linedebug -sv -define UART_BAUD_RATE=$(BAUD)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(TB_DIR)


all: firmware boot $(VSRC)
	SRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

firmware:
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(TEST_DIR) BAUD=$(BAUD)'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware.hex .
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_0.hex ./firmware_0.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_1.hex ./firmware_1.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_2.hex ./firmware_2.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_3.hex ./firmware_3.dat

boot: 
ifeq ($(USE_RAM)$(USE_DDR),00)
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) BAUD=$(BAUD)'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_0.hex ./boot_0.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_1.hex ./boot_1.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_2.hex ./boot_2.dat
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/$(TEST_DIR)/firmware_3.hex ./boot_3.dat
else 
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/$(BOOT_DIR) BAUD=$(BAUD)'
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
