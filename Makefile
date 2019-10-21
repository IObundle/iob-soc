TEST := test
BOOT := boot
SYNTH_TARGET := system
FPGA := xilinx
IOBUSER := $(shell whoami)
REPO_PATH := ~/sandbox/iob-soc-e

all: uart-loader

help:
	@echo ""
	@echo "Example system with open-source memories:"
	@echo "  make synth_system"
	@echo "  make sim_system"
	@echo "  clock in 'firmware.c' needs to be 100 MHz"
	@echo ""
	@echo "Example system with SDDR4:"
	@echo "  make synth_system_ddr"
	@echo "  there is no 'make sim_system_ddr' since you can't simulate a physical memory"
	@echo "  clock in 'firmware.c' needs to be 100 MHz"
	@echo ""
	@echo "Make the executable of your program (firmware.c):"
	@echo "  make firmware.hex"
	@echo ""
	@echo "Make boot-rom program (boot.c):"
	@echo "  make boot.hex"
	@echo ""

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

send-baba:
	scp -P 1418 ./fpga/xilinx/*.bit $(IOBUSER)@iobundle.ddns.net:$(REPO_PATH)/fpga/xilinx/
#This is used just to debug. To produce this file use write_debug_probes command in Tcl
#scp -P 1418 ./fpga/xilinx/*.ltx $(IOBUSER)@iobundle.ddns.net:$(REPO_PATH)/fpga/xilinx

clean:
	rm -rf INCA_libs
	rm -f *.log
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
