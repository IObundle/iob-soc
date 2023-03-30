RUN_DEPS+=iob_soc_boot.hex iob_soc_firmware.hex
# Don't add firmware to BUILD_DEPS if we are not initializing memory since we don't want to rebuild the bitstream when we modify it.
BUILD_DEPS+=iob_soc_boot.hex $(if $(filter $(INIT_MEM),1),iob_soc_firmware.hex)
include ../../software/sw_build.mk

IS_FPGA=1


QUARTUS_SEED=5

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean BOARD=$(BOARD)
	make -C ../../ fpga-clean BOARD=$(BOARD)
	make run BOARD=$(BOARD)
