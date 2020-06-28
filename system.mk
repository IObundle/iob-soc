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

#Peripheral list (must match respective submodule name)
PERIPHERALS:=UART

#RTL simulator
#SIMULATOR:=icarus
#SIMULATOR:=modelsim
SIMULATOR:=ncsim

#FPGA
FPGA_BOARD:=AES-KU040-DB-G
#FPGA_BOARD:=CYCLONEV-GT-DK
FPGA_COMPILER_SERVER=$(PUDIM)

#ASIC node
ASIC_NODE:=umc130

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
DEFINE+=$(define)PROG_SIZE=$(shell wc -c $(FIRM_DIR)/firmware.bin | head -n1 | cut -d " " -f1)
DEFINE+=$(define)N_SLAVES=$(N_SLAVES) 
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


#run target by default
all: run

#create periph indices and directories
N_SLAVES:=0
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p_DIR:=$(SUBMODULES_DIR)/$p))
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
dummy:=$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$(define)$p=$($p)))

ifeq ($(FPGA_BOARD),AES-KU040-DB-G)
FPGA_BOARD_SERVER=$(BABA)
else ifeq ($(FPGA_BOARD),CYCLONEV-GT-DK)
FPGA_BOARD_SERVER=$(PUDIM)
endif

#server list
PUDIM:=146.193.44.48
BABA:=146.193.44.179

