ROOT_DIR:=../../../..

BOARD=CYCLONEV-GT-DK
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

ifeq ($(USE_DDR),1)
VSRC += qsys/alt_ddr3.qsys
endif

include ../quartus.mk

