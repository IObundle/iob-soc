include $(UART_DIR)/config.mk

UART_SW_DIR:=$(UART_DIR)/software

#include
INCLUDE+=-I$(UART_SW_DIR)

#headers
HDR+=$(UART_SW_DIR)/*.h iob_uart_swreg.h

#sources
SRC+=$(UART_SW_DIR)/iob-uart.c

iob_uart_swreg.h: $(UART_HW_DIR)/include/iob_uart_swreg.vh
	$(MKREGS) $< SW UART
