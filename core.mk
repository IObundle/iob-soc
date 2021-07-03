#
# CORE DEFINITIONS FILE
#

CORE_NAME:=UART
IS_CORE:=1
USE_NETLIST ?=0

#UART PATHS
UART_HW_DIR:=$(UART_DIR)/hardware
UART_SW_DIR:=$(UART_DIR)/software
UART_DOC_DIR:=$(UART_DIR)/document
UART_SUBMODULES_DIR:=$(UART_DIR)/submodules

#SUBMODULES
UART_SUBMODULES:=INTERCON LIB TEX
$(foreach p, $(UART_SUBMODULES), $(eval $p_DIR ?=$(UART_SUBMODULES_DIR)/$p))

#
#SIMULATION
#
SIM_DIR ?=$(UART_HW_DIR)/simulation

#
#FPGA
#
FPGA_FAMILY ?=CYCLONEV-GT
#FPGA_FAMILY ?=XCKU

REMOTE_ROOT_DIR ?= sandbox/iob-soc/submodules/UART

ifeq ($(FPGA_FAMILY),XCKU)
	FPGA_COMP:=vivado
	FPGA_PART:=xcku040-fbva676-1-c
else
	FPGA_COMP:=quartus
	FPGA_PART:=5CGTFD9E5F35C7
endif
FPGA_DIR ?=$(UART_HW_DIR)/fpga/$(FPGA_COMP)

ifeq ($(FPGA_COMP),vivado)
FPGA_LOG ?=vivado.log
else ifeq ($(FPGA_COMP),quartus)
FPGA_LOG ?=quartus.log
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
