#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

set FAMILY "MAX 10"
set DEVICE 10M50DAF484C7G


# Pin & Location Assignments
# ==========================

#System
set_location_assignment PIN_P11 -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_location_assignment PIN_B8 -to resetn
set_instance_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to resetn

#Leds
set_location_assignment  PIN_A8 -to trap
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to trap
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to trap

#Uart
set_location_assignment PIN_V10 -to uart_txd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_txd
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to uart_txd
set_location_assignment PIN_W10 -to uart_rxd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_rxd

#============================================================
# End of pin assignments
#============================================================

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
