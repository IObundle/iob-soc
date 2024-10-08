# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

CORE := iob_uart

LIB_DIR=../../../../lib
DISABLE_LINT:=1
export DISABLE_LINT
export LIB_DIR
BUILD_DIR := build

include $(LIB_DIR)/setup.mk

all: test

setup:
	nix-shell --run 'py2hwsw $(CORE)'

test: clean setup
	nix-shell --run "make -C ../iob_uart_* sim-run"

.PHONY: all setup test


