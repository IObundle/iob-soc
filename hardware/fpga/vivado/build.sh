#!/bin/bash
source $VIVADOPATH/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source ../uart.tcl -tclargs "$1" "$2" "$3" "$4" "$5"
