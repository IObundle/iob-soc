include $(UART_DIR)/config.mk

USE_NETLIST ?=0

#add itself to MODULES list
MODULES+=UART

#include submodule's hardware
$(foreach p, $(SUBMODULES_TMP), $(if $(filter $p, $(MODULES)),,$(eval include $($p_DIR)/hardware/hardware.mk)))


#UART HARDWARE

#hardware include dirs
INCLUDE+=$(incdir) $(UART_HW_DIR)/include

#included files
VHDR+=$(wildcard $(UART_HW_DIR)/include/*.vh)
VHDR+=UARTsw_reg_gen.v UARTsw_reg.vh
#sources
VSRC+=$(UART_HW_DIR)/src/uart_core.v $(UART_HW_DIR)/src/iob_uart.v

#cpu accessible registers
UARTsw_reg_gen.v UARTsw_reg.vh: $(UART_HW_DIR)/include/UARTsw_reg.v
	$(LIB_DIR)/software/mkregs.py $< HW

uart_clean_hw:
	@rm -rf $(UART_HW_DIR)/include/UARTsw_reg_gen.v \
	$(UART_HW_DIR)/include/UARTsw_reg.vh tmp

.PHONY: uart_clean_hw

