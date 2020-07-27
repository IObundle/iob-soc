ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 

include ../simulation.mk

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(ROOT_DIR)/hardware/testbench


SIM_USER:=user19
SIM_SERVER=$(SIM_USER)@micro7.lx.it.pt
SIM_ROOT_DIR=./sandbox/iob-soc

#simulate
run: $(VSRC) $(VHDR) firmware.bin firmware.hex boot.hex periphs
	ssh $(SIM_SERVER) "if [ ! -d $(SIM_ROOT_DIR) ]; then mkdir -p $(SIM_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(SIM_SERVER):$(SIM_ROOT_DIR) 
	ssh $(SIM_SERVER) "cd $(SIM_ROOT_DIR)/hardware/simulation/ncsim; VSRC=\"$(VSRC)\" CFLAGS=\"$(CFLAGS)\" EFLAGS=\"$(EFLAGS)\" SFLAGS=\"$(SFLAGS)\" ./run_ncsim.sh $(TEST_LOG)"

clean: hw-clean
	ssh $(SIM_SERVER) "cd $(SIM_SERVER_ROOT_DIR); rm -rf xcelium.d xmsim.key *.log"

.PHONY: clean
