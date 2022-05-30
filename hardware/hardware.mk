#default baud rate for hardware
BAUD ?=115200

include $(ROOT_DIR)/config.mk

#add itself to MODULES list
HW_MODULES+=$(IOBSOC_NAME)

#
# ADD SUBMODULES HARDWARE
#

#include LIB modules
include $(LIB_DIR)/hardware/iob_merge/hardware.mk
include $(LIB_DIR)/hardware/iob_split/hardware.mk

#include MEM modules
include $(MEM_DIR)/hardware/rom/iob_rom_sp/hardware.mk
include $(MEM_DIR)/hardware/ram/iob_ram_dp_be/hardware.mk

#CPU
include $(PICORV32_DIR)/hardware/hardware.mk

#CACHE
include $(CACHE_DIR)/hardware/hardware.mk

#HARDWARE PATHS
INC_DIR:=$(HW_DIR)/include
SRC_DIR:=$(HW_DIR)/src

#DEFINES
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#HEADERS
VHDR+=$(INC_DIR)/system.vh $(LIB_DIR)/hardware/include/iob_intercon.vh

#SOURCES

#external memory interface
ifeq ($(USE_DDR),1)
VSRC+=$(SRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(SRC_DIR)/boot_ctr.v $(SRC_DIR)/int_mem.v $(SRC_DIR)/sram.v
VSRC+=tester.v

HEXPROGS=boot.hex firmware.hex
#create init_ddr_contents (to merge UUT with Tester firmware, assuming that UUT has a firmware)
#TODO: check if UUT has firmware
ifeq ($(USE_DDR),1)
ifeq ($(RUN_EXTMEM),1)
ifeq ($(INIT_MEM),1)
HEXPROGS+=init_ddr_contents.hex
endif
endif
endif

#Include targets to copy VSRC, VHDR and DEFINES
include $(ROOT_DIR)/get_makefile_variables.mk

# make tester.v and copy vsrc, vhdr, defines from peripherals
tester.v: $(SRC_DIR)/system_core.v
	$(SW_DIR)/python/createSystem.py $(ROOT_DIR) "../../peripheral_portmap.conf" "$(GET_DIRS)" "$(PERIPHERALS)"
	# get VSRC, VHDR and DEFINES from peripherals, UUT and extra tester peripherals (from tester.mk of unit under test)
	$(foreach p, $(sort $(PERIPHERALS)), make -f $(ROOT_DIR)/get_makefile_variables.mk get_vsrc get_vhdr get_defines PERIPHERAL_INC_DIR=$($p_DIR)/hardware/hardware.mk $p_DIR=$($p_DIR) ROOT_DIR=$($p_DIR);)

# make and copy memory init files
PYTHON_DIR=$(MEM_DIR)/software/python

boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $< $(BOOTROM_ADDR_W) > $@

firmware.hex: $(FIRM_DIR)/firmware.bin
	$(PYTHON_DIR)/makehex.py $< $(FIRM_ADDR_W) > $@
	$(PYTHON_DIR)/hex_split.py firmware .

# init file for external mem with firmware of both systems
init_ddr_contents.hex: uut_firmware.hex firmware.hex
	$(SW_DIR)/python/joinHexFiles.py $^ $(DDR_ADDR_W) > $@

#clean general hardware files
hw-clean: gen-clean
	@rm -f *.v *.vh *.hex *.bin $(SRC_DIR)/tester.v $(TB_DIR)/system_tb.v defines.txt
	@rm -rf vsrc vhdr

.PHONY: hw-clean
