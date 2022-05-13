
include $(IOBNATIVEBRIDGEIF_DIR)/config.mk

IOBNATIVEBRIDGEIF_SW_DIR:=$(IOBNATIVEBRIDGEIF_DIR)/software

#include
INCLUDE+=

#headers
HDR+=iob_nativebridgeif_swreg.h

#sources
SRC+=

iob_nativebridgeif_swreg.h iob_nativebridgeif_inverted_swreg.h: $(IOBNATIVEBRIDGEIF_DIR)/mkregs.conf
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< SW $(shell dirname $(MKREGS)) iob_nativebridgeif
    