ROOT_DIR:=../../..
FPGA_OBJ=output_files/top_system.sof
FPGA_LOG=output_files/top_system.fit.summary

include ../fpga.mk

clean: hw-clean
	rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~ system.v

.PHONY: clean

