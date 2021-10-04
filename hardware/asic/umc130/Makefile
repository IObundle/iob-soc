ROOT_DIR:=../../..

ASIC_SERVER=$(CADE_SERVER)
ASIC_USER=$(CADE_USER)

include ../asic.mk

all: mem

mem:
ifeq ($(ASIC_SERVER),)
	make -C memory/bootrom run
	make -C memory/sram run
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make asic-mem ASIC_NODE=$(ASIC_NODE)'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/memory/bootrom/*.lef memory/bootrom/
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/memory/sram/*.lef memory/sram/
endif

clean:
	make -C memory/bootrom clean
	make -C memory/sram clean
ifneq ($(ASIC_SERVER),)
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make asic-clean ASIC_NODE=$(ASIC_NODE)'
endif

.PHONY: all mem clean
