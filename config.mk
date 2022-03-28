TOP_MODULE=iob_regfileif

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-regfileif
REGFILEIF_FPGA_DIR:=$(REGFILEIF_HW_DIR)/fpga
REGFILEIF_INC_DIR:=$(REGFILEIF_HW_DIR)/include
REGFILEIF_SRC_DIR:=$(REGFILEIF_HW_DIR)/src
REGFILEIF_TB_DIR:=$(REGFILEIF_HW_DIR)/testbench

LIB_DIR ?=$(REGFILEIF_DIR)/submodules/LIB
REGFILEIF_HW_DIR:=$(REGFILEIF_DIR)/hardware

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#Check that configuration file exists
ifeq (,$(wildcard $(ROOT_DIR)/iob_regfileif_swreg.vh))
    $(error Missing 'iob_regfileif_swreg.vh' configuration file in root directory!)
endif

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#cpu accessible registers
iob_regfileif_swreg_def.vh iob_regfileif_swreg_gen.vh: $(REGFILEIF_HW_DIR)/include/iob_regfileif_swreg.vh
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< HW $(shell dirname $(MKREGS))

regfileif-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: regfileif-gen-clean
