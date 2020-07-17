include $(ROOT_DIR)/hardware/hardware.mk

#testbench defines 
DEFINE+=$(define)VCD
#testbench source file
VSRC+=$(HW_DIR)/testbench/system_tb.v $(AXI_MEM_DIR)/rtl/axi_ram.v

firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin .


clean: sim_clean
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh

.PHONY: clean
