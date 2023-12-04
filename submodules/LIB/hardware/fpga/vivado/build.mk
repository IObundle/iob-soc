# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)
FPGA_SSH_FLAGS=$(VIVADO_SSH_FLAGS)
FPGA_SCP_FLAGS=$(VIVADO_SCP_FLAGS)
FPGA_SYNC_FLAGS=$(VIVADO_SYNC_FLAGS)


ifeq ($(IS_FPGA),1)
FPGA_OBJ=$(FPGA_TOP).bit
else
FPGA_OBJ=$(FPGA_TOP)_netlist.v
FPGA_STUB=$(FPGA_TOP)_stub.v
endif


FPGA_PROG=vivado -nojournal -log vivado.log -mode batch -source vivado/prog.tcl -tclargs $(FPGA_TOP)

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

VIVADO_FLAGS= -nojournal -log reports/vivado.log -mode batch -source vivado/build.tcl -tclargs $(FPGA_TOP) $(CSR_IF) $(BOARD) "$(VSRC)" $(IS_FPGA) $(USE_EXTMEM) $(N_INTERCONNECT_SLAVES)

$(FPGA_OBJ): $(VSRC) $(VHDR) $(wildcard $(BOARD)/*.sdc)
	mkdir -p reports && vivado $(VIVADO_FLAGS) 

vivado-clean:
	@rm -rf .Xil

.PHONY: vivado-clean
