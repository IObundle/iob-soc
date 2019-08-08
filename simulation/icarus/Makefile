VLOG = iverilog

#hardware modules
RISCV = ../../submodules/iob-rv32
UARTDIR = ../../submodules/iob-uart
UARTSRC = $(UARTDIR)/rtl/src
INC_UART = $(UARTDIR)/rtl/include

RTLDIR = ../../rtl/
INCLUDE_DIR= $(RTLDIR)/include
SRC_DIR = $(RTLDIR)/src
IP_DIR = $(RTLDIR)/ip

TESTBENCH = $(RTLDIR)/testbench/top_system_test_Icarus_tb.v

VSRC = $(SRC_DIR)/*.v $(SRC_DIR)/fifo/afifo.v $(SRC_DIR)/memory/*.v $(RISCV)/picorv32.v $(RISCV)/rtl/xalt_1p_mem.v $(UARTSRC)/simpleuart.v

#software
TEST := test
BOOT := uart

TESTDIR = ../../software/tests/$(TEST)
BOOTDIR = ../../software/bootloader/$(BOOT)

all: firmware.hex boot.hex $(VSRC)
	$(VLOG) -I$(INCLUDE_DIR) -I$(INC_UART) -o top_system_test_Icarus_tb $(VSRC) $(TESTBENCH)
	./top_system_test_Icarus_tb +vcd

firmware.hex:
	make -C $(TESTDIR)
	cp $(TESTDIR)/firmware_0.hex ./firmware_0.dat
	cp $(TESTDIR)/firmware_1.hex ./firmware_1.dat
	cp $(TESTDIR)/firmware_2.hex ./firmware_2.dat
	cp $(TESTDIR)/firmware_3.hex ./firmware_3.dat

boot.hex:
	make -C $(BOOTDIR) TEST=$(TEST)
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
	@rm -f ./top_system_test_Icarus_tb
	@make -C $(BOOTDIR) clean --no-print-directory
	@make -C $(TESTDIR) clean --no-print-directory

.PHONY: all firmware.hex boot.hex clean
