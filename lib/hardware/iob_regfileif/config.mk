# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

TOP_MODULE=iob_regfileif

#PATHS
LIB_DIR ?=$(REGFILEIF_DIR)/submodules/LIB
REGFILEIF_HW_DIR:=$(REGFILEIF_DIR)/hardware

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#Check that configuration file exists
ifeq (,$(wildcard $(ROOT_DIR)/sut_csrs.vh))
    $(error Missing 'sut_csrs.vh' configuration file in root directory!)
endif

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#cpu accessible registers
iob_regfileif_csrs_def.vh iob_regfileif_csrs_gen.vh: $(REGFILEIF_DIR)/mkregs.conf
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< HW $(shell dirname $(MKREGS)) iob_regfileif 

regfileif-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: regfileif-gen-clean
