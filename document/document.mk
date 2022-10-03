include $(ROOT_DIR)/config.mk

#RESULTS
#results for intel FPGA
INT_FAMILY ?=CYCLONEV-GT-DK
#results for xilinx fpga
XIL_FAMILY ?=AES-KU040-DB-G

NOCLEAN+=-o -name "test.expected" -o -name "Makefile"

#PREPARE TO INCLUDE TEX SUBMODULE MAKEFILE SEGMENT
#root directory
CORE_DIR:=$(ROOT_DIR)

BDTAB=0
SWREGS=0

include $(LIB_DIR)/document/document.mk

test: clean-all $(DOC).pdf

clean-all: clean
	rm -f $(DOC).pdf

.PHONY: test clean-all
