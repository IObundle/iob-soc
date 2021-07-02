include $(GPIO_DIR)/core.mk

# submodules
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
SUBMODULES+=LIB
include $(LIB_DIR)/hardware/hardware.mk
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
