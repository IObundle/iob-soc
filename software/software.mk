include $(UART_DIR)/core.mk

UART_SW_DIR:=$(UART_DIR)/software

#include
INCLUDE+=-I$(UART_SW_DIR)

#headers
HDR+=$(UART_SW_DIR)/*.h

#sources
SRC+=$(UART_SW_DIR)/iob-uart.c

