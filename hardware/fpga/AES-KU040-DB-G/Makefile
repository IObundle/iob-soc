ROOT_DIR:=../../..

include ../fpga.mk

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

clean: hw-clean
	rm -rf .Xil/ *.map *. *~ synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb table.txt tab_*/ *webtalk* *.jou xelab.* xsim[._]* xvlog.* uart_loader *.ltx system.v fsm_encoding.os $(COMPILE_OBJ)

clean-ip:
	rm -rf ip *.log

.PHONY: clean clean-ip
