# core name
NAME=iob_soc
# core version 
VERSION=0010
# top-leel module
TOP_MODULE?=system
# core path as seen from LIB's makefile
ROOT_DIR=$(CORE_DIR)

SETUP_SW=1
SETUP_SIM=1
SETUP_FPGA=0
SETUP_DOC=0

#PERIPHERAL LIST
#list with corename of peripherals to be attached to peripheral bus.
#to include multiple instances, write the corename of the peripheral multiple times.
#to pass verilog parameters to each instance, type the parameters inside parenthesis.
#Example: 'PERIPHERALS ?=UART[1,\"textparam\"] UART UART' will create 3 UART instances, 
#         the first one will be instantiated with verilog parameters 1 and "textparam", 
#         the second and third will use default parameters.
PERIPHERALS ?=UART

#submodule paths
PICORV32_DIR=$(ROOT_DIR)/submodules/PICORV32
CACHE_DIR=$(ROOT_DIR)/submodules/CACHE
UART_DIR=$(ROOT_DIR)/submodules/UART
LIB_DIR=$(ROOT_DIR)/submodules/LIB

#address selection bits
E:=31 #extra memory bit
P:=30 #periphs
B:=29 #boot controller

DEFINE+=E=$E
DEFINE+=P=$P
DEFINE+=B=$B

#kill "console", the background running program seriving simulators,
#emulators and boards
#used by fpga and pc-emul makefiles
CNSL_PID:=ps aux | grep $(USER) | grep console | grep python3 | grep -v grep
kill-cnsl:
	@if [ "`$(CNSL_PID)`" ]; then \
	kill -9 $$($(CNSL_PID) | awk '{print $$2}'); fi

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
DEFINE+=$(shell $(ROOT_DIR)/software/python/submodule_utils.py get_defines "$(PERIPHERALS)" "$(defmacro)")

DEFINE+=$(defmacro)N_SLAVES=$(shell $(ROOT_DIR)/software/python/submodule_utils.py get_n_slaves "$(PERIPHERALS)") #peripherals
DEFINE+=$(defmacro)N_SLAVES_W=$(shell $(ROOT_DIR)/software/python/submodule_utils.py get_n_slaves_w "$(PERIPHERALS)")

#RISC-V HARD MULTIPLIER AND DIVIDER INSTRUCTIONS
USE_MUL_DIV ?=1

#RISC-V COMPRESSED INSTRUCTIONS
USE_COMPRESSED ?=1

#default baud and system clock frequency
SIM_BAUD = 2500000
SIM_FREQ =50000000

#default baud and frequency if not given
BAUD ?=$(SIM_BAUD)
FREQ ?=$(SIM_FREQ)

#CPU ARCHITECTURE
DATA_W := 32
ADDR_W := 32

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W ?=15

#SRAM SIZE (LOG2)
SRAM_ADDR_W ?=15

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

DEFINE+=DATA_W=$(DATA_W)
DEFINE+=ADDR_W=$(ADDR_W)
DEFINE+=FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=N_SLAVES=$(N_SLAVES) #peripherals

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $(eval TMP_VAR:=$(subst ROOT_DIR,ROOT_DIR_TMP,$(value $V)))$V=$(TMP_VAR);))
