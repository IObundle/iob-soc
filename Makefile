ROOT_DIR:=.
include ./system.mk

#
# SIMULATE RTL
#

sim:
	make -C $(SIM_DIR) all

sim-test:
	make -C $(SIM_DIR) test


sim-clean:
	make -C $(SIM_DIR) clean clean-testlog

#
# EMULATE ON PC
#

pc-emul:
	make -C $(PC_DIR) all

pc-emul-test:
	make -C $(PC_DIR) test

pc-emul-clean:
	make -C $(PC_DIR) clean

#
# BUILD, LOAD AND RUN ON FPGA BOARD
#

fpga-build:
	make -C $(BOARD_DIR) build

fpga-run:
	make -C $(BOARD_DIR) all TEST_LOG="$(TEST_LOG)"

fpga-test:
	make -C $(BOARD_DIR) test

fpga-clean:
	make -C $(BOARD_DIR) clean clean-testlog


#
# SYNTHESIZE AND SIMULATE ASIC
#

asic-synt:
	make -C $(ASIC_DIR) all

asic-sim-post-synt:
	make -C $(ASIC_DIR) all

#
# COMPILE DOCUMENTS
#
doc-build:
	make -C $(DOC_DIR) all

doc-test:
	make -C $(DOC_DIR) test

doc-clean:
	make -C $(DOC_DIR) clean


#
# TEST ON SIMULATORS AND BOARDS
#

test-pc-emul: pc-emul-test

test-pc-emul-clean: pc-emul-clean

test-sim:
	make sim-test SIMULATOR=xcelium
	make sim-test SIMULATOR=icarus

test-sim-clean:
	make sim-clean SIMULATOR=xcelium
	make sim-clean SIMULATOR=icarus

test-fpga:
	make fpga-test BOARD=CYCLONEV-GT-DK
	make fpga-test BOARD=AES-KU040-DB-G

test-fpga-clean:
	make fpga-clean BOARD=CYCLONEV-GT-DK
	make fpga-clean BOARD=AES-KU040-DB-G

test-doc:
	make doc-test DOC=pb
	make doc-test DOC=presentation

test-doc-clean:
	make doc-clean DOC=pb
	make doc-clean DOC=presentation

test: test-clean test-pc-emul test-sim test-fpga test-doc

test-clean: test-pc-emul-clean test-sim-clean test-fpga-clean test-doc-clean


#generic clean 
clean: 
	make pc-emul-clean
	make sim-clean
	make fpga-clean
	make doc-clean

clean-all: test-clean


.PHONY: pc-emul pc-emul-test pc-emul-clean \
	sim sim-test sim-clean\
	fpga-build fpga-run fpga-test fpga-clean\
	asic-synt asic-sim-post-synt\
	doc-build doc-test  doc-clean clean\
	test-pc-emul test-pc-emul-clean\
	test-sim test-sim-clean\
	test-fpga test-fpga-clean\
	test-doc test-doc-clean\
	test test-clean
	clean clean-all
