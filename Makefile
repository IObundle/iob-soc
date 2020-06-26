ROOT_DIR:=.
include ./system.mk

sim: firmware bootloader
	make -C $(SIM_DIR) 

fpga: firmware bootloader
	make -C $(FPGA_DIR)

asic: bootloader
	make -C $(ASIC_DIR)

firmware:
	make -C $(FIRM_DIR)

bootloader: firmware
	make -C $(BOOT_DIR)

document:
	make -C $(DOC_DIR)

clean: 
	make -C $(SIM_DIR) clean
	make -C $(FPGA_DIR) clean
	make -C $(ASIC_DIR) clean
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(DOC_DIR) clean


.PHONY: sim fpga asic firmware bootloader doc clean
