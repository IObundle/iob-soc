
# Library
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
SUBMODULES+=LIB
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
endif

# hardware include dirs
INCLUDE+=$(incdir)$(NATIVEBRIDGEIF_DIR)/hardware/include

# includes
VHDR+=$(wildcard $(NATIVEBRIDGEIF_DIR)/hardware/include/*.vh)

# sources
VSRC+=$(NATIVEBRIDGEIF_DIR)/hardware/src/iob_nativebridgeif.v
    