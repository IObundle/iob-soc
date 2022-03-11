######################################################################
#
# IOb-SoC Configuration File
#
######################################################################

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS OR OVERRIDEN BY ENV VARS
#

#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W ?=15

#SRAM SIZE (LOG2)
SRAM_ADDR_W ?=15

#DDR
USE_DDR ?=0
RUN_EXTMEM ?=0

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

#PRE-INIT MEMORY WITH PROGRAM AND DATA
INIT_MEM ?=1

#PERIPHERAL LIST
#list with corename of peripherals to be attached to peripheral bus.
#must match the 'corename' target in the Makefile inside the peripheral submodule directory.
#to include multiple instances, write the corename of the peripheral multiple times.
#(Example: 'PERIPHERALS ?=UART UART' will create 2 UART instances)
PERIPHERALS ?=UART

#RISC-V HARD MULTIPLIER AND DIVIDER INSTRUCTIONS
USE_MUL_DIV ?=1

#RISC-V COMPRESSED INSTRUCTIONS
USE_COMPRESSED ?=1


#TESTER SYSTEM
#list with corename of peripherals to be attached to Tester peripheral bus.
TESTER_PERIPHERALS ?=UART UART

#REMOTE MACHINES
#git url for cloning 
GITURL := $(word 2, $(shell git remote -v))
#SUT DIR ON REMOTE MACHINES
REMOTE_SUT_DIR ?=sandbox/iob-soc-sut


#SIMULATION
#default simulator running locally or remotely
#check the respective Makefile in hardware/simulation/$(SIMULATOR) for specific settings
SIMULATOR ?=icarus

#BOARD
#default board running locally or remotely
#check the respective Makefile in hardware/fpga/$(BOARD) for specific settings
BOARD ?=CYCLONEV-GT-DK

#ASIC COMPILATION
#default asic node running locally or remotely
#check the respective Makefile in hardware/asic/$(ASIC_NODE) for specific settings
ASIC_NODE ?=umc130


#DOCUMENTATION
#default document to compile
DOC ?= pb


####################################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE BELOW THIS POINT
####################################################################

ifeq ($(RUN_EXTMEM),1)
DEFINE+=$(defmacro)RUN_EXTMEM
USE_DDR=1
INIT_MEM=0
endif

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
endif

ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM
endif

#sw paths
SW_DIR:=$(SUT_DIR)/software
PC_DIR:=$(SW_DIR)/pc-emul
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console

#hw paths
HW_DIR=$(SUT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)
ASIC_DIR=$(HW_DIR)/asic/$(ASIC_NODE)
TESTER_DIR=$(HW_DIR)/tester
BOARD_DIR ?=$(shell find hardware -name $(BOARD))

#doc paths
DOC_DIR=$(SUT_DIR)/document/$(DOC)
TEX_DIR=$(UART_DIR)/submodules/TEX
INTERCON_DIR=$(UART_DIR)/submodules/INTERCON

#submodule paths
SUBMODULES_DIR=$(SUT_DIR)/submodules
SUBMODULES=
SUBMODULE_DIRS=$(shell ls $(SUBMODULES_DIR))
$(foreach d, $(SUBMODULE_DIRS), $(eval TMP=$(shell make -C $(SUBMODULES_DIR)/$d corename | grep -v make)) $(eval SUBMODULES+=$(TMP)) $(eval $(TMP)_DIR ?=$(SUBMODULES_DIR)/$d))

#define macros
DEFINE+=$(defmacro)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(defmacro)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(defmacro)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(defmacro)DCACHE_ADDR_W=$(DCACHE_ADDR_W)

DEFINE+=$(defmacro)N_SLAVES=$(shell python3 $(SW_DIR)/submodule_utils.py get_n_slaves $(SUT_DIR))

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

DEFINE+=$(shell python3 $(SW_DIR)/submodule_utils.py get_defines $(SUT_DIR) $(defmacro)) 

#RULES
gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
