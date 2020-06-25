include $(ROOT_DIR)/system.mk

#python scripts location
PYTHON_DIR:=../python

#compiler settings
TOOLCHAIN_PREFIX:=riscv32-unknown-elf-
CFLAGS:=-Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 --std=gnu99

HDR:=../system.h

#include dir
INCLUDE:=-I..

define:=-D

include $(UART_DIR)/software/embedded/embedded.mk
include $(INTERCON_DIR)/software/software.mk


