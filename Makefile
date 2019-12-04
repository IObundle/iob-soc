#hardware configuration
USE_RAM = 0
USE_DDR = 0

MY_PC = $(shell hostname)

all:
	less Makefile

#
# simulation
#

ncsim:
	make -C simulation/ncsim USE_RAM=$(USE_RAM) USE_DDR=$(USE_DDR)

icarus:
	make -C simulation/icarus USE_RAM=$(USE_RAM) USE_DDR=$(USE_DDR)

#
# fpga
#

ku040:
	make -C fpga/xilinx/AES-KU040-DB-G USE_RAM=$(USE_RAM) USE_DDR=$(USE_DDR)
#	REMOTE_REPO_PATH = ~/sandbox/iob-soc-e
#	scp -P 1418 ./fpga/xilinx/*.bit $(IOBUSER)@iobundle.ddns.net:$(REMOTE_REPO_PATH)/fpga/xilinx/AES-KU040-DB-G
#	ssh -p 1418 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_REPO_PATH)/fpga/xilinx/AES-KU040-DB-G ld-hw'
#	ssh -p 1418 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_REPO_PATH) progld'

sp605:
	@echo "FPGA not yet available"

gt:
	make -C fpga/intel/CYCLONEV-GT-DK USE_RAM=$(USE_RAM) USE_DDR=$(USE_DDR)



ld-sw:
	make -C software/ld-sw USE_RAM=$(USE_RAM) USE_DDR=$(USE_DDR)


clean:
	@rm -rf INCA_libs
	@rm -f *.log
	make -C software/bootloader clean --no-print-directory
	make -C software/ld-sw clean --no-print-directory
	make -C software/hello_world clean --no-print-directory
ifeq ($(MY_PC),micro5.lx.it.pt)
	make -C simulation/ncsim clean --no-print-directory
endif
	make -C simulation/icarus clean --no-print-directory
	make -C fpga/xilinx/AES-KU040-DB-G clean --no-print-directory
	make -C fpga/intel/CYCLONEV-GT-DK clean --no-print-directory
	@echo "Cleaned"

#left here because I don't know if it's needed
very_clean:
	@rm -rf rtl/ip/*
	@echo "All Cleaned"
