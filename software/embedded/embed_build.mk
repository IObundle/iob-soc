# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file may be appended to embed_build.mk files of other systems/cores

UTARGETS+=build_tester_software

TESTER_INCLUDES=-I. -I.. -I../esrc -I../src

TESTER_LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

#FW_SRC=$(wildcard *.c)
TESTER_FW_SRC=$(wildcard ../firmware/iob_soc_tester_firmware.*)
TESTER_FW_SRC+=$(wildcard ../esrc/*.c)
TESTER_FW_SRC+=$(wildcard ../src/*.c)

TESTER_BOOT_SRC=$(wildcard ../bootloader/iob_soc_tester_boot.*)
TESTER_BOOT_SRC+=$(wildcard ../esrc/*.c)
TESTER_BOOT_SRC+=$(filter-out ../src/printf.c, $(wildcard ../src/*.c))

build_tester_software:
	make iob_soc_tester_firmware.elf INCLUDES="$(TESTER_INCLUDES) -I../firmware " LFLAGS="$(TESTER_LFLAGS) -Wl,-Map,iob_soc_tester_firmware.map" SRC="$(TESTER_FW_SRC)"
	make iob_soc_tester_boot.elf INCLUDES="$(TESTER_INCLUDES) -I../bootloader " LFLAGS="$(TESTER_LFLAGS) -Wl,-Map,iob_soc_tester_boot.map" SRC="$(TESTER_BOOT_SRC)"


.PHONE: build_tester_software
