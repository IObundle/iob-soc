# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time in $(BUILD_DIR)/software/Makefile
#

include ../config_build.mk

#########################################
#           Embedded settings           #
#########################################

TEMPLATE_LDS ?=template.lds

MFLAGS=$(MFLAGS_BASE)$(MFLAG_M)$(MFLAG_C)
MFLAGS_BASE:=rv32i
ifeq ($(USE_MUL_DIV),1)
MFLAG_M=m
endif
ifeq ($(USE_COMPRESSED),1)
MFLAG_C=c
endif

#default compiler settings
TOOLCHAIN_PREFIX ?=riscv64-unknown-elf-
CFLAGS ?=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32 --specs=nano.specs -Wcast-align=strict
LFLAGS ?= -Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug
LLIBS ?=-lgcc -lc -lnosys
INCLUDES ?=-I. -Isrc

#########################################
#         PC emulation settings         #
#########################################

# compiler flags
EMUL_CFLAGS=-Os -std=gnu99 -Wl,--strip-debug

CONSOLE_CMD=rm -f soc2cnsl cnsl2soc; ../scripts/console.py -L

EMUL_INCLUDES=-I. -Isrc

EMUL_HDR+=$(wildcard src/*_emul.h)

EMUL_SRC+=$(wildcard src/*_emul.c)

#########################################
#            General settings           #
#########################################

# include local build segment
# all previously defined variables can be overwritten in this file
ifneq ($(wildcard sw_build.mk),)
include sw_build.mk
endif

#########################################
#            Embedded targets           #
#########################################

build: $(UTARGETS)
%.elf: $(TEMPLATE_LDS) $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(LFLAGS) $(INCLUDES) $(SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary $@ $(*F).bin

ifneq ($(BOARD),)
FPGA_TOOL:=$(shell find ../hardware/fpga -name $(BOARD) | cut -d"/" -f5)
endif

debug:
	@echo $(TEMPLATE_LDS)
	@echo $(FW_SRC)
	@echo $(BOOT_SRC)
	@echo $(HDR)

.PHONY: build debug

#########################################
#         PC emulation targets          #
#########################################

fw_emul: $(EMUL_HDR) $(EMUL_SRC)
	gcc -o $@ $(EMUL_CFLAGS) $(EMUL_INCLUDES) $(EMUL_SRC) -lgcc -lc

build_emul: fw_emul
	@echo "build"

#board client command
BOARD_GRAB_CMD=../scripts/board_client.py grab 300

run_emul: build_emul
	$(BOARD_GRAB_CMD) -s './fw_emul' -c '$(CONSOLE_CMD)'

test_emul: clean $(EMUL_TEST_LIST)
	test "$$(cat test.log)" = "Test passed!"

.PHONY: build_emul run_emul test_emul

#########################################
#            General targets            #
#########################################

# TODO add to iob-soc custom clean list
# CLEAN_LIST+=

clean: $(CLEAN_LIST)
	@rm -rf *.bin *.elf *.map *.hex
	@rm -rf fw_emul test.log soc2cnsl cnsl2soc
	@rm -rf *.txt

.PHONY: clean
