#default baud rate for hardware
BAUD ?=115200

# include $(ROOT_DIR)/config.mk

#
# ADD SUBMODULES HARDWARE
# SUBCORES hardware is copied first, so that possible duplicated source modules
# are overwritten
#

#CACHE verilog sources and headers
CACHE_HW_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/CACHE/ -maxdepth 1 -type d -name iob_cache_V*)/hw/vsrc
VHDR+=$(patsubst $(CACHE_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(CACHE_HW_BUILD_DIR)/*.vh))
$(BUILD_VSRC_DIR)/%.vh: $(CACHE_HW_BUILD_DIR)/%.vh
	cp $< $@

VSRC+=$(patsubst $(CACHE_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(CACHE_HW_BUILD_DIR)/*.v))
$(BUILD_VSRC_DIR)/%.v: $(CACHE_HW_BUILD_DIR)/%.v
	cp $< $@

#UART verilog sources and headers
UART_HW_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/UART/ -maxdepth 1 -type d -name iob_uart_V*)/hw/vsrc
VHDR+=$(patsubst $(UART_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(UART_HW_BUILD_DIR)/*.vh))
$(BUILD_VSRC_DIR)/%.vh: $(UART_HW_BUILD_DIR)/%.vh
	cp $< $@

VSRC+=$(patsubst $(UART_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(UART_HW_BUILD_DIR)/*.v))
$(BUILD_VSRC_DIR)/%.v: $(UART_HW_BUILD_DIR)/%.v
	cp $< $@

#include LIB modules
include hardware/iob_merge/hardware.mk
include hardware/iob_split/hardware.mk
include hardware/rom/iob_rom_sp/hardware.mk
include hardware/ram/iob_ram_dp_be/hardware.mk
include hardware/iob_pulse_gen/hardware.mk

#CPU
PICORV32_DIR:=$(CORE_DIR)/submodules/PICORV32
include $(PICORV32_DIR)/hardware/hardware.mk

#CACHE
# include $(CACHE_DIR)/hardware/hardware.mk
#UART
# include $(UART_DIR)/hardware/hardware.mk



#DEFINES
DEFINE+=DDR_DATA_W=$(DDR_DATA_W)
DEFINE+=DDR_ADDR_W=$(DDR_ADDR_W)

#HEADERS
VHDR+=$(BUILD_VSRC_DIR)/system.vh
$(BUILD_VSRC_DIR)/system.vh: $(ROOT_DIR)/hardware/include/system.vh
	cp $< $@

VHDR+=$(BUILD_VSRC_DIR)/iob_intercon.vh
$(BUILD_VSRC_DIR)/iob_intercon.vh: hardware/include/iob_intercon.vh
	cp $< $@

VHDR+=$(BUILD_VSRC_DIR)/iob_gen_if.vh
$(BUILD_VSRC_DIR)/iob_gen_if.vh: hardware/include/iob_gen_if.vh
	cp $< $(BUILD_VSRC_DIR)

#
# Sources
#

#external memory interface
ifeq ($(USE_DDR),1)
VSRC+=$(BUILD_VSRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(BUILD_VSRC_DIR)/boot_ctr.v $(BUILD_VSRC_DIR)/int_mem.v $(BUILD_VSRC_DIR)/sram.v
VSRC+=$(BUILD_VSRC_DIR)/system.v

$(BUILD_VSRC_DIR)/%.v: $(ROOT_DIR)/hardware/src/%.v
	cp $< $@

# make system.v with peripherals
$(BUILD_VSRC_DIR)/system.v: $(ROOT_DIR)/hardware/src/system_core.v
	$(ROOT_DIR)/software/python/createSystem.py $(ROOT_DIR) "$(GET_DIRS)" "$(PERIPHERALS)"
	cp system.v $@
