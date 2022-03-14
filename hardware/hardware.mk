include $(REGFILEIF_DIR)/core.mk

# SUBMODULES

# Interconnect
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
include $(INTERCON_DIR)/hardware/hardware.mk
endif

# Library
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
SUBMODULES+=LIB
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
endif

# hardware include dirs
INCLUDE+=$(incdir)$(REGFILEIF_HW_DIR)/include

# includes
VHDR+=$(wildcard $(REGFILEIF_HW_DIR)/include/*.vh)
VHDR+=REGFILEIFsw_reg.v REGFILEIFsw_reg_gen.v REGFILEIFsw_reg.vh

# sources
VSRC+=$(wildcard $(REGFILEIF_SRC_DIR)/*.v)

#cpu accessible registers
REGFILEIFsw_reg_gen.v REGFILEIFsw_reg.vh: REGFILEIFsw_reg.v
	$(REGFILEIF_DIR)/software/mkregsregfileif.py $< HW $(LIB_DIR)/software
