include $(UART_DIR)/software/software.mk

#submodule
include $(INTERCON_DIR)/software/software.mk

#embeded sources
SRC+=$(UART_SW_DIR)/embedded/iob-uart-platform.c
