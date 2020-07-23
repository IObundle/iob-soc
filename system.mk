#FIRMWARE
FIRM_ADDR_W:=13

#SRAM
SRAM_ADDR_W=13

#DDR
ifeq ($(USE_DDR),)
USE_DDR:=0
endif
ifeq ($(RUN_DDR),)
RUN_DDR:=0
endif

DDR_ADDR_W:=30
CACHE_ADDR_W:=24

#ROM
BOOTROM_ADDR_W:=12

#Init memory (only works in simulation or FPGA not running DDR)
ifeq ($(INIT_MEM),)
INIT_MEM:=1
endif

#Peripheral list (must match respective submodule name)
PERIPHERALS:=UART

#RTL simulator
SIMULATOR:=icarus
#SIMULATOR:=modelsim
#SIMULATOR:=ncsim
#SIM_SERVER:=$(USER)@micro7.lx.it.pt
SIM_ROOT_DIR=$(ROOT_DIR)/sandbox/iob-soc

#FPGA
FPGA_COMPILE_SERVER:=$(USER)@pudim-flan.iobundle.com
FPGA_COMPILE_ROOT_DIR=./sandbox/iob-soc
#FPGA_BOARD:=AES-KU040-DB-G
ifeq ($(FPGA_BOARD),)
FPGA_BOARD:=CYCLONEV-GT-DK
endif
ifeq ($(FPGA_BOARD),CYCLONEV-GT-DK)
FPGA_BOARD_SERVER:=$(USER)@pudim-flan.iobundle.com
else 
FPGA_BOARD_SERVER:=$(USER)@baba-de-camelo.iobundle.com
endif
FPGA_BOARD_ROOT_DIR=$(ROOT_DIR)/sandbox/iob-soc

#ASIC
ASIC_NODE:=umc130
ASIC_COMPILE_SERVER=$(USER)@micro7.lx.it.pt
ASIC_COMPILE_ROOT_DIR=$(ROOT_DIR)/sandbox/iob-soc

#DOC_TYPE
DOC_TYPE:=presentation


#
#DO NOT EDIT BEYOND THIS POINT
#

#object directories
HW_DIR:=$(ROOT_DIR)/hardware
SIM_DIR:=$(HW_DIR)/simulation/$(SIMULATOR)
FPGA_DIR:=$(HW_DIR)/fpga/$(FPGA_BOARD)
ASIC_DIR:=$(HW_DIR)/asic/$(ASIC_NODE)

SW_DIR:=$(ROOT_DIR)/software
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console
PYTHON_DIR:=$(SW_DIR)/python

DOC_DIR:=$(ROOT_DIR)/document/$(DOC_TYPE)


#submodule paths
SUBMODULES_DIR=$(ROOT_DIR)/submodules
CPU_DIR:=$(SUBMODULES_DIR)/iob-picorv32
CACHE_DIR:=$(SUBMODULES_DIR)/iob-cache
INTERCON_DIR:=$(CACHE_DIR)/submodules/iob-interconnect
MEM_DIR:=$(CACHE_DIR)/submodules/iob-mem
AXI_MEM_DIR:=$(CACHE_DIR)/submodules/axi-mem

#defines
DEFINE+=$(define)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(define)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(define)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(define)CACHE_ADDR_W=$(CACHE_ADDR_W)
ifeq ($(USE_DDR),1)
DEFINE+=$(define)USE_DDR
DEFINE+=$(define)DDR_ADDR_W=$(DDR_ADDR_W)
ifeq ($(RUN_DDR),1)
DEFINE+=$(define)RUN_DDR
endif
endif
ifeq ($(INIT_MEM),1)
DEFINE+=$(define)INIT_MEM 
endif
DEFINE+=$(define)N_SLAVES=$(N_SLAVES) 
#address select bits: Extra memory (E), Peripherals (P), Boot controller (B)
DEFINE+=$(define)E=31
DEFINE+=$(define)P=30
DEFINE+=$(define)B=29
ifeq ($(MAKECMDGOALS),)
BAUD:=30000000
else ifeq ($(MAKECMDGOALS),sim)
BAUD:=30000000
else
BAUD:=115200
endif
DEFINE+=$(define)BAUD=$(BAUD)
DEFINE+=$(define)FREQ=100000000
dummy:= $(shell echo $(BAUD))

#run target by default
all: run

#create periph indices and directories
N_SLAVES:=0
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p_DIR:=$(SUBMODULES_DIR)/$p))
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
dummy:=$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$(define)$p=$($p)))

.PHONY: all
