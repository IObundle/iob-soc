HEX+=iob_soc_boot.hex iob_soc_firmware.hex
include ../../software/sw_build.mk

# Set USE_EXTMEM if IOB_SOC_RUN_EXTMEM is present in the *confs.vh file

ifneq ($(call GET_CONF_PARAM,IOB_SOC_RUN_EXTMEM),)
USE_EXTMEM:=1
else
USE_EXTMEM:=0
endif

IS_FPGA=1

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean BOARD=$(BOARD)
	make -C ../../ fpga-clean BOARD=$(BOARD)
	make run BOARD=$(BOARD)
	diff run.log $(FPGA_TOOL)/$(BOARD)/test.expected
