include $(REGFILEIF_DIR)/config.mk

REGFILEIF_SW_DIR:=$(REGFILEIF_DIR)/software

#include
INCLUDE+=

#headers
HDR+=iob_regfileif_swreg_inverted.h

#sources
SRC+=

iob_regfileif_swreg.h iob_regfileif_swreg_inverted.h: $(REGFILEIF_HW_DIR)/include/iob_regfileif_swreg.vh
	$(REGFILEIF_SW_DIR)/python/mkregsregfileif.py $< SW $(shell dirname $(MKREGS)) "REGFILEIF"
