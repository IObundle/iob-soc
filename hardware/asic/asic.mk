#DEFINES
ASIC=1

CASE=TC

#ddr controller address width
DDR_ADDR_W=24

include $(ROOT_DIR)/hardware/hardware.mk

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

mems: sw bootrom sram
ifneq ($(ASIC_SERVER),)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_LEFS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_LIBS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_SIM_MODELS) .
endif
	make fix-mems

bootrom: boot.hex
ifeq ($(ASIC_SERVER),)
	./bootrom.sh $(BOOTROM_WORDS)
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

sram:
ifeq ($(ASIC_SERVER),)
	./sram.sh $(SRAM_WORDS)
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

bootrom.v:
	$(MEM_DIR)/software/python/memakerwrap.py fsc0l_d iob_sp_rom sp $(BOOTROM_W) 32 1 > $@

sram.v:
	$(MEM_DIR)/software/python/memakerwrap.py fsc0l_d iob_dp_ram_be sj 0 1 $(SRAM_W) 8 4 16 > $@

#
# Synthesis
#

synth: system_synth.v

system_synth.v: $(VHDR) $(VSRC)
ifeq ($(ASIC_SERVER),)
	echo "set INCLUDE [list $(INCLUDE)]" > inc.tcl
	echo "set DEFINE [list $(DEFINE)]" > defs.tcl
	echo "set VSRC [list $(VSRC)]" > vsrc.tcl
	echo "set CASE $(CASE)" > case.tcl
	./synth.sh
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$@ .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_LOG) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_REPORTS) .
endif

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
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make clean'
endif

#clean test log only when asic testing begins
clean-testlog:
	@rm -f test.log
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
endif

.PHONY: all \
	mems bootrom sram \
	synth \
	test test1 \
	clean-remote clean-testlog
