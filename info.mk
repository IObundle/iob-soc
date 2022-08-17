# core name
NAME=iob_soc
# core version 
VERSION=0010
# top-leel module
TOP_MODULE?=system
# core path as seen from LIB's makefile
ROOT_DIR=$(CORE_DIR)

SETUP_SW=1
SETUP_SIM=1
SETUP_FPGA=0
SETUP_DOC=0

# Needed by software/simulation.mk to generate periphs_tmp.h
PERIPHERALS:=UART

#address selection bits
E:=31 #extra memory bit
P:=30 #periphs
B:=29 #boot controller

DEFINE+=E=$E
DEFINE+=P=$P
DEFINE+=B=$B

#kill "console", the background running program seriving simulators,
#emulators and boards
#used by fpga and pc-emul makefiles
CNSL_PID:=ps aux | grep $(USER) | grep console | grep python3 | grep -v grep
kill-cnsl:
	@if [ "`$(CNSL_PID)`" ]; then \
	kill -9 $$($(CNSL_PID) | awk '{print $$2}'); fi

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
N_SLAVES:=0
$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$p=$($p)))

N_SLAVES_W = $(shell echo "import math; print(math.ceil(math.log($(N_SLAVES),2)))"|python3 )
DEFINE+=N_SLAVES_W=$(N_SLAVES_W)

#RISC-V HARD MULTIPLIER AND DIVIDER INSTRUCTIONS
USE_MUL_DIV ?=1

#RISC-V COMPRESSED INSTRUCTIONS
USE_COMPRESSED ?=1

#default baud and system clock frequency
SIM_BAUD = 2500000
SIM_FREQ =50000000

#default baud and frequency if not given
BAUD ?=$(SIM_BAUD)
FREQ ?=$(SIM_FREQ)

#CPU ARCHITECTURE
DATA_W := 32
ADDR_W := 32

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W ?=15

#SRAM SIZE (LOG2)
SRAM_ADDR_W ?=15

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

DEFINE+=DATA_W=$(DATA_W)
DEFINE+=ADDR_W=$(ADDR_W)
DEFINE+=FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=N_SLAVES=$(N_SLAVES) #peripherals
