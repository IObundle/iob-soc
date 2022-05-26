ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 

SIMULATOR=xcelium
SIM_SERVER=$(CADENCE_SERVER)
SIM_USER=$(CADENCE_USER)
SIM_PROC=xmsim

include ../simulation.mk

INIT_SCRIPT = set -e; source /opt/ic_tools/init/init-xcelium1903-hf013

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status 

comp:
	$(INIT_SCRIPT); xmvlog $(CFLAGS) $(VSRC); xmelab $(EFLAGS) worklib.system_tb:module

#simulate
exec:
	$(INIT_SCRIPT); xmsim $(SFLAGS) worklib.system_tb:module
	grep -v xcelium xmsim.log | grep -v xmsim | grep -v "\$finish" $(TEST_LOG)

clean: clean-remote
	@rm -rf xcelium.d xmsim.key

.PHONY: comp exec clean
