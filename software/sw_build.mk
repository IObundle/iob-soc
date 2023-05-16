#########################################
#            Embedded targets           #
#########################################
# Local embedded makefile settings for custom bootloader and firmware targets.

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_MACRO,<param_name>,<vh_path>)
GET_MACRO = $(shell grep $(1) $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_CONF_MACRO = $(call GET_MACRO,IOB_SOC_$(1),../src/iob_soc_conf.vh)

iob_soc_boot.hex: ../../software/iob_soc_boot.bin
	../../scripts/makehex.py $< $(call GET_CONF_MACRO,BOOTROM_ADDR_W) > $@

iob_soc_firmware.hex: iob_soc_firmware.bin
	../../scripts/makehex.py $< $(call GET_CONF_MACRO,SRAM_ADDR_W) > $@
	../../scripts/hex_split.py iob_soc_firmware .

iob_soc_firmware.bin: ../../software/iob_soc_firmware.bin
	cp $< $@

../../software/%.bin:
	make -C ../../ fw-build

UTARGETS+=build_software

IOB_SOC_INCLUDES=-I. -Isrc 

IOB_SOC_LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

# FIRMWARE SOURCES
IOB_SOC_FW_SRC=src/iob_soc_firmware.S
IOB_SOC_FW_SRC+=src/iob_soc_firmware.c
IOB_SOC_FW_SRC+=src/printf.c
IOB_SOC_FW_SRC+=src/iob_str.c
# PERIPHERAL SOURCES
IOB_SOC_FW_SRC+=$(wildcard src/iob-*.c)
IOB_SOC_FW_SRC+=$(filter-out %_emul.c, $(wildcard src/*swreg*.c))

# BOOTLOADER SOURCES
IOB_SOC_BOOT_SRC+=src/iob_soc_boot.S
IOB_SOC_BOOT_SRC+=src/iob_soc_boot.c
IOB_SOC_BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*uart*.c))
IOB_SOC_BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*cache*.c))

build_software:
	make iob_soc_firmware.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,iob_soc_firmware.map" SRC="$(IOB_SOC_FW_SRC)"
	make iob_soc_boot.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,iob_soc_boot.map" SRC="$(IOB_SOC_BOOT_SRC)"


.PHONE: build_software
