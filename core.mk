CORE_NAME:=REGFILEIF
IS_CORE:=1
USE_NETLIST ?=0
TOP_MODULE:=iob_regfileif

#REGFILEIF ADDRESS WIDTH
REGFILEIF_ADDR_W ?=2

#PATHS
REGFILEIF_HW_DIR:=$(REGFILEIF_DIR)/hardware
REGFILEIF_INC_DIR:=$(REGFILEIF_HW_DIR)/include
REGFILEIF_SRC_DIR:=$(REGFILEIF_HW_DIR)/src
REGFILEIF_TB_DIR:=$(REGFILEIF_HW_DIR)/testbench
REGFILEIF_FPGA_DIR:=$(REGFILEIF_HW_DIR)/fpga
REGFILEIF_SUBMODULES_DIR:=$(REGFILEIF_DIR)/submodules

#SUBMODULES
REGFILEIF_SUBMODULES:=MEM INTERCON LIB
$(foreach p, $(REGFILEIF_SUBMODULES), $(eval $p_DIR ?=$(REGFILEIF_SUBMODULES_DIR)/$p))

REMOTE_ROOT_DIR ?=sandbox/iob-regfileif

#SIMULATION
SIMULATOR ?=icarus
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
FPGA_DIR ?= $(REGFILEIF_DIR)/hardware/fpga/$(FPGA_COMP)
ifeq ($(FPGA_COMP),vivado)
FPGA_LOG:=vivado.log
else ifeq ($(FPGA_COMP),quartus)
FPGA_LOG:=quartus.log
endif

XILINX ?=1
INTEL ?=1

VLINE:="V$(VERSION)"
$(CORE_NAME)_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt
