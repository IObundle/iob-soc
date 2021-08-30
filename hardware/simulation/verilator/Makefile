ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)
SIM_PROC=Vsystem


include ../simulation.mk

# remove space between -I and directory for verilator
INCLUDE_VERI=$(subst -I ,-I,$(INCLUDE)) 

VSRC_VERI=$(subst system_tb.v,,$(VSRC))

#simulator flags
VLOG = verilator +1800-2005ext+v --error-limit 1000  -cc  $(INCLUDE_VERI) $(DEFINE) 
#VLOG = verilator +1800-2005ext+v --error-limit 1000  -Wall -cc  $(INCLUDE2) $(DEFINE) 

# Add system wrapper to the sources list to be verilated
VSRC+=sim_system_top.v

#run the simulator
run: $(VSRC) $(VHDR) firmware boot.hex
	$(VLOG) $(VSRC_VERI) --trace --top-module sim_system_top -Wno-WIDTH -Wno-PINMISSING -Wno-fatal --exe sim_xtop.cpp  
	make -C obj_dir -j -f Vsim_system_top.mk Vsim_system_top
	cp obj_dir/Vsim_system_top Vsim_system_top
	./Vsim_system_top

sim-clean: hw-clean
	@rm -f *.cpp Vsystem
	@rm -rf obj_dir
	mv sim_system_top.ver sim_system_top.v

#@rm  -f *.v *.cpp *.hex Vsystem  !("sim_system_top.v")


.PHONY: run clean


