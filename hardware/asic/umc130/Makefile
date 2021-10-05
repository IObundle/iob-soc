ROOT_DIR:=../../..

ASIC_MEMS=*.lef

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
	@find *.v -type f -not -name initial.v
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE); make $@ ASIC_NODE=$(ASIC_NODE)'
endif

.PHONY: gen-bootrom gen-sram clean
