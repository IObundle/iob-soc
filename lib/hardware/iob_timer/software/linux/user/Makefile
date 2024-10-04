# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

SRC = $(wildcard *.c)
HDR += iob_timer.h
FLAGS = -Wall -Werror -O2
FLAGS += -static
FLAGS += -march=rv32imac
FLAGS += -mabi=ilp32
BIN = iob_timer_user
CC = riscv64-unknown-linux-gnu-gcc

all: $(BIN)

$(BIN): $(SRC) $(HDR)
	$(CC) $(FLAGS) $(INCLUDE) -o $(BIN) $(SRC)

LIB_DIR = ../../../../../../
IOB_LINUX_DIR ?= ../../../lib/iob-linux
$(HDR):
	cd lib && \
		.$(IOB_LINUX_DIR)/scripts/drivers.py iob_timer -o `realpath $(CURDIR)`

clean:
	rm -rf $(BIN) $(HDR)
