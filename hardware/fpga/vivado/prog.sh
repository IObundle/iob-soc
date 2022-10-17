#!/usr/bin/env bash
set -e
source $VIVADOPATH/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source ld-hw.tcl
