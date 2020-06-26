UART_HW_DIR:=$(UART_DIR)/hardware

#include
UART_INC_DIR:=$(UART_HW_DIR)/include
INCLUDE+=$(incdir) $(UART_INC_DIR)

#headers
VHDR+=$(UART_INC_DIR)/*.vh

#sources
UART_SRC_DIR:=$(UART_DIR)/hardware/src
VSRC+=$(UART_HW_DIR)/src/*.v
