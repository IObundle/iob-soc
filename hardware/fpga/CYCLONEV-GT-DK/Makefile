ROOT_DIR:=../../..
DEFINE+=$(defmacro)IS_CYCLONEV=1
FPGA_OBJ=output_files/top_system.sof
FPGA_LOG=output_files/top_system.fit.summary
FPGA_NORUN ?=$(USE_DDR)
BOARD=CYCLONEV-GT-DK

include ../fpga.mk

board-clean: fpga-clean
	rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done \
	*.jdi *.pin *.sof *.sld *.qpf *.qsf *~ system.v *.log

.PHONY: board-clean

