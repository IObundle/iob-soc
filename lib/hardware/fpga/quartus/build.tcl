#extract cli args
set NAME [lindex $argv 0]
set BOARD [lindex $argv 1]
set VSRC [lindex $argv 2]
set IS_FPGA [lindex $argv 3]
set USE_EXTMEM [lindex $argv 4]
set SEED [lindex $argv 5]
set USE_QUARTUS_PRO [lindex $argv 6]

load_package flow

project_new $NAME -overwrite

if {[project_exists $NAME]} {
    project_open $NAME -force
} else {
    project_new $NAME
}

set_global_assignment -name TOP_LEVEL_ENTITY $NAME

#board data
source quartus/$BOARD/board.tcl

set_global_assignment -name FAMILY $FAMILY
set_global_assignment -name DEVICE $PART
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY reports
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

#verilog heders search path
set_global_assignment -name SEARCH_PATH ../src
set_global_assignment -name SEARCH_PATH ./src
set_global_assignment -name SEARCH_PATH quartus/$BOARD

#verilog sources, quartus IPs, use extension
foreach file [split $VSRC \ ] {
    if { [ file extension $file ] == ".qsys" } {
        set_global_assignment -name QSYS_FILE $file
    } elseif {$file != ""} {
        set_global_assignment -name VERILOG_FILE $file
    }
}

if {$IS_FPGA != "1"} {
    set_global_assignment -name INCREMENTAL_COMPILATION_EXPORT_NETLIST_TYPE POST_FIT
    set_global_assignment -name INCREMENTAL_COMPILATION_EXPORT_ROUTING OFF
}


#read synthesis design constraints
set_global_assignment -name SDC_FILE ./quartus/$BOARD/$NAME\_dev.sdc
set_global_assignment -name SDC_FILE ./src/$NAME.sdc

set_global_assignment -name SYNCHRONIZER_IDENTIFICATION "Forced if Asynchronous"


# random seed for fitting
set_global_assignment -name SEED $SEED

export_assignments

if {$USE_QUARTUS_PRO == 1} {
    set synth_tool "syn"
} else {
    set synth_tool "map"
}

#Incremental compilation
#run quartus pro synthesis
if {[catch {execute_module -tool $synth_tool} result]} {
    puts "\nResult: $result\n"
    puts "ERROR: Synthesis failed. See report files.\n"
    qexit -error
} else {
    puts "\nINFO: Synthesis was successful.\n"
}

if {$IS_FPGA != "1"} {
    #assign virtual pins
    set name_ids [get_names -filter * -node_type pin]
    foreach_in_collection name_id $name_ids {
        set pin_name [get_name_info -info full_path $name_id]
        post_message "Making VIRTUAL_PIN assignment to $pin_name"
        set_instance_assignment -to $pin_name -name VIRTUAL_PIN ON
    }
    
    export_assignments
    
    #rerun quartus pro synthesis to apply virtual pin assignments
    if {[catch {execute_module -tool $synth_tool} result]} {
        puts "\nResult: $result\n"
        puts "ERROR: Synthesis failed. See report files.\n"
        qexit -error
    } else {
        puts "\nINFO: Synthesis was successful.\n"
    }
}

#read post-synthesis script
if {[file exists "quartus/postmap.tcl"]} {
    source quartus/postmap.tcl
}

#read implementation design constraints
if {[file exists "quartus/$NAME\_tool.sdc"] == 0} {
    puts [open "quartus/$NAME\_tool.sdc" w] "derive_clock_uncertainty"
}
set_global_assignment -name SDC_FILE ./quartus/$NAME\_tool.sdc

#run quartus fit
if {[catch {execute_module -tool fit} result]} {
    puts "\nResult: $result\n"
    puts "ERROR: Fit failed. See report files.\n"
    qexit -error
} else {
    puts "\nINFO: Fit was successful.\n"
}

#run quartus sta
if {[catch {execute_module -tool sta} result]} {
    puts "\nResult: $result\n"
    puts "ERROR: STA failed. See report files.\n"
    qexit -error
} else {
    puts "\nINFO: STA was successful.\n"
}

#rerun quartus sta to generate reports
if [catch {qexec "[file join $::quartus(binpath) quartus_sta] -t quartus/timing.tcl $NAME"} result] {
    puts "\nResult: $result\n"
    puts "ERROR: STA failed. See report files.\n"
    qexit -error
} else {
    puts "\nINFO: STA was successful.\n"
}
    
if {$IS_FPGA != "1"} {

    #write netlist
    if {$USE_QUARTUS_PRO == 1} {
        if {[catch {execute_module -tool eda -args "--resynthesis --format verilog"} result]} {
            qexit -error
        }
    } else {
        if {[catch {execute_module -tool cdb -args "--vqm=resynthesis/$NAME"} result]} {
            qexit -error
        }
    }
    
    #rename netlist
    set netlist_file "$NAME\_netlist.v"
    if {[file exists $netlist_file] == 1} {
        file delete $netlist_file
    }
    file rename resynthesis/$NAME.vqm $netlist_file
} else {
    if {[catch {execute_module -tool asm} result]} {
        qexit -error
    }
    #Move bitstream out of the reports directory
    file rename reports/$NAME.sof $NAME.sof
}

project_close

#rename report files
file rename reports/$NAME.fit.summary reports/$NAME\_$PART.fit.summary
file rename reports/$NAME.sta.summary reports/$NAME\_$PART.sta.summary
