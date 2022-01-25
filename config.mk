UART_NAME = UART
TOP_MODULE=iob_uart

#PATHS
REMOTE_ROOT_DIR ?= sandbox/iob-uart

UART_HW_DIR:=$(UART_DIR)/hardware
UART_INC_DIR:=$(UART_HW_DIR)/include
UART_SRC_DIR:=$(UART_HW_DIR)/src

SIM_DIR ?=$(UART_SIM_DIR)
UART_SIM_DIR:=$(UART_HW_DIR)/simulation
UART_TB_DIR:=$(UART_SIM_DIR)/testbench

UART_SW_DIR:=$(UART_DIR)/software

FPGA_DIR ?=$(shell find $(UART_DIR)/hardware -name $(FPGA_FAMILY))

DOC_DIR ?=$(UART_DIR)/document/$(DOC)

LIB_DIR ?= $(UART_DIR)/submodules/LIB

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#DEFAULT FPGA FAMILY
FPGA_FAMILY ?=CYCLONEV-GT
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC
DOC ?=pb
DOC_LIST ?=pb ug

# VERSION
VERSION ?=0.1
VLINE ?="V$(VERSION)"
UART_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt
