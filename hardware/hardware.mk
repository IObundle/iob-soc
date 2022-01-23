include $(UART_DIR)/config.mk

USE_NETLIST ?=0

#add itself to MODULES list
MODULES+=$(shell make -C $(UART_DIR) corename | grep -v make)

#include submodule's hardware
$(foreach p, $(SUBMODULES), $(if $(filter $p, $(MODULES)),,$(eval include $($p_DIR)/hardware/hardware.mk)))


#UART HARDWARE

#hardware include dirs
INCLUDE+=$(incdir)$(UART_INC_DIR)

#included files
VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)
VHDR+=UARTsw_reg_gen.v UARTsw_reg.vh
VHDR+=$(UART_INC_DIR)/UARTsw_reg.v 
#sources
VSRC+=$(UART_SRC_DIR)/uart_core.v $(UART_SRC_DIR)/iob_uart.v

#cpu accessible registers
UARTsw_reg_gen.v UARTsw_reg.vh: $(UART_INC_DIR)/UARTsw_reg.v
	$(LIB_DIR)/software/python/mkregs.py $< HW

uart_clean_hw:
	@rm -rf $(UART_INC_DIR)/UARTsw_reg_gen.v \
	$(UART_INC_DIR)/UARTsw_reg.vh tmp

.PHONY: uart_clean_hw

