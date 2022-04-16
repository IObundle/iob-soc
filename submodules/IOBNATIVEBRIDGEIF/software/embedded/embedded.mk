
ifeq ($(filter IOBNATIVEBRIDGEIF, $(SW_MODULES)),)

SW_MODULES+=IOBNATIVEBRIDGEIF

include $(IOBNATIVEBRIDGEIF_DIR)/software/software.mk

# add embeded sources
SRC+=iob_nativebridgeif_swreg_emb.c

iob_nativebridgeif_swreg_emb.c: iob_nativebridgeif_swreg.h
	

endif
    