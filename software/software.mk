defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/system.mk

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
CFLAGS:=-Os -nostdlib -march=rv32im -mabi=ilp32

#INCLUDE
INCLUDE+=$(incdir)$(SW_DIR) $(incdir).

#headers
HDR=$(SW_DIR)/system.h

#common sources (none so far)
#SRC=$(SW_DIR)/*.c

.PHONY: periphs.h
