SIM_DIR:=hardware/simulation/icarus

sim:
	make -C $(SIM_DIR)

clean:
	make -C $(SIM_DIR) clean
	$(RM) *~

.PHONY: sim clean
