SHELL:=/bin/bash

TOP_MODULE=iob_gpio

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-gpio
SIM_DIR ?=$(GPIO_HW_DIR)/simulation/$(SIMULATOR)
FPGA_DIR ?=$(GPIO_DIR)/hardware/fpga/$(FPGA_COMP)
DOC_DIR ?=

LIB_DIR ?=$(GPIO_DIR)/submodules/LIB
GPIO_HW_DIR:=$(GPIO_DIR)/hardware

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#DEFAULT FPGA FAMILY AND FAMILY LIST
FPGA_FAMILY ?=XCKU
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC AND DOC LIST
DOC ?=pb
DOC_LIST ?=pb ug

# default target
default: sim

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#cpu accessible registers
iob_gpio_swreg_def.vh iob_gpio_swreg_gen.vh: $(GPIO_DIR)/mkregs.conf
	$(MKREGS) iob_gpio $(GPIO_DIR) HW

gpio-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: default gpio-gen-clean
