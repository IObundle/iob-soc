UART_DIR:=../..
CORE_DIR:=$(UART_DIR)
include $(UART_DIR)/core.mk

#interface signal tables 
TAB := rs232_is_tab.tex cpu_nat_s_is_tab.tex cpu_axi4lite_s_is_tab.tex


#block diagram verilog source
BD_VSRC=uart_core.v


#include tex makefile segment
include $(UART_DIR)/submodules/TEX/document/document.mk

rs232_is_tab.tex: $(UART_HW_DIR)/src/iob_uart.v
	$(TEX_SW_DIR)/io2tex.py $< $@

cpu_nat_s_is_tab.tex: $(INTERCON_DIR)/hardware/include/cpu_nat_s_if.v $(TEX_DOC_DIR)/ug/cpu_nat_s_is.tex
	$(TEX_SW_DIR)/io2tex.py $< $@

cpu_axi4lite_s_is_tab.tex: $(INTERCON_DIR)/hardware/include/cpu_axi4lite_s_if.v $(TEX_DOC_DIR)/ug/cpu_axi4lite_s_is.tex
	$(TEX_SW_DIR)/io2tex.py $< $@
