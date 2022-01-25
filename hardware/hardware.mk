ifeq ($(filter $(UART_NAME), $(MODULES)),)

#add itself to MODULES list
MODULES+=$(shell make -C $(UART_DIR) corename | grep -v make)

include $(UART_DIR)/config.mk

USE_NETLIST ?=0

#include files
VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)
VHDR+=UARTsw_reg_gen.vh UARTsw_reg_def.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh

#hardware include dirs
INCLUDE+=$(incdir)$(UART_INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(UART_SRC_DIR)/uart_core.v $(UART_SRC_DIR)/iob_uart.v

#cpu accessible registers
UARTsw_reg_gen.vh UARTsw_reg_def.vh: $(UART_INC_DIR)/UARTsw_reg.vh
	$(MKREGS) $< HW

.PHONY: uart_clean_hw

endif
