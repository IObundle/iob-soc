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

INCLUDES=-I. -Isrc 

LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

# FIRMWARE SOURCES
FW_SRC+=src/iob_soc_firmware.S
FW_SRC+=src/iob_soc_firmware.c
FW_SRC+=src/printf.c
FW_SRC+=src/iob_str.c
# PERIPHERAL SOURCES
FW_SRC+=$(wildcard src/iob-*.c)
FW_SRC+=$(filter-out %_emul.c, $(wildcard src/*swreg*.c))

# BOOTLOADER SOURCES
BOOT_SRC+=src/iob_soc_boot.S
BOOT_SRC+=src/iob_soc_boot.c
BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*uart*.c))
BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*cache*.c))

build_software:
	make iob_soc_firmware.elf INCLUDES="$(INCLUDES)" LFLAGS="$(LFLAGS) -Wl,-Map,iob_soc_firmware.map" SRC="$(FW_SRC)"
	make iob_soc_boot.elf INCLUDES="$(INCLUDES)" LFLAGS="$(LFLAGS) -Wl,-Map,iob_soc_boot.map" SRC="$(BOOT_SRC)"


.PHONE: build_software

#########################################
#         PC emulation targets          #
#########################################
# Local pc-emul makefile settings for custom pc emulation targets.

# Include directory with iob_soc_system.h
EMUL_INCLUDE+=-I. -Isrc

# SOURCES
EMUL_SRC+=src/iob_soc_firmware.c
EMUL_SRC+=src/printf.c
EMUL_SRC+=src/iob_str.c

# PERIPHERAL SOURCES
EMUL_SRC+=$(wildcard src/iob-*.c)

EMUL_TEST_LIST+=test1
test1:
	make run_emul TEST_LOG="> test.log"


CLEAN_LIST+=clean1
clean1:
	@rm -rf iob_soc_conf.h
