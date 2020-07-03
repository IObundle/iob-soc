#!/usr/bin/bash
export XILINXPATH=/opt/Xilinx
export LM_LICENSE_FILE=$LM_LICENSE_FILE:$XILINXPATH/Xilinx.lic
source /opt/Xilinx/Vivado/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source synth_system.tcl -tclargs "$1" "$2" "$3"
