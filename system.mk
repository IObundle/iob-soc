#FIRMWARE
FIRM_ADDR_W:=14

#SRAM
SRAM_ADDR_W=14

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

#Init memory (only works in simulation or in FPGA)
ifeq ($(INIT_MEM),)
	INIT_MEM:=0
endif

#Peripheral list (must match respective submodule or folder name in the submodules directory)
PERIPHERALS:=UART TIMER

#SIMULATION TEST
SIM_LIST="SIMULATOR=icarus" "SIMULATOR=ncsim"
#SIM_LIST="SIMULATOR=ncsim"
#SIM_LIST="SIMULATOR=icarus"
LOCAL_SIM_LIST=icarus #leave space in the end

ifeq ($(SIMULATOR),ncsim)
	SIM_SERVER=micro7.lx.it.pt
ifeq ($(SIM_USER),)
	SIM_USER=user19
endif
else
#default
	SIMULATOR:=icarus
endif

#BOARD TEST
BOARD_LIST="BOARD=CYCLONEV-GT-DK" "BOARD=AES-KU040-DB-G"
#BOARD_LIST="BOARD=AES-KU040-DB-G"
#BOARD_LIST="BOARD=CYCLONEV-GT-DK"

#LOCAL_BOARD_LIST=CYCLONEV-GT-DK #leave space in the end
#LOCAL_COMPILER_LIST=CYCLONEV-GT-DK AES-KU040-DB-G

ifeq ($(BOARD),AES-KU040-DB-G)
	COMPILE_USER=$(USER)
	COMPILE_SERVER=pudim-flan.iobundle.com
	COMPILE_OBJ=synth_system.bit
	BOARD_USER=$(USER)
	BOARD_SERVER=baba-de-camelo.iobundle.com
else
#default
	BOARD=CYCLONEV-GT-DK
	COMPILE_SERVER=pudim-flan.iobundle.com
	COMPILE_USER=$(USER)
	COMPILE_OBJ=output_files/top_system.sof
	BOARD_SERVER=pudim-flan.iobundle.com
	BOARD_USER=$(USER)
endif

#ROOT DIR ON REMOTE MACHINES
REMOTE_ROOT_DIR=./sandbox/iob-soc

#ASIC
ASIC_NODE:=umc130

#DOC_TYPE
#DOC_TYPE:=presentation
DOC_TYPE:=pb


#############################################################
#DO NOT EDIT BEYOND THIS POINT
#############################################################

#object directories
HW_DIR:=$(ROOT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)
FPGA_DIR=$(HW_DIR)/fpga/$(BOARD)
ASIC_DIR=$(HW_DIR)/asic/$(ASIC_NODE)


SW_DIR:=$(ROOT_DIR)/software
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console
PYTHON_DIR:=$(SW_DIR)/python

DOC_DIR:=$(ROOT_DIR)/document/$(DOC_TYPE)

#submodule paths
SUBMODULES_DIR=$(ROOT_DIR)/submodules
CPU_DIR:=$(SUBMODULES_DIR)/CPU
CACHE_DIR:=$(SUBMODULES_DIR)/CACHE
INTERCON_DIR:=$(CACHE_DIR)/submodules/iob-interconnect
MEM_DIR:=$(CACHE_DIR)/submodules/iob-mem
AXI_MEM_DIR:=$(CACHE_DIR)/submodules/axi-mem

#defmacros
DEFINE+=$(defmacro)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(defmacro)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(defmacro)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(defmacro)CACHE_ADDR_W=$(CACHE_ADDR_W)

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)
ifeq ($(RUN_DDR),1)
DEFINE+=$(defmacro)RUN_DDR
endif
endif
ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM 
endif
DEFINE+=$(defmacro)N_SLAVES=$(N_SLAVES) 

#address selection bits
E:=31 #extra memory bit
ifeq ($(USE_DDR),1)
P:=30 #periphs
B:=29 #boot controller
else
P:=31
B:=30
endif

DEFINE+=$(defmacro)E=$E
DEFINE+=$(defmacro)P=$P
DEFINE+=$(defmacro)B=$B

SIM_BAUD:=10000000
HW_BAUD:=115200


ifeq ($(word 1, $(MAKECMDGOALS)),fpga)
BAUD:=$(HW_BAUD)
else
BAUD:=$(SIM_BAUD)
endif


DEFINE+=$(defmacro)BAUD=$(BAUD)

ifeq ($(FREQ),) 
DEFINE+=$(defmacro)FREQ=100000000
else
DEFINE+=$(defmacro)FREQ=$(FREQ)
endif


all: usage

usage:
	@echo "INFO: Top target must me defined so that target \"run\" can be found" 
	@echo "      For example, \"make sim INIT_MEM=0\"." 
	@echo "Usage: make target [parameters]"

#create periph indices and directories
N_SLAVES:=0
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p_DIR:=$(SUBMODULES_DIR)/$p))
dummy:=$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
dummy:=$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$(defmacro)$p=$($p)))

#test log
ifneq ($(TEST_LOG),)
LOG=>test.log
endif

.PHONY: all
