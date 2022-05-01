FPGA_OBJ=top_system.bit
FPGA_LOG=vivado.log

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

include ../../fpga.mk

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

post-build:

clean: clean-all
	@rm -rf .Xil/ .cache/ reports/ *.bit
	if [ $(CLEANIP) ]; then rm -rf ip/ ; fi

.PHONY: post-build clean
