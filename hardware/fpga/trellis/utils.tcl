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
proc create_lpf_file {board_revision} {
    # 6.0 and 8.0 have the same pin mapping
    if {$board_revision == "8.0"} {
        $board_revision = "6.0"
    }

    set pin_map_dict [dict create 6.0 {
        {LOCATE COMP "clk" SITE "P6"}
        {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
        {FREQUENCY PORT "clk" 25 MHZ}
        {LOCATE COMP "uart_rxd" SITE "R7"}
        {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
        {LOCATE COMP "uart_txd" SITE "T6"}
        {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
    } 7.1 {
        #TODO:
        }]

        set pin_map [dict get $pin_map_dict $board_revision]
        if { $pin_map == {} } {
            error "Error: REVISION variable must be: 6.0, 7.1 or 8.0"
        }

        set lpf_file [open "colorlight_5a-75e_$board_revision.lpf" w]
        puts $lpf_file [join $pin_map ";\n"]
        close $lpf_file
    }