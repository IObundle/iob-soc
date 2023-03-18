HEX+=iob_soc_tester_boot.hex iob_soc_tester_firmware.hex
include ../../software/sw_build.mk

IS_FPGA=1

QUARTUS_SEED=10

# Undefine FPGA_TOP, as it was set by UUT.
undefine FPGA_TOP


include uut_build.mk
