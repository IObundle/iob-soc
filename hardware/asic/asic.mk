#DEFINES

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=$(FPGA_DDR_ADDR_W)

include $(ROOT_DIR)/hardware/hardware.mk

MEMORIES_DIR=$(ASIC_DIR)/memory
BOOTROM_DIR=$(MEMORIES_DIR)/bootrom
SRAM_DIR=$(MEMORIES_DIR)/sram

CASE=TC

# Memory sizes in log2
BOOTROM_W:=$(shell echo '$(BOOTROM_ADDR_W)-2' | bc)
SRAM_W:=$(shell echo '$(SRAM_ADDR_W)-2' | bc)

BOOTROM_WORDS:=$(shell echo '2^($(BOOTROM_W))' | bc)
SRAM_WORDS:=$(shell echo '2^($(SRAM_W))' | bc)

# Memories' wrappers
VSRC+=bootrom.v sram.v

all: mems synth

mems: bootrom sram
ifneq ($(ASIC_SERVER),)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_LEFS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_LIBS) .
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/hardware/asic/$(ASIC_NODE)/$(ASIC_MEM_SIM_MODELS) .
endif
	make fix-mems

bootrom: sw gen-bootrom

sram: gen-sram

synth: system_synth.v

.PHONY: all \
	mems bootrom sram \
	synth
