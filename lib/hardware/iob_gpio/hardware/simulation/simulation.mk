# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

include $(GPIO_DIR)/hardware/hardware.mk

DEFINE+=$(defmacro)VCD

VSRC+=$(wildcard $(GPIO_HW_DIR)/testbench/*.v)
