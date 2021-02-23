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
#SIMULATION
#

#default simulator
SIMULATOR ?=icarus

#simulators installed locally
LOCAL_SIM_LIST ?=icarus verilator

#produce waveform dump
VCD ?=0

#set for running remote simulators
ifeq ($(SIMULATOR),ncsim)
	SIM_SERVER ?=micro7.lx.it.pt
	SIM_USER ?=user19
endif

#simulator used in regression testing
SIM_LIST:=icarus ncsim

#
#FPGA BOARD COMPILE & RUN
#

#DDR controller address width
FPGA_DDR_ADDR_W ?=30

#default board
BOARD ?=CYCLONEV-GT-DK

#Boards for which the FPGA compiler is installed in host
#LOCAL_FPGA_LIST=CYCLONEV-GT-DK AES-KU040-DB-G

#boards installed host
#LOCAL_BOARD_LIST=CYCLONEV-GT-DK
#LOCAL_BOARD_LIST=AES-KU040-DB-G

#set according to FPGA board
ifeq ($(BOARD),AES-KU040-DB-G)
	BOARD_SERVER ?=baba-de-camelo.iobundle.com
	BOARD_USER ?=$(USER)
	FPGA_OBJ ?=synth_system.bit
	FPGA_LOG ?=vivado.log
	FPGA_SERVER ?=pudim-flan.iobundle.com
	FPGA_USER ?=$(USER)
else #default; ifeq ($(BOARD),CYCLONEV-GT-DK)
	BOARD_SERVER ?=pudim-flan.iobundle.com
	BOARD_USER ?=$(USER)
	FPGA_OBJ ?=output_files/top_system.sof
	FPGA_LOG ?=output_files/top_system.fit.summary
	FPGA_SERVER ?=pudim-flan.iobundle.com
	FPGA_USER ?=$(USER)
endif

#board list for testing
BOARD_LIST ?=CYCLONEV-GT-DK AES-KU040-DB-G 


#
#ROOT DIR ON REMOTE MACHINES
#
REMOTE_ROOT_DIR ?=sandbox/iob-soc

#
# ASIC COMPILE (WIP)
#
ASIC_NODE:=umc130
ASIC_SERVER:=micro7.lx.it.pt
ASIC_COMPILE_ROOT_DIR=$(ROOT_DIR)/sandbox/iob-soc
#ASIC_USER=

#
#SOFTWARE COMPILATION
#

# risc-v compressed instructions
USE_COMPRESSED ?=1


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



#RULES

gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
