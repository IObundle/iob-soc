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
proc create_lpf_file_dict {board_version board_revision pin_map_dict} {
    set pin_map [dict get $pin_map_dict $board_revision]
    if { $pin_map == {} } {
        error "Error: Could not get PIN MAPPING of $board_version $board_revision \n"
    }

    set lpf_file [open "colorlight_$board_version-_-$board_revision.lpf" w]
    puts $lpf_file [join $pin_map ";\n"]
    close $lpf_file
}

# Auto generates a pin constraint file depending on the board revision
proc create_lpf_file {board_version pin_map} {
    if { $pin_map == {} } {
        error "Error: Could not get PIN MAPPING of $board_version \n"
    }

    set lpf_file [open "colorlight_$board_version.lpf" w]
    puts $lpf_file [join $pin_map ";\n"]
    close $lpf_file
}