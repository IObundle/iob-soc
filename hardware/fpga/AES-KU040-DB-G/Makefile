ROOT_DIR:=../../..

#define:=-verilog_define
#incdir:=-include_dirs

include ../fpga.mk

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

load:
	./ld-hw.sh

compile: periphs firmware.hex synth_system.bit

synth_system.bit: $(wildcard *.xdc) $(VSRC) boot.hex 
	rm -f $@.log
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo

clean: hw-clean
	rm -rf .Xil/ *.map *. *~ synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb table.txt tab_*/ *webtalk* *.jou xelab.* xsim[._]* xvlog.* uart_loader *.ltx fsm_encoding.os

clean-ip:
	rm -rf ip *.log

.PRECIOUS: synth_system.bit

.PHONY: load compile fpga-clean clean-ip
