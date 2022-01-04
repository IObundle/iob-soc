# User config

set ::env(DESIGN_NAME) system

# Change if needed
set ::env(VERILOG_FILES) "\
    designs/system/src/system.v\
    designs/system/src/boot_ctr.v\
    designs/system/src/int_mem.v\
    designs/system/src/iob_sp_ram_be.v\
    designs/system/src/iob_sp_rom.v\
    designs/system/src/iob_picorv32.v\
    designs/system/src/iob_uart.v\
    designs/system/src/merge.v\
    designs/system/src/picorv32.v\
    designs/system/src/split.v\
    designs/system/src/sram.v\
    designs/system/src/uart_core.v"

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"
#for non interactive macro placement -please do not remove-
#set ::env(MACRO_PLACEMENT_CFG) $::env(OPENLANE_HOME)/designs/$::env(DESIGN_NAME)/macro_placement.cfg

#variables to set macro to be placed as macro (not core i.e., without io ring/pad)
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
#variables to prohibit router from using metal 5 for routing. Router will use up to met4 before macro placement
set ::env(GLB_RT_MAXLAYER) 5
#lef and gds files from generated OpenRAM (sram)
set ::env(EXTRA_LEFS) [glob $::env(DESIGN_DIR)/macros/lef/*.lef]
set ::env(EXTRA_GDS_FILES) [glob $::env(DESIGN_DIR)/macros/gds/*.gds]
set ::env(DIE_AREA) "0 0 812.060 422.780"
set ::env(FP_SIZING) absolute
set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
