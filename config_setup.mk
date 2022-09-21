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
