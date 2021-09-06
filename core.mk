#
# CORE DEFINITIONS FILE
#

CORE_NAME:=UART
TOP_MODULE = iob_uart

DATA_W=32

# UART PATHS
UART_HW_DIR:=$(UART_DIR)/hardware
UART_SW_DIR:=$(UART_DIR)/software
UART_DOC_DIR:=$(UART_DIR)/document
UART_SUBMODULES_DIR:=$(UART_DIR)/submodules

# SUBMODULES
UART_SUBMODULES:=INTERCON LIB TEX
$(foreach p, $(UART_SUBMODULES), $(eval $p_DIR ?=$(UART_SUBMODULES_DIR)/$p))

#
# SIMULATION
#
SIM_DIR ?=$(UART_HW_DIR)/simulation

#
# FPGA
#
FPGA_DIR ?=$(shell find $(UART_DIR)/hardware -name $(FPGA_FAMILY))

FPGA_FAMILY ?=CYCLONEV-GT
#FPGA_FAMILY ?=XCKU

FPGA_FAMILY_LIST = CYCLONEV-GT XCKU

REMOTE_ROOT_DIR ?= sandbox/iob-soc/submodules/UART

#
# DOCUMENTS
#
TEX_DIR ?=$(UART_SUBMODULES_DIR)/TEX

DOC:=pb
#DOC:=ug

DOC_LIST:=pb ug

DOC_DIR:=document/$(DOC)

INTEL ?=1
INT_FAMILY ?=CYCLONEV-GT
XILINX ?=1
XIL_FAMILY ?=XCKU



#
# VERSION
#
VERSION= 0.1
VLINE:="V$(VERSION)"
$(CORE_NAME)_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt
