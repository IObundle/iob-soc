CORE_NAME:=GPIO
IS_CORE:=1
USE_NETLIST ?=0
TOP_MODULE:=iob_gpio

#PATHS
GPIO_HW_DIR:=$(GPIO_DIR)/hardware
GPIO_INC_DIR:=$(GPIO_HW_DIR)/include
GPIO_SRC_DIR:=$(GPIO_HW_DIR)/src
GPIO_TB_DIR:=$(GPIO_HW_DIR)/testbench
GPIO_FPGA_DIR:=$(GPIO_HW_DIR)/fpga
GPIO_SUBMODULES_DIR:=$(GPIO_DIR)/submodules

#SUBMODULES
GPIO_SUBMODULES:=LIB TEX
$(foreach p, $(GPIO_SUBMODULES), $(eval $p_DIR ?=$(GPIO_SUBMODULES_DIR)/$p))

REMOTE_ROOT_DIR ?=sandbox/iob-gpio

#SIMULATION
SIMULATOR ?=icarus
SIM_SERVER ?=localhost
SIM_USER ?=$(USER)
SIM_DIR ?=hardware/simulation/$(SIMULATOR)

#FPGA
FPGA_FAMILY ?=XCKU
FPGA_USER ?=$(USER)
FPGA_SERVER ?=pudim-flan.iobundle.com
ifeq ($(FPGA_FAMILY),XCKU)
        FPGA_COMP:=vivado
        FPGA_PART:=xcku040-fbva676-1-c
else #default; ifeq ($(FPGA_FAMILY),CYCLONEV-GT)
        FPGA_COMP:=quartus
        FPGA_PART:=5CGTFD9E5F35C7
endif
FPGA_DIR ?= $(GPIO_DIR)/hardware/fpga/$(FPGA_COMP)
ifeq ($(FPGA_COMP),vivado)
FPGA_LOG:=vivado.log
else ifeq ($(FPGA_COMP),quartus)
FPGA_LOG:=quartus.log
endif

#ASIC
ASIC_NODE ?=umc130
ASIC_SERVER ?=micro5.lx.it.pt
ASIC_COMPILE_ROOT_DIR ?=$(ROOT_DIR)/sandbox/iob-gpio
ASIC_USER ?=user14
ASIC_DIR ?=hardware/asic/$(ASIC_NODE)

XILINX ?=1
INTEL ?=1

VLINE:="V$(VERSION)"
$(CORE_NAME)_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt
