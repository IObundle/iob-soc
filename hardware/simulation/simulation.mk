HW_DIR:=$(ROOT_DIR)/hardware
include $(HW_DIR)/hardware.mk

#testbench defines 
DEFINE+=$(define)VCD
DEFINE+=$(define)PROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
#testbench source file
VSRC+=$(HW_DIR)/testbench/system_tb.v

#CLEAN UP

ifeq ($(SIM_DIR),simulation/icarus)
sim_clean:=icarus_clean
endif

ifeq ($(SIM_DIR),simulation/ncsim)
sim_clean:=ncsim_clean
endif

clean: $(sim_clean)
	@rm -f *# *~ *.vcd *.dat *.hex *.bin *.vh

.PHONY: all run boot firmware clean
