ifeq ($(filter UART, $(HW_MODULES)),)

include $(UART_DIR)/config.mk

#add itself to HW_MODULES list
HW_MODULES+=UART


UART_INC_DIR:=$(UART_HW_DIR)/include
UART_SRC_DIR:=$(UART_HW_DIR)/src

USE_NETLIST ?=0

#include files
VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)
VHDR+=iob_uart_swreg_gen.vh iob_uart_swreg_def.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh

#hardware include dirs
INCLUDE+=$(incdir). $(incdir)$(UART_INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(UART_SRC_DIR)/uart_core.v $(UART_SRC_DIR)/iob_uart.v

uart-hw-clean: uart-gen-clean
	@rm -f *.v *.vh

.PHONY: uart-hw-clean

endif
