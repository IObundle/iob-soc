UART_DIR:=../..
CORE_DIR:=$(UART_DIR)

#interface signal tables
TAB=rs232_if_tab.tex iob_s_if_tab.tex

#include sowftware accessible registers
SWREGS=1

NOCLEAN=-name "ug.pdf" -o -name "ifsignals.tex" -o -name "sw_reg_tab.tex"

include $(UART_DIR)/document/document.mk

rs232_if_tab.tex: $(UART_HW_DIR)/src/iob_uart.v
	$(LIB_SW_PYTHON_DIR)/io2tex.py $< $@

