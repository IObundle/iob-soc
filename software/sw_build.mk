#########################################
#            Embedded targets           #
#########################################
ROOT_DIR ?=..
# Local embedded makefile settings for custom bootloader and firmware targets.

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_MACRO,<param_name>,<vh_path>)
GET_MACRO = $(shell grep "define $(1)" $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_IOB_SOC_CONF_MACRO = $(call GET_MACRO,IOB_SOC_$(1),../src/iob_soc_conf.vh)

iob_soc_preboot.hex: ../../software/iob_soc_preboot.bin
	../../scripts/makehex.py $< $(call GET_IOB_SOC_CONF_MACRO,PREBOOT_BOOTROM_ADDR_W) > $@

iob_soc_boot.hex: ../../software/iob_soc_boot.bin
	../../scripts/makehex.py $< $(call GET_IOB_SOC_CONF_MACRO,BOOT_BOOTROM_ADDR_W) > $@

iob_soc_rom.hex: iob_soc_preboot.hex iob_soc_boot.hex
	cat $^ > $@

iob_soc_firmware.hex: iob_soc_firmware.bin
	../../scripts/makehex.py $< $(call GET_IOB_SOC_CONF_MACRO,SRAM_ADDR_W) > $@
	../../scripts/hex_split.py iob_soc_firmware .

iob_soc_firmware.bin: ../../software/iob_soc_firmware.bin
	cp $< $@

../../software/%.bin:
	make -C ../../ fw-build



# Uncomment to compile the python-setup branch version of iob-soc software at commit
# fd744280e78fe4ce8369254a47c3a03d5fc1b4c2.
#COMPILE_PYTHON=python-setup/



UTARGETS+=build_iob_soc_software

TEMPLATE_LDS=src/$(COMPILE_PYTHON)$@.lds

IOB_SOC_INCLUDES=-I. -Isrc 

IOB_SOC_LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

# FIRMWARE SOURCES
IOB_SOC_FW_SRC=src/$(COMPILE_PYTHON)iob_soc_firmware.S
IOB_SOC_FW_SRC+=src/$(COMPILE_PYTHON)iob_soc_firmware.c
IOB_SOC_FW_SRC+=src/printf.c
IOB_SOC_FW_SRC+=src/iob_str.c
# PERIPHERAL SOURCES
IOB_SOC_FW_SRC+=$(wildcard src/iob-*.c)
IOB_SOC_FW_SRC+=$(filter-out %_emul.c, $(wildcard src/*swreg*.c))

# BOOTLOADER SOURCES
IOB_SOC_BOOT_SRC=src/$(COMPILE_PYTHON)iob_soc_boot.c
IOB_SOC_BOOT_SRC+=src/$(COMPILE_PYTHON)iob_soc_boot.S
IOB_SOC_BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*uart*.c))
IOB_SOC_BOOT_SRC+=$(filter-out %_emul.c, $(wildcard src/iob*cache*.c))

# PREBOOT SOURCES
IOB_SOC_PREBOOT_SRC=src/$(COMPILE_PYTHON)iob_soc_preboot.S

build_iob_soc_software: iob_soc_firmware iob_soc_boot iob_soc_preboot

iob_soc_firmware:
	make $@.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SOC_FW_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"

iob_soc_boot:
	make $@.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SOC_BOOT_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"

iob_soc_preboot:
	make $@.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SOC_PREBOOT_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"


.PHONE: build_iob_soc_software

# Include the UUT configuration if iob-soc is used as a Tester
ifneq ($(wildcard $(ROOT_DIR)/software/uut_build_for_iob_soc.mk),)
include $(ROOT_DIR)/software/uut_build_for_iob_soc.mk
endif

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

EMUL_TEST_LIST+=pcemul_test1
pcemul_test1:
	make run_emul TEST_LOG="> test.log"


CLEAN_LIST+=clean1
clean1:
	@rm -rf iob_soc_conf.h
