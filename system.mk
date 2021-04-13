######################################################################
#
# IOb-SoC Configuration File
#
######################################################################

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS OR OVERRIDEN BY ENV VARS
#

#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W ?=16

#SRAM SIZE (LOG2)
SRAM_ADDR_W ?=16

#DDR
USE_EXTMEM ?=1
RUN_EXTMEM ?=1

USE_DDR ?=1
RUN_DDR ?=1

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=21

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

#PRE-INIT MEMORY WITH PROGRAM AND DATA
INIT_MEM ?=0

#PERIPHERAL LIST
#must match respective submodule or folder name in the submodules directory
#and CORE_NAME in the core.mk file of the submodule
#PERIPHERALS:=UART
PERIPHERALS ?=UART

#
#SOFTWARE COMPILATION
#

# risc-v compressed instructions
USE_COMPRESSED ?=1


#
#ROOT DIR ON REMOTE MACHINES
#
REMOTE_ROOT_DIR ?=sandbox/iob-soc


#
#SIMULATION
#

#produce waveform dump
VCD ?=0

#set for running (remote) simulators
#servers and respective users should be environment variables
#default simulator
SIMULATOR ?=icarus
#select according simulators
ifeq ($(SIMULATOR),icarus)
	SIM_SERVER=$(IVSIM_SERVER)
	SIM_USER=$(IVSIM_USER)
else ifeq ($(SIMULATOR),ncsim)
	SIM_SERVER=$(NCSIM_SERVER)
	SIM_USER=$(NCSIM_USER)
else ifeq ($(SIMULATOR),modelsim)
	SIM_SERVER=$(MSIM_SERVER)
	SIM_USER=$(MSIM_USER)
else ifeq ($(SIMULATOR),verilator)
	SIM_SERVER=$(VSIM_SERVER)
	SIM_USER=$(VSIM_USER)
endif

#
#FPGA BOARD COMPILE & RUN
#

#DDR controller address width
FPGA_DDR_ADDR_W ?=21


#set for running (remote) tools and boards
#servers and respective users should be environment variables
#default board
BOARD ?=AES-KU040-DB-G
#select according to board
ifeq ($(BOARD),AES-KU040-DB-G)
	FPGA_SERVER=$(VIVA_SERVER)
	FPGA_USER=$(VIVA_USER)
	FPGA_OBJ=synth_system.bit
	FPGA_LOG=vivado.log
	BOARD_SERVER=$(KU40_SERVER)
	BOARD_USER=$(KU40_USER)
else ifeq ($(BOARD),CYCLONEV-GT-DK)
	FPGA_SERVER=$(QUAR_SERVER)
	FPGA_USER=$(QUAR_USER)
	FPGA_OBJ=output_files/top_system.sof
	FPGA_LOG=output_files/top_system.fit.summary
	BOARD_SERVER=$(CYC5_SERVER)
	BOARD_USER=$(CYC5_USER)
else ifeq ($(BOARD),DE10-LITE)
	FPGA_SERVER=$(DE10_SERVER)
	FPGA_USER=$(DE10_USER)
	FPGA_OBJ=output_files/top_system.sof
	FPGA_LOG=output_files/top_system.fit.summary
	BOARD_SERVER=$(DE10_SERVER)
	BOARD_USER=$(DE10_USER)
endif

#
#ASIC COMPILE
#
#set for running (remote) tools and boards
#servers and respective users should be environment variables
#default node
ASIC_NODE ?=umc130
#select according to node
ifeq ($(ASIC_NODE),umc130)
	ASIC_SERVER=$(CADE_SERVER)
	ASIC_USER=$(CADE_USER)
endif


#
# REGRESSION TESTING
#

#simulators used in regression testing
SIM_LIST ?=ncsim

#boards used for regression testing
BOARD_LIST ?=CYCLONEV-GT-DK AES-KU040-DB-G







#############################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE
#############################################################
SIM_HOST=$(shell echo $(SIM_SERVER) | cut -d"." -f1)
FPGA_HOST=$(shell echo $(FPGA_SERVER) | cut -d"." -f1)
BOARD_HOST=$(shell echo $(BOARD_SERVER) | cut -d"." -f1)
ASIC_HOST=$(shell echo $(ASIC_SERVER) | cut -d"." -f1)


ifeq ($(RUN_EXTMEM),1)
	USE_EXTMEM=1
endif

#paths
HW_DIR:=$(ROOT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)
BOARD_DIR=$(HW_DIR)/fpga/$(BOARD)
ASIC_DIR=$(HW_DIR)/asic/$(ASIC_NODE)
SW_DIR:=$(ROOT_DIR)/software
FIRM_DIR:=$(SW_DIR)/firmware
BOOT_DIR:=$(SW_DIR)/bootloader
CONSOLE_DIR:=$(SW_DIR)/console
PYTHON_DIR:=$(SW_DIR)/python

TEX_DIR=$(UART_DIR)/submodules/TEX

#submodule paths
SUBMODULES_DIR:=$(ROOT_DIR)/submodules
SUBMODULES=CPU CACHE $(PERIPHERALS)
$(foreach p, $(SUBMODULES), $(eval $p_DIR:=$(SUBMODULES_DIR)/$p))

#defmacros
DEFINE+=$(defmacro)BOOTROM_ADDR_W=$(BOOTROM_ADDR_W)
DEFINE+=$(defmacro)SRAM_ADDR_W=$(SRAM_ADDR_W)
DEFINE+=$(defmacro)FIRM_ADDR_W=$(FIRM_ADDR_W)
DEFINE+=$(defmacro)DCACHE_ADDR_W=$(DCACHE_ADDR_W)

ifeq ($(USE_EXTMEM),1)
DEFINE+=$(defmacro)USE_EXTMEM
endif
ifeq ($(RUN_EXTMEM),1)
DEFINE+=$(defmacro)RUN_EXTMEM
endif

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
endif
ifeq ($(RUN_DDR),1)
DEFINE+=$(defmacro)RUN_DDR
endif

ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM
endif
DEFINE+=$(defmacro)N_SLAVES=$(N_SLAVES)

#address selection bits
E:=31 #extra memory bit
ifeq ($(USE_EXTMEM),1)
P:=30 #periphs
B:=29 #boot controller
else
P:=31
B:=30
endif

DEFINE+=$(defmacro)E=$E
DEFINE+=$(defmacro)P=$P
DEFINE+=$(defmacro)B=$B

#baud rate
SIM_BAUD:=5000000
HW_BAUD:=115200
BAUD ?= $(HW_BAUD)
DEFINE+=$(defmacro)BAUD=$(BAUD)

#operation frequency
ifeq ($(FREQ),)
DEFINE+=$(defmacro)FREQ=100000000
else
DEFINE+=$(defmacro)FREQ=$(FREQ)
endif

N_SLAVES:=0
$(foreach p, $(PERIPHERALS), $(eval $p=$(N_SLAVES)) $(eval N_SLAVES:=$(shell expr $(N_SLAVES) \+ 1)))
$(foreach p, $(PERIPHERALS), $(eval DEFINE+=$(defmacro)$p=$($p)))

#test log
ifneq ($(TEST_LOG),)
LOG=>test.log
endif


#RULES

gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
