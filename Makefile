ROOT_DIR:=.
include ./system.mk

run: sim

sim: firmware bootloader
ifeq ($(SIMULATOR),ncsim)
	ssh $(MICRO_USER)@$(SIM_SERVER) "if [ ! -d $(MICRO_ROOT_DIR) ]; then mkdir -p $(MICRO_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(MICRO_USER)@$(SIM_SERVER):$(MICRO_ROOT_DIR) 
	ssh $(MICRO_USER)@$(SIM_SERVER) "cd $(MICRO_ROOT_DIR); make -C $(SIM_DIR)"
else
	make -C $(SIM_DIR)
endif

fpga: firmware bootloader
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(USER)@$(FPGA_COMPILE_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) compile"


fpga-load: fpga
	ssh $(USER)@$(FPGA_BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); rsync -avz --exclude .git . $(USER)@$(FPGA_BOARD_SERVER):$(REMOTE_ROOT_DIR)"
	ssh $(USER)@$(FPGA_BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) load"


fpga-clean:
	ssh $(USER)@$(FPGA_BOARD_SERVER) "if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"

fpga-clean-ip: fpga-clean
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean-ip; fi"

asic: bootloader
	ssh $(MICRO_USER)@$(ASIC_SERVER) "if [ ! -d $(MICRO_ROOT_DIR) ]; then mkdir -p $(MICRO_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(MICRO_USER)@$(ASIC_SERVER):$(MICRO_ROOT_DIR) 
	ssh $(MICRO_USER)@$(ASIC_SERVER) "cd $(MICRO_ROOT_DIR); make -C $(ASIC_DIR)"

asic-clean:
	rsync -avz --exclude .git . $(MICRO_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(MICRO_USER)@$(ASIC_SERVER) "cd $(MICRO_ROOT_DIR); make -C $(ASIC_DIR) clean"

run-firmware:
	ssh $(USER)@$(FPGA_BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(USER)@$(FPGA_BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(USER)@$(FPGA_BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) run"

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)

document:
	make -C $(DOC_DIR)

clean: 
ifeq ($(SIMULATOR),ncsim)
	ssh $(MICRO_USER)@$(SIM_SERVER) "cd $(MICRO_ROOT_DIR); make -C $(SIM_DIR) clean"
else
	make -C $(SIM_DIR) clean
endif
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(DOC_DIR) clean


.PHONY: sim fpga firmware bootloader document clean fpga-load fpga-clean fpga-clen-ip asic asic-clean
