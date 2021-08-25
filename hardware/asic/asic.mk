#DEFINES

include $(ROOT_DIR)/hardware/hardware.mk

MEMORIES_DIR=$(ASIC_DIR)/$(ASIC_NODE)/memory
SYNTH_DIR=$(ASIC_DIR)/$(ASIC_NODE)/synth
PR_DIR=$(ASIC_DIR)/$(ASIC_NODE)/pr

MEMW_DIR=$(HW_DIR)/src/wrapper
ROM_DIR=$(MEMORIES_DIR)/bootrom
RAM_DIR=$(MEMORIES_DIR)/sram

CASE=TC

# Memory sizes in log2
MEM_SIZE_ROM:=$(shell echo '$(BOOTROM_ADDR_W)-2' | bc)
MEM_SIZE_RAM:=$(shell echo '$(SRAM_ADDR_W)-2' | bc)
