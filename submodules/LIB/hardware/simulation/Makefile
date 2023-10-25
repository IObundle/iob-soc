# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash

#select simulator
#default simulator
SIMULATOR ?=icarus

include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_SIM_DIR=$(REMOTE_BUILD_DIR)/hardware/simulation

#include simulation headers and sources
VHDR+=$(wildcard ./src/*.vh)
VSRC+=$(wildcard ./src/*.v)

ifeq ($(SYN),)
#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh)
VSRC+=$(wildcard ../src/*.v)
else
NODE ?= umc130
include ../syn/$(NODE)/sim.mk
VSRC+= ../syn/results/*.v
../syn/%.v:
	make -C ../syn build
endif

#exclude verilog testbench when using Verilator
ifeq ($(SIMULATOR), verilator)
VSRC:=$(filter-out $(wildcard ./src/*_tb.v), $(VSRC))
endif

#include local simulation segment
ifneq ($(wildcard sim_build.mk),)
include sim_build.mk
endif

include $(SIMULATOR).mk

UFLAGS+=VCD=$(VCD)
UFLAGS+=COV=$(COV)
UFLAGS+=SYN=$(SYN)
UFLAGS+=NODE=$(NODE)
UFLAGS+=COV_TEST=$(COV_TEST)

remote_build_dir:
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(SIM_SYNC_FLAGS) -avz --force --delete ../.. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
endif

build: $(VHDR) $(VSRC) $(HEX) remote_build_dir
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh -t $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR) $(UFLAGS)'
endif

#board client command
GRAB_TIMEOUT ?= 300
BOARD_GRAB_CMD=../../scripts/board_client.py grab $(GRAB_TIMEOUT)

run: remote_build_dir
ifeq ($(SIM_SERVER),)
ifneq ($(CONSOLE_CMD),)
	$(BOARD_GRAB_CMD) -s 'make exec' -c '$(CONSOLE_CMD)'
else
	make exec
endif
else
ifeq ($(VCD),1)
	trap 'trap - INT TERM; scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.vcd .' INT TERM EXIT;\
	ssh -t $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR) $(UFLAGS)' || true
else
	ssh -t $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR) $(UFLAGS)'
endif
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.log .
ifeq ($(COV),1)
	sleep 1 && sync && scp -r $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/cov_work .
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/coverage_report_summary.rpt .
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/coverage_report_detail.rpt .
endif
endif
ifeq ($(VCD),1)
	make waves
endif

waves:
	if [ ! "`pgrep -u $(USER) gtkwave`" ]; then gtkwave -a uut.gtkw uut.vcd; fi &

fix-vcd:
	$(eval VCD_FILE:=$(shell ls *.vcd))
	@tail -n 1 $(VCD_FILE) | wc -c | xargs -I {} truncate $(VCD_FILE) -s -{}
	@echo "" >> $(VCD_FILE)

test.log: very-clean clean-test-log $(TEST_LIST)

test: test.log
	sync && sleep 1 && test "$$(cat test.log)" = "Test passed!"

gen-clean:
	@rm -f *.hex
	@find . -maxdepth 1 -name "*.vh" -not \( -name "bsp.vh" -o -name "uut_build.mk" \) -delete
ifneq ($(SIM_SERVER),)
	ssh -t $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'if [ -f $(REMOTE_SIM_DIR)/Makefile ]; then make -C $(REMOTE_SIM_DIR) $@; fi'
endif

clean-test-log:
	rm -f test.log

debug:
	@echo NAME=$(NAME)
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo VFLAGS=$(VFLAGS)
	@echo $(TEST_LIST)

.PRECIOUS: uut.vcd

.PHONY: build run remote_build_dir waves fix-vcd test run-tests gen-clean clean-test-log debug
