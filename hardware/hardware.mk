include $(ROOT_DIR)/config.mk

#default baud and freq for hardware
BAUD ?=115200
FREQ ?=100000000

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

#UART
include $(UART_DIR)/hardware/hardware.mk

#REGFILEIF
include $(REGFILEIF_DIR)/hardware/hardware.mk

# include CORE_UT and tester peripherals if we are testing a core
ifeq ($(TESTING_CORE),1)
#CORE_UT
include $($(CORE_UT)_DIR)/hardware/hardware.mk

#include every other configured tester peripheral (in tester.mk of core under test)
$(foreach p, $(TESTER_PERIPHERALS), $(eval include $($p_DIR)/hardware/hardware.mk))
endif


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
VSRC+=system.v

IMAGES=boot.hex firmware.hex

ifeq ($(TESTER_ENABLED),1)
include $(TESTER_DIR)/hardware.mk
endif

# make system.v with peripherals
system.v: $(SRC_DIR)/system_core.v
	$(HW_DIR)/createSystem.py $(ROOT_DIR)

# make and copy memory init files
PYTHON_DIR=$(MEM_DIR)/software/python

boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

firmware.hex: $(FIRM_DIR)/firmware.bin
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
	$(PYTHON_DIR)/hex_split.py firmware .
	cp $(FIRM_DIR)/firmware.bin .

# make embedded sw software
sw:
	make -C $(FIRM_DIR) firmware.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(BOOT_DIR) boot.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(CONSOLE_DIR) INIT_MEM=$(INIT_MEM)

sw-clean:
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean
	make -C $(SW_DIR)/tester clean

#clean general hardware files
hw-clean: sw-clean gen-clean
	@rm -f *.v *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v *.vh

.PHONY: sw sw-clean hw-clean
