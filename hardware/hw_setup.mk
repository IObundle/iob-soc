#
# ADD SUBMODULES HARDWARE
# SUBCORES hardware is copied first, so that possible duplicated source modules
# are overwritten
#

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
#select cache configuration
CACHE_CONFIG:=iob
include $(CACHE_DIR)/hardware/hw_setup.mk

#UART
include $(UART_DIR)/hardware/hw_setup.mk


#SOURCES

# make iob_soc top with CPU memory and peripherals
SRC+=$(BUILD_VSRC_DIR)/iob_soc.v

$(BUILD_VSRC_DIR)/iob_soc.v: $(SOC_DIR)/hardware/src/system.vt
	$(LIB_DIR)/scripts/createSystem.py "$(SOC_DIR)" "$(PERIPHERALS)" "$@"

