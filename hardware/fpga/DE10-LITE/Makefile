ROOT_DIR:=../../..
FPGA_OBJ=output_files/top_system.sof
FPGA_LOG=output_files/top_system.fit.summary

BOARD=DE10-LITE

FPGA_SERVER=$(DE10_SERVER)
FPGA_USER=$(DE10_USER)

BOARD_SERVER=$(DE10_SERVER)
BOARD_USER=$(DE10_USER)


NORUN = $(USE_DDR)

FREQ=50000000

include ../fpga.mk

board-clean: hw-clean
	rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done \
	*.jdi *.pin *.sof *.sld *.qpf *.qsf *~ system.v *.log

.PHONY: board-clean
