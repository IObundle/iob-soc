include $(ROOT_DIR)/hardware/hardware.mk

#testbench defines 
DEFINE+=$(define)VCD
#testbench source file
VSRC+=$(ROOT_DIR)/hardware/testbench/system_tb.v

#CLEAN UP

ifeq ($(SIMULATOR),icarus)
sim_clean:=icarus_clean
endif

ifeq ($(SIMULATOR),ncsim)
sim_clean:=ncsim_clean
endif

clean: $(sim_clean)
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh

.PHONY: clean
