######################################################################
#
# IOb-SoC Configuration File
#
######################################################################

ifneq ($(TESTING_CORE),)
#Use 'IOBTESTER' as the name if we are testing a core.
IOBSOC_NAME:=IOBTESTER
else
IOBSOC_NAME:=IOBSOC
endif

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS OR OVERRIDEN BY ENV VARS
#

#CPU ARCHITECTURE
DATA_W := 32
ADDR_W := 32

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
#to include multiple instances, write the corename of the peripheral multiple times.
#(Example: 'PERIPHERALS ?=UART UART' will create 2 UART instances)
PERIPHERALS ?=UART REGFILEIF

#RISC-V HARD MULTIPLIER AND DIVIDER INSTRUCTIONS
USE_MUL_DIV ?=1

#RISC-V COMPRESSED INSTRUCTIONS
USE_COMPRESSED ?=1

#TESTER SYSTEM
#list with corename of peripherals to be attached to Tester peripheral bus.
TESTER_PERIPHERALS ?=UART UART IOBNATIVEBRIDGEIF

#ROOT DIRECTORY ON REMOTE MACHINES
REMOTE_ROOT_DIR ?=sandbox/iob-soc-tester

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

#IOB LIBRARY
UART_HW_DIR:=$(UART_DIR)/hardware

####################################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE BELOW THIS POINT
####################################################################

ifeq ($(RUN_EXTMEM),1)
DEFINE+=$(defmacro)RUN_EXTMEM
USE_DDR=1
endif

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
endif

ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM
endif


ifneq ($(TESTING_CORE),)
#include tester configuration from core under test directory
include $(ROOT_DIR)/../../tester.mk
#add core under test
PERIPHERALS+=$(CORE_UT)
#add other tester peripherals.
#Note: this is not the variable above. It should be overwritten by the tester.mk cofiguration file in the core under test.
PERIPHERALS+=$(TESTER_PERIPHERALS)
#Set root directory of tester on remote machines in the submodules directory of CUT
REMOTE_ROOT_DIR=$(REMOTE_CUT_DIR)/submodules/$(shell realpath $(ROOT_DIR) | xargs -I {} basename {})
endif

#submodule paths
PICORV32_DIR=$(ROOT_DIR)/submodules/PICORV32
CACHE_DIR=$(ROOT_DIR)/submodules/CACHE
UART_DIR=$(ROOT_DIR)/submodules/UART
LIB_DIR=$(ROOT_DIR)/submodules/LIB
MEM_DIR=$(ROOT_DIR)/submodules/MEM
AXI_DIR=$(ROOT_DIR)/submodules/AXI
ifneq ($(TESTING_CORE),)
#core under test
$(CORE_UT)_DIR=$(ROOT_DIR)/../..
endif

REGFILEIF_DIR=$(ROOT_DIR)/submodules/REGFILEIF
IOBNATIVEBRIDGEIF_DIR=$(ROOT_DIR)/submodules/IOBNATIVEBRIDGEIF

#sw paths
SW_DIR:=$(ROOT_DIR)/software
PC_DIR:=$(SW_DIR)/pc-emul
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console

#hw paths
HW_DIR=$(ROOT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)
ASIC_DIR=$(HW_DIR)/asic/$(ASIC_NODE)
TESTER_DIR=$(HW_DIR)/tester
BOARD_DIR ?=$(shell find hardware -name $(BOARD))

#doc paths
DOC_DIR=$(ROOT_DIR)/document/$(DOC)

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP:=$(ROOT_DIR))\
          $(eval ROOT_DIR=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $V=$($V);))\
          $(eval ROOT_DIR:=$(ROOT_DIR_TMP))

#define macros
DEFINE+=$(defmacro)DATA_W=$(DATA_W)
DEFINE+=$(defmacro)ADDR_W=$(ADDR_W)
DEFINE+=$(defmacro)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(defmacro)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(defmacro)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(defmacro)DCACHE_ADDR_W=$(DCACHE_ADDR_W)
DEFINE+=$(defmacro)N_SLAVES=$(shell $(SW_DIR)/python/submodule_utils.py get_n_slaves "$(PERIPHERALS)") #peripherals
DEFINE+=$(defmacro)N_SLAVES_W=$(shell $(SW_DIR)/python/submodule_utils.py get_n_slaves_w "$(PERIPHERALS)")

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

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
DEFINE+=$(shell $(SW_DIR)/python/submodule_utils.py get_defines "$(PERIPHERALS)" $(defmacro))

N_SLAVES_W = $(shell echo "import math; print(math.ceil(math.log($(N_SLAVES),2)))"|python3 )
DEFINE+=$(defmacro)N_SLAVES_W=$(N_SLAVES_W)


#default baud and system clock freq
BAUD=5000000
FREQ=100000000

SHELL = /bin/bash

#RULES
gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
