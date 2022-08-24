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
P:=30 #periphs

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $(eval TMP_VAR:=$(subst ROOT_DIR,ROOT_DIR_TMP,$(value $V)))$V=$(TMP_VAR);))
