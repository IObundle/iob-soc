ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 

SIMULATOR=xcelium
SIM_SERVER=$(CADENCE_SERVER)
SIM_USER=$(CADENCE_USER)
SIM_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SIM_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SIM_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)

include ../simulation.mk

INIT_SCRIPT = set -e; source /opt/ic_tools/init/init-xcelium1903-hf013

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status 

comp:
	xmvlog $(CFLAGS) $(VSRC); xmelab $(EFLAGS) worklib.system_top:module

#simulate
exec:
	$(INIT_SCRIPT); xmsim $(SFLAGS) worklib.system_top:module
	grep -v xcelium xmsim.log | grep -v xmsim | grep -v "\$finish" $(TEST_LOG)

clean: clean-remote
	@rm -rf xcelium.d xmsim.key

.PHONY: comp exec clean
