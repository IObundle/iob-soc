include $(ROOT_DIR)/hardware/hardware.mk

#testbench defmacros
ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

#testbench source files
VSRC+=system_tb.v $(AXI_MEM_DIR)/rtl/axi_ram.v

#create testbench 
system_tb.v:
	cp $(TB_DIR)/system_core_tb.v $@
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/*.vh; then sed -i '/PHEADER/a `include \"$(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`)\"' $@; fi;) #include header files
	$(foreach p, $(PERIPHERALS), sed s/input/wire/ $(SUBMODULES_DIR)/$p/hardware/include/pio.v | sed s/output/wire/  | sed s/\,/\;/ > wires_tb.v; sed -i '/PWIRES/a `include \"wires_tb.v"' $@;) #declare wires
	$(foreach p, $(PERIPHERALS), sed s/input// $(SUBMODULES_DIR)/$p/hardware/include/pio.v | sed s/output// | sed 's/\([A-Za-z].*\),/\.\1(\1),/' > ./pio_tb.v; sed -i '/PIO/r pio_tb.v' $@) #insert and connect pins in uut instance
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/inst_tb.sv; then sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/include/inst_tb.sv' $@; fi;) #instantiate peripheral test module

VSRC+=$(foreach p, $(PERIPHERALS), $(shell if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; then echo $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; fi;))
