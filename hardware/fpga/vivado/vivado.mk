FPGA_OBJ=top_system.bit
FPGA_LOG=vivado.log

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

include ../../fpga.mk

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

post-build:

clean: hw-clean clean-remote
	rm -rf .Xil/ *.map *. *~ synth_*.mmi synth_*.bit top_system*.v \
	*_tb table.txt tab_*/ *webtalk* *.jou xelab.* xsim[._]* xvlog.* \
	uart_loader *.ltx system.v fsm_encoding.os
	if [ $(CLEANIP) ]; then rm -rf ip; fi

.PHONY: post-build clean
