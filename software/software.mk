include ../../system.mk

TOOLCHAIN_PREFIX:=riscv32-unknown-elf-
CFLAGS:=-Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 --std=gnu99

PYTHON_DIR:=../python

SUBMODULES_DIR:=../../submodules
INTERCON_DIR:=$(SUBMODULES_DIR)/interconnect/software
UART_DIR:=$(SUBMODULES_DIR)/uart/software

INCLUDE:=-I.. -I$(UART_DIR)/common -I$(INTERCON_DIR)

DEFINE:=-DUSE_DDR=$(USE_DDR)
DEFINE+=-DFIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=-DN_SLAVES=$(N_SLAVES) 
DEFINE+=-DUART=$(UART) -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)
DEFINE+=-DE=$(E) -DP=$(P) -DB=$(B)

SRC = $(UART_DIR)/common/iob-uart.c $(UART_DIR)/embedded/iob-uart-platform.c
