ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)

include ../simulation.mk

# remove space between -I and directory for verilator
INCLUDE_VERI=$(subst -I ,-I,$(INCLUDE)) 

VSRC_VERI=$(subst system_tb.v,,$(VSRC))

#simulator flags
VLOG = verilator +1800-2005ext+v --error-limit 1000  -cc  $(INCLUDE_VERI) $(DEFINE) 
#VLOG = verilator +1800-2005ext+v --error-limit 1000  -Wall -cc  $(INCLUDE2) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware boot.hex
	$(VLOG) $(VSRC_VERI) --trace --top-module system -Wno-WIDTH -Wno-PINMISSING -Wno-fatal --exe sim_xtop.cpp  
	make -C obj_dir -j -f Vsystem.mk Vsystem
	cp obj_dir/Vsystem Vsystem
	./Vsystem

kill-remote-sim:
	@echo "INFO: Remote verilator will be killed; ignore following errors"
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a Vsystem`'

clean: hw-clean
	@rm -f *.cpp Vsystem
	@rm -rf obj_dir

.PHONY: clean


