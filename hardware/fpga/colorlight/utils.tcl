# Add "-I" for each include path (needed by 'verilog_defaults -add')
proc set_include_path {include_path} {
    set INCLUDE_PATH ""
    foreach path [split $include_path \ ] {
        if {$path != "" && $path != "."} {
            set INCLUDE_PATH "$INCLUDE_PATH -I$path"
        }
    }
    return $INCLUDE_PATH
}

# Auto generates a pin constraint file depending on the board revision
# in this case, board's pin_constraints.tcl must have a dictionary
proc create_lpf_file_dict {board board_revision pin_map_dict} {
    set pin_map [dict get $pin_map_dict $board_revision]
    if { $pin_map == {} } {
        error "Error: Could not get PIN constraints of $board ($board_revision) \n"
    }

    lappend pin_map "" ;# fixes last line not having semicolon
    set lpf_file [open "${board}_$board_revision.lpf" w]
    puts $lpf_file [join $pin_map ";\n"]
    close $lpf_file
}