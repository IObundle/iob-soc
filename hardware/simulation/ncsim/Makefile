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

export VSRC CFLAGS EFLAGS SFLAGS 

#simulate
run: $(VSRC) $(VHDR) firmware boot.hex periphs
	./run_ncsim.sh
	grep -v xcelium xmsim.log | grep -v xmsim $(LOG)

clean: hw-clean
	@rm -rf xcelium.d xmsim.key *.log

.PHONY: clean
