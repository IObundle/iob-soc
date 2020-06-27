define:=-D
include $(ROOT_DIR)/system.mk

#submodules
include $(INTERCON_DIR)/software/software.mk

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

# peripherals
dummy:=$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/software/embedded/embedded.mk))
dummy:=$(foreach p, $(PERIPHERALS), $(shell echo "\#define $p_BASE (1<<P) |($p<<(ADDR_W-2-N_SLAVES_W))" >> ../periphs.h)))

