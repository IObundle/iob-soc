include $(UART_DIR)/core.mk

#include
INCLUDE+=-I$(UART_SW_DIR)

#headers
HDR+=$(UART_SW_DIR)/*.h $($UART_SW_DIR)/UARTsw_reg.h

#sources
SRC+=$(UART_SW_DIR)/iob-uart.c

$($UART_SW_DIR)/UARTsw_reg.h: $(UART_HW_DIR)/include/UARTsw_reg.v
	$(LIB_DIR)/software/mkregs.py $< SW
