# TCL File Generated by Component Editor 11.1sp1
# Mon Jan 30 09:54:01 CST 2012
# DO NOT MODIFY


# +-----------------------------------
# | 
# | TERASIC_CLOCK_COUNT "TERASIC_CLOCK_COUNT" v1.0
# | null 2012.01.30.09:54:01
# | 
# | 
# | C:/svn/TR5-Lite-Q11.1/Q_TR5LE/ip/TERASIC_CLOCK/TERASIC_CLOCK_COUNT.v
# | 
# |    ./TERASIC_CLOCK_COUNT.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module TERASIC_CLOCK_COUNT
# | 
set_module_property NAME TERASIC_CLOCK_COUNT
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Terasic Qsys Component/"
set_module_property DISPLAY_NAME TERASIC_CLOCK_COUNT
set_module_property TOP_LEVEL_HDL_FILE TERASIC_CLOCK_COUNT.v
set_module_property TOP_LEVEL_HDL_MODULE TERASIC_CLOCK_COUNT
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property STATIC_TOP_LEVEL_MODULE_NAME TERASIC_CLOCK_COUNT
set_module_property FIX_110_VIP_PATH false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file TERASIC_CLOCK_COUNT.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk clockRate 0

set_interface_property clk ENABLED true

add_interface_port clk s_clk_in clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point Slave
# | 
add_interface Slave avalon end
set_interface_property Slave addressUnits WORDS
set_interface_property Slave associatedClock clk
set_interface_property Slave associatedReset reset
set_interface_property Slave bitsPerSymbol 8
set_interface_property Slave burstOnBurstBoundariesOnly false
set_interface_property Slave burstcountUnits WORDS
set_interface_property Slave explicitAddressSpan 0
set_interface_property Slave holdTime 0
set_interface_property Slave linewrapBursts false
set_interface_property Slave maximumPendingReadTransactions 0
set_interface_property Slave readLatency 0
set_interface_property Slave readWaitTime 1
set_interface_property Slave setupTime 0
set_interface_property Slave timingUnits Cycles
set_interface_property Slave writeWaitTime 0

set_interface_property Slave ENABLED true

add_interface_port Slave s_address_in address Input 2
add_interface_port Slave s_read_in read Input 1
add_interface_port Slave s_readdata_out readdata Output 32
add_interface_port Slave s_write_in write Input 1
add_interface_port Slave s_writedata_in writedata Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_in_ref
# | 
add_interface clk_in_ref conduit end

set_interface_property clk_in_ref ENABLED true

add_interface_port clk_in_ref CLK_1 export Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_in_target
# | 
add_interface clk_in_target conduit end

set_interface_property clk_in_target ENABLED true

add_interface_port clk_in_target CLK_2 export Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset s_reset_in reset Input 1
# | 
# +-----------------------------------
