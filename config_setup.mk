# core name
NAME=iob_soc
# core version 
VERSION=0070
# include implementation in document (disabled by default)
DOC_RESULTS=

#supported flows
FLOWS := pc-emul emb sim doc

# root directory when building locally
SOC_DIR ?= .
#submodule paths
PICORV32_DIR ?= $(SOC_DIR)/submodules/PICORV32
CACHE_DIR ?= $(SOC_DIR)/submodules/CACHE
UART_DIR ?= $(SOC_DIR)/submodules/UART
LIB_DIR ?= $(SOC_DIR)/submodules/LIB
