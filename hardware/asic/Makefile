ROOT_DIR:=../..
ASIC_SERVER=$(CADENCE_SERVER)
ASIC_USER=$(CADENCE_USER)
FREQ:=100000000

include $(ROOT_DIR)/hardware/hardware.mk

all: mem synth sim-synth

mem: sw
ifeq ($(ASIC_SERVER),)
	make -C $(ASIC_DIR)/$(ASIC_NODE) mem
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic; make mem INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
endif

synth:
ifeq ($(ASIC_SERVER),)
	make -C $(ASIC_DIR)/$(ASIC_NODE) synth ASIC_MEM=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic; make synth INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC_MEM=1'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/synth/*.txt $(ASIC_DIR)/$(ASIC_NODE)/synth
endif

sim-synth: sw
ifeq ($(ASIC_SERVER),)
	make -C $(HW_DIR)/simulation/xmsim run LOG=$(TEST_LOG) SYNTH=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/asic; make sim-synth INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) TEST_LOG=$(TEST_LOG) VCD=$(VCD) BAUD=$(BAUD) SYNTH=1'
ifneq ($(TEST_LOG),)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(HW_DIR)/simulation/xmsim/test.log $(HW_DIR)/simulation/xmsim
endif
ifeq ($(VCD),1)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(HW_DIR)/simulation/xmsim/*.vcd $(HW_DIR)/simulation/xmsim
endif
endif

clean:
	make -C $(ASIC_DIR)/$(ASIC_NODE) clean
ifneq ($(ASIC_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR)/hardware/asic; make clean; fi'
endif

.PHONY: all mem synth sim-synth clean
