#gpio common parameters
include $(GPIO_DIR)/software/software.mk


# add pc-emul sources
SRC+=$(GPIO_SW_DIR)/pc-emul/iob_gpio_swreg_pc_emul.c

