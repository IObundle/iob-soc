# File paths
ROOT_DIR:=../../..
RTL_DIR:=$(ROOT_DIR)/rtl
FIRM_DIR:=$(ROOT_DIR)/software/firmware
BOOT_DIR:=$(ROOT_DIR)/software/bootloader
LD_SW_DIR:=$(ROOT_DIR)/software/ld-sw
PYTHON_DIR:=$(ROOT_DIR)/software/python

SUBMODULES_DIR:=$(ROOT_DIR)/submodules
RISCV_DIR:=$(SUBMODULES_DIR)/picorv32
UART_DIR:=$(SUBMODULES_DIR)/uart
MEM_DIR:=$(SUBMODULES_DIR)/mem
CACHE_DIR:=$(SUBMODULES_DIR)/cache
AXI_RAM_DIR:=$(SUBMODULES_DIR)/axi-mem
INTERCON_DIR:=$(SUBMODULES_DIR)/interconnect

#hw defines
include $(ROOT_DIR)/system.mk

ifeq ($(CPU),PICORV32)
HW_DEFINE += $(define) PICORV32
endif

ifeq ($(CPU),DARKRV)
HW_DEFINE += $(define) DARKRV
endif

ifeq ($(USE_LA_IF),1)
HW_DEFINE += $(define) USE_LA_IF
endif

ifeq ($(USE_SRAM),1)
HW_DEFINE += $(define) USE_SRAM $(define) SRAM_ADDR_W=$(SRAM_ADDR_W)
endif

ifeq ($(USE_DDR),1)
HW_DEFINE += $(define) USE_DDR
endif

ifeq ($(RUN_DDR),1)
HW_DEFINE += $(define) RUN_DDR
endif

ifeq ($(USE_BOOT),1)
HW_DEFINE += $(define) USE_BOOT $(define) BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
endif

HW_DEFINE+=$(define) DDR_ADDR_W=$(DDR_ADDR_W)
HW_DEFINE+=$(define) N_SLAVES=$(N_SLAVES)
HW_DEFINE+=$(define) UART=$(UART)

#hw includes
HW_INCLUDE := $(incdirs) . $(RTL_DIR)/include $(UART_DIR)/rtl/include \
$(CACHE_DIR)/rtl/include $(INTERCON_DIR)/rtl/include

ifeq ($(USE_SRAM),1)
RAM_VSRC:=$(RTL_DIR)/src/int_mem.v $(RTL_DIR)/src/ram.v $(MEM_DIR)/tdp_ram/iob_tdp_ram.v
endif

ifeq ($(USE_DDR),1)
DDR_VSRC:=$(RTL_DIR)/src/ext_mem.v $(CACHE_DIR)/rtl/src/iob-cache.v \
$(AXI_RAM_DIR)/rtl/axi_ram.v $(MEM_DIR)/reg_file/iob_reg_file.v $(MEM_DIR)/fifo/afifo/afifo.v \
$(MEM_DIR)/sp_ram/iob_sp_mem.v
endif

ifeq ($(USE_BOOT),1)
ROM_VSRC$:=$(MEM_DIR)/sp_rom/sp_rom.v $(RTL_DIR)/src/boot_ctr.v
endif

#hardware sources
VSRC = \
system.vh \
verilog/top_system.v \
$(RTL_DIR)/src/system.v \
$(RISCV_DIR)/picorv32.v \
$(RISCV_DIR)/iob_picorv32.v \
$(UART_DIR)/rtl/include/iob-uart.vh \
$(UART_DIR)/rtl/src/iob-uart.v \
$(INTERCON_DIR)/rtl/include/interconnect.vh \
$(INTERCON_DIR)/rtl/src/merge.v \
$(INTERCON_DIR)/rtl/src/split.v \
$(ROM_VSRC) $(RAM_VSRC) $(DDR_VSRC)
