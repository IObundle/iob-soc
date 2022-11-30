ifeq ($(filter GPIO, $(HW_MODULES)),)

include $(GPIO_DIR)/config.mk

#add itself to HW_MODULES list
HW_MODULES+=GPIO


GPIO_INC_DIR:=$(GPIO_HW_DIR)/include
GPIO_SRC_DIR:=$(GPIO_HW_DIR)/src


#include files
VHDR+=$(wildcard $(GPIO_INC_DIR)/*.vh)
VHDR+=iob_gpio_swreg_gen.vh iob_gpio_swreg_def.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh $(LIB_DIR)/hardware/include/iob_s_if.vh $(LIB_DIR)/hardware/include/iob_gen_if.vh

#hardware include dirs
INCLUDE+=$(incdir). $(incdir)$(GPIO_INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(wildcard $(GPIO_SRC_DIR)/*.v)

gpio-hw-clean:
	@rm -rf $(GPIO_HW_DIR)/fpga/vivado/XCKU $(GPIO_HW_DIR)/fpga/quartus/CYCLONEV-GT

.PHONY: gpio-hw-clean

endif
