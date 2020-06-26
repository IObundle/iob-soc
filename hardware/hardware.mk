UART_HW_DIR:=$(UART_DIR)/hardware

#include
UART_INC_DIR:=$(UART_HW_DIR)/include
INCLUDE+=$(incdir) $(UART_INC_DIR)

#headers
VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)

#sources
UART_SRC_DIR:=$(UART_DIR)/hardware/src
VSRC+=$(wildcard $(UART_HW_DIR)/src/*.v)
