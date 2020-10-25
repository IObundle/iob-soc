defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/system.mk

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
CFLAGS:=-Os -nostdlib -march=rv32im -mabi=ilp32

#INCLUDE
INCLUDE+=$(incdir)$(SW_DIR)

#headers
HDR=$(SW_DIR)/system.h

#peripherals' base addresses
periphs.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> periphs.h) )

#common sources (none so far)
#SRC=$(SW_DIR)/*.c

