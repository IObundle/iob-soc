ROOT_DIR:=../../..

include ../fpga.mk

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

COMPILE_SERVER=$(USER)@pudim-flan.iobundle.com

load:
	ssh $(BOARD_SERVER) "cd $(REMOTE_FPGA_DIR); ./prog.sh"

compile: periphs firmware synth_system.bit

synth_system.bit: $(wildcard *.xdc) $(VSRC)  $(VHDR) boot.hex
	echo $(FPGA_DIR) $(BOARD)
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	ssh $(COMPILE_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(COMPILE_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(COMPILE_SERVER) "cd $(REMOTE_FPGA_DIR)/; ./build.sh \"$(INCLUDE)\" \"$(DEFINE)\" \"$(VSRC)\""
	touch $(FPGA_DIR)/$@
	scp $(COMPILE_SERVER):$(FPGA_DIR)/vivado.log $(FPGA_DIR)/vivado.log
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo

clean: hw-clean
	ssh $(COMPILE_SERVER) "cd $(REMOTE_FPGA_DIR); rm -rf .Xil/ *.map *. *~ synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb table.txt tab_*/ *webtalk* *.jou xelab.* xsim[._]* xvlog.* uart_loader *.ltx fsm_encoding.os"

clean-ip:
	ssh $(COMPILE_SERVER) "cd $(REMOTE_FPGA_DIR); rm -rf ip *.log"

.PRECIOUS: synth_system.bit

.PHONY: run load compile clean clean-ip
