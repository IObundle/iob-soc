all: sim


ROOT_DIR:=.
include ./system.mk

#
# SIMULATE RTL
#

sim:
	make -C $(SIM_DIR) all

sim-clean:
	make -C $(SIM_DIR) clean clean-testlog

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

fpga-run:
	make -C $(BOARD_DIR) all TEST_LOG="$(TEST_LOG)"

fpga-build:
	make -C $(BOARD_DIR) build

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
doc:
	make -C $(DOC_DIR) all

doc-clean:
	make -C $(DOC_DIR) clean


#
# TEST ON SIMULATORS AND BOARDS
#

test:
	@echo TEST REPORT `date`> test_report.log;\
	make test-pc-emul;\
	make test-all-simulators;\
	make test-all-boards;\
	make test-all-docs;\
	echo TEST FINISHED `date`>> test_report.log

test-pc-emul:
	@make -C $(PC_DIR) all TEST_LOG="> test.log";\
	if [ "`diff -q $(PC_DIR)/test.log $(PC_DIR)/test.expected`" ]; then \
	echo PC EMULATION TEST FAILED; else \
	echo PC EMULATION TEST PASSED; fi >> test_report.log


test-simulator:
	@make -C $(SIM_DIR) clean-testlog;\
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log";\
	if [ "`diff -q $(SIM_DIR)/test.log $(SIM_DIR)/test.expected`" ]; then \
	echo SIMULATOR $(SIMULATOR) TEST FAILED; else \
	echo SIMULATOR $(SIMULATOR) TEST PASSED; fi >> test_report.log

test-all-simulators:
	$(foreach s, $(SIM_LIST), make test-simulator SIMULATOR=$s;)

clean-all-simulators:
	$(foreach s, $(SIM_LIST), make -C $(HW_DIR)/simulation/$s clean clean-testlog SIMULATOR=$s;)

test-board:
	@make -C $(BOARD_DIR) clean-testlog;\
	make -C $(BOARD_DIR) clean;\
	make -C $(BOARD_DIR) all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(BOARD_DIR) all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(BOARD_DIR) clean;\
	make -C $(BOARD_DIR) all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log";\
	if [ "`diff -q $(CONSOLE_DIR)/test.log $(BOARD_DIR)/test.expected`" ]; then \
	echo BOARD $(BOARD) TEST FAILED; else \
	echo BOARD $(BOARD) TEST PASSED; fi >> test_report.log

test-all-boards:
	$(foreach b, $(BOARD_LIST), make test-board BOARD=$b;)

clean-all-boards:
	$(foreach s, $(BOARD_LIST), make -C $(BOARD_DIR) clean BOARD=$s;)

test-doc:
	@make -C $(DOC_DIR) clean;\
	make -C $(DOC_DIR) all DOC=$(DOC);\
	if [ "`diff -q $(DOC_DIR)/$(DOC).aux $(DOC_DIR)/$(DOC).expected`" ]; then \
	echo DOC $(DOC) TEST FAILED; else \
	echo DOC $(DOC) TEST PASSED; fi >> test_report.log

test-all-docs:
	$(foreach b, $(DOC_LIST), make test-doc DOC=$b;)

clean-all-docs:
	$(foreach s, $(DOC_LIST), make -C document/$s clean DOC=$s;)


clean: 
	make -C $(PC_DIR) clean
#	make -C $(ASIC_DIR) clean
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
