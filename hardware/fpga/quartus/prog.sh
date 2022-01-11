#!/bin/bash
set -e
nios=$QUARTUSPATH/nios2eds/nios2_command_shell.sh
$nios quartus_pgm -m jtag -c 1 -o "p;top_system.sof"
