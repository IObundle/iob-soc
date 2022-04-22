include $(AXISTREAMIN_DIR)/config.mk

#results for intel fpga
INT_FAMILY ?=CYCLONEV-GT

#results for xilinx fpga
XIL_FAMILY ?=XCKU

NOCLEAN+=-o -name "test.expected" -o -name "Makefile"

#PREPARE TO INCLUDE TEX SUBMODULE MAKEFILE SEGMENT
#root directory
CORE_DIR:=$(AXISTREAMIN_DIR)

#headers for creating tables
VHDR+=$(FPGA_DIR)/iob_axistream_in_swreg_def.vh
VHDR+=$(AXISTREAMIN_HW_DIR)/include/iob_axistream_in_swreg.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_s_if.vh
VHDR+=$(LIB_DIR)/hardware/include/gen_if.vh

#export definitions
export DEFINE

#INCLUDE TEX SUBMODULE MAKEFILE SEGMENT
include $(LIB_DIR)/document/document.mk

test: clean $(DOC).pdf
	diff -q $(DOC).aux test.expected

.PHONY: test
