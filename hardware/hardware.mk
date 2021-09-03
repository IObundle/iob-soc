include $(REGFILEIF_DIR)/core.mk

# submodules
# Dual-port register file
ifneq (DPREGFILE,$(filter DPREGFILE, $(SUBMODULES)))
SUBMODULES+=DPREGFILE
DPREGFILE_DIR:=$(MEM_DIR)/dp_reg_file
VSRC+=$(DPREGFILE_DIR)/iob_dp_reg_file.v
endif

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

# defines
DEFINE+=$(defmacro)REGFILEIF_ADDR_W=$(REGFILEIF_ADDR_W)

# includes
VHDR+=$(wildcard $(REGFILEIF_HW_DIR)/include/*.vh)
VHDR+=$(REGFILEIF_HW_DIR)/include/REGFILEIFsw_reg_gen.v

# sources
VSRC+=$(wildcard $(REGFILEIF_SRC_DIR)/*.v)

# CPU accessible registers
$(REGFILEIF_HW_DIR)/include/REGFILEIFsw_reg_gen.v $(REGFILEIF_HW_DIR)/include/REGFILEIFsw_reg.vh: $(REGFILEIF_HW_DIR)/include/REGFILEIFsw_reg.v
	$(LIB_DIR)/software/mkregs.py $< HW
	mv REGFILEIFsw_reg_gen.v $(REGFILEIF_HW_DIR)/include
	mv REGFILEIFsw_reg.vh $(REGFILEIF_HW_DIR)/include

regfileif_clean_hw:
	@rm -rf $(REGFILEIF_FPGA_DIR)/vivado/XCKU $(REGFILEIF_FPGA_DIR)/quartus/CYCLONEV-GT

.PHONY: regfileif_clean_hw
