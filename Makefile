export SHELL = /usr/bin/env bash

ROOT_DIR:=.
include ./config.mk


#
# BUILD EMBEDDED SOFTWARE
#

fw-build:
	make -C $(FIRM_DIR) build-all

fw-clean:
	make -C $(FIRM_DIR) clean-all

fw-debug:
	make -C $(FIRM_DIR) debug

#
# EMULATE ON PC
#

#default baud and system clock frequency
SIM_BAUD ?= 2500000
SIM_FREQ ?=50000000
pc-emul-build:
	make fw-build BAUD=$(SIM_BAUD) FREQ=$(SIM_FREQ)
	make -C $(PC_DIR) BAUD=$(SIM_BAUD) FREQ=$(SIM_FREQ)

pc-emul-run: pc-emul-build
	make -C $(PC_DIR) run BAUD=$(SIM_BAUD) FREQ=$(SIM_FREQ)

pc-emul-clean: fw-clean
	make -C $(PC_DIR) clean

pc-emul-test: pc-emul-clean
	make -C $(PC_DIR) test BAUD=$(SIM_BAUD) FREQ=$(SIM_FREQ)

#
# SIMULATE RTL
#

sim-build:
	make fw-build BAUD=$(SIM_BAUD) FREQ=$(SIM_FREQ)
	make -C $(SIM_DIR) build BAUD=$(SIM_BAUD) FREQ=$(SIM_FREQ)

sim-run: sim-build
	make -C $(SIM_DIR) run

sim-clean: fw-clean
	make -C $(SIM_DIR) clean

sim-test:
	make -C $(SIM_DIR) test

sim-debug:
	make -C $(SIM_DIR) debug

#
# BUILD, LOAD AND RUN ON FPGA BOARD
#

#default baud and system clock freq for boards
BOARD_BAUD ?= 115200
#default board frequency
ifeq ($(BOARD), CYCLONEV-GT-DK)
BOARD_FREQ ?=50000000
else
BOARD_FREQ ?=100000000
endif

fpga-build:
	make fw-build BAUD=$(BOARD_BAUD) FREQ=$(BOARD_FREQ)
	make -C $(BOARD_DIR) build BAUD=$(BOARD_BAUD) FREQ=$(BOARD_FREQ) SHELL="$(SHELL)"

fpga-run: fpga-build
	make -C $(BOARD_DIR) run TEST_LOG="$(TEST_LOG)"

fpga-clean: fw-clean
	make -C $(BOARD_DIR) clean

fpga-veryclean:
	make -C $(BOARD_DIR) veryclean

fpga-debug:
	make -C $(BOARD_DIR) debug

fpga-test:
	make -C $(BOARD_DIR) test

#
# COMPILE DOCUMENTS
#

doc-build:
	make -C $(DOC_DIR) $(DOC).pdf

doc-clean:
	make -C $(DOC_DIR) clean

doc-test:
	make -C $(DOC_DIR) test

#
# CLEAN
#

clean: pc-emul-clean sim-clean fpga-clean doc-clean python-cache-clean

#
# TEST ALL PLATFORMS
#

test-pc-emul: pc-emul-test

test-pc-emul-clean: pc-emul-clean

test-sim:
	make sim-test SIMULATOR=verilator
	make sim-test SIMULATOR=icarus

test-sim-clean:
	make sim-clean SIMULATOR=verilator
	make sim-clean SIMULATOR=icarus

test-fpga:
	make fpga-test BOARD=CYCLONEV-GT-DK
	make fpga-test BOARD=AES-KU040-DB-G

test-fpga-clean:
	make fpga-clean BOARD=CYCLONEV-GT-DK
	make fpga-clean BOARD=AES-KU040-DB-G

test-doc:
	make fpga-clean BOARD=CYCLONEV-GT-DK
	make fpga-clean BOARD=AES-KU040-DB-G
	make fpga-build BOARD=CYCLONEV-GT-DK
	make fpga-build BOARD=AES-KU040-DB-G
	make doc-test DOC=pb
	make doc-test DOC=presentation

test-doc-clean:
	make doc-clean DOC=pb
	make doc-clean DOC=presentation

test: test-clean test-pc-emul test-sim test-fpga test-doc

test-clean: test-pc-emul-clean test-sim-clean test-fpga-clean test-doc-clean

python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune

debug:
	@echo $(UART_DIR)
	@echo $(CACHE_DIR)


.PHONY: fw-build fw-clean fw-debug\
	pc-emul-build pc-emul-run pc-emul-clean pc-emul-test \
	sim-build sim-run sim-clean sim-test sim-debug \
	fpga-build fpga-run fpga-clean fpga-test fpga-debug \
	doc-build doc-clean doc-test \
	clean \
	test-pc-emul test-pc-emul-clean \
	test-sim test-sim-clean \
	test-fpga test-fpga-clean \
	test-doc test-doc-clean \
	test test-clean \
	debug
