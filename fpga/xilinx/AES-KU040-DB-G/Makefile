RTL_DIR = ../../../rtl
RISCV_DIR = ../../../submodules/iob-rv32
UART_DIR = ../../../submodules/iob-uart
FIFO_DIR = ../../../submodules/fifo
FIRM_DIR := ../../../software/firmware
BOOT_DIR := ../../../software/bootloader
PYTHON_DIR := ../../../software/python

BAUD = 115200

ifneq ($(shell grep USE_DDR $(RTL_DIR)/include/system.vh | grep -v "//"),)
USE_DDR = USE_DDR
endif


VSRC = verilog/top_system.v  $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

synth_system.bit: *.xdc $(VSRC) firmware.hex boot.hex
	rm -f $@.log
	$(PYTHON_DIR)/hex_split.py firmware
ifeq ($(shell grep USE_ $(RTL_DIR)/include/system.vh | grep -v \/\/),)
	mv firmware.hex boot.hex
	$(PYTHON_DIR)/hex_split.py boot
else
	$(PYTHON_DIR)/hex_split.py boot
endif
	vivado -nojournal -log $@.log -mode batch -source synth_system.tcl -tclargs $(BAUD) $(USE_DDR)
	-grep -B4 -A10 'CLB LUTs' $@.log
	-grep -B1 -A9 ^Slack $@.log && echo
	scp -P 1418 $@ ${USER}@iobundle.ddns.net:sandbox/iob-soc-e/fpga/xilinx/AES-KU040-DB-G
	scp -P 1418 $(FIRM_DIR)/firmware.bin ${USER}@iobundle.ddns.net:sandbox/iob-soc-e/fpga/xilinx/AES-KU040-DB-G

firmware.hex:
	make -C $(FIRM_DIR) BAUD=$(BAUD)
	cp   $(FIRM_DIR)/firmware.hex .

boot.hex:
	make -C $(BOOT_DIR) BAUD=$(BAUD)
	cp  $(BOOT_DIR)/boot.hex .

ld-hw:
	source /opt/Xilinx/Vivado/settings.sh
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

.PHONY: clean boot firmware
