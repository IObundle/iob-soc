#Define CPU architecture
CPU:=PICORV32
#picorv32 look ahead interface
USE_LA_IF:=0

#CPU := DARKRV

#Firmware size (program and data)
FIRM_ADDR_W:=13

#SRAM
SRAM_ADDR_W=13

#DDR
USE_DDR:=1
RUN_DDR:=0
DDR_ADDR_W:=30

#BOOT
USE_BOOT:=1
BOOTROM_ADDR_W:=12

#Number of slaves (peripherals)
N_SLAVES:=1

#Peripheral IDs (assign serially: 0, 1, 2, etc)
UART:=0

#RTL simulation directory
SIM_DIR:=simulation/icarus
#SIM_DIR:=simulation/modelsim
#SIM_DIR:=simulation/ncsim

#FPGA compilation directory
FPGA_DIR:=fpga/xilinx/AES-KU040-DB-G
#FPGA_DIR:=fpga/intel/CYCLONEV-GT-DK
#FPGA_DIR:=fpga/xilinx/SP605

#FPGA servers
PUDIM:=146.193.44.48
BABA:=146.193.44.179

FPGA_COMPILER_SERVER:=$(PUDIM)#pudim-flan
#FPGA_COMPILER_SERVER:=$(BABA)#baba-de-camelo

FPGA_BOARD_SERVER:= $(PUDIM)#pudim-flan
#FPGA_BOARD_SERVER:=$(BABA)#baba-de-camelo

#ASIC compilation directory
ASIC_DIR = asic/umc130
