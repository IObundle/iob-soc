#
# ADD SUBMODULES HARDWARE
# SUBCORES hardware is copied first, so that possible duplicated source modules
# are overwritten
#

#LIB
include $(LIB_DIR)/hardware/iob_merge/hardware.mk
include $(LIB_DIR)/hardware/iob_split/hardware.mk
include $(LIB_DIR)/hardware/rom/iob_rom_sp/hardware.mk
include $(LIB_DIR)/hardware/ram/iob_ram_dp_be/hardware.mk
include $(LIB_DIR)/hardware/iob_pulse_gen/hardware.mk
include $(LIB_DIR)/hardware/include/hardware.mk

#CPU
PICORV32_DIR:=$(SOC_DIR)/submodules/PICORV32
include $(PICORV32_DIR)/hardware/hardware.mk

#CACHE
include $(CACHE_DIR)/hardware/hardware.mk

#UART
include $(UART_DIR)/hardware/hardware.mk



#DEFINES
DEFINE+=DDR_DATA_W=$(DDR_DATA_W)
DEFINE+=DDR_ADDR_W=$(DDR_ADDR_W)

#HEADERS
SRC+=$(BUILD_VSRC_DIR)/system.vh
$(BUILD_VSRC_DIR)/system.vh: $(SOC_DIR)/hardware/include/system.vh
	cp $< $@

SRC+=$(BUILD_VSRC_DIR)/iob_soc.vh
$(BUILD_VSRC_DIR)/iob_soc.vh:
	$(LIB_DIR)/software/python/hw_defines.py  $@ $(SOC_DEFINE)

SRC+=$(BUILD_VSRC_DIR)/iob_intercon.vh
$(BUILD_VSRC_DIR)/iob_intercon.vh: $(LIB_DIR)/hardware/include/iob_intercon.vh
	cp $< $@

#
# Sources
#

#external memory interface
ifeq ($(USE_DDR),1)
SRC+=$(BUILD_VSRC_DIR)/ext_mem.v
endif

#system
SRC+=$(BUILD_VSRC_DIR)/boot_ctr.v $(BUILD_VSRC_DIR)/int_mem.v $(BUILD_VSRC_DIR)/sram.v
$(BUILD_VSRC_DIR)/%.v: $(SOC_DIR)/hardware/src/%.v
	cp $< $@

# make system.v with peripherals
SRC+=$(BUILD_VSRC_DIR)/system.v
$(BUILD_VSRC_DIR)/system.v: $(SOC_DIR)/hardware/src/system_core.v
	$(SOC_DIR)/software/python/createSystem.py $(SOC_DIR) "$(GET_DIRS)" "$(PERIPHERALS)" && mv system.v $@

#
# Scripts
#
# console script
SRC+=$(BUILD_SW_PYTHON_DIR)/console
$(BUILD_SW_PYTHON_DIR)/console: $(LIB_DIR)/software/python/console
	cp $< $@
