#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

set FAMILY "Cyclone V"
set DEVICE 5CGTFD9E5F35C7


# Pin & Location Assignments
# ==========================

#System 
set_location_assignment PIN_H19 -to clk
set_location_assignment PIN_AN8 -to resetn

set_instance_assignment -name IO_STANDARD LVDS -to clk
set_instance_assignment -name IO_STANDARD "2.5-V" -to resetn

#Leds
set_location_assignment  PIN_AM23 -to led
set_instance_assignment -name IO_STANDARD "2.5-V" -to led

set_location_assignment  PIN_AE25 -to trap
set_instance_assignment -name IO_STANDARD "2.5-V" -to trap
set_instance_assignment -name SLEW_RATE 1 -to trap
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to trap

#Uart
set_location_assignment PIN_F10 -to uart_txd
set_instance_assignment -name IO_STANDARD "2.5-V" -to uart_txd
set_instance_assignment -name SLEW_RATE 1 -to uart_txd
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to uart_txd
set_location_assignment PIN_C12 -to uart_rxd
set_instance_assignment -name IO_STANDARD "2.5-V" -to uart_rxd

