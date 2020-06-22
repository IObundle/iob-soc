define := #--verilog_macro
incdir := #--lib_path

include ../../synth.mk

REMOTE_FPGA_DIR := ./sandbox/iob-soc/fpga/intel/CYCLONEV-GT-DK

REMOTE := ${USER}@$(FPGA_BOARD_SERVER):$(REMOTE_FPGA_DIR)

run: output_files/top_system.sof firmware.bin
	scp $^ $(REMOTE)

output_files/top_system.sof: top_system.tcl top_system.sdc $(VSRC) boot.dat firmware.dat
	./build.sh "$(HW_INCLUDE)" "$(HW_DEFINE)" "$(VSRC)"

ld-hw:
#	ssh $(REMOTE) $(REMOTE_FPGA_DIR)/prog.sh $(REMOTE_FPGA_DIR)
	./prog.sh .

clean_altera:
	@rm -rf db incremental_db output_files
	@rm -f *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~

.PRECIOUS: output_files/top_system.sof
