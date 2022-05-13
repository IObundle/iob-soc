
TOP_MODULE=iob_nativebridgeif

#PATHS
LIB_DIR ?=$(REGFILEIF_DIR)/submodules/LIB
IOBNATIVEBRIDGEIF_HW_DIR:=$(IOBNATIVEBRIDGEIF_DIR)/hardware

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#target to create (and update) swreg for nativebridgeif based on regfileif
$(IOBNATIVEBRIDGEIF_DIR)/mkregs.conf: $(REGFILEIF_DIR)/mkregs.conf
	$(IOBNATIVEBRIDGEIF_DIR)/software/python/createIObNativeIfSwreg.py $(REGFILEIF_DIR)

#cpu accessible registers
iob_nativebridgeif_swreg_def.vh iob_nativebridgeif_swreg_gen.vh: $(IOBNATIVEBRIDGEIF_DIR)/mkregs.conf
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< HW $(shell dirname $(MKREGS)) iob_nativebridgeif

    