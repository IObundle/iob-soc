
ifeq ($(filter IOBNATIVEBRIDGEIF, $(HW_MODULES)),)

include $(IOBNATIVEBRIDGEIF_DIR)/config.mk

#add itself to HW_MODULES list
HW_MODULES+=IOBNATIVEBRIDGEIF

#LIB dir from regfileif peripheral
LIB_DIR ?=$(REGFILEIF_DIR)/submodules/LIB

#include files
VHDR+=$(wildcard $(IOBNATIVEBRIDGEIF_DIR)/hardware/include/*.vh)
VHDR+=iob_nativebridgeif_swreg_gen.vh iob_nativebridgeif_swreg_def.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh

#hardware include dirs
INCLUDE+=$(incdir). $(incdir)$(IOBNATIVEBRIDGEIF_DIR)/harware/include $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(IOBNATIVEBRIDGEIF_DIR)/hardware/src/iob_nativebridgeif.v

endif
    