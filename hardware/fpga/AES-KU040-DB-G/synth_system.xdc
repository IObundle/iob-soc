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

## System Clock 
# LVDS Programmable Clock Generator (CDCM61002)
#set_property  PACKAGE_PIN M5   [get_ports LVDS_CLK0_N]
#set_property  PACKAGE_PIN M6   [get_ports LVDS_CLK0_P]
#set_property  PACKAGE_PIN P5   [get_ports LVDS_CLK1_N]
#set_property  PACKAGE_PIN P6   [get_ports LVDS_CLK1_P]

#set_property  IOSTANDARD LVDS [get_ports LVDS_CLK0_N]
#set_property  IOSTANDARD LVDS [get_ports LVDS_CLK0_P]
#set_property  IOSTANDARD LVDS [get_ports LVDS_CLK1_N]
#set_property  IOSTANDARD LVDS [get_ports LVDS_CLK1_P]

##DDR clocks
set_property PACKAGE_PIN H22 [get_ports c0_sys_clk_clk_p]
set_property PACKAGE_PIN H23 [get_ports c0_sys_clk_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports c0_sys_clk_clk_n]

#create_clock -period 4.000 [get_ports c0_sys_clk_clk_p]  

#derive_pll_clocks
#derive_clock_uncertainty

set_property CFGBVS VCCO [current_design]

## USB-UART Interface
set_property PACKAGE_PIN D20 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_txd]
set_property PACKAGE_PIN C19 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_rxd]

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

set_property PACKAGE_PIN H17 [get_ports {trap}]
set_property IOSTANDARD LVCMOS18 [get_ports {trap}]

####### User PUSH Switches
set_property PACKAGE_PIN K20 [get_ports {reset}]
set_property IOSTANDARD LVCMOS12 [get_ports {reset}]

#set_property PACKAGE_PIN K18 [get_ports {gpio_push_sw_tri_i[0]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[0]}]

#set_property PACKAGE_PIN L18 [get_ports {gpio_push_sw_tri_i[1]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[1]}]

#set_property PACKAGE_PIN K21 [get_ports {gpio_push_sw_tri_i[2]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[2]}]

#set_property PACKAGE_PIN K20 [get_ports {gpio_push_sw_tri_i[3]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {gpio_push_sw_tri_i[3]}]
