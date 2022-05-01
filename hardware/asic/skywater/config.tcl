# User config
set ::env(DESIGN_NAME) system
# Change if needed
set ::env(VERILOG_INCLUDE_DIRS) "designs/system/inc"
set ::env(VERILOG_FILES) "designs/system/src/*.v"
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(PL_TARGET_DENSITY) 0.5
set ::env(PL_BASIC_PLACEMENT) 1
set ::env(CELL_PAD) 0
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(RT_MAX_LAYER) {met4}
set ::env(FP_PDN_CHECK_NODES) 0
set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
