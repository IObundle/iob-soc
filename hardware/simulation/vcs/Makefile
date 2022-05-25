ROOT_DIR:=../../..

defmacro:=+define+
incdir:=+incdir+

SIMULATOR=vcs
SIM_SERVER=$(SYNOPSYS_SERVER)
SIM_USER=$(SYNOPSYS_USER)
SIM_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
SIM_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
SIM_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)

include ../simulation.mk


VLOG =
VELAB =

#compile
comp: $(VSRC) $(VHDR) $(MACRO_LIST)
	vlogan -nc -sverilog $(INCLUDE) $(DEFINE) $(VSRC)

#elaborate
elab: comp
	vcs -debug_access+nomemcbk+dmptf -debug_region+cell system_tb

exec: elab
	./simv

clean:
	@rm -f simv *.raw

.PHONY: comp elab exec clean

