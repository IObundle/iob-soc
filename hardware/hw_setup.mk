#
# ADD SUBMODULES HARDWARE
# SUBCORES hardware is copied first, so that possible duplicated source modules
# are overwritten
#

include $(SOC_DIR)/config.mk

#LIB
include $(LIB_DIR)/hardware/iob_merge/hw_setup.mk
include $(LIB_DIR)/hardware/iob_split/hw_setup.mk
include $(LIB_DIR)/hardware/rom/iob_rom_sp/hw_setup.mk
include $(LIB_DIR)/hardware/ram/iob_ram_dp_be/hw_setup.mk
include $(LIB_DIR)/hardware/iob_pulse_gen/hw_setup.mk
include $(LIB_DIR)/hardware/include/hw_setup.mk

#CPU
PICORV32_DIR:=$(SOC_DIR)/submodules/PICORV32
include $(PICORV32_DIR)/hardware/hw_setup.mk

#CACHE
include $(CACHE_DIR)/hardware/hw_setup.mk

#UART
include $(UART_DIR)/hardware/hw_setup.mk

#DEFINES
SOC_DEFINE+=DDR_DATA_W=$(DDR_DATA_W)
SOC_DEFINE+=DDR_ADDR_W=$(DDR_ADDR_W)

#HEADER
SRC+=$(BUILD_VSRC_DIR)/iob_soc_conf_base.vh
hardware/src/$(NAME)_conf_$(CONFIG).vh:
	$(LIB_DIR)/scripts/hw_defines.py $@ $(SOC_DEFINE)

#SOURCES
# make system.v with peripherals
SRC+=$(BUILD_VSRC_DIR)/iob_soc.v

$(BUILD_VSRC_DIR)/iob_soc.v: system.v
	cp $< $@

system.v: $(SOC_DIR)/hardware/src/system.vt
	$(LIB_DIR)/scripts/createSystem.py "$(SOC_DIR)" "$(GET_DIRS)" "$(PERIPHERALS)"
