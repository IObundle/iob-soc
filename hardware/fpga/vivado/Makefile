FPGA_OBJ?=$(FPGA_FAMILY)/iob_i2s_tdm.edif
CLKBUF_WRAPPER:=xilinx
CONSTRAINTS:=$(wildcard *.xdc)

include ../fpga.mk

run: $(FPGA_OBJ)

clean: clean_hw
	rm -rf $(FPGA_FAMILY) *.v *.vh

.PHONY: run clean
