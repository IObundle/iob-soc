#
# CORE DEFINITIONS FILE
#

CORE_NAME:=UART
IS_CORE:=1
USE_NETLIST ?=0


#SUBMODULE PATHS

ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
INTERCON_DIR:=$(UART_DIR)/submodules/INTERCON
endif

ifneq (LIB,$(filter LIB, $(SUBMODULES)))
LIB_DIR:=$(UART_DIR)/submodules/LIB
endif

ifneq (TEX,$(filter TEX, $(SUBMODULES)))
TEX_DIR:=$(UART_DIR)/submodules/TEX
endif


#UART PATHS
UART_HW_DIR:=$(UART_DIR)/hardware
UART_SW_DIR:=$(UART_DIR)/software
UART_DOC_DIR:=$(UART_DIR)/document


#
#SIMULATION
#
SIM_DIR ?=$(UART_HW_DIR)/simulation

#
#FPGA
#
FPGA_FAMILY ?=CYCLONEV-GT
#FPGA_FAMILY ?=XCKU

#FPGA_SERVER :=localhost
REMOTE_ROOT_DIR ?= sandbox/iob-soc/submodules/UART
FPGA_SERVER ?=pudim-flan.iobundle.com
FPGA_USER ?= $(USER)

ifeq ($(FPGA_FAMILY),XCKU)
	FPGA_COMP:=vivado
	FPGA_PART:=xcku040-fbva676-1-c
else
	FPGA_COMP:=quartus
	FPGA_PART:=5CGTFD9E5F35C7
endif
FPGA_DIR ?=$(UART_HW_DIR)/fpga/$(FPGA_COMP)

ifeq ($(FPGA_COMP),vivado)
FPGA_LOG:=vivado.log
else ifeq ($(FPGA_COMP),quartus)
FPGA_LOG:=quartus.log
endif

#
#DOCUMENT
#
DOC_TYPE:=pb
#DOC_TYPE:=ug
INTEL ?=1
INT_FAMILY ?=CYCLONEV-GT
XILINX ?=1
XIL_FAMILY ?=XCKU
VERSION= 0.1
VLINE:="V$(VERSION)"
$(CORE_NAME)_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt
