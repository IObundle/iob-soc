define := #-verilog_define
incdir := #-include_dirs

include ../../synth.mk

REMOTE := ${USER}@$(FPGA_BOARD_SERVER):sandbox/iob-soc/fpga/xilinx/AES-KU040-DB-G

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

run: synth_system.bit firmware.bin
	scp $^ $(REMOTE)

synth_system.bit: *.xdc $(VSRC) boot.dat
	rm -f $@.log
	./run_vivado.sh $(USE_DDR) "$(HW_INCLUDE)" "$(HW_DEFINE)" "$(VSRC)"
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo

ld-hw:
	./ld-hw.sh

clean_xilinx:
	@rm -rf .Xil/ *.map *.vh
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*# ./rtl/
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb
	@rm -rf table.txt tab_*/ *webtalk* *.jou *.log .log
	@rm -rf xelab.* xsim[._]* xvlog.* uart_loader
	@rm -rf *.ltx fsm_encoding.os
