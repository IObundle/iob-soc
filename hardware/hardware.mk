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
VHDR+=$(wildcard $(HW_DIR)/include/*)
VHDR+=$(INC_DIR)/system.vh #Include system.vh because it is required by some verilog modules (such as boot_ctr.v), although its contents are never used by the tester.
VHDR+=$(INC_DIR)/tester.vh $(LIB_DIR)/hardware/include/iob_intercon.vh

#SOURCES

#external memory interface
ifeq ($(USE_DDR),1)
VSRC+=$(SRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(SRC_DIR)/boot_ctr.v $(SRC_DIR)/int_mem.v $(SRC_DIR)/sram.v
VSRC+=tester.v

HEXPROGS=tester_boot.hex tester_firmware.hex
#create init_ddr_contents (to merge UUT with Tester firmware, assuming that UUT has a firmware)
ifeq ($(USE_DDR),1)
ifeq ($(RUN_EXTMEM),1)
ifeq ($(INIT_MEM),1)
HEXPROGS+=init_ddr_contents.hex
endif
endif
endif

#Include targets to copy VSRC, VHDR and DEFINES
include $(ROOT_DIR)/get_makefile_variables.mk

# make tester.v
tester.v: $(SRC_DIR)/system_core.v get_peripherals_makefile_variables copy_uut_hexfiles
	$(SW_DIR)/python/createSystem.py $(ROOT_DIR) "../../peripheral_portmap.conf" "$(GET_DIRS)" "$(PERIPHERALS)"

#copy vsrc, vhdr, defines from peripherals
get_peripherals_makefile_variables: set_default_defines
	$(foreach p, $(sort $(PERIPHERALS)), make -f $(ROOT_DIR)/get_makefile_variables.mk get_vsrc get_vhdr get_defines PERIPHERAL_INC_DIR=$($p_DIR)/hardware/hardware.mk $p_DIR=$($p_DIR) ROOT_DIR=$($p_DIR);)

#set default defines because they are required by multiple modules, even though these values will not be used
#since they will always be overriden (at instantiation with parameters) by either tester defines or sut defines
set_default_defines:
	echo -n "ADDR_W=0 DATA_W=0 BOOTROM_ADDR_W=0 SRAM_ADDR_W=0 FIRM_ADDR_W=0 DCACHE_ADDR_W=0 E=0 V=0 P=0 B=0 USE_COMPRESSED=0 USE_MUL_DIV=0\
           " >> defines.txt

#Tries to build UUT bootloader and firmware (if targets exist) and copies them
copy_uut_hexfiles:
	-for p in "$($(UUT_NAME)_DIR)/software/firmware/boot.hex" "$($(UUT_NAME)_DIR)/software/firmware/firmware.hex"; do\
		make $$p 2> /dev/null &&\
		ln -fsr $$p .;\
	done
	-for p in {0..3}; do\
		ln -fsr "$($(UUT_NAME)_DIR)/software/firmware/firmware_$$p.hex" .;\
	done

# make and copy memory init files
PYTHON_DIR=$(MEM_DIR)/software/python

tester_boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $< $(BOOTROM_ADDR_W) > $@

tester_firmware.hex: $(FIRM_DIR)/firmware.bin
	$(PYTHON_DIR)/makehex.py $< $(FIRM_ADDR_W) > $@
	$(PYTHON_DIR)/hex_split.py tester_firmware .

# init file for external mem with firmware of both systems
init_ddr_contents.hex: firmware.hex tester_firmware.hex
	$(SW_DIR)/python/joinHexFiles.py $^ $(DDR_ADDR_W) > $@

#clean general hardware files
hw-clean: gen-clean
	@rm -f *.v *.vh *.hex *.bin $(SRC_DIR)/tester.v $(TB_DIR)/system_tb.v defines.txt
	@rm -rf vsrc vhdr

.PHONY: hw-clean get_peripherals_makefile_variables copy_uut_hexfiles set_default_defines
