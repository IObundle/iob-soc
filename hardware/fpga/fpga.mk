include $(ROOT_DIR)/hardware/hardware.mk

VSRC+=verilog/top_system.v

ld-sw:
	cp firmware.bin $(LD_SW_DIR)
	make -C $(LD_SW_DIR)

clean: clean_xilinx clean_altera
	@rm -f *.hex *.dat *.bin

.PHONY: all run ld-hw ld-sw clean clean_xilinx clean_altera
