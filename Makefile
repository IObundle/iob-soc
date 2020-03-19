SIM_DIR = simulation/icarus
#SIM_DIR = simulation/modelsim
#SIM_DIR = simulation/ncsim

#FPGA_DIR = fpga/xilinx/AES-KU040-DB-G
FPGA_DIR = fpga/intel/CYCLONEV-GT-DK
#FPGA_DIR = fpga/xilinx/SP605

ASIC_DIR = asic/umc130

sim:
	make -C $(SIM_DIR) 

fpga:
	make -C $(FPGA_DIR)

asic:
	make -C $(ASIC_DIR)

ld-hw:
	make -C $(FPGA_DIR) ld-hw

ld-sw:
	make -C $(FPGA_DIR) ld-sw

clean: 
	make -C  $(SIM_DIR) clean
	make -C fpga/xilinx/AES-KU040-DB-G clean
	make -C fpga/xilinx/SP605 clean
	make -C asic/umc130 clean

.PHONY: sim fpga asic ld-hw ld-sw clean
