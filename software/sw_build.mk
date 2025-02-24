# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

#########################################
#            Embedded targets           #
#########################################
ROOT_DIR ?=..

include $(ROOT_DIR)/software/auto_sw_build.mk

# Local embedded makefile settings for custom bootloader and firmware targets.

#Function to obtain parameter named $(1) in verilog header file located in $(2)
#Usage: $(call GET_MACRO,<param_name>,<vh_path>)
GET_MACRO = $(shell grep "define $(1)" $(2) | rev | cut -d" " -f1 | rev)

#Function to obtain parameter named $(1) from iob_soc_conf.vh
GET_IOB_SOC_CONF_MACRO = $(call GET_MACRO,IOB_SOC_$(1),../src/iob_soc_conf.vh)

iob_soc_bootrom.hex: ../../software/iob_soc_preboot.bin ../../software/iob_soc_boot.bin
	../../scripts/makehex.py $^ 00000080 $(call GET_IOB_SOC_CONF_MACRO,BOOTROM_ADDR_W) $@

iob_soc_firmware.hex: iob_soc_firmware.bin
	../../scripts/makehex.py $< $(call GET_IOB_SOC_CONF_MACRO,MEM_ADDR_W) $@
	../../scripts/makehex.py --split $< $(call GET_IOB_SOC_CONF_MACRO,MEM_ADDR_W) $@

iob_soc_firmware.bin: ../../software/iob_soc_firmware.bin
	cp $< $@

../../software/%.bin:
	make -C ../../ fw-build

UTARGETS+=build_iob_soc_software

TEMPLATE_LDS=src/$@.lds

IOB_SOC_INCLUDES=-I. -Isrc -Iinclude

IOB_SOC_LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

# FIRMWARE SOURCES
IOB_SOC_FW_SRC=src/iob_soc_firmware.S
IOB_SOC_FW_SRC+=src/iob_soc_firmware.c
IOB_SOC_FW_SRC+=src/iob_printf.c
# PERIPHERAL SOURCES
IOB_SOC_FW_SRC+=$(addprefix src/,$(addsuffix .c,$(PERIPHERALS)))
IOB_SOC_FW_SRC+=$(addprefix src/,$(addsuffix _csrs_emb.c,$(PERIPHERALS)))

# BOOTLOADER SOURCES
IOB_SOC_BOOT_SRC+=src/iob_soc_boot.S
IOB_SOC_BOOT_SRC+=src/iob_soc_boot.c
IOB_SOC_BOOT_SRC+=src/iob_uart.c
IOB_SOC_BOOT_SRC+=src/iob_uart_csrs_emb.c

# PREBOOT SOURCES
IOB_SOC_PREBOOT_SRC=src/iob_soc_preboot.S

build_iob_soc_software: iob_soc_firmware iob_soc_boot iob_soc_preboot

iob_soc_firmware:
	make $@.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SOC_FW_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"

iob_soc_boot:
	make $@.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SOC_BOOT_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"

iob_soc_preboot:
	make $@.elf INCLUDES="$(IOB_SOC_INCLUDES)" LFLAGS="$(IOB_SOC_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SOC_PREBOOT_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"


.PHONY: build_iob_soc_software iob_soc_firmware iob_soc_boot

#########################################
#         PC emulation targets          #
#########################################
# Local pc-emul makefile settings for custom pc emulation targets.

# SOURCES
EMUL_SRC+=src/iob_soc_firmware.c
EMUL_SRC+=src/iob_printf.c

# PERIPHERAL SOURCES
EMUL_SRC+=$(addprefix src/,$(addsuffix .c,$(PERIPHERALS)))
EMUL_SRC+=$(addprefix src/,$(addsuffix _csrs_pc_emul.c,$(PERIPHERALS)))

