#FIRMWARE
FIRM_ADDR_W:=13

#SRAM
SRAM_ADDR_W=13

#DDR
USE_DDR:=1
RUN_DDR:=1
DDR_ADDR_W:=30

#BOOT
USE_BOOT:=1
BOOTROM_ADDR_W:=12

#Number of slaves (peripherals)
N_SLAVES:=1

#Peripheral IDs (assign serially: 0, 1, 2, etc)
UART:=0

#RTL simulator
SIMULATOR:=icarus
#SIMULATOR:=modelsim
#SIMULATOR:=ncsim

#FPGA
FPGA_BOARD:=AES-KU040-DB-G
#FPGA_BOARD:=CYCLONEV-GT-DK
FPGA_COMPILER_SERVER=$(PUDIM)

ifeq (FPGA_BOARD,AES-KU040-DB-G)
FPGA_BOARD_SERVER=$(BABA)
else ifeq (FPGA_BOARD,CYCLONEV-GT-DK)
FPGA_BOARD_SERVER=$(PUDIM)
endif

#ASIC node
ASIC_NODE:=umc130

#DOC_TYPE
DOC_TYPE:=presentation

#server list
PUDIM:=146.193.44.48
BABA:=146.193.44.179


#
#DO NOT EDIT BEYOND THIS POINT
#

#object directories
FIRM_DIR:=$(ROOT_DIR)/software/firmware
BOOT_DIR:=$(ROOT_DIR)/software/bootloader
SIM_DIR:=$(ROOT_DIR)/hardware/simulation/$(SIMULATOR)
FPGA_DIR:=$(ROOT_DIR)/hardware/fpga/$(FPGA_BOARD)
ASIC_DIR:=$(ROOT_DIR)/hardware/asic/$(ASIC_NODE)
DOC_DIR:=$(ROOT_DIR)/document/$(DOC_TYPE)
PYTHON_DIR:=$(ROOT_DIR)/software/python


#submodule paths
SUBMODULES_DIR:=$(ROOT_DIR)/submodules
CPU_DIR:=$(SUBMODULES_DIR)/iob-picorv32
UART_DIR:=$(SUBMODULES_DIR)/iob-uart
CACHE_DIR:=$(SUBMODULES_DIR)/iob-cache
INTERCON_DIR:=$(CACHE_DIR)/submodules/iob-interconnect
MEM_DIR:=$(CACHE_DIR)/submodules/iob-mem
AXI_MEM_DIR:=$(CACHE_DIR)/submodules/axi-mem

#defines
DEFINE+=$(define)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(define)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(define)FIRM_ADDR_W=$(FIRM_ADDR_W)
ifeq ($(USE_DDR),1)
DEFINE+=$(define)USE_DDR
DEFINE+=$(define)DDR_ADDR_W=$(DDR_ADDR_W)
ifeq ($(RUN_DDR),1)
DEFINE+=$(define)RUN_DDR
endif
endif
ifeq ($(USE_BOOT),1)
DEFINE+=$(define)USE_BOOT=$(USE_BOOT) 
endif
DEFINE+=-DPROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
DEFINE+=$(define)N_SLAVES=$(N_SLAVES) 
DEFINE+=$(define)UART=$(UART)
#address select bits: Extra memory (E), Peripherals (P), Boot controller (B)
DEFINE+=$(define)E=31
DEFINE+=$(define)P=30
DEFINE+=$(define)B=29
ifeq ($(CMDGOALS),)
BAUD:=30000000
FREQ:=100000000
else ifeq ($(CMDGOALS),sim)
BAUD:=30000000
FREQ:=100000000
else
BAUD:=115200
FREQ:=100000000
endif
DEFINE+=$(define)BAUD=$(BAUD)
DEFINE+=$(define)FREQ=$(FREQ)
