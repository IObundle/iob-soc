ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 

SIM_SERVER ?=$(NCSIM_SERVER)
SIM_USER ?=$(NCSIM_USER)

include ../simulation.mk

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(LIBS) $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(ROOT_DIR)/hardware/testbench

export VSRC CFLAGS EFLAGS SFLAGS 

#simulate
run: $(VSRC) $(VHDR) $(IMAGES)
	echo $(NCSIM_SERVER)
	./run_ncsim.sh
	grep -v xcelium xmsim.log | grep -v xmsim $(LOG)

sim-clean: clean
ifeq ($(SIM_SERVER),)
	@rm -rf xcelium.d xmsim.key
endif

.PHONY: run sim-clean
