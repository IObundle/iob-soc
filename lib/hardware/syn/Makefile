# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash

include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_SYN_DIR=$(REMOTE_BUILD_DIR)/hardware/syn

#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh) $(wildcard ./src/*.vh)
VSRC+=$(wildcard ../src/*.v) $(wildcard ./src/*.v)

INCLUDE+=.
INCLUDE+=../src
INCLUDE+=../common_src

#include local syn segment
ifneq ($(wildcard syn_build.mk),)
include syn_build.mk
endif

OUTPUT_DIR=results

#default node
NODE ?= umc130

SYN_SERVER=$(CADENCE_SERVER)
SYN_USER=$(CADENCE_USER)
SYN_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SYN_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SYN_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)

synth: $(VHDR) $(VSRC)
	genus -batch -files build.tcl


UFLAGS+=COV=$(COV)
UFLAGS+=COV_TEST=$(COV_TEST)

build: $(VHDR) $(VSRC) config.tcl
ifeq ($(SYN_SERVER),)
	make synth
else
	ssh $(SYN_SSH_FLAGS) $(SYN_USER)@$(SYN_SERVER) 'if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi'
	rsync $(SYN_SYNC_FLAGS) -avz --force --delete ../.. $(SYN_USER)@$(SYN_SERVER):$(REMOTE_BUILD_DIR)
	ssh -t $(SYN_SSH_FLAGS) -Y -C $(SYN_USER)@$(SYN_SERVER) 'make -C $(REMOTE_SYN_DIR) $@ NODE=$(NODE) $(UFLAGS)'
	scp $(SYN_SCP_FLAGS) $(SYN_USER)@$(SYN_SERVER):$(REMOTE_SYN_DIR)/*.log .
	scp $(SYN_SCP_FLAGS) $(SYN_USER)@$(SYN_SERVER):$(REMOTE_SYN_DIR)/$(OUTPUT_DIR)/*.rpt .
	scp $(SYN_SCP_FLAGS) $(SYN_USER)@$(SYN_SERVER):$(REMOTE_SYN_DIR)/$(OUTPUT_DIR)/*.v .
endif

config.tcl:
	@echo "set NODE $(NODE)" > $@
	@echo "set NAME $(NAME)" >> $@
	@echo "set CSR_IF $(CSR_IF)" >> $@
	@echo "set DESIGN $(NAME)" >> $@
	@echo "set OUTPUT_DIR $(OUTPUT_DIR)" >> $@
	@echo "set INCLUDE [list $(INCLUDE)]" >> $@
	@echo "set VSRC [glob $(VSRC)]" >> $@

clean:
	find . -maxdepth 1 -type f -not \( -name Makefile -o -name \*.tcl -o -name \*.sdc -o -name syn_build.mk \) -delete
	@rm -rf ../../*.vh config.tcl fv results st_part_log
ifneq ($(SYN_SERVER),)
	ssh $(SYN_SSH_FLAGS) $(SYN_USER)@$(SYN_SERVER) 'if [ -f $(REMOTE_SYN_DIR)/Makefile ]; then make -C $(REMOTE_SYN_DIR) $@; fi'
endif

.PHONY: run clean config.tcl synth
