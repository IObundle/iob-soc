SIM_DIR = simulation/icarus
FPGA_DIR = fpga/xilinx/AES-KU040-DB-G
//FPGA_DIR = fpga/xilinx/SP605

sim:
	make -C $(SIM_DIR) 

fpga:
	make -C $(FPGA_DIR)

clean: 
	make -C  $(SIM_DIR) clean
	make -C $(FPGA_DIR) clean

.PHONY: sim fpga clean
