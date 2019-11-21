VLOG = iverilog -W all -g2005-sv


#hardware
RISCVDIR = ../../submodules/iob-rv32
UARTDIR = ../../submodules/iob-uart
FIFODIR = ../../submodules/fifo

UARTSRC = $(UARTDIR)/rtl/src
UARTINC = $(UARTDIR)/rtl/include

RTLDIR = ../../rtl/
INCLUDE_DIR= $(RTLDIR)/include
SRC_DIR = $(RTLDIR)/src
IP_DIR = $(RTLDIR)/ip

TESTBENCH = $(RTLDIR)/testbench/system_tb.v
VSRC = $(SRC_DIR)/*.v $(FIFODIR)/afifo.v $(SRC_DIR)/memory/*.v $(RISCVDIR)/picorv32.v $(RISCVDIR)/rtl/xalt_1p_mem.v $(UARTSRC)/iob-uart.v

#software
TESTDIR = ../../software/tests/test
BOOTDIR = ../../software/bootloader/uart

all: firmware.hex boot.hex $(VSRC)
	$(VLOG) -I$(INCLUDE_DIR) -I$(UARTINC) $(VSRC) $(TESTBENCH)
	./a.out +vcd

firmware.hex:
	make -C $(TESTDIR) BAUD=10000000
	cp $(TESTDIR)/firmware_0.hex ./firmware_0.dat
	cp $(TESTDIR)/firmware_1.hex ./firmware_1.dat
	cp $(TESTDIR)/firmware_2.hex ./firmware_2.dat
	cp $(TESTDIR)/firmware_3.hex ./firmware_3.dat

boot.hex:
	make -C $(BOOTDIR) BAUD=10000000
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
	@rm -f ./a.out
	@make -C $(BOOTDIR) clean --no-print-directory
	@make -C $(TESTDIR) clean --no-print-directory

.PHONY: all clean
