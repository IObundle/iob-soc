FPGA_OBJ=top_system.bit
FPGA_LOG=vivado.log

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

include ../../fpga.mk

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

local-build:
	source $(VIVADOPATH)/settings64.sh && vivado -nojournal -log vivado.log -mode batch -source ../top_system.tcl -tclargs "$(INCLUDE)" "$(DEFINE)" "$(VSRC)" "$(DEVICE)"


clean: clean-all
	@rm -rf .Xil/ .cache/ reports/ *.bit

clean-ip:
	rm -rf ip

veryclean: clean clean-ip

