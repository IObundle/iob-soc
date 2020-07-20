include $(ROOT_DIR)/hardware/hardware.mk

MEMW_DIR=$(HW_DIR)/src/wrapper
ROM_DIR=$(ASIC_DIR)/memory/bootrom
RAM_DIR=$(ASIC_DIR)/memory/sram

CASE=TC

# Memory sizes in log2
MEM_SIZE_ROM:=$(shell echo '$(BOOTROM_ADDR_W)-2' | bc)
MEM_SIZE_RAM:=$(shell echo '$(SRAM_ADDR_W)-2' | bc)