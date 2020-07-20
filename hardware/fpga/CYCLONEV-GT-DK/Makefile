ROOT_DIR:=../../..

define := #--verilog_macro
incdir := #--lib_path

include ../fpga.mk

SOF:=output_files/top_system.sof

load:
	./prog.sh

compile: periphs firmware.hex $(SOF)

$(SOF): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"

clean: hw-clean
	@rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~

.PRECIOUS: $(SOF)

.PHONY: load compile clean

