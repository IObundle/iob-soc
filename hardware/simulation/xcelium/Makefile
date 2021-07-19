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

#simulate
run: $(VSRC) $(VHDR) $(IMAGES)
	echo $(XMSIM_SERVER)
	./run_xmsim.sh "$(VSRC)" "$(CFLAGS)" "$(EFLAGS)" "$(SFLAGS)"
	grep -v xcelium xmsim.log | grep -v xmsim $(LOG)

kill-remote-sim:
	@echo "INFO: Remote xcelium will be killed; ignore following errors"
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a xmsim`'

sim-clean: hw-clean
	@rm -rf xcelium.d xmsim.key

.PHONY: run kill-remote-sim sim-clean
