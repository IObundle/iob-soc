#----------------------------------------------------------------------
# Copyright (c) 2017 CAST, Inc.
# Copyright (c) 2023 IObundle, Lda.
#
# Please review the terms of the license agreement before using this
# file.  If you are not an authorized user, please destroy this source
# code file and notify CAST immediately that you inadvertently received
# an unauthorized copy.
#----------------------------------------------------------------------
#  GENUS template;  requires design.tcl  to set variables and path 
#----------------------------------------------------------------------
#
#

#
# set DESIGN and hdl_search_path paths
#
source config.tcl

set OUTPUTS_DIR "./${OUTPUT_DIR}"

set_db init_hdl_search_path $INCLUDE

set_db stdout_log genus.log
set_db information_level 7
set_db super_thread_debug_directory st_part_log
set_db hdl_error_on_latch true
if {[file exists "genus/syn_build.tcl"]} {
    source "genus/syn_build.tcl"
}
set_db lp_power_analysis_effort medium
set_db lp_power_unit uW

#set max loop limit to 64k
set_db hdl_max_loop_limit 65536

set_db super_thread_servers [string repeat "localhost " 4]
# max 8 cpus for 1 license,  max 16 for 2 licenses
set_db max_cpus_per_server 6


  # Error on combinational loop
  set_db message:TIM/TIM-20 .severity Error
  # Error on multiple drivers
  set_db message:CDFG2G/CDFG2G-622 .severity Error

  ##### Reduce noise
  # "Ignoring delay"
  #set_attribute max_print 0 /messages/VLOGPT/VLOGPT-35
  # "Ignoring after clause"
  #set_attribute max_print 0 /messages/VHDL/VHDL-616
  # These two made up nearly 20% of the report..
  # "Connecting all ... to TIELO/TIEHI cells" repeat too often
  #set_attribute max_print 10 /messages/UTUI/UTUI-207
  # "Unused hierarchical pins are ignored for tie-cell insertion"
  #set_attribute max_print 10 /messages/UTUI/UTUI-202

 #LIBRARY messages
 set_db message:LBR/LBR-9   .max_print 3
 set_db message:LBR/LBR-40   .max_print 3
 set_db message:LBR/LBR-66   .max_print 3
 set_db message:LBR/LBR-76   .max_print 3
 set_db message:LBR/LBR-136   .max_print 3
 set_db message:PHYS/PHYS-15   .max_print 3
 set_db message:PHYS/PHYS-129   .max_print 3
 set_db message:PHYS/PHYS-2381   .max_print 3
 set_db message:CDFG/CDFG-500 .max_print 3
 set_db message:CDFG/CDFG-508 .max_print 3


# general setup
#----------------------------------------------------------------------
set_db auto_super_thread true

set DATE [clock format [clock seconds] -format "%b%d-%T"]

if {![file exists ${OUTPUTS_DIR}]} {
  file mkdir ${OUTPUTS_DIR}
  puts "Creating directory ${OUTPUTS_DIR}"
}

#load the library 
#----------------------------------------------------------------------
source $NODE/genus.setup.tcl
if {[file exists $NODE/mems/genus.mems.tcl]} {
   source $NODE/mems/genus.mems.tcl
}

# retain hierarchy to see area
#set_attribute auto_ungroup none /

# load and elaborate the design
#----------------------------------------------------------------------
#

#
# verilog source files, includes, design and node
#
echo "\n\n"
echo "NODE=" $NODE
echo "\n\n"
echo "NAME=" $NAME
echo "\n\n"
echo "CSR_IF=" $CSR_IF
echo "\n\n"
echo "DESIGN=" $DESIGN
echo "\n\n"
echo "INCLUDE=" $INCLUDE
echo "\n\n"
echo "VSRC=" $VSRC
echo "\n\n"

#
# verilog read
#
read_hdl -v2001 $VSRC

#
# elaborate
#
elaborate $DESIGN

timestat Elaboration

check_design -unresolved

# add optimization constraints
#----------------------------------------------------------------------
if {[file exists ./$NODE/$NAME\_dev.sdc]} {
    read_sdc -stop_on_error ./$NODE/$NAME\_dev.sdc
}

if {[file exists ./src/$NAME.sdc]} {
    read_sdc -stop_on_error ./src/$NAME.sdc
}

if {[file exists ./src/$NAME\_$CSR_IF.sdc]} {
    read_sdc -stop_on_error ./src/$NAME\_$CSR_IF.sdc
}

if {[file exists ./$NAME\_tool.sdc]} {
    read_sdc -stop_on_error ./$NAME\_tool.sdc
}

check_timing_intent 

check_design -all > $OUTPUTS_DIR/${DESIGN}_check_design.rpt

#LP
#set_db lp_insert_clock_gating true 
#set_db retime ?

# synthesize the design 
#----------------------------------------------------------------------
set_db syn_global_effort medium
set_db syn_generic_effort medium
syn_generic

report timing -lint -verbose > $OUTPUTS_DIR/${DESIGN}_lint_gen_timing.rpt

set_db syn_map_effort medium
syn_map

set_db syn_opt_effort medium
syn_opt

timestat Synthesis


# analyze results
#----------------------------------------------------------------------

report_area > $OUTPUTS_DIR/${DESIGN}_area.rpt

report_area -summary > $OUTPUTS_DIR/${DESIGN}_area_summary.rpt

report_gates > $OUTPUTS_DIR/${DESIGN}_gates.rpt

report_clocks > $OUTPUTS_DIR/${DESIGN}_clk.rpt

report_timing -max_paths 30 > $OUTPUTS_DIR/${DESIGN}_timing.rpt

report_power -by_hierarchy -format %.2f -levels 2  -unit uW  > $OUTPUTS_DIR/${DESIGN}_power.rpt

report_gates -power > $OUTPUTS_DIR/${DESIGN}_gates-power.rpt

report_qor > $OUTPUTS_DIR/${DESIGN}_qor.rpt

puts "============================"
puts "Synthesis Finished ........."
puts "============================"

if {[file exists "post_syn.tcl"]} {
  source post_syn.tcl
}

write_hdl -mapped -v2001 > $OUTPUTS_DIR/${DESIGN}_synth.v 

timestat FINAL
quit
