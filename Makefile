VIVADO_BASE = /home/iobundle/Xilinx/Vivado/2017.4
#VIVADO_BASE = /home/Xilinx/Vivado/2018.3
VIVADO = $(VIVADO_BASE)/bin/vivado
XELAB = $(VIVADO_BASE)/bin/xelab
GLBL = $(VIVADO_BASE)/data/verilog/src/glbl.v

TEST := test
BOOT := boot

RISCV = ./submodules/iob-rv32
RTLDIR = ./rtl/

INCLUDE_DIR=.$(RTLDIR)/include
SRC_DIR = $(RTLDIR)/src
IP_DIR = $(RTLDIR)/ip

TESTBENCH = $(RTLDIR)/testbench/top_system_test_Icarus_diff_clk.v

VSRC := $(SRC_DIR)/*.v $(SRC_DIR)/fifo/afifo.v $(SRC_DIR)/iob-uart/picosoc_uart.v $(SRC_DIR)/memory/*.v

export VIVADO

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

help:
	@echo ""
	@echo "Example system with open-source memories:"
	@echo "  make synth_system"
	@echo "  make sim_system"
	@echo "  clock in 'firmware.c' needs to be 100 MHz"
	@echo ""
	@echo "Example system with SDDR4:"
	@echo "  make synth_system_ddr"
	@echo "  there is no 'make sim_system_ddr' since you can't simulate a physical memory"
	@echo "  clock in 'firmware.c' needs to be 100 MHz"
	@echo ""
	@echo "Make the executable of your program (firmware.c):"
	@echo "  make firmware.hex"
	@echo ""
	@echo "Make boot-rom program (boot.c):"
	@echo "  make boot.hex"
	@echo ""


synth_%: firmware.hex boot.hex
	rm -f $@.log
	$(VIVADO) -nojournal -log $@.log -mode batch -source $@.tcl
	rm -rf .Xil fsm_encoding.os synth_*.backup.log usage_statistics_webtalk.*
	-grep -B4 -A10 'Slice LUTs' $@.log
	-grep -B1 -A9 ^Slack $@.log && echo

ncsim:
	make -C simulation/ncsim TEST=$(TEST) BOOT=$(BOOT)

icarus:
	make -C simulation/icarus TEST=$(TEST) BOOT=$(BOOT)

clean:
	@rm -rf .Xil/ firmware.bin firmware.elf firmware.hex firmware_?.hex firmware_?.dat firmware.map synth_*.log *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*#
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb table.txt tab_*/ webtalk.jou
	@rm -rf webtalk.log webtalk_*.jou webtalk_*.log xelab.* xsim[._]* xvlog.*
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader
	make -C simulation/ncsim clean
	make -C simulation/icarus clean
