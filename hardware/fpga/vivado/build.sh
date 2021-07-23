#!/usr/bin/bash
TOP_MODULE="iob_uart"
source $XILINXPATH/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source ../iob_uart.tcl -tclargs "$TOP_MODULE" "$1" "$2" "$3" "$4"
