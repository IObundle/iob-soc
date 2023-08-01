# Add iob-soc software as a build dependency
RUN_DEPS+=iob_soc_boot.hex iob_soc_firmware.hex
# Don't add firmware to BUILD_DEPS if we are not initializing memory since we don't want to rebuild the bitstream when we modify it.
BUILD_DEPS+=iob_soc_boot.hex $(if $(filter $(INIT_MEM),1),iob_soc_firmware.hex)

ROOT_DIR :=../..
include $(ROOT_DIR)/software/sw_build.mk

IS_FPGA=1

QUARTUS_SEED ?=5

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean BOARD=$(BOARD) && make -C ../../ fpga-clean BOARD=$(BOARD) && make run BOARD=$(BOARD)

# Include the UUT configuration if iob-soc is used as a Tester
ifneq ($(wildcard uut_build_for_iob_soc.mk),)
include uut_build_for_iob_soc.mk
endif
