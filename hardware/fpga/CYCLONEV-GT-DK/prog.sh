#!/usr/bin/bash
export ALTERAPATH=/home/iobundle/Intel/Altera_full/18.0
export LM_LICENSE_FILE=1801@localhost:$ALTERAPATH/../1-MVXX5H_License.dat
nios=/home/iobundle/Intel/Altera_full/18.0/nios2eds/nios2_command_shell.sh
$nios quartus_pgm -m jtag -c 1 -o "p;output_files/top_system.sof"
