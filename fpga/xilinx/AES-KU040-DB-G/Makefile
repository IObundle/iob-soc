define := #-verilog_define
incdir := #-include_dirs

include ../../synth.mk

REMOTE := ${USER}@$(FPGA_BOARD_SERVER):sandbox/iob-soc/fpga/xilinx/AES-KU040-DB-G

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

run: synth_system.bit firmware.dat firmware.bin
	scp synth_system.bit $(REMOTE)
	scp firmware.bin $(REMOTE)

synth_system.bit: *.xdc $(VSRC) boot.dat
	rm -f $@.log
	./run_vivado.sh $(USE_DDR) "$(HW_INCLUDE)" "$(HW_DEFINE)" "$(VSRC)"
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo
