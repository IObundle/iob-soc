include $(SUT_DIR)/config.mk

#default baud and freq for hardware
BAUD ?=115200
FREQ ?=100000000

#add itself to MODULES list
MODULES+=$(shell make -C $(SUT_DIR) corename | grep -v make)

#ADD SUBMODULES

#list memory modules before including MEM's hardware.mk
MEM_MODULES+=rom/sp_rom ram/dp_ram_be

#include submodule's hardware
$(foreach p, $(SUBMODULES), $(if $(filter $p, $(MODULES)),, $(eval include $($p_DIR)/hardware/hardware.mk)))

#HARDWARE PATHS
INC_DIR:=$(HW_DIR)/include
SRC_DIR:=$(HW_DIR)/src

#DEFINES
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(INC_DIR)

#HEADERS
VHDR+=$(INC_DIR)/system.vh

#SOURCES
#testbench
TB_DIR:=$(HW_DIR)/testbench

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
	python3 $(HW_DIR)/createSystem.py $(SUT_DIR)

# make and copy memory init files
MEM_PYTHON_DIR=$(MEM_DIR)/software/python

boot.hex: $(BOOT_DIR)/boot.bin
	$(MEM_PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

firmware.hex: $(FIRM_DIR)/firmware.bin
	$(MEM_PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
	$(MEM_PYTHON_DIR)/hex_split.py firmware .
	cp $(FIRM_DIR)/firmware.bin .

# TODO: move this
# tester init files
#tester_boot.hex: $(SW_DIR)/tester/boot.bin
	#$(MEM_PYTHON_DIR)/makehex.py $(SW_DIR)/tester/boot.bin $(BOOTROM_ADDR_W) > $@

#tester_firmware.hex: $(SW_DIR)/tester/firmware.bin
	#$(MEM_PYTHON_DIR)/makehex.py $(SW_DIR)/tester/firmware.bin $(FIRM_ADDR_W) > $@
	#$(MEM_PYTHON_DIR)/hex_split.py tester_firmware
	#cp $(SW_DIR)/tester/firmware.bin tester_firmware.bin

# make embedded sw software
sw:
	make -C $(FIRM_DIR) firmware.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(BOOT_DIR) boot.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(CONSOLE_DIR) INIT_MEM=$(INIT_MEM)

# make embedded Tester software
#tester-sw:
	#make -C $(SW_DIR)/tester firmware.elf FREQ=$(FREQ) BAUD=$(BAUD)
	#make -C $(SW_DIR)/tester boot.elf FREQ=$(FREQ) BAUD=$(BAUD)

sw-clean:
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean

#tester-sw-clean:
	#make -C $(SW_DIR)/tester clean

#clean general hardware files
hw-clean: sw-clean gen-clean
	@rm -f *.v *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v
	# Clean generated tester files 
	#@rm -f $(TESTER_DIR)/*_generated.v

.PHONY: sw sw-clean hw-clean
