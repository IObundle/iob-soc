ROOT_DIR:=../../../..

BOARD_SERVER=$(DE5_SERVER)
BOARD_USER=$(DE5_USER)

DEVICE=5SGXEA7N2F45C2

#DEFINES
DEFINE+=$(defmacro)IS_CYCLONEV

#specify any conditions that prevent running this FPGA
NORUN = $(USE_DDR)

QIP_FILE=qsys/QSysDE5QGen1x8If64/synthesis/QSysDE5QGen1x8If64.qip

$(QIP_FILE): qsys/QSysDE5QGen1x8If64.qsys
	$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh qsys-generate  --synthesis qsys/QSysDE5QGen1x8If64.qsys


include ../quartus.mk
