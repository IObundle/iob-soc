ROOT_DIR:=../../..

define := #--verilog_macro
incdir := #--lib_path

include ../fpga.mk

run: output_files/top_system.sof
	scp $^ $(REMOTE):$(REMOTE_FPGA_DIR)
	ssh $(REMOTE) $(REMOTE_FPGA_DIR)/prog.sh $(REMOTE_FPGA_DIR)

output_files/top_system.sof: top_system.tcl top_system.sdc $(VSRC) boot.dat firmware.dat
	ssh $(REMOTE) $(REMOTE_FPGA_DIR)/build.sh "$(HW_INCLUDE)" "$(HW_DEFINE)" "$(VSRC)"

fpga-clean:
	@rm -rf db incremental_db output_files
	@rm -f *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~

.PRECIOUS: output_files/top_system.sof

.PHONY: fpga-clean

