#####################################################################
#
# IOb-SoC Configuration File
#
#####################################################################

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS
#

#FIRMWARE SIZE (LOG2)
FIRM_ADDR_W ?=16

#SRAM SIZE (LOG2)
SRAM_ADDR_W ?=16

#DDR 
USE_DDR ?=0
RUN_DDR ?=0

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

#ROM SIZE (LOG2)
BOOTROM_ADDR_W:=12

#PRE-INIT MEMORY WITH PROGRAM AND DATA
INIT_MEM ?=1

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

#default simulator
SIMULATOR ?=icarus

#produce waveform dump
VCD ?=0

#set for running remote simulators
ifeq ($(SIMULATOR),ncsim)
	SIM_SERVER=$(NCSIM_SERVER)
	SIM_USER=$(NCSIM_USER)
endif

#
#FPGA BOARD COMPILE & RUN
#

#DDR controller address width
FPGA_DDR_ADDR_W ?=30

#default board
BOARD ?=CYCLONEV-GT-DK

#set for running remote FPGA boards
ifeq ($(BOARD),AES-KU040-DB-G)
	BOARD_SERVER = $(KU40_SERVER)
	BOARD_USER =$(KU40_USER)
	FPGA_OBJ ?= synth_system.bit
	FPGA_LOG ?= vivado.log
else #default; ifeq ($(BOARD),CYCLONEV-GT-DK)
	BOARD_SERVER = $(CYC5_SERVER)
	BOARD_USER = $(CYC5_USER)
	FPGA_OBJ ?=output_files/top_system.sof
	FPGA_LOG ?=output_files/top_system.fit.summary
endif

#
#ASIC COMPILE
#
ASIC_NODE=umc130


#
# REGRESSION TESTING
#

#simulators used in regression testing
SIM_LIST=icarus ncsim

#boards used for regression testing
BOARD_LIST=CYCLONEV-GT-DK AES-KU040-DB-G 







#############################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE
#############################################################

ifeq ($(RUN_DDR),1)
	USE_DDR=1
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

ifeq ($(USE_DDR),1)
DEFINE+=$(defmacro)USE_DDR
ifeq ($(RUN_DDR),1)
DEFINE+=$(defmacro)RUN_DDR
endif
endif
ifeq ($(INIT_MEM),1)
DEFINE+=$(defmacro)INIT_MEM
endif
DEFINE+=$(defmacro)N_SLAVES=$(N_SLAVES)

#address selection bits
E:=31 #extra memory bit
ifeq ($(USE_DDR),1)
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

#default remote servers and users
HOSTNAME=$(shell hostname)

SIM_SERVER ?=$(HOSTNAME)
SIM_USER ?=$(USER)

FPGA_SERVER ?=$(HOSTNAME)
FPGA_USER ?=$(USER)

BOARD_SERVER ?=$(HOSTNAME)
BOARD_USER ?=$(USER)

ASIC_SERVER ?=$(HOSTNAME)
ASIC_USER ?=$(USER)


SIM_HOST=$(shell echo $(SIM_SERVER) | cut -d"." -f1)
FPGA_HOST=$(shell echo $(FPGA_SERVER) | cut -d"." -f1)
BOARD_HOST=$(shell echo $(BOARD_SERVER) | cut -d"." -f1)
ASIC_HOST=$(shell echo $(ASIC_SERVER) | cut -d"." -f1)



#RULES

gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
