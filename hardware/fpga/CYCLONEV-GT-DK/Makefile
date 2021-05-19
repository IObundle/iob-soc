ROOT_DIR:=../../..

DEFINE+=$(defmacro)IS_CYCLONEV=1

include ../fpga.mk

clean: hw-clean
	rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~ system.v

.PHONY: clean

