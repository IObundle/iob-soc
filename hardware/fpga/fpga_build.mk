RUN_DEPS+=iob_soc_tester_boot.hex iob_soc_tester_firmware.hex
# Don't add firmware to BUILD_DEPS if we are not initializing memory since we don't want to rebuild the bitstream when we modify it.
BUILD_DEPS+=iob_soc_tester_boot.hex $(if $(filter $(INIT_MEM),1),iob_soc_tester_firmware.hex)
include ../../software/sw_build.mk

IS_FPGA=1

QUARTUS_SEED ?=5

# Undefine FPGA_TOP, as it may have been set by UUT.
undefine FPGA_TOP

ifneq ($(wildcard uut_build.mk),)
include uut_build.mk
endif
