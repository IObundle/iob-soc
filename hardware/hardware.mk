include $(ROOT_DIR)/system.mk

#SUBMODULES

#cpu
include $(CPU_DIR)/hardware/hardware.mk

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/hardware/hardware.mk
endif

#rom
ifneq ($(ASIC),1)
SUBMODULES+=SPROM
SPROM_DIR:=$(CACHE_DIR)/submodules/MEM/sp_rom
VSRC+=$(SPROM_DIR)/sp_rom.v
endif

#ram
ifneq ($(ASIC),1)
SUBMODULES+=TDPRAM
TDPRAM_DIR:=$(CACHE_DIR)/submodules/MEM/tdp_ram
VSRC+=$(TDPRAM_DIR)/iob_tdp_ram.v
endif

#peripherals
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/hardware/hardware.mk))

#HARDWARE PATHS
INC_DIR:=$(HW_DIR)/include
SRC_DIR:=$(HW_DIR)/src

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(INC_DIR)

#HEADERS
VHDR+=$(INC_DIR)/system.vh

#SOURCES
#testbench
TB_DIR:=$(ROOT_DIR)/hardware/testbench

#external memory interface
ifeq ($(USE_DDR),1)
VSRC+=$(SRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(SRC_DIR)/boot_ctr.v $(SRC_DIR)/int_mem.v
ifneq ($(ASIC),1)
VSRC+=$(SRC_DIR)/sram.v
endif
VSRC+=system.v

# make system.v with peripherals
system.v:
	cp $(SRC_DIR)/system_core.v $@ # create system.v
	$(foreach p, $(INSTANCES), if [ `ls -1 $(INST_DIR)/$p/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $(INST_DIR)/$p/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(INSTANCES), if test -f $(INST_DIR)/$p/pio.v; then sed -i '/PIO/r $(INST_DIR)/$p/pio.v' $@; fi;) #insert system IOs for peripheral
	$(foreach p, $(INSTANCES), if test -f $(INST_DIR)/$p/inst.v; then sed -i '/endmodule/e cat $(INST_DIR)/$p/inst.v' $@; fi;) # insert peripheral instances

# make and copy memory init files
firmware: $(FIRM_DIR)/firmware.bin
ifeq ($(INIT_MEM),1)
ifeq ($(RUN_DDR),1)
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(DCACHE_ADDR_W) > firmware.hex
else
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
endif 
	$(PYTHON_DIR)/hex_split.py firmware .
else
	cp $(FIRM_DIR)/firmware.bin .
endif

boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

#clean general hardware files
hw-clean: gen-clean
	@rm -f *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v

.PHONY: firmware hw-clean
