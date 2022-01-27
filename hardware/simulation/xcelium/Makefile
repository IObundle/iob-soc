ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 

SIMULATOR=xcelium
SIM_SERVER=$(CADENCE_SERVER)
SIM_USER=$(CADENCE_USER)
SIM_PROC=xmsim

include ../simulation.mk

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(LIBS) $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(ROOT_DIR)/hardware/testbench

#simulate
run: $(VSRC) $(VHDR) $(IMAGES)
	echo $(XMSIM_SERVER)
	./run_xmsim.sh "$(VSRC)" "$(CFLAGS)" "$(EFLAGS)" "$(SFLAGS)"
	grep -v xcelium xmsim.log | grep -v xmsim | grep -v "\$finish" $(TEST_LOG)

clean: clean-remote
	@rm -rf xcelium.d xmsim.key

.PHONY: run clean
