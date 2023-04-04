#########################################
#            Embedded targets           #
#########################################
# Local embedded makefile settings for custom bootloader and firmware targets.

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_MACRO,<param_name>,<vh_path>)
GET_MACRO = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_tester_conf.vh
GET_TESTER_CONF_MACRO = $(call GET_MACRO,IOB_SOC_TESTER_$(1),../src/iob_soc_tester_conf.vh)

iob_soc_tester_boot.hex: ../../software/iob_soc_tester_boot.bin
	../../scripts/makehex.py $< $(call GET_TESTER_CONF_MACRO,BOOTROM_ADDR_W) > $@

iob_soc_tester_firmware.hex: iob_soc_tester_firmware.bin
	../../scripts/makehex.py $< $(call GET_TESTER_CONF_MACRO,SRAM_ADDR_W) > $@
	../../scripts/hex_split.py iob_soc_tester_firmware .

iob_soc_tester_firmware.bin: ../../software/iob_soc_tester_firmware.bin
	cp $< $@

../../software/%.bin:
	make -C ../../ fw-build

UTARGETS+=build_tester_software

TESTER_INCLUDES=-I. -Isrc 

TESTER_LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

# FIRMWARE SOURCES
TESTER_FW_SRC=src/iob_soc_tester_firmware.S
TESTER_FW_SRC+=src/iob_soc_tester_firmware.c
TESTER_FW_SRC+=src/printf.c
TESTER_FW_SRC+=src/iob_str.c
# PERIPHERAL SOURCES
TESTER_FW_SRC+=$(wildcard src/iob-*.c)
TESTER_FW_SRC+=$(filter-out %_emul.c, $(wildcard src/*swreg*.c))

# BOOTLOADER SOURCES
TESTER_BOOT_SRC+=src/iob_soc_tester_boot.S
TESTER_BOOT_SRC+=src/iob_soc_tester_boot.c
TESTER_BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*uart*.c))
TESTER_BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*cache*.c))

build_tester_software:
	make iob_soc_tester_firmware.elf INCLUDES="$(TESTER_INCLUDES)" LFLAGS="$(TESTER_LFLAGS) -Wl,-Map,iob_soc_tester_firmware.map" SRC="$(TESTER_FW_SRC)"
	make iob_soc_tester_boot.elf INCLUDES="$(TESTER_INCLUDES)" LFLAGS="$(TESTER_LFLAGS) -Wl,-Map,iob_soc_tester_boot.map" SRC="$(TESTER_BOOT_SRC)"


.PHONE: build_tester_software
