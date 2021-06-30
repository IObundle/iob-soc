ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 

SIMULATOR=xcelium
SIM_SERVER ?=$(XMSIM_SERVER)
SIM_USER ?=$(XMSIM_USER)

include ../simulation.mk

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(LIBS) $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(ROOT_DIR)/hardware/testbench

export VSRC CFLAGS EFLAGS SFLAGS 

#simulate
run: $(VSRC) $(VHDR) $(IMAGES)
	echo $(XMSIM_SERVER)
	./run_xmsim.sh
	grep -v xcelium xmsim.log | grep -v xmsim $(LOG)

sim-clean: hw-clean
	@rm -rf xcelium.d xmsim.key

.PHONY: run sim-clean
