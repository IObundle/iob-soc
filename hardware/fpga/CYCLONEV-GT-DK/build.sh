#!/usr/bin/bash
export ALTERAPATH=/home/iobundle/Intel/Altera_full/18.0
export LM_LICENSE_FILE=1801@localhost:$ALTERAPATH/../1-MVXX5H_License.dat
nios=/home/iobundle/Intel/Altera_full/18.0/nios2eds/nios2_command_shell.sh
$nios quartus_sh -t top_system.tcl "$1" "$2" "$3"
$nios quartus_map top_system
$nios quartus_fit --read_settings_files=off -write_settings_files=off top_system -c top_system
$nios quartus_sta top_system -c top_system --do_report_timing
$nios quartus_asm top_system
