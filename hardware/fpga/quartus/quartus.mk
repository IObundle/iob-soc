FPGA_OBJ=top_system.sof
FPGA_LOG=quartus.log

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)

include ../../fpga.mk

local-build: $(QIP_FILE)
	$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh quartus_sh -t ../top_system.tcl "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"
	mv output_files/top_system.sof $(FPGA_OBJ)
	mv output_files/top_system.fit.summary $(FPGA_LOG)

clean: clean-all
	@rm -rf db/ incremental_db/ output_files/ \
	*.qdf *.sof *.sld *.qpf *.qsf *.txt

clean-ip:
	rm -rf qsys/alt_ddr3 qsys/alt_ddr3.sopcinfo

veryclean: clean clean-ip

