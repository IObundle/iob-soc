ROOT_DIR:=../../../..

BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

DEVICE=5CGTFD9E5F35C7

#DEFINES
DEFINE+=$(defmacro)IS_CYCLONEV

#specify any conditions that prevent running this FPGA
NORUN = $(USE_DDR)

#Dummy DDR controller address width (only used for building system)
DDR_ADDR_W=30

include ../quartus.mk


