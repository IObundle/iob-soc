#import functions from utils.tcl
#since top_system.tcl is getting executed inside board folder
#we have to go back 1 folder 
source ../utils.tcl

set project_name top_system

# FIXME:
# iob_ram_sp_be/iob_ram_dp_be + main_mem_byte from hardware/src/sram.v are causing problems
# the problem is that ram block isn't being instantiated as BRAM,
# but as (many) individual flip-flops per bit.
# and because of this, the synthesis is taking **literally** ages
# so if you want to compile the bitstream, you have to:
# - comment sram.v
# - add -no-rw-check to synth (it might break some things(?))

set INCLUDE [lindex $argv 0]
set DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]
set REVISION [lindex $argv 3]

#------ Auto generate pin constraints ------#
create_lpf_file $REVISION

#------ Set include path ------#
set INCLUDE_PATH [set_include_path $INCLUDE]

#------ Synthesis (yosys script) ------#
puts "\n-> Synthesizing design...\n"
set yosys_script "$project_name.ys"
set yosys_script_handle [open $yosys_script "w"]
puts $yosys_script_handle "read -define $DEFINE \n"
puts $yosys_script_handle "verilog_defaults -add $INCLUDE_PATH \n"
puts $yosys_script_handle "read_verilog $VSRC \n"
puts $yosys_script_handle "synth_ecp5 -no-rw-check -top $project_name -json $project_name.json \n"
close $yosys_script_handle
exec yosys -T $yosys_script -t -q -ql "${project_name}_synthesis.log"

#------ Place & Route ------#
puts "-> Synthesis done! Place & Route now\n"
exec -ignorestderr nextpnr-ecp5 \
    --ignore-loops --25k --package CABGA256 --speed 6 --freq 25 \
    --json $project_name.json --textcfg $project_name.config \
    --lpf $project_name.lpf --lpf-allow-unconstrained -ql "${project_name}_pnr.log"
# TODO: $pin_mapping_file should be auto generated for each board revision (6.0/8.0, 7.1, etc..)
# FIXME: does '--ignore-loops' break the system?

#------ Bitstream Generation ------#
puts "-> Place & Route done! Generating bitstream... \n"
exec ecppack --svf $project_name.svf ${project_name}.config $project_name.bit

# DONE!
puts "-> Bitstream generated! ($project_name.bit) \n"



