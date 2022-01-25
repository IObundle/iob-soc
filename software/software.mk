include $(UART_DIR)/config.mk

MODULES+=UART

#include
INCLUDE+=-I$(UART_SW_DIR)

#headers
HDR+=$(UART_SW_DIR)/*.h UARTsw_reg.h

#sources
SRC+=$(UART_SW_DIR)/iob-uart.c

UARTsw_reg.h: $(UART_HW_DIR)/include/UARTsw_reg.vh
	$(MKREGS) $< SW
