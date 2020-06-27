include $(ROOT_DIR)/hardware/hardware.mk

VSRC+=verilog/top_system.v

REMOTE_FPGA_DIR := ./sandbox/iob-soc/fpga/$(FPGA_BOARD)

REMOTE := ${USER}@$(FPGA_BOARD_SERVER)

firmware.dat: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

boot.dat: $(BOOT_DIR)/boot.hex
	cp $< ./boot.dat

clean: fpga-clean
	@rm -f *.hex *.dat *.bin

.PHONY: all run ld-hw ld-sw clean
