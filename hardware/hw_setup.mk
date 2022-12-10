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
include $(LIB_DIR)/hardware/iob_tasks/hw_setup.mk

#CPU
PICORV32_DIR:=$(SOC_DIR)/submodules/PICORV32
include $(PICORV32_DIR)/hardware/hw_setup.mk

#CACHE
CACHE_CONFIG ?= iob
include $(CACHE_DIR)/hardware/hw_setup.mk

#UART
include $(UART_DIR)/hardware/hw_setup.mk


#SOURCES

#Build version file required by cache # FIXME: this is probably not the best solution
SRC+=$(BUILD_VSRC_DIR)/iob_cache_version.vh
$(BUILD_VSRC_DIR)/iob_cache_version.vh: $(CACHE_DIR)/config_setup.mk
	env -C $(CACHE_DIR) -- $(LIB_DIR)/scripts/version.py -v . -o $(shell realpath --relative-to $(CACHE_DIR) $(@D))

# make iob_soc top with CPU memory and peripherals
SRC+=$(BUILD_VSRC_DIR)/iob_soc.v
$(BUILD_VSRC_DIR)/iob_soc.v: $(SOC_DIR)/hardware/src/system.vt

# generate axi ports
SRC+=$(BUILD_VSRC_DIR)/iob_soc_axi_m_port.vh
$(BUILD_VSRC_DIR)/iob_soc_axi_m_port.vh:
	$(AXI_GEN) axi_m_port $(@D)/iob_soc_ --top

# generate portmap for axi instance
SRC+=$(BUILD_VSRC_DIR)/iob_soc_axi_m_m_portmap.vh
$(BUILD_VSRC_DIR)/iob_soc_axi_m_m_portmap.vh:
	$(AXI_GEN) axi_m_m_portmap $(@D)/iob_soc_
