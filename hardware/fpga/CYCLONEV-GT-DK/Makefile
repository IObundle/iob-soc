ROOT_DIR:=../../..

define := #--verilog_macro
incdir := #--lib_path

include ../fpga.mk

run: output_files/top_system.sof
	./prog.sh

output_files/top_system.sof: top_system.tcl top_system.sdc $(VSRC) $(VHDR) boot.hex firmware.hex
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"

fpga-clean:
	@rm -rf db incremental_db output_files
	@rm -f *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~

.PRECIOUS: output_files/top_system.sof

.PHONY: fpga-clean

