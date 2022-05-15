include $(REGFILEIF_DIR)/config.mk

REGFILEIF_SW_DIR:=$(REGFILEIF_DIR)/software

#include
INCLUDE+=

#headers
HDR+=iob_regfileif_inverted_swreg.h

#sources
SRC+=

iob_regfileif_swreg.h iob_regfileif_inverted_swreg.h: $(REGFILEIF_DIR)/mkregs.conf
	$(REGFILEIF_SW_DIR)/python/mkregsregfileif.py $< SW $(shell dirname $(MKREGS)) iob_regfileif
