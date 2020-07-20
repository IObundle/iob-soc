include $(ROOT_DIR)/hardware/hardware.mk

#testbench defines 
DEFINE+=$(define)VCD

#testbench source files
VSRC+=$(TB_DIR)/system_tb.v $(AXI_MEM_DIR)/rtl/axi_ram.v

firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin .

$(TB_DIR)/system_tb.v:
	cp $(TB_DIR)/system_core_tb.v $@
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/inst_tb.sv; then sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/testbench/inst_tb.sv' $@; fi;)
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/pio_tb.v; then sed -i '/PIO/r $(SUBMODULES_DIR)/$p/hardware/testbench/pio_tb.v' $@; fi;)
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/*.vh; then sed -i '/PHEADER/a `include \"$(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`)\"' $@; fi;)
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/wires_tb.v; then sed -i '/PWIRES/a `include \"$(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/testbench/wires_tb.v`)\"' $@; fi;)

VSRC+=$(foreach p, $(PERIPHERALS), $(shell if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; then echo $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; fi;))


