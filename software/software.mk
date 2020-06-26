define:=-D
include $(ROOT_DIR)/system.mk

#submodules
include $(INTERCON_DIR)/software/software.mk
include $(UART_DIR)/software/embedded/embedded.mk

SW_DIR:=$(ROOT_DIR)/software

#include
INCLUDE+=-I$(SW_DIR)

#headers
HDR=$(SW_DIR)/*.h

#sources (none so far)
#SRC=$(SW_DIR)/*.c

#compiler settings
TOOLCHAIN_PREFIX:=riscv32-unknown-elf-
CFLAGS:=-Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 --std=gnu99

