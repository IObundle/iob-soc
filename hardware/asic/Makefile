
#
# COMPILE ASIC (WIP)
#
ROOT_DIR:=../..
include ../hardware.mk

asic: clean
	make -C $(FIRM_DIR) run BAUD=$(HW_BAUD)
	make -C $(BOOT_DIR) run BAUD=$(HW_BAUD)
ifeq ($(ASIC_SERVER),)
	make -C $(ASIC_DIR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC=1'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(ASIC_DIR)/synth/*.txt $(ASIC_DIR)/synth
endif

asic-mem:
	make -C $(BOOT_DIR) run BAUD=$(HW_BAUD)
ifeq ($(ASIC_SERVER),)
	make -C $(ASIC_DIR) mem INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) mem INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC=1'
endif

asic-synth:
ifeq ($(ASIC_SERVER),)
	make -C $(ASIC_DIR) synth INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) synth INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) ASIC=1'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(ASIC_DIR)/synth/*.txt $(ASIC_DIR)/synth
endif

asic-sim-synth: sim-clean
	make -C $(FIRM_DIR) run BAUD=$(SIM_BAUD)
	make -C $(BOOT_DIR) run BAUD=$(SIM_BAUD)
ifeq ($(ASIC_SERVER),)
	make -C $(HW_DIR)/simulation/ncsim run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) TEST_LOG=$(TEST_LOG) VCD=$(VCD) BAUD=$(SIM_BAUD) SYNTH=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(HW_DIR)/simulation/ncsim run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) TEST_LOG=$(TEST_LOG) VCD=$(VCD) BAUD=$(SIM_BAUD) SYNTH=1'
ifeq ($(TEST_LOG),1)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(HW_DIR)/simulation/ncsim/test.log $(HW_DIR)/simulation/ncsim
endif
ifeq ($(VCD),1)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(HW_DIR)/simulation/ncsim/*.vcd $(HW_DIR)/simulation/ncsim
endif
endif

clean: 
	make -C $(ASIC_DIR)/$(ASIC_NODE) clean
ifneq ($(ASIC_SERVER),)
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) clean; fi'
endif

