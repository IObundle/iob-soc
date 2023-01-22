FPGA_OBJ=top_system.bit
FPGA_LOG=colorlight.log

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)

include ../../fpga.mk

local-build:
	tclsh ../top_system.tcl "$(INCLUDE)" "$(DEFINE)" "$(VSRC)" "$(BOARD)" "$(REVISION)"

clean: clean-all
	@rm -rf *.json *.ys *.txt *.config *.log *.svf *.bit *.lpf

clean-ip:
	

veryclean: clean clean-ip

