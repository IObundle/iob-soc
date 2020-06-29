ROOT_DIR:=.
include ./system.mk

run: sim

sim: firmware bootloader
	make -C $(SIM_DIR)

fpga: firmware bootloader
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(USER)@$(FPGA_COMPILE_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) compile"
	ssh $(USER)@$(FPGA_BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	ssh $(USER)@$(FPGA_COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); rsync -avz --exclude .git . $(USER)@$(FPGA_BOARD_SERVER):$(REMOTE_ROOT_DIR)"
	ssh $(USER)@$(FPGA_BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) load"

asic: bootloader
	make -C $(ASIC_DIR)

run-firmware:
	ssh $(USER)@$(FPGA_BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(USER)@$(FPGA_BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(USER)@$(FPGA_BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) run"

load-firmware: firmware
	ssh $(USER)@$(FPGA_BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(USER)@$(FPGA_BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(USER)@$(FPGA_BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) load"

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)

console:
	make -C $(CONSOLE_DIR)

document:
	make -C $(DOC_DIR)

clean: 
	make -C $(SIM_DIR) clean
	make -C $(FPGA_DIR) clean
	make -C $(ASIC_DIR) clean
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean
	make -C $(DOC_DIR) clean


.PHONY: sim fpga asic firmware bootloader document clean
