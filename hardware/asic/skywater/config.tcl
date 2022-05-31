# User config
set ::env(DESIGN_NAME) system
# Change if needed
set ::env(VERILOG_INCLUDE_DIRS) "designs/system/inc"
set ::env(VERILOG_FILES) "designs/system/src/*.v"
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"
set ::env(DESIGN_IS_CORE) 0
set ::env(DIE_AREA) "0 0 301500.060 300000.060"
set ::env(FP_SIZING) absolute
set ::env(DIODE_PADDING) {1};
set ::env(DIODE_INSERTION_STRATEGY) {1};
set ::env(FP_PDN_CORE_RING) 0
set ::env(PL_TARGET_DENSITY) 0.15
set ::env(PL_BASIC_PLACEMENT) 1
set ::env(CELL_PAD) 0
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(GLB_RT_MAXLAYER) "6"
set ::env(FP_PDN_CHECK_NODES) 0
set ::env(GLB_RT_LAYER_ADJUSTMENTS) 0.99,0,0,0,0,0
set ::env(FP_PDN_MACROS) {1}
set ::env(FP_PDN_RAILS_LAYER) {met1}
set ::env(FP_PDN_RAIL_OFFSET) {0}
set ::env(FP_PDN_RAIL_WIDTH) {0.48}
set ::env(FP_PDN_UPPER_LAYER) {met5}
set ::env(FP_PDN_VOFFSET) {19.62}
set ::env(FP_PDN_VPITCH) {153.6}
set ::env(FP_PDN_VSPACING) {1.7}
set ::env(FP_PDN_VWIDTH) {1.6}
set ::env(EXTRA_LEFS) [glob $::env(DESIGN_DIR)/macros/lef/*.lef]
set ::env(EXTRA_GDS_FILES) [glob $::env(DESIGN_DIR)/macros/gds/*.gds]
set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
