UART_HW_DIR:=$(UART_DIR)/hardware

#submodules
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
INTERCON_DIR:=$(UART_DIR)/submodules/INTERCON
include $(INTERCON_DIR)/hardware/hardware.mk
endif

#include
UART_INC_DIR:=$(UART_HW_DIR)/include
INCLUDE+=$(incdir) $(UART_INC_DIR)

#headers
VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)

#sources
VSRC+=$(wildcard $(UART_HW_DIR)/src/*.v)
