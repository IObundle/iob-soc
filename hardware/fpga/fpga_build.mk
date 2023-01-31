VHDR+=iob_soc_boot.hex iob_soc_firmware.hex
include ../../software/sw_build.mk

IS_FPGA=1

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean BOARD=$(BOARD)
	make -C ../../ fpga-clean BOARD=$(BOARD)
	make run BOARD=$(BOARD)
	diff run.log $(FPGA_TOOL)/$(BOARD)/test.expected
