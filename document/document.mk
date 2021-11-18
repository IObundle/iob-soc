include $(ROOT_DIR)/config.mk

#FPGA results to include
INTEL = 1
XILINX = 1
ASIC = 0
XIL_FAMILY:=AES-KU040-DB-G
INT_FAMILY:=CYCLONEV-GT-DK

CORE_DIR:=$(ROOT_DIR)

BDTAB=0
SWREGS=0

include $(TEX_DIR)/document/document.mk


test: clean all
	diff -q $(DOC).aux $(DOC).expected


.PHONY: test
