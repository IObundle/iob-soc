include $(ROOT_DIR)/system.mk

# INCLUDE
INCLUDE:=$(incdir) $(HW_DIR)/include

# VERILOG SOURCES

SRC_DIR:=$(HW_DIR)/src

ROM_VSRC$:=$(SRC_DIR)/boot_ctr.v $(MEM_DIR)/sp_rom/sp_rom.v 

RAM_VSRC:=$(SRC_DIR)/int_mem.v $(SRC_DIR)/sram.v $(MEM_DIR)/tdp_ram/iob_tdp_ram.v

ifeq ($(USE_DDR),1)
DDR_VSRC:=$(SRC_DIR)/ext_mem.v $(CACHE_DIR)/rtl/src/iob-cache.v \
$(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/reg_file/iob_reg_file.v $(MEM_DIR)/fifo/afifo/afifo.v \
$(MEM_DIR)/sp_ram/iob_sp_mem.v
endif

VSRC+= $(SRC_DIR)/system.v $(ROM_VSRC) $(RAM_VSRC) $(DDR_VSRC)

# DATA FILES

firmware:
	cp $(FIRM_DIR)/firmware.hex .
	cp $(FIRM_DIR)/firmware.bin .
	$(PYTHON_DIR)/hex_split.py firmware

boot:
	cp $(BOOT_DIR)/boot.hex .
	cp $(BOOT_DIR)/boot.hex boot.dat
	$(PYTHON_DIR)/hex_split.py boot

#
# SUBMODULES
#

include $(CPU_DIR)/hardware/hardware.mk
include $(UART_DIR)/hardware/hardware.mk
include $(INTERCON_DIR)/hardware/hardware.mk
