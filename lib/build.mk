# Copyright © 2023 IObundle, Lda. All rights reserved.
#
# This file is copied to the root of the build directory and becomes the top Makefile.
#

SHELL:=bash

SIMULATOR ?= icarus
BOARD ?= CYCLONEV-GT-DK

include config_build.mk

BSP_H ?= software/src/bsp.h
SIM_DIR := hardware/simulation
BOARD_DIR := $(shell find -name $(BOARD) -type d -print -quit)

#
# Create bsp.h from bsp.vh
#

ifeq (fpga,$(findstring fpga,$(MAKECMDGOALS)))
  USE_FPGA = 1
endif

$(BSP_H):
ifeq ($(USE_FPGA),1)
	@echo "Creating $(BSP_H) for FPGA"
	cp $(BOARD_DIR)/bsp.vh $@;	
else
	@echo "Creating $(BSP_H) for simulation"
	cp $(SIM_DIR)/src/bsp.vh $@;
endif
	sed -i 's/`/#/g' $@;


# 
# EMBEDDED SOFTWARE
#
SW_DIR=software
fw-build: $(BSP_H)
	make -C $(SW_DIR) build

fw-clean:
	make -C $(SW_DIR) clean

#this target is not the same as fw-build because bsp.h is build for FPGA when fw-build is called
#see $(BSP_H) target that uses $(MAKECMDGOALS) to check if fw-build is called for FPGA or simulation
fpga-fw-build: fw-build

#
# PC EMUL
#
pc-emul-build: fw-build
	make -C $(SW_DIR) build_emul

pc-emul-run: $(BSP_H)
	make -C $(SW_DIR) run_emul

pc-emul-test: $(BSP_H)
	make -C $(SW_DIR) test_emul

pc-emul-clean:
	make -C $(SW_DIR) clean


#
# LINT
#

LINTER ?= spyglass
LINT_DIR=hardware/lint
lint-run:
	make -C $(LINT_DIR) run

lint-clean:
	make -C $(LINT_DIR) clean

lint-test:
	make lint-run LINTER=spyglass
	make lint-run LINTER=alint


#
# SIMULATE
#
sim-build: fw-build
	make -C $(SIM_DIR) -j1 build

sim-run: fw-build
	make -C $(SIM_DIR) -j1 run

sim-waves:
	make -C $(SIM_DIR) waves

sim-test:
	make -C $(SIM_DIR) test

sim-debug: 
	make -C $(SIM_DIR) debug

sim-clean:
	make -C $(SIM_DIR) clean

sim-cov: sim-clean
	make -C $(SIM_DIR) -j1 run COV=1



#
# FPGA
#
FPGA_DIR=hardware/fpga
fpga-build:
	make -C $(FPGA_DIR) -j1 build

fpga-run:
	make -C $(FPGA_DIR) -j1 run

fpga-test:
	make -C $(FPGA_DIR) test

fpga-debug:
	echo "BOARD=$(BOARD)"
	make -C $(FPGA_DIR) debug

fpga-clean:
	make -C $(FPGA_DIR) clean

#
# SYN
#
SYN_DIR=hardware/syn
syn-build:
	make -C $(SYN_DIR) build

syn-clean:
	make -C $(SYN_DIR) clean

syn-test: syn-clean syn-build

#
# DOCUMENT
#
DOC_DIR=document
doc-build: $(BSP_H)
	make -C $(DOC_DIR) build

doc-view: $(BSP_H)
	make -C $(DOC_DIR) view

doc-debug: 
	make -C $(DOC_DIR) debug

doc-clean:
ifneq ($(wildcard $(DOC_DIR)/Makefile),)
	make -C $(DOC_DIR) clean
endif

ifneq ($(wildcard document/tsrc),)
doc-test: doc-clean
	make -C $(DOC_DIR) test
else
doc-test:
endif


#
# TEST
#
test: sim-test fpga-test doc-test

ptest: dtest lint-test sim-cov

dtest: test syn-test 



#
# CLEAN
#

clean: fw-clean pc-emul-clean lint-clean sim-clean fpga-clean doc-clean
	rm -f $(BSP_H)


.PHONY: fw-build fpga-fw-build fw-clean \
	pc-emul-build pc-emul-run pc-emul-clean \
	lint-test lint-run lint-clean \
	sim-build sim-run sim-debug sim-clean \
	fpga-build fpga-debug fpga-clean \
	doc-build doc-view doc-debug doc-test doc-clean \
	test clean debug

