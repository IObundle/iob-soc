# SOC DEFINES
SOC_DEFINE+=DATA_W=32
SOC_DEFINE+=ADDR_W=32
SOC_DEFINE+=FIRM_ADDR_W=15
SOC_DEFINE+=SRAM_ADDR_W=15
SOC_DEFINE+=BOOTROM_ADDR_W=12

# list of defines that have the same value regardless of system configuration
SOC_DEFINE+=USE_MUL_DIV=1
SOC_DEFINE+=USE_COMPRESSED=1
SOC_DEFINE+=E=31 #select secondary data memory
SOC_DEFINE+=P=30 #select peripheral space
SOC_DEFINE+=B=29 #select boot controller

#PERIPHERAL LIST
#list with corename of peripherals to be attached to peripheral bus.
#to include multiple instances, write the corename of the peripheral multiple times.
#to pass verilog parameters to each instance, type the parameters inside parenthesis.
#Example: 'PERIPHERALS ?=UART[1,\"textparam\"] UART UART' will create 3 UART instances, 
#         the first one will be instantiated with verilog parameters 1 and "textparam", 
#         the second and third will use default parameters.
PERIPHERALS ?=UART

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
SOC_DEFINE+=$(shell $(SOC_DIR)/software/python/submodule_utils.py get_defines "$(PERIPHERALS)" "")
SOC_DEFINE+=N_SLAVES=$(shell $(SOC_DIR)/software/python/submodule_utils.py get_n_slaves "$(PERIPHERALS)") #peripherals
SOC_DEFINE+=N_SLAVES_W=$(shell $(SOC_DIR)/software/python/submodule_utils.py get_n_slaves_w "$(PERIPHERALS)")

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $(eval TMP_VAR:=$(subst ROOT_DIR,ROOT_DIR_TMP,$(value $V)))$V=$(TMP_VAR);))

#PRE-INIT MEMORY WITH PROGRAM AND DATA
INIT_MEM ?=1

#DDR
USE_DDR ?=0
RUN_EXTMEM ?=0

#RISC-V HARD MULTIPLIER AND DIVIDER INSTRUCTIONS
USE_MUL_DIV=1

#RISC-V COMPRESSED INSTRUCTIONS
USE_COMPRESSED=1

#default baud and system clock frequency
SIM_BAUD = 2500000
SIM_FREQ =50000000

#default baud and frequency if not given
BAUD ?=$(SIM_BAUD)
FREQ ?=$(SIM_FREQ)

# #CPU ARCHITECTURE
DATA_W := 32
# ADDR_W := 32

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

FIRM_ADDR_W=15
BOOTROM_ADDR_W=12

