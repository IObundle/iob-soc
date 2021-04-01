#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

set TOP top_system
set QUARTUS_VERSION "18.0.0 Standard Edition"
set FAMILY "MAX 10"
set DEVICE 10M50DAF484C7G

set HW_INCLUDE [lindex $argv 0]
set HW_DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]

project_new $TOP -overwrite

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

#constraints file

# Pin & Location Assignments
# ==========================

#System 
set_location_assignment PIN_N5 -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_location_assignment PIN_B8 -to resetn
instance_set_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to resetn

#Leds
set_location_assignment  PIN_A8 -to trap
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to trap
set_instance_assignment -name SLEW_RATE 1 -to trap
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to trap

#Uart
set_location_assignment PIN_V10 -to uart_txd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_txd
set_instance_assignment -name SLEW_RATE 1 -to uart_txd
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to uart_txd
set_location_assignment PIN_W10 -to uart_rxd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_rxd

#============================================================
# End of pin assignments
#============================================================


set_global_assignment -name LAST_QUARTUS_VERSION $QUARTUS_VERSION
set_global_assignment -name SDC_FILE top_system.sdc
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name ENABLE_OCT_DONE OFF
set_global_assignment -name EXTERNAL_FLASH_FALLBACK_ADDRESS 00000000
set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
set_global_assignment -name INTERNAL_FLASH_UPDATE_MODE "SINGLE IMAGE WITH ERAM"
set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"

project_close
