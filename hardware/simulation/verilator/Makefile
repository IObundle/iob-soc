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
VLOG = verilator +1800-2005ext+v --error-limit 1000  -cc -f input.vc $(DEFINE) 
#VLOG = verilator +1800-2005ext+v --error-limit 1000  -Wall -cc  $(INCLUDE2) $(DEFINE) 

# Add system wrapper to the sources list to be verilated
VSRC+=sim_system_top.v

#run the simulator
run: $(VSRC) $(VHDR) $(IMAGES)
	@echo
	@echo "-- INCLUDE FILE ------------"
	@echo "// This file typically lists flags required by a large project, e.g. include directories\n+librescan +libext+.v+.vh+.c+.cpp -y . $(INCLUDE_VERI)" > input.vc
	@echo
	@echo "-- VERILATE ----------------"
	$(VLOG) $(VSRC_VERI) --trace --top-module sim_system_top -Wno-WIDTH -Wno-PINMISSING -Wno-fatal --exe sim_xtop.cpp
	@echo
	@echo "-- BUILD -------------------"
# To compile, we can either
	$(MAKE) -j -C obj_dir -f Vsim_system_top.mk
#› $(MAKE) -j -C obj_dir -f ../Makefile_obj
	@echo
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	obj_dir/Vsim_system_top +trace
	@echo

sim-clean: hw-clean
	@rm -f *.cpp Vsystem
	@rm -rf obj_dir
	mv sim_system_top.ver sim_system_top.v

#@rm  -f *.v *.cpp *.hex Vsystem  !("sim_system_top.v")


.PHONY: run clean


