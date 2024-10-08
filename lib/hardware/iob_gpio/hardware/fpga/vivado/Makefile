# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

FPGA_OBJ?=$(FPGA_FAMILY)/$(TOP_MODULE).edif
CONSTRAINTS:=$(wildcard *.xdc)

include ../fpga.mk

run: $(FPGA_OBJ)

clean: gpio_clean_hw
	rm -rf $(FPGA_FAMILY) *.v *.vh

.PHONY: run clean
