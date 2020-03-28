FPGA_DIR := fpga/altera/cyclone_v_gt/quartus_18.0
SIM_DIR := simulation/icarus

sim:
	make -C $(SIM_DIR)

fpga:
	make -C $(FPGA_DIR)

clean:
	make -C $(SIM_DIR) clean
#	make -C $(FPGA_DIR) clean
	$(RM) *~

.PHONY: sim fpga clean

