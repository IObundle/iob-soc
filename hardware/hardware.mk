include $(ROOT_DIR)/system.mk

# submodules
include $(CPU_DIR)/hardware/hardware.mk
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/hardware/hardware.mk
else
include $(INTERCON_DIR)/hardware/hardware.mk
endif

# include
INC_DIR:=$(ROOT_DIR)/hardware/include

INCLUDE+=$(incdir). $(incdir)$(INC_DIR)

#headers
VHDR+=$(INC_DIR)/system.vh

# sources
SRC_DIR:=$(ROOT_DIR)/hardware/src

#rom
VSRC+=$(SRC_DIR)/boot_ctr.v \
$(MEM_DIR)/sp_rom/sp_rom.v 

#ram
VSRC+=$(SRC_DIR)/int_mem.v \
$(SRC_DIR)/sram.v \
$(MEM_DIR)/tdp_ram/iob_tdp_ram.v

#ddr
ifeq ($(USE_DDR),1)
VSRC+=$(SRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(SRC_DIR)/system.v

# peripherals
periphs:
	$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/hardware/hardware.mk))

$(SRC_DIR)/system.v:
	cp $(SRC_DIR)/system_core.v $@
	$(foreach p, $(PERIPHERALS), sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/include/inst.v' $(SRC_DIR)/system.v;)
	$(foreach p, $(PERIPHERALS), sed -i '/PIO/r $(SUBMODULES_DIR)/$p/hardware/include/pio.v' $(SRC_DIR)/system.v;)
	$(foreach p, $(PERIPHERALS), sed -i '/PHEADER/a `include \"$(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`)\"' $(SRC_DIR)/system.v;)\

# data files
firmware.hex: $(FIRM_DIR)/firmware.bin
ifeq ($(INIT_MEM),1)
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
	$(PYTHON_DIR)/hex_split.py firmware .
else
	cp $(FIRM_DIR)/firmware.bin .
endif

boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

hw-clean:
	@rm -f *# *~ *.vcd *.dat *.hex *.bin $(SRC_DIR)/system.v

.PHONY: periphs hw-clean


