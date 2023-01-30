HEX+=iob_soc_boot.hex iob_soc_firmware.hex
include ../../software/sw_build.mk

IS_FPGA=1

TEST_LIST+=test1
test1:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run TEST_LOG=">> test.log"
