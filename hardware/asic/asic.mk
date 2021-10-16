#DEFINES

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=24

include $(ROOT_DIR)/hardware/hardware.mk

CASE=TC

# Memory sizes in log2
BOOTROM_W:=$(shell echo '$(BOOTROM_ADDR_W)-2' | bc)
SRAM_W:=$(shell echo '$(SRAM_ADDR_W)-2' | bc)

BOOTROM_WORDS:=$(shell echo '2^($(BOOTROM_W))' | bc)
SRAM_WORDS:=$(shell echo '2^($(SRAM_W))' | bc)

# Memories' wrappers
VSRC+=bootrom.v sram.v

#RULES

all: mems synth

#
# Memories
#

mems: bootrom sram
ifneq ($(ASIC_SERVER),)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_LEFS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_LIBS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_SIM_MODELS) .
endif
	make fix-mems

bootrom: sw gen-bootrom

sram: gen-sram

rom.v: *$(CASE).lib
	$(MEM_DIR)/software/python/memwrapper_make.py fsc0l_d sp $(BOOTROM_W) 32 1 > rom.v

sram.v: $(SRAM_DIR)/*$(CASE).lib
	$(MEM_DIR)/software/python/memwrapper_make.py fsc0l_d sj 0 1 $(SRAM_W) 8 4 1 > sram.v

#
# Synthesis
#

synth: system_synth.v

#
# Testing
#

test: clean-testlog test1
	diff -q $(HW_DIR)/simulation/xcelium/test.log test.expected

test1: clean
	make all ASIC_NODE=$(ASIC_NODE) TEST_LOG=">> test.log";

#
# Clean
#

clean-remote: hw-clean
	@rm -f $(ASIC_MEM_LEFS) $(ASIC_MEM_LIBS) $(ASIC_MEM_SIM_MODELS)
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

#clean test log only when asic testing begins
clean-testlog:
	@rm -f test.log
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

.PHONY: all \
	mems bootrom sram \
	synth \
	test test1 \
	clean-remote clean-testlog
