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

#Function to obtain parameter named $(1) from iob_system_conf.vh
GET_IOB_SYSTEM_CONF_MACRO = $(call GET_MACRO,IOB_SYSTEM_$(1),../src/iob_system_conf.vh)

iob_system_bootrom.hex: ../../software/iob_system_preboot.bin ../../software/iob_system_boot.bin
	../../scripts/makehex.py $^ 00000080 $(call GET_IOB_SYSTEM_CONF_MACRO,BOOTROM_ADDR_W) > $@

iob_system_firmware.hex: iob_system_firmware.bin
	../../scripts/makehex.py $< $(call GET_IOB_SYSTEM_CONF_MACRO,MEM_ADDR_W) > $@
	../../scripts/hex_split.py iob_system_firmware .

iob_system_firmware.bin: ../../software/iob_system_firmware.bin
	cp $< $@

../../software/%.bin:
	make -C ../../ fw-build

UTARGETS+=build_iob_system_software

TEMPLATE_LDS=src/$@.lds

IOB_SYSTEM_INCLUDES=-I. -Isrc -Iinclude

IOB_SYSTEM_LFLAGS=-Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug

# FIRMWARE SOURCES
IOB_SYSTEM_FW_SRC=src/iob_system_firmware.S
IOB_SYSTEM_FW_SRC+=src/iob_system_firmware.c
IOB_SYSTEM_FW_SRC+=src/printf.c
# PERIPHERAL SOURCES
IOB_SYSTEM_FW_SRC+=$(addprefix src/,$(addsuffix .c,$(PERIPHERALS)))
IOB_SYSTEM_FW_SRC+=$(addprefix src/,$(addsuffix _csrs_emb.c,$(PERIPHERALS)))

# BOOTLOADER SOURCES
IOB_SYSTEM_BOOT_SRC+=src/iob_system_boot.S
IOB_SYSTEM_BOOT_SRC+=src/iob_system_boot.c
IOB_SYSTEM_BOOT_SRC+=src/iob_uart.c
IOB_SYSTEM_BOOT_SRC+=src/iob_uart_csrs_emb.c

# PREBOOT SOURCES
IOB_SYSTEM_PREBOOT_SRC=src/iob_system_preboot.S

build_iob_system_software: iob_system_firmware iob_system_boot iob_system_preboot

iob_system_firmware:
	make $@.elf INCLUDES="$(IOB_SYSTEM_INCLUDES)" LFLAGS="$(IOB_SYSTEM_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SYSTEM_FW_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"

iob_system_boot:
	make $@.elf INCLUDES="$(IOB_SYSTEM_INCLUDES)" LFLAGS="$(IOB_SYSTEM_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SYSTEM_BOOT_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"

iob_system_preboot:
	make $@.elf INCLUDES="$(IOB_SYSTEM_INCLUDES)" LFLAGS="$(IOB_SYSTEM_LFLAGS) -Wl,-Map,$@.map" SRC="$(IOB_SYSTEM_PREBOOT_SRC)" TEMPLATE_LDS="$(TEMPLATE_LDS)"


.PHONY: build_iob_system_software iob_system_firmware iob_system_boot

#########################################
#         PC emulation targets          #
#########################################
# Local pc-emul makefile settings for custom pc emulation targets.

# SOURCES
EMUL_SRC+=src/iob_system_firmware.c
EMUL_SRC+=src/printf.c

# PERIPHERAL SOURCES
EMUL_SRC+=$(addprefix src/,$(addsuffix .c,$(PERIPHERALS)))
EMUL_SRC+=$(addprefix src/,$(addsuffix _csrs_pc_emul.c,$(PERIPHERALS)))

