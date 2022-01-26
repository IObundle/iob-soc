include $(UART_DIR)/config.mk

#block diagram verilog source
BD_VSRC=uart_core.v
CORENAME=UART

INTEL ?=1
INT_FAMILY ?=CYCLONEV-GT
XILINX ?=1
XIL_FAMILY ?=XCKU

NOCLEAN+=-o -name "test.expected" -o -name "Makefile"

#include tex submodule makefile segment
CORE_DIR:=$(UART_DIR)
LIB_DOC_DIR ?=$(LIB_DIR)/document
include $(LIB_DOC_DIR)/document.mk

test: clean all
	diff -q $(DOC).aux test.expected

.PHONY: test
