INCLUDE+=-I$(UART_DIR)/common
DEFINE+=-DUART=$(UART) -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)
SRC = $(UART_DIR)/common/iob-uart.c $(UART_DIR)/embedded/iob-uart-platform.c
