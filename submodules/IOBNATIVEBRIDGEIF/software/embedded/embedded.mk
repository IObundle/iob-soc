
ifeq ($(filter IOBNATIVEBRIDGEIF, $(SW_MODULES)),)

SW_MODULES+=IOBNATIVEBRIDGEIF

include $(IOBNATIVEBRIDGEIF_DIR)/software/software.mk

#embeded sources
SRC+=$(IOBNATIVEBRIDGEIF_DIR)/software/embedded/iob-nativebridgeif.c

endif
    