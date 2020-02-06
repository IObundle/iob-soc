RTL_DIR = ../../../rtl
RISCV_DIR = ../../../submodules/iob-rv32
UART_DIR = ../../../submodules/iob-uart
FIFO_DIR = ../../../submodules/fifo
FIRM_DIR := ../../../software/firmware
BOOT_DIR := ../../../software/bootloader
PYTHON_DIR := ../../../software/python
REMOTE := ${USER}@iobundle.ddns.net:sandbox/iob-soc-e/fpga/xilinx/AES-KU040-DB-G
PORT := -P 1418

BAUD = 115200

ifneq ($(shell grep USE_DDR $(RTL_DIR)/include/system.vh | grep -v "//"),)
USE_DDR = USE_DDR
endif


VSRC = verilog/top_system.v $(RTL_DIR)/include/*.vh $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

all: synth_system.bit
	scp $(PORT) $< $(REMOTE)
	scp $(PORT) $(FIRM_DIR)/firmware.bin  $(REMOTE)

synth_system.bit: *.xdc $(VSRC) firmware.hex boot.hex
	rm -f $@.log
	vivado -nojournal -log $@.log -mode batch -source synth_system.tcl -tclargs $(USE_DDR)
	-grep -B4 -A10 'CLB LUTs' $@.log
	-grep -B1 -A9 ^Slack $@.log && echo

firmware.hex: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD)

boot.hex: $(BOOT_DIR)/boot.hex
ifeq ($(shell grep USE_ $(RTL_DIR)/include/system.vh | grep -v \/\/),)
	cp $(FIRM_DIR)/firmware.hex boot.hex
else 
	cp $< .
endif
	$(PYTHON_DIR)/hex_split.py boot

$(BOOT_DIR)/boot.hex: FORCE
	make -C $(BOOT_DIR) BAUD=$(BAUD)

ld-hw:
	vivado -nojournal -log $@.log -mode batch -source $@.tcl

clean:
	@rm -rf .Xil/ *.hex *.dat *.map synth_*.log 
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*# ./rtl/
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb 
	@rm -rf table.txt tab_*/ *webtalk* *.jou *.log
	@rm -rf xelab.* xsim[._]* xvlog.* uart_loader
	@rm -rf *.ltx fsm_encoding.os
	make -C $(FIRM_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory

.PHONY: all clean ld-hw FORCE
