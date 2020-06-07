include ../../system.mk

TOOLCHAIN_PREFIX:=riscv32-unknown-elf-
CFLAGS:=-Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 --std=gnu99

PYTHON_DIR:=../python

SUBMODULES_DIR:=../../submodules
INTERCON_DIR:=$(SUBMODULES_DIR)/interconnect/software
UART_DIR:=$(SUBMODULES_DIR)/uart/software

INCLUDE:=-I.. -I$(UART_DIR)/common -I$(INTERCON_DIR)

DEFINE:=-DUSE_SRAM=$(USE_SRAM) -DSRAM_ADDR_W=$(SRAM_ADDR_W) -DUSE_DDR=$(USE_DDR)
DEFINE+=-DN_SLAVES=$(N_SLAVES) 
DEFINE+=-DUART=$(UART) -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)

SRC = $(UART_DIR)/common/iob-uart.c $(UART_DIR)/embedded/iob-uart-platform.c
