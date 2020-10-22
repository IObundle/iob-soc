include $(ROOT_DIR)/hardware/hardware.mk

#board specific top level source
VSRC+=./verilog/top_system.v

load:
	./prog.sh

compile: firmware $(FPGA_OBJ)

$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"

.PRECIOUS: $(FPGA_OBJ)

.PHONY: load compile
