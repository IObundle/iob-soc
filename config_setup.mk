SOC_DIR=.
#submodule paths
PICORV32_DIR=$(SOC_DIR)/submodules/PICORV32
CACHE_DIR=$(SOC_DIR)/submodules/CACHE
UART_DIR=$(SOC_DIR)/submodules/UART
LIB_DIR=$(SOC_DIR)/submodules/LIB

SIMULATOR=verilator
BOARD=CYCLONEV-GT-DK

#PERIPHERAL LIST
#list with corename of peripherals to be attached to peripheral bus.
#to include multiple instances, write the corename of the peripheral multiple times.
#to pass verilog parameters to each instance, type the parameters inside parenthesis.
#Example: 'PERIPHERALS ?=UART[1,\"textparam\"] UART UART' will create 3 UART instances, 
#         the first one will be instantiated with verilog parameters 1 and "textparam", 
#         the second and third will use default parameters.
PERIPHERALS ?=UART

#address selection bits
E:=31 #extra memory bit
P:=30 #periphs
B:=29 #boot controller

# SOC DEFINES
# list of defines that have the same value regardless of system configuration
SOC_DEFINE+=USE_MUL_DIV=1
SOC_DEFINE+=USE_COMPRESSED=1
SOC_DEFINE+=E=$E
SOC_DEFINE+=P=$P
SOC_DEFINE+=B=$B

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
SOC_DEFINE+=$(shell $(SOC_DIR)/software/python/submodule_utils.py get_defines "$(PERIPHERALS)" "")
SOC_DEFINE+=N_SLAVES=$(shell $(SOC_DIR)/software/python/submodule_utils.py get_n_slaves "$(PERIPHERALS)") #peripherals
SOC_DEFINE+=N_SLAVES_W=$(shell $(SOC_DIR)/software/python/submodule_utils.py get_n_slaves_w "$(PERIPHERALS)")

SOC_DEFINE+=DATA_W=32
SOC_DEFINE+=ADDR_W=32
SOC_DEFINE+=FIRM_ADDR_W=15
SOC_DEFINE+=SRAM_ADDR_W=15
SOC_DEFINE+=BOOTROM_ADDR_W=12

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $(eval TMP_VAR:=$(subst ROOT_DIR,ROOT_DIR_TMP,$(value $V)))$V=$(TMP_VAR);))
