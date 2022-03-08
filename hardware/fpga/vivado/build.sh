#!/bin/bash
set -e
source $VIVADOPATH/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source ../top_system.tcl -tclargs "$1" "$2" "$3" "$4"
