include $(ROOT_DIR)/hardware/hardware.mk

#board specific top level source
VSRC+=./verilog/top_system.v

clean: fpga-clean
	@rm -f *.hex *.dat *.bin

.PHONY: clean load compile
