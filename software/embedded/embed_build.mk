# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file may be appended to embed_build.mk files of other systems/cores

UTARGETS+=build_software

INCLUDES=-I. -I.. -I../esrc -I../src

LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

#FW_SRC=$(wildcard *.c)
FW_SRC=$(wildcard ../firmware/*)
FW_SRC+=$(wildcard ../esrc/*.c)
FW_SRC+=$(wildcard ../src/*.c)

BOOT_SRC=$(wildcard ../bootloader/*)
BOOT_SRC+=$(wildcard ../esrc/*.c)
BOOT_SRC+=$(filter-out ../src/printf.c, $(wildcard ../src/*.c))

build_software:
	make iob_soc_firmware.elf INCLUDES="$(INCLUDES) -I../firmware " LFLAGS="$(LFLAGS) -Wl,-Map,iob_soc_firmware.map" SRC="$(FW_SRC)"
	make iob_soc_boot.elf INCLUDES="$(INCLUDES) -I../bootloader " LFLAGS="$(LFLAGS) -Wl,-Map,iob_soc_boot.map" SRC="$(BOOT_SRC)"


.PHONE: build_software
