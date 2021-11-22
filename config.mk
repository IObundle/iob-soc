MODULE=UART
TOP_MODULE=iob_uart

#PATHS
REMOTE_ROOT_DIR ?= sandbox/iob-soc/submodules/UART
UART_HW_DIR:=$(UART_DIR)/hardware
UART_SW_DIR:=$(UART_DIR)/software
SIM_DIR ?=$(UART_HW_DIR)/simulation
FPGA_DIR ?=$(shell find $($(MODULE)_DIR)/hardware -name $(FPGA_FAMILY))
DOC_DIR ?=$(UART_DIR)/document/$(DOC)
SUBMODULES_DIR:=$(UART_DIR)/submodules

# SUBMODULE PATHS
SUBMODULES=
SUBMODULE_DIRS=$(shell ls $(SUBMODULES_DIR))
$(foreach d, $(SUBMODULE_DIRS), $(eval TMP=$(shell make -C $(SUBMODULES_DIR)/$d corename | grep -v make)) $(eval SUBMODULES+=$(TMP)) $(eval $(TMP)_DIR ?=$(SUBMODULES_DIR)/$d))

#DEFAULT FPGA FAMILY
FPGA_FAMILY ?=CYCLONEV-GT
#FPGA_FAMILY ?=XCKU
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC
DOC ?=pb
#DOC ?=ug
DOC_LIST ?=pb ug

# VERSION
VERSION ?=0.1
VLINE ?="V$(VERSION)"
UART_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt
