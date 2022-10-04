
include $(PCIE_DIR)/config.mk

PCIE_SW_DIR:=$(PCIE_DIR)/software

#include
INCLUDE+=

#headers
HDR+=iob_pcie_swreg.h

#sources
SRC+=

iob_pcie_swreg.h iob_pcie_inverted_swreg.h: $(PCIE_DIR)/mkregs.conf
	$(PCIE_DIR)/software/python/mkregsregfileif.py $< SW $(shell dirname $(MKREGS)) iob_pcie
