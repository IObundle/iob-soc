include $(GPIO_DIR)/config.mk

GPIO_SW_DIR:=$(GPIO_DIR)/software

#include
INCLUDE+=-I$(GPIO_SW_DIR)

#headers
HDR+=$(GPIO_SW_DIR)/*.h iob_gpio_swreg.h

#sources
SRC+=$(GPIO_SW_DIR)/iob-gpio.c

iob_gpio_swreg.h: $(GPIO_DIR)/mkregs.conf
	$(MKREGS) iob_gpio $(GPIO_DIR) SW
