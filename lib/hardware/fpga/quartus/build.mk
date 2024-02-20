# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)
FPGA_SSH_FLAGS=$(QUARTUS_SSH_FLAGS)
FPGA_SCP_FLAGS=$(QUARTUS_SCP_FLAGS)
FPGA_SYNC_FLAGS=$(QUARTUS_SYNC_FLAGS)

# Determine the Quartus edition to use (default to Standard)
USE_QUARTUS_PRO ?=0
ifeq ($(BOARD),DK-DEV-10CX220-A)
		USE_QUARTUS_PRO=1
endif
ifeq ($(BOARD),DK-DEV-AGF014E2ES)
		USE_QUARTUS_PRO=1
endif


# Determine the object to build
ifeq ($(IS_FPGA),1)
FPGA_OBJ:=$(FPGA_TOP).sof
else
FPGA_OBJ:=$(FPGA_TOP)_netlist.v
endif

# Set the Quartus command to porgram the FPGA
FPGA_PROG=nios2_command_shell.sh quartus_pgm -m jtag -c 1 -o "p;$(FPGA_TOP).sof"

QUARTUS_FLAGS = -t quartus/build.tcl $(FPGA_TOP) $(BOARD) "$(VSRC)" $(IS_FPGA) $(USE_EXTMEM) $(QUARTUS_SEED) $(USE_QUARTUS_PRO)

$(FPGA_OBJ): $(VHDR) $(VSRC) $(wildcard $(BOARD)/*.sdc)
	nios2_command_shell.sh quartus_sh $(QUARTUS_FLAGS)

quartus-clean:
	@rm -rf incremental_db db reports
	@find ~ -maxdepth 1 -type d -empty -iname "sopc_altera_pll*" -delete

.PHONY: quartus-clean

