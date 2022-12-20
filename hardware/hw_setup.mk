#
# ADD SUBMODULES HARDWARE
# SUBCORES hardware is copied first, so that possible duplicated source modules
# are overwritten
#
#CPU
PICORV32_DIR:=$(SOC_DIR)/submodules/PICORV32
include $(PICORV32_DIR)/hardware/hw_setup.mk

#CACHE
CACHE_CONFIG ?= iob
include $(CACHE_DIR)/hardware/hw_setup.mk

#UART
include $(UART_DIR)/hardware/hw_setup.mk
