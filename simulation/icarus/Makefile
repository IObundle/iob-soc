#
# Edit configuration here
#

#hardware configuration
USE_RAM = 0
USE_DDR = 0
BAUD = 10000000

#software configuration
TEST_DIR = ../../software/hello_world
BOOT_DIR = ../../software/bootloader

#
# Do not edit beyond this point
#

#hardware paths
RTL_DIR = ../../rtl
RISCV_DIR = ../../submodules/iob-rv32
UART_DIR = ../../submodules/iob-uart
FIFO_DIR = ../../submodules/fifo


#defines

DEFINE := -DUART_BAUD_RATE=$(BAUD)
ifeq ($(USE_RAM),1)
DEFINE := $(DEFINE) -DUSE_RAM 
endif	

ifeq ($(USE_DDR),1)
DEFINE := $(DEFINE) -DUSE_DDR
endif

#includes
INCLUDE = -I$(RTL_DIR)/include -I$(UART_DIR)/rtl/include -I$(BOOT_DIR) -I$(TEST_DIR)

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv -DVCD


#hardware sources
VSRC = $(RTL_DIR)/testbench/system_tb.v  $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

all: firmware boot $(VSRC)
	$(VLOG) $(INCLUDE) $(DEFINE) $(VSRC) 
	./a.out

firmware:
	make -C $(TEST_DIR) DEFINE="$(DEFINE)"
	cp $(TEST_DIR)/firmware.hex .
	cp $(TEST_DIR)/firmware_0.hex ./firmware_0.dat
	cp $(TEST_DIR)/firmware_1.hex ./firmware_1.dat
	cp $(TEST_DIR)/firmware_2.hex ./firmware_2.dat
	cp $(TEST_DIR)/firmware_3.hex ./firmware_3.dat

boot: 
ifeq ($(USE_RAM)$(USE_DDR),00)
	cp $(TEST_DIR)/firmware_0.hex ./boot_0.dat
	cp $(TEST_DIR)/firmware_1.hex ./boot_1.dat
	cp $(TEST_DIR)/firmware_2.hex ./boot_2.dat
	cp $(TEST_DIR)/firmware_3.hex ./boot_3.dat
else 
	make -C $(BOOT_DIR) DEFINE="$(DEFINE)"
	cp $(BOOT_DIR)/boot_0.hex ./boot_0.dat
	cp $(BOOT_DIR)/boot_1.hex ./boot_1.dat
	cp $(BOOT_DIR)/boot_2.hex ./boot_2.dat
	cp $(BOOT_DIR)/boot_3.hex ./boot_3.dat
endif

clean:
	@rm -f *# *~ *.vcd *.dat *.hex ./a.out
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(TEST_DIR) clean --no-print-directory

.PHONY: all clean boot firmware
