
include $(IOBNATIVEBRIDGEIF_DIR)/config.mk

IOBNATIVEBRIDGEIF_SW_DIR:=$(IOBNATIVEBRIDGEIF_DIR)/software

#include
INCLUDE+=

#headers
HDR+=iob_nativebridgeif_swreg.h

#sources
SRC+=

iob_nativebridgeif_swreg.h iob_nativebridgeif_swreg_inverted.h: $(IOBNATIVEBRIDGEIF_HW_DIR)/include/iob_nativebridgeif_swreg.vh
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< SW $(shell dirname $(MKREGS)) "IOBNATIVEBRIDGEIF"
    