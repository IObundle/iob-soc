# Add iob-soc software as a build dependency
RUN_DEPS+=iob_soc_boot.hex iob_soc_firmware.hex
# Don't add firmware to BUILD_DEPS if we are not initializing memory since we don't want to rebuild the bitstream when we modify it.
BUILD_DEPS+=iob_soc_boot.hex $(if $(filter $(INIT_MEM),1),iob_soc_firmware.hex)

QUARTUS_SEED ?=5

ROOT_DIR :=../..
include $(ROOT_DIR)/software/sw_build.mk
