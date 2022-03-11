FPGA_OBJ=top_system.sof
FPGA_LOG=quartus.log

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)

include ../../fpga.mk

pre-build:
	mkdir -p output_files

post-build:
	mv output_files/top_system.sof $(FPGA_OBJ)
	mv output_files/top_system.fit.summary $(FPGA_LOG)

clean: clean-remote
	@rm -rf db/ incremental_db/ output_files/ \
	*.qdf *.sof *.sld *.qpf *.qsf *.txt

.PHONY: pre-build post-build clean
