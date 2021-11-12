include $(UART_DIR)/config.mk

#block diagram verilog source
BD_VSRC=uart_core.v

#include tex submodule makefile segment
CORE_DIR:=$(UART_DIR)
include $(UART_DIR)/submodules/TEX/document/document.mk
