# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile segment is used at build-time
#


SYN_SERVER=$(CADENCE_SERVER)
SYN_USER=$(CADENCE_USER)
SYN_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SYN_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SYN_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)


SYNTH_COMMAND = $(SYNTHESIZER) -batch -files


