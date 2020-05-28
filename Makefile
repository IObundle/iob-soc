include ./system.mk

sim:
	make -C $(SIM_DIR) 

fpga:
	make -C $(FPGA_DIR)

asic:
	make -C $(ASIC_DIR)

ld-hw:
	make -C $(FPGA_DIR) ld-hw

ld-sw:
	make -C software/ld-sw

clean: 
	make -C $(SIM_DIR) clean
	make -C  $(ASIC_DIR) clean
	make -C fpga/xilinx/AES-KU040-DB-G clean
	make -C fpga/intel/CYCLONEV-GT-DK clean
	make -C fpga/xilinx/SP605 clean


.PHONY: sim fpga asic ld-hw ld-sw clean
