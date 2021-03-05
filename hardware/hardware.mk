include $(UART_DIR)/core.mk

#SUBMODULE HARDWARE
#intercon
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
include $(INTERCON_DIR)/hardware/hardware.mk
SUBMODULES+=INTERCON
endif

#lib
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
INCLUDE+=$(incdir) $(LIB_DIR)/hardware/include
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
SUBMODULES+=LIB
endif

#hardware include dirs
INCLUDE+=$(incdir) $(UART_HW_DIR)/include

#UART HARDWARE
#included files
VHDR+=$(wildcard $(UART_HW_DIR)/include/*.vh)
VHDR+=$(UART_HW_DIR)/include/UARTsw_reg_gen.v
#sources
VSRC+=$(UART_HW_DIR)/src/uart_core.v $(UART_HW_DIR)/src/iob_uart.v


#cpu accessible registers
$(UART_HW_DIR)/include/UARTsw_reg_gen.v $(UART_HW_DIR)/include/UARTsw_reg.vh: $(UART_HW_DIR)/include/UARTsw_reg.v
	$(LIB_DIR)/software/mkregs.py $< HW
	mv UARTsw_reg_gen.v $(UART_HW_DIR)/include
	mv UARTsw_reg.vh $(UART_HW_DIR)/include

uart_clean_hw:
	@rm -rf $(UART_HW_DIR)/include/UARTsw_reg_gen.v $(UART_HW_DIR)/include/UARTsw_reg.vh tmp $(UART_HW_DIR)/fpga/vivado/XCKU $(UART_HW_DIR)/fpga/quartus/CYCLONEV-GT

.PHONY: uart_clean_hw

