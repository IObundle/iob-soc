ROOT_DIR:=../../..

ASIC_MEM_LEFS=*.lef
ASIC_MEM_LIBS=*$(CASE).lib
ASIC_MEM_SIM_MODELS=*LD130*.v

ASIC_SERVER=$(CADE_SERVER)
ASIC_USER=$(CADE_USER)

include ../asic.mk

#
# Memories
#

gen-bootrom: boot.hex
ifeq ($(ASIC_SERVER),)
	./bootrom.sh $(BOOTROM_WORDS)
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

gen-sram:
ifeq ($(ASIC_SERVER),)
	./sram.sh $(SRAM_WORDS)
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

fix-mems: fix-lefs fix-bootrom-sim-model fix-sram-sim-model

fix-lefs:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-bootrom-sim-model:
	sed -i -E 's/(parameter *ROMCODE *= \").*(\";)/\1boot.hex\2/g' SP*.v
	sed -i -E "s/(readmemh\(ROMCODE,Memory)/\1,0,Words-1/g" SP*.v

fix-sram-sim-model:
	sed -i "/endprotect/e cat initial.v" SJ*.v

#
# Synthesis
#

system_synth.v: $(VHDR) $(VSRC)
ifeq ($(ASIC_SERVER),)
	./synth.sh
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

#
# Clean
#

clean:
	@rm -rf *~ *.hex *.txt rc.cmd* rc.* fv libscore_work *.sdc *.h *.lib *.lef *.db
	@find *.tcl -type f -not -name synscript.tcl -not -name powscript.tcl -delete
	@find *.v -type f -not -name initial.v -delete
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

.PHONY: gen-bootrom gen-sram \
	fix-mems fix-lefs fix-bootrom-sim-model fix-sram-sim-model \
	clean
