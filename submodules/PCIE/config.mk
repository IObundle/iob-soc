
TOP_MODULE=iob_pcie

#PATHS
LIB_DIR ?=$(PCIE_DIR)/submodules/LIB
PCIE_HW_DIR:=$(PCIE_DIR)/hardware

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find -L $(LIB_DIR) -name mkregs.py)

#target to create (and update) swreg for nativebridgeif based on pcie_swreg.conf
$(PCIE_DIR)/mkregs.conf: $(PCIE_DIR)/../../pcie_swreg.vh
	$(PCIE_DIR)/software/python/createPcieSwreg.py $(PCIE_DIR)/../..

#cpu accessible registers
iob_pcie_swreg_def.vh iob_pcie_swreg_gen.vh: $(PCIE_DIR)/mkregs.conf
	$(PCIE_DIR)/software/python/mkregsregfileif.py $< HW $(shell dirname $(MKREGS)) iob_pcie
