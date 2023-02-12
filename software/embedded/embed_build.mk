# Local embedded makefile fragment for custom bootloader and firmware targets.
# This file may be appended to embed_build.mk files of other systems/cores

UTARGETS+=build_software

INCLUDES=-I. -I.. -I../esrc -I../src

# The following is a list of all the source files that need to be compiled
FW_SRC=$(wildcard ../firmware/iob_soc_firmware.*)
FW_SRC+=$(wildcard ../esrc/*.c)
FW_SRC+=$(wildcard ../src/*.c)

BOOT_SRC=../bootloader/iob_soc_boot.S ../bootloader/iob_soc_boot.c
BOOT_SRC+=$(wildcard ../esrc/*.c)
BOOT_SRC+=$(filter-out ../src/printf.c, $(wildcard ../src/*.c))


PREBOOT_SRC=../preboot/iob_soc_preboot.S


build_software: build_firmware build_bootloader build_preboot

build_preboot: $(PREBOOT_SRC)
	make iob_soc_preboot.elf INCLUDES="$(INCLUDES)" LDFLAGS="$(LDFLAGS)" SRC="$(PREBOOT_SRC)" LDS="../preboot/template.lds"

build_bootloader: $(BOOT_SRC)
	make iob_soc_boot.elf INCLUDES="$(INCLUDES) " LDFLAGS="$(LDFLAGS) -Wl,-Map,iob_soc_boot.map" SRC="$(BOOT_SRC)" LDS="../bootloader/template.lds"

build_firmware: $(FW_SRC)
	make iob_soc_firmware.elf INCLUDES="$(INCLUDES) " LDFLAGS="$(LDFLAGS) -Wl,-Map,iob_soc_firmware.map" SRC="$(FW_SRC)" LDS="../firmware/template.lds"

.PHONE: build_software
