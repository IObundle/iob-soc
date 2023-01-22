FPGA_OBJ=top_system.bit
FPGA_LOG=colorlight.log

FPGA_SERVER=$(TRELLIS_SERVER)
FPGA_USER=$(TRELLIS_USER)

include ../../fpga.mk

local-build:
	tclsh ../top_system.tcl "$(INCLUDE)" "$(DEFINE)" "$(VSRC)" "$(BOARD)" "$(REVISION)"

clean: clean-all
	@rm -rf *.json *.ys *.txt *.config *.log *.svf *.bit *.lpf

clean-ip:
	

veryclean: clean clean-ip

