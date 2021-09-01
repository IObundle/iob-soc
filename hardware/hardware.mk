include $(GPIO_DIR)/core.mk

# submodules
#intercon
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
include $(INTERCON_DIR)/hardware/hardware.mk
endif

#lib
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
SUBMODULES+=LIB
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
endif

# hardware include dirs
INCLUDE+=$(incdir)$(GPIO_HW_DIR)/include

# includes
VHDR+=$(wildcard $(GPIO_HW_DIR)/include/*.vh)
VHDR+=$(GPIO_HW_DIR)/include/GPIOsw_reg_gen.v

# sources
VSRC+=$(wildcard $(GPIO_SRC_DIR)/*.v)

# CPU accessible registers
$(GPIO_HW_DIR)/include/GPIOsw_reg_gen.v $(GPIO_HW_DIR)/include/GPIOsw_reg.vh: $(GPIO_HW_DIR)/include/GPIOsw_reg.v
	$(LIB_DIR)/software/mkregs.py $< HW
	mv GPIOsw_reg_gen.v $(GPIO_HW_DIR)/include
	mv GPIOsw_reg.vh $(GPIO_HW_DIR)/include

gpio_clean_hw:
	@rm -rf $(GPIO_FPGA_DIR)/vivado/XCKU $(GPIO_FPGA_DIR)/quartus/CYCLONEV-GT

.PHONY: gpio_clean_hw
