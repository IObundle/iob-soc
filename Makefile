ROOT_DIR:=.
include ./system.mk

#
# EMULATE ON PC
#

pc-emul:
	make -C $(PC_DIR) all

#
# SIMULATE RTL
#

sim:
	make -C $(SIM_DIR) all


#
# RUN ON FPGA BOARD
#
run:
	make -C $(BOARD_DIR) all TEST_LOG="$(TEST_LOG)"

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
	make -C $(SIM_DIR) log-clean SIMULATOR=$(SIMULATOR)
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
	diff -q $(SIM_DIR)/test.log $(SIM_DIR)/test.expected
	@echo SIMULATOR $(SIMULATOR) TEST PASSED

test-all-simulators:
	$(foreach s, $(SIM_LIST), make test-simulator SIMULATOR=$s;)

all-simulators-clean:
	$(foreach s, $(SIM_LIST), make -C $(HW_DIR)/simulation/$s clean SIMULATOR=$s;)

test-board:
	make -C $(BOARD_DIR) BOARD=$(BOARD) log-clean
	make -C $(BOARD_DIR) BOARD=$(BOARD) board-clean
	make run BOARD=$(BOARD) INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make run BOARD=$(BOARD) INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
	make -C $(BOARD_DIR) board-clean
	make run BOARD=$(BOARD) INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
	diff -q $(CONSOLE_DIR)/test.log $(BOARD_DIR)/test.expected
	@echo BOARD $(BOARD) TEST PASSED

test-all-boards:
	$(foreach b, $(BOARD_LIST), make test-board BOARD=$b;)

all-boards-clean:
	$(foreach s, $(BOARD_LIST), make -C $(FPGA_DIR)/$s board-clean BOARD=$s;)

clean: 
	make -C $(PC_DIR) clean
	make -C $(ASIC_DIR) clean
	make -C $(DOC_DIR) clean
	make all-simulators-clean
	make all-boards-clean


.PHONY: pc-emul pc-clean sim sim-clean run run-clean asic asic-clean doc doc-clean test test-all-simulators test-simulator test-all-boards test-board clean
