# Template Tester configuration file
# Copy this template file to the UUT's repository and make the necessary changes.
# Use this file to set/override tester parameters and makefile targets
# Any variables preceded by the comment 'REQUIRED:' need to be defined for compatibility with the Tester. Any other variables defined here are optional.
#
ifneq ($(INCLUDING_VARS),)
# MAKEFILE VARIABLES: PLACE BELOW VARIABLES USED BY THE TESTER
#

#REQUIRED: Name of this unit under test
UUT_NAME=IOBSOC

#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W:=15

#SRAM SIZE (LOG2)
SRAM_ADDR_W:=15

#DDR
USE_DDR:=0
RUN_EXTMEM:=0

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

#PRE-INIT MEMORY WITH PROGRAM AND DATA
INIT_MEM:=1

#SIMULATION
#default simulator running locally or remotely
#check the respective Makefile in TESTER/hardware/simulation/$(SIMULATOR) for specific settings
SIMULATOR:=icarus

#BOARD
#default board running locally or remotely
#check the respective Makefile in TESTER/hardware/fpga/$(BOARD) for specific settings
BOARD:=CYCLONEV-GT-DK

#REQUIRED: Add Unit Under Test to Tester peripherals list
#this works even if UUT is not a "peripheral"
PERIPHERALS+=$(UUT_NAME)
#PERIPHERALS+=$(UUT_NAME)[VERILOG,PARAMS,HERE]

# Other tester peripherals to add (besides the default ones in IOb-SoC-Tester config.mk)
PERIPHERALS+=UART
#
# Instance 0 of ETHERNET has default MAC address. Instance 1 has the same MAC address as the console (this way, the UUT always connects to the console's MAC address).
#PERIPHERALS+=ETHERNET
#PERIPHERALS+=ETHERNET[32,\`iob_eth_swreg_ADDR_W,48'h$(RMAC_ADDR)]

# Submodule paths for Tester peripherals (listed above)
# The Tester already provides $($(UUT_NAME)_DIR) macro to access the root directory of UUT
UART_DIR=$($(UUT_NAME)_DIR)/submodules/UART
#ETHERNET_DIR=$($(UUT_NAME)_DIR)/submodules/ETHERNET

#REQUIRED: Root directory on remote machines
REMOTE_UUT_DIR ?=sandbox/iob-soc-sut

#Define SIM macro when running in simulation
#ifneq ($(ISSIMULATION),)
#DEFINE+=$(defmacro)SIM=1
#endif

#MAC address of pc interface connected to ethernet peripheral
#ifeq ($(BOARD),AES-KU040-DB-G) # Arroz eth if MAC
#RMAC_ADDR:=4437e6a6893b
#else # Pudim eth if MAC
#RMAC_ADDR:=309c231e624a
#endif
#Auto-set ethernet interface name based on MAC address
#ETH_IF:=$(shell ip -br link | sed 's/://g' | grep $(RMAC_ADDR) | cut -d " " -f1)

#Configure Tester to use ethernet
#USE_ETHERNET:=1
#DEFINE+=$(defmacro)USE_ETHERNET=1

#Extra tester target dependencies
#Run before building the system
BUILD_DEPS+=$($(UUT_NAME)_DIR)/hardware/src/system.v
#Run before building system for simulation
SIM_DEPS+=set-simulation-variable
#Run before building system for FPGA
FPGA_DEPS+=
#Run when cleaning tester
CLEAN_DEPS+=clean-top-module clean-sut-fw
#Run after finishing the FPGA run (useful to copy files from remote machines at the end of a run sequence)
FPGA_POST_RUN_DEPS+=

#
else
# MAKEFILE TARGETS: PLACE BELOW EXTRA TARGETS USED BY THE TESTER
#

#Target to build UUT topsystem
$($(UUT_NAME)_DIR)/hardware/src/system.v:
	make -C $($(UUT_NAME)_DIR)/hardware/src -f ../hardware.mk system.v ROOT_DIR=../..

clean-top-module:
	rm -f $($(UUT_NAME)_DIR)/hardware/src/system.v

#Target to build UUT bootloader and firmware
$($(UUT_NAME)_DIR)/software/firmware/boot.hex $($(UUT_NAME)_DIR)/software/firmware/firmware.hex:
	make -C $($(UUT_NAME)_DIR)/software/firmware build-all BAUD=$(BAUD)
	make -C $($(UUT_NAME)_DIR)/software/firmware -f ../../hardware/hardware.mk boot.hex firmware.hex ROOT_DIR=../..

clean-sut-fw:
	make -C $($(UUT_NAME)_DIR) fw-clean

#Set ISSIMULATION variable
set-simulation-variable:
	$(eval export ISSIMULATION=1)

.PHONY: clean-top-module clean-sut-fw set-simulation-variable
endif
