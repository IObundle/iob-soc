#SIM_DIR = simulation/icarus
SIM_DIR = simulation/modelsim
FPGA_DIR = fpga/xilinx/AES-KU040-DB-G
#FPGA_DIR = fpga/xilinx/SP605

sim:
	make -C $(SIM_DIR) 

fpga:
	make -C $(FPGA_DIR)

clean: 
	make -C  $(SIM_DIR) clean
	make -C fpga/xilinx/AES-KU040-DB-G clean
	make -C fpga/xilinx/SP605 clean

.PHONY: sim fpga clean
