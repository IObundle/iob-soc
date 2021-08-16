#FPGA COMPILER
ifeq ($(BOARD),AES-KU040-DB-G)
	FPGA_COMPILE=vivado
else ifeq ($(BOARD),BASYS3)
	FPGA_COMPILE=vivado
else ifeq ($(BOARD),CYCLONEV-GT-DK)
	FPGA_COMPILE=quartus
else ifeq ($(BOARD),DE10-LITE)
	FPGA_COMPILE=quartus
else
	FPGA_COMPILE=vivado
endif

all:
	make -C $(FPGA_COMPILE)/$(BOARD) all

build:
	make -C $(FPGA_COMPILE)/$(BOARD) build

load:
	make -C $(FPGA_COMPILE)/$(BOARD) load

run:
	make -C $(FPGA_COMPILE)/$(BOARD) run

