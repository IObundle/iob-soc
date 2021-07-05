all: sim


ROOT_DIR:=.
include ./system.mk

#
# SIMULATE RTL
#

sim:
	make -C $(SIM_DIR) all


#
# EMULATE ON PC
#

pc-emul:
	make -C $(PC_DIR) all

#
# RUN ON FPGA BOARD
#
run:
	make -C $(BOARD_DIR) all TEST_LOG="$(TEST_LOG)"

#
# SIMULATE POST-SYNTHESIS ASIC
#

asic:
	make -C $(ASIC_DIR) all

#
# COMPILE DOCUMENTS
#
doc:
	make -C $(DOC_DIR)


#
# TEST ON SIMULATORS AND BOARDS
#

test: test-all-simulators test-all-boards

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
	$(foreach s, $(BOARD_LIST), make -C $(FPGA_DIR)/$s clean-all BOARD=$s;)

clean: 
	make -C $(PC_DIR) clean
	make -C $(ASIC_DIR) clean
	make -C $(DOC_DIR) clean
	make clean-all-simulators
	make clean-all-boards


.PHONY: all pc-emul sim run asic doc test test-all-simulators test-simulator test-all-boards test-board clean-all-simulators clean-all-boards clean
