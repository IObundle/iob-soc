#!/bin/bash
set -e
source /opt/ic_tools/init/init-rc14_25_hf000
echo "quit" | rc -files inc.tcl -files defs.tcl -files vsrc.tcl -files case.tcl -files synscript.tcl
echo "quit"
