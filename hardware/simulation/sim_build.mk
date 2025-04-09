# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

include auto_sim_build.mk

# Add iob-soc software as a build dependency
HEX+=iob_soc_bootrom.hex iob_soc_firmware.hex

ROOT_DIR :=../..
include $(ROOT_DIR)/software/sw_build.mk

ifeq ($(USE_ETHERNET),1)
VSRC+=./src/iob_eth_csrs_emb_verilator.c ./src/iob_eth_driver_tb.cpp
endif

CSRS = ../../software/src/iob_uart_csrs.c

CONSOLE_CMD ?=rm -f soc2cnsl cnsl2soc; ../../scripts/console.py -L

GRAB_TIMEOUT ?= 3600
