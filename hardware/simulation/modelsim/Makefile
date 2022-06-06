ROOT_DIR:=../../..

defmacro:=+define+
incdir:=+incdir+

SIMULATOR=modelsim
SIM_SERVER=$(MODELSIM_SERVER)
SIM_USER=$(MODELSIM_USER)
SIM_SSH_FLAGS=$(MODELSIM_SSH_FLAGS)
SIM_SYNC_FLAGS=$(MODELSIM_SYNC_FLAGS)
SIM_PROC=vsimk

include ../simulation.mk

INIT_SCRIPT = set -e; source ~/questa_env

#simulator flags
CFLAGS = -sv $(incdir)vhdr $(addprefix $(defmacro),$(shell cat defines.txt))
SFLAGS = -voptargs="+acc" -c system_tb

comp:
	$(INIT_SCRIPT); vlog $(CFLAGS) $(wildcard vsrc/*)

exec:
	$(INIT_SCRIPT); vsim $(SFLAGS) -do "run -all;quit"

clean: clean-remote

debug:
	@echo $(INCLUDE)
	@echo $(VSRC)

.PHONY: comp exec clean

