TEST := test
BOOT := boot
SYNTH_TARGET := system
FPGA := xilinx
IOBUSER := $(shell whoami)
REPO_PATH := ~/sandbox/iob-soc-e
BOOT_HEX = $(addprefix software/bootloader/$(BOOT)/,boot_0.hex boot_1.hex boot_2.hex boot_3.hex)

all: uart-loader

uart-loader:
	make -C software/tests/$(TEST)
	make -C software/scripts TEST=$(TEST)

bitstream: $(FPGA)

ld-hw:
	make -C fpga/xilinx ld-hw

xilinx:
	make -C fpga/xilinx TEST=$(TEST) BOOT=$(BOOT) SYNTH_TARGET=$(SYNTH_TARGET)

altera:
	make -C fpga/altera TEST=$(TEST) BOOT=$(BOOT)

ncsim:
	make -C simulation/ncsim TEST=$(TEST) BOOT=$(BOOT)

icarus:
	make -C simulation/icarus TEST=$(TEST) BOOT=$(BOOT)
#target icarus is outdated

send-baba:
	scp -P 1418 ./fpga/xilinx/*.bit $(IOBUSER)@iobundle.ddns.net:$(REPO_PATH)/fpga/xilinx/
#This is used just to debug. To produce this file use write_debug_probes command in Tcl
#scp -P 1418 ./fpga/xilinx/*.ltx $(IOBUSER)@iobundle.ddns.net:$(REPO_PATH)/fpga/xilinx

clean:
	@rm -rf INCA_libs
	@rm -f *.log
	@make -C fpga/xilinx clean --no-print-directory
	@make -C simulation/ncsim clean --no-print-directory
	@make -C simulation/icarus clean --no-print-directory
	@make -C software/scripts clean --no-print-directory
	@make -C fpga/altera clean --no-print-directory
	@make -C software/bootloader/$(BOOT) clean --no-print-directory
	@echo "Cleaned"

very_clean:
	@rm -rf rtl/ip/*
	@echo "All Cleaned"
