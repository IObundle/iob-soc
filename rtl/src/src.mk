#
# VERILOG SOURCES
#

RAM_VSRC:=$(SRC_DIR)/int_mem.v $(SRC_DIR)/sram.v $(MEM_DIR)/tdp_ram/iob_tdp_ram.v

ifeq ($(USE_DDR),1)
DDR_VSRC:=$(SRC_DIR)/ext_mem.v $(CACHE_DIR)/rtl/src/iob-cache.v \
$(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/reg_file/iob_reg_file.v $(MEM_DIR)/fifo/afifo/afifo.v \
$(MEM_DIR)/sp_ram/iob_sp_mem.v
endif

ROM_VSRC$:=$(MEM_DIR)/sp_rom/sp_rom.v $(SRC_DIR)/boot_ctr.v

VSRC+= \
$(SRC_DIR)/system.v \
$(RISCV_DIR)/picorv32.v \
$(RISCV_DIR)/iob_picorv32.v \
$(UART_DIR)/rtl/src/iob-uart.v \
$(INTERCON_DIR)/rtl/src/merge.v \
$(INTERCON_DIR)/rtl/src/split.v \
$(ROM_VSRC) $(RAM_VSRC) $(DDR_VSRC)

#
# HARDWARE DEFINES
#

HW_DEFINE+=$(define) SRAM_ADDR_W=$(SRAM_ADDR_W)

ifeq ($(USE_DDR),1)
HW_DEFINE+=$(define) USE_DDR
HW_DEFINE+=$(define) DDR_ADDR_W=$(DDR_ADDR_W)
ifeq ($(RUN_DDR),1)
HW_DEFINE+=$(define) RUN_DDR
endif
endif


ifeq ($(USE_BOOT),1)
HW_DEFINE+=$(define) USE_BOOT 
endif

HW_DEFINE+=$(define) BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
HW_DEFINE+=$(define) FIRM_ADDR_W=$(FIRM_ADDR_W)
HW_DEFINE+=$(define) N_SLAVES=$(N_SLAVES)
HW_DEFINE+=$(define) UART=$(UART)

HW_DEFINE+=$(define) E=$(E)
HW_DEFINE+=$(define) P=$(P)
HW_DEFINE+=$(define) B=$(B)


#
# HW INCLUDES
#

HW_INCLUDE := \
$(incdir) . \
$(incdir) $(RTL_DIR)/include \
$(incdir) $(UART_DIR)/rtl/include \
$(incdir) $(CACHE_DIR)/rtl/include \
$(incdir) $(INTERCON_DIR)/rtl/include

