HEX+=iob_soc_tester_boot.hex iob_soc_tester_firmware.hex
include ../../software/sw_build.mk

# Set USE_EXTMEM if IOB_SOC_TESTER_USE_EXTMEM is present in the *confs.vh file
ifneq ($(call GET_TESTER_CONF_MACRO,USE_EXTMEM),)
USE_EXTMEM:=1
else
USE_EXTMEM:=0
endif

IS_FPGA=1


QUARTUS_SEED=10

TEST_LIST+=test1
test1:
	make -C ../../ fw-clean BOARD=$(BOARD)
	make -C ../../ fpga-clean BOARD=$(BOARD)
	make run BOARD=$(BOARD)
	diff run.log $(FPGA_TOOL)/$(BOARD)/test.expected
