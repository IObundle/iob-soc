include $(ROOT_DIR)/hardware/hardware.mk

#testbench defines 
DEFINE+=$(define)VCD
#testbench source file
VSRC+=$(ROOT_DIR)/hardware/testbench/system_tb.v

clean: sim_clean
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh

.PHONY: clean
