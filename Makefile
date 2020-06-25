ROOT_DIR:=.
include ./system.mk

sim: firmware boot
	make -C $(SIM_DIR) 

fpga: firmware boot
	make -C $(FPGA_DIR)

asic: boot
	make -C $(ASIC_DIR)

firmware:
	make -C $(FIRM_DIR)

boot:
	make -C $(BOOT_DIR)

doc:
	make -C $(DOC_DIR)

clean: 
	make -C $(SIM_DIR) clean
	make -C $(FPGA_DIR) clean
	make -C $(ASIC_DIR) clean
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(DOC_DIR) clean


.PHONY: sim fpga asic firmware boot doc clean
