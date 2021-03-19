#!/usr/bin/bash
source $XILINXPATH/Vivado/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source ld-hw.tcl
