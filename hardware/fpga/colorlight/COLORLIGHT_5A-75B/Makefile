ROOT_DIR:=../../../..

BOARD=COLORLIGHT_5A-75B

#TODO
BOARD_SERVER=$(5A-75B_SERVER)
BOARD_USER=$(5A-75B_USER)

ifeq ($(REVISION), 6.1)
    DEVICE=LFE5U-25F-6BG381C
else #7.0/8.0
    DEVICE=LFE5U-25F-6BG256C
endif

#specify any conditions that prevent running this FPGA
NORUN = 0

FREQ=25000000 #25MHz

include ../colorlight.mk


