#DEFINES

BAUD=$(HW_BAUD)

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=$(FPGA_DDR_ADDR_W)

include $(ROOT_DIR)/hardware/hardware.mk

#SOURCES
VSRC+=./verilog/top_system.v

#RULES
load:
	./prog.sh

compile: firmware $(FPGA_OBJ)

$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"

.PRECIOUS: $(FPGA_OBJ)

.PHONY: load compile
