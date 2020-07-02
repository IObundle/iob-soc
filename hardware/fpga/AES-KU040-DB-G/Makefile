ROOT_DIR:=../../..

define := #-verilog_define
incdir := #-include_dirs

include ../fpga.mk


# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

load: synth_system.bit
	./ld-hw.sh

compile: periphs synth_system.bit

synth_system.bit: *.xdc $(VSRC) firmware.hex boot.hex
	rm -f $@.log
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo

GARBAGE:=.Xil/ *.map *. *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*# ./rtl/ synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb \
table.txt tab_*/ *webtalk* *.jou *.log .log xelab.* xsim[._]* xvlog.* uart_loader *.ltx fsm_encoding.os

fpga-clean:
	rm -rf $(GARBAGE)

.PHONY: fpga-clean
