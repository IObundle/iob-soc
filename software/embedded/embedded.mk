UART_SW_DIR:=$(UART_DIR)/software
include $(UART_SW_DIR)/software.mk

INCLUDE+=-I$(UART_SW_DIR)/common
DEFINE+=-DUART=$(UART) -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)
SRC+=$(UART_SW_DIR)/common/iob-uart.c $(UART_SW_DIR)/embedded/iob-uart-platform.c
