HEX+=iob_soc_tester_boot.hex iob_soc_tester_firmware.hex
include ../../software/sw_build.mk

# Set USE_EXTMEM if IOB_SOC_TESTER_RUN_EXTMEM is present in the *confs.vh file
USE_EXTMEM:=$(call GET_TESTER_CONF_MACRO,RUN_EXTMEM)

IS_FPGA=1

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean BOARD=$(BOARD)
	make -C ../../ fpga-clean BOARD=$(BOARD)
	make run BOARD=$(BOARD)
	diff run.log $(FPGA_TOOL)/$(BOARD)/test.expected
