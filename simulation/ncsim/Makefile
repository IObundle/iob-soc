define:=-define 
incdir:=-incdir 

include ../simulation.mk

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(HW_DEFINE) $(TB_DEFINE) $(HW_INCLUDE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(RTL_DIR)/testbench

#simulate
run: console.vh firmware boot $(VSRC)
	VSRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

ncsim_clean:
	@rm -rf xcelium.d xmsim.key *.log

.PHONY: ncsim_clean
