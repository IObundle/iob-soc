
ifeq ($(filter PCIE, $(SW_MODULES)),)

SW_MODULES+=PCIE

include $(PCIE_DIR)/software/software.mk

# add embeded sources
SRC+=iob_pcie_swreg_emb.c

iob_pcie_swreg_emb.c: iob_pcie_swreg.h


endif

