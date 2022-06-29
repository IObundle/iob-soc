ROOT_DIR:=../../../..

BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

DEVICE=5CGTFD9E5F35C7

#DEFINES
DEFINE+=$(defmacro)IS_CYCLONEV

#DDR controller address width
DDR_ADDR_W=30

#specify any conditions that prevent running this FPGA
#NORUN = $(USE_DDR)
NORUN = 0

FREQ=50000000


VSRC+=$(LIB_DIR)/hardware/axi2axi/alt_axi2axi.v

QIP_FILE=qsys/alt_ddr3/synthesis/alt_ddr3.qip

$(QIP_FILE): qsys/alt_ddr3.qsys qsys/axi2axi_hw.tcl
	qsys-generate  --synthesis qsys/alt_ddr3.qsys

#DDR controller address and data widths
DDR_ADDR_W=25
DDR_DATA_W=256

include ../quartus.mk

