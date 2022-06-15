ROOT_DIR:=../../../..

BOARD_SERVER=$(DE5_SERVER)
BOARD_USER=$(DE5_USER)

DEVICE=5SGXEA7N2F45C2

#DEFINES
DEFINE+=$(defmacro)IS_CYCLONEV

#specify any conditions that prevent running this FPGA
NORUN = $(USE_DDR)

include ../quartus.mk
