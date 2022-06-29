FPGA_OBJ=top_system.sof
FPGA_LOG=quartus.log

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)

include ../../fpga.mk
include $(LIB_DIR)/hardware/iob_reset_sync/hardware.mk

post-build:
	mv output_files/top_system.sof $(FPGA_OBJ)
	mv output_files/top_system.fit.summary $(FPGA_LOG)

clean: clean-all
	@rm -rf db/ incremental_db/ output_files/ \
	*.qdf *.sof *.sld *.qpf *.qsf *.txt
	 if [ $(CLEANIP) ]; then rm -rf qsys/alt_ddr3 qsys/alt_ddr3.sopcinfo ; fi

.PHONY: post-build clean
