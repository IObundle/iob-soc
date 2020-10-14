include $(ROOT_DIR)/system.mk

#submodules
include $(CPU_DIR)/hardware/hardware.mk
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/hardware/hardware.mk
else
include $(INTERCON_DIR)/hardware/hardware.mk
endif

#include
INC_DIR:=$(ROOT_DIR)/hardware/include

INCLUDE+=$(incdir). $(incdir)$(INC_DIR)

#headers
VHDR+=$(INC_DIR)/system.vh

#sources
SRC_DIR:=$(ROOT_DIR)/hardware/src

#testbench
TB_DIR:=$(ROOT_DIR)/hardware/testbench

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
VSRC+=system.v

# peripherals
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/hardware/hardware.mk))

# insert peripherals
system.v:
	cp $(SRC_DIR)/system_core.v $@ # create system.v
	$(foreach p, $(PERIPHERALS), if [ `ls -1 $(SUBMODULES_DIR)/$p/hardware/include/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/pio.v; then sed -i '/PIO/r $(SUBMODULES_DIR)/$p/hardware/include/pio.v' $@; fi;) #insert system IOs for peripheral
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/inst.v; then sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/include/inst.v' $@; fi;) # insert peripheral instances


# data files
firmware: $(FIRM_DIR)/firmware.bin
ifeq ($(INIT_MEM),1)
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
	$(PYTHON_DIR)/hex_split.py firmware .
else
	cp $(FIRM_DIR)/firmware.bin .
endif

boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

hw-clean: gen-clean
	@rm -f *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v

.PHONY: firmware hw-clean
