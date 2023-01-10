# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file is included in BUILD_DIR/sw/emb/Makefile.

UTARGETS=build_software

INCLUDES=-I. -I.. -I../esrc

LFLAGS= -Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

#FW_SRC=$(wildcard *.c)
FW_SRC=$(wildcard ../firmware/*)
FW_SRC+=$(wildcard ../esrc/*.c)

BOOT_SRC=$(wildcard ../bootloader/*)
BOOT_SRC+=$(filter-out ../esrc/printf.c, $(wildcard ../esrc/*.c))


HDR=$(wildcard *.h)
HDR+=$(wildcard ../*.h)
HDR+=$(wildcard ../esrc/*.h)

build_software:
	make iob_soc_tester_firmware.elf INCLUDES="$(INCLUDES) -I../firmware " LFLAGS="$(LFLAGS) -Wl,-Map,iob_soc_tester_firmware.map" SRC="$(FW_SRC)" HDR="$(HDR)"
	make iob_soc_tester_boot.elf INCLUDES="$(INCLUDES) -I../bootloader " LFLAGS="$(LFLAGS) -Wl,-Map,iob_soc_tester_boot.map" SRC="$(BOOT_SRC)" HDR="$(HDR)"


.PHONE: build_software
