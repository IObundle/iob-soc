#!/usr/bin/bash
source $XILINPATH/Vivado/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source synth_system.tcl -tclargs "$1" "$2" "$3"
