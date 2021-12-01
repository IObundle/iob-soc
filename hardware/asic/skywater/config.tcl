# User config

set ::env(DESIGN_NAME) system_core

# Change if needed
set ::env(VERILOG_FILES) "src/*.v"

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
