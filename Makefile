TEST := test
BOOT := boot
SYNTH_TARGET := system

all: xilinx

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

xilinx: 
	make -C fpga/xilinx TEST=$(TEST) BOOT=$(BOOT) SYNTH_TARGET=$(SYNTH_TARGET)

ncsim:
	make -C simulation/ncsim TEST=$(TEST) BOOT=$(BOOT)

icarus:
	make -C simulation/icarus TEST=$(TEST) BOOT=$(BOOT)

clean:
	@make -C fpga/xilinx clean --no-print-directory
	@make -C simulation/ncsim clean --no-print-directory
	@make -C simulation/icarus clean --no-print-directory
	@echo "All clean"
