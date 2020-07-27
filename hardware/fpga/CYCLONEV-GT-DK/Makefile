ROOT_DIR:=../../..

include ../fpga.mk

SOF:=output_files/top_system.sof

load:
	ssh $(BOARD_SERVER) "cd $(REMOTE_FPGA_DIR); ./prog.sh"

compile: periphs firmware $(SOF)

$(SOF): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
	echo $(FPGA_DIR) $(BOARD)
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	echo FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	ssh $(BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_SERVER) "cd $(REMOTE_FPGA_DIR); ./build.sh \"$(INCLUDE)\" \"$(DEFINE)\" \"$(VSRC)\""
	if [ ! -d $(FPGA_DIR)/output_files ]; then mkdir -p $(FPGA_DIR)/output_files; fi
	touch $(FPGA_DIR)/$@

clean: hw-clean
	ssh $(BOARD_SERVER) "cd $(REMOTE_FPGA_DIR); rm -rf db incremental_db output_files *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *.qsf *~"

.PRECIOUS: $(SOF)

.PHONY: run load compile clean

