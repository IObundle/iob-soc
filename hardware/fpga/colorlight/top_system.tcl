source ../utils.tcl
source pin_constraints.tcl

set PROJECT_NAME top_system
set INCLUDE [lindex $argv 0]
set DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]
set BOARD [lindex $argv 3]
set REVISION [lindex $argv 4]

#------ Auto generate pin constraints ------#
if { $REVISION in $POSSIBLE_REVISIONS } {
    create_lpf_file_dict $BOARD $REVISION $PIN_MAP_DICT
} else {
    error "Error: REVISION for $BOARD must be one of these options: $POSSIBLE_REVISIONS \n"
}

#------ Set include path ------#
set INCLUDE_PATH [set_include_path $INCLUDE]

#------ Synthesis (yosys script) ------#
puts "\n-> Synthesizing design...\n"
set yosys_script "$PROJECT_NAME.ys"
set yosys_script_handle [open $yosys_script "w"]
puts $yosys_script_handle "read -define $DEFINE \n"
puts $yosys_script_handle "verilog_defaults -add $INCLUDE_PATH \n"
puts $yosys_script_handle "read_verilog $VSRC \n"
puts $yosys_script_handle "synth_ecp5 -no-rw-check -top $PROJECT_NAME -json $PROJECT_NAME.json \n"
close $yosys_script_handle
exec yosys -T $yosys_script -q -q -t -l "${PROJECT_NAME}_synthesis.log"

#------ Place & Route ------#
puts "-> Synthesis done! Place & Route now\n"
set pnr_arguments [dict get $EXTRA_PNR_ARGUMENTS $REVISION] ;# board+revision specific p&r arguments
eval exec -ignorestderr nextpnr-ecp5 $pnr_arguments \
    --json $PROJECT_NAME.json --textcfg $PROJECT_NAME.config \
    --lpf ${BOARD}_$REVISION.lpf --lpf-allow-unconstrained \
    -ql "${PROJECT_NAME}_pnr.log"

#------ Bitstream Generation ------#
puts "-> Place & Route done! Generating bitstream... \n"
exec ecppack --svf $PROJECT_NAME.svf ${PROJECT_NAME}.config $PROJECT_NAME.bit

# DONE!
puts "-> Bitstream generated! ($PROJECT_NAME.bit) \n"



