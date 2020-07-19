include $(ROOT_DIR)/hardware/hardware.mk

#testbench defines 
DEFINE+=$(define)VCD

#testbench source files
VSRC+=$(TB_DIR)/system_tb.v $(AXI_MEM_DIR)/rtl/axi_ram.v

firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin .
