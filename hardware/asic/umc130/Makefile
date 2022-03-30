ROOT_DIR:=../../..

# Memory technology
ASIC_MEM_TECH:=fsc0l_d

# Memories' types
ASIC_SPROM_TYPE:=SP
ASIC_DPRAM_TYPE:=SJ
ASIC_2PRAM_TYPE:=SZ
ASIC_SPRAM_TYPE:=SH

# Memories' simulation model files
ASIC_MEM_FILES=*LD130*.v

# SPROM files
ASIC_SPROM_DS=$(ASIC_SPROM_TYPE)*.ds
ASIC_SPROM_LEF=$(ASIC_SPROM_TYPE)*.lef
ASIC_SPROM_LIB=$(ASIC_SPROM_TYPE)*$(CASE).lib
ASIC_SPROM_SIM_MODEL=$(ASIC_SPROM_TYPE)*.v

# DPRAM files
ASIC_DPRAM_DS=$(ASIC_DPRAM_TYPE)*.ds
ASIC_DPRAM_LEF=$(ASIC_DPRAM_TYPE)*.lef
ASIC_DPRAM_LIB=$(ASIC_DPRAM_TYPE)*$(CASE).lib
ASIC_DPRAM_SIM_MODEL=$(ASIC_DPRAM_TYPE)*.v

# 2PRAM files
ASIC_2PRAM_DS=$(ASIC_2PRAM_TYPE)*.ds
ASIC_2PRAM_LEF=$(ASIC_2PRAM_TYPE)*.lef
ASIC_2PRAM_LIB=$(ASIC_2PRAM_TYPE)*$(CASE).lib
ASIC_2PRAM_SIM_MODEL=$(ASIC_2PRAM_TYPE)*.v

# SPRAM files
ASIC_SPRAM_DS=$(ASIC_SPRAM_TYPE)*.ds
ASIC_SPRAM_LEF=$(ASIC_SPRAM_TYPE)*.lef
ASIC_SPRAM_LIB=$(ASIC_SPRAM_TYPE)*$(CASE).lib
ASIC_SPRAM_SIM_MODEL=$(ASIC_SPRAM_TYPE)*.v

# Log and report files
ASIC_LOG=*.log
ASIC_REPORTS=*.txt

# Simulation libs
ASIC_LIBS=/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/verilog/fsc0l_d_generic_core_30.lib

ASIC_NODE=umc130
ASIC_SERVER=$(CADENCE_SERVER)
ASIC_USER=$(CADENCE_USER)

# Memories' wrappers
VSRC+=sp_rom_wrap.v dp_ram_wrap.v

ifeq ($(USE_DDR),1)
VSRC+=2p_ram_wrap.v sp_ram_wrap.v
endif

#RULES

all: synth sim-post-synth


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
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$@ .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_LOG) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_REPORTS) .
endif

include ../asic.mk

#
# Fix memories
#

fix-sprom: fix-lefs fix-sprom-sim-model

fix-dpram: fix-lefs fix-dpram-sim-model

fix-2pram: fix-lefs

fix-spram: fix-lefs

fix-lefs:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-sprom-sim-model:
	sed -i -E 's/(parameter *ROMCODE *= \").*(\";)/\1boot.hex\2/g' $(ASIC_SPROM_TYPE)LD130_$(BOOTROM_WORDS)X32BM1A.v
	sed -i -E "s/(readmemh\(ROMCODE,Memory)\)/\1,0,Words-1\)/g" $(ASIC_SPROM_TYPE)LD130_$(BOOTROM_WORDS)X32BM1A.v

fix-dpram-sim-model:
	sed -i "/endprotect/e cat verilog/initial_dp_ram.v" $(ASIC_DPRAM_TYPE)LD130_$(SRAM_WORDS)X8X4CM16.v


sp-rom: boot.hex
ifeq ($(ASIC_SERVER),)
	./rom.sh $(BOOTROM_WORDS)
	make fix-sprom
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPROM_SIM_MODEL) .
endif

dp-ram:
ifeq ($(ASIC_SERVER),)
	./ram.sh $(ASIC_DPRAM_TYPE) $(SRAM_WORDS) 8 4 16
	make fix-dpram
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_SIM_MODEL) .
endif

2p-ram:
ifeq ($(ASIC_SERVER),)
	./ram.sh $(ASIC_2PRAM_TYPE) 32 49 1 4
	./ram.sh $(ASIC_DPRAM_TYPE) 32 49 1 4
	./ram.sh $(ASIC_2PRAM_TYPE) 32 58 1 4
	./ram.sh $(ASIC_DPRAM_TYPE) 32 58 1 4
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_2PRAM_SIM_MODEL) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_DPRAM_SIM_MODEL) .
endif
	make fix-2pram

sp-ram:
ifeq ($(ASIC_SERVER),)
	./ram.sh $(ASIC_SPRAM_TYPE) 128 8 1 1
	./ram.sh $(ASIC_SPRAM_TYPE) 128 2 1 1
	./ram.sh $(ASIC_SPRAM_TYPE) 128 11 1 1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_DS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_LEF) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_LIB) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_SPRAM_SIM_MODEL) .
endif
	make fix-spram


sp_rom_wrap.v:
	$(MEM_DIR)/software/python/memwrapper.py  $(ASIC_MEM_TECH) iob_sp_rom $(ASIC_SPROM_TYPE) 1 $(BOOTROM_W) 32 1 > $@

dp_ram_wrap.v:
	$(MEM_DIR)/software/python/memwrapper.py $(ASIC_MEM_TECH) iob_dp_ram_be $(ASIC_DPRAM_TYPE) 0 1 1 $(SRAM_W) 8 4 16 > $@

2p_ram_wrap.v:
	$(MEM_DIR)/software/python/memwrapper.py $(ASIC_MEM_TECH) iob_2p_ram $(ASIC_2PRAM_TYPE) 0 0 2 5 49 1 4 5 58 1 4 > $@

sp_ram_wrap.v:
	$(MEM_DIR)/software/python/memwrapper.py $(ASIC_MEM_TECH) iob_sp_ram $(ASIC_SPRAM_TYPE) 0 3 7 8 1 1 7 2 1 1 7 11 1 1 > $@



#
# Clean
#

clean: clean-remote
	rm -rf *.txt rc.* fv libscore_work *.sdc *.lib *.lef *.ds
	find *.tcl -type f -not -name synscript.tcl -not -name powscript.tcl -delete

.PHONY: fix-sprom fix-dpram \
	fix-2pram fix-spram \
	fix-lefs \
	fix-sprom-sim-model fix-dpram-sim-model \
	clean
