#FIRMWARE
FIRM_ADDR_W:=13

#SRAM
SRAM_ADDR_W=13

#DDR
USE_DDR:=1
RUN_DDR:=1
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

FPGA_COMPILER_SERVER=$(PUDIM)
#FPGA_COMPILER_SERVER=$(BABA)

#FPGA_BOARD_SERVER=$(PUDIM)
FPGA_BOARD_SERVER=$(BABA)

#ASIC compilation directory
ASIC_DIR = asic/umc130

#address select bits: Extra memory (E), Peripherals (P), Boot controller (B)
#do not edit
E:=31
P:=30
B:=29

#FPGA servers (replace at will)
PUDIM:=146.193.44.48
BABA:=146.193.44.179

