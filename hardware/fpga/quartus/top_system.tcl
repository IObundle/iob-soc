#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

set TOP top_system
set QUARTUS_VERSION "18.0.0 Standard Edition"

set HW_INCLUDE [lindex $argv 0]
set HW_DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]

project_new $TOP -overwrite

source device.tcl


set_global_assignment -name FAMILY $FAMILY
set_global_assignment -name DEVICE $DEVICE
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name TOP_LEVEL_ENTITY $TOP
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

#file search paths
foreach path [split $HW_INCLUDE \ ] {
    if {$path != ""} {
        set_global_assignment -name SEARCH_PATH $path
    }
}

#verilog macros
foreach macro [split $HW_DEFINE \ ] {
    if {$macro != ""} {
        set_global_assignment -name VERILOG_MACRO $macro
    }
}

#verilog sources
foreach file [split $VSRC \ ] {
    if {$file != ""} {
        set_global_assignment -name VERILOG_FILE $file
    }
}

# Pin & Location Assignments
# ==========================

#Force registers into IOBs
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to *
set_instance_assignment -name FAST_INPUT_REGISTER ON -to *
#set_instance_assignment -name FAST_OUTPUT_ENABLE_REGISTER ON -to *
set_global_assignment -name LAST_QUARTUS_VERSION $QUARTUS_VERSION
set_global_assignment -name SDC_FILE top_system.sdc
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"

project_close
