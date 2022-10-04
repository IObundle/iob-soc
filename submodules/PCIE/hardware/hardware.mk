
ifeq ($(filter PCIE, $(HW_MODULES)),)

include $(PCIE_DIR)/config.mk

#add itself to HW_MODULES list
HW_MODULES+=PCIE

PCIE_INC_DIR:=$(PCIE_HW_DIR)/include
PCIE_SRC_DIR:=$(PCIE_HW_DIR)/src

#include files
VHDR+=$(wildcard $(PCIE_INC_DIR)/*.vh)
VHDR+=iob_pcie_swreg_gen.vh iob_pcie_swreg_def.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh $(LIB_DIR)/hardware/include/iob_s_if.vh $(LIB_DIR)/hardware/include/iob_gen_if.vh



#hardware include dirs
INCLUDE+=$(incdir). $(incdir)$(PCIE_INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(PCIE_SRC_DIR)/iob_pcie.v

endif
