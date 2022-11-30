ifeq ($(filter GPIO, $(SW_MODULES)),)

SW_MODULES+=GPIO

include $(GPIO_DIR)/software/software.mk

# add embeded sources
SRC+=iob_gpio_swreg_emb.c

iob_gpio_swreg_emb.c: iob_gpio_swreg.h

endif
