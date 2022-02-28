UART_DIR:=../..
CORE_DIR:=$(UART_DIR)

NOCLEAN=-name "ug.pdf" -o -name "if.tex" -o -name "swreg.tex" -o -name "swop.tex" -o -name "inst.tex"

figures:
	mkdir -p ./figures
	cp -r -u $(LIB_DIR)/document/figures/* ../figures/* ./figures

include $(UART_DIR)/document/document.mk
