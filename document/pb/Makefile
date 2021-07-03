ROOT_DIR:=../..
include ../../system.mk

INTEL = 1
XILINX = 1

CORE_DIR:=$(ROOT_DIR)
include $(TEX_DIR)/document/document.mk

all: pb.pdf

clean-all: clean pdfclean

clean: texclean resultsclean

.PHONY: all clean clean-all
