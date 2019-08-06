#hardware modules
RISCV = ../../submodules/iob-rv32
RTLDIR = ../../rtl/

INCLUDE_DIR=.$(RTLDIR)/include
SRC_DIR = $(RTLDIR)/src
IP_DIR = $(RTLDIR)/ip

TESTBENCH = $(RTLDIR)/testbench/top_system_test_Icarus_diff_clk.v

VSRC = $(SRC_DIR)/*.v $(SRC_DIR)/fifo/afifo.v $(SRC_DIR)/iob-uart/picosoc_uart.v $(SRC_DIR)/memory/*.v

#software
TEST := ./

TESTDIR = ../../software/tests/$(TEST)
BOOTDIR = ../../software/bootloader

all: firmware.hex boot.hex $(VSRC)
	$(VLOG) -I.$(RTLDIR)  -o top_system_test_Icarus_tb $(VSRC)
	./top_system_test_Icarus_tb +vcd

firmware.hex:
	make -C $(TESTDIR)
	cp firmware_0.hex firmware_0.dat
	cp firmware_1.hex firmware_1.dat
	cp firmware_2.hex firmware_2.dat
	cp firmware_3.hex firmware_3.dat

boot.hex:
	make -C $(BOOTDIR)
	cp $(BOOTDIR)/boot_0.hex ./boot_0.dat
	cp $(BOOTDIR)/boot_1.hex ./boot_1.dat
	cp $(BOOTDIR)/boot_2.hex ./boot_2.dat
	cp $(BOOTDIR)/boot_3.hex ./boot_3.dat

clean:
	@rm -f *#
	@rm -f *~
	@rm -f *.vcd
	@rm -f firmware_?.dat
	@rm -f boot_?.dat
	make -C $(BOOTDIR) clean
	make -C $(TESTDIR) clean

.PHONY: all firmware.hex boot.hex clean
