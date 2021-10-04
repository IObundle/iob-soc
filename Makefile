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

asic-mem:
	make -C $(ASIC_DIR) mem

asic-synth:
	make -C $(ASIC_DIR) synth

asic-sim-post-synth:
	make -C $(ASIC_DIR) sim

asic-clean:
	make -C $(ASIC_DIR) clean

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
	make test-pc-emul;\
	make test-all-simulators;\
	make test-all-boards;\
	make test-all-docs;\

test-pc-emul:
	@make -C $(PC_DIR) all TEST_LOG="> test.log";\
	diff -q $(PC_DIR)/test.log $(PC_DIR)/test.expected

test-simulator:
	@make -C $(SIM_DIR) clean-testlog;\
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log";\
	make -C $(SIM_DIR) all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log";\
	diff -q $(SIM_DIR)/test.log $(SIM_DIR)/test.expected

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
	diff -q $(CONSOLE_DIR)/test.log $(BOARD_DIR)/test.expected

test-all-boards:
	$(foreach b, $(BOARD_LIST), make test-board BOARD=$b;)

clean-all-boards:
	$(foreach s, $(BOARD_LIST), make -C $(BOARD_DIR) clean BOARD=$s;)

test-doc:
	@make -C $(DOC_DIR) clean;\
	make -C $(DOC_DIR) all DOC=$(DOC);\
	diff -q $(DOC_DIR)/$(DOC).aux $(DOC_DIR)/$(DOC).expected

test-all-docs:
	$(foreach b, $(DOC_LIST), make test-doc DOC=$b;)

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
	sim sim-clean \
	fpga-all fpga-run fpga-build fpga-clean \
	asic-mem asic-synth asic-sim-post-synth asic-clean \
	doc doc-clean \
	test test-all-simulators test-simulator test-all-boards test-board \
	clean-all-simulators clean-all-boards clean
