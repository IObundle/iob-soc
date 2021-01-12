#
# CORE DEFINITIONS FILE
#


CORE_NAME=UART
IS_CORE:=1
USE_NETLIST ?=0

#PATHS
UART_HW_DIR:=$(UART_DIR)/hardware
UART_HW_INC_DIR:=$(UART_HW_DIR)/include
UART_DOC_DIR:=$(UART_DIR)/document
UART_SUBMODULES_DIR:=$(UART_DIR)/submodules
LIB_DIR ?= $(UART_SUBMODULES_DIR)/LIB
TEX_DIR ?= $(UART_SUBMODULES_DIR)/TEX

REMOTE_ROOT_DIR ?= sandbox/iob-soc/submodules/UART

#
#SIMULATION
#
SIMULATOR ?=icarus
SIM_SERVER ?=localhost
SIM_USER ?=$(USER)

#SIMULATOR ?=ncsim
#SIM_SERVER ?=micro7.lx.it.pt
#SIM_USER ?=user19

SIM_DIR ?=hardware/simulation/$(SIMULATOR)

#
#FPGA
#
FPGA_FAMILY ?=CYCLONEV-GT
#FPGA_FAMILY ?=XCKU
#FPGA_SERVER :=localhost
FPGA_SERVER ?=pudim-flan.iobundle.com
FPGA_USER ?= $(USER)

ifeq ($(FPGA_FAMILY),XCKU)
	FPGA_COMP:=vivado
	FPGA_PART:=xcku040-fbva676-1-c
else
	FPGA_COMP:=quartus
	FPGA_PART:=5CGTFD9E5F35C7
endif
FPGA_DIR ?=$(UART_DIR)/hardware/fpga/$(FPGA_COMP)

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
