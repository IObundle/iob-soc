include $(UART_DIR)/core.mk

UART_SW_DIR:=$(UART_DIR)/software

#include
INCLUDE+=-I$(UART_SW_DIR)

#headers
HDR+=$(UART_SW_DIR)/*.h

#sources
SRC+=$(UART_SW_DIR)/iob-uart.c

$($(CORE_NAME)_SW_DIR)/$(CORE_NAME)sw_reg.h: $($(CORE_NAME)_HW_INC_DIR)/$(CORE_NAME)sw_reg.v
	$(LIB_DIR)/software/mkregs.py $< SW
	mv $(CORE_NAME)sw_reg.h $@
