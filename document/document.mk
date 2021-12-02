include $(UART_DIR)/config.mk

#block diagram verilog source
BD_VSRC=uart_core.v
MODULE=$(shell make -C $(UART_DIR) corename | grep -v make)

INTEL ?=1
INT_FAMILY ?=CYCLONEV-GT
XILINX ?=1
XIL_FAMILY ?=XCKU

NOCLEAN+=-o -name "test.expected" -o -name "Makefile"

#include tex submodule makefile segment
CORE_DIR:=$(UART_DIR)
TEX_DOC_DIR ?=$(TEX_DIR)/document
include $(TEX_DOC_DIR)/document.mk

test: clean all
	diff -q $(DOC).aux test.expected

.PHONY: test
