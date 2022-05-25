ROOT_DIR:=../../..

defmacro:=-define 
incdir:=-incdir 


SIMULATOR=xcelium
SIM_SERVER=$(CADENCE_SERVER)
SIM_USER=$(CADENCE_USER)
SIM_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SIM_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SIM_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)
SIM_PROC=xmsim

include ../simulation.mk

# Coverage test name
TEST?=test

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(LIBS) $(INCLUDE) $(DEFINE)
ifeq ($(DO_COV),0)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE ../testbench
else
EFLAGS = -errormax 15 -access +wc -status -covdut iob_png_d_top -coverage A -covfile cov_commands.ccf
SFLAGS = -LICQUEUE -errormax 15 -status -CMDFILE ../testbench -covoverwrite -covtest $(TEST)
endif

.PHONY: run build clean

#compile
comp: $(VSRC) $(VHDR)
	xmvlog $(CFLAGS) $(VSRC)

#elaborate
elab: comp
	xmelab $(EFLAGS) worklib.system_tb:module

#simulate
exec: elab
	xmsim  $(SFLAGS) worklib.system_tb:module
ifeq ($(DO_COV),1)
	ls -d cov_work/scope/* > all_ucd_file
	imc -execcmd "merge -runfile all_ucd_file -overwrite -out merge_all"
	imc -exec iob_png_d_run_cov.tcl
endif

clean: sim-clean
	@rm -rf xcelium.d xmsim.key *.raw *.png *.hex *.log

.PHONY: comp elab exec clean
