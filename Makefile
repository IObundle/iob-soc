SIM_DIR:=hardware/simulation/icarus

sim:
	make -C $(SIM_DIR)

waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/iob_uart.vcd

clean:
	make -C $(SIM_DIR) clean
	$(RM) *~

.PHONY: sim clean
