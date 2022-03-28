include $(UART_DIR)/config.mk

#results for intel fpga
INT_FAMILY ?=CYCLONEV-GT

#results for xilinx fpga
XIL_FAMILY ?=XCKU

NOCLEAN+=-o -name "test.expected" -o -name "Makefile"

#PREPARE TO INCLUDE TEX SUBMODULE MAKEFILE SEGMENT
#root directory
CORE_DIR:=$(UART_DIR)

#headers for creating tables
VHDR+=$(FPGA_DIR)/iob_uart_swreg_def.vh
VHDR+=$(UART_HW_DIR)/include/iob_uart_swreg.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_s_if.vh
VHDR+=$(LIB_DIR)/hardware/include/gen_if.vh

#export definitions
export DEFINE

#INCLUDE TEX SUBMODULE MAKEFILE SEGMENT
include $(LIB_DIR)/document/document.mk

test: clean $(DOC).pdf
	diff -q $(DOC).aux test.expected

.PHONY: test
