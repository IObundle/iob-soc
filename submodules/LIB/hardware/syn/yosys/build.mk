# (c) 2022-Present IObundle, Lda, all rights reserved
#
#
# This makefile segment is used at build-time
#


SYN_SERVER=$(YOSYS_SERVER)
SYN_USER=$(YOSYS_USER)
SYN_SSH_FLAGS=$(YOSYS_SSH_FLAGS)
SYN_SCP_FLAGS=$(YOSYS_SCP_FLAGS)
SYN_SYNC_FLAGS=$(YOSYS_SYNC_FLAGS)

synth: $(VHDR) $(VSRC)
	yosys -l yosys.log $(SYNTHESIZER)/build.tcl 
