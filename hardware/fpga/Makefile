ROOT_DIR:=../..
include ../hardware.mk

#FPGA COMPILER
ifeq ($(BOARD),AES-KU040-DB-G)
	FPGA_COMPILE=vivado
else ifeq ($(BOARD),BASYS3)
	FPGA_COMPILE=vivado
else ifeq ($(BOARD),CYCLONEV-GT-DK)
	FPGA_COMPILE=quartus
else ifeq ($(BOARD),DE10-LITE)
	FPGA_COMPILE=quartus
endif

export FPGA_COMPILE

all: sw build load run

build:
	make -C $(FPGA_COMPILE)/$(BOARD) build

load:
	make -C $(FPGA_COMPILE)/$(BOARD) load

run:
	make -C $(FPGA_COMPILE)/$(BOARD) run


.PHONY: all build load run

