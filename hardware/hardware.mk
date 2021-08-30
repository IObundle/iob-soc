include $(ROOT_DIR)/system.mk

#default baud and freq for hardware
BAUD ?=115200
FREQ ?=100000000


#SUBMODULES

#cpu
include $(CPU_DIR)/hardware/hardware.mk

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/hardware/hardware.mk
endif

ifneq ($(ASIC_MEM),1)
#rom
SUBMODULES+=SPROM
SPROM_DIR:=$(CACHE_DIR)/submodules/MEM/sp_rom
VSRC+=$(SPROM_DIR)/sp_rom.v
#ram
SUBMODULES+=TDPRAM
TDPRAM_DIR:=$(CACHE_DIR)/submodules/MEM/tdp_ram
VSRC+=$(TDPRAM_DIR)/iob_tdp_ram.v
endif

#peripherals
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/hardware/hardware.mk))

#HARDWARE PATHS
INC_DIR:=$(HW_DIR)/include
SRC_DIR:=$(HW_DIR)/src

#DEFINES
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)


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
ifneq ($(ASIC_MEM),1)
VSRC+=$(SRC_DIR)/sram.v
endif
VSRC+=system.v

IMAGES=boot.hex firmware.hex

# make system.v with peripherals
system.v:
	cp $(SRC_DIR)/system_core.v $@ # create system.v
	$(foreach p, $(PERIPHERALS), if [ `ls -1 $(SUBMODULES_DIR)/$p/hardware/include/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/pio.v; then sed -i '/PIO/r $(SUBMODULES_DIR)/$p/hardware/include/pio.v' $@; fi;) #insert system IOs for peripheral
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/inst.v; then sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/include/inst.v' $@; fi;) # insert peripheral instances

# make and copy memory init files
boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

firmware.hex: $(FIRM_DIR)/firmware.bin
ifeq ($(RUN_EXTMEM),1)
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(DCACHE_ADDR_W) > firmware.hex
else
	$(PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
endif 
	$(PYTHON_DIR)/hex_split.py firmware .
	cp $(FIRM_DIR)/firmware.bin .

# make embedded sw software
sw:
	make -C $(FIRM_DIR) firmware.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(BOOT_DIR) boot.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(CONSOLE_DIR) INIT_MEM=$(INIT_MEM)

sw-clean:
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean

#clean general hardware files
hw-clean: sw-clean gen-clean
	@rm -f *.v *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v

.PHONY: sw sw-clean hw-clean
