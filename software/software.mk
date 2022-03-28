include $(REGFILEIF_DIR)/config.mk

REGFILEIF_SW_DIR:=$(REGFILEIF_DIR)/software

#include
INCLUDE+=-I$(REGFILEIF_SW_DIR)

#headers
HDR+=$(REGFILEIF_SW_DIR)/*.h iob_regfileif_swreg.h

#sources
SRC+=

iob_regfileif_swreg.h: $(REGFILEIF_HW_DIR)/include/iob_regfileif_swreg.vh
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< SW $(shell dirname $(MKREGS))
