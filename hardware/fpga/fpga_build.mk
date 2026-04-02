# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

include auto_fpga_build.mk

# Add iob-soc software as a build dependency
RUN_DEPS+=iob_soc_bootrom.hex iob_soc_firmware.hex
# Don't add firmware to BUILD_DEPS if we are not initializing memory since we don't want to rebuild the bitstream when we modify it.
BUILD_DEPS+=iob_soc_bootrom.hex $(if $(filter $(INIT_MEM),1),iob_soc_firmware.hex)

# Throw error if user attempts to initialize external memory in FPGA
ifeq ($(INIT_MEM), 1)
    ifneq ($(USE_INTMEM), 1)
        ifeq ($(USE_EXTMEM), 1)
            $(error Error: FPGA board's DDR memory cannot be initialized. Either use INIT_MEM=0 to avoid DDR memory initialization or set USE_INTMEM=1 to use internal memory instead)
        endif
    endif
endif

QUARTUS_SEED ?=5

ROOT_DIR :=../..
include $(ROOT_DIR)/software/sw_build.mk

# include fpga build segment of child socs
# child socs can add their own child_fpga_build.mk without having to override this one.
ifneq ($(wildcard child_fpga_build.mk),)
include child_fpga_build.mk
endif
