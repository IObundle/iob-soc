include $(ROOT_DIR)/hardware/hardware.mk

VSRC+=verilog/top_system.v


all: run

firmware.bin: $(FIRM_DIR)/firmware.hex
	cp $(FIRM_DIR)/firmware.bin .

firmware.dat: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

boot.dat: $(BOOT_DIR)/boot.hex
	cp $< ./boot.dat

ld-sw:
	cp firmware.bin $(LD_SW_DIR)
	make -C $(LD_SW_DIR)

clean: clean_xilinx clean_altera
	@rm -f *.hex *.dat *.bin

.PHONY: all run ld-hw ld-sw clean clean_xilinx clean_altera
