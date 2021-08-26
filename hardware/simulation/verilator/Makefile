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
VSRC+=verilog/sim_system_top.v

#run the simulator
run: build
	./$(SIM_PROC) $(TEST_LOG)

build: $(SIM_PROC)

$(SIM_PROC): $(VSRC) $(VHDR) $(IMAGES)
	$(VLOG) $(VSRC_VERI) --trace --top-module sim_system_top -Wno-WIDTH -Wno-PINMISSING -Wno-fatal --exe sim_xtop.cpp
	make -C obj_dir -j -f Vsim_system_top.mk $(SIM_PROC)
	cp obj_dir/$(SIM_PROC) $(SIM_PROC)

clean: clean-remote
	@rm -f *.v *.cpp *.hex $(SIM_PROC)
	@rm -rf obj_dir

.PHONY: run build clean
