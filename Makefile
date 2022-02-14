UART_DIR:=.
include config.mk

.PHONY: sim sim-test sim-clean \
	fpga-build fpga-build-all fpga-test fpga-clean fpga-clean-all \
	doc-build doc-build-all doc-test doc-clean doc-clean-all \
	test-sim test-sim-clean \
	test-fpga test-fpga-clean \
	test-doc test-doc-clean \
	test test-clean \
	clean-all debug


#
# SIMULATE
#
SIM_DIR ?=$(UART_HW_DIR)/simulation
VCD ?=0

sim:
	make -C $(SIM_DIR) run

sim-test:
	make -C $(SIM_DIR) test

sim-clean:
	make -C $(SIM_DIR) clean-all

#
# FPGA COMPILE
#
FPGA_DIR ?= $(shell find $(UART_DIR)/hardware -name $(FPGA_FAMILY))


fpga-build:
	make -C $(FPGA_DIR) build

fpga-build-all:
	$(foreach s, $(FPGA_FAMILY_LIST), make fpga-build FPGA_FAMILY=$s;)

fpga-test:
	make -C $(FPGA_DIR) test

fpga-clean:
	make -C $(FPGA_DIR) clean-all

fpga-clean-all:
	$(foreach s, $(FPGA_FAMILY_LIST), make fpga-clean FPGA_FAMILY=$s;)


#
# DOCUMENT
#
DOC_DIR ?=$(UART_DIR)/document/$(DOC)

doc-build:
	make -C $(DOC_DIR) all

doc-build-all:
	$(foreach s, $(DOC_LIST), make doc-build DOC=$s;)

doc-test:
	make -C $(DOC_DIR) test

doc-clean:
	make -C $(DOC_DIR) clean

doc-clean-all:
	$(foreach s, $(DOC_LIST), make doc-clean DOC=$s;)


#
# TEST ON SIMULATORS AND BOARDS
#

test-sim:
	make sim-test

test-sim-clean:
	make sim-clean

test-fpga:
	make fpga-test FPGA_FAMILY=CYCLONEV-GT
	make fpga-test FPGA_FAMILY=XCKU

test-fpga-clean:
	make fpga-clean FPGA_FAMILY=CYCLONEV-GT
	make fpga-clean FPGA_FAMILY=XCKU

test-doc:
	make doc-test DOC=pb
	make doc-test DOC=ug

test-doc-clean:
	make doc-clean DOC=pb
	make doc-clean DOC=ug

test: test-clean test-sim test-fpga test-doc

test-clean: test-sim-clean test-fpga-clean test-doc-clean

#
# CLEAN ALL
# 

clean-all: sim-clean fpga-clean-all doc-clean-all


debug:
	@echo $(SIM_DIR)
	@echo $(FPGA_DIR)
	@echo $(DOC_DIR)
