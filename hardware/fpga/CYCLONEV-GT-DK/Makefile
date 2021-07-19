ROOT_DIR:=../../..
DEFINE+=$(defmacro)IS_CYCLONEV=1
FPGA_OBJ=output_files/top_system.sof
FPGA_LOG=output_files/top_system.fit.summary

BOARD=CYCLONEV-GT-DK

FPGA_SERVER=$(QUAR_SERVER)
FPGA_USER=$(QUAR_USER)

BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

NORUN = $(USE_DDR)

include ../fpga.mk

board-clean: hw-clean
	rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done \
	*.jdi *.pin *.sof *.sld *.qpf *.qsf *~ system.v *.log

.PHONY: board-clean

