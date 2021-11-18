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
VSRC+=sp_rom_wrap.v dp_ram_wrap.v

# Behaveral memories
MEMS=sp-rom dp-ram

ifeq ($(USE_DDR),1)
VSRC+=2p_ram_wrap.v sp_ram_wrap.v
MEMS+=2p-ram sp-ram
endif

#RULES

all: synth sim-post-synth

#
# Memories
#

mems: sw $(MEMS)

#
# Synthesis
#

synth: mems system_synth.v

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
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$@ .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_LOG) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_REPORTS) .
endif

#
# Simulation
#

sim-post-synth:
	make -C $(HW_DIR)/simulation/xcelium all INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) VCD=$(VCD) TEST_LOG="$(TEST_LOG)" ASIC=1 SYNTH=1 ASIC_MEM_FILES=$(ASIC_MEM_FILES) LIBS=$(ASIC_LIBS)

#
# Testing
#

test: clean-testlog test1 test2 test3
	diff -q $(HW_DIR)/simulation/xcelium/test.log test.expected

test1:
	make clean
	make all INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"

test2:
	make all INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"

test3:
	make clean
	make all INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"

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
	mems synth \
	sp-rom dp-ram 2p-ram sp-ram \
	sim-post-synth \
	test test1 test2 test3 \
	clean-remote clean-testlog
