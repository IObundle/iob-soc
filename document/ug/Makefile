UART_DIR:=../..
CORE_DIR:=$(UART_DIR)

include $(UART_DIR)/core.mk

include $(UART_DIR)/submodules/TEX/document/document.mk

bd_tab.tex: $(UART_HW_DIR)/src/iob_uart.v $(UART_HW_DIR)/src/uart_core.v
	$(TEX_SW_DIR)/block2tex.py $@ $^

rs232_is_tab.tex: $(UART_HW_DIR)/src/iob_uart.v
	$(TEX_SW_DIR)/io2tex.py $< $@

.PHONY: clean
