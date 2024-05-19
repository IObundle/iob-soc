# This file becomes the syn makefile when copied to the build
# (c) 2022-Present IObundle, Lda, all rights reserved
#
# directory

SHELL:=bash

include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_SYN_DIR=$(REMOTE_BUILD_DIR)/hardware/syn

OUTPUT_DIR=results

SYNTHESIZER?=yosys
NODE ?= umc130
UFLAGS+=


#include local syn segment
ifneq ($(wildcard syn_build.mk),)
include syn_build.mk
endif

#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh)  
VSRC+=$(wildcard ../src/*.v) 

INCLUDE+=.
INCLUDE+=../src
INCLUDE+=../common_src

#include local syn segment
include $(SYNTHESIZER)/build.mk

build: $(VHDR) $(VSRC)
ifeq ($(SYN_SERVER),)
	make synth
else
	ssh $(SYN_SSH_FLAGS) $(SYN_USER)@$(SYN_SERVER) 'if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi'
	rsync $(SYN_SYNC_FLAGS) -avz --force --delete ../.. $(SYN_USER)@$(SYN_SERVER):$(REMOTE_BUILD_DIR)
	ssh -t $(SYN_SSH_FLAGS) -Y -C $(SYN_USER)@$(SYN_SERVER) 'make -C $(REMOTE_SYN_DIR) $@ NODE=$(NODE) $(UFLAGS) SYNTHESIZER=$(SYNTHESIZER)'
	scp $(SYN_SCP_FLAGS) $(SYN_USER)@$(SYN_SERVER):$(REMOTE_SYN_DIR)/*.log .
	scp $(SYN_SCP_FLAGS) $(SYN_USER)@$(SYN_SERVER):$(REMOTE_SYN_DIR)/$(OUTPUT_DIR)/*.rpt .
	scp $(SYN_SCP_FLAGS) $(SYN_USER)@$(SYN_SERVER):$(REMOTE_SYN_DIR)/$(OUTPUT_DIR)/*.v .
endif


clean:
	find . -maxdepth 1 -type f -not \( -name Makefile -o -name \*.tcl -o -name \*.sdc -o -name syn_build.mk \) -delete
	@rm -rf ../../*.vh config.tcl fv results st_part_log
ifneq ($(SYN_SERVER),)
	ssh $(SYN_SSH_FLAGS) $(SYN_USER)@$(SYN_SERVER) 'if [ -f $(REMOTE_SYN_DIR)/Makefile ]; then make -C $(REMOTE_SYN_DIR) $@; fi'
endif

.PHONY: build clean synth
