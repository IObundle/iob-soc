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
BE_MEMS=sp_rom_be.v dp_ram_be.v

ifeq ($(USE_DDR),1)
VSRC+=2p_ram_wrap.v sp_ram_wrap.v
BE_MEMS+=2p_ram_be.v sp_ram_be.v
endif

#RULES

all: synth sim-post-synth

#
# Memories
#

mems: sw $(BE_MEMS)

sp_rom_be.v: boot.hex
ifeq ($(ASIC_SERVER),)
	./rom.sh $(BOOTROM_WORDS)
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_SIM_MODEL) .
endif
	cp $(ASIC_SPROM_SIM_MODEL) $@
	make fix-sprom

dp_ram_be.v:
ifeq ($(ASIC_SERVER),)
	./ram.sh $(ASIC_DPRAM_TYPE) $(SRAM_WORDS) 8 4 16
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_SIM_MODEL) .
endif
	cp $(ASIC_DPRAM_SIM_MODEL) $@
	make fix-dpram

2p_ram_be.v:
ifeq ($(ASIC_SERVER),)
	./ram.sh $(ASIC_2PRAM_TYPE) 32 49 1 2
	./ram.sh $(ASIC_2PRAM_TYPE) 32 58 1 2
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_SIM_MODEL) .
endif
	cp $(ASIC_DPRAM_SIM_MODEL) $@
	make fix-2pram

sp_ram_be.v:
ifeq ($(ASIC_SERVER),)
	./ram.sh $(ASIC_SPRAM_TYPE) 128 8 1 1
	./ram.sh $(ASIC_SPRAM_TYPE) 128 2 1 1
	./ram.sh $(ASIC_SPRAM_TYPE) 128 11 1 1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_SIM_MODEL) .
endif
	cp $(ASIC_DPRAM_SIM_MODEL) $@
	make fix-spram

sp_rom_wrap.v:
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_sp_rom $(ASIC_SPROM_TYPE) $(BOOTROM_W) 32 1 > $@

dp_ram_wrap.v:
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_dp_ram_be $(ASIC_DPRAM_TYPE) 0 1 $(SRAM_W) 8 4 16 > $@

2p_ram_wrap.v:
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_2p_ram $(ASIC_2PRAM_TYPE) 0 2 5 49 1 2 5 58 1 2 > $@

sp_ram_wrap.v:
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_sp_ram $(ASIC_SPRAM_TYPE) 0 3 7 8 1 1 7 2 1 1 7 11 1 1 > $@

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
	make -C $(HW_DIR)/simulation/xcelium all INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) VCD=$(VCD) TEST_LOG="$(TEST_LOG)" ASIC=1 SYNTH=1 LIBS=$(ASIC_LIBS)

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
	sim-post-synth \
	test test1 test2 test3 \
	clean-remote clean-testlog
