#DEFINES

#default baud and freq for simulation
BAUD ?=5000000
FREQ ?=100000000

#define for testbench
DEFINE+=$(defmacro)BAUD=$(BAUD)
DEFINE+=$(defmacro)FREQ=$(FREQ)

#ddr controller address width
DDR_ADDR_W=$(FIRM_ADDR_W)

#produce waveform dump
VCD ?=0

ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

include $(SUT_DIR)/hardware/hardware.mk

#SOURCES
#asic post-synthesis and post-pr sources
ifeq ($(ASIC),1)
ifeq ($(SYNTH),1)
VSRC=$(ASIC_DIR)/system_synth.v
endif
VSRC+=$(wildcard $(ASIC_DIR)/$(ASIC_MEM_FILES))
endif

#ddr memory
VSRC+=$(CACHE_DIR)/submodules/AXIMEM/rtl/axi_ram.v
#testbench
VSRC+=system_tb.v

ALL_DEPENDENCIES=clean sw

ifeq ($(TESTER_ENABLED),1)
include $(TESTER_DIR)/simulation.mk
endif

#RULES
all: $(ALL_DEPENDENCIES)
ifeq ($(SIM_SERVER),)
	make run 
else
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_SUT_DIR) ]; then git clone --recursive $(GITURL) $(REMOTE_SUT_DIR); fi"
	rsync -avz --delete --exclude .git $(SUT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SUT_DIR)
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SUT_DIR)/hardware/simulation/$(SIMULATOR) run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) VCD=$(VCD) ASIC=$(ASIC) SYNTH=$(SYNTH) ASIC_MEM_FILES=$(ASIC_MEM_FILES) LIBS=$(LIBS) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SUT_DIR)/hardware/simulation/$(SIMULATOR)/test.log $(SIM_DIR)
endif
ifeq ($(VCD),1)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SUT_DIR)/hardware/simulation/$(SIMULATOR)/*.vcd $(SIM_DIR)
endif
endif
ifeq ($(VCD),1)
	if [ "`pgrep -u $(USER) gtkwave`" ]; then killall -q -9 gtkwave; fi
	gtkwave -a ../waves.gtkw system.vcd &
endif


#create testbench
system_tb.v: $(TB_DIR)/system_core_tb.v
	python3 $(HW_DIR)/simulation/createTestbench.py $(SUT_DIR)

#What is this for?
#VSRC+=$(foreach p, $(PERIPH_INSTANCES), $(shell if test -f $($($p_CORENAME)_DIR)/hardware/testbench/module_tb.sv; then sed 's/\/\*<InstanceName>\*\//$p/g' $($($p_CORENAME)_DIR)/hardware/testbench/module_tb.sv; fi;)) #add test cores to list of sources

kill-remote-sim:
	@echo "INFO: Remote simulator $(SIMULATOR) will be killed"
	ssh $(SIM_USER)@$(SIM_SERVER) 'killall -q -u $(SIM_USER) -9 $(SIM_PROC)'


test: clean-testlog test1 test2 test3 test4 test5
	diff -q test.log test.expected

test1:
	make all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
test2:
	make all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"
test3:
	make all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"
test4:
	make all INIT_MEM=1 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"
test5:
	make all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"


#clean target common to all simulators
clean-remote: hw-clean 
	@rm -f system.vcd
ifneq ($(SIM_SERVER),)
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_SUT_DIR) ]; then git clone --recursive $(GITURL) $(REMOTE_SUT_DIR); fi"
	rsync -avz --delete --exclude .git $(SUT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SUT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SUT_DIR) sim-clean SIMULATOR=$(SIMULATOR)'
endif

#clean test log only when sim testing begins
clean-testlog:
	@rm -f test.log
ifneq ($(SIM_SERVER),)
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_SUT_DIR) ]; then git clone --recursive $(GITURL) $(REMOTE_SUT_DIR); fi"
	rsync -avz --delete --exclude .git $(SUT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SUT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'rm -f $(REMOTE_SUT_DIR)/hardware/simulation/$(SIMULATOR)/test.log'
endif



.PRECIOUS: system.vcd test.log

.PHONY: all \
	kill-remote-sim \
	test test1 test2 test3 test4 test5 \
	clean-remote clean-testlog
