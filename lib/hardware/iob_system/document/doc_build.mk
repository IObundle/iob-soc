# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile segment is used at build-time in $(BUILD_DIR)/doc/Makefile
#

#Set ASICSYNTH to 1 to include an ASIC synthesis section
ASICSYNTH?=0

#include implementation results; requires EDA tools
#default is 0 as EDA tools may not be accessible
RESULTS ?= 1
#results for intel FPGA
INT_FAMILY ?=cyclonev_gt_dk
#results for xilinx fpga
XIL_FAMILY ?=aes_ku040_db_g

