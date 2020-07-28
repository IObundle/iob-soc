include $(ROOT_DIR)/hardware/hardware.mk

#board specific top level source
VSRC+=./verilog/top_system.v

load:
	./prog.sh

compile: periphs firmware $(COMPILE_OBJ)

$(COMPILE_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"

.PRECIOUS: $(COMPILE_OBJ)

.PHONY: load compile
