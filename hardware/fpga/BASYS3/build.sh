#!/bin/bash
export XILINXPATH=/tools/Xilinx/Vivado/2020.1/bin
export LM_LICENSE_FILE=$LM_LICENSE_FILE:$XILINXPATH/Xilinx.lic
source /tools/Xilinx/Vivado/2020.1/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source synth_system.tcl -tclargs "$1" "$2" "$3"
