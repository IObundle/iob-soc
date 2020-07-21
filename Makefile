ROOT_DIR:=.
include ./system.mk

run: sim

sim: firmware bootloader
ifeq ($(SIM_SERVER),)
	make -C $(SIM_DIR)
else
	ssh $(SIM_SERVER) "if [ ! -d $(SIM_ROOT_DIR) ]; then mkdir -p $(SIM_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(SIM_SERVER):$(SIM_ROOT_DIR) 
	ssh $(SIM_SERVER) "cd $(SIM_ROOT_DIR); make -C $(SIM_DIR)"
endif

fpga: firmware bootloader
	ssh $(FPGA_COMPILE_SERVER) "if [ ! -d $(FPGA_COMPILE_ROOT_DIR) ]; then mkdir -p $(FPGA_COMPILE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(FPGA_COMPILE_SERVER):$(FPGA_COMPILE_ROOT_DIR) 
	ssh $(FPGA_COMPILE_SERVER) "cd $(FPGA_COMPILE_ROOT_DIR); make -C $(FPGA_DIR) compile"

fpga-load: fpga
	ssh $(FPGA_BOARD_SERVER) "if [ ! -d $(FPGA_BOARD_ROOT_DIR) ]; then mkdir -p $(FPGA_BOARD_ROOT_DIR); fi"
	ssh $(FPGA_COMPILE_SERVER) "cd $(FPGA_COMPILE_ROOT_DIR); rsync -avz --exclude .git . $(FPGA_BOARD_SERVER):$(FPGA_BOARD_ROOT_DIR)"
	ssh $(FPGA_BOARD_SERVER) "cd $(FPGA_BOARD_ROOT_DIR); make -C $(FPGA_DIR) load"

fpga-clean: clean
	ssh $(FPGA_BOARD_SERVER) "if [ -d $(FPGA_BOARD_ROOT_DIR) ]; then cd $(FPGA_BOARD_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"
	ssh $(FPGA_COMPILE_SERVER) "if [ -d $(FPGA_COMPILE_ROOT_DIR) ]; then cd $(FPGA_COMPILE_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"

fpga-clean-ip: fpga-clean
	ssh $(FPGA_COMPILE_SERVER) "if [ -d $(FPGA_COMPILE_ROOT_DIR) ]; then cd $(FPGA_COMPILE_ROOT_DIR); make -C $(FPGA_DIR) clean-ip; fi"

asic: bootloader
	ssh -C -Y $(ASIC_COMPILE_SERVER) "if [ ! -d $(ASIC_COMPILE_ROOT_DIR) ]; then mkdir -p $(ASIC_COMPILE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(ASIC_SERVER):$(MICRO_ROOT_DIR) 
	ssh -C -Y $(ASIC_COMPILE_SERVER) "cd $(ASIC_COMPILE_ROOT_DIR); make -C $(ASIC_DIR)"

asic-clean:
	rsync -avz --exclude .git . $(ASIC_SERVER):$(ASIC_COMPILE_ROOT_DIR) 
	ssh $(ASIC_COMPILE_SERVER) "cd $(ASIC_COMPILE_ROOT_DIR); make -C $(ASIC_DIR) clean"

run-firmware: firmware
	ssh $(FPGA_BOARD_SERVER) "if [ ! -d $(FPGA_BOARD_ROOT_DIR) ]; then mkdir -p $(FPGA_BOARD_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(FPGA_BOARD_SERVER):$(FPGA_BOARD_ROOT_DIR) 
	ssh $(FPGA_BOARD_SERVER) "cd $(FPGA_BOARD_ROOT_DIR); make -C $(CONSOLE_DIR) run"

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)

document:
	make -C $(DOC_DIR)

waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd

clean: 
ifeq ($(SIMULATOR),ncsim)
	ssh $(SIM_SERVER) "cd $(MICRO_ROOT_DIR); make -C $(SIM_DIR) clean"
else
	make -C $(SIM_DIR) clean
endif
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(DOC_DIR) clean

.PHONY: sim fpga firmware bootloader document clean fpga-load fpga-clean fpga-clean-ip asic asic-clean run-firmware waves
