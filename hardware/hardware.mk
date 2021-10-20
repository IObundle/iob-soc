include $(UART_DIR)/core.mk

USE_NETLIST ?=0

#SUBMODULE HARDWARE
#intercon
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
include $(INTERCON_DIR)/hardware/hardware.mk
endif

#lib
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
SUBMODULES+=LIB
INCLUDE+=$(incdir) $(LIB_DIR)/hardware/include
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
endif

#hardware include dirs
INCLUDE+=$(incdir) $(UART_HW_DIR)/include

#UART HARDWARE
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

