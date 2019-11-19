# ----------------------------------------------------------------------------
#     _____
#    /     \
#   /____   \____
#  / \===\   \==/
# /___\===\___\/  AVNET Design Resource Center
#      \======/         www.em.avnet.com/drc
#       \====/    
# ----------------------------------------------------------------------------
#  
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2009 Avnet, Inc.
#                              All rights reserved.
# 
# ----------------------------------------------------------------------------

## 250MHz System Clock 
set_property IOSTANDARD DIFF_SSTL12 [get_ports C0_SYS_CLK_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports C0_SYS_CLK_clk_n]
#set_property PACKAGE_PIN H22 [get_ports C0_SYS_CLK_clk_p]
#set_property PACKAGE_PIN H23 [get_ports C0_SYS_CLK_clk_n]
#set_property IOSTANDARD LVCMOS18 [get_ports clk]
#set_property PACKAGE_PIN H22 [get_ports clk]

#set_property CFGBVS VCCO [current_design] 
#######where value1 is either VCCO or GND
#set_property CONFIG_VOLTAGE 3.3 [current_design] 
########where value2 is the voltage provided to configuration bank 0

create_clock -period 4.000 [get_ports C0_SYS_CLK_clk_p]  


## USB-UART Interface
#set_property PACKAGE_PIN D20 [get_ports ser_tx]
set_property IOSTANDARD LVCMOS18 [get_ports ser_tx]
#set_property PACKAGE_PIN C19 [get_ports ser_rx]
set_property IOSTANDARD LVCMOS18 [get_ports ser_rx]

###### User LEDs
#set_property PACKAGE_PIN D16 [get_ports {led[6]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[6]}]

#set_property PACKAGE_PIN G16 [get_ports {led[5]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[5]}]

#set_property PACKAGE_PIN H16 [get_ports {led[4]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[4]}]

#set_property PACKAGE_PIN E18 [get_ports {led[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]

#set_property PACKAGE_PIN E17 [get_ports {led[2]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]

#set_property PACKAGE_PIN E16 [get_ports {led[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]

#set_property PACKAGE_PIN H18 [get_ports {led[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]

#set_property PACKAGE_PIN H17 [get_ports {trap}]
set_property IOSTANDARD LVCMOS18 [get_ports {trap}]


####### User PUSH Switches
#set_property PACKAGE_PIN K20 [get_ports {reset}]
set_property IOSTANDARD LVCMOS12 [get_ports {reset}]

### User PUSH Switches
#set_property PACKAGE_PIN K18 [get_ports {gpio_push_sw_tri_i[0]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[0]}]

#set_property PACKAGE_PIN L18 [get_ports {gpio_push_sw_tri_i[1]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[1]}]

#set_property PACKAGE_PIN K21 [get_ports {gpio_push_sw_tri_i[2]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[2]}]

#set_property PACKAGE_PIN K20 [get_ports {gpio_push_sw_tri_i[3]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[3]}]

