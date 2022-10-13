ROOT_DIR:=../../../..

BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

#DEFINES
DEFINE+=$(defmacro)IS_CYCLONEV

#DDR controller address and data widths
DDR_ADDR_W=28
DDR_DATA_W=32

#specify any conditions that prevent running this FPGA
#NORUN = $(USE_DDR)
NORUN = 0

QIP_FILE=qsys/alt_ddr3/synthesis/alt_ddr3.qip

$(QIP_FILE): qsys/alt_ddr3.qsys
	$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh qsys-generate  --synthesis qsys/alt_ddr3.qsys

include ../quartus.mk

