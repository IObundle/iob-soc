defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/system.mk

#compiler settings
TOOLCHAIN_PREFIX:=riscv32-unknown-elf-
CFLAGS=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32

MFLAGS=$(BASE_FLAGS)$(CFLAG)

BASE_FLAGS:=rv32im

ifeq ($(USE_COMPRESSED),1)
CFLAG:=c
endif

#INCLUDE
INCLUDE+=$(incdir)$(SW_DIR) $(incdir).

#headers
HDR=$(SW_DIR)/system.h

#common sources (none so far)
#SRC=$(SW_DIR)/*.c

.PHONY: periphs.h
