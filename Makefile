all: sim


ROOT_DIR:=.
include ./system.mk

#
# SIMULATE RTL
#

sim:
	make -C $(SIM_DIR) all

sim-clean:
	make -C $(SIM_DIR) clean

#
# EMULATE ON PC
#

pc-emul:
	make -C $(PC_DIR) all

pc-emul-clean:
	make -C $(PC_DIR) clean

#
# BUILD, LOAD AND RUN ON FPGA BOARD
#

fpga-all:
	make -C $(BOARD_DIR) all TEST_LOG="$(TEST_LOG)"

fpga-run:
	make -C $(BOARD_DIR) load
	make -C $(BOARD_DIR) run TEST_LOG="$(TEST_LOG)"

fpga-build:
	make -C $(BOARD_DIR) build

fpga-clean:
	make -C $(BOARD_DIR) clean-all


#
# BUILD AND SIMULATE ASIC
#

asic-synt:
	make -C $(ASIC_DIR) all

asic-sim-post-synt:
	make -C $(ASIC_DIR) all

#
# COMPILE DOCUMENTS
#
doc:
	make -C $(DOC_DIR) $(DOC).pdf

doc-clean:
	make -C $(DOC_DIR) clean


#
# TEST ON SIMULATORS AND BOARDS
#

test: test-all-simulators test-all-boards test-all-docs
	@echo ALL TESTS PASSED

test-simulator:
	make -C $(SIM_DIR) testlog-clean
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make -C $(SIM_DIR) all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
	make -C $(SIM_DIR) all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
	diff -q $(SIM_DIR)/test.log $(SIM_DIR)/test.expected
	@echo SIMULATOR $(SIMULATOR) TEST PASSED

test-all-simulators:
	$(foreach s, $(SIM_LIST), make test-simulator SIMULATOR=$s;)

clean-all-simulators:
	$(foreach s, $(SIM_LIST), make -C $(HW_DIR)/simulation/$s clean-all SIMULATOR=$s;)

test-board:
	make -C $(BOARD_DIR) testlog-clean
	make -C $(BOARD_DIR) clean
	make -C $(BOARD_DIR) all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make -C $(BOARD_DIR) all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make -C $(BOARD_DIR) clean
	make -C $(BOARD_DIR) all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
	diff -q $(CONSOLE_DIR)/test.log $(BOARD_DIR)/test.expected
	@echo BOARD $(BOARD) TEST PASSED

test-all-boards:
	$(foreach b, $(BOARD_LIST), make test-board BOARD=$b;)

clean-all-boards:
	$(foreach s, $(BOARD_LIST), make -C $(BOARD_DIR) clean-all BOARD=$s;)

test-doc:
	make -C $(DOC_DIR) clean
	make -C $(DOC_DIR) $(DOC).pdf
	diff -q $(DOC_DIR)/$(DOC).aux $(DOC_DIR)/$(DOC).expected

test-all-docs:
	$(foreach b, $(DOC_LIST), make test-doc DOC=$b;)
	@echo DOC TEST PASSED

clean-all-docs:
	$(foreach s, $(DOC_LIST), make -C document/$s clean DOC=$s;)


clean: 
	make -C $(PC_DIR) clean
	make -C $(ASIC_DIR) clean
	make -C $(DOC_DIR) clean
	make clean-all-simulators
	make clean-all-boards
	make clean-all-docs


.PHONY: all pc-emul pc-emul-clean \
	sim sim-clean\
	fpga-all fpga-run fpga-build fpga-clean\
	asic-synt asic-sim-post-synt
	doc doc-clean \
	test test-all-simulators test-simulator test-all-boards test-board\
	clean-all-simulators clean-all-boards clean
