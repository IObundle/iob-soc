#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#
#--------------------------------------------------------------#
# 
# The following Tcl script instructs the Quartus Prime 
# software to create a project (or open it if it already 
# exists), make global assignments for family and device, 
# and include timing and location settings.
#
# There are two ways to compile a project after making 
# assignments. The first method, and the easiest, is 
# to use the ::quartus::flow package and call the Tcl 
# command "execute_flow -compile".
# 
# The second method is to call the Tcl command 
# "export_assignments" to write assignment changes to the 
# Quartus Prime Settings File (.qsf) before compiling the 
# design. Calling "export_assignments" beforehand is 
# necessary so that the command-line executables detect 
# the assignment changes.
# 
# After compilation, with either method, the script then 
# instructs the Quartus Prime software to write the project 
# databases and to compile using the command-line executables. 
# The script obtains the fmax result from the report database. 
# Finally, the script closes the project.
# 
#--------------------------------------------------------------#

#------ Get Slack from the Report File ------#

#------ Set the project name ------#
set project_name top_system


set INCLUDE [lindex $argv 0]
set DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]

set USE_DDR [string last "USE_DDR" $DEFINE]


load_package report

proc get_slack_from_report {} {
    global project_name

    load_report $project_name
    set panel "Timing Analyzer||Setup Summary"
    set panel_id [get_report_panel_id $panel]

    # Check if specified panel exists. Delete it if yes.
    if {$panel_id != -1} {
        delete_report_panel -id $panel_id
    }

    # Create the specified panel and get its id
    set panel_id    [create_report_panel -table $panel]

    set slack [get_report_panel_data -col_name Slack -row 1 -id $panel_id]

    unload_report $project_name

    return $slack
}

proc report_slack {} {
    set setup_slack [get_slack_from_report]
    set seed [get_global_assignment -name SEED]
    puts ""
    puts "-----------------------------------------------------"
    puts "Setup Slack for Seed $seed: $setup_slack"
    puts "-----------------------------------------------------"
}


#------ Create or open project ------#
if [project_exists $project_name] {

    #------ Project already exists -- open project -------#
    project_open $project_name -force
} else {

    #------ Project does not exist -- create new project ------#
    project_new $project_name
}


set_global_assignment -name TOP_LEVEL_ENTITY $project_name

source device.tcl

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

#if { $USE_DDR >= 0 } {
#set_global_assignment -name QIP_FILE qsys/alt_ddr3/synthesis/alt_ddr3.qip
#}

#file search paths
foreach path [split $INCLUDE \ ] {
    if {$path != ""} {
        set_global_assignment -name SEARCH_PATH $path
    }
}

#verilog macros
foreach macro [split $DEFINE \ ] {
    if {$macro != ""} {
        set_global_assignment -name VERILOG_MACRO $macro
    }
}

#verilog sources
foreach file [split $VSRC \ ] {
    if {[file extension $file] == ".qsys"} {
        set_global_assignment -name QSYS_FILE $file
    } elseif {$file != ""} {
        set_global_assignment -name VERILOG_FILE $file
    }
}

# Pin & Location Assignments
# ==========================

#Force registers into IOBs
#set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to *
#set_instance_assignment -name FAST_INPUT_REGISTER ON -to *
#set_instance_assignment -name FAST_OUTPUT_ENABLE_REGISTER ON -to *
set_global_assignment -name LAST_QUARTUS_VERSION "18.0.0 Standard Edition"
set_global_assignment -name SDC_FILE top_system.sdc
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"


#------ Compile using ::quartus::flow ------#
#execute_flow -compile

set_global_assignment -name SEED 23

#------ Manually recompile and perform timing analysis again using qexec ------#

# Write these assignments to the
# Quartus Prime Settings File (.qsf) so that
# the Quartus Prime command-line executables
# can use these assignments during compilation
export_assignments

if [catch {qexec "[file join $::quartus(binpath) quartus_map] $project_name"} result] {
    qexit -error
}

#used for hard macro with no success
if { $USE_DDR >= 0 } {
    source "./db/ip/alt_ddr3/submodules/alt_ddr3_mem_if_ddr3_emif_0_p0_parameters.tcl"
    source "./db/ip/alt_ddr3/submodules/alt_ddr3_mem_if_ddr3_emif_0_p0_pin_assignments.tcl"
}

# Compile the project and
# exit using "qexit" if there is an error
if [catch {qexec "[file join $::quartus(binpath) quartus_fit] $project_name"} result] {
    qexit -error
}
if [catch {qexec "[file join $::quartus(binpath) quartus_sta] $project_name"} result] {
    qexit -error
}
if [catch {qexec "[file join $::quartus(binpath) quartus_asm] $project_name"} result] {
    qexit -error
}


#------ Report Slack from report ------#
# TODO: commented below as it does not work
#report_slack

project_close

