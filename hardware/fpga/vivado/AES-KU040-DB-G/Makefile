ROOT_DIR:=../../../..

BOARD=AES-KU040-DB-G
BOARD_SERVER=$(KU40_SERVER)
BOARD_USER=$(KU40_USER)

DEVICE=xcku040-fbva676-1-c

#specify any conditions that prevent running this FPGA
NORUN = 0

#DDR controller address and data widths
DDR_ADDR_W=30
DDR_DATA_W=32

VHDR+=ddr4_axi_wire.vh
ddr4_axi_wire.vh:
	$(LIB_DIR)/software/python/axi_gen.py axi_wire 'ddr4_' 'ddr4_' 'ddr4_'

include ../vivado.mk
