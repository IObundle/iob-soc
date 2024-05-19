# This file becomes the syn makefile when copied to the build
# (c) 2022-Present IObundle, Lda, all rights reserved
#
# directory

SHELL:=bash

include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_SYN_DIR=$(REMOTE_BUILD_DIR)/hardware/syn

OUTPUT_DIR=results

NODE ?= umc130
UFLAGS+=COV=$(COV)
UFLAGS+=COV_TEST=$(COV_TEST)


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

synth: $(VHDR) $(VSRC)
	$(SYNTH_COMMAND) $(SYNTHESIZER)/build.tcl 

build: $(VHDR) $(VSRC) config.tcl
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

.PHONY: run clean synth
