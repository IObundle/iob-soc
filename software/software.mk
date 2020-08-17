defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/system.mk

#submodules
include $(INTERCON_DIR)/software/software.mk

#software directory
SW_DIR:=$(ROOT_DIR)/software

#include
#INCLUDE+=$(incdir)$(SW_DIR)
INCLUDE+=-I$(SW_DIR)

#headers
HDR=$(SW_DIR)/system.h

#sources (none so far)
#SRC=$(SW_DIR)/*.c

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
#CFLAGS:=-Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 --std=gnu99
CFLAGS:=-Os -nostdlib -march=rv32im -mabi=ilp32

#peripherals' base addresses
$(SW_DIR)/periphs.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> ../periphs.h) )
