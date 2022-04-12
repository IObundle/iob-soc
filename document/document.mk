include $(ROOT_DIR)/config.mk

#RESULTS
#results for intel FPGA
INT_FAMILY ?=CYCLONEV-GT-DK
#results for xilinx fpga
XIL_FAMILY ?=AES-KU040-DB-G
#results for asic nodes
ASIC_NODE=

NOCLEAN+=-o -name "test.expected" -o -name "Makefile"

#PREPARE TO INCLUDE TEX SUBMODULE MAKEFILE SEGMENT
#root directory
CORE_DIR:=$(ROOT_DIR)

BDTAB=0
SWREGS=0

include $(LIB_DIR)/document/document.mk


test: clean-all
ifeq ($(DOC),pb)
	make -C $(ROOT_DIR) fpga-test
endif
	make $(DOC).pdf


$(DOC).pdf
	make doc-build 
diff -q $(DOC).aux test.expected

clean-all: clean
	rm -f $(DOC).pdf

test-clean:
	make doc-clean DOC=presentation
	make doc-clean DOC=pb

.PHONY: test clean-all

