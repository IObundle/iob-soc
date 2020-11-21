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
set_property PACKAGE_PIN F23 [get_ports c0_sys_clk_clk_p]
set_property PACKAGE_PIN E23 [get_ports c0_sys_clk_clk_n]
set_property IOSTANDARD LVDS [get_ports c0_sys_clk_clk_p]
set_property IOSTANDARD LVDS [get_ports c0_sys_clk_clk_n]


set_property PACKAGE_PIN M11      [get_ports "reset"] ;# Bank  87 VCCO - VCC3V3   - IO_L4N_AD8N_87
set_property IOSTANDARD  LVCMOS33 [get_ports "reset"] ;# Bank  87 VCCO - VCC3V3   - IO_L4N_AD8N_87

 
create_clock -period 8.000 [get_ports c0_sys_clk_clk_p]  


## USB-UART Interface
set_property PACKAGE_PIN C19 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_txd]
set_property PACKAGE_PIN A20 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_rxd]
