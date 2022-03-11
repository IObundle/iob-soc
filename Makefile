ROOT_DIR:=.
include ./config.mk

.PHONY: sim sim-test sim-clean\
	pc-emul pc-emul-test pc-emul-clean\
	fpga-build fpga-build-all fpga-run fpga-test fpga-clean fpga-clean-all\
	asic-synth asic-sim-post-synth asic-test asic-clean\
	doc-build doc-build-all doc-test doc-clean doc-clean-all\
	test-pc-emul test-pc-emul-clean\
	test-sim test-sim-clean\
	test-fpga test-fpga-clean\
	test-asic test-asic-clean\
	test-doc test-doc-clean\
	test test-clean\
	clean clean-all\
	debug

#
# SIMULATE RTL
#

sim:
	make -C $(SIM_DIR) all

sim-test:
	make -C $(SIM_DIR) test

sim-clean:
	make -C $(SIM_DIR) clean-all

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

fpga-build-all:
	make fpga-build BOARD=CYCLONEV-GT-DK
	make fpga-build BOARD=AES-KU040-DB-G

fpga-run:
	make -C $(BOARD_DIR) all TEST_LOG="$(TEST_LOG)"

fpga-test:
	make -C $(BOARD_DIR) test

fpga-clean:
	make -C $(BOARD_DIR) clean-all

fpga-clean-all:
	make fpga-clean BOARD=CYCLONEV-GT-DK
	make fpga-clean BOARD=AES-KU040-DB-G


#
# SYNTHESIZE AND SIMULATE ASIC
#

asic-synth:
	make -C $(ASIC_DIR) synth

asic-sim-post-synth:
	make -C $(ASIC_DIR) all TEST_LOG="$(TEST_LOG)"

asic-test:
	make -C $(ASIC_DIR) test

asic-clean:
	make -C $(ASIC_DIR) clean-all

#
# COMPILE DOCUMENTS
#
doc-build:
	make -C $(DOC_DIR) $(DOC).pdf

doc-build-all:
	make fpga-clean-all
	make fpga-build-all
	make doc-build DOC=presentation
	make doc-build DOC=pb

doc-test:
	make -C $(DOC_DIR) test

doc-clean:
	make -C $(DOC_DIR) clean

doc-clean-all:
	make doc-clean DOC=presentation
	make doc-clean DOC=pb


#
# TEST ON SIMULATORS AND BOARDS
#

test-pc-emul: pc-emul-test

test-pc-emul-clean: pc-emul-clean

test-sim:
	make sim-test SIMULATOR=verilator
#	make sim-test SIMULATOR=xcelium
	make sim-test SIMULATOR=icarus

test-sim-clean:
	make sim-clean SIMULATOR=verilator
#	make sim-clean SIMULATOR=xcelium
	make sim-clean SIMULATOR=icarus

test-fpga:
	make fpga-test BOARD=CYCLONEV-GT-DK
	make fpga-test BOARD=AES-KU040-DB-G

test-fpga-clean:
	make fpga-clean BOARD=CYCLONEV-GT-DK
	make fpga-clean BOARD=AES-KU040-DB-G

test-asic:
	make asic-test ASIC_NODE=umc130
	make asic-test ASIC_NODE=skywater

test-asic-clean:
	make asic-clean ASIC_NODE=umc130
	make asic-clean ASIC_NODE=skywater

test-doc:
	make fpga-clean-all
	make fpga-build-all
	make doc-test DOC=pb
	make doc-test DOC=presentation

test-doc-clean:
	make doc-clean DOC=pb
	make doc-clean DOC=presentation

test: test-clean test-pc-emul test-sim test-fpga test-doc

test-clean: test-pc-emul-clean test-sim-clean test-fpga-clean test-doc-clean


#generic clean
clean: pc-emul-clean sim-clean fpga-clean doc-clean

clean-all: test-clean


debug:
	@echo $(UART_DIR)
	@echo $(CACHE_DIR)
