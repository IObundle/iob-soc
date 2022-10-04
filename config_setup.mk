# core name
NAME=iob_soc
# core version 
VERSION=0070
# include implementation in document (disabled by default)
DOC_RESULTS=

# root directory when building locally
SOC_DIR ?= .
#submodule paths
PICORV32_DIR ?= $(SOC_DIR)/submodules/PICORV32
CACHE_DIR ?= $(SOC_DIR)/submodules/CACHE
UART_DIR ?= $(SOC_DIR)/submodules/UART
LIB_DIR ?= $(SOC_DIR)/submodules/LIB

#PERIPHERAL LIST
#list with corename of peripherals to be attached to peripheral bus.
#to include multiple instances, write the corename of the peripheral multiple times.
#to pass verilog parameters to each instance, type the parameters inside parenthesis.
#Example: 'PERIPHERALS ?=UART[1,\"textparam\"] UART UART' will create 3 UART instances, 
#         the first one will be instantiated with verilog parameters 1 and "textparam", 
#         the second and third will use default parameters.
PERIPHERALS ?=UART

# default configuration
CONFIG ?= base

# needed for periphs_tmp.py script
P=30

SOC_DEFINE+=DATA_W=32
SOC_DEFINE+=ADDR_W=32
SOC_DEFINE+=FIRM_ADDR_W=15
SOC_DEFINE+=SRAM_ADDR_W=15
SOC_DEFINE+=BOOTROM_ADDR_W=12
SOC_DEFINE+=USE_MUL_DIV=1
SOC_DEFINE+=USE_COMPRESSED=1
SOC_DEFINE+=E=31 #select secondary data memory
SOC_DEFINE+=P=30 #select peripheral space
SOC_DEFINE+=B=29 #select boot controller
SOC_DEFINE+=INIT_MEM=1 #pre-init memory with program and data
SOC_DEFINE+=RUN_EXTMEM=0
SOC_DEFINE+=DCACHE_ADDR_W=24
SOC_DEFINE+=DDR_DATA_W=32
SOC_DEFINE+=DDR_ADDR_W_SIM=24
SOC_DEFINE+=DDR_ADDR_W_HW=30
SOC_DEFINE+=BAUD_HW=115200
SOC_DEFINE+=BAUD_SIM=5000000
SOC_DEFINE+=FREQ=100000000

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
SOC_DEFINE+=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_periphs_id "$(PERIPHERALS)" "")

SOC_DEFINE+=N_SLAVES=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_n_periphs "$(PERIPHERALS)") #peripherals
SOC_DEFINE+=N_SLAVES_W=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_n_periphs_w "$(PERIPHERALS)")
