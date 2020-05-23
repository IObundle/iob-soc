include ../../system.mk

TOOLCHAIN_PREFIX:=riscv32-unknown-elf-
CFLAGS:=-Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 --std=gnu99

PYTHON_DIR:=../python

SUBMODULES_DIR:=../../submodules
INTERCON_DIR:=$(SUBMODULES_DIR)/interconnect/software
UART_DIR:=$(SUBMODULES_DIR)/iob-uart/software

INCLUDE:=-I.. -I$(UART_DIR)/common -I$(INTERCON_DIR)

DEFINE:=-DN_SLAVES=$(N_SLAVES) -DUART=$(UART)
DEFINE+=-DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)

SRC = ../template.S $(UART_DIR)/common/iob-uart.c $(UART_DIR)/embedded/iob-uart-platform.c
