#!/usr/bin/bash
nios=$ALTERAPATH/nios2eds/nios2_command_shell.sh
$nios quartus_pgm -m jtag -c 1 -o "p;output_files/top_system.sof"
